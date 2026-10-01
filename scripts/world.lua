-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

require "globals"
require "utils/func"

local Mesh = require "classes/Mesh"

if vc.is_client() then
    require("utils/model_manager").register_models()
end

function on_world_save()
    Mesh.save()
end

function on_world_open()
    Mesh.load()
end