-- Example of using disabled elements in Phoenix_UIConfig
-- This showcases how to create and manage disabled UI elements
local Phoenix_UIConfig = LibStub('Phoenix_UIConfig');
local database = {}; -- Your database table

local function CreateExample()
    local frame = CreateFrame("Frame", "DisabledElementsExample", UIParent);
    frame:SetSize(400, 500);
    frame:SetPoint("CENTER");
    Phoenix_UIConfig:MakeDraggable(frame);
    
    -- Example config that shows disabled elements
    local config = {
        database = database,
        rows = {
            [1] = {
                { type = "header", label = "Disabled Elements Example" },
            },
            [2] = {
                { type = "checkbox", label = "Enable Elements Below", key = "masterEnable", initialValue = false },
            },
            [3] = {
                { 
                    type = "editBox", 
                    label = "Disabled Text Input", 
                    key = "textInput",
                    disabled = true -- Initial disabled state 
                },
            },
            [4] = {
                { 
                    type = "dropdown", 
                    label = "Disabled Dropdown", 
                    key = "dropdownValue",
                    options = {
                        { text = "Option 1", value = 1 },
                        { text = "Option 2", value = 2 },
                        { text = "Option 3", value = 3 },
                    },
                    disabled = true
                },
            },
            [5] = {
                { 
                    type = "slider", 
                    label = "Disabled Slider", 
                    key = "sliderValue",
                    min = 0,
                    max = 100,
                    disabled = true
                },
            },
            [6] = {
                { 
                    type = "button", 
                    text = "Disabled Button",
                    disabled = true,
                    onClick = function() print("This button was clicked!") end
                },
            },
            [7] = {
                { type = "header", label = "Dynamic Enablement" },
            },
            [8] = {
                { 
                    type = "editBox", 
                    label = "Dynamically Controlled Input", 
                    key = "dynamicTextInput",
                    init = function(element)
                        -- Store reference for later use
                        frame.dynamicTextInput = element;
                        
                        -- NOTE: The Phoenix_UIConfig reference is automatically assigned
                        -- during element creation. This is important for visual effects
                        -- such as highlighting and disabling to work properly.
                    end
                },
            },
            [9] = {
                { type = "header", label = "Container Elements" },
            },
            [10] = {
                { 
                    type = "checkbox", 
                    label = "Enable Container Elements", 
                    key = "enableContainer", 
                    initialValue = false,
                    init = function(element)
                        -- Store reference for later use
                        frame.containerToggle = element;
                    end
                },
            },
            [11] = {
                {
                    type = "group",
                    key = "settingsGroup",
                    inline = true,
                    args = {
                        [1] = {
                            { type = "editBox", label = "Setting 1", key = "setting1" },
                            { type = "editBox", label = "Setting 2", key = "setting2" },
                        },
                        [2] = {
                            { type = "checkbox", label = "Enable Feature", key = "enableFeature" },
                            { type = "dropdown", label = "Feature Type", key = "featureType", options = {
                                { text = "Type A", value = "a" },
                                { text = "Type B", value = "b" },
                                { text = "Type C", value = "c" },
                            }},
                        },
                    },
                    init = function(element)
                        -- Store reference to the container
                        frame.settingsGroup = element;
                    end,
                },
            },
        },
    };
    
    Phoenix_UIConfig:BuildWindow(frame, config);
    
    -- Setup the master checkbox to control individual elements
    local masterCheckbox = frame.elements["masterEnable"];
    if masterCheckbox then
        -- IMPORTANT: When elements call OnValueChanged, they must have access
        -- to the Phoenix_UIConfig reference to properly apply visual effects
        masterCheckbox.onChange = function(self, value)
            -- Enable/disable elements based on the checkbox
            Phoenix_UIConfig:SetElementDisabled(frame.elements["textInput"], not value);
            Phoenix_UIConfig:SetElementDisabled(frame.elements["dropdownValue"], not value);
            Phoenix_UIConfig:SetElementDisabled(frame.elements["sliderValue"], not value);
            
            -- Use the conditional helper for the dynamic text input
            Phoenix_UIConfig:SetElementDisabledIf(frame.dynamicTextInput, function() 
                return not value; -- Disabled when master checkbox is unchecked
            end);
        end
    end
    
    -- Setup checkbox to control all elements in the container
    if frame.containerToggle then
        frame.containerToggle.onChange = function(self, value)
            -- Enable/disable all elements in the settings group
            Phoenix_UIConfig:SetContainerElementsDisabled(frame.settingsGroup, not value, true);
        end
    end
    
    -- Initially disable the container elements
    Phoenix_UIConfig:SetContainerElementsDisabled(frame.settingsGroup, true, true);
    
    return frame;
end

-- Call this function to create and show the example
-- To test this example, run:
-- local frame = CreateExample();
-- frame:Show(); 