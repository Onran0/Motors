-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local logic = require "blocks_logic/mechanical_rotator_logic"

function on_placed(x, y, z)
    logic.on_placed(x, y, z)
end

function on_interact(x, y, z)
    MECH_ROTATOR_SETTINGS = {
        x = x, y = y, z = z,

        mode = block.get_field(x, y, z, "mode"),

        min_speed = block.get_field(x, y, z, "min_speed"),
        max_speed = block.get_field(x, y, z, "max_speed"),

        min_angle = block.get_field(x, y, z, "min_angle"),
        max_angle = block.get_field(x, y, z, "max_angle"),

        invert_signal = block.get_field(x, y, z, "invert_signal") == 1
    }

    hud.show_overlay("motors:mechanical_rotator_ui", false)

    return true
end