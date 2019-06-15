
local class = require 'middleclass'
local lume = require 'lume'

-- 種コンポーネントクラス
local Base = require 'components.Base'
local Leaf = class('Leaf', Base)

-- 初期化
function Leaf:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'plantal'
    t.exchange = t.exchange or {}
    t.exchange.mineral = t.exchange.mineral or 0.1
    t.cost = t.cost or 0.01
    t.color = t.color or { 0, 1, 0 }
    t.mass = t.mass or 0.5

    -- Base 初期化
    Base.initialize(self, t)

    -- プロパティ
    self.radius = self.radius or 5
    self.grow = self.grow or {}
    self.grow.current = self.grow.current or 0
    self.grow.max = self.grow.max or 1
    self.grow.cost = self.grow.cost or 0.1
    self.timer = 1
end

-- 更新
function Leaf:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)

    -- 種を蒔く
    self:plantSeeds(dt)
end

-- 生長
function Leaf:grows(dt)
    local rate = 1 - (self.grow.current / self.grow.max)
    local c = math.min(self.energy, self.grow.cost * dt * rate)
    if c > 0 then
        self.energy = self.energy - c
        self.grow.current = self.grow.current + c
    end
end

-- 種を蒔く
function Leaf:plantSeeds(dt)
    self.timer = self.timer - dt
    if self.timer > 0 then
        -- タイマー作動中
    elseif self.energy > 0.5 and self.nutrients.mineral > 0.5 and self:growRate() > 0.75 then
        local n = love.math.random(1, 5)
        for i = 1, n do
            local x, y = lume.vector(love.math.random() * math.pi * 2, 10 + love.math.random() * 20)
            self.entity.field:emplaceEntity {
                x = self.entity.x + x, y = self.entity.y + y,
                components = {
                    (require 'components.Seed') {}
                },
            }
        end
        self.energy = self.energy - n * 0.1
        self.nutrients.mineral = self.nutrients.mineral - n * 0.1
        self.timer = love.math.random(10, 100)
    else
        self.timer = 1
    end
end

-- 描画
function Leaf:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.entity.x, self.entity.y, self.radius * self:growRate(), 8)
end

-- 成長率
function Leaf:growRate()
    return (self.grow.current / self.grow.max)
end

-- 質量分の栄養素
function Leaf:massNutrient()
    return self.mass * self.radius * self:growRate()
end

return Leaf
