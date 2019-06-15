
local class = require 'middleclass'
local lume = require 'lume'

-- エンティティクラス
local Entity = class 'Entity'

-- 初期化
function Entity:initialize(t)
    lume.extend(self, type(t) == 'table' and t or {})

    -- 初期プロパティ
    self.x = self.x or 0
    self.y = self.y or 0
    self.angle = self.angle or 0
    self.remove = false

    -- 各種テーブル
    self.updateComponents = self.updateComponents or {}
    self.drawComponents = self.drawComponents or {}
    self.nameTable = {}
    self.removes = {}

    -- コンポーネントが指定されていたら、各テーブルに登録
    if self.components then
        local t = self.components
        self.components = {}
        for i, component in ipairs(t) do
            self:addComponent(component)
        end
    else
        self.components = {}
    end
end

-- 破棄
function Entity:destroy()
    self.field:removeEntity(self)
end

-- 更新
function Entity:update(dt)
    for i, t in ipairs(self.updateComponents) do
        for j, component in ipairs(t) do
            component:update(dt)

            -- 削除フラグが立っていればリストに登録
            if component.remove then
                table.insert(self.removes, component)
            end
        end
    end

    -- 削除
    if self.removes[1] then
        for _, component in ipairs(self.removes) do
            self:removeComponent(component)
        end
        self.removes = {}
        if #self.components == 0 then
            self.remove = true
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

-- 指定のテーブルの優先度別テーブルにコンポーネントを追加する
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
    -- ネームテーブル
    if self.nameTable[component.class.name] == nil then
        self.nameTable[component.class.name] = {}
    end
    table.insert(self.nameTable[component.class.name], component)

    -- 更新テーブル
    if component.updatable then
        addComponentForTable(self.updateComponents, component, component.updatePriority)
    end

    -- 描画テーブル
    if component.drawable then
        addComponentForTable(self.drawComponents, component, component.drawPriority)
    end

    -- 所有しているエンティティを登録
    component.entity = self

    -- コンポーネント一覧に追加
    table.insert(self.components, component)

    return component
end

-- 指定のテーブルの優先度別テーブルからコンポーネントを削除する
local function removeComponentFromTable(t, component, priority)
    if t[priority] == nil then
        -- 未登録なので何もしない
    else
        lume.remove(t[priority], component)
    end
end

-- コンポーネントの削除
function Entity:removeComponent(component)
    -- ネームテーブル
    local components = self:getComponents(component.class.name)
    if components then
        lume.remove(components, component)
    end

    -- 更新テーブル
    if component.updatable then
        removeComponentFromTable(self.updateComponents, component, component.updatePriority)
    end

    -- 描画テーブル
    if component.drawable then
        removeComponentFromTable(self.drawComponents, component, component.drawPriority)
    end

    -- 所有エンティティを削除
    component.entity = nil

    -- コンポーネント一覧から削除
    lume.remove(self.components, component)
end

-- 同じ名前のコンポーネント一覧の取得
function Entity:getComponents(name)
    return self.nameTable[name]
end

-- コンポーネントの取得
function Entity:getComponent(name)
    local components = self:getComponents(name)
    return components and components[1] or nil
end

-- 指定の名前のコンポーネントがあるかどうか返す
function Entity:hasComponent(name)
    return self.nameTable[name] and self.nameTable[name][1] ~= nil
end

-- 矩形
function Entity:rect()
    return self.x, self.y, self.x, self.y
end

-- 移動
function Entity:move(magnitude)
    local x, y = lume.vector(self.angle, magnitude)
    self.x = math.max(0, math.min(self.x + x, self.field.width))
    self.y = math.max(0, math.min(self.y + y, self.field.height))
end

return Entity
