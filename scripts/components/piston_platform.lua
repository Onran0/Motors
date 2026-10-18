-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local assembler = require "assembler"
local Contraption = require "classes/Contraption"

local ROD_SIZE = 0.25
local BASE_HEIGHT = 0.75
local BASE_EMPTY_SPACE = 1 - BASE_HEIGHT

local tsf = entity.transform
local rig = entity.skeleton
local body = entity.rigidbody

local rod_bone = rig:index("rod")

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
    if block.get(unpack(data.block_pos)) ~= block.index("motors:piston") then
        assembler.disassemble_contraption(data.contr)
        entity:despawn()
    end
end

function update_extension(delta)
    local final_normalized_signal = normalized_signal

    if data.invert_signal then
        final_normalized_signal = 1.0 - final_normalized_signal
    end

    if data.mode == PISTON_MODE_SPEED_CONTROL then
        extension = math.clamp(
                extension + UTILS.lerp(data.min_speed, data.max_speed, final_normalized_signal) * delta,
                0, data.max_extension
        )
    elseif data.mode == PISTON_MODE_EXTENSION_CONTROL then
        extension = data.max_extension * final_normalized_signal
    end
end

function on_render(delta)
    if not destroy_in_next_frame then
        if data.disassembling then
            if extension == data.disassemble_extension then
                local bx, by, bz = unpack(data.block_pos)

                block.set_variant(bx, by, bz, 0)
                block.set_field(bx, by, bz, "is_assembled", 0)

                assembler.disassemble_contraption(data.contr)

                destroy_in_next_frame = true
            end

            extension = math.max(
                    extension - math.max(
                            math.abs(data.min_speed),
                            math.abs(data.max_speed)
                    ) * delta,
                    data.disassemble_extension
            )
        else
            update_extension(delta)
        end
    end

    data.contr:set_pos(vec3.add(data.block_pos, vec3.mul(axis, extension + 1)))

    local pos = vec3.add(
            vec3.add(
                    data.block_pos, vec3.mul(axis, extension / 2 + BASE_EMPTY_SPACE / 2)
            ),
            { 0.5, 0.5, 0.5 }
    )

    tsf:set_pos(pos)

    rig:set_matrix(0, mat4.translate(
            { 0, extension / 2 - BASE_EMPTY_SPACE / 2, 0 }
    ))

    if destroy_in_next_frame then
        entity:despawn()
        return
    end

    local body_size = vec3.mul(axis, math.max(extension + BASE_HEIGHT, 0.01))

    for i = 1, #body_size do
        if body_size[i] == 0 then
            body_size[i] = 0.99999
        end
    end

    body:set_size(body_size)

    rig:set_matrix(rod_bone, mat4.mul(
            mat4.translate({ 0, extension/2 - extension - BASE_EMPTY_SPACE, 0 }),
            mat4.scale({ ROD_SIZE, extension + BASE_EMPTY_SPACE, ROD_SIZE })
    ))
end