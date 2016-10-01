local PATH = minetest.get_modpath("custom_npc")

custom_npc = {}
custom_npc.creative_mode = minetest.setting_getbool("creative_mode")

dofile(PATH.."/vector.lua")
dofile(PATH.."/util.lua")
dofile(PATH.."/move.lua")
dofile(PATH.."/npc.lua")
dofile(PATH.."/entity.lua")
dofile(PATH.."/item.lua")
