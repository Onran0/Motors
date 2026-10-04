-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

require "globals"
require "utils/func"

local Contraption = require "classes/Contraption"
local glue_manager = require "glue/glue_manager"

function on_world_save()
    Contraption.save()
    glue_manager.save()
end

function on_world_open()
    Contraption.load()
    glue_manager.load()

    require("utils/block_visuals_manager").register_models()
end