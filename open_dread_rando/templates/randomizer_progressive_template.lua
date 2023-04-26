Game.LogWarn(0, 'loading TEMPLATE("name")')

T__name__T = {}
setmetatable(T__name__T, {__index = TEMPLATE("parent")})
function T__name__T.main()
end
function T__name__T.OnPickedUp(actor)
    Game.LogWarn(0, 'picked up TEMPLATE("name")')
    local progression = TEMPLATE("progression")
    TEMPLATE("parent").OnPickedUp(actor, progression)
end
