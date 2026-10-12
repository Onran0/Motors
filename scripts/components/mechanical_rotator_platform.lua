-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"
local Contraption = require "classes/Contraption"

local tsf = entity.transform

local DISASSEMBLE_DURATION_SEC = 1.0
local MIN_ANGLE_DIFF_TO_DISASSEMBLE = 0.25

angle = 0
signal = 0

local disassembling = false
local disassemble_angle = 0
local disassemble_progress = 0

local min_angle_speed
local max_angle_speed

local min_angle_limit
local max_angle_limit

local has_angle_limit

local contr
local block_pos
local axis

-- TODO: instead of defined disassemble use closest 90-multiple angle to current angle
local src_angle = 0

if SAVED_DATA.contr then
    contr = SAVED_DATA.contr
    block_pos = SAVED_DATA.block_pos
    axis = SAVED_DATA.axis

    angle = SAVED_DATA.angle

    disassembling = SAVED_DATA.disassembling
    disassemble_angle = SAVED_DATA.disassembling_angle
    disassemble_progress = SAVED_DATA.disassemble_progress

    min_angle_speed = SAVED_DATA.min_angle_speed
    max_angle_limit = SAVED_DATA.max_angle_limit

    has_angle_limit = SAVED_DATA.has_angle_limit

    min_angle_limit = SAVED_DATA.min_angle_limit
    max_angle_limit = SAVED_DATA.max_angle_limit
else
    contr = ARGS.contr
    block_pos = ARGS.block_pos
    axis = ARGS.axis

    min_angle_speed = ARGS.min_angle_speed
    max_angle_limit = ARGS.max_angle_limit

    has_angle_limit = ARGS.has_angle_limit

    min_angle_limit = ARGS.min_angle_limit
    max_angle_limit = ARGS.max_angle_limit

    angle = 0
end

local rotation_matrix = ROTATION_MATRICES.pipe[block.get_rotation(unpack(block_pos))]

contr = Contraption.get(contr)

function on_save()
    SAVED_DATA = {
        contr = contr.id,
        block_pos = block_pos,
        axis = axis,
        angle = angle,
        disassembling = disassembling,
        disassemble_angle = disassemble_angle,
        disassemble_progress = disassemble_progress,

        min_angle_speed = min_angle_speed,
        max_angle_speed = max_angle_speed,

        has_angle_limit = has_angle_limit,

        min_angle_limit = min_angle_limit,
        max_angle_limit = max_angle_limit,
    }
end

function disassemble()
    if not disassembling then
        disassembling = true
        disassemble_angle = src_angle
        disassemble_progress = 0
        angle = angle % 360
    end
end

function on_physics_update()
    if block.get(block_pos[1], block_pos[2], block_pos[3]) ~= block.index("motors:mechanical_rotator") then
        assembler.disassemble_contraption(contr)
        entity:despawn()
    end
end

function on_render(delta)
    if disassembling then
        if UTILS.angles_dist(angle, disassemble_angle) <= MIN_ANGLE_DIFF_TO_DISASSEMBLE then
            local bx, by, bz = unpack(block_pos)

            block.set_variant(bx, by, bz, 0)
            block.set_field(bx, by, bz, "is_assembled", 0)

            assembler.disassemble_contraption(contr)

            entity:despawn()

            return
        end

        disassemble_progress = math.min(disassemble_progress + delta / DISASSEMBLE_DURATION_SEC, 1.0)

        angle = UTILS.lerp_angle(angle, disassemble_angle, disassemble_progress)
    else
        angle = angle + 45 * delta
    end

    contr:set_rot(vec3.mul(axis, angle))
    tsf:set_rot(mat4.mul(mat4.rotate(axis, angle), rotation_matrix))
end