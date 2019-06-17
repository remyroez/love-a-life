
local class = require 'middleclass'
local lume = require 'lume'

-- 頭コンポーネントクラス
local Base = require 'components.Base'
local Head = class('Head', Base)

-- 初期化
function Head:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'animal'
    t.cost = t.cost or 0
    t.color = t.color or { 1, 0, 0 }
    t.mass = t.mass or 0.2

    -- Base 初期化
    Base.initialize(self, t)

    -- プロパティ
    self.radius = self.radius or 5
    self.grow = self.grow or {}
    self.grow.current = self.grow.current or 5
    self.grow.max = self.grow.max or 5
    self.grow.cost = self.grow.cost or 0.1
end

-- 更新
function Head:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)
end

-- 生長
function Head:grows(dt)
    local rate = 1 - (self.grow.current / self.grow.max)
    local c = math.min(self.energy, self.grow.cost * dt * rate)
    if c > 0 then
        self.energy = self.energy - c
        self.grow.current = self.grow.current + c
    end
end

-- 描画
function Head:draw()
    love.graphics.setColor(self.color)
    local x, y = lume.vector(self.entity.angle, 5)
    love.graphics.circle('fill', self.entity.x + x, self.entity.y + y, self.radius * self:growRate(), 6)
end

-- 成長率
function Head:growRate()
    return (self.grow.current / self.grow.max)
end

-- 質量分の栄養素
function Head:massNutrient()
    return self.mass * self.radius * self:growRate()
end

return Head
