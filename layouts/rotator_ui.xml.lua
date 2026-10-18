-- Copyright (C) 2026 Onran
-- SPDX-License-Identifier: GPL-3.0-only

local K = require "kompot:kompot"
local UI = require "kompot:ui"

local rotator_logic = require "blocks_logic/rotator_logic"

local states
local handle

local function close()
    hud.close("motors:rotator_ui")
end

local function apply_settings()
    local old_settings = ROTATOR_SETTINGS

    rotator_logic.set_settings(
            old_settings.x, old_settings.y, old_settings.z,
            {
                mode = states.mode.value - 1,
                min_speed = states.min_speed.value,
                max_speed = states.max_speed.value,
                min_angle = states.min_angle.value,
                max_angle = states.max_angle.value,
                invert_signal = states.invert_signal.value
            }
    )
end

function on_open()
    handle = K.mount({target = document.panel, theme = UI.theme(), content = function()
        UI.Panel({ title = "Настройки вращателя", width = 700 }, function()
            K.Column({spacing = 12}, function()
                local settings = ROTATOR_SETTINGS

                states = {
                    mode = K.state(settings.mode + 1),

                    assemble_button = K.state(rotator_logic.is_assembled(settings.x, settings.y, settings.z)),

                    min_speed = K.state(settings.min_speed),
                    max_speed = K.state(settings.max_speed),

                    min_angle = K.state(settings.min_angle),
                    max_angle = K.state(settings.max_angle),

                    invert_signal = K.state(settings.invert_signal)
                }

                K.Text("Режим работы", { style = "title" })

                UI.Segmented({
                    options = { "Контроль скорости", "Контроль угла" },
                    selected = states.mode.value,
                    on_select = function(v)
                        states.mode.value = v
                    end,
                })

                UI.Slider({
                    label = "Минимальный RPM",
                    value = states.min_speed.value,
                    min = -256,
                    max = 256,
                    step = 1,
                    on_change = function(v)
                        states.min_speed.value = v
                    end,
                })

                UI.Slider({
                    label = "Максимальный RPM",
                    value = states.max_speed.value,
                    min = -256,
                    max = 256,
                    step = 1,
                    on_change = function(v)
                        states.max_speed.value = v
                    end,
                })

                UI.Slider({
                    label = "Минимальный угол",
                    value = states.min_angle.value,
                    min = -180,
                    max = 180,
                    step = 0.1,
                    on_change = function(v)
                        states.min_angle.value = v
                    end,
                })

                UI.Slider({
                    label = "Максимальный угол",
                    value = states.max_angle.value,
                    min = -180,
                    max = 180,
                    step = 0.1,
                    on_change = function(v)
                        states.max_angle.value = v
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
                                        rotator_logic.set_assembled(
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