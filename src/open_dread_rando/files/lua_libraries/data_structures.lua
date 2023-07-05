Game.ImportLibrary("system/scripts/class.lua", false)

---@class Queue
---@field push fun(self: Queue, item: any)
---@field peek fun(self: Queue): any
---@field pop fun(self: Queue): any
---@field empty fun(self: Queue): boolean

---@type fun(): Queue
Queue = class.New(
---comment
---@param inst Queue
function(inst)
    inst.data = {}

    inst.first = 0
    inst.last = -1

    inst.push = function(self, item)
        self.last = self.last + 1
        self.data[self.last] = item
    end

    inst.peek = function (self)
        if self:empty() then error("Trying to retrieve from an empty queue") end
        return self.data[self.first]
    end

    inst.pop = function(self)
        local value = self:peek()
        self.data[self.first] = nil
        self.first = self.first + 1
        return value
    end

    inst.empty = function(self)
        return self.first > self.last
    end
end)
