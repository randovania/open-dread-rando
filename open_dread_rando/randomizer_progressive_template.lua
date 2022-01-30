
setmetatable(TEMPLATE("name"), mt)
function TEMPLATE("name").main()
end
function TEMPLATE("name").OnPickedUp(actor)
    local progression = TEMPLATE("progression")
    RandomizerPowerup.OnPickedUp(actor, progression)
end
