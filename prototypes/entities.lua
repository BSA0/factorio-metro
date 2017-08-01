require "prototypes/constants"

railpictures = function()
  return railpicturesinternal({{"metals", "metals", mipmap = true},
                               {"backplates", "backplates", mipmap = true},
                               {"ties", "ties"},
                               {"stone_path", "stone-path"}})
end                                

railpicturesinternal = function(elems)
  local keys = {{"straight_rail", "horizontal", 64, 64, 0, 0},
                {"straight_rail", "vertical", 64, 64, 0, 0},
                {"straight_rail", "diagonal-left-top", 64, 64, 0, 0},
                {"straight_rail", "diagonal-right-top", 64, 64, 0, 0},
                {"straight_rail", "diagonal-right-bottom", 64, 64, 0, 0},
                {"straight_rail", "diagonal-left-bottom", 64, 64, 0, 0},
                {"curved_rail", "vertical-left-top", 128, 256, 0, 0},
                {"curved_rail", "vertical-right-top", 128, 256, 0, 0},
                {"curved_rail", "vertical-right-bottom", 128, 256, 0, 0},
                {"curved_rail", "vertical-left-bottom", 128, 256, 0, 0},
                {"curved_rail" ,"horizontal-left-top", 256, 128, 0, 0},
                {"curved_rail" ,"horizontal-right-top", 256, 128, 0, 0},
                {"curved_rail" ,"horizontal-right-bottom", 256, 128, 0, 0},
                {"curved_rail" ,"horizontal-left-bottom", 256, 128, 0, 0}}
  local res = {}
  for _ , key in ipairs(keys) do
    part = {}
    dashkey = key[1]:gsub("_", "-")
    for _ , elem in ipairs(elems) do
      part[elem[1]] = { sheet = {
        filename = string.format(constants.basePathGraphicsEntity+"%s/%s-%s-%s.png", dashkey, dashkey, key[2], elem[2]),
        priority = "extra-high",
        flags = elem.mipmap and { "icon" },
        width = key[3],
        height = key[4],
        shift = {key[5], key[6]},
        variation_count = (key[7] and elem.variations) or 1,
        hr_version = {
          filename = string.format(constants.basePathGraphicsEntity+"%s/%s-%s-%s.png", dashkey, dashkey, key[2], elem[2]),
          priority = "extra-high",
          flags = elem.mipmap and { "icon" },
          width = key[3],
          height = key[4],
          shift = {key[5], key[6]},
          scale = 1,
          variation_count = (key[7] and elem.variations) or 1,
          }
        }
      }
    end
    dashkey2 = key[2]:gsub("-", "_")
    res[key[1] .. "_" .. dashkey2] = part
  end
  res["rail_endings"] = {
   sheets =
   {
     {
       filename = constants.basePathGraphicsEntity+"rail-endings/rail-endings-background.png",
       priority = "high",
       width = 128,
       height = 128,
       hr_version = {
         filename = constants.basePathGraphicsEntity+"rail-endings/rail-endings-background.png",
         priority = "high",
         width = 128,
         height = 128,
         scale = 1
       }
     },
     {
       filename = constants.basePathGraphicsEntity+"rail-endings/rail-endings-metals.png",
       priority = "high",
       flags = { "icon" },
       width = 128,
       height = 128,
       hr_version = {
         filename = constants.basePathGraphicsEntity+"rail-endings/rail-endings-metals.png",
         priority = "high",
         flags = { "icon" },
         width = 128,
         height = 128,
         scale = 1
       }
     }
   }   

 }
  return res
end

data:extend({
  {
    type = "straight-rail",
    name = "concrete-straight-rail",
    icon = constants.basePathGraphicsIcons+"concrete-straight-rail.png",
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    minable = {mining_time = 0.5, result = "concrete-rail"},
    max_health = 100,
    corpse = "straight-rail-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    collision_box = {{-0.7, -0.8}, {0.7, 0.8}},
    selection_box = {{-0.7, -0.8}, {0.7, 0.8}},
    rail_category = "regular",
    pictures = railpictures(),
  },
  {
    type = "curved-rail",
    name = "concrete-curved-rail",
    icon = constants.basePathGraphicsIcons+"concrete-curved-rail.png",
    flags = {"placeable-neutral", "player-creation", "building-direction-8-way"},
    minable = {mining_time = 0.5, result = "concrete-rail", count = 4},
    max_health = 200,
    corpse = "curved-rail-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    collision_box = {{-0.75, -0.55}, {0.75, 1.6}},
    secondary_collision_box = {{-0.65, -2.43}, {0.65, 2.43}},
    selection_box = {{-1.7, -0.8}, {1.7, 0.8}},
    rail_category = "regular",
    pictures = railpictures(),
    placeable_by = { item="concrete-rail", count = 4}
  },
})
