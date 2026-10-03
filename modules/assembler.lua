local Mesh = require "classes/Mesh"

local M = { }

local function vec3_min(a, b)
    return {
        math.min(a[1], b[1]),
        math.min(a[2], b[2]),
        math.min(a[3], b[3])
    }
end

local function vec3_max(a, b)
    return {
        math.max(a[1], b[1]),
        math.max(a[2], b[2]),
        math.max(a[3], b[3])
    }
end

function M.assemble_mesh(a, b, origin)
    local startX, startY, startZ = unpack(vec3_min(a, b))
    local endX, endY, endZ = unpack(vec3_max(a, b))

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

                    block.set(x, y, z, 0, true)
                end
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