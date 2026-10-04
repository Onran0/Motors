function on_hud_render()
    local item_id, count = inventory.get(player.get_inventory(hud.get_player()))

    SHOW_GLUE_AREAS = count > 0 and item.name(item_id) == "motors:glue"

    local out = entities.raycast({ player.get_pos(pid) }, player.get_dir(pid), 5, player.get_entity(pid))

    if out and out.entity then
        local entity = entities.get(out.entity)

        if entity and entity:def_name() == "motors:glue_area" then
            SELECTED_GLUE_AREA = entity
        else
            SELECTED_GLUE_AREA = nil
        end
    else
        SELECTED_GLUE_AREA = nil
    end
end