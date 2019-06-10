
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
    self.field = Field{  }
end

-- 更新
function Game:update(dt, ...)
    self.field:update(dt)
end

-- 描画
function Game:draw(...)
    self.field:draw()

    love.graphics.setColor(1, 1, 1)
    local str = ''
    local x, y = love.mouse.getPosition()
    str = str .. 'x = ' .. x .. ', y = ' .. y
    local square = self.field:getSquare(x, y)
    if square then
        str = str .. ', animal = ' .. square.nutrients.animal .. ''
        str = str .. ', plantal = ' .. square.nutrients.plantal .. ''
        str = str .. ', mineral = ' .. square.nutrients.mineral .. ''
    end
    love.graphics.print(str, 0, 50)
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
end

-- リサイズ
function Game:resize(width, height)
end
