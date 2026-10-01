-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"

local rotY
local mesh

function on_interact(x, y, z)
    if mesh then
        assembler.disassemble_mesh(mesh)
        mesh = nil
    else
        rotY = 0
        mesh = assembler.assemble_mesh({ x, y + 1, z }, { x, y + 1, z })
    end
end

function on_block_tick(x, y, z, tps)
    if mesh then
        mesh:set_rot({ 0, rotY, 0 })
        rotY = rotY + 360/tps
    end
end