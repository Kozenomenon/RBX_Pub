local same = true
if same then
    local ts = game:GetService('TeleportService')
    --ts:Teleport(game.PlaceId)
    
    local origPID = game.PlaceId
    
    pcall(function()
        local p = game:GetService("Players").LocalPlayer
        p:Kick('boo hoo')
    end)
    
    wait(1)
    ts:Teleport(origPID)
else
    -- load it to local var. returns func
	local rj = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Kozenomenon/RBX_Pub/main/Misc/Rejoin_Different_Server.lua"))()
	-- call the func w/ defaults
	rj()    
end