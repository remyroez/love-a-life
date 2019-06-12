
local class = require 'middleclass'
local lume = require 'lume'

-- コンポーネントクラス
local Component = class 'Component'

-- 初期化
function Component:initialize(t)
    lume.extend(self, type(t) == 'table' and t or {})

    -- 更新／描画するか
    self.updatable = self.updatable == nil and true or self.updatable
    self.drawable = self.drawable == nil and true or self.drawable

    -- 優先度
    self.updatePriority = self.updatePriority or 1
    self.drawPriority = self.drawPriority or 1

    -- 破棄フラグ
    self.remove = false
end

-- 破棄
function Component:destroy()
    self.entity:removeComponent(self)
end

-- 更新
function Component:update(dt)
end

-- 描画
function Component:draw()
end

return Component
