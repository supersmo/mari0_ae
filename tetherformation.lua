TetherFormation = class:new()

TetherFormation.LINE = "LINE"
TetherFormation.CIRCLE = "CIRCLE"
TetherFormation.HUB_AND_SPOKE = "HUB_AND_SPOKE"
TetherFormation.SPOKE_WHEEL = "SPOKE_WHEEL"
TetherFormation.ALL_TO_ALL = "ALL_TO_ALL"

-- create players by tetheres so they form a line
local function attachasline(playerlist, color)
	if #playerlist <= 1 then
		return
	end
	local globaltethers = objects["tether"]
	for i = 1,(#playerlist-1) do
		globaltethers[#globaltethers+1] = tether:new(playerlist[i], playerlist[i+1], color)
	end
end

local function attachascircle(playerlist, color)
	if #playerlist <= 1 then
		return
	end
	attachasline(playerlist, color)
	-- close the line
	local globaltethers = objects["tether"]
	globaltethers[#globaltethers+1] = tether:new(playerlist[1], playerlist[#playerlist], color)
end
	
-- attach tethers in hub and spoke
local function attachashubandspoke(playerlist, color)
	if #playerlist <= 1 then
		return nil
	end
	local hubplayer = math.random(1,#playerlist)
	local globaltethers = objects["tether"]
	for i = 1, #playerlist do
		if i ~= hubplayer then
			globaltethers[#globaltethers+1] = tether:new(objects["player"][i], objects["player"][hubplayer], color)
		end
	end
	print ("hubplayer is: " .. hubplayer)
	return hubplayer
end

local function attachasspokewheel(playerlist, color)
	if #playerlist <= 1 then
		return
	end
	local hubplayer = attachashubandspoke(playerlist, color)
	table.remove(playerlist, hubplayer)
	attachascircle(playerlist, color)

end

-- attach tethers between everyone in a group
local function attachalltoall(playerlist, color)
	if #playerlist <= 1 then
		return
	end
	local globaltethers = objects["tether"]
	for i = 1, players do
		for j = i+1, #playerlist do
			globaltethers[#globaltethers+1] = tether:new(objects["player"][i], objects["player"][j], color)
		end
	end
end

function TetherFormation.createtetherformation(group, formation, color)
	local formationfunctions = {
		[TetherFormation.LINE] = attachasline,
		[TetherFormation.CIRCLE] = attachascircle,
		[TetherFormation.HUB_AND_SPOKE] = attachashubandspoke,
		[TetherFormation.SPOKE_WHEEL] = attachasspokewheel,
		[TetherFormation.ALL_TO_ALL] = attachalltoall
	}

	local createtethers = formationfunctions[formation]
	if createtethers then
		-- create tethers
		createtethers(group, color)
	else
		print("Invalid formation: " .. tostring(formation))
	end
end

	-- todo: make repelling springs
	-- todo: Magnets??
	-- springs that snap?
	-- springs that attach?
	-- Extend/retract springs without shoulder buttons?