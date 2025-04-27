local Layout = Phoenix_UI:NewModule('Config.Layout.Chat')

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db
    
    -- Common change handler for all chat settings
    local function chatSettingChanged(element, value)
        -- Get the database reference
        if element.dataKey and db.profile.chat then
            -- Handle nested fields if needed
            if element.dataKey:find("%.") then
                local parts = {}
                for part in element.dataKey:gmatch("[^%.]+") do
                    table.insert(parts, part)
                end
                
                -- Navigate to the right spot in the table
                local current = db.profile.chat
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
                db.profile.chat[element.dataKey] = value
            end
        end
        
        -- Force database save
        if Phoenix_UI and Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
            
            -- Ensure it's written to disk
            if FlushSavedVariables then
                FlushSavedVariables()
            elseif FlushSettingsDB then
                FlushSettingsDB()
            end
        end
    end

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.chat,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Chat'
                }
            },
            {
                style = {
                    key = 'style',
                    label = 'Style',
                    type = 'dropdown',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'PhoenixFlame', text = 'Phoenix Flame' },
                        { value = 'Custom', text = 'Custom' }
                    },
                    column = 5,
                    order = 1,
                    onChange = chatSettingChanged
                },
                preview = {
                    key = 'preview',
                    type = 'checkbox',
                    label = 'Preview Theme',
                    tooltip = 'Show theme preview in chat frames',
                    column = 5,
                    order = 2,
                    onChange = function(element, value)
                        -- Store the setting
                        chatSettingChanged(element, value)
                        
                        -- Apply preview if enabled
                        if value then
                            -- Send a message to trigger theme refresh
                            Phoenix_UI:SendMessage("PHOENIX_UI_THEME_CHANGED", Phoenix_UI.currentTheme)
                            
                            -- Show preview message in first chat frame
                            local chatFrame = _G["ChatFrame1"]
                            if chatFrame then
                                chatFrame:AddMessage("|cffFF7D0APhoenix UI:|r Chat theme preview activated!")
                                
                                -- Send a sample message with emojis
                                C_Timer.After(0.5, function()
                                    chatFrame:AddMessage("|cffFF7D0APhoenix UI:|r Example message with emojis: Hello there :) :D <3")
                                end)
                            end
                        end
                    end
                }
            },
            {
                chatinput = {
                    key = 'top',
                    type = 'checkbox',
                    label = 'Input on Top',
                    tooltip = 'Move chat input field to top of chat',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                link = {
                    key = 'link',
                    type = 'checkbox',
                    label = 'Link copy',
                    tooltip = 'Make links clickable to copy them',
                    column = 4,
                    order = 2,
                    onChange = chatSettingChanged
                },
                copy = {
                    key = 'copy',
                    type = 'checkbox',
                    label = 'Copy Symbol',
                    tooltip = 'Show/Hide copy chat-history icon',
                    column = 4,
                    order = 3,
                    onChange = chatSettingChanged
                },
            },
            {
                historyEnabled = {
                    key = 'history.enabled',
                    type = 'checkbox',
                    label = 'Save Chat History',
                    tooltip = 'Save chat history between sessions',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                historyCount = {
                    key = 'history.lines',
                    type = 'slider',
                    label = 'History Lines',
                    tooltip = 'Number of chat lines to save in history',
                    min = 100,
                    max = 1000,
                    step = 100,
                    initialValue = 500,
                    column = 8,
                    order = 2,
                    onChange = chatSettingChanged
                }
            },
            {
                advancedSearch = {
                    key = 'history.advancedSearch',
                    type = 'checkbox',
                    label = 'Advanced Search',
                    tooltip = 'Enable enhanced chat history search with improved filtering',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                maxSearchResults = {
                    key = 'history.maxSearchResults',
                    type = 'slider',
                    label = 'Max Search Results',
                    tooltip = 'Maximum number of search results to display',
                    min = 25,
                    max = 200,
                    step = 25,
                    initialValue = 100,
                    column = 8,
                    order = 2,
                    onChange = chatSettingChanged
                }
            },
            {
                expandedChatView = {
                    key = 'expandedView.enabled',
                    type = 'checkbox',
                    label = 'Expanded Chat View',
                    tooltip = 'Enable button to view expanded chat for copying',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                showClassSpecIcons = {
                    key = 'classSpec.enabled',
                    type = 'checkbox',
                    label = 'Class Coloring',
                    tooltip = 'Enable class coloring in chat',
                    column = 4,
                    order = 2,
                    onChange = chatSettingChanged
                },
                showSpecIcons = {
                    key = 'classSpec.showIcons',
                    type = 'checkbox',
                    label = 'Class Spec Icons',
                    tooltip = 'Show class specialization icons in chat',
                    column = 4,
                    order = 3,
                    onChange = chatSettingChanged
                }
            },
            {
                emojiHeader = {
                    type = 'header',
                    label = 'Emoji Settings'
                }
            },
            {
                emojiEnabled = {
                    key = 'emoji.enabled',
                    type = 'checkbox',
                    label = 'Enable Emojis',
                    tooltip = 'Enable emoji support in chat',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                emojiSize = {
                    key = 'emoji.size',
                    type = 'slider',
                    label = 'Emoji Size',
                    tooltip = 'Size of emoji icons in chat',
                    min = 8,
                    max = 32,
                    step = 1,
                    initialValue = 16,
                    column = 8,
                    order = 2,
                    onChange = chatSettingChanged
                }
            },
            {
                emojiCacheSize = {
                    key = 'emoji.cacheSize',
                    type = 'slider',
                    label = 'Emoji Cache Size',
                    tooltip = 'Number of messages to cache for emoji processing (higher = better performance, more memory)',
                    min = 50,
                    max = 500,
                    step = 50,
                    initialValue = 100,
                    column = 8,
                    order = 1,
                    onChange = chatSettingChanged
                },
                clearEmojiCache = {
                    key = 'clearEmojiCache',
                    type = 'button',
                    label = 'Clear Emoji Cache',
                    tooltip = 'Clear emoji message cache to free memory',
                    column = 4,
                    order = 2,
                    onClick = function()
                        -- Clear emoji cache via the module if available
                        local emojiModule = Phoenix_UI:GetModule("Chat.Emoji", true)
                        if emojiModule and emojiModule.ClearCache then
                            emojiModule:ClearCache()
                            Phoenix_UI:Print("Emoji cache cleared")
                        else
                            -- Fallback: clear via global variable if available
                            if Phoenix_UI.ChatEmojiCache then
                                Phoenix_UI.ChatEmojiCache = {}
                                Phoenix_UI:Print("Emoji cache cleared")
                            else
                                Phoenix_UI:Print("Emoji cache not available")
                            end
                        end
                    end
                }
            },
            {
                classIconHeader = {
                    type = 'header',
                    label = 'Class Icon Settings'
                }
            },
            {
                classIconsEnabled = {
                    key = 'classIcons.enabled',
                    type = 'checkbox',
                    label = 'Show Class Icons',
                    tooltip = 'Show class icons next to player names',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                classIconPosition = {
                    key = 'classIcons.position',
                    label = 'Icon Position',
                    type = 'dropdown',
                    options = {
                        { value = 'before', text = 'Before Name' },
                        { value = 'after', text = 'After Name' }
                    },
                    column = 8,
                    order = 2,
                    onChange = chatSettingChanged
                }
            },
            {
                organizationHeader = {
                    type = 'header',
                    label = 'Message Organization'
                }
            },
            {
                organizeEnabled = {
                    key = 'organize.enabled',
                    type = 'checkbox',
                    label = 'Enable Organization',
                    tooltip = 'Enable smart message organization and categorization',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                categoriesEnabled = {
                    key = 'organize.categories',
                    type = 'checkbox',
                    label = 'Message Categories',
                    tooltip = 'Show category tags for different types of messages',
                    column = 4,
                    order = 2,
                    onChange = chatSettingChanged
                },
                preserveTrade = {
                    key = 'organize.preserveTrade',
                    type = 'checkbox',
                    label = 'Preserve Trade Chat',
                    tooltip = 'Keep original formatting for trade chat messages with profession/item links',
                    column = 4,
                    order = 3,
                    onChange = chatSettingChanged
                }
            },
            {
                collapseLoot = {
                    key = 'organize.collapseLoot',
                    type = 'checkbox',
                    label = 'Collapse Loot',
                    tooltip = 'Combine repeated loot messages',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                collapseRepeat = {
                    key = 'organize.collapseRepeat',
                    type = 'checkbox',
                    label = 'Collapse Repeats',
                    tooltip = 'Combine repeated identical messages',
                    column = 4,
                    order = 2,
                    onChange = chatSettingChanged
                }
            },
            {
                historyHeader = {
                    type = 'header',
                    label = 'Advanced History'
                }
            },
            {
                historySearch = {
                    key = 'history.advancedSearch',
                    type = 'checkbox',
                    label = 'Enable Search',
                    tooltip = 'Enable advanced chat history search',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                }
            },
            -- Performance optimization settings
            {
                performanceHeader = {
                    type = 'header',
                    label = 'Performance Optimization'
                }
            },
            {
                performanceEnabled = {
                    key = 'performance.enabled',
                    type = 'checkbox',
                    label = 'Enable Optimizations',
                    tooltip = 'Enable memory and performance optimizations',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                trimOldMessages = {
                    key = 'performance.trimOldMessages',
                    type = 'checkbox',
                    label = 'Trim Old Messages',
                    tooltip = 'Automatically remove old messages from history',
                    column = 4,
                    order = 2,
                    onChange = chatSettingChanged
                },
                compressHistory = {
                    key = 'performance.compressHistory',
                    type = 'checkbox',
                    label = 'Compress History',
                    tooltip = 'Compress chat history to reduce memory usage',
                    column = 4,
                    order = 3,
                    onChange = chatSettingChanged
                }
            },
            {
                daysToKeep = {
                    key = 'performance.maxDaysToKeep',
                    type = 'slider',
                    label = 'Days to Keep History',
                    tooltip = 'Number of days to keep chat history',
                    min = 1,
                    max = 30,
                    step = 1,
                    initialValue = 7,
                    column = 6,
                    order = 1,
                    onChange = chatSettingChanged
                },
                useModernUI = {
                    key = 'performance.useModernUI',
                    type = 'checkbox',
                    label = 'Modern UI Elements',
                    tooltip = 'Use modern UI elements and APIs for better compatibility with recent WoW versions',
                    column = 6,
                    order = 2,
                    onChange = chatSettingChanged
                }
            }
        },
    }
end
