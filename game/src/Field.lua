
local class = require 'middleclass'
local lume = require 'lume'

-- フィールドクラス
local Field = class 'Field'

-- クラス
local Square = require 'Square'
local Entity = require 'Entity'

-- 初期化
function Field:initialize(args)
    args = args or {}
    self:setup(args.width, args.height, args.numHorizontal, args.numVertical)
    self:setViewport()
    self.entities = self.entities or {}
    self.removes = {}
    self.maxEntities = self.maxEntities or 10000
end

-- セットアップ
function Field:setup(width, height, numHorizontal, numVertical)
    -- プロパティの設定
    self.width = width or 1000
    self.height = height or 1000
    self.numHorizontal = numHorizontal or 10
    self.numVertical = numVertical or 10

    -- 単位のサイズ
    self.unitWidth = math.floor(self.width / self.numHorizontal)
    self.unitHeight = math.floor(self.height / self.numVertical)

    -- マスの生成
    self.squares = {}
    for x = 1, self.numHorizontal do
        self.squares[x] = {}
        for y = 1, self.numVertical do
            self.squares[x][y] = Square { x = x - 1, y = y - 1, xr = (x - 1) / self.numHorizontal, yr = (y - 1) / self.numVertical }
        end
    end
end

-- マスの取得
function Field:getSquare(x, y)
    x = math.floor((x or 0) / self.unitWidth) + 1
    y = math.floor((y or 0) / self.unitHeight) + 1
    if self.squares[x] then
        return self.squares[x][y]
    end
    return nil
end

-- 描画
function Field:update(dt)
    -- 分解
    --self:decompose(dt)

    -- エンティティ更新
    for _, entity in ipairs(self.entities) do
        if entity:updatable() then
            entity:update(dt)

            -- 削除フラグが立っていればリストに登録
            if entity.remove then
                table.insert(self.removes, entity)
            end
        end
    end

    -- エンティティ削除
    if self.removes[1] then
        for _, entity in ipairs(self.removes) do
            self:removeEntity(entity)
        end
        self.removes = {}
    end
end

-- 分解作用
function Field:decompose(dt)
    for x, row in ipairs(self.squares) do
        for y, square in ipairs(row) do
            square:decompose(dt)
        end
    end
end

-- 描画
function Field:draw()
    -- マスの描画
    for x, row in ipairs(self.squares) do
        local sx = (x - 1) * self.unitWidth
        if self:isView(sx, 0, sx + self.unitWidth, self.height) then
            for y, square in ipairs(row) do
                local  sy = (y - 1) * self.unitHeight
                if self:isView(sx, sy, sx + self.unitWidth, sy + self.unitHeight) then
                    self:drawSquare(square, sx, sy)
                end
            end
        end
    end

    -- マス目の描画
    self:drawMeasures()

    -- エンティティ描画
    for _, entity in ipairs(self.entities) do
        if entity:drawable() and self:isView(entity:rect()) then
            entity:draw()
        end
    end
end

-- マスの描画
function Field:drawSquare(square, x, y)
    love.graphics.setColor(
        square.nutrients.animal,
        square.nutrients.plantal,
        square.nutrients.mineral
    )
    love.graphics.rectangle('fill', x, y, self.unitWidth, self.unitHeight)
end

-- マス目の描画
function Field:drawMeasures()
    love.graphics.setColor(0, 0, 0)
    local p = 0
    for x = 1, self.numHorizontal do
        p = (x - 1) * self.unitWidth
        if p < self.viewport.left then
        elseif p > self.viewport.right then
        else
            love.graphics.line(p, 0, p, self.height)
        end
    end
    for y = 1, self.numVertical do
        p = (y - 1) * self.unitHeight
        if p < self.viewport.top then
        elseif p > self.viewport.bottom then
        else
            love.graphics.line(0, p, self.width, p)
        end
    end
end

-- エンティティの追加
function Field:addEntity(entity)
    if #self.entities >= self.maxEntities then
        -- 最大数オーバー
        return entity, false
    else
        table.insert(self.entities, entity)
        entity.field = self
        return entity, true
    end
end

-- エンティティを生成して追加
function Field:emplaceEntity(t)
    return self:addEntity(Entity(t))
end

-- エンティティの削除
function Field:removeEntity(entity)
    lume.remove(self.entities, entity)
    entity.field = nil
end

-- 表示領域
function Field:setViewport(x, y, w, h)
    local sw, sh = love.graphics.getDimensions()

    self.viewport = self.viewport or {}
    self.viewport.left = x or 0
    self.viewport.top = y or 0
    self.viewport.right = self.viewport.left + (w or sw)
    self.viewport.bottom = self.viewport.top + (h or sh)
end

-- 指定した矩形が表示できるかどうか
function Field:isView(left, top, right, bottom)
    local left = left or 0
    local top = top or 0
    local right = right or left
    local bottom = bottom or top

    return (right > self.viewport.left)
        and (bottom > self.viewport.top)
        and (left < self.viewport.right)
        and (top < self.viewport.bottom)
end

return Field
