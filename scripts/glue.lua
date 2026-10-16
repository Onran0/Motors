-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local glue_manager = require "glue/glue_manager"

local first_pos

-- calling from hud.lua
function do_glue_break()
    if SELECTED_GLUE_AREA and glue_manager.delete_area_by_entity(SELECTED_GLUE_AREA, true) then
        local ex, ey, ez = unpack(GLUE_AREA_RAYCAST_ENDPOINT)

        audio.play_sound("glue", ex, ey, ez, 1.0, 0.5)

        first_pos = nil
    end
end

function on_block_break_by()
    return true
end

function on_use_on_block(x, y, z)
    audio.play_sound("glue", x, y, z, 1.0, 1.0)

    if not first_pos then
        first_pos = { x, y, z }
    else
        glue_manager.add_area(first_pos, { x, y, z }, true)

        first_pos = nil
    end
end