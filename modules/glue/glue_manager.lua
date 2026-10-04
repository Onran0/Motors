-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local M = { }

local GLUE_AREAS = { }

local function get_area_id(area_table)
    for uid, area in pairs(GLUE_AREAS) do
        if area == area_table then
            return uid
        end
    end
end

local function add_blocks_from_area(area, dest, visited_areas)
    visited_areas[get_area_id(area)] = true

    local minX, minY, minZ = unpack(area.min)
    local maxX, maxY, maxZ = unpack(area.max)

    for x = minX, maxX do
        for y = minY, maxY do
            for z = minZ, maxZ do
                dest[#dest + 1] = { x, y, z }

                for _, sub_area in ipairs(M.get_glue_areas_at(x, y, z)) do
                    if not visited_areas[get_area_id(sub_area)] then
                        add_blocks_from_area(sub_area, dest, visited_areas)
                    end
                end
            end
        end
    end
end

local function spawn_glue_particles(pos)
    gfx.particles.emit(
            pos, 8,
            {
                texture = "glue_particles",
                lifetime = 1.5,
                spawn_spread = { 1, 0, 1 },
                angle_spread = 0.5,
                spawn_interval = 0.05,
                spawn_shape = "sphere"
            }
    )
end

function M.get_glue_areas()
    return GLUE_AREAS
end

function M.get_glue_areas_at(x, y, z)
    local areas = { }

    for _, area in pairs(GLUE_AREAS) do
        if UTILS.is_inside_area(x, y, z, area.min, area.max) then
            table.insert(areas, area)
        end
    end

    return areas
end

function M.has_glue_areas_at(x, y, z)
    return M.get_glue_areas(x, y, z)
end

function M.get_glued_blocks(x, y, z)
    local blocks = { }

    local visited_areas = { }

    for _, area in ipairs(M.get_glue_areas_at(x, y, z)) do
        add_blocks_from_area(area, blocks, visited_areas)
    end

    return blocks
end

function M.add_area(posA, posB)
    spawn_glue_particles(posA)
    spawn_glue_particles(posB)

    local min = UTILS.vec3_min(posA, posB)
    local max = UTILS.vec3_max(posA, posB)

    local area = {
        min = min,
        max = max
    }

    local entity = entities.spawn("motors:glue_area", min)

    area.entity = entity

    local uid = entity:get_uid()

    GLUE_AREAS[uid] = area

    return entity, uid
end

function M.delete_area_by_uid(uid)
    local area = GLUE_AREAS[uid]

    GLUE_AREAS[area.entity:get_uid()] = nil

    area.entity:despawn()

    GLUE_AREAS[uid] = nil
end

function M.delete_area_by_entity(entity)
    M.delete_area_by_uid(entity:get_uid())
end

function M.get_area_by_uid(uid)
    return GLUE_AREAS[uid]
end

function M.get_area_by_entity(entity)
    local area = GLUE_AREAS[entity:get_uid()]

    if area then
        if not area.loaded then
            area.entity = entity
            area.loaded = true
        end
    end

    return area
end

function M.load()
    if not file.exists(GLUE_AREAS_SAVING_FILE) then
        return
    end

    local raw_areas = bjson.frombytes(file.read_bytes(GLUE_AREAS_SAVING_FILE)).glue_areas

    GLUE_AREAS = { }

    local max_uid = 0

    for uid, raw_area in pairs(raw_areas) do
        uid = tonumber(uid)

        local area = {
            min = raw_area.min,
            max = raw_area.max,
            entity = entities.get(uid)
        }

        area.loaded = area.entity ~= nil

        GLUE_AREAS[uid] = area

        max_uid = math.max(uid, max_uid)
    end

    next_area_uid = max_uid + 1
end

function M.save()
    local raw_areas = { }

    for uid, area in pairs(GLUE_AREAS) do
        raw_areas[tonumber(uid)] = {
            min = area.min,
            max = area.max
        }
    end

    file.write_bytes(GLUE_AREAS_SAVING_FILE,
            bjson.tobytes({ glue_areas = raw_areas }, true)
    )
end

return M