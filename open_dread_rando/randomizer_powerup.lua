Game.LogWarn(0, "Loading randomizer_powerup.lua...")

RandomizerPowerup = {}
function RandomizerPowerup.main()
end

RandomizerPowerup.Self = nil

function RandomizerPowerup.OnPickedUp(actor, progression)
    RandomizerPowerup.Self = actor
    local name = "Boss"
    if actor ~= nil then name = actor.sName end
    Game.LogWarn(0, "Collected pickup: " .. name)
    local granted = RandomizerPowerup.ProgressivePickup(progression)
    RandomizerPowerup.ChangeSuit()
    RandomizerPowerup.IncreaseEnergy(granted)
    -- Game.ReinitPlayerFromBlackboard()
    return granted
end

function RandomizerPowerup.ProgressivePickup(progression)
    progression = progression or {}
    local loop = false

    if #progression == 0 then
        return nil
    elseif #progression == 1 then
        loop = true
    end

    local data = "Progression: "
    for _, resource in ipairs(progression) do
        data = data .. resource.item_id .. " (" .. resource.quantity .. ") / "
    end
    Game.LogWarn(0, data)

    for _, resource in ipairs(progression) do
        local current = Game.GetItemAmount(Game.GetPlayerName(), resource.item_id)
        if loop or current < resource.quantity then
            Game.LogWarn(0, "Granting " .. resource.quantity .. " " .. resource.item_id)
            Game.GetPlayer().INVENTORY:SetItemAmount(resource.item_id, current + resource.quantity, true)
            return resource.item_id
        end
    end
end

function RandomizerPowerup.ChangeSuit()
    -- ordered by priority
    local suits = {
        {item = "ITEM_HYPER_SUIT", model = "Hyper"},
        {item = "ITEM_GRAVITY_SUIT", model = "Gravity"},
        {item = "ITEM_VARIA_SUIT", model = "Varia"},
    }
    local model_updater = Game.GetPlayer().MODELUPDATER
    for _, suit in ipairs(suits) do
        if suit.model == model_updater.sModelAlias then break end
        if Game.GetItemAmount(Game.GetPlayerName(), suit.item) > 0 then
            Game.LogWarn(0, "Updating suit to " .. suit.model)
            model_updater.sModelAlias = suit.model
            model_updater:ForceUpdate()
            break
        end
    end
end

function RandomizerPowerup.IncreaseEnergy(item_id)
    if item_id ~= "ITEM_ENERGY_TANKS" and item_id ~= "ITEM_LIFE_SHARDS" then return end
    if item_id == "ITEM_LIFE_SHARDS" and (Game.GetItemAmount(Game.GetPlayerName(), item_id) % 4) ~= 0 then return end
    Game.LogWarn(0, "Increasing player energy.")
    local max = Game.GetItemAmount(Game.GetPlayerName(), "ITEM_MAX_LIFE")
    Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_MAX_LIFE", max+100, true)
    Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_CURRENT_LIFE", max+100, true)
end

-- Main PBs (always) + PB expansions (if required mains are disabled)
RandomizerPowerBomb = {}
setmetatable(RandomizerPowerBomb, {__index = RandomizerPowerup})
function RandomizerPowerBomb.OnPickedUp(actor, progression)
    progression = {{item_id = "ITEM_WEAPON_POWER_BOMB_MAX", quantity = 0}}
    local granted = RandomizerPowerup.OnPickedUp(actor, progression)
    if granted == "ITEM_WEAPON_POWER_BOMB_MAX" then
        Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_POWER_BOMB", 1, true)
    end
end

