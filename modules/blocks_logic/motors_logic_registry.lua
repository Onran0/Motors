local M = { }

local logics = { }

function M.register_motor_logic(block_name, logic)
    logics[block_name] = logic
end

function M.get_motor_logic(block_name)
    return logics[block_name]
end

return M