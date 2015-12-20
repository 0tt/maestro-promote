local times = {}
if mysql then
    local q = mysql:Create("maestro_tempo")
        q:Create("id", "VARCHAR(32) NOT NULL")
        q:Create("time", "INT NOT NULL")
    q:Execute()
    maestro.hook("PlayerInitialSpawn", "maestro-tempo", function(ply)
        local s = mysql:Select("maestro_tempo")
            s:Where("id", ply:SteamID())
            s:Callback(function(res, status, id)
                if type(res) == "table" and #res > 0 then
                    times[ply] = CurTime() - res[1].time
                    ply:SetNWInt("maestro-tempo", times[ply])
                else
                    local q = mysql:Insert("maestro_tempo")
                        q:Insert("id", ply:SteamID())
                        q:Insert("time", math.floor(ply:GetPData("maestro-tempo", 0)))
                    q:Execute()
                    times[ply] = CurTime() - ply:GetPData("maestro-tempo", 0)
                    ply:SetNWInt("maestro-tempo", times[ply])
                end
            end)
        s:Execute()
    end)
    timer.Create("maestro-tempo", 30, 0, function()
        for k, v in pairs(player.GetAll()) do
            times[v] = times[v] or CurTime()
            local time = CurTime() - times[v]
            local q = mysql:Update("maestro_tempo")
                q:Update("time", math.floor(time))
                q:Where("id", v:SteamID())
            q:Execute()
        end
    end)
    maestro.hook("PlayerDisconnected", "maestro-tempo", function(ply)
        times[ply] = times[ply] or CurTime()
        local time = CurTime() - times[ply]
        local q = mysql:Update("maestro_tempo")
            q:Update("time", math.floor(time))
            q:Where("id", v:SteamID())
        q:Execute()
        times[ply] = nil
    end)
else
    maestro.hook("PlayerInitialSpawn", "maestro-tempo", function(ply)
        times[ply] = CurTime() - ply:GetPData("maestro-tempo", 0)
        ply:SetNWInt("maestro-tempo", times[ply])
    end)
    timer.Create("maestro-tempo", 30, 0, function()
        for k, v in pairs(player.GetAll()) do
            times[v] = times[v] or CurTime()
            local time = CurTime() - times[v]
            v:SetPData("maestro-tempo", time)
        end
    end)
    maestro.hook("PlayerDisconnected", "maestro-tempo", function(ply)
        times[ply] = times[ply] or CurTime()
        local time = CurTime() - times[ply]
        ply:SetPData("maestro-tempo", time)
        times[ply] = nil
    end)
end
