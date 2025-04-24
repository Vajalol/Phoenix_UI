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
                historyLines = {
                    key = 'history.lines',
                    type = 'slider',
                    label = 'History Lines',
                    tooltip = 'Number of chat lines to save',
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
                quickjoin = {
                    key = 'quickjoin',
                    type = 'checkbox',
                    label = 'Friendlist Button',
                    tooltip = 'Show/Hide friendlist button',
                    onChange = chatSettingChanged
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Friendlist'
                }
            },
            {
                friendlist = {
                    key = 'friendlist',
                    type = 'checkbox',
                    label = 'Class-Friendlist',
                    tooltip = 'Show character names in class color in friendlist',
                    column = 4,
                    order = 1,
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
                    min = 12,
                    max = 24,
                    step = 1,
                    initialValue = 16,
                    column = 8,
                    order = 2,
                    onChange = chatSettingChanged
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
            -- Social integration settings
            {
                socialHeader = {
                    type = 'header',
                    label = 'Social Integration'
                }
            },
            {
                socialEnabled = {
                    key = 'social.enabled',
                    type = 'checkbox',
                    label = 'Enable Social Features',
                    tooltip = 'Enable enhanced social integration',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                enhancedStatuses = {
                    key = 'social.enhancedStatuses',
                    type = 'checkbox',
                    label = 'Enhanced Status',
                    tooltip = 'Show enhanced online status for friends and guild members',
                    column = 4,
                    order = 2,
                    onChange = chatSettingChanged
                },
                guildRanks = {
                    key = 'social.guildRanks',
                    type = 'checkbox',
                    label = 'Show Guild Ranks',
                    tooltip = 'Display guild ranks next to guild member names',
                    column = 4,
                    order = 3,
                    onChange = chatSettingChanged
                }
            },
            {
                friendNotes = {
                    key = 'social.friendNotes',
                    type = 'checkbox',
                    label = 'Friend Notes',
                    tooltip = 'Show friend notes in chat messages',
                    column = 4,
                    order = 1,
                    onChange = chatSettingChanged
                },
                inlineTooltips = {
                    key = 'social.inlineTooltips',
                    type = 'checkbox',
                    label = 'Inline Tooltips',
                    tooltip = 'Show detailed tooltips when clicking player names',
                    column = 4,
                    order = 2,
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
                virtualScrolling = {
                    key = 'performance.virtualScrolling',
                    type = 'checkbox',
                    label = 'Virtual Scrolling',
                    tooltip = 'Optimize chat display when scrolling through history',
                    column = 3,
                    order = 2,
                    onChange = chatSettingChanged
                },
                throttleUpdates = {
                    key = 'performance.throttleUpdates',
                    type = 'checkbox',
                    label = 'Throttle Updates',
                    tooltip = 'Limit chat frame updates during high activity',
                    column = 3,
                    order = 3,
                    onChange = chatSettingChanged
                }
            }
        },
    }
end



