-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local K = require "kompot:kompot"
local UI = require "kompot:ui"

local piston_logic = require "blocks_logic/piston_logic"

local states
local handle

local function close()
    hud.close("motors:piston_ui")
end

local function apply_settings()
    local old_settings = PISTON_SETTINGS

    piston_logic.set_settings(
            old_settings.x, old_settings.y, old_settings.z,
            {
                mode = states.mode.value - 1,
                disassemble_condition = states.disassemble_condition.value - 1,

                min_speed = states.min_speed.value,
                max_speed = states.max_speed.value,

                max_extension = states.max_extension.value,

                invert_signal = states.invert_signal.value
            }
    )
end

function on_open()
    handle = K.mount({target = document.panel, theme = UI.theme(), content = function()
        UI.Panel({ title = "Настройки поршня", width = 700 }, function()
            K.Column({spacing = 12}, function()
                local settings = PISTON_SETTINGS

                states = {
                    mode = K.state(settings.mode + 1),
                    disassemble_condition = K.state(settings.disassemble_condition + 1),

                    assemble_button = K.state(piston_logic.is_assembled(settings.x, settings.y, settings.z)),

                    min_speed = K.state(settings.min_speed),
                    max_speed = K.state(settings.max_speed),

                    max_extension = K.state(settings.max_extension),

                    invert_signal = K.state(settings.invert_signal)
                }

                K.Text("Режим работы", { style = "title" })

                UI.Segmented({
                    options = { "Контроль скорости", "Контроль выдвижения" },
                    selected = states.mode.value,
                    on_select = function(v)
                        states.mode.value = v
                    end,
                })

                K.Text("Условие разборки", { style = "title" })

                UI.Segmented({
                    options = { "При остановке в любом положении", "При остановке в исходном положении", "Только вручную" },
                    selected = states.disassemble_condition.value,
                    on_select = function(v)
                        states.disassemble_condition.value = v
                    end,
                })

                UI.Slider({
                    label = "Минимальная скорость (м/с)",
                    value = states.min_speed.value,
                    min = -256,
                    max = 256,
                    step = 1,
                    on_change = function(v)
                        states.min_speed.value = v
                    end,
                })

                UI.Slider({
                    label = "Максимальная скорость (м/с)",
                    value = states.max_speed.value,
                    min = -256,
                    max = 256,
                    step = 1,
                    on_change = function(v)
                        states.max_speed.value = v
                    end,
                })

                UI.Slider({
                    label = "Максимальная дистанция выдвижения",
                    value = states.max_extension.value,
                    min = 0,
                    max = 256,
                    step = 0.25,
                    on_change = function(v)
                        states.max_extension.value = v
                    end,
                })

                UI.Checkbox({
                    label = "Инвертировать сигнал",
                    checked = states.invert_signal.value,
                    on_change = function(v)
                        states.invert_signal.value = v
                    end,
                })

                K.Row({ spacing = 32, align = "center" }, function()
                    UI.Button({
                        text = "Отмена",
                        variant = "danger",
                        on_click = function()
                            time.post_runnable(close)
                        end,
                    })

                    UI.Button({
                        text = "Применить",
                        variant = "primary",
                        on_click = function()
                            apply_settings()
                            time.post_runnable(close)
                        end,
                    })

                    UI.Button({
                        text = states.assemble_button.value and "Разобрать штуковину" or "Собрать штуковину",
                        variant = "primary",
                        on_click = function()
                            states.assemble_button.value = not states.assemble_button.value
                            time.post_runnable(
                                    function()
                                        piston_logic.set_assembled(
                                                settings.x, settings.y, settings.z,
                                                states.assemble_button.value
                                        )
                                    end
                            )
                        end,
                    })
                end)
            end)
        end)
    end})
end

function on_close()
    handle:dispose()
end