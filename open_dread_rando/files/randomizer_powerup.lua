Game.LogWarn(0, "Loading randomizer_powerup.lua...")

RandomizerPowerup = {}
function RandomizerPowerup.main()
end

RandomizerPowerup.Self = nil

function RandomizerPowerup.SetItemAmount(item_id, quantity)
    if type(quantity) == "string" then
        quantity = RandomizerPowerup.GetItemAmount(quantity)
    end
    Game.SetItemAmount(Game.GetPlayerName(), item_id, quantity)
end
function RandomizerPowerup.GetItemAmount(item_id)
    return Game.GetItemAmount(Game.GetPlayerName(), item_id)
end
function RandomizerPowerup.IncreaseItemAmount(item_id, quantity, capacity)
    local target = RandomizerPowerup.GetItemAmount(item_id) + quantity
    if capacity ~= nil then
        if type(capacity) == "string" then
            capacity = RandomizerPowerup.GetItemAmount(capacity)
        end
        target = math.min(target, capacity)
    end
    RandomizerPowerup.SetItemAmount(item_id, target)
end

function RandomizerPowerup.OnPickedUp(actor, progression)
    RandomizerPowerup.Self = actor
    local name = "Boss"
    if actor ~= nil then name = actor.sName end
    Game.LogWarn(0, "Collected pickup: " .. name)
    local granted = RandomizerPowerup.ProgressivePickup(actor, progression)
    RandomizerPowerup.ChangeSuit()
    RandomizerPowerup.IncreaseEnergy(granted)
    RandomizerPowerup.IncreaseAmmo(granted)

    local oPlayer = Game.GetPlayer()
    if oPlayer ~= nil then
        oPlayer.INPUT:IgnoreInput(true, false, "PickupObtained")
    end
    Game.AddSF(0.1, RandomizerPowerup.RecoverInput, "")
    return granted
end

function RandomizerPowerup.RecoverInput()
    -- items with unique inputs (Speed Booster, Phantom Cloak) require disabling and re-enabling inputs to work properly
    local oPlayer = Game.GetPlayer()
    if oPlayer ~= nil then
        oPlayer.INPUT:IgnoreInput(false, false, "PickupObtained")
    end
end

function RandomizerPowerup.ProgressivePickup(actor, progression)
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
        local current = RandomizerPowerup.GetItemAmount(resource.item_id)
        if loop or current < resource.quantity then
            Game.LogWarn(0, "Granting " .. resource.quantity .. " " .. resource.item_id)
            RandomizerPowerup.IncreaseItemAmount(resource.item_id, resource.quantity)
            return resource
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
        if RandomizerPowerup.GetItemAmount(suit.item) > 0 then
            Game.LogWarn(0, "Updating suit to " .. suit.model)
            model_updater.sModelAlias = suit.model
            model_updater:ForceUpdate()
            break
        end
    end
end

function RandomizerPowerup.IncreaseEnergy(resource)
    if resource == nil then return end
    local item_id = resource.item_id
    if item_id ~= "ITEM_ENERGY_TANKS" and item_id ~= "ITEM_LIFE_SHARDS" then return end
    if item_id == "ITEM_LIFE_SHARDS" and (RandomizerPowerup.GetItemAmount(item_id) % 4) ~= 0 then return end
    Game.LogWarn(0, "Increasing player energy.")
    RandomizerPowerup.IncreaseItemAmount("ITEM_MAX_LIFE", 100)
    RandomizerPowerup.SetItemAmount("ITEM_CURRENT_LIFE", "ITEM_MAX_LIFE")
end

function RandomizerPowerup.IncreaseAmmo(resource)
    if resource == nil then return end
    local current_id = nil

    if resource.item_id == "ITEM_WEAPON_POWER_BOMB_MAX" then
        current_id = "ITEM_WEAPON_POWER_BOMB_CURRENT"
    elseif resource.item_id == "ITEM_WEAPON_MISSILE_MAX" then
        current_id = "ITEM_WEAPON_MISSILE_CURRENT"
    end

    if current_id == nil then return end

    RandomizerPowerup.IncreaseItemAmount(current_id, resource.quantity, resource.item_id)
end

-- Main PBs (always) + PB expansions (if required mains are disabled)
RandomizerPowerBomb = {}
setmetatable(RandomizerPowerBomb, {__index = RandomizerPowerup})
function RandomizerPowerBomb.OnPickedUp(actor, progression)
    progression = {{item_id = "ITEM_WEAPON_POWER_BOMB_MAX", quantity = 0}}
    local granted = RandomizerPowerup.OnPickedUp(actor, progression)
    if granted ~= nil and granted.item_id == "ITEM_WEAPON_POWER_BOMB_MAX" then
        RandomizerPowerup.SetItemAmount("ITEM_WEAPON_POWER_BOMB", 1)
    end
end

RandomizerPhantomCloak = {}
setmetatable(RandomizerPhantomCloak, {__index = RandomizerPowerup})
function RandomizerPhantomCloak.OnPickedUp(actor, progression)
    local has_cloak_already = RandomizerPowerup.GetItemAmount("ITEM_OPTIC_CAMOUFLAGE") > 0
    RandomizerPowerup.OnPickedUp(actor, progression)
    if not has_cloak_already then
        Game.AddSF(0.101, RandomizerPhantomCloak.Deactivate, "")
    end
end

function RandomizerPhantomCloak.Deactivate()
    -- prevent the pickup from trying to kill you
    Game.GetPlayer().SPECIALENERGY:Fill()
end
