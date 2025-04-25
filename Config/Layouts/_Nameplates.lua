local Layout = Phoenix_UI:NewModule('Config.Layout.Nameplates')

-- Create a common change handler for nameplate settings to ensure they save properly
local function nameplateSettingChanged(element, value)
    -- Get the database
    local db = Phoenix_UI.db
    
    -- Store the value in the database
    if element.dataKey and db.profile.nameplates then
        -- Get the field name without the nameplates. prefix
        local fieldName = element.dataKey:gsub("^nameplates%.", "")
        
        -- Handle nested fields if needed
        if fieldName:find("%.") then
            local parts = {}
            for part in fieldName:gmatch("[^%.]+") do
                table.insert(parts, part)
            end
            
            -- Navigate to the right spot in the table
            local current = db.profile.nameplates
            for i = 1, #parts-1 do
                if not current[parts[i]] then
                    current[parts[i]] = {}
                end
                current = current[parts[i]]
            end
            
            -- Set the value
            current[parts[#parts]] = value
        else
            -- Direct setting
            db.profile.nameplates[fieldName] = value
        end
        
        -- Debug output
        if Phoenix_UI.debug then
            print("PHX-UI: Nameplate setting changed:", element.dataKey, "=", tostring(value))
        end
        
        -- Force an immediate save
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
            
            -- Ensure it's written to disk
            if FlushSavedVariables then
                FlushSavedVariables()
            elseif FlushSettingsDB then
                FlushSettingsDB()
            end
        end
        
        -- Also directly update global savedvariables
        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
            local currentProfile = db.keys and db.keys.profile or "Default"
            if not _G["Phoenix_UIDB"].profiles[currentProfile] then
                _G["Phoenix_UIDB"].profiles[currentProfile] = {}
            end
            if not _G["Phoenix_UIDB"].profiles[currentProfile].nameplates then
                _G["Phoenix_UIDB"].profiles[currentProfile].nameplates = {}
            end
            
            -- Deep copy to ensure all changes are preserved
            _G["Phoenix_UIDB"].profiles[currentProfile].nameplates = CopyTable(db.profile.nameplates)
            _G["Phoenix_UIDB"].profiles[currentProfile].nameplates.__updated = GetTime()
        end
        
        -- Also trigger UI refresh
        if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
            C_Timer.After(0.1, function()
                Phoenix_UI.UI:RefreshConfig()
            end)
        end
    end
end

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Components
    local NPCColors = Phoenix_UI:GetModule("Config.Components.NPCColors")

    -- Data
    local Textures = Phoenix_UI:GetModule("Data.Textures")

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.nameplates,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Nameplates'
                }
            },
            {
                style = {
                    key = 'style',
                    label = 'Style',
                    type = 'dropdown',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'Custom',  text = 'Custom' }
                    },
                    initialValue = 1,
                    column = 5,
                    order = 1
                },
                texture = {
                    key = 'texture',
                    type = 'dropdown',
                    label = 'Texture',
                    options = Textures.data,
                    column = 5,
                    order = 2
                }
            },
            {
                decimals = {
                    key = 'decimals',
                    label = 'Health Text Decimals',
                    type = 'dropdown',
                    options = {
                        { value = '0', text = '0 (e.g. 99%)' },
                        { value = '1', text = '1 (e.g. 99.9%)' },
                        { value = '2', text = '2 (e.g. 99.99%)' }
                    },
                    initialValue = 1,
                    column = 4,
                    order = 1
                },
                height = {
                    key = 'height',
                    type = 'slider',
                    label = 'Height',
                    precision = 1,
                    min = 1,
                    max = 5,
                    initialValue = 2,
                    column = 3,
                    order = 2
                },
                width = {
                    key = 'width',
                    type = 'slider',
                    label = 'Width',
                    precision = 1,
                    min = 1,
                    max = 5,
                    initialValue = 3,
                    column = 3,
                    order = 3
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Options'
                }
            },
            {
                healthtext = {
                    key = 'healthtext',
                    type = 'checkbox',
                    label = 'Health Text',
                    tooltip = 'Shows the health percentage in the nameplate',
                    column = 4,
                    order = 1
                },
                color = {
                    key = 'color',
                    type = 'checkbox',
                    label = 'Classcolor Playernames',
                    tooltip = 'Show Playernames in their class color',
                    column = 4,
                    order = 2
                },
                server = {
                    key = 'server',
                    type = 'checkbox',
                    label = 'Hide Servername',
                    tooltip = 'Hide servernames entirely on nameplates',
                    column = 4,
                    order = 3
                },
            },
            {
                arenanumber = {
                    key = 'arenanumber',
                    type = 'checkbox',
                    label = 'Arena Nameplate',
                    tooltip = 'Shows Arena number over Nameplate',
                    column = 4,
                    order = 1
                },
                totemicons = {
                    key = 'totemicons',
                    type = 'checkbox',
                    label = 'Totem Icons',
                    tooltip = 'Shows Totem icons on Nameplate',
                    column = 4,
                    order = 2
                },
                casttime = {
                    key = 'casttime',
                    type = 'checkbox',
                    label = 'Cast Time',
                    tooltip = 'Show cast time below the cast icon',
                    column = 4,
                    order = 3
                },
            },
            {
                focusHighlight = {
                    key = 'focusHighlight',
                    type = 'checkbox',
                    label = 'Focus Highlight',
                    tooltip = 'Highlight Focus Target (different Texture)',
                    column = 4,
                    order = 1
                },
                debuffs = {
                    key = 'debuffs',
                    type = 'checkbox',
                    label = 'Hide Debuffs',
                    tooltip = 'Hides your own debuffs above of the nameplates',
                    column = 4,
                    order = 2
                },
                stackingmode = {
                    key = 'stackingmode',
                    type = 'checkbox',
                    label = 'Smart Stacking Mode',
                    tooltip = 'Enabled = Smart Stacking Mode / Disabled = Overlapping Nameplates',
                    column = 4,
                    order = 3
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Mythic+ Options'
                }
            },
            {
                colors = {
                    key = 'colors',
                    type = 'checkbox',
                    label = 'NPC Colors',
                    tooltip = 'Enable/Disable NPC Colors for important NPCs',
                    column = 4,
                    order = 1
                },
                npccolors = {
                    type = 'button',
                    text = 'Change NPC Colors',
                    onClick = function()
                        -- Use the global function which has better error handling
                        Phoenix_UI_ShowNPCColors()
                    end,
                    column = 4,
                    order = 2
                }
            },
        },
    }
end



