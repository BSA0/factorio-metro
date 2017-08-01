require "prototypes/constants"

data:extend({
	{
    type = "technology",
    name = "concrete-railway-tracks",
    icon = constants.basePathGraphics+"concrete-railway-tracks.png",
    icon_size = 64,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "concrete-rail"
      },
    },
    prerequisites = {"railway", "concrete"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
      },
      time = 20
    },
    order = "c-g-a",
  },
})
