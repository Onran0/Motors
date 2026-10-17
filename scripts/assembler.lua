local motors_logic_registry = require("blocks_logic/motors_logic_registry")

function on_use_on_block(x, y, z)
    local logic = motors_logic_registry.get_motor_logic(block.name(block.get(x, y, z)))

    if logic then
        logic.set_assembled(x, y, z, not logic.is_assembled(x, y, z))
    end

    return true
end