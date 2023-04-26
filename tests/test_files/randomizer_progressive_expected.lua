Game.LogWarn(0, 'loading RandomizerTestPowerup')

RandomizerTestPowerup = {}
setmetatable(RandomizerTestPowerup, {__index = RandomizerPowerup})
function RandomizerTestPowerup.main()
end
function RandomizerTestPowerup.OnPickedUp(actor)
    Game.LogWarn(0, 'picked up RandomizerTestPowerup')
    local progression = {
{
item_id = "ITEM_TEST_POWERUP",
quantity = 1,
},
}
    RandomizerPowerup.OnPickedUp(actor, progression)
end
