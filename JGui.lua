local Component = require('Component')
local JGui = {}

---Retrieves a component by name
---@param name string The name of the component
---@return component component The component.
function JGui.getComponent(name)
    return Component.getCopy(name)
end

---Renders the component with the specified name
---@param name string The name of the component to render.
---@param root gui? The gui object to attach the component to, will be root if nil.
---@param data table?
function JGui.renderComponent(name, root, data)
    local component = JGui.getComponent(name)
    if data then
        for key, value in pairs(data) do
            component.data[key] = value
        end
    end
    local attachedTo = root or GUI.getRoot()
    component:render(attachedTo)
end

---Loads a set of components from the specified draft.
---@param draft draft The draft to load components from.
function JGui.LoadDraft(draft)
    local meta = draft:getMeta()
    JGui.LoadTable(meta.components)
end

---Load components from a specified table.
---@param table table A table containing the components indexed by name.
function JGui.LoadTable(table)
    for name, component in pairs(table) do
        JGui.loadComponent(name, component)
    end
end

---Loads a single component.
---@param name string The name of the component.
---@param component table The component to load.
function JGui.loadComponent(name, component)
    Component.new(name, component)
end

return JGui