
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

-- ゲームクラス
local Game = require(folderOfThisFile .. 'class')

-- クラス
local Application = require 'Application'
local Field = require 'Field'

-- 初期化
function Game:initialize(...)
    Application.initialize(self, ...)
end

-- 読み込み
function Game:load(...)
    -- スクリーンサイズ
    self.width, self.height = love.graphics.getDimensions()

    -- フィールド
    self.field = Field {
        width = 100,
        height = 100,
        numHorizontal = 10,
        numVertical = 10,
        maxEntities = 10000,
    }
    for i = 1, 10 do
        local x = love.math.random(self.field.width)
        local y = love.math.random(self.field.height)
        self.field:emplaceEntity {
            x = x,
            y = y,
            left = x - 5,
            top = y - 5,
            width = 10,
            height = 10,
            components = {
                (require 'components.Root') {}
            },
        }
    end

    -- 移動モード
    self.move = false
    self.moveOrigin = { x = 0, y = 0 }
    self.offsetOrigin = { x = 0, y = 0 }
    self.offset = { x = 0, y = 0 }
    self.zoom = 0
    self:setOffset()
end

-- 更新
function Game:update(dt, ...)
    -- 中クリック
    if love.mouse.isDown(3) then
        if not self.move then
            -- 移動モード開始
            self.move = true
            self.moveOrigin.x, self.moveOrigin.y = love.mouse.getPosition()
            self.offsetOrigin.x, self.offsetOrigin.y = self.offset.x, self.offset.y
        else
            -- 移動中
            local x, y = love.mouse.getPosition()
            self:setOffset(self.offsetOrigin.x + x - self.moveOrigin.x, self.offsetOrigin.y + y - self.moveOrigin.y)
        end
    else
        if self.move then
            -- 移動モード終了
            self.move = false
        end
    end

    self.field:update(dt)
end

-- 描画
function Game:draw(...)
    -- フィールド描画
    love.graphics.push()
    do
        love.graphics.translate(self.offset.x, self.offset.y)
        love.graphics.scale(self:scale())
        self.field:draw()
    end
    love.graphics.pop()

    -- デバッグ
    love.graphics.setColor(1, 1, 1)
    local str = 'FPS: ' .. tostring(love.timer.getFPS()) .. '\nscale = ' .. self:scale() .. ', zoom = ' .. self.zoom .. '\n'
    local x, y = love.mouse.getPosition()
    x, y = (x - self.offset.x) / self:scale(), (y - self.offset.y) / self:scale()
    str = str .. 'x = ' .. x .. ', y = ' .. y .. '\n'
    local square = self.field:getSquare(x, y)
    if square then
        str = str .. 'animal = ' .. square.nutrients.animal .. ''
        str = str .. ', plantal = ' .. square.nutrients.plantal .. ''
        str = str .. ', mineral = ' .. square.nutrients.mineral .. ''
    end
    love.graphics.print(str)

    local entity = self.field.entities[1]
    if entity then
        local s = 'entity\n'
        s = s .. '  x = ' .. entity.x .. ', y = ' .. entity.y .. '\n'
        for _, c in ipairs(entity.components) do
            s = s .. '  ' .. c.class.name .. '\n'
            if c.nutrients then
                s = s .. '    life = ' .. c.life .. ', health = ' .. c.health .. ', energy = ' .. c.energy .. ', cost = ' .. c.cost .. '\n'
                s = s .. '    nutrients.animal = ' .. c.nutrients.animal .. ', .plantal = ' .. c.nutrients.plantal .. ', .mineral = ' .. c.nutrients.mineral .. '\n'
            end
        end
        love.graphics.print(s, 0, 100)
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- キー離した
function Game:keyreleased(key, scancode)
end

-- テキスト入力
function Game:textinput(text)
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end

-- マウス離した
function Game:mousereleased(x, y, button, istouch, presses)
end

-- マウス移動
function Game:mousemoved(x, y, dx, dy, istouch)
end

-- マウスホイール
function Game:wheelmoved(x, y)
    if y < 0 and self.zoom > -19 then
        -- ズームアウト
        self.zoom = self.zoom - 1
        self:setOffset()
    elseif y > 0 and self.zoom < 9 then
        -- ズームイン
        self.zoom = self.zoom + 1
        self:setOffset()
    end
end

-- リサイズ
function Game:resize(width, height)
    self.width, self.height = width, height
    self:setOffset()
end

-- リサイズ
function Game:scale()
    if self.zoom == 0 then
        return 1
    elseif self.zoom > 0 then
        return self.zoom + 1
    elseif self.zoom < 0 then
        return 1 / math.abs(self.zoom - 1)
    end
end

-- オフセットの設定
function Game:setOffset(x, y)
    local s = self:scale()
    self.offset.x = math.max(-self.field.width * s + self.width * 0.5, math.min(x or self.offset.x, self.width * 0.5))
    self.offset.y = math.max(-self.field.height * s + self.height * 0.5, math.min(y or self.offset.y, self.height * 0.5))
    self.field:setViewport(-self.offset.x / s, -self.offset.y / s, self.width / s, self.height / s)
end
