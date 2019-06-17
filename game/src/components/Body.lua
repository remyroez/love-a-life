
local class = require 'middleclass'
local lume = require 'lume'

-- 体コンポーネントクラス
local Base = require 'components.Base'
local Body = class('Body', Base)
Body:include(require 'Growth')

-- 初期化
function Body:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'animal'
    t.exchange = t.exchange or {}
    t.exchange.plantal = t.exchange.plantal or 0.1
    t.energy = t.energy or 5
    t.cost = t.cost or 0.1
    t.color = t.color or { 1, 0, 0 }
    t.mass = t.mass or 0.5

    -- Base 初期化
    Base.initialize(self, t)

    -- Growth 初期化
    self:initializeGrowth()
    self._grow.current = 1

    -- プロパティ
    self.radius = self.radius or 8
    self.providePower = self.providePower or 0.05
end

-- 死亡
function Body:die()
    Base.die(self)

    -- 頭コンポーネントも削除
    local heads = self.entity:getComponents('Head') or {}
    for _, head in ipairs(heads) do
        head:die()
    end
end

-- 更新
function Body:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)

    -- エネルギーの転送
    self:provideEnergy(dt)
end

-- 描画
function Body:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.entity.x, self.entity.y, self.radius * self:growRate(), 8)
end

-- 質量分の栄養素
function Body:massNutrient()
    return self.mass * self.radius * self:growRate()
end

-- 栄養の運搬
function Body:provideEnergy(dt)
    local basePower = self.providePower * dt
    local children = {}

    -- Head
    do
        local components = self.entity:getComponents('Head')
        if components then
            children = lume.concat(children, components)
        end
    end

    -- Leg
    do
        local components = self.entity:getComponents('Leg')
        if components then
            children = lume.concat(children, components)
        end
    end

    -- エネルギーのやりとり
    for _, child in ipairs(children) do
        if (child.energy < self.energy) and (self.energy > 0) then
            local power = math.min(self.energy, basePower)
            child.energy = child.energy + power
            self.energy = self.energy - power
        elseif (child.energy > self.energy) and (child.energy > 0) then
            local power = math.min(child.energy, basePower)
            child.energy = child.energy - power
            self.energy = self.energy + power
        end
    end
end

return Body
