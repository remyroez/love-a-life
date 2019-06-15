
local class = require 'middleclass'
local lume = require 'lume'

-- 体コンポーネントクラス
local Base = require 'components.Base'
local Body = class('Body', Base)

-- 初期化
function Body:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'animal'
    t.exchange = t.exchange or {}
    t.exchange.plantal = t.exchange.plantal or 0.1
    t.cost = t.cost or 0
    t.color = t.color or { 1, 0, 0 }
    t.mass = t.mass or 0.5

    -- Base 初期化
    Base.initialize(self, t)

    -- プロパティ
    self.radius = self.radius or 8
    self.grow = self.grow or {}
    self.grow.current = self.grow.current or 5
    self.grow.max = self.grow.max or 5
    self.grow.cost = self.grow.cost or 0.1
end

-- 更新
function Body:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)
end

-- 生長
function Body:grows(dt)
    local rate = 1 - (self.grow.current / self.grow.max)
    local c = math.min(self.energy, self.grow.cost * dt * rate)
    if c > 0 then
        self.energy = self.energy - c
        self.grow.current = self.grow.current + c
    end
end

-- 描画
function Body:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.entity.x, self.entity.y, self.radius * self:growRate(), 8)
end

-- 成長率
function Body:growRate()
    return (self.grow.current / self.grow.max)
end

-- 質量分の栄養素
function Body:massNutrient()
    return self.mass * self.radius * self:growRate()
end

return Body
