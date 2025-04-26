local Layout = Phoenix_UI:NewModule('Config.Layout.PlayerStats')

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Components
    local Phoenix_UIConfig = LibStub('Phoenix_UIConfig')

    -- Get the Stats module
    local Stats = Phoenix_UI:GetModule("General.Stats", true)

    -- Helper functions
    local function IsModuleLoaded()
        return Stats ~= nil
    end

    local function SaveSettings()
        if Phoenix_UI.SaveDB then
            Phoenix_UI:SaveDB()
        end
    end
    
    -- Initialize settings with defaults if needed
    if not db.profile.general.playerStats then
        db.profile.general.playerStats = {
            showPrimaryStats = true,
            showSecondaryStats = true,
            showCooldowns = true,
            compactMode = false,
            updateFrequency = {
                inCombat = 0.3,
                outOfCombat = 1.0
            }
        }
    end
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.edit and db.profile.edit.playerStatsFrame or {},
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Player Stats Module'
                }
            },
            {
                enabled = {
                    key = 'display.playerStats',
                    type = 'checkbox',
                    label = 'Enable Player Stats Window',
                    tooltip = 'Show the detailed player stats panel with Crit, Haste, Mastery, etc.',
                    get = function()
                        return db.profile.general.display and db.profile.general.display.playerStats ~= false
                    end,
                    set = function(value)
                        if not db.profile.general.display then db.profile.general.display = {} end
                        db.profile.general.display.playerStats = value
                        
                        -- Update the frame visibility if module is loaded
                        if IsModuleLoaded() and _G.Phoenix_PlayerStatsFrame then
                            if value then
                                _G.Phoenix_PlayerStatsFrame:Show()
                            else
                                _G.Phoenix_PlayerStatsFrame:Hide()
                            end
                        end
                        
                        SaveSettings()
                    end,
                    column = 12,
                    order = 1
                }
            },
            {
                showPrimaryStats = {
                    key = 'playerStats.showPrimaryStats',
                    type = 'checkbox',
                    label = 'Show Primary Stats',
                    tooltip = 'Display Strength, Agility, Intellect, Stamina and Armor',
                    get = function()
                        return db.profile.general.playerStats and db.profile.general.playerStats.showPrimaryStats ~= false
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        db.profile.general.playerStats.showPrimaryStats = value
                        SaveSettings()
                        
                        -- Notify the module to refresh if loaded
                        if IsModuleLoaded() and _G.Phoenix_PlayerStatsFrame then
                            Stats:RefreshPlayerStats()
                        end
                    end,
                    column = 4,
                    order = 2
                },
                showSecondaryStats = {
                    key = 'playerStats.showSecondaryStats',
                    type = 'checkbox',
                    label = 'Show Secondary Stats',
                    tooltip = 'Display Crit, Haste, Mastery, Versatility, etc.',
                    get = function()
                        return db.profile.general.playerStats and db.profile.general.playerStats.showSecondaryStats ~= false
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        db.profile.general.playerStats.showSecondaryStats = value
                        SaveSettings()
                        
                        -- Notify the module to refresh if loaded
                        if IsModuleLoaded() and _G.Phoenix_PlayerStatsFrame then
                            Stats:RefreshPlayerStats()
                        end
                    end,
                    column = 4,
                    order = 3
                },
                showCooldowns = {
                    key = 'playerStats.showCooldowns',
                    type = 'checkbox',
                    label = 'Show Cooldown Timers',
                    tooltip = 'Display timers for Bloodlust and Combat Resurrection',
                    get = function()
                        return db.profile.general.playerStats and db.profile.general.playerStats.showCooldowns ~= false
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        db.profile.general.playerStats.showCooldowns = value
                        SaveSettings()
                        
                        -- Notify the module to refresh if loaded
                        if IsModuleLoaded() and _G.Phoenix_PlayerStatsFrame then
                            Stats:RefreshPlayerStats()
                        end
                    end,
                    column = 4,
                    order = 4
                }
            },
            {
                compactMode = {
                    key = 'playerStats.compactMode',
                    type = 'checkbox',
                    label = 'Compact Mode',
                    tooltip = 'Use a more compact display format to save screen space',
                    get = function()
                        return db.profile.general.playerStats and db.profile.general.playerStats.compactMode == true
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        db.profile.general.playerStats.compactMode = value
                        SaveSettings()
                        
                        -- Notify the module to refresh if loaded
                        if IsModuleLoaded() and _G.Phoenix_PlayerStatsFrame then
                            Stats:RefreshPlayerStats()
                        end
                    end,
                    column = 6,
                    order = 5
                },
                changeIndicators = {
                    key = 'playerStats.changeIndicators',
                    type = 'checkbox',
                    label = 'Show Stat Change Indicators',
                    tooltip = 'Display arrows showing when stats increase or decrease',
                    get = function()
                        return db.profile.general.playerStats and db.profile.general.playerStats.changeIndicators ~= false
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        db.profile.general.playerStats.changeIndicators = value
                        SaveSettings()
                    end,
                    column = 6,
                    order = 6
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Frame Settings'
                }
            },
            {
                position = {
                    type = 'text',
                    label = 'Position',
                    text = 'The Player Stats frame can be moved by dragging its title bar. Settings are saved automatically.',
                    column = 12,
                    order = 1
                }
            },
            {
                resetPosition = {
                    type = 'button',
                    label = 'Reset Position',
                    text = 'Reset Frame Position',
                    onClick = function()
                        -- Default position values
                        local defaultPos = {
                            point = "TOPRIGHT",
                            x = -10,
                            y = -150,
                            width = 150,
                            height = 180
                        }
                        
                        -- Update database
                        if db.profile.edit then
                            db.profile.edit.playerStatsFrame = defaultPos
                        end
                        
                        -- Apply to frame
                        if _G.Phoenix_PlayerStatsFrame then
                            local frame = _G.Phoenix_PlayerStatsFrame
                            frame:ClearAllPoints()
                            frame:SetPoint(defaultPos.point, UIParent, defaultPos.point, defaultPos.x, defaultPos.y)
                            frame:SetSize(defaultPos.width, defaultPos.height)
                        end
                        
                        SaveSettings()
                    end,
                    column = 6,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Performance Settings'
                }
            },
            {
                updateFrequency = {
                    type = 'text',
                    label = 'Update Frequency',
                    text = 'Stats update more frequently during combat for accuracy, and less frequently when out of combat to improve performance.',
                    column = 12,
                    order = 1
                }
            },
            {
                combatRate = {
                    key = 'playerStats.updateFrequency.inCombat',
                    type = 'slider',
                    label = 'In Combat Update Rate',
                    tooltip = 'How frequently stats update during combat (in seconds)',
                    min = 0.1,
                    max = 1.0,
                    step = 0.1,
                    get = function()
                        if not db.profile.general.playerStats or not db.profile.general.playerStats.updateFrequency then
                            return 0.3
                        end
                        return db.profile.general.playerStats.updateFrequency.inCombat or 0.3
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        if not db.profile.general.playerStats.updateFrequency then
                            db.profile.general.playerStats.updateFrequency = {}
                        end
                        db.profile.general.playerStats.updateFrequency.inCombat = value
                        SaveSettings()
                    end,
                    column = 6,
                    order = 2
                },
                outOfCombatRate = {
                    key = 'playerStats.updateFrequency.outOfCombat',
                    type = 'slider',
                    label = 'Out of Combat Update Rate',
                    tooltip = 'How frequently stats update out of combat (in seconds)',
                    min = 0.5,
                    max = 3.0,
                    step = 0.5,
                    get = function()
                        if not db.profile.general.playerStats or not db.profile.general.playerStats.updateFrequency then
                            return 1.0
                        end
                        return db.profile.general.playerStats.updateFrequency.outOfCombat or 1.0
                    end,
                    set = function(value)
                        if not db.profile.general.playerStats then db.profile.general.playerStats = {} end
                        if not db.profile.general.playerStats.updateFrequency then
                            db.profile.general.playerStats.updateFrequency = {}
                        end
                        db.profile.general.playerStats.updateFrequency.outOfCombat = value
                        SaveSettings()
                    end,
                    column = 6,
                    order = 3
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Help and Information'
                }
            },
            {
                aboutStats = {
                    type = 'text',
                    label = 'About Player Stats',
                    text = 'The Player Stats module provides a comprehensive window displaying all your character\'s important statistics in real-time. The window updates automatically as your stats change, with enhanced performance optimization and visual indicators for stat changes. Primary stats, secondary stats, and raid cooldown timers can all be configured to your preference.',
                    column = 12,
                    order = 1
                }
            },
            {
                visualEnhancement = {
                    type = "group",
                    name = "Visual Effects",
                    order = 7,
                    args = {
                        enableVisuals = {
                            type = "toggle",
                            name = "Enable Visual Enhancements",
                            desc = "Enable visual effects for the player stats panel",
                            width = "full",
                            get = function()
                                return db.profile.general.playerStats and db.profile.general.playerStats.visualEffects ~= false
                            end,
                            set = function(info, value)
                                if not db.profile.general.playerStats then
                                    db.profile.general.playerStats = {}
                                end
                                db.profile.general.playerStats.visualEffects = value
                                
                                -- Apply the change immediately
                                local visualsModule = Phoenix_UI:GetModule("General.StatsVisuals", true)
                                if visualsModule and value == false then
                                    -- Turn off effects if disabled
                                    local statsFrame = _G.Phoenix_PlayerStatsFrame
                                    if statsFrame and statsFrame.visualElements then
                                        if statsFrame.visualElements.emberAnim then statsFrame.visualElements.emberAnim:Stop() end
                                        if statsFrame.visualElements.flameAnim then statsFrame.visualElements.flameAnim:Stop() end
                                        if statsFrame.animatedBorder and statsFrame.animatedBorder.glowAnim then 
                                            statsFrame.animatedBorder.glowAnim:Stop() 
                                        end
                                        if statsFrame.titleEnhancement and statsFrame.titleEnhancement.anim then 
                                            statsFrame.titleEnhancement.anim:Stop() 
                                        end
                                        if statsFrame.particleSystem then
                                            visualsModule:SetParticleEffectLevel(0)
                                        end
                                    end
                                elseif visualsModule and value == true then
                                    -- Re-enable effects
                                    local statsFrame = _G.Phoenix_PlayerStatsFrame
                                    if statsFrame and statsFrame.visualElements then
                                        if statsFrame.visualElements.emberAnim then statsFrame.visualElements.emberAnim:Play() end
                                        if statsFrame.visualElements.flameAnim then statsFrame.visualElements.flameAnim:Play() end
                                        if statsFrame.animatedBorder and statsFrame.animatedBorder.glowAnim then 
                                            statsFrame.animatedBorder.glowAnim:Play() 
                                        end
                                        if statsFrame.titleEnhancement and statsFrame.titleEnhancement.anim then 
                                            statsFrame.titleEnhancement.anim:Play() 
                                        end
                                        if statsFrame.particleSystem then
                                            visualsModule:SetParticleEffectLevel(2)
                                        end
                                    end
                                end
                            end,
                            order = 1
                        },
                        effectLevel = {
                            type = "select",
                            name = "Effect Level",
                            desc = "Choose the level of visual effects (higher levels may affect performance)",
                            values = {
                                [1] = "Low",
                                [2] = "Medium",
                                [3] = "High"
                            },
                            get = function()
                                return db.profile.general.playerStats and db.profile.general.playerStats.effectLevel or 2
                            end,
                            set = function(info, value)
                                if not db.profile.general.playerStats then
                                    db.profile.general.playerStats = {}
                                end
                                db.profile.general.playerStats.effectLevel = value
                                
                                -- Apply particle effect level immediately
                                local visualsModule = Phoenix_UI:GetModule("General.StatsVisuals", true)
                                if visualsModule then
                                    visualsModule:SetParticleEffectLevel(value)
                                end
                            end,
                            disabled = function()
                                return not (db.profile.general.playerStats and db.profile.general.playerStats.visualEffects ~= false)
                            end,
                            width = "full",
                            order = 2
                        }
                    }
                }
            }
        }
    }
end

function Layout:Refresh()
    if not self.layout or not self.layout.rows then return end
    
    -- Get the config tabs
    local config = Phoenix_UI.UI
    if not config or not config.elements then return end
    
    -- Force a full rebuild if needed
    if config.RefreshConfig then
        config:RefreshConfig()
    end
    
    -- Force all settings to be saved
    if Phoenix_UI.ForceSaveDB then
        Phoenix_UI:ForceSaveDB()
    end
end 