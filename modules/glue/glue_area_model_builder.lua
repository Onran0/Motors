-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local used_model_ids = { }

local SIDE_DIRECTIONS = {
    ["top"] = { 0, 1, 0 },
    ["bottom"] = { 0, -1, 0 },
    ["east"] = { 1, 0, 0 },
    ["west"] = { -1, 0, 0 },
    ["north"] = { 0, 0, -1 },
    ["south"] = { 0, 0, 1 }
}

local INVERSE_SIDE = {
    ["top"] = "bottom",
    ["bottom"] = "top",
    ["east"] = "west",
    ["west"] = "east",
    ["north"] = "south",
    ["south"] = "north"
}

local EDGES_THICKNESS = 0.1
local HALF_EDGES_THICKNESS = EDGES_THICKNESS/2

local M = { }

local function add_edge(vcm_buffer, from, to, direction)
    local inverse_dir = vec3.sub({ 1.0, 1.0, 1.0 }, direction)

    from = vec3.sub(from, vec3.mul(inverse_dir, HALF_EDGES_THICKNESS))
    to = vec3.add(to, vec3.mul(inverse_dir, HALF_EDGES_THICKNESS))

    from = vec3.sub(from, vec3.mul({ 0, 0, HALF_EDGES_THICKNESS }, direction))
    to = vec3.add(to, vec3.mul({ 0, 0, HALF_EDGES_THICKNESS }, direction))

    vcm_buffer[#vcm_buffer + 1] = string.format(
            '\t@box from (%f,%f,%f) to (%f,%f,%f) shading off',
            from[1], from[2], from[3],
            to[1], to[2], to[3]
    )
end

local function add_edges(vcm_buffer, min, max)
    -- vertical edges
    add_edge(vcm_buffer, { min[1], min[2], min[3] }, { min[1], max[2], min[3] }, { 0, 1, 0 })
    add_edge(vcm_buffer, { min[1], min[2], max[3] }, { min[1], max[2], max[3] }, { 0, 1, 0 })
    add_edge(vcm_buffer, { max[1], min[2], min[3] }, { max[1], max[2], min[3] }, { 0, 1, 0 })
    add_edge(vcm_buffer, { max[1], min[2], max[3] }, { max[1], max[2], max[3] }, { 0, 1, 0 })

    -- horizontal edges
    add_edge(vcm_buffer, { min[1], min[2], min[3] }, { max[1], min[2], min[3] }, { 1, 0, 0 })
    add_edge(vcm_buffer, { min[1], max[2], min[3] }, { max[1], max[2], min[3] }, { 1, 0, 0 })

    add_edge(vcm_buffer, { min[1], min[2], min[3] }, { min[1], min[2], max[3] }, { 0, 0, 1 })
    add_edge(vcm_buffer, { min[1], max[2], min[3] }, { min[1], max[2], max[3] }, { 0, 0, 1 })

    add_edge(vcm_buffer, { min[1], min[2], max[3] }, { max[1], min[2], max[3] }, { 1, 0, 0 })
    add_edge(vcm_buffer, { min[1], max[2], max[3] }, { max[1], max[2], max[3] }, { 1, 0, 0 })

    add_edge(vcm_buffer, { max[1], min[2], min[3] }, { max[1], min[2], max[3] }, { 0, 0, 1 })
    add_edge(vcm_buffer, { max[1], max[2], min[3] }, { max[1], max[2], max[3] }, { 0, 0, 1 })
end

function M.build_model(min, max)
    local id

    for used_id, has_holder in ipairs(used_model_ids) do
        if not has_holder then
            id = used_id
            used_model_ids[used_id] = true
            break
        end
    end

    if not id then
        table.insert(used_model_ids, true)
        id = #used_model_ids
    end

    local vcm_buffer = { }

    local minX, minY, minZ = unpack(min)
    local maxX, maxY, maxZ = unpack(max)

    vcm_buffer[#vcm_buffer + 1] = "@bone name glue_blocks {"

    for x = minX, maxX do
        for y = minY, maxY do
            for z = minZ, maxZ do
                local sides_to_delete = { }

                for side, dir in pairs(SIDE_DIRECTIONS) do
                    if UTILS.is_inside_area(
                            x + dir[1], y + dir[2], z + dir[3],
                            min, max
                    ) then
                        sides_to_delete[#sides_to_delete + 1] = side
                    end
                end

                if #sides_to_delete < 6 then
                    vcm_buffer[#vcm_buffer + 1] = "\t@box from (" .. x .. "," .. y .. "," .. z .. ") to (" ..
                    (x + 1) .. "," .. (y + 1) .. "," .. (z + 1) .. ') texture "glue_area" delete (' ..
                    table.concat(sides_to_delete, ",") .. ") shading off"

                    local remaining_sides = table.keys(SIDE_DIRECTIONS)

                    for _, side in ipairs(sides_to_delete) do
                        table.remove(remaining_sides, table.index(remaining_sides, side))
                    end

                    for _, side in ipairs(remaining_sides) do
                        local dir = SIDE_DIRECTIONS[side]

                        local bx = x + dir[1]
                        local by = y + dir[2]
                        local bz = z + dir[3]
                        local to_delete = table.keys(SIDE_DIRECTIONS)

                        table.remove(to_delete, table.index(to_delete, INVERSE_SIDE[side]))

                        vcm_buffer[#vcm_buffer + 1] = "\t@box from (" .. bx .. "," .. by .. "," .. bz .. ") to (" ..
                                (bx + 1) .. "," .. (by + 1) .. "," .. (bz + 1) .. ') texture "glue_area" delete (' ..
                                table.concat(to_delete, ",") .. ") shading off"
                    end
                end
            end
        end
    end

    vcm_buffer[#vcm_buffer + 1] = "}\n@bone name edges {"

    add_edges(vcm_buffer, min, vec3.add(max, {1, 1, 1}))

    vcm_buffer[#vcm_buffer + 1] = "}"

    local content = table.concat(vcm_buffer, '\n')

    local model_name = "motors_glue_area_model_" .. id

    assets.parse_model("vcm", content, model_name, model_name)

    return model_name, id
end

function M.free_model_id(id)
    if used_model_ids[id] then
        used_model_ids[id] = false
    end
end

return M