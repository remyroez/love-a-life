
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
        width = 300,
        height = 300,
        numHorizontal = 10,
        numVertical = 10,
        maxEntities = 10000,
    }
    for i = 1, 0 do
        self.field:emplaceEntity {
            x = love.math.random(self.field.width),
            y = love.math.random(self.field.height),
            angle = math.pi * 2 * 0.25,
            components = {
                (require 'components.Seed') {},
            },
        }
    end
    for i = 1, 10 do
        self.field:emplaceEntity {
            x = love.math.random(self.field.width),
            y = love.math.random(self.field.height),
            angle = math.pi * 2 * 0.25,
            components = {
                (require 'components.Leg') {},
                (require 'components.Head') {},
                (require 'components.Body') {},
                (require 'components.Eye') {},
            },
        }
    end

    -- 移動モード
    self.move = false
    self.moveOrigin = { x = 0, y = 0 }
    self.offsetOrigin = { x = 0, y = 0 }
    self.offset = { x = 0, y = 0 }
    self.zoom = 0
    self.speed = 1
    self:setOffset()
end

-- 更新
function Game:update(dt, ...)
    dt = dt * self.speed

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
    local str = 'FPS: ' .. tostring(love.timer.getFPS()) .. '\nscale = ' .. self:scale() .. '\nzoom = ' .. self.zoom .. '\nspeed = ' .. self.speed .. '\n'
    local x, y = love.mouse.getPosition()
    x, y = (x - self.offset.x) / self:scale(), (y - self.offset.y) / self:scale()
    str = str .. 'x = ' .. x .. ', y = ' .. y .. '\n\nsquare\n'
    local square = self.field:getSquare(x, y)
    if square then
        str = str .. 'animal = ' .. square.nutrients.animal .. ''
        str = str .. ', plantal = ' .. square.nutrients.plantal .. ''
        str = str .. ', mineral = ' .. square.nutrients.mineral .. ''
        str = str .. '\ndecomposer.amount = ' .. square.decomposer.amount .. '\n'
    end

    str = str .. '\nentities = ' .. #self.field.entities .. '\n\n'
    local entity = self.field.entities[1]
    if entity then
        str = str .. 'entity [1]\n'
        str = str .. '  x = ' .. entity.x .. ', y = ' .. entity.y .. '\n'
        for _, c in ipairs(entity.components) do
            str = str .. '  ' .. c.class.name .. '\n'
            if c.nutrients then
                str = str .. '    life = ' .. c.life .. ', health = ' .. c.health .. ', energy = ' .. c.energy .. ', cost = ' .. c.cost .. '\n'
                str = str .. '    nutrients.animal = ' .. c.nutrients.animal .. ', .plantal = ' .. c.nutrients.plantal .. ', .mineral = ' .. c.nutrients.mineral .. '\n'
            end
        end
    end

    love.graphics.print(str)
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if key == '1' then
        self.speed = 1
    elseif key == '2' then
        self.speed = 2
    elseif key == '3' then
        self.speed = 4
    elseif key == '4' then
        self.speed = 8
    elseif key == '5' then
        self.speed = 16
    elseif key == '6' then
        self.speed = 32
    elseif key == '7' then
        self.speed = 64
    elseif key == '8' then
        self.speed = 128
    elseif key == '9' then
        self.speed = 256
    elseif key == '0' then
        self.speed = 0
    else
    end
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
