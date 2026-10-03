-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"
local Contraption = require "classes/Contraption"

local tsf = entity.transform

angle = 0

local contr
local block_pos
local axis

if SAVED_DATA.contr then
    contr = SAVED_DATA.contr
    block_pos = SAVED_DATA.block_pos
    axis = SAVED_DATA.axis
    angle = SAVED_DATA.angle
else
    contr = ARGS.contr
    block_pos = ARGS.block_pos
    axis = ARGS.axis
    angle = 0
end

local rotation_matrix = ROTATION_MATRICES.pipe[block.get_rotation(unpack(block_pos))]

contr = Contraption.get(contr)

function on_save()
    SAVED_DATA = {
        contr = contr.id,
        block_pos = block_pos,
        axis = axis,
        angle = angle
    }
end

function on_physics_update()
    if block.get(block_pos[1], block_pos[2], block_pos[3]) ~= block.index("motors:mechanical_rotator") then
        assembler.disassemble_contraption(contr)
        entity:despawn()
    end
end

function on_render(delta)
    contr:set_rot(vec3.mul(axis, angle))
    tsf:set_rot(mat4.mul(mat4.rotate(axis, angle), rotation_matrix))

    angle = angle + 180 * 2 * delta
end