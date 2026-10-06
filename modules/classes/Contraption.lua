-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local Contraption = {}
Contraption.__index = Contraption

local CONTRAPTIONS = {}

function Contraption.new(origin, glue_areas, id)
    local self = setmetatable({}, Contraption)

    if not id then
        for i = 0, table.count_pairs(CONTRAPTIONS) + 1 do
            if not CONTRAPTIONS[i] then
                id = i
                break
            end
        end
        if not id then
            for a, b in pairs(CONTRAPTIONS) do
                print(a, b)
            end
            error("айди меша равен nil, хз почему")
        end
    end

    self.id = id
    self.blocks = {}
    self.glue_areas = glue_areas or {}
    self.origin = origin
    self.rotation = { 0, 0, 0 }
    self.active = true

    self.loaded = true
    self.deferred_data = nil

    CONTRAPTIONS[id] = self

    return self
end

function Contraption.save()
    local save_tbl = {}
    for _, contr in pairs(CONTRAPTIONS) do
        save_tbl[#save_tbl+1] = contr:to_serialize()
    end

    local bytes = bjson.tobytes(
            {contrs = save_tbl},
            true)
    file.write_bytes(CONTRAPTIONS_SAVING_FILE, bytes)
end

function Contraption.load()
    if not file.exists(CONTRAPTIONS_SAVING_FILE) then
        return
    end

    local bytes = file.read_bytes(CONTRAPTIONS_SAVING_FILE)
    local save_tbl = bjson.frombytes(bytes).contrs

    for _, contr_info in pairs(save_tbl) do
        local contr = Contraption.new(contr_info.origin, contr_info.glue_areas, contr_info.id)
        contr.loaded = false
        contr.deferred_data = contr_info
    end
end

function Contraption.get(id)
    return CONTRAPTIONS[id]
end

function Contraption.remove(id)
    local contr = CONTRAPTIONS[id]
    contr.active = false
    CONTRAPTIONS[id] = nil

    for _, block in pairs(contr.blocks) do
        block.entity:despawn()
    end
end

function Contraption:get_block_entry(unit_id)
    local b = self.blocks[unit_id]
    if not b then return nil end
    if b.segment_of then
        return self.blocks[b.segment_of]
    end
    return b
end

function Contraption:to_serialize()
    local contr_tbl = {
        id = self.id,
        origin = self.origin,
        rotation = self.rotation,
        glue_areas = self.glue_areas,
        blocks = {}
    }

    for _, block in pairs(self.blocks) do
        if not block.segment_of then
            contr_tbl.blocks[#contr_tbl.blocks + 1] = {
                id = block.id,
                variant = block.variant,
                states = block.states,
                uid = block.entity:get_uid(),
                base_rot = block.base_rot,
                local_pos = block.local_pos,
            }
        end
    end

    return contr_tbl
end

function Contraption:wakeup()
    local tbl = self.deferred_data
    if not tbl then return end

    if table.count_pairs(entities.get_all()) < #tbl.blocks then
        return
    end

    local blocks = { }

    for _, block in ipairs(tbl.blocks) do
        local unit_id = UTILS.pos_to_num(block.local_pos)

        local entity = entities.get(block.uid)

        if not entity then
            return
        end

        local logic = entity:require_component("motors:block_logic")

        local rot = bit.band(logic.get_states() or 0, 7)
        local occupied = UTILS.get_occupied_cells(block.id, rot)

        local entry = {
            id = block.id,
            variant = block.variant,
            states = block.states,
            entity = entity,
            base_rot = block.base_rot,
            local_pos = block.local_pos,
            logic = logic,
            occupied = occupied,
            origin_unit_id = unit_id,
        }

        blocks[unit_id] = entry

        for _, offset in ipairs(occupied) do
            if offset[1] ~= 0 or offset[2] ~= 0 or offset[3] ~= 0 then
                local cell_pos = vec3.add(block.local_pos, offset)
                blocks[UTILS.pos_to_num(cell_pos)] = { segment_of = unit_id }
            end
        end
    end

    self.id = tbl.id
    self.origin = tbl.origin
    self.rotation = tbl.rotation
    self.blocks = blocks

    self.deferred_data = nil
    self.loaded = true

    return true
end

function Contraption:get_neighbors(pos)
    local neighbors = {}

    local neighbor_offsets = {
        { 1,  0,  0},
        {-1,  0,  0},
        { 0,  1,  0},
        { 0, -1,  0},
        { 0,  0,  1},
        { 0,  0, -1}
    }

    for _, offset in ipairs(neighbor_offsets) do
        local neighbor_pos = {
            pos[1] + offset[1],
            pos[2] + offset[2],
            pos[3] + offset[3]
        }

        local unit_id = UTILS.pos_to_num(neighbor_pos)

        if self.blocks[unit_id] then
            neighbors[#neighbors+1] = self.blocks[unit_id]
        end
    end
    return neighbors
end

function Contraption:change_origin(pos)
    self.origin = pos

    for _, block in pairs(self.blocks) do
        block.pos = vec3.sub(block.pos, pos)
    end
end

function Contraption:get_unrotated_local_pos(block_world_pos)
    local current_rel_pos = vec3.sub(block_world_pos, self.origin)

    local rot_vec = self.rotation
    local rot_matrix = UTILS.vec_to_mat(rot_vec)
    local inv_rot_matrix = mat4.inverse(rot_matrix)

    local base_rel_pos = mat4.mul(inv_rot_matrix, current_rel_pos)

    return {
        math.floor(base_rel_pos[1]),
        math.floor(base_rel_pos[2]),
        math.floor(base_rel_pos[3])
    }
end

function Contraption:on_update(pos)
    local neighbors = self:get_neighbors(pos)
    for _, neighbour in ipairs(neighbors) do
        neighbour.logic.on_update()
    end
end

function Contraption:get_world_pos_and_rot(local_pos, base_rot)
    local rotation_matrix = UTILS.vec_to_mat(self.rotation)

    local rotated_pos = mat4.mul(rotation_matrix, vec3.add(local_pos, { -0.5, 0, -0.5 }))
    local world_pos = vec3.add(vec3.add(self.origin, { 0.5, 0, 0.5 }), rotated_pos)

    base_rot = base_rot or mat4.idt()
    local world_rot = mat4.mul(rotation_matrix, base_rot)

    return world_pos, world_rot
end

function Contraption:update_block(unit_id, states)
    local entry = self:get_block_entry(unit_id)
    if entry then
        entry.logic.set_states(states)
    end
end

function Contraption:remove_block(unit_id)
    local entry = self:get_block_entry(unit_id)
    if not entry then return end

    for _, offset in ipairs(entry.occupied) do
        local cell_pos = vec3.add(entry.local_pos, offset)
        self.blocks[UTILS.pos_to_num(cell_pos)] = nil
    end

    if not vc.is_client() then
        self:on_update(UTILS.num_to_pos(unit_id))
    end

    entry.entity:despawn()
end

function Contraption:put_block(local_pos, id, variant, states)
    states = states or 0
    variant = variant or 0
    if self.rotation[1] ~= 0 or self.rotation[2] ~= 0 or self.rotation[3] ~= 0 then
        error("Вращение должно быть нулевое")
    end

    if id == -1 or id == 0 then
        return
    end

    local pos = self:get_world_pos_and_rot(local_pos)
    local unit_id = UTILS.pos_to_num(local_pos)
    local rot = bit.band(states, 7)
    local occupied = UTILS.get_occupied_cells(id, rot)

    local to_clear = {}
    for _, offset in ipairs(occupied) do
        local cell_pos = vec3.add(local_pos, offset)
        local cell_unit_id = UTILS.pos_to_num(cell_pos)
        local existing = self.blocks[cell_unit_id]
        if existing then
            local origin_id = existing.segment_of or cell_unit_id
            to_clear[origin_id] = true
        end
    end
    for origin_id in pairs(to_clear) do
        self:remove_block(origin_id)
    end

    local entity = entities.spawn("motors:phys_block", pos,
            {
                motors__block_logic = {
                    id = id,
                    unit_id = unit_id,
                    contr_id = self.id,
                    local_pos = local_pos,
                    states = states
                },
                motors__block_visuals = {
                    id = id,
                    variant = variant
                },
            }
    )

    local entry = {
        id = id,
        variant = variant,
        states = states,
        pos = pos,
        entity = entity,
        base_rot = entity.transform:get_rot(),
        local_pos = local_pos,
        logic = entity:require_component("motors:block_logic"),
        occupied = occupied,
        origin_unit_id = unit_id,
    }

    self.blocks[unit_id] = entry

    for _, offset in ipairs(occupied) do
        if offset[1] ~= 0 or offset[2] ~= 0 or offset[3] ~= 0 then
            local cell_pos = vec3.add(local_pos, offset)
            local cell_unit_id = UTILS.pos_to_num(cell_pos)
            self.blocks[cell_unit_id] = { segment_of = unit_id }
        end
    end

    self:update_block(unit_id, states)

    if not vc.is_client() then
        self:on_update(local_pos)
    end

    return entity
end

function Contraption:__get_relative_pos(entity, pos)
    pos = pos or self.origin
    return vec3.sub(pos, entity.transform:get_pos())
end

function Contraption:__get_blocks_data()
    local data = {}
    for _, block in pairs(self.blocks) do
        data[#data + 1] = { id = block.id, pos = block.pos }
    end
    return data
end

function Contraption:set_pos(pos)
    self.origin = pos
    local rotation_matrix = UTILS.vec_to_mat(self.rotation)

    for _, block in pairs(self.blocks) do
        if not block.segment_of then
            local rotated_pos = mat4.mul(rotation_matrix, block.local_pos)
            local new_pos = vec3.add(self.origin, rotated_pos)
            block.pos = new_pos
            block.entity.transform:set_pos(new_pos)
        end
    end
end

function Contraption:move(move)
    local pos = vec3.add(self.origin, move)
    self:set_pos(pos)
end

function Contraption:get_states()
    local blocks = self.blocks
    local states = {}

    for unit_id, block in pairs(blocks) do
        if not block.segment_of then
            states[unit_id] = block.logic.get_states()
        end
    end

    return states
end

function Contraption:set_rot(rotation_vector)
    self.rotation = rotation_vector
    local rotation_matrix = UTILS.vec_to_mat(rotation_vector)

    for _, block in pairs(self.blocks) do
        if not block.segment_of then
            local rotated_pos = mat4.mul(rotation_matrix, block.local_pos)
            local world_pos = vec3.add(vec3.add(self.origin, { 0.5, 0.5, 0.5 }), rotated_pos)
            local world_rot = mat4.mul(rotation_matrix, block.base_rot)

            block.pos = world_pos

            tsf = block.entity.transform

            tsf:set_pos(world_pos)
            tsf:set_rot(world_rot)
        end
    end
end

return Contraption