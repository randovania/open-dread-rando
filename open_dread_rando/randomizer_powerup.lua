local suit_ids = {
    "ITEM_VARIA_SUIT": true,
    "ITEM_GRAVITY_SUIT": true,
    "ITEM_HYPER_SUIT": true,
}

function RandomizerPowerup.main()
end
function RandomizerPowerup:OnPickedUp()
    local granted = self:ProgressivePickup()
    if suit_ids[granted] then
        self.ChangeSuit()
    end
    return granted
end
function RandomizerPowerup:Progression()
    return {}
end

function RandomizerPowerup:ProgressivePickup()
    local progression = self:Progression()
    if table.getn(progression) == 0 then
        return nil
    elseif table.getn(progression) == 1 then
        return progression[0].item_id
    end

    for _, resource in progression:ipairs() do
        local current = Game.GetPlayer().INVENTORY:GetItemAmount(resource.item_id)
        if current < resource.quantity then
            Game.GetPlayer().INVENTORY:SetItemAmount(resource.item_id, current+resource.quantity, true)
            return resource.item_id
        end
    end
end

function RandomizerPowerup.ChangeSuit()
    -- ordered by priority
    local suits = {
        {"item": "ITEM_HYPER_SUIT":, "model": "Hyper"},
        {"item": "ITEM_GRAVITY_SUIT", "model": "Gravity"},
        {"item": "ITEM_VARIA_SUIT", "model": "Varia"},
    }
    for _, suit in ipairs(suits) do
        if Game.GetPlayer().INVENTORY:GetItemAmount(suit.item) > 0 then
            Game.GetPlayer().MODELUPDATER.sModelAlias = suit.model
            Game.GetPlayer().MODELUPDATER:ForceUpdate()
            break
        end
    end
end

local metatable = {}
metatable.__index = RandomizerPowerup

-- Main PBs (always) + PB expansions (if required mains are disabled)
RandomizerPowerBomb = {}
setmetatable(RandomizerPowerBomb, metatable)
function RandomizerPowerBomb:OnPickedUp()
    local granted = RandomizerPowerup.OnPickedUp(self)
    if granted == "ITEM_WEAPON_POWER_BOMB_MAX" then
        Game.GetPlayer().INVENTORY:SetItemAmount("ITEM_WEAPON_POWER_BOMB", 1, true)
    end
end

