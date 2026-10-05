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
    local mesh = Contraption.new(origin)

    if block.get(unpack(pos)) ~= 0 then
        local glued_blocks = glue_manager.get_glued_blocks(unpack(pos))

        if #glued_blocks > 0 then
            for _, glued_pos in ipairs(glued_blocks) do
                add_block(mesh, origin, unpack(glued_pos))
            end

            for _, glued_pos in ipairs(glued_blocks) do
                block.set(glued_pos[1], glued_pos[2], glued_pos[3], 0, true)
            end
        else
            add_block(mesh, origin, unpack(pos))
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

    Contraption.remove(mesh.id)
end

return M