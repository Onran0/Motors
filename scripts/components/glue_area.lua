-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local glue_manager = require "glue/glue_manager"
local glue_area_model_builder = require "glue/glue_area_model_builder"

local EDGES_AIM_OFF_COLOR = { 1.0, 1.0, 1.0, 1/4 }
local EDGES_AIM_ON_COLOR = { 1.0, 1.0, 1.0, 1.0 }

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

need_model_update = true

local prev_target_edges_color = EDGES_AIM_OFF_COLOR
local target_edges_color = prev_target_edges_color
local edges_color_interp_factor = 1.0
local edges_color_interp_duration = 1/5

local function change_edges_color(new_color)
    if not need_model_update then
        if target_edges_color ~= new_color then
            prev_target_edges_color = target_edges_color
            target_edges_color = new_color
            edges_color_interp_factor = 0.0
        end
    end
end

function on_render(delta)
    if need_model_update then
        local area = glue_manager.get_area_by_entity(entity)

        if not area then
            entity:despawn()
            return
        end

        local offset = vec3.inverse(area.min)

        local min = vec3.add(area.min, offset)
        local max = vec3.add(area.max, offset)

        local model = glue_area_model_builder.build_model(
                vec3.sub(vec3.sub(min, vec3.mul(max, 0.5)), { 0.5, 0.5, 0.5 }),
                vec3.sub(vec3.sub(max, vec3.mul(max, 0.5)), { 0.5, 0.5, 0.5 }),
                entity:get_uid()
        )

        tsf:set_pos(vec3.add(vec3.sub(area.max, vec3.mul(max, 0.5)), { 0.5, 0.5, 0.5 }))
        body:set_size(vec3.add(max, { 1, 1, 1 }))
        entity:set_skeleton(model)

        target_edges_color = EDGES_AIM_OFF_COLOR
        edges_color_interp_factor = 1.0

        rig:set_color(target_edges_color)

        need_model_update = false
    end

    if edges_color_interp_factor < 1.0 then
        edges_color_interp_factor = math.min(
                1.0,
                edges_color_interp_factor + delta / edges_color_interp_duration
        )

        rig:set_color(
                vec4.mix(
                        prev_target_edges_color, target_edges_color,
                        edges_color_interp_factor
                )
        )
    end

    if SELECTED_GLUE_AREA == entity then
        change_edges_color(EDGES_AIM_ON_COLOR)
    else
        change_edges_color(EDGES_AIM_OFF_COLOR)
    end

    rig:set_visible(SHOW_GLUE_AREAS)
end