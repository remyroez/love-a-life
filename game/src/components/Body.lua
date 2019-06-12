
local class = require 'middleclass'
local lume = require 'lume'

-- ボディコンポーネントクラス
local Component = require 'Component'
local Body = class('Body', Component)

-- 初期化
function Body:initialize(t)
    Component.initialize(self, t)

    -- 更新／描画フラグ
    self.updatable = false

    -- 栄養素
    self.nutrients = self.nutrients or {}
    self.nutrients.animal = self.nutrients.animal or 0
    self.nutrients.plantal = self.nutrients.plantal or 0
    self.nutrients.mineral = self.nutrients.mineral or 0

    -- その他プロパティ
    self.radius = self.radius or 10
end

-- 更新
function Body:update(dt)
end

-- 描画
function Body:draw()
    love.graphics.setColor(1, 1, 1)
    --love.graphics.circle('fill', self.entity.x, self.entity.y, self.radius, 3)
    love.graphics.polygon(
        'fill',
        self.entity.x - 5, self.entity.y + 5,
        self.entity.x + 5, self.entity.y + 5,
        self.entity.x, self.entity.y - 5
    )
end

return Body
