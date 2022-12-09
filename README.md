JGui offers a way to create gui templates using a draft's metatable or other tables. This simplifies the amount of code required for making repetetive gui and offers a flexible way of putting data in a template.

This article assumes you have basic knowledge of scripting and that you have good knowledge on creating and manipulating gui objects.

## Components
JGui uses objects called components to handle the information about a gui template, below is a basic json definition of a component.
```jsonc
// This is the identifying name of the component.
"coolComponent": {
    // This is the gui object type of the component, top level objects can be layout, dialog or menu.
    "type": "layout",
    // The args table contains the arguments that will be used to create the gui object, in this case the arguments are for the layout.
    "args": {
        "width": 50
    },
    // The content array contains more component tables that will automaticaly be placed inside the component. Defining these components works the same as the outer component, except they do not require a name. These components can be nested indefinitely.
    "content": [
        {
            "type": "label",
            "args": {
                "text": "line 2",
                "height": 15
            }
        },
        // some more components..
    ]
}
```
This table can then be loaded using JGui.loadComponent(). The JGui module also provides other functions for loading components like loadTable() which loads an array of components and loadDraft which will read components out of a draft's components field in the meta table.

## Data in components
Simple templates are fine, but we're gonna want to be able to insert our data into the component templates. We can do this by defining a field in the args table with a value of "{identifier}". We can later replace this value by putting a key called "identifier" in the component's "data" table.
```jsonc
"someComponent": {
    "type": "label",
    "args": {
        "height": "{labelHeight}",
        "text": "templates are {inlineText} cool"
    },
    // Lets define some data for our template, we can also do this during runtime, which is how it is intended to be used.
    "data": {
        "labelHeight": 15,
        "inlineText": "very"
    }
}
```
Data values inherit through diffrent components, the uppermost component's data will overwrite overlapping keys in child components.

## Chaining components
Now we get into the fun stuff, a component can define another component in its content.
```jsonc
[
    // some extra tables like args have been omitted for simplicity
    "coolMenu": {
        "type": "layout",
        "data": {
            // CoolMenu doesnt use this data tag, but coolButton will inherit and use it.
            "buttonContent": "woah thats a cool button"
        },
        "content": [
            {
                // let's use the cool button component we defined below. Load order does not matter as the components are resolved on render.
                // These component definitons cannot use args or data, but they will inherit data defined in the coolMenu component.
                "type": "coolButton",
            }
        ]
    },
    "coolButton": {
        "type": "button",
        "args": {
            // The value for this will be defined by coolMenu
            "text": "{buttonContent}"
        }
    }
]

```

## Rendering
In order to render a component you loaded you can us JGui.getComponent to get a copy of your component template which you can then fill with data. In order to render the component object you can call component:render() on it and pass it the root gui object which you would like to attach it to. You can also use the JGui.renderComponent shorthand which will get the component for you, insert the data you passed and attach it to the passed gui root or GUI.root if you omitted the argument.

## Full example
Below is a full example json and script that makes use of the features the JGui module offers, it omits some menial args like width and height for the components.
#### json
```jsonc
[{
    "id": "JGui-example",
    "type": "script",
    "script": "script.lua",
    "meta": {
        "components": {
            "coolListEntry": {
                "type": "layout",
                "content": [
                    {
                        "type": "button",
                        "args": {
                            "onClick": "{onClick}"
                        }
                    }
                ]
            }
        }
    }
}]
```
#### lua
```lua
-- use whatever path is needed here
local JGui = require("TT-Jgui.JGui")

function script:init()
    -- lets load the components we defined
    local draft = script:getDraft()
    JGui.LoadDraft(draft)
end

function script:buildCityGui()
    -- let's get the component we loaded and put some data into it.
    local myComponent = JGui.getComponent('coolListEntry')
    myComponent.data = {
        onClick = function ()
            Debug.toast('woah the button has been clicked')
        end
    }

    -- lets create a dialog to attach our component to
    local ourDialog = GUI.createDialog{
        icon = Icon.SETTINGS,
        title = 'Title',
        text = 'Text'
    }

    -- lets render myComponent in the dialog's content
    myComponent:render(ourDialog.content)

    -- we can also use the shorthand method if we want to do it all in 1 go
    local data = {
        onClick = function ()
            Debug.toast('woah the button has been clicked')
        end
    }
    JGui.renderComponent('coolListEntry', ourDialog.content, data)
end
```