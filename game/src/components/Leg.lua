
local class = require 'middleclass'
local lume = require 'lume'

-- 脚コンポーネントクラス
local Base = require 'components.Base'
local Leg = class('Leg', Base)

-- 初期化
function Leg:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Base
    t.material = t.material or 'animal'
    t.cost = t.cost or 0
    t.color = t.color or { 1, 0, 0 }
    t.mass = t.mass or 0.1

    -- Base 初期化
    Base.initialize(self, t)

    -- プロパティ
    self.speed = self.speed or 10
    self.legs = self.legs or 4
    self.length = self.length or 10
    self.thickness = self.thickness or 3
    self.angle = self.angle or math.pi * 2 * -0.01
end

-- 更新
function Leg:update(dt)
    -- 回転
    self:rotate(dt)

    -- 移動
    self:move(dt)

    -- Base 更新
    Base.update(self, dt)
end

-- 移動
function Leg:move(dt)
    self.entity:move(self.speed * dt)
end

-- 移動
function Leg:rotate(dt)
    if self.angle ~= 0 then
        self.entity:rotate(self.angle * self.speed * dt)
    end
end

-- 描画
function Leg:draw()
    love.graphics.push()
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.thickness)
    local n = self.legs + 1
    if n % 2 > 0 then
        n = n + 1
    end
    for i = 2, n do
        if i == (n / 2 + 1) then
            -- お尻
        else
            local x, y = lume.vector(math.pi * 2 / n * (i - 1) + self.entity.angle, self.length)
            love.graphics.line(self.entity.x, self.entity.y, self.entity.x + x, self.entity.y + y)
        end
    end
    love.graphics.pop()
end

-- 質量分の栄養素
function Leg:massNutrient()
    return self.mass * self.legs * self.thickness
end

return Leg
