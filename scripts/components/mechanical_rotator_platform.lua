-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"
local Contraption = require "classes/Contraption"

local tsf = entity.transform

local DISASSEMBLE_DURATION_SEC = 1.0
local MIN_ANGLE_DIFF_TO_DISASSEMBLE = 0.25

normalized_signal = 0.0 -- normalized input signal

-- TODO: instead of defined disassemble use closest 90-multiple angle to current angle
local src_angle = 0

local data = table.deep_copy(SAVED_DATA.contr and SAVED_DATA or ARGS)

angle = data.angle

local rotation_matrix = ROTATION_MATRICES.pipe[block.get_rotation(unpack(data.block_pos))]

data.contr = Contraption.get(data.contr)

function on_save()
    local contr = data.contr

    data.contr = contr.id

    local to_save = table.deep_copy(data)

    data.contr = contr

    to_save.angle = angle

    SAVED_DATA = to_save
end

function disassemble()
    if not data.disassembling then
        data.disassembling = true
        data.disassemble_angle = src_angle
        data.disassemble_progress = 0
        angle = angle % 360
    end
end

function on_physics_update()
    if block.get(unpack(data.block_pos)) ~= block.index("motors:mechanical_rotator") then
        assembler.disassemble_contraption(data.contr)
        entity:despawn()
    end
end

function update_angle(delta)
    -- here's min_speed & max_speed is degrees per second

    local final_normalized_signal = normalized_signal

    if data.invert_signal then
        final_normalized_signal = 1.0 - final_normalized_signal
    end

    if data.mode == MECH_ROTATOR_MODE_ROTATION then
        angle = (angle + UTILS.lerp(data.min_speed, data.max_speed, final_normalized_signal) * delta) % 360

        if data.min_angle then
            angle = math.clamp(angle, data.min_angle, data.max_angle)
        end
    elseif data.mode == MECH_ROTATOR_MODE_ANGLE then
        angle = UTILS.lerp(data.min_angle, data.max_angle, final_normalized_signal)
    end
end

function on_render(delta)
    if data.disassembling then
        if UTILS.angles_dist(angle, data.disassemble_angle) <= MIN_ANGLE_DIFF_TO_DISASSEMBLE then
            local bx, by, bz = unpack(data.block_pos)

            block.set_variant(bx, by, bz, 0)
            block.set_field(bx, by, bz, "is_assembled", 0)

            assembler.disassemble_contraption(data.contr)

            entity:despawn()

            return
        end

        data.disassemble_progress = math.min(data.disassemble_progress + delta / DISASSEMBLE_DURATION_SEC, 1.0)

        angle = UTILS.lerp_angle(angle, data.disassemble_angle, data.disassemble_progress)
    else
        update_angle(delta)
    end

    data.contr:set_rot(vec3.mul(data.axis, angle))
    tsf:set_rot(mat4.mul(mat4.rotate(data.axis, angle), rotation_matrix))
end