-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"

function on_placed(x, y, z)
    -- here's min_speed & max_speed is RPM

    block.set_field(x, y, z, "mode", MECH_ROTATOR_MODE_ROTATION)

    block.set_field(x, y, z, "min_speed", 15)
    block.set_field(x, y, z, "max_speed", -15)

    block.set_field(x, y, z, "min_angle", 0)
    block.set_field(x, y, z, "max_angle", 360)

    block.set_field(x, y, z, "invert_signal", 0)
end

function on_interact(x, y, z)
    local axis = { block.get_Y(x, y, z) }

    if block.get_field(x, y, z, "is_assembled") == 1 then
        entities.get(
                block.get_field(x, y, z, "platform_entity_uid")
        ):get_component("motors:mechanical_rotator_platform"):disassemble()
    else
        block.set_variant(x, y, z, 1)
        block.set_field(x, y, z, "is_assembled", 1)

        local targetBlockPos = { x + axis[1], y + axis[2], z + axis[3] }

        local contr = assembler.assemble_contraption(targetBlockPos, targetBlockPos, { x, y, z })

        local platformEntity = entities.spawn("motors:mechanical_rotator_platform",
                { x + 0.5, y + 0.5, z + 0.5 },
                {
                    motors__mechanical_rotator_platform = {
                        mode = block.get_field(x, y, z, "mode"),

                        min_speed = UTILS.rpm_to_degrees_per_sec(block.get_field(x, y, z, "min_speed")),
                        max_speed = UTILS.rpm_to_degrees_per_sec(block.get_field(x, y, z, "max_speed")),

                        min_angle = block.get_field(x, y, z, "min_angle"),
                        max_angle = block.get_field(x, y, z, "max_angle"),

                        invert_signal = block.get_field(x, y, z, "invert_signal") == 1,

                        contr = contr.id,
                        block_pos = { x, y, z },
                        angle = 0,
                        axis = axis
                    }
                }
        )

        block.set_field(x, y, z, "platform_entity_uid", platformEntity:get_uid())
        block.set_field(x, y, z, "contraption_uid", contr.id)
    end

    return true
end