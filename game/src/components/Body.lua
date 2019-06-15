
local class = require 'middleclass'
local lume = require 'lume'

-- ボディコンポーネントクラス
local Component = require 'Component'
local Body = class('Body', Component)

-- 初期化
function Body:initialize(t)
    -- 更新／描画フラグ
    t.updatable = t.updatable ~= nil and t.updatable or false

    -- Component 初期化
    Component.initialize(self, t)

    -- マテリアル
    self.material = 'mineral'

    -- 栄養素
    self.nutrients = self.nutrients or {}
    self.nutrients.animal = self.nutrients.animal or 0
    self.nutrients.plantal = self.nutrients.plantal or 0
    self.nutrients.mineral = self.nutrients.mineral or 0

    -- 栄養素
    self.exchange = self.exchange or {}
    self.exchange.animal  = self.exchange.animal or 0
    self.exchange.plantal = self.exchange.plantal or 0
    self.exchange.mineral = self.exchange.mineral or 0

    -- エネルギー
    self.life = self.life or 1
    self.health = self.health or 0
    self.energy = self.energy or 0
    self.cost = self.cost or 0
    self.healing = self.healing or 0
    self.mass = self.mass or 1

    -- その他プロパティ
    self.radius = self.radius or 10
    self.color = self.color or { 1, 1, 1 }
end

-- 更新
function Body:update(dt)
    self:exchangeNutrients(dt)
    self:payCost(dt)
    if self.life < 0 then
        self:die()
    end
end

-- コストを支払う
function Body:payCost(dt)
    -- コスト
    local cost = self.cost * dt

    -- エネルギー
    if self.energy > 0 then
        self.energy = self.energy - cost
        if self.energy < 0 then
            cost = -self.energy
            self.energy = 0
        else
            cost = 0
        end
    end

    -- ヘルス
    if cost > 0 and self.health > 0 then
        self.health = self.health - cost
        if self.health < 0 then
            cost = -self.health
            self.health = 0
        else
            cost = 0
        end
    end

    -- ライフ
    if cost > 0 then
        self.life = self.life - cost
    end
end

-- 栄養素をエネルギーに交換
function Body:exchangeNutrients(dt)
    for category, rate in pairs(self.exchange) do
        if rate <= 0 then
            -- 変換レートが０
        elseif self.energy >= 1 then
            -- 十分にあるのでスキップ
            break
        elseif self.nutrients[category] > 0 then
            local n = math.min(self.nutrients[category], dt * rate)
            self.nutrients[category] = self.nutrients[category] - n
            self.energy = self.energy + n
        end
    end
end

-- 描画
function Body:draw()
    love.graphics.setColor(self.color)
    love.graphics.polygon(
        'fill',
        self.entity.x - 5, self.entity.y + 5,
        self.entity.x + 5, self.entity.y + 5,
        self.entity.x, self.entity.y - 5
    )
end

-- 質量分の栄養素
function Body:massNutrient()
    return self.mass
end

-- 死亡
function Body:die()
    -- マスに栄養素を送る
    local square = self.entity.field:getSquare(self.entity.x, self.entity.y)
    if square then
        -- 自身を栄養素に変換して送る
        square.nutrients[self.material] = square.nutrients[self.material] + self:massNutrient()

        -- 手持ちの栄養素を送る
        for material, value in pairs(self.nutrients) do
            square.nutrients[material] = square.nutrients[material] + self.nutrients[material]
        end
    end

    -- 削除
    self.remove = true
end

return Body
