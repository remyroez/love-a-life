
local class = require 'middleclass'
local lume = require 'lume'

-- マスクラス
local Square = class 'Square'

-- 初期化
function Square:initialize(t)
    lume.extend(self, type(t) == 'table' and t or {})

    -- 栄養素
    self.nutrients = self.nutrients or {}
    self.nutrients.animal = self.nutrients.animal or love.math.noise(self.xr, self.yr, 0) * 10
    self.nutrients.plantal = self.nutrients.plantal or love.math.noise(self.xr, self.yr, 100) * 10
    self.nutrients.mineral = self.nutrients.mineral or love.math.noise(self.xr, self.yr, 200) * 10

    -- 分解者
    self.decomposer = self.decomposer or {}
    self.decomposer.amount = self.decomposer.amount or 1
    self.decomposer.process = self.decomposer.process or {}
    self.decomposer.process.animal = self.decomposer.process.animal or 0.01
    self.decomposer.process.plantal = self.decomposer.process.plantal or 0.01
end

-- 分解作用
function Square:decompose(dt)
    local plus = 0
    local minus = 0

    for category, power in pairs(self.decomposer.process) do
        local req = dt * self.decomposer.amount * power
        if self.nutrients.mineral >= 10 then
            -- 十分にあるのでスキップ
        elseif self.nutrients[category] > 0 then
            -- 栄養素を分解して、無機栄養素へ変換
            local move = math.min(self.nutrients[category], req)
            self.nutrients[category] = self.nutrients[category] - move
            self.nutrients.mineral = self.nutrients.mineral + move

            -- 報酬
            plus = plus + move + move * love.math.random()
        else
            -- ペナルティ
            minus = minus + req + req * love.math.random()
        end
    end

    -- 分解者の増減
    if plus > 0 then
        self.decomposer.amount = self.decomposer.amount + plus
    elseif minus > 0 then
        self.decomposer.amount = self.decomposer.amount - minus
    end
end

return Square
