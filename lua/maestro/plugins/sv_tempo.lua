local times = {}
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
