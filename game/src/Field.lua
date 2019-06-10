
local class = require 'middleclass'

-- フィールドクラス
local Field = class 'Field'

-- クラス
local Square = require 'Square'

-- 初期化
function Field:initialize(args)
    args = args or {}
    self:setup(args.width, args.height, args.numHorizontal, args.numVertical)
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
    self:decompose(dt)
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
    for x, row in ipairs(self.squares) do
        for y, square in ipairs(row) do
            love.graphics.push()
            love.graphics.translate((x - 1) * self.unitWidth, (y - 1) * self.unitHeight)
            love.graphics.scale(self.unitWidth, self.unitHeight)
            self:drawSquare(square)
            love.graphics.pop()
        end
    end
end

-- 描画
function Field:drawSquare(square)
    love.graphics.setColor(
        square.nutrients.animal,
        square.nutrients.plantal,
        square.nutrients.mineral
    )
    love.graphics.rectangle('fill', 0, 0, 1, 1)
end

return Field
