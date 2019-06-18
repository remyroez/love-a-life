
local class = require 'middleclass'
local lume = require 'lume'

-- 頭コンポーネントクラス
local Base = require 'components.Base'
local Head = class('Head', Base)
Head:include(require 'Growth')

-- 初期化
function Head:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'animal'
    t.energy = t.energy or 1
    t.cost = t.cost or 0.05
    t.color = t.color or { 1, 0, 0 }
    t.mass = t.mass or 0.2

    -- Base 初期化
    Base.initialize(self, t)

    -- Growth 初期化
    self:initializeGrowth()
    self._grow.current = 1

    -- プロパティ
    self.radius = self.radius or 5
    self.providePower = self.providePower or 0.05
end

-- 死亡
function Head:die()
    Base.die(self)

    -- 目コンポーネントも削除
    local eyes = self.entity:getComponents('Eye') or {}
    for _, eye in ipairs(eyes) do
        eye:die()
    end
end

-- 更新
function Head:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)

    -- エネルギーの転送
    self:provideEnergy(dt)
end

-- 栄養の運搬
function Head:provideEnergy(dt)
    local children = {}

    -- Head
    do
        local components = self.entity:getComponents('Eye')
        if components then
            children = lume.concat(children, components)
        end
    end

    -- エネルギーのやりとり
    for _, child in ipairs(children) do
        if (child.energy < self.energy) and (self.energy > 0) then
            local power = math.min(self.energy, self.providePower)
            child.energy = child.energy + power
            self.energy = self.energy - power
        elseif (child.energy > self.energy) and (child.energy > 0) then
            local power = math.min(child.energy, self.providePower)
            child.energy = child.energy - power
            self.energy = self.energy + power
        end
    end
end

-- 描画
function Head:draw()
    love.graphics.setColor(self.color)
    local x, y = lume.vector(self.entity.angle, 5)
    love.graphics.circle('fill', self.entity.x + x, self.entity.y + y, self.radius * self:growRate(), 6)
end

-- 質量分の栄養素
function Head:massNutrient()
    return self.mass * self.radius * self:growRate()
end

return Head
