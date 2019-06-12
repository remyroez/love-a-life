
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

    -- プロパティ
    self.absorb = self.absorb or {}
    self.absorb.power = self.absorb.power or 0.01
end

-- 更新
function Root:update(dt)
    local square = self.entity.field:getSquare(self.entity.x, self.entity.y)
    if square then
        local n = math.min(square.nutrients.mineral, dt * self.absorb.power)
        square.nutrients.mineral = square.nutrients.mineral - n
        self.nutrients.mineral = self.nutrients.mineral + n
    end
end

return Root
