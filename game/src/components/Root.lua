
local class = require 'middleclass'
local lume = require 'lume'

-- 根コンポーネントクラス
local Body = require 'components.Body'
local Root = class('Root', Body)

-- 初期化
function Root:initialize(t)
    Body.initialize(self, t)

    -- 更新／描画フラグ
    self.updatable = true
    self.drawable = true

    -- Body
    self.exchange.mineral = 0.001
    self.cost = 0.001

    -- プロパティ
    self.absorb = self.absorb or {}
    self.absorb.power = self.absorb.power or 0.001
end

-- 更新
function Root:update(dt)
    -- 地面から栄養素の吸収
    local square = self.entity.field:getSquare(self.entity.x, self.entity.y)
    if square then
        local t = square.nutrients
        local n = math.min(t.mineral, dt * self.absorb.power)
        t.mineral = t.mineral - n
        self.nutrients.mineral = self.nutrients.mineral + n
    end

    Body.update(self, dt)
end

return Root
