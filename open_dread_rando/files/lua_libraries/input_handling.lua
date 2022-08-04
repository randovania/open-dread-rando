Game.DoFile('system/scripts/bit.lua')

Input = Input or {}

Input.buttons = {
    -- face buttons
    A               = 2 ^ 0,
    B               = 2 ^ 1,
    X               = 2 ^ 2,
    Y               = 2 ^ 3,
    -- stick clicks
    STICKL          = 2 ^ 4,
    STICKR          = 2 ^ 5,
    -- shoulder buttons
    L               = 2 ^ 6,
    R               = 2 ^ 7,
    ZL              = 2 ^ 8,
    ZR              = 2 ^ 9,
    -- pause buttons
    PLUS            = 2 ^ 10,
    MINUS           = 2 ^ 11,
    -- dpad
    DPAD_LEFT       = 2 ^ 12,
    DPAD_UP         = 2 ^ 13,
    DPAD_RIGHT      = 2 ^ 14,
    DPAD_DOWN       = 2 ^ 15,
    -- left stick pseudo-buttons
    STICKL_LEFT     = 2 ^ 16,
    STICKL_UP       = 2 ^ 17,
    STICKL_RIGHT    = 2 ^ 18,
    STICKL_DOWN     = 2 ^ 19,
    -- right stick pseudo-buttons
    STICKR_LEFT     = 2 ^ 20,
    STICKR_UP       = 2 ^ 21,
    STICKR_RIGHT    = 2 ^ 22,
    STICKR_DOWN     = 2 ^ 23,
}

-- check whether all inputs are being held
function Input.CheckInputs(...)
    local held = true
    local inputs = Game.IsDebugPadButtonPressed()
    Input.LogInputs(inputs)

    for _, button in ipairs(arg) do
        held = held and Bit.btest(inputs, Input.buttons[button])
    end

    return held
end

function Input.LogInputs(inputs)
    inputs = inputs or Game.IsDebugPadButtonPressed()

    local state = "Inputs held: "
    for name, bit in pairs(Input.buttons) do
        if Bit.btest(inputs, bit) then
            state = state .. name .. ", "
        end
    end

    Game.LogWarn(0, state)
end