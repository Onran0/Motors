-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"

function on_interact(x, y, z)
    if mesh then
        assembler.disassemble_mesh(mesh)
        mesh = nil
    else
        rotY = 0
        mesh = assembler.assemble_mesh({ x, y + 1, z }, { x + 3, y + 2, z }, { x, y, z })
    end

    return true
end