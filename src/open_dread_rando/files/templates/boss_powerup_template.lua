
local original_T__funcname__T = TEMPLATE("scenario").TEMPLATE("funcname")
function T__scenario__T.T__funcname__T(T__args__T)
    Game.LogWarn(0, "Starting boss callback")
    original_T__funcname__T(T__args__T)
    Game.LogWarn(0, "Granting item")
    RandomizerPowerup.MarkLocationCollected('TEMPLATE("scenario")_TEMPLATE("funcname")')
    TEMPLATE("pickup_class").OnPickedUp(nil)
    TEMPLATE("extra_code")
    Game.LogWarn(0, "Item granted")
end