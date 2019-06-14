
local class = require 'middleclass'
local lume = require 'lume'

-- 種コンポーネントクラス
local Body = require 'components.Body'
local Seed = class('Seed', Body)

-- 初期化
function Seed:initialize(t)
    -- Component
    t.updatable = t.updatable == nil and true or t.updatable
    t.drawable = t.drawable == nil and true or t.drawable

    -- Body
    t.nutrients = t.nutrients or {}
    t.nutrients.mineral = t.nutrients.mineral or 2
    t.exchange = t.exchange or {}
    t.exchange.mineral = t.exchange.mineral or 0.1
    t.cost = t.cost or 0.01
    t.color = t.color or { 1, 1, 0 }

    -- Body 初期化
    Body.initialize(self, t)

    -- プロパティ
    self.sproutThreshold = self.sproutThreshold or 0 --0.5
end

-- 更新
function Seed:update(dt)
    -- 発芽チェック
    self:checkSprout(dt)

    -- Body 更新
    Body.update(self, dt)

    -- カラー更新
    --self.color[1] = (self.life + self.health + self.energy) / 3
    --self.color[2] = self.color[1]
end

-- 描画
function Seed:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.entity.x - 1, self.entity.y - 1, 3, 3)
end

-- 発芽チェック
function Seed:checkSprout(dt)
    -- 地面の取得
    local square = self.entity.field:getSquare(self.entity.x, self.entity.y)
    if square then
        if square.nutrients.mineral > self.sproutThreshold and self.energy > 1 then
            self.entity:addComponent(
                (require 'components.Root'){
                    life = self.life,
                    health = self.health,
                    energy = self.energy,
                    nutrients = self.nutrients
                }
            )
            self.remove = true
        end
    else
        self.remove = true
    end
end

return Seed
