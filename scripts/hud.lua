function on_hud_render()
	if mesh then
        mesh:set_rot({ 0, rotY, 0 })
        rotY = rotY + 360*time.delta()
    end
end