-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local Mesh = require "classes/Mesh"
local tsf = entity.transform

angle = 0

local mesh

if SAVED_DATA.mesh then
    mesh = SAVED_DATA.mesh
    angle = SAVED_DATA.angle
else
    mesh = ARGS.mesh
    angle = 0
end

mesh = Mesh.get(mesh)

function on_save()
    SAVED_DATA = {
        mesh = mesh.id,
        angle = angle
    }
end

function on_render(delta)
    mesh:set_rot({0, angle, 0})
    tsf:set_rot(mat4.rotate({ 0, 1, 0 }, angle))

    angle = angle + 180 * delta
end