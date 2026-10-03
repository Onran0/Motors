-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local Mesh = require "classes/Mesh"

local assembler = require "assembler"

function on_interact(x, y, z)
    if block.get_field(x, y, z, "is_assembled") == 1 then
        block.set_variant(x, y, z, 0)
        block.set_field(x, y, z, "is_assembled", 0)

        entities.get(block.get_field(x, y, z, "platform_entity_uid")):despawn()

        local mesh = Mesh.get(block.get_field(x, y, z, "mesh_uid"))

        assembler.disassemble_mesh(mesh)
    else
        block.set_variant(x, y, z, 1)
        block.set_field(x, y, z, "is_assembled", 1)

        local mesh = assembler.assemble_mesh({ x, y + 1, z }, { x + 3, y + 2, z }, { x, y, z })

        local platformEntity = entities.spawn("motors:mechanical_rotator_platform",
                { x + 0.5, y + 0.5, z + 0.5 },
                {
                    motors__mechanical_rotator_platform = {
                        mesh = mesh.id
                    }
                }
        )

        block.set_field(x, y, z, "platform_entity_uid", platformEntity:get_uid())
        block.set_field(x, y, z, "mesh_uid", mesh.id)
    end

    return true
end