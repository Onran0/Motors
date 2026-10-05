local glue_manager = require "glue/glue_manager"

function on_hud_render()
    local pid = hud.get_player()

    local item_id, count = inventory.get(player.get_inventory(pid))

    SHOW_GLUE_AREAS = count > 0 and item.name(item_id) == "motors:glue"

    local out = world.raycast(
            {
                start = cameras.get(player.get_camera(pid)):get_pos(),
                dir = player.get_dir(pid), distance = 5,

                ignore_uid = player.get_entity(pid),

                filter_entities = { "motors:glue_area" },
                nonselect_entities = true,

                filter_blocks = { },
                blocks_exclusion = false
            }
    )

    if out and out.entity then
        local ex, ey, ez = unpack(out.endpoint)

        local areas = glue_manager.get_glue_areas_at(math.floor(ex), math.floor(ey), math.floor(ez))

        if #areas > 0 then
            SELECTED_GLUE_AREA = areas[1].entity
        else
            SELECTED_GLUE_AREA = entities.get(out.entity)
        end
    else
        SELECTED_GLUE_AREA = nil
    end
end

function on_hud_open()
    input.add_callback(
            "player.attack",
            function()
                if SHOW_GLUE_AREAS and not hud.is_paused() then
                    do_glue_break()
                end
            end
    )
end