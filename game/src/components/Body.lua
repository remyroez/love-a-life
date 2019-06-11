
local class = require 'middleclass'
local lume = require 'lume'
local Component = require 'Component'

-- ボディクラス
local Body = class('Body', Component)

-- 初期化
function Body:initialize(t)
    Component.initialize(self, t)

    self.radius = self.radius or 10
end

-- 更新
function Body:update(dt)
end

-- 描画
function Body:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', 0, 0, self.radius)
end

return Body
