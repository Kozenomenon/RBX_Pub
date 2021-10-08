--[[
	KoZ Rejoin Different Server Script
	Changed to be a module so I can just loadstring this for my own scripts like so: 
		-- load it to local var. returns func
		local rj = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Kozenomenon/RBX_Pub/main/Misc/Rejoin_Different_Server.lua"))
		-- call the func w/ defaults
		rj()
		-- or call the func pass in different values
		rj(5,0.5,30,true,false)
		-- or you may want use coroutine so rest of your script keeps going until it works
		coroutine.wrap(rj)()
]]
local LoopRetryDelaySeconds = 10
local DelaySeconds = 1
local ServerListLimit = 100
local SkipPlayerKick = false
local TeleportSameServerIfRequestFails = true

function RejoinNewServer(teleportDelay: number,serverLimit: number,skipKick: boolean,teleportSameSvrOnReqFail: boolean)
	teleportDelay = teleportDelay or 1
	serverLimit = serverLimit or 100
	serverLimit = math.clamp(serverLimit,1,100) -- rbx api won't allow more than 100
	local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=%s"):format(game.PlaceId,tostring(serverLimit))

	-- afaik this will only work with: synapse, script-ware, krnl, and protosmasher. or it will default to the rbx http get. 
	local req = (syn and syn.request) or (http and http.request) or http_request or request or function() local resp = {}; resp.Body = game:HttpGetAsync(url); return resp end
	local Response 
	pcall(function() 
		Response = req({
			Url = url,
			Method = "GET"
		})
	end)
	if not Response then 
		print("HTTP Request Call Failed"); 
		if not teleportSameSvrOnReqFail then
			return false 
		end
	end

	local currJobId = game.JobId
	local newJobId 
	local justInCase = 0
	local respJson 
	if Response and Response.Body then
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
			if not teleportSameSvrOnReqFail then
				return false 
			end
		end
	end

	if (newJobId ~= nil) then
		local p 
		pcall(function()
			p = game:GetService("Players").LocalPlayer
			local msg = ('Rejoining to new server instance in %ss.'):format(tostring(teleportDelay))
			if not skipKick then
				p:Kick(msg)
			else
				print(msg)
			end
		end)
		if (teleportDelay > 0) then
			wait(teleportDelay)
		end
		game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,newJobId,p)
		print("Teleporting to new server...")
		return true
	else
		print("Failed to get new jobid. Try bigger limit?")
		if teleportSameSvrOnReqFail then
			print(('Rejoining in %ss.'):format(tostring(teleportDelay)))
			if (teleportDelay > 0) then
				wait(teleportDelay)
			end
			game:GetService('TeleportService'):Teleport(game.PlaceId)
			print("Teleported...")
		else
			return false
		end
	end
end
 
return function(loopRetrySeconds: number,tpDelaySeconds: number,svrListLimit: number,skipKick: boolean,tpSameSvrOnReqFail: boolean)
	LoopRetryDelaySeconds = loopRetrySeconds or LoopRetryDelaySeconds
	DelaySeconds = tpDelaySeconds or DelaySeconds
	ServerListLimit = svrListLimit or ServerListLimit
	if skipKick~=nil then
		SkipPlayerKick = skipKick
	end
	if tpSameSvrOnReqFail~=nil then
		TeleportSameServerIfRequestFails = tpSameSvrOnReqFail
	end
	-- will keep trying every X seconds until it works. edit values at top
	while not RejoinNewServer(DelaySeconds,ServerListLimit,SkipPlayerKick,TeleportSameServerIfRequestFails) do 
		wait(LoopRetryDelaySeconds) 
	end
end