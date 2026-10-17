-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local logic = require "blocks_logic/mechanical_piston_logic"

function on_placed(x, y, z)
    logic.on_placed(x, y, z)
end

function on_interact(x, y, z)
    MECH_PISTON_SETTINGS = {
        x = x, y = y, z = z,

        mode = block.get_field(x, y, z, "mode"),
        disassemble_condition = block.get_field(x, y, z, "disassemble_condition"),

        min_speed = block.get_field(x, y, z, "min_speed"),
        max_speed = block.get_field(x, y, z, "max_speed"),

        max_extension = block.get_field(x, y, z, "max_extension"),

        invert_signal = block.get_field(x, y, z, "invert_signal") == 1
    }

    hud.show_overlay("motors:mechanical_piston_ui", false)

    return true
end