local times = {}
if mysql then
    local q = mysql:Create("maestro_promote")
        q:Create("id", "VARCHAR(32) NOT NULL")
        q:Create("time", "INT NOT NULL")
    q:Execute()
    maestro.hook("PlayerInitialSpawn", "maestro-promote", function(ply)
        local s = mysql:Select("maestro_promote")
            s:Where("id", ply:SteamID())
            s:Callback(function(res, status, id)
                if type(res) == "table" and #res > 0 then
                    times[ply] = CurTime() - res[1].time
                    ply:SetNWInt("maestro-promote", times[ply])
                else
                    local q = mysql:Insert("maestro_promote")
                        q:Insert("id", ply:SteamID())
                        q:Insert("time", math.floor(ply:GetPData("maestro-promote", 0)))
                    q:Execute()
                    times[ply] = CurTime() - ply:GetPData("maestro-promote", 0)
                    ply:SetNWInt("maestro-promote", times[ply])
                end
            end)
        s:Execute()
    end)
    timer.Create("maestro-promote-update", 30, 0, function()
        for k, v in pairs(player.GetAll()) do
            times[v] = times[v] or CurTime()
            local time = CurTime() - times[v]
            local q = mysql:Update("maestro_promote")
                q:Update("time", math.floor(time))
                q:Where("id", v:SteamID())
            q:Execute()
        end
    end)
    maestro.hook("PlayerDisconnected", "maestro-promote", function(ply)
        times[ply] = nil
    end)
else
    maestro.hook("PlayerInitialSpawn", "maestro-promote", function(ply)
        times[ply] = CurTime() - ply:GetPData("maestro-promote", 0)
        ply:SetNWInt("maestro-promote", times[ply])
    end)
    timer.Create("maestro-promote-update", 30, 0, function()
        for k, v in pairs(player.GetAll()) do
            times[v] = times[v] or CurTime()
            local time = CurTime() - times[v]
            v:SetPData("maestro-promote", time)
        end
    end)
    maestro.hook("PlayerDisconnected", "maestro-promote", function(ply)
        times[ply] = times[ply] or CurTime()
        local time = CurTime() - times[ply]
        ply:SetPData("maestro-promote", time)
        times[ply] = nil
    end)
end

local promote = {}
maestro.load("promote", function(ret, newfile)
    promote = ret
end)
function maestro.rankpromote(name, time)
    promote[name] = time
    maestro.save("promote", promote)
end

timer.Create("maestro_promote", 1, 0, function()
    for ply, playtime in pairs(times) do
        local ranks = maestro.targetrank(">^", maestro.userrank(ply))
        playtime = CurTime() - playtime
        for rank in pairs(ranks) do
            if promote[rank] then
                if promote[rank] <= playtime then
                    maestro.userrank(ply, rank)
                    maestro.chat(nil, ply, Color(255, 255, 255), " has been promoted to ", maestro.blue, rank, Color(255, 255, 255), "!")
                end
            end
        end
    end
end)
