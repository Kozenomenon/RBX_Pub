--[[
	Rejoin Preferred Server Script by Kozenomenon#0001

	Settings allow you to define your preferences for finding a server to rejoin to.
	Primary sort is by player count, smallest or largest preferred.
	When counts match secondary sort uses fps and ping.

	-- to call this from github source
	local rejoinPreferred = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Kozenomenon/RBX_Pub/main/Misc/Rejoin_Preferred_Server.lua"))
	rejoinPreferred({
		SizeSort = "asc",
		MinPlayers = 0,
		MaxPlayers = 0,
		ExcludeFull = true,
		ExcludeSame = true,
		MinFps = 55,
		MaxPing = 190
	})

]]

-- settings you can adjust
local prefer = {
	SizeSort = "asc",		-- 'asc' or 'desc' - asc will prefer smallest, desc will prefer largest (current players)
	MinPlayers = 0,			-- 0 is unused, >0 will filter out servers with less players than this number
	MaxPlayers = 0,			-- 0 is unused, >0 will filter out servers with more players than this number
	ExcludeFull = true,		-- will filter out any servers that are full (at server's max players)
	ExcludeSame = true,		-- will filter out the current server
	MinFps = 55,			-- 0 is unused, >0 will filter any servers that do not have at least this FPS
	MaxPing = 190,			-- 0 is unused, >0 will filter any servers whose ping is higher than this

	--[[
		Sort Control
		Can change the weight of the sorting for size (players), fps, and ping
		Higher weights will give more preference during sorting.
		Set to 0 to remove a value from sort consideration.
			- Higher FPS is better FPS / Lower Ping is Better Ping
			- Size Pref depends on 'SizeSort' field above
	]]
	FpsSortWeight = 1,
	PingSortWeight = 1,
	SizeSortWeight = 5,

	--[[
		Other settings not usually needed
	]]
	PrintVerbose = false,
	PrintPrefixTime = false,
	PrintUseConsoleWindow = false
}







--[[ *************************************************************************************************************************
*************************************************************************************************************************
							CODEZ IS BELOW _ DO NOT MESS WITH IT IF U DONT KNOW WUTWUT
*************************************************************************************************************************
*************************************************************************************************************************]]





local verbose = false -- setting to true will print a lot
local prnt_prefix_time = false -- prefixes all prints with current time

-- some funcs used you can change if you like (dont if you dunno wut doin)
local prnt = print--rconsoleprint or printconsole or output or print
local pcll = pcall
local req = (syn or http or {}).request or http_request or request -- should handle most exploits worth using
local jsondecode = function(a) return game:GetService("HttpService"):JSONDecode(a) end

local prnt_add_nl = prnt==rconsoleprint or prnt==output
local locale

local tm = tick()

-- rbx games api info here: https://games.roblox.com/docs#!/Games/get_v1_games_placeId_servers_serverType
local rbx_games_url_frmt = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s"
local cursor_frmt = "&cursor=%s"

local function TimeString()
	locale = locale or game:GetService("LocalizationService").RobloxLocaleId
	return DateTime.now():FormatLocalTime("hh:mm:ss.SSS", locale)
end
local function TableToString(tbl: table,delimit: string,includeNames: boolean) -- cuz table.concat doesn't tostring for you
	tbl = tbl or {}
	delimit = delimit or ""
	local txt
	for i,v in (includeNames and pairs or ipairs)(tbl) do -- use ipairs if not using names, to ensure order
		-- http://lua-users.org/wiki/StringTrim
		-- txt = (txt and ((txt:match'^()%s*$' and '' or txt:match'^%s*(.*%S)').." | ") or "")..(includeNames and ("[%s]=%s"):format(tostring(i),tostring(v)) or tostring(v))
		-- https://stackoverflow.com/questions/51181222/lua-trailing-space-removal/51181334#51181334
		txt = (txt and (string.gsub(txt, '^%s*(.-)%s*$', '%1') ..delimit) or "")..(includeNames and ("[%s]=%s"):format(tostring(i),tostring(v)) or tostring(v))
	end
	return txt or ""
end
local function Prnt(...)
	local args = {...}
	local txt = (prnt_prefix_time and (TimeString()..": ") or "")..TableToString(args," | ")
	prnt(prnt_add_nl and txt:sub(#txt)~="\n" and (txt .. "\n") or txt) -- cuz rconsoleprint/output don't put newline at end
end

local function GetAllServersForPlace(placeId: number)
	prefer = prefer or {}
	local servers = {} -- to hold the server data as we go
	local cont = true
	local cursor -- for paging the requests, can only get 100 at a time..
	local cnt = 0
	local min_p,max_p,min_f,max_png
	local maxPlayers,maxFps,maxPing = 0,0,0
	local function numOrDefZero(val) return val and type(val)=="number" and val>0 and val or 0 end
	min_p = numOrDefZero(prefer.MinPlayers)
	max_p = numOrDefZero(prefer.MaxPlayers)
	min_f = numOrDefZero(prefer.MinFps)
	max_png = numOrDefZero(prefer.MaxPing)
	while cont do
		cont = false -- default to discontinue the loop, will only flip to true if we get a next page cursor
		local url = rbx_games_url_frmt:format(tostring(placeId),cursor and cursor_frmt:format(tostring(cursor)) or "")
		local succ_rsp,rsp = pcll(function()
			return req({
				Url = url,
				Method = "GET"
			})
		end)
		if succ_rsp and rsp and rsp.StatusCode and rsp.StatusCode==200 and rsp.Body then
			local succ_jsn,jsn = pcll(function() return jsondecode(rsp.Body) end)
			if succ_jsn and jsn then
				-- great it worked
				-- set the next page cursor if there is one
				cursor = jsn.nextPageCursor or nil
				if jsn.data then
					cnt = cnt + 1
					if verbose then 
						Prnt("Call#",cnt,"NumSvrs_Before",#servers,"Url",url)
					end
					for i,v in pairs(jsn.data) do
						if v and v.id and v.playing~=nil and v.fps and v.ping and v.maxPlayers then
							--[[just returning all of what it has, which is: 
								id				string (guid) | this is the server's id, or JobId
								maxPlayers		number | how many players server can support
								playing			number | how many players playing right now
								playerTokens	array of string (tokens) | the tokens of the players playing right now
								fps				number | server's current frames per second for execution
								ping			number | the ping with this server
							]]
							if (min_p>0 and v.playing<min_p) or 					-- filter min players
							   (max_p>0 and v.playing>max_p) or 					-- filter max players
							   (prefer.ExcludeFull and v.playing==v.maxPlayers) or 	-- filter full svr
							   (prefer.ExcludeSame and v.id==game.JobId) or			-- filter same svr
							   (min_f>0 and v.fps and v.fps<min_f) or 				-- filter min fps
							   (max_png>0 and v.ping and v.ping>max_png)			-- filter max ping
							   then continue end
							v.origord = #servers+1 -- fallback in case sort weights match
							-- keep the max values found, to be used in sort weights later
							if v.maxPlayers>maxPlayers then maxPlayers=v.maxPlayers end
							if v.fps>maxFps then maxFps=v.fps end
							if v.ping>maxPing then maxPing=v.ping end
							table.insert(servers,v)
						end
					end
					if verbose then 
						Prnt("Call#",cnt,"NumSvrs_After",#servers)
					end
				end
			elseif not succ_jsn and jsn then
				Prnt("Response was success, but json decode failed! Url >>>",url)
				Prnt("ERROR >>>",jsn)
			else 
				Prnt("Response was weird wtf! Url >>>",url,"json decode pcall returned",succ_jsn or "nil",jsn or "nil")

			end
		elseif not succ_rsp and rsp then
			Prnt("General failure wtf! Url >>>",url)
			Prnt("ERROR >>>",rsp)
		elseif succ_rsp and rsp then
			Prnt("Response was NOT success! Url >>>",url)
			for i,v in pairs(rsp) do
				Prnt(" -- ",i,v)
			end
		else
			Prnt("WTF SHOULD NOT HAPPEN! Url >>>",url,"request pcall returned >>>",succ_rsp or "nil","and >>>",rsp or "nil")
		end
		cont = cursor~=nil
	end
	return servers,maxPlayers,maxFps,maxPing
end

local function RejoinPreferredServer(preferences)

	prefer = prefer or {}
	if preferences and type(preferences)=="table" then
		for i,v in pairs(preferences) do
			if prefer[i] and type(prefer[i])==type(v) then
				prefer[i] = v
			end
		end
	end
	verbose = prefer.PrintVerbose
	prnt_prefix_time = prefer.PrintPrefixTime
	if prefer.PrintUseConsoleWindow then 
		prnt = rconsoleprint or output or printconsole or print
	end

	if prnt==rconsoleprint then
		if not syn then rconsolecreate() end -- noticed SW needs this
		if rconsoleclear then rconsoleclear() end
	end

	
	Prnt("******************************************************")
	Prnt("Rejoin Preferred Server by KoZ")
	Prnt("******************************************************")
	Prnt("Prefer:",TableToString(prefer," | ",true))
	Prnt("------------------------------------------------------")
	Prnt("Current PlaceId",game.PlaceId)
	Prnt("Current (Job)ServerId",game.JobId)
	-- get the servers but also the max plyrs,fps,& ping to use in sort weight math
	local allSvrs,maxPlayers,maxFps,maxPing = GetAllServersForPlace(game.PlaceId)
	Prnt("Servers Found for PlaceId",game.PlaceId,"NumSvrs",allSvrs and #allSvrs or 0,"Time",tostring(tick()-tm):sub(1,6))
	if allSvrs and #allSvrs>0 then
		local sortTm = tick()
		local sort = prefer.SizeSort and type(prefer.SizeSort)=="string" and prefer.SizeSort or "asc" -- size sort prefer small or large
		local sort_desc = sort:lower()=="desc"
		local function numOrDefaultClamp(val) return val and type(val)=="number" and math.clamp(val,0.01,1000) or 0.01 end
		local fps_wgt = numOrDefaultClamp(prefer.FpsSortWeight) -- fps wgt
		local png_wgt = numOrDefaultClamp(prefer.PingSortWeight) -- ping wgt
		local size_wgt = numOrDefaultClamp(prefer.SizeSortWeight) -- size wgt
		local function sortWeight(svr)
			local sz_wgt
			if sort_desc then -- size weight depends on whether its asc or desc
				sz_wgt = svr.playing/maxPlayers*size_wgt
			else
				sz_wgt = (1-svr.playing/maxPlayers)*size_wgt
			end
			return sz_wgt+svr.fps/maxFps*fps_wgt+(1-svr.ping/maxPing)*png_wgt -- fps/ping weight always the same way (ping inverted cuz lower is better)
		end
		table.sort(allSvrs,function(a,b)
			local a_w = sortWeight(a)
			local b_w = sortWeight(b)
			if a_w>b_w then return true
			elseif a_w==b_w then
				return a.origord<b.origord -- in the rare chance weight is same, use the original order returned by rbx api to ensure table sort does not fail
			else
				return false
			end
		end)

		if verbose then
			for i,v in ipairs(allSvrs) do
				Prnt("SORT",i,v.id,"playing",v.playing,"fps",v.fps,"ping",v.ping) -- if verbose dump out full sort order results for all servers found
			end
		end

		if verbose then Prnt("Sort Time",tick()-sortTm) end
		for i,v in ipairs(allSvrs) do
			Prnt(("Preferred #%s"):format(tostring(i)),v.id,("playing %s/%s"):format(tostring(v.playing),tostring(maxPlayers)),"fps",tostring(v.fps):sub(1,5),"ping",v.ping)
			Prnt("Teleporting...")
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,v.id)
			task.wait(10) -- keep trying in case we fail to teleport to preferred, get next and so on
		end
	else
		Prnt("Found no servers for PlaceId",game.PlaceId,"Time",tostring(tick()-tm):sub(1,6))
	end
end

RejoinPreferredServer(...)