local ts = game:GetService('TeleportService')
--ts:Teleport(game.PlaceId)

local origPID = game.PlaceId

local p = game:GetService("Players").LocalPlayer

p:Kick('boo hoo')
wait(8)
ts:Teleport(origPID)