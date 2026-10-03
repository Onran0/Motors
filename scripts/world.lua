-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

require "globals"
require "utils/func"

local Contraption = require "classes/Contraption"

function on_world_save()
    Contraption.save()
end

function on_world_open()
    Contraption.load()

    if vc.is_client() then
        require("utils/model_manager").register_models()
    end
end