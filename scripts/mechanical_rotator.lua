-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"

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