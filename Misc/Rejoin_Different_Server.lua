local DelaySeconds = 1
local ServerListLimit = 100

function RejoinNewServer(teleportDelay: number,serverLimit: number)
	teleportDelay = teleportDelay or 1
	serverLimit = serverLimit or 100
	serverLimit = math.clamp(serverLimit,1,100) -- rbx api won't allow more than 100
	local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=%s"):format(game.PlaceId,tostring(serverLimit))

	-- afaik this will only work with: synapse, script-ware, krnl, and protosmasher. or it will default to the rbx http get. 
	local req = (syn and syn.request) or (http and http.request) or http_request or request or function() local resp = {}; resp.Body = game:HttpGetAsync(url); return resp.Body end
	local Response = nil
	pcall(function() 
		Response = req({
			Url = url,
			Method = "GET"
		})
	end)
	if not Response then print("HTTP Request Call Failed"); return false end

	local currJobId = game.JobId
	local newJobId = nil
	local justInCase = 0
	local respJson = nil
	pcall(function() respJson = game:GetService("HttpService"):JSONDecode(Response.Body) end)
	if (respJson) then
		for i,v in pairs(respJson) do
			if (i == "data" and v and #v > 0) then
				while (justInCase < serverLimit and (newJobId == nil or newJobId == currJobId)) do
					justInCase = justInCase + 1
					local sel = math.random(1,#v)
					newJobId = v[sel].id
				end
			end
		end
	else
		print("Unexpected Response >>>",Response.StatusCode,Response.StatusMessage,Response.Body)
	end

	if (newJobId ~= nil) then
		local ts = game:GetService('TeleportService')
		local p = nil
		pcall(function()
			p = game:GetService("Players").LocalPlayer
			p:Kick(('Rejoining to new server instance in %ss.'):format(tostring(teleportDelay)))
		end)
		if (teleportDelay > 0) then
			wait(teleportDelay)
		end
		ts:TeleportToPlaceInstance(game.PlaceId,newJobId,p)
		print("Teleported!")
		return true
	else
		print("Failed to get new jobid. Try bigger limit?")
		return false
	end
end
-- will keep trying every 2s until it works. this is meant for example.. do your own thing ofc :P 
while not RejoinNewServer(DelaySeconds,ServerListLimit) do wait(2) end