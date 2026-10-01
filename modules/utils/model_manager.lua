-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local M = {}

local models = {}

function M.reg_variant(block_id, variant, model)
    if not models[block_id] then
        models[block_id] = { }
    end

    models[block_id][variant + 1] = model
end

function M.get_model(block_id, variant)
    return models[block_id][variant + 1]
end

function M.register_models()
    local model_builder = require "utils/model_builder"

    for id = 0, block.defs_count() - 1 do
        local pack, block_name = parse_path(block.name(id))
        local path = string.format("%s:blocks/%s.json", pack, block_name)

        if pack ~= "core" then
            local data = json.parse(file.read(path))

            local variants = data["state-based"] and data["state-based"].variants

            if not variants then
                variants = { data }
            end

            for i = 1, #variants do
                local vcm = model_builder.build(variants[i])

                if vcm then
                    local raw_model_name = block.model_name(id):match(":(.-)%.")
                    local model_name = string.format("motors__%s__%s__%d", pack, raw_model_name, i - 1)

                    assets.parse_model("vcm", vcm, model_name)

                    M.reg_variant(id, i - 1, {
                        name = model_name,
                        type = GENERATED_MODEL_TYPE
                    })
                else
                    M.reg_variant(id, i - 1, {
                        name = block.model_name(id),
                        type = DEFAULT_MODEL_TYPE
                    })
                end
            end
        end
    end
end

return M