
local class = require 'middleclass'
local lume = require 'lume'

-- 目コンポーネントクラス
local Base = require 'components.Base'
local Eye = class('Eye', Base)
Eye:include(require 'Growth')

-- 初期化
function Eye:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'animal'
    t.cost = t.cost or 0
    t.color = t.color or { 0, 0, 0 }
    t.mass = t.mass or 0.1

    -- Base 初期化
    Base.initialize(self, t)

    -- Growth 初期化
    self:initializeGrowth()
    self._grow.current = 1

    -- プロパティ
    self.radius = self.radius or 1
    self.eyes = self.eyes or 1
end

-- 更新
function Eye:update(dt)
    -- 生長
    self:grows(dt)

    -- Base 更新
    Base.update(self, dt)
end

local baseAngle = math.pi

-- 描画
function Eye:draw()
    love.graphics.setColor(self.color)

    -- 頭の座標へのオフセット
    -- TODO: 頭コンポーネントから取得する
    local bx, by = lume.vector(self.entity.angle, 5)

    local n = self.eyes

    -- 偶数かどうか
    local even = n % 2 == 0
    if even then
        -- 偶数なら、真ん中を空けるために１個分増やす
        n = n + 1
    end

    -- 真ん中の数字
    local center = math.ceil(n / 2)

    -- 目の描画
    for i = 1, n do
        if even and i == center then
            -- 偶数のとき、真ん中を空ける
        else
            local angle = self.entity.angle
            if self.eyes > 1 then
                -- １つより多いなら、分割して配置する
                angle = angle - (baseAngle * 0.5) + (baseAngle / n) * (i - 1 + 0.5)
            end
            local x, y = lume.vector(angle, 3)
            love.graphics.circle('fill', self.entity.x + bx + x, self.entity.y + by + y, self.radius * self:growRate(), 6)
        end
    end
end

-- 質量分の栄養素
function Eye:massNutrient()
    return self.mass * self.radius * self:growRate()
end

return Eye
