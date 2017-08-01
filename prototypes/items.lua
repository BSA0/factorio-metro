require "prototypes/constants"

data:extend({
	{
		type = "rail-planner",
		name = "concrete-rail",
		icon = constants.basePathGraphicsIcons+"concrete-straight-rail.png",
		flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-a[rail]",
		place_result = "concrete-straight-rail",
		stack_size = 100,
		straight_rail = "concrete-straight-rail",
		curved_rail = "concrete-curved-rail"
	},
  {
    type = "item",
    name = "concrete-straight-rail",
    icon = constants.basePathGraphicsIcons+"concrete-straight-rail.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    place_result = "concrete-straight-rail",
    stack_size = 100
  },
	{
    type = "item",
    name = "concrete-curved-rail",
    icon = constants.basePathGraphicsIcons+"concrete-curved-rail.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    place_result = "concrete-curved-rail",
    stack_size = 100
  },
})