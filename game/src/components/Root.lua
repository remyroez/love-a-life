
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
    t.cost = t.cost or 0.01
    t.color = t.color or { 1, 1, 1 }

    -- Body 初期化
    Body.initialize(self, t)

    -- プロパティ
    self.absorb = self.absorb or {}
    self.absorb.power = self.absorb.power or 0.1
    self.providePower = self.providePower or 0.05
    self.growTimer = 1
    self.leaf = nil
end

-- 更新
function Root:update(dt)
    -- 地面から栄養素の吸収
    self:absorbNutrients(dt)

    -- 葉の発生
    self:growLeaf(dt)

    -- 栄養を送る
    self:provideNutrients(dt)

    -- Body 更新
    Body.update(self, dt)

    -- カラー更新
    --self.color[2] = (self.life + self.health + self.energy) / 3
end

-- 描画
function Root:draw()
    love.graphics.setColor(self.color)
    --love.graphics.circle('fill', self.entity.x, self.entity.y, self.radius, 3)
    love.graphics.polygon(
        'line',
        self.entity.x - 5, self.entity.y + 5,
        self.entity.x + 5, self.entity.y + 5,
        self.entity.x, self.entity.y - 5
    )
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

-- 葉の発生
function Root:growLeaf(dt)
    self.growTimer = self.growTimer - dt
    if self.growTimer > 0 then
        -- タイマー作動中
    elseif (self.leaf and not self.leaf.remove) or self.entity:hasComponent('Leaf') then
        -- 既に葉がある
        self.growTimer = 100
    elseif self.energy > 0.5 and self.nutrients.mineral > 0.5 then
        self.leaf = self.entity:addComponent(
            (require 'components.Leaf'){
                life = self.life,
                health = self.health,
                energy = self.energy * 0.5,
                nutrients = {
                    mineral = self.nutrients.mineral * 0.5
                }
            }
        )
        self.energy = self.energy * 0.5
        self.nutrients.mineral = self.nutrients.mineral * 0.5
        self.growTimer = 100
    else
        self.growTimer = 1
    end
end

-- 栄養の運搬
function Root:provideNutrients(dt)
    -- 葉が削除されていたら登録解除
    if self.leaf and self.leaf.remove then
        self.leaf = nil
    end

    -- 葉が登録されていなければ検索
    if self.leaf == nil then
        self.leaf = self.entity:getComponent('Leaf')
    end

    -- 処理
    if self.leaf == nil then
        -- 葉がない
    elseif self.leaf.nutrients.mineral >= 1 then
        -- 葉の栄養素が十分
    else
        local n = math.min(self.nutrients.mineral, self.providePower * dt)
        self.nutrients.mineral = self.nutrients.mineral - n
        self.leaf.nutrients.mineral = self.leaf.nutrients.mineral + n
    end
end

return Root
