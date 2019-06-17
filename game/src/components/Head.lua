
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
    t.cost = t.cost or 0
    t.color = t.color or { 1, 0, 0 }
    t.mass = t.mass or 0.2

    -- Base 初期化
    Base.initialize(self, t)

    -- Growth 初期化
    self:initializeGrowth()
    self._grow.current = 1

    -- プロパティ
    self.radius = self.radius or 5
end

-- 更新
function Head:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)
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
