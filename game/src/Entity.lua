
local class = require 'middleclass'
local lume = require 'lume'

-- エンティティクラス
local Entity = class 'Entity'

-- 初期化
function Entity:initialize(t)
    lume.extend(self, type(t) == 'table' and t or {})

    self.updateComponents = self.updateComponents or {}
    self.drawComponents = self.drawComponents or {}
end

-- 更新
function Entity:update(dt)
    for i, t in ipairs(self.updateComponents) do
        for j, component in ipairs(t) do
            component:update(dt)
        end
    end
end

-- 描画
function Entity:draw()
    for i, t in ipairs(self.drawComponents) do
        for j, component in ipairs(t) do
            component:draw()
        end
    end
end

-- 更新できるかどうか
function Entity:updatable()
    return #self.updateComponents > 0
end

-- 描画できるかどうか
function Entity:drawable()
    return #self.drawComponents > 0
end

-- 指定のテーブルに優先度別にコンポーネントを追加する
local function addComponentForTable(t, component, priority)
    if t[priority] then
        table.insert(t[priority], component)
    else
        for i = #t + 1, priority do
            t[i] = {}
            if i == priority then
                table.insert(t[priority], component)
            end
        end
    end
end

-- コンポーネントの追加
function Entity:addComponent(component)
    if component.updatable then
        addComponentForTable(self.updateComponents, component, component.updatePriority)
    end
    if component.drawable then
        addComponentForTable(self.drawComponents, component, component.drawPriority)
    end
end

return Entity
