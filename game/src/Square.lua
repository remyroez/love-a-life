
local class = require 'middleclass'
local lume = require 'lume'

-- マスクラス
local Square = class 'Square'

-- 初期化
function Square:initialize(t)
    lume.extend(self, type(t) == 'table' and t or {})

    -- 栄養素
    self.nutrients = self.nutrients or {}
    self.nutrients.animal = self.nutrients.animal or love.math.noise(self.xr, self.yr, 0) * 0.5
    self.nutrients.plantal = self.nutrients.plantal or love.math.noise(self.xr, self.yr, 100) * 0.5
    self.nutrients.mineral = self.nutrients.mineral or love.math.noise(self.xr, self.yr, 200) * 0.5

    -- 分解者
    self.decomposer = self.decomposer or {}
    self.decomposer.amount = self.decomposer.amount or 100
    self.decomposer.process = self.decomposer.process or {}
    self.decomposer.process.animal = self.decomposer.process.animal or 0.0001
    self.decomposer.process.plantal = self.decomposer.process.plantal or 0.0001
end

-- 分解作用
function Square:decompose(dt)
    for category, power in pairs(self.decomposer.process) do
        if self.nutrients.mineral >= 1 then
            -- 十分にあるのでスキップ
            break
        elseif self.nutrients[category] > 0 then
            local move = math.min(self.nutrients[category], dt * self.decomposer.amount * power)
            self.nutrients[category] = self.nutrients[category] - move
            self.nutrients.mineral = self.nutrients.mineral + move
        end
    end
end

return Square
