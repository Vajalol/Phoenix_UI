local Layout = Phoenix_UI:NewModule('Config.Layout.IdTip')

function Layout:OnEnable()
    if not _G.idTipConfig then return end
    if not _G.kinds then return end

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = _G.idTipConfig,
        rows = {
            {
                header = {
                    type = 'header',
                    label = '|cff669900id|r|cffffffffTip|r Configuration'
                }
            },
            {
                enabled = {
                    key = 'enabled',
                    type = 'checkbox',
                    label = 'Enable idTip',
                    tooltip = 'Enable or disable the idTip addon',
                    column = 12,
                    order = 1
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'ID Types to Display'
                }
            }
        }
    }
    
    -- Get all available ID types from idTip
    local row = {}
    local index = 1
    local keys = {}
    
    -- Get all key-value pairs from kinds table in idTip
    for key, label in pairs(_G.kinds or {}) do 
        -- Validate key is a string to prevent errors
        if type(key) == "string" then
            table.insert(keys, {key = key, label = label})
        end
    end
    
    -- Sort keys alphabetically by label
    table.sort(keys, function(a, b) return a.label < b.label end)
    
    -- Create checkboxes for each ID type
    for i, info in ipairs(keys) do
        local configKey = info.key .. "Enabled"  -- This matches the format in idTip.lua
        
        -- Ensure we're not using any problematic key names
        if configKey ~= "setEnabled" then 
            row[info.key] = {
                key = configKey,
                type = 'checkbox',
                label = info.label,
                tooltip = 'Show ' .. info.label .. ' IDs in tooltips',
                column = 4,
                order = index
            }
            
            -- Add to layout after every 3 items or at the end
            if i % 3 == 0 or i == #keys then
                table.insert(Layout.layout.rows, row)
                row = {}
                index = 1
            else
                index = index + 1
            end
        end
    end
end 



