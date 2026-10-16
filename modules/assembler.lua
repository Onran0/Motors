local glue_manager = require "glue/glue_manager"
local Contraption = require "classes/Contraption"

local M = { }

local function add_block(mesh, origin, x, y, z)
    local id = block.get(x, y, z)

    if id ~= 0 and id ~= -1 then
        local localPos = vec3.sub({ x, y, z }, origin)

        local variant = block.get_variant(x, y, z)
        local states = block.get_states(x, y, z)

        mesh:put_block(localPos, id, variant, states)
    end
end

function M.assemble_contraption(pos, origin)
    local mesh

    if block.get(unpack(pos)) ~= 0 then
        local glued_blocks, glue_areas = glue_manager.get_glued_blocks_and_areas(unpack(pos))

        if #glued_blocks > 0 then
            for i, uid in ipairs(glue_areas) do
                local min, max = glue_manager.get_area_min_max_by_uid(uid)

                glue_areas[i] = {
                    min = min,
                    max = max
                }

                glue_manager.delete_area_by_uid(uid)
            end

            mesh = Contraption.new(origin, glue_areas)

            for _, glued_pos in ipairs(glued_blocks) do
                add_block(mesh, origin, unpack(glued_pos))
            end

            for _, glued_pos in ipairs(glued_blocks) do
                block.set(glued_pos[1], glued_pos[2], glued_pos[3], 0, true)
            end
        else
            mesh = Contraption.new(origin)
            add_block(mesh, origin, unpack(pos))
            block.set(pos[1], pos[2], pos[3], 0, true)
        end
    end

    return mesh
end

function M.disassemble_contraption(mesh)
    for _, block_data in pairs(mesh.blocks) do
        local finalPos = vec3.add(block_data.local_pos, mesh.origin)

        local x, y, z = math.floor(finalPos[1]), math.floor(finalPos[2]), math.floor(finalPos[3])

        block.set(x, y, z, block_data.id, block_data.states, true)
        block.set_variant(x, y, z, block_data.variant)
    end

    if mesh.glue_areas then
        for _, area_data in ipairs(mesh.glue_areas) do
            glue_manager.add_area(area_data.min, area_data.max)
        end
    end

    Contraption.remove(mesh.id)
end

return M