local npc = custom_npc.npc

minetest.register_craftitem("custom_npc:npc", {
	description = "NPC",
	stack_max = 1,
	inventory_image = "default_bronze_block.png",
	on_place = function(itemstack, placer, pointed_thing)
		local owner = placer:get_player_name()
		local pos = vector(minetest.get_pointed_thing_position(pointed_thing, true)) + vector(0.0, 1.0, 0.0)
		npc(pos, {
			owner = owner
		})
		if custom_npc.creative_mode then
			return nil
		end
		return ItemStack(nil)
	end,
})
