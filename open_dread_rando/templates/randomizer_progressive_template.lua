Game.LogWarn(0, "loading TEMPLATE("name")")

TEMPLATE("name") = {}
setmetatable(TEMPLATE("name"), {__index = TEMPLATE("parent")})
function TEMPLATE("name").main()
end
function TEMPLATE("name").OnPickedUp(actor)
    Game.LogWarn(0, "picked up TEMPLATE("name")")
    local progression = TEMPLATE("progression")
    TEMPLATE("parent").OnPickedUp(actor, progression)
end
