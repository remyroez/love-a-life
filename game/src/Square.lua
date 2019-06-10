
local class = require 'middleclass'

-- マスクラス
local Square = class 'Square'

-- 初期化
function Square:initialize(...)
    self.value = ''
    for _, v in ipairs({...}) do
        self.value = self.value .. tostring(v) .. ', '
    end
end

-- 描画
function Square:draw()
    love.graphics.print(self.value)
end

return Square
