
local original_TEMPLATE("funcname") = TEMPLATE("scenario").TEMPLATE("funcname")
function TEMPLATE("scenario").TEMPLATE("funcname")(TEMPLATE("args"))
    Game.LogWarn(0, "Starting boss callback")
    original_TEMPLATE("funcname")(TEMPLATE("args"))
    Game.LogWarn(0, "Granting item")
    RandomizerPowerup.MarkLocationCollected("TEMPLATE("scenario")_TEMPLATE("funcname")")
    TEMPLATE("pickup_class").OnPickedUp(nil)
    TEMPLATE("extra_code")
    Game.LogWarn(0, "Item granted")
end