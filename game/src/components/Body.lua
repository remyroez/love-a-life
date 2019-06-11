
local class = require 'middleclass'
local lume = require 'lume'

-- ボディコンポーネントクラス
local Body = class('Body', require 'Component')

-- 初期化
function Body:initialize(t)
    self.class.super.initialize(self, t)

    self.updatable = false
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
