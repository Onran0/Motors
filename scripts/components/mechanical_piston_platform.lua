-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"
local Contraption = require "classes/Contraption"

local tsf = entity.transform

local DISASSEMBLE_EXTENSION_REDUCE_SPEED_MS = 12

normalized_signal = 0.0 -- normalized input signal

local src_extension = 0

local data = table.deep_copy(SAVED_DATA.contr and SAVED_DATA or ARGS)

local axis = { block.get_Y(unpack(data.block_pos)) }

local rotation_matrix = ROTATION_MATRICES.pipe[block.get_rotation(unpack(data.block_pos))]

tsf:set_rot(rotation_matrix)

extension = data.extension

local destroy_in_next_frame = false

data.contr = Contraption.get(data.contr)

function on_save()
    local contr = data.contr

    data.contr = contr.id

    local to_save = table.deep_copy(data)

    data.contr = contr

    to_save.extension = extension

    SAVED_DATA = to_save
end

function disassemble()
    if not data.disassembling then
        data.disassembling = true
        data.disassemble_extension = src_extension
    end
end

function on_physics_update()
    if block.get(unpack(data.block_pos)) ~= block.index("motors:mechanical_piston") then
        assembler.disassemble_contraption(data.contr)
        entity:despawn()
    end
end

function update_extension(delta)
    local final_normalized_signal = normalized_signal

    if data.invert_signal then
        final_normalized_signal = 1.0 - final_normalized_signal
    end

    if data.mode == MECH_PISTON_MODE_SPEED_CONTROL then
        extension = math.clamp(
                extension + UTILS.lerp(data.min_speed, data.max_speed, final_normalized_signal) * delta,
                0, data.max_extension
        )
    elseif data.mode == MECH_PISTON_MODE_EXTENSION_CONTROL then
        extension = data.max_extension * final_normalized_signal
    end
end

function on_render(delta)
    if destroy_in_next_frame then
        entity:despawn()
        return
    end

    if data.disassembling then
        if extension == data.disassemble_extension then
            local bx, by, bz = unpack(data.block_pos)

            block.set_variant(bx, by, bz, 0)
            block.set_field(bx, by, bz, "is_assembled", 0)

            assembler.disassemble_contraption(data.contr)

            destroy_in_next_frame = true

            return
        end

        extension = math.max(
                extension - math.max(
                        DISASSEMBLE_EXTENSION_REDUCE_SPEED_MS,
                        math.max(
                                math.abs(data.min_speed),
                                math.abs(data.max_speed)
                        )
                ) * delta,
                data.disassemble_extension
        )
    else
        update_extension(delta)
    end

    data.contr:set_pos(vec3.add(data.block_pos, vec3.mul(axis, extension + 1)))
    tsf:set_pos(
            vec3.add(
                    vec3.add(
                            data.block_pos, vec3.mul(axis, extension)
                    ),
                    { 0.5, 0.5, 0.5 }
            )
    )
end