
-- 成長モジュール
local Growth = {}

-- 初期化
function Growth:initializeGrowth()
    self.energy = self.energy or 0

    self._grow = self._grow or {}
    self._grow.current = self._grow.current or 0
    self._grow.max = self._grow.max or 1
    self._grow.cost = self._grow.cost or 0.1
end

-- 成長処理
function Growth:grows(dt)
    local rate = 1 - (self._grow.current / self._grow.max)
    local c = math.min(self.energy, self._grow.cost * dt * rate)
    if c > 0 then
        self.energy = self.energy - c
        self._grow.current = self._grow.current + c
    end
end

-- 成長率
function Growth:growRate()
    return (self._grow.current / self._grow.max)
end

return Growth
