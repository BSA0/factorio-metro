data:extend({
  {
    type = "noise-layer",
    name = "cave-ground"
  },
  
    {
    type = "flying-text",
    name = "cave-view-x-mark",
    flags = {"not-on-map"},
    time_to_live = 4294967295, --http://lua-api.factorio.com/latest/LuaEntity.html#LuaEntity.time_to_live
    speed = 0
  },
  
{
    type = "tile",
    name = "cave-ground",
    collision_mask = {"ground-tile"},
    autoplace = nil,
    layer = 38,
    variants =
    {
      main =
      {
        {
          picture = "__Caves__/graphics/terrain/cave-ground/cave-ground1.png",
          count = 16,
          size = 1,
          hr_version =
          {
            picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground1.png",
            count = 16,
            size = 1,
            scale = 0.5,
          },
        },
        {
          picture = "__Caves__/graphics/terrain/cave-ground/cave-ground2.png",
          count = 16,
          size = 2,
          hr_version =
          {
            picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground2.png",
            count = 16,
            size = 2,
            scale = 0.5,
          },
        },
        {
          picture = "__Caves__/graphics/terrain/cave-ground/cave-ground4.png",
          count = 16,
          size = 4,
          hr_version =
          {
            picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground4.png",
            count = 16,
            size = 4,
            scale = 0.5,
          }
        },
        {
          picture = "__Caves__/graphics/terrain/cave-ground/cave-ground8.png",
          line_length = 4,
          count = 16,
          size = 8,
          hr_version =
          {
            picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground8.png",
            line_length = 4,
            count = 16,
            size = 8,
            scale = 0.5,
          }
        },
        {
          picture = "__Caves__/graphics/terrain/cave-ground/cave-ground16.png",
          line_length = 4,
          count = 16,
          size = 16,
          hr_version =
          {
            picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground16.png",
            line_length = 4,
            count = 16,
            size = 16,
            scale = 0.5,
          }
        },
      },
      inner_corner =
      {
        picture = "__Caves__/graphics/terrain/cave-ground/cave-ground-inner-corner.png",
        count = 8,
        hr_version =
        {
          picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground-inner-corner.png",
          count = 8,
          scale = 0.5,
        },
      },
      outer_corner =
      {
        picture = "__Caves__/graphics/terrain/cave-ground/cave-ground-outer-corner.png",
        count = 8,
        hr_version =
        {
          picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground-outer-corner.png",
          count = 8,
          scale = 0.5,
        },
      },
      side =
      {
        picture = "__Caves__/graphics/terrain/cave-ground/cave-ground-side.png",
        count = 8,
        hr_version =
        {
          picture = "__Caves__/graphics/terrain/cave-ground/hr-cave-ground-side.png",
          count = 8,
          scale = 0.5,
        },
      },
    },
    walking_sound =
    {
      {
        filename = "__base__/sound/walking/grass-01.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/grass-02.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/grass-03.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/grass-04.ogg",
        volume = 0.8
      }
    },
    map_color={r=160, g=160, b=160},
    ageing=0.0004,
    vehicle_friction_modifier = grass_vehicle_speed_modifier
  },
  
  
  {
    type = "tile",
    name = "cave-wall",
    collision_mask =
    {
      "water-tile",
      "item-layer",
      "resource-layer",
      "player-layer",
      "doodad-layer"
    },
    autoplace = nil,
    layer = 80,
	needs_correction = false,
    variants =
    {
      main =
      {
        {
          picture = "__Caves__/graphics/terrain/cave-wall/cave1.png",
          count = 16,
          size = 1
        },
        {
          picture = "__Caves__/graphics/terrain/cave-wall/cave2.png",
          count = 16,
          size = 2
        },
        {
          picture = "__Caves__/graphics/terrain/cave-wall/cave4.png",
          count = 16,
          size = 4
        }
      },
      inner_corner =
      {
        picture = "__Caves__/graphics/terrain/cave-wall/cave-inner-corner.png",
        count = 1
      },
      outer_corner =
      {
        picture = "__Caves__/graphics/terrain/cave-wall/cave-outer-corner.png",
        count = 1
      },
      side =
      {
        picture = "__Caves__/graphics/terrain/cave-wall/cave-side.png",
        count = 1
      },
	  u_transition = 
	  {
		picture = "__Caves__/graphics/terrain/cave-wall/cave-u.png",
        count = 1
	  },
	  o_transition = 
	  {
		picture = "__Caves__/graphics/terrain/cave-wall/cave-o.png",
        count = 1
	  },
    },
    allowed_neighbors = nil,
    map_color={r=0.0, g=0.0, b=0.0},
    ageing=0.0006
  },
  
  {
    type = "electric-energy-interface",
    name = "mine-entrance",
    icon = "__Caves__/graphics/icons/mine-entrance/mine-entrance.png",
	order="e-a-b",
    flags = {"placeable-neutral", "player-creation", "not-blueprintable"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "mine-entrance"},
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "10MJ",
      usage_priority = "secondary-input",
      input_flow_limit = "10MW",
      output_flow_limit = "1kW"
    },
    picture =
    {
      filename = "__Caves__/graphics/entity/mine-entrance/mine-entrance.png",
      priority = "extra-high",
      width = 160,
      height = 112,
      shift = {0.625, -0.125}
    },
    charge_animation =
    {
      filename = "__Caves__/graphics/entity/mine-entrance/mine-entrance-charge-animation.png",
      width = 160,
      height = 112,
      line_length = 1,
      frame_count = 1,
      shift = {0.625, -0.125},
      animation_speed = 0.5
    },
    charge_cooldown = 30,
    charge_light = {intensity = 0.3, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    discharge_animation =
    {
      filename = "__Caves__/graphics/entity/mine-entrance/mine-entrance-discharge-animation.png",
      width = 160,
      height = 112,
      line_length = 1,
      frame_count = 1,
      shift = {0.625, -0.125},
      animation_speed = 0.5
    },
    discharge_cooldown = 60,
    discharge_light = {intensity = 0.7, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound = {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 5
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.984375, 1.10938},
        green = {0.890625, 1.10938}
      },
      wire =
      {
        red = {0.6875, 0.59375},
        green = {0.6875, 0.71875}
      }
    },
    circuit_connector_sprites = get_circuit_connector_sprites({0.46875, 0.5}, {0.46875, 0.8125}, 26),
    circuit_wire_max_distance = 9,
    default_output_signal = {type = "virtual", name = "signal-A"},
  },
  
    {
    type = "item",
    name = "mine-entrance",
    icon = "__Caves__/graphics/icons/mine-entrance/mine-entrance.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "c[mine-entrance]",
    place_result = "mine-entrance",
    stack_size = 10
  },
  
  {
    type = "recipe",
    name = "mine-entrance",
    enabled = "true",
	category = "crafting",
    ingredients =
    {
	  {name = "raw-wood", amount = 20},
	  {name = "stone", amount = 20},
    },
	energy_required = 5,
	result = "mine-entrance",
    result_count = 1
  },
  
  {
    type = "accumulator",
    name = "mine-exit",
    icon = "__base__/graphics/icons/accumulator.png",
	order="e-a-b",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "accumulator"},
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "10MJ",
      usage_priority = "terciary",
      input_flow_limit = "1kW",
      output_flow_limit = "10MW"
    },
    picture =
    {
      filename = "__Caves__/graphics/entity/mine-exit/mine-exit.png",
      priority = "extra-high",
      width = 160,
      height = 112,
      shift = {0.59375, 0.0}
    },
    charge_animation =
    {
      filename = "__Caves__/graphics/entity/mine-exit/mine-exit-charge-animation.png",
      width = 160,
      height = 112,
      line_length = 1,
      frame_count = 1,
      shift = {0.59375, 0.0},
      animation_speed = 0.5
    },
    charge_cooldown = 30,
    charge_light = {intensity = 0.3, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    discharge_animation =
    {
      filename = "__Caves__/graphics/entity/mine-exit/mine-exit-discharge-animation.png",
      width = 160,
      height = 112,
      line_length = 1,
      frame_count = 1,
      shift = {0.59375, 0.0},
      animation_speed = 0.5
    },
    discharge_cooldown = 60,
    discharge_light = {intensity = 0.7, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/accumulator-working.ogg",
        volume = 1
      },
      idle_sound = {
        filename = "__base__/sound/accumulator-idle.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 5
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.984375, 1.10938},
        green = {0.890625, 1.10938}
      },
      wire =
      {
        red = {0.6875, 0.59375},
        green = {0.6875, 0.71875}
      }
    },
    circuit_connector_sprites = get_circuit_connector_sprites({0.46875, 0.5}, {0.46875, 0.8125}, 26),
    circuit_wire_max_distance = 9,
    default_output_signal = {type = "virtual", name = "signal-A"}
  },
  
})
