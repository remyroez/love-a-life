
local class = require 'middleclass'
local lume = require 'lume'

-- 種コンポーネントクラス
local Body = require 'components.Body'
local Leaf = class('Leaf', Body)

-- 初期化
function Leaf:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Body
    t.material = t.material or 'plantal'
    t.exchange = t.exchange or {}
    t.exchange.mineral = t.exchange.mineral or 0.1
    t.cost = t.cost or 0.01
    t.color = t.color or { 0, 1, 0 }

    -- Body 初期化
    Body.initialize(self, t)

    -- プロパティ
    self.radius = self.radius or 5 --0.5
    self.grow = self.grow or {}
    self.grow.current = self.grow.current or 0
    self.grow.max = self.grow.max or 1
    self.grow.cost = self.grow.cost or 0.1
end

-- 更新
function Leaf:update(dt)
    -- 生長
    self:grows(dt)

    -- Body 更新
    Body.update(self, dt)
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

-- 描画
function Leaf:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.entity.x, self.entity.y, self.radius * (self.grow.current / self.grow.max), 5)
end

return Leaf
