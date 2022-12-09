---@class component
---@field type string The gui type of the component.
---@field args table The argument table used to create the gui object.
---@field data table Data fields that are substituted in the component when rendering.
---@field content array<component>
local Component = {}
Component.all = {}

local types = {
    ICON = "icon",
    LISTBOX = "listBox",
    BUTTON = "button",
    TEXTFRAME = "textFrame",
    LABEL = "label",
    CANVAS = "canvas",
    LAYOUT = "layout",
    MENU = "menu",
    DIALOG = "dialog"
}
---Returns whether a gui object type is a component type of a simple gui object type.
---@param type string The string type of the object.
---@return boolean
local function isSimpleType(type)
    for _, compareType in pairs(types) do
        if type == compareType then
            return true
        end
    end
    return false
end

---Creates a deep copy of a table
---@param table table The table to copy.
---@param depth number? The amount of recursions that have occured in the copying process.
---@return table copy A copy of the table.
local function deepCopy(table, depth)
    depth = depth or 0
    depth = depth + 1
    if depth > 50 then
        error("Attempted to deep copy circular table references")
    end
    local copy = {}
    for key, value in pairs(table) do
        if type(value) == "table" then
            copy[key] = deepCopy(value, depth)
        else
            copy[key] = value
        end
    end
    return copy
end

function Component.getCopy(name)
    return deepCopy(Component.all[name])
end

Component.meta = {__index = Component}
---Creates a new component
---@param name string The name of the component.
---@param component table The table representing the component.
---@return component component The created component.
function Component.new(name, component)
    component.data = component.data or {}
    setmetatable(component, Component.meta)
    Component.all[name] = component
    return component
end

---Creates a component and adds it to the root.
---@param component component The component to create.
---@param root gui The gui object to attach the component to.
---@return gui guiComponent The created component
local function createComponent(component, root)
    local type = component.type
    local args = component.args
    if type == types.ICON then
        return root:addIcon(args)

    elseif type == types.LISTBOX then
        return root:addListBox(args)

    elseif type == types.BUTTON then
        return root:addButton(args)

    elseif type == types.TEXTFRAME then
        return root:addTextFrame(args)

    elseif type == types.LABEL then
        return root:addLabel(args)

    elseif type == types.CANVAS then
        return root:addCanvas(args)

    elseif type == types.LAYOUT then
        return root:addLayout(args)

    elseif type == types.MENU then
        return GUI.createMenu(args)

    elseif type == types.DIALOG then
        return GUI.createDialog(args)

    else
        return root:addLabel{
            text="Element does not have a known type"
        }
    end
end

---Gets whether the component will be created on the root.
---@param component component
---@return boolean
local function isTopLevel(component)
    local type = component.type
    return type == types.MENU or type == types.DIALOG
end

---Inserts data into the component template
---@param component component The component to insert data into.
---@param upperData table? Data from an upper component that will also be inserted.
local function insertData(component, upperData)
    if component.args == nil and component.content == nil then return end
    local data = {}
    if component.data then
        for key, value in pairs(component.data) do
            data["{" + key + "}"] = value
        end
    end

    if upperData ~= nil then
        for key, value in pairs(upperData) do
            data[key] = value
        end
    end

    for dataKey, dataValue in pairs(data) do
        for argKey, argValue in pairs(component.args) do
            -- substitute the entire value if they key matches
            if argValue == dataKey then
                component.args[argKey] = dataValue

            -- substitute the key in the string
            elseif type(dataValue == "string") and type(argValue) == "string" then
                component.args[argKey] = string.gsub(argValue, dataKey, dataValue)
            end
        end
    end

    if component.content then
        for _, content in pairs(component.content) do
            insertData(content, data)
        end
    end
end

---Retrieves all child components of the component
---@param component component
local function resolveComponents(component)
    for _, child in pairs(component.content) do
        if not isSimpleType(child.type) then
            child = Component.getCopy(child.type)
        end
    end
end

---Inserts data and attaches the component to the specified root.
---@param root gui The root gui object to attach the component to.
---@return gui component The created gui object.
function Component:render(root)
    -- we will use a copy so that we do not manipulate the template
    local component = deepCopy(self)
    resolveComponents(component)
    insertData(component)

    local guiObj = createComponent(component, root)
    for _, child in pairs(component.content) do
        if isTopLevel(component) then
            child:render(guiObj.content)
        else
            child:render(guiObj)
        end
    end

    return guiObj
end

return Component