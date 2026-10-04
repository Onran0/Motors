-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

if not vc.is_client() then return end

local body = entity.rigidbody
local rig = entity.skeleton

local model_manager = require "utils/block_visuals_manager"

local block_id = ARGS.id
local block_variant = ARGS.variant

if SAVED_DATA.block then
    block_id = SAVED_DATA.block.id
    block_variant = SAVED_DATA.block.var
end

function on_save()
    SAVED_DATA = {
        block = {
            id = block_id,
            var = block_variant
        },
    }
end

do -- setup visuals
    local model_info = model_manager.get_model(block_id, block_variant)

    rig:set_model(0, model_manager.get_model(block_id, block_variant).name)

    if model_info.type == DEFAULT_MODEL_TYPE then
        rig:set_matrix(0, mat4.translate({-0.5,-0.5,-0.5}))
    end

    body:set_material(block.material(block_id))
end