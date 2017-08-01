--[[
credits:

factorio devs

MagmaMcFry for Factorissimo, which illustrated how to get players, items and power across surfaces

Earendel for Water Fix, where i saw how to create proper round corners with transparencies

Emmote for fewerTrees, for the idea of how to get rid of them (in the cave surface) 

this cave generator is an implementation of
http://www.jimrandomh.org/misc/caves.html
using the parameters of the Cellular Automata generator from
http://www.futuredatalab.com/proceduraldungeon/

--]]

local function toChunk(position)
	return {x = math.floor(position.x) / 32, y = math.floor(position.y) / 32} 
end

local function init_globals()
	
	global.generator = game.create_random_generator()

	global.TILE_FLOOR = 0
	global.TILE_WALL = 1

	--chunk is 32x32. generate a bit more to get a smooth transition chunk border. it must be ensured that coord x/y is generated using the same random number as if another chunk would be considering it.

	local CHUNK_SIZE = 32
	global.BORDER_SIZE = 8 --probably BORDER_SIZE must be > GENERATIONS
	global.SIZE_X = CHUNK_SIZE + 2 * global.BORDER_SIZE
	global.SIZE_Y = CHUNK_SIZE + 2 * global.BORDER_SIZE
	global.FILLPROB = 40
	global.OPENINGPROB = 25 --custom addition: chance of a bigger cave being created (in order to facilitate more cave entrances)
	global.OPENINGSIZE = 2
	global.GENERATIONS = 7
	global.SUB_GENERATIONS = 2
	
	global.grid = {}
	global.grid2 = {}
	
	for i = 0,global.SIZE_Y-1 do
		global.grid[i] = {}
		global.grid2[i] = {}
	end
	
	global.chunksToCreate = {}
	global.chunkCreationStep = 0
	global.chunkCreationGeneration = 0
	global.chunkCreationSubGeneration = 0
	
	global.activeMinesToUpdate = {}
	global.inactiveMinesToUpdate = {}

	local autoplace_defaultWithoutBiters = game.surfaces["nauvis"].map_gen_settings.autoplace_controls
	
	if settings.startup["caves-enable-biters"].value == false then
		autoplace_defaultWithoutBiters["enemy-base"].size = "none"	
	end
	
	global.mineSurface = game.create_surface("cave1", {
		--terrain_segmentation
		water="none",
		autoplace_controls = autoplace_defaultWithoutBiters,
		seed = game.surfaces["nauvis"].map_gen_settings.seed + 1,
		--shift 
		width = 0, 
		height = 0, 
		starting_area = game.surfaces["nauvis"].map_gen_settings.starting_area,
		peaceful_mode = false
	})
	global.mineSurface.daytime = 0.5
	global.mineSurface.freeze_daytime = true
	
	global.flyingTexts = {}
	
	global.version = "0.1.4"
				
end

script.on_init(function()
	init_globals()
end)

local function updateModVersion()
	if global.version == nil then global.version = "0.1.3" end
	if global.version < "0.1.4" then

		global.chunksToLink = nil
		
		global.flyingTexts = {}

		local beltOffsets = 0.5

		for _, v in pairs(global.activeMinesToUpdate) do
			v.x = v.x + beltOffsets
			v.y = v.y + beltOffsets
		end
		for _, v in pairs(global.inactiveMinesToUpdate) do
			v.x = v.x + beltOffsets
			v.y = v.y + beltOffsets
		end

		local oldMineEntrances = game.surfaces["nauvis"].find_entities_filtered{name="mine-entrance"}
		for i = 1,#oldMineEntrances do
			oldMineEntrances[i].minable = true
			oldMineEntrances[i].force = "neutral"
		end
		
		global.version = "0.1.4"
	end

end

script.on_configuration_changed(function()
	updateModVersion()
end)

local function enter_mine(player, factory)
	player.teleport({player.position.x+1.5, player.position.y-0.8},global.mineSurface)
end

local function leave_mine(player, factory)
	player.teleport({player.position.x+1.5, player.position.y+0.8},game.surfaces["nauvis"])
end


local function find_mine_entrance(surface, area)
	local candidates = surface.find_entities_filtered{area=area}
	for _,entity in pairs(candidates) do
	    if entity.name == "mine-entrance" or entity.name=="mine-exit" then
			return entity
		end
	end
	return nil
end

local function teleport_players()
	
	local tick = game.tick
	for player_index, player in pairs(game.players) do
		if player.connected and not player.driving and tick % 20 == 4 then
			local walking_state = player.walking_state
			if walking_state.walking then
				if walking_state.direction == defines.direction.north
				or walking_state.direction == defines.direction.northeast
				or walking_state.direction == defines.direction.northwest then
					-- Enter factory
					local mine_entrance = find_mine_entrance(player.surface, {{player.position.x-0.2, player.position.y-0.3},{player.position.x+0.2, player.position.y}})
					if mine_entrance ~= nil then
							enter_mine(player, factory)
					end
				elseif walking_state.direction == defines.direction.south
				or walking_state.direction == defines.direction.southeast
				or walking_state.direction == defines.direction.southwest then
					local mine_entrance = find_mine_entrance(player.surface, {{player.position.x-0.2, player.position.y},{player.position.x+0.2, player.position.y+0.3}})
					if mine_entrance ~= nil then
							leave_mine(player, mine_entrance)
					end
				end
				
			end
		end
	end
end

local function updateBelts()

	local beltInputOffsetSurface = {x=-1.0,y=2.0}
	local beltInputOffsetCave = {x=-1.0,y=-2.0}
	local beltOutputOffsetSurface = {x=1.0,y=2.0}
	local beltOutputOffsetCave = {x=1.0,y=-2.0}

	for _, v in pairs(global.activeMinesToUpdate) do
	
		local surfacePos = {x = v.x + beltInputOffsetSurface.x, y = v.y + beltInputOffsetSurface.y}
		local cavePos = {x = v.x + beltInputOffsetCave.x, y = v.y + beltInputOffsetCave.y}
		local surfaceEntities = game.surfaces["nauvis"].find_entities_filtered{position=surfacePos,type="transport-belt",limit=1}
		local caveEntities = global.mineSurface.find_entities_filtered{position=cavePos,type="transport-belt",limit=1}
		
		--debug: used to find where belts are expected
		--game.surfaces["nauvis"].create_entity{name="transport-belt", position=surfacePos}
		--global.mineSurface.create_entity{name="transport-belt", position=cavePos}
		
				
		if #surfaceEntities > 0 and #caveEntities > 0 and surfaceEntities[1].direction == defines.direction.north and caveEntities[1].direction == defines.direction.north then
		
			local givingEntity = surfaceEntities[1]
			local receiving = caveEntities[1]
		
			for beltSide = 1,2 do
				if receiving.get_transport_line(beltSide).can_insert_at_back() and givingEntity.get_transport_line(beltSide).get_item_count() > 0 then
					local itemToMove = givingEntity.get_transport_line(beltSide)[1]
					receiving.get_transport_line(beltSide).insert_at_back(itemToMove)
					givingEntity.get_transport_line(beltSide).remove_item(itemToMove)
				end
			end
			
		end
		
		surfacePos = {x = v.x + beltOutputOffsetSurface.x, y = v.y + beltOutputOffsetSurface.y}
		cavePos = {x = v.x + beltOutputOffsetCave.x, y = v.y + beltOutputOffsetCave.y}
		surfaceEntities = game.surfaces["nauvis"].find_entities_filtered{position=surfacePos,type="transport-belt",limit=1}
		caveEntities = global.mineSurface.find_entities_filtered{position=cavePos,type="transport-belt",limit=1}

		--debug: used to find where belts are expected
		--game.surfaces["nauvis"].create_entity{name="transport-belt", position=surfacePos}
		--global.mineSurface.create_entity{name="transport-belt", position=cavePos}

		
		if #surfaceEntities > 0 and #caveEntities > 0 and surfaceEntities[1].direction == defines.direction.south and caveEntities[1].direction == defines.direction.south then
	
			givingEntity = caveEntities[1]
			receiving = surfaceEntities[1]
		
			for beltSide = 1,2 do
				if receiving.get_transport_line(beltSide).can_insert_at_back() and givingEntity.get_transport_line(beltSide).get_item_count() > 0 then
					local itemToMove = givingEntity.get_transport_line(beltSide)[1]
					receiving.get_transport_line(beltSide).insert_at_back(itemToMove)
					givingEntity.get_transport_line(beltSide).remove_item(itemToMove)
				end
			end
			
		end
	end

end

local function updatePower()

	for _, v in pairs(global.activeMinesToUpdate) do
	
		local surfaceEntity = game.surfaces["nauvis"].find_entity("mine-entrance", v)
		local caveEntity = global.mineSurface.find_entity("mine-exit", v)
		
		if surfaceEntity ~= nil and caveEntity ~= nil then
			caveEntity.energy = (surfaceEntity.energy + caveEntity.energy)/2
			surfaceEntity.energy = caveEntity.energy
		end
	
	end
end

local function spreadPollution()
	
	for _, v in pairs(global.activeMinesToUpdate) do
	
		local diff = global.mineSurface.get_pollution(v)
		global.mineSurface.pollute(v,-diff)
		game.surfaces["nauvis"].pollute(v,diff)
	end
	
end

local function updateCaveView()
	for player_index, player in pairs(game.players) do
	
		local cave_view_container = player.gui.top.cave_view_container
		if not cave_view_container then
			cave_view_container = player.gui.top.add{type="frame", name="cave_view_container"}
			local cave_view = cave_view_container.cave_view
			if not cave_view then
				cave_view = cave_view_container.add{type="camera", name="cave_view", position={0,0}, surface_index=global.mineSurface.index, zoom=0.5}
				cave_view.style.minimal_width = 400
				cave_view.style.minimal_height = 400
			end
			if not global.flyingTexts[player_index] then
				local flyingText = global.mineSurface.create_entity{name="cave-view-x-mark", position = player.position, text = "+"}
				global.flyingTexts[player_index] = flyingText
			end
		end
	
		local cave_view = player.gui.top.cave_view_container.cave_view
		cave_view.position = player.position
		
		local isOnRegularSurface = player.surface == game.surfaces["nauvis"]
		local hasEntranceInHand = player.cursor_stack ~= nil and player.cursor_stack.valid_for_read and player.cursor_stack.name == "mine-entrance"
		local isHoveringOverEntrance = player.selected ~= nil and player.selected.name == "mine-entrance"
		
		if isOnRegularSurface and (hasEntranceInHand or isHoveringOverEntrance) then
			cave_view.style.visible = true
			if isHoveringOverEntrance then cave_view.position = player.selected.position end
			global.flyingTexts[player_index].teleport(player.position)
		else
			cave_view.style.visible = false
			global.flyingTexts[player_index].teleport({x=999999,y=999999}) --no concept for visibility=false and text changes are ignored -> move out of sight instead
		end					
	end
end

local function prepareChunkCreation()
					
	for key, entity in pairs(global.mineSurface.find_entities(global.chunksToCreate[1])) do
		local removeEntity = false
		
		if entity.type == "tree" then
			removeEntity = true
		elseif entity.name:lower():find("-rock") then
				removeEntity = true
		end
		
		if removeEntity then
			entity.destroy()
		end
	end
	
	global.mineSurface.destroy_decoratives(global.chunksToCreate[1])
	
	for chunkY = -1, 1 do
		for chunkX = -1, 1 do
			local chunkStartX = global.chunksToCreate[1].left_top.x + chunkX * 32
			local chunkStartY = global.chunksToCreate[1].left_top.y + chunkY * 32
			global.generator.re_seed(bit32.bxor(bit32.lshift(chunkStartX / 32, 16) + (chunkStartY / 32),game.surfaces["nauvis"].map_gen_settings.seed))	
			
			for yi = 0,31 do
				for xi = 0, 31 do
					local xIndex = xi + (chunkX * 32) + 32 - (32 - global.BORDER_SIZE)
					local yIndex = yi + (chunkY * 32) + 32 - (32 - global.BORDER_SIZE)
					local tileValue = global.generator(100) --execute always to ensure consistency across chunks!
					
					if xIndex >= 0 and yIndex >= 0 and xIndex < 32 + 2*global.BORDER_SIZE and yIndex < 32 + 2*global.BORDER_SIZE then
						if tileValue < global.FILLPROB then global.grid[yIndex][xIndex] = global.TILE_WALL else global.grid[yIndex][xIndex] = global.TILE_FLOOR end
						global.grid2[yIndex][xIndex] = global.TILE_WALL
					end
				end
			end
			
		end
	end
	
	global.generator.re_seed(bit32.bxor(bit32.lshift(global.chunksToCreate[1].left_top.x / 32, 16) + (global.chunksToCreate[1].left_top.y / 32),game.surfaces["nauvis"].map_gen_settings.seed))	
					
	if global.generator(100) < global.OPENINGPROB then
		local openingPosX = (global.SIZE_X / 2) + global.generator(-4,4)
		local openingPosY = (global.SIZE_Y / 2) + global.generator(-4,4)
		for yi = openingPosY,openingPosY+global.OPENINGSIZE do
			for xi = openingPosX,openingPosX+global.OPENINGSIZE do
				global.grid[yi][xi] = global.TILE_FLOOR			
			end
		end
	end

end

local function workOnChunk()
	
	local r1_cutoff = 0
	local r2_cutoff = 0
	if global.chunkCreationGeneration == 0 then r1_cutoff = 5 r2_cutoff = 2 end
	if global.chunkCreationGeneration == 1 then r1_cutoff = 5 r2_cutoff = 2 end
	if global.chunkCreationGeneration == 2 then r1_cutoff = 5 r2_cutoff = 2 end
	if global.chunkCreationGeneration == 3 then r1_cutoff = 5 r2_cutoff = 2 end
	if global.chunkCreationGeneration == 4 then r1_cutoff = 5 r2_cutoff = -1 end
	if global.chunkCreationGeneration == 5 then r1_cutoff = 5 r2_cutoff = -1 end
	if global.chunkCreationGeneration == 6 then r1_cutoff = 5 r2_cutoff = -1 end
	
	local yiStart = 0
	local yiEnd = 0
	if global.chunkCreationSubGeneration == 0 then yiStart = 2 end
	if global.chunkCreationSubGeneration == 0 then yiEnd = (global.SIZE_Y / 2)-1 end
	if global.chunkCreationSubGeneration == 1 then yiStart = global.SIZE_Y / 2 end
	if global.chunkCreationSubGeneration == 1 then yiEnd = global.SIZE_Y - 3 end
	
	for yi = yiStart, yiEnd do
		for xi = 2, global.SIZE_X - 3 do
			local adjcount_r1 = 0
			local adjcount_r2 = 0
			
			for ii = -1,1 do
				for jj = -1,1 do
					if global.grid[yi+ii][xi+jj] ~= global.TILE_FLOOR then
						adjcount_r1 = adjcount_r1 + 1
					end
				end
			end
			
			for ii = yi-2,yi+2 do
				for jj = xi-2,xi+2 do
		
					--no continue in lua syntax
					if not(
						(math.abs(ii-yi) == 2 and math.abs(jj-xi) == 2)
						) then
						
						if global.grid[ii][jj] ~= global.TILE_FLOOR then
							adjcount_r2 = adjcount_r2 + 1
						end
						
					end
						
				end
			end
			
			if adjcount_r1 >= r1_cutoff or adjcount_r2 <= r2_cutoff then
				global.grid2[yi][xi] = global.TILE_WALL
			else
				global.grid2[yi][xi] = global.TILE_FLOOR
			end
			
		end
	end
	
	if global.chunkCreationSubGeneration == global.SUB_GENERATIONS -1 then
		for yi = 1,global.SIZE_Y-2 do
			for xi = 1, global.SIZE_X -2 do
				global.grid[yi][xi] = global.grid2[yi][xi]
			end
		end
	end
	
	global.chunkCreationSubGeneration = global.chunkCreationSubGeneration + 1
	if global.chunkCreationSubGeneration == global.SUB_GENERATIONS then
		global.chunkCreationSubGeneration = 0
		global.chunkCreationGeneration = global.chunkCreationGeneration + 1
	end
end

local function finalizeChunk()

	local tiles = {}
	
	for y = global.chunksToCreate[1].left_top.y, global.chunksToCreate[1].left_top.y + 31 do
		for x = global.chunksToCreate[1].left_top.x, global.chunksToCreate[1].left_top.x + 31 do				
			table.insert(tiles, {name="cave-ground", position = {x,y}})
		end
	end
	
	global.mineSurface.set_tiles(tiles, false)
	
	local resourcesToRegenerate = {}
	for resource, v in pairs(game.surfaces["nauvis"].map_gen_settings.autoplace_controls) do
		if not (resource == "enemy-base") then
			table.insert(resourcesToRegenerate, resource) 
		end
	end
	
	for prototypeName, prototype in pairs(game.entity_prototypes) do
		if prototype.autoplace_specification ~= nil and prototype.autoplace_specification.control == "enemy-base" then
			table.insert(resourcesToRegenerate, prototypeName) 
		end
	end

	local chunkToRegenerate = toChunk(global.chunksToCreate[1].left_top)
	for xi = chunkToRegenerate.x - 1, chunkToRegenerate.x + 1 do
		for yi = chunkToRegenerate.y - 1, chunkToRegenerate.y + 1 do
			global.mineSurface.regenerate_entity(resourcesToRegenerate, {{xi, yi}})
		end
	end
	
	tiles = {}
	
	for yi = global.BORDER_SIZE,global.SIZE_Y-global.BORDER_SIZE-1 do
		for xi = global.BORDER_SIZE,global.SIZE_X-global.BORDER_SIZE-1 do
			local x = global.chunksToCreate[1].left_top.x + xi - global.BORDER_SIZE
			local y = global.chunksToCreate[1].left_top.y + yi - global.BORDER_SIZE
			
			if global.grid[yi][xi] == global.TILE_FLOOR then
				table.insert(tiles, {name="cave-ground", position = {x,y}})
			end
			if global.grid[yi][xi] == global.TILE_WALL then
				table.insert(tiles, {name="cave-wall", position = {x,y}})
			end
		end
	end
			
	global.mineSurface.set_tiles(tiles, true)

end

local function createMoreChunks()

	if #global.chunksToCreate > 0 then
		if global.chunkCreationStep == 0 then
			prepareChunkCreation()
			global.chunkCreationStep = global.chunkCreationStep + 1
		elseif global.chunkCreationStep == 1 then
			workOnChunk()
			if global.chunkCreationGeneration == global.GENERATIONS then
				global.chunkCreationStep = global.chunkCreationStep + 1
				global.chunkCreationGeneration = 0
				global.chunkCreationSubGeneration = 0
			end
		elseif global.chunkCreationStep == 2 then
			finalizeChunk()
			global.chunkCreationStep = 0
			table.remove(global.chunksToCreate, 1) --lua dequeue?
		end	
	end
	
end

local function activateMines(currentTick)

	if currentTick % 60 == 47 then
	
		for currentIndex, v in pairs(global.inactiveMinesToUpdate) do

			local energyChange = false
			local beltPresence = false
		
			local surfaceEntity = game.surfaces["nauvis"].find_entity("mine-entrance", v)
			local caveEntity = global.mineSurface.find_entity("mine-exit", v)
			
			if (surfaceEntity ~= nil and caveEntity ~= nil) and
			(caveEntity.energy > 0 or surfaceEntity.energy > 0)
			then
				energyChange = true
			end
			
			local surroundingArea = {{v.x - 5, v.y - 5},{v.x + 5, v.y + 5}}
			
			local surfaceEntities = game.surfaces["nauvis"].find_entities_filtered{area=surroundingArea,type="transport-belt",limit=1}
			local caveEntities = global.mineSurface.find_entities_filtered{area=surroundingArea,type="transport-belt",limit=1}
			
			if #surfaceEntities > 0 and #caveEntities > 0 then
				beltPresence = true
			end
			
			if energyChange or beltPresence then
				table.insert(global.activeMinesToUpdate, v) 
				table.remove(global.inactiveMinesToUpdate, currentIndex)
				return
			end
		end
	end
end

script.on_event(defines.events.on_tick, function(event)

	teleport_players()
	
	activateMines(event.tick)
	
	updateBelts()

	updatePower()
	
	spreadPollution()
	
	updateCaveView()
		
	createMoreChunks()

end)

script.on_event(defines.events.on_chunk_generated, function(e)

	if e.surface == game.surfaces["nauvis"] then
		
		local overworldResources = game.surfaces["nauvis"].find_entities_filtered{e.area, type= "resource"}
		for key, entity in pairs(overworldResources) do
			entity.destroy()
		end
		
		global.mineSurface.request_to_generate_chunks(e.area.left_top)
		
	end
	if e.surface == global.mineSurface then
	
		local tiles = {}
	
		for y = e.area.left_top.y,e.area.left_top.y + 31 do
			for x = e.area.left_top.x,e.area.left_top.x + 31 do				
				table.insert(tiles, {name="cave-wall", position = {x,y}})
			end
		end
				
		global.mineSurface.set_tiles(tiles, false)
		
		game.surfaces["nauvis"].request_to_generate_chunks(e.area.left_top)
		
		table.insert(global.chunksToCreate, e.area)

	end	
end)

local function abortPlacement(entity, playerBuild, playerIndex, errorMessage)
	local entityPos = {x=entity.position.x, y=entity.position.y}
	local surface = entity.surface
	if playerBuild then
		game.players[playerIndex].insert{name=entity.name, count=1}
		game.players[playerIndex].print(errorMessage)
	else
		surface.spill_item_stack(entity.position, {name=entity.name, count=1}, true)
		for onePlayerIndex, player in pairs(game.players) do
			game.players[onePlayerIndex].print({"item-limitation.chunk-not-created-yet"})
		end
	end
	entity.die()
	for _, ghost in pairs(surface.find_entities_filtered{type="entity-ghost", position=entityPos}) do
	    ghost.destroy()
    end
end

local function checkCreatedEntity(entity, playerBuild, playerIndex)
	if entity.name == "mine-entrance" then
		if not (entity.surface == game.surfaces["nauvis"]) then
			abortPlacement(entity, playerBuild, playerIndex, {"item-limitation.entrances-only-above-ground"})
			return
		end
		local chunkPos = toChunk(entity.position)
		local chunkMissing = false
		for yi = chunkPos.y-1, chunkPos.y+1 do
			for xi = chunkPos.x-1, chunkPos.x+1 do
				if not global.mineSurface.is_chunk_generated({x=xi,y=yi}) then 
					chunkMissing = true
				end
			end
		end
		if chunkMissing then
			abortPlacement(entity, playerBuild, playerIndex, {"item-limitation.chunk-not-created-yet"})
			return
		end
		
		if not global.mineSurface.can_place_entity{name="mine-exit", position=entity.position} then
			abortPlacement(entity, playerBuild, playerIndex, {"item-limitation.no-space-for-entrance"})
			return
		end
		
	   local entity2 = global.mineSurface.create_entity{name="mine-exit", position=entity.position}
	   
	   entity.destructible = false
	   entity2.destructible = false
	   entity2.minable = false --the cave entity is not minable to ensure the player isn't stranded
	   
	   table.insert(global.inactiveMinesToUpdate, entity.position) 
					
	end
end

script.on_event(defines.events.on_built_entity, function(event)
	checkCreatedEntity(event.created_entity, true, event.player_index)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	checkCreatedEntity(event.created_entity, false, -1)
end)

local function checkMinedEntity(entity)
	if entity.name == "mine-entrance" then
		for currentIndex, v in pairs(global.inactiveMinesToUpdate) do
			if v.x == entity.position.x and v.y == entity.position.y then
				table.remove(global.inactiveMinesToUpdate, currentIndex)
			end
		end
		for currentIndex, v in pairs(global.activeMinesToUpdate) do
			if v.x == entity.position.x and v.y == entity.position.y then
				table.remove(global.activeMinesToUpdate, currentIndex)
			end
		end
		local caveEntity = global.mineSurface.find_entity("mine-exit", entity.position)
		if caveEntity ~= nil then
			caveEntity.destroy()
		end
	end
end

script.on_event(defines.events.on_player_mined_entity, function(event)
	checkMinedEntity(event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
	checkMinedEntity(event.entity)
end)


