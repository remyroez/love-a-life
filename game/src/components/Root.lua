
local class = require 'middleclass'
local lume = require 'lume'

-- 根コンポーネントクラス
local Body = require 'components.Body'
local Root = class('Root', Body)

-- 初期化
function Root:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Body
    t.material = t.material or 'plantal'
    t.exchange = t.exchange or {}
    t.exchange.mineral = t.exchange.mineral or 0.1
    t.cost = t.cost or 0.1
    t.color = t.color or { 0, 1, 0 }

    -- Body 初期化
    Body.initialize(self, t)

    -- プロパティ
    self.absorb = self.absorb or {}
    self.absorb.power = self.absorb.power or 0.1
end

-- 更新
function Root:update(dt)
    -- 地面から栄養素の吸収
    self:absorbNutrients(dt)

    Body.update(self, dt)

    self.color[2] = (self.life + self.health + self.energy) / 3
end

-- 栄養素の吸収
function Root:absorbNutrients(dt)
    -- 地面の取得
    local square = self.entity.field:getSquare(self.entity.x, self.entity.y)
    if square then
        local t = square.nutrients
        local n = math.min(t.mineral, dt * self.absorb.power)
        t.mineral = t.mineral - n
        self.nutrients.mineral = self.nutrients.mineral + n
    end
end

return Root
