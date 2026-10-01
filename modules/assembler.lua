local Mesh = require "classes/Mesh"

local M = { }

function M.assemble_mesh(startPos, endPos)
    local startX, startY, startZ = unpack(startPos)
    local endX, endY, endZ = unpack(endPos)

    local origin = vec3.add(vec3.div(vec3.add(startPos, endPos), 2), { 0.5, 0, 0.5 })

    local mesh = Mesh.new(nil, { }, origin)

    for x = startX, endX do
        for y = startY, endY do
            for z = startZ, endZ do
                local id = block.get(x, y, z)

                if id ~= 0 and id ~= -1 then
                    local localPos = vec3.sub({ x, y, z }, origin)

                    local variant = block.get_variant(x, y, z)
                    local states = block.get_states(x, y, z)

                    mesh:put_block(localPos, id, variant, states)
                end
            end
        end
    end

    for x = startX, endX do
        for y = startY, endY do
            for z = startZ, endZ do
                block.destruct(x, y, z, 0)
            end
        end
    end

    return mesh
end

function M.disassemble_mesh(mesh)
    for _, block_data in pairs(mesh.blocks) do
        local finalPos = vec3.add(block_data.local_pos, mesh.origin)

        local x, y, z = math.floor(finalPos[1]), math.floor(finalPos[2]), math.floor(finalPos[3])

        block.set(x, y, z, block_data.id, block_data.states, true)
        block.set_variant(x, y, z, block_data.variant)
    end

    Mesh.remove(mesh.id)
end

return M