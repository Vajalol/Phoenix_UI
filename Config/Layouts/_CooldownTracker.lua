local addonName, Phoenix = ...

-- Create the module
local module = Phoenix_UI:NewModule('Config.Layout.CooldownTracker')

-- Helper function to get cooldown tracker
local function GetCooldownTracker()
    -- First try the normal module API
    if Phoenix_UI and Phoenix_UI.GetModule then
        local module = Phoenix_UI:GetModule('CooldownTracker', true)
        if module then return module end
    end
    
    -- Next try direct access to the modules table
    if Phoenix_UI and Phoenix_UI.modules and Phoenix_UI.modules['CooldownTracker'] then
        return Phoenix_UI.modules['CooldownTracker']
    end
    
    -- Try the global namespace
    if _G['Phoenix_UI_CooldownTracker'] then
        return _G['Phoenix_UI_CooldownTracker']
    end
    
    return nil
end

-- Helper function to check if the module is loaded
local function IsCooldownTrackerLoaded()
    local cooldownTracker = GetCooldownTracker()
    
    -- First check if we have the module
    if cooldownTracker then
        return true
    end
    
    -- Check if we have the module's functions in the addon namespace
    if Phoenix_UI and Phoenix_UI.CooldownTracker then
        return true
    end
    
    -- Check for existence of key functions
    if Phoenix_UI and Phoenix_UI.UpdateCooldowns then
        return true
    end
    
    return false
end

-- Helper function to get database
local function GetDB()
    -- Get the main addon database
    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile then
        -- Ensure cooldownTracker table exists
        if not Phoenix_UI.db.profile.cooldownTracker then
            Phoenix_UI.db.profile.cooldownTracker = {
                general = {
                    enabled = true,
                    performanceMode = false,
                    showModuleButtons = true,
                    minimapButton = true,
                },
                cooldownText = {
                    enabled = true,
                    textSize = 14,
                    textFont = "Expressway",
                    swipe = true,
                    expiringColor = {1, 0, 0, 1},
                    expiringDuration = 3,
                    finishEffects = { enableFlash = true },
                    textPosition = "CENTER"
                },
                spellTracker = {
                    enabled = true
                },
                partyCD = {
                    enabled = true
                },
                -- Raid timeline
                timeline = {
                    enabled = true,
                    width = 300,
                    height = 150,
                    minDisplayTime = 60,
                    showLegend = true,
                    trackPlayerOnly = false,
                    position = {
                        point = "CENTER",
                        relativePoint = "CENTER",
                        xOffset = 0,
                        yOffset = -200,
                    }
                }
            }
        end
        
        -- Ensure timeline settings exist and have valid values
        if not Phoenix_UI.db.profile.cooldownTracker.timeline then
            Phoenix_UI.db.profile.cooldownTracker.timeline = {
                enabled = true,
                width = 300,
                height = 150,
                minDisplayTime = 60,
                showLegend = true,
                trackPlayerOnly = false,
                position = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOffset = 0,
                    yOffset = -200,
                }
            }
        end
        
        -- Ensure required timeline properties have valid values
        local timeline = Phoenix_UI.db.profile.cooldownTracker.timeline
        if not timeline.width or type(timeline.width) ~= "number" then
            timeline.width = 300
        end
        
        if not timeline.height or type(timeline.height) ~= "number" then
            timeline.height = 150
        end
        
        if not timeline.minDisplayTime or type(timeline.minDisplayTime) ~= "number" then
            timeline.minDisplayTime = 60
        end
        
        return Phoenix_UI.db.profile
    end
    return {}
end

-- Helper function to safely update a slider value
local function UpdateSliderValue(widget, value, defaultValue)
    if not widget then return end
    
    -- Ensure value is a valid number
    if value == nil or type(value) ~= "number" or value ~= value then -- Check for NaN
        value = defaultValue
    end
    
    -- Ensure default is valid as well
    if defaultValue == nil or type(defaultValue) ~= "number" or defaultValue ~= defaultValue then
        defaultValue = 0
    end
    
    -- Ensure widget has the right methods
    if not widget.SetValue or type(widget.SetValue) ~= "function" then
        return
    end
    
    -- Use pcall to catch any errors during value updates
    local success = pcall(function()
        widget:SetValue(value)
    end)
    
    if not success and defaultValue ~= nil then
        -- Try again with default value
        pcall(function()
            widget:SetValue(defaultValue)
        end)
    end
end

-- Helper function to get cooldown tracker
local function GetCDT()
    return GetCooldownTracker()
end

-- Helper function to safely initialize a slider with a valid value
local function InitializeSlider(slider, widget, min, max, defaultValue)
    -- Safety check
    if not slider or not slider.SetValue then return end
    
    -- Ensure min/max are valid numbers
    min = (type(min) == "number" and min) or 0
    max = (type(max) == "number" and max) or 100
    defaultValue = (type(defaultValue) == "number" and defaultValue) or min
    
    -- Set up a protected call to avoid errors
    local function safeSetValue(value)
        -- Validate the value
        if value == nil or type(value) ~= "number" or value ~= value then -- Check for NaN
            value = defaultValue or min
        end
        
        -- Clamp value to valid range
        value = math.max(min, math.min(max, value))
        
        -- Set the value with protection
        local success = pcall(function()
            slider:SetValue(value)
        end)
        
        -- Return success status
        return success
    end
    
    -- Try to get a valid initial value
    local initialValue
    if widget.get and type(widget.get) == "function" then
        initialValue = widget.get()
    end
    
    -- If no valid value from get(), try initialValue or default
    if initialValue == nil or type(initialValue) ~= "number" or initialValue ~= initialValue then
        initialValue = widget.initialValue or defaultValue or min
    end
    
    -- Apply the value
    return safeSetValue(initialValue)
end

-- Create a safe wrapper for slider creation
local originalSlider
function module:HookSliderCreation()
    -- Get the Phoenix_UIConfig library
    local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true)
    if not Phoenix_UIConfig then return end
    
    -- Only hook once
    if originalSlider then return end
    
    -- Store the original function
    originalSlider = Phoenix_UIConfig.Slider
    
    -- Create a safer version that handles errors
    Phoenix_UIConfig.Slider = function(self, parent, width, height, value, vertical, min, max)
        -- Ensure parent exists
        if not parent then return nil end
        
        -- Ensure input parameters are valid
        min = type(min) == "number" and min or 0
        max = type(max) == "number" and max or 100
        value = type(value) == "number" and value or min
        width = type(width) == "number" and width or 100
        height = type(height) == "number" and height or 20
        
        -- Validate value
        if value == nil or type(value) ~= "number" or value ~= value then -- Check for NaN
            value = min
        end
        
        -- Clamp value to range
        value = math.max(min, math.min(max, value))
        
        -- Create the slider with protected call
        local success, slider
        success, slider = pcall(function()
            return originalSlider(self, parent, width, height, value, vertical, min, max)
        end)
        
        if not success or not slider then
            -- If creation failed, try with default values
            success, slider = pcall(function()
                return originalSlider(self, parent, 100, 20, min, vertical, min, max)
            end)
            
            -- If it still fails, give up
            if not success or not slider then
                return nil
            end
        end
        
        -- If slider was created successfully, ensure method safety
        if slider and not slider.protected then
            -- Keep a reference to the original SetValue
            local originalSetValue = slider.SetValue
            
            -- Create a protected version
            slider.SetValue = function(self, val)
                if not val or type(val) ~= "number" or val ~= val then
                    val = value -- Use original value as fallback
                end
                
                -- Clamp value to range
                val = math.max(min, math.min(max, val))
                
                -- Use protected call
                pcall(function()
                    originalSetValue(self, val)
                end)
            end
            
            slider.protected = true
        end
        
        return slider
    end
    
    -- Return success
    return true
end

function module:OnInitialize()
    -- Hook slider creation before UI loads
    self:HookSliderCreation()
end

function module:OnEnable()
    if not Phoenix_UI.layouts then
        Phoenix_UI.layouts = {}
    end
    
    -- Get Config
    local L = Phoenix_UI.L or {}
    local DB = GetDB()
    
    -- Ensure timeline settings are valid values (initialize if needed)
    if not DB.cooldownTracker or not DB.cooldownTracker.timeline then
        DB.cooldownTracker = DB.cooldownTracker or {}
        DB.cooldownTracker.timeline = {
            enabled = true,
            width = 300,
            height = 150,
            minDisplayTime = 60,
            showLegend = true,
            trackPlayerOnly = false,
            position = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = -200,
            }
        }
    end
    
    -- Create the layout
    local layout = {
        layoutConfig = { padding = { top = 15 } },
        database = DB.cooldownTracker,
        rows = {
            -- Integration Status section
            {
                header = {
                    type = 'header',
                    label = L["Integration Status"] or "Integration Status"
                }
            },
            {
                description = {
                    type = 'description',
                    text = L["Control how CooldownTracker integrates with Phoenix UI"] or "Control how CooldownTracker integrates with Phoenix UI",
                    column = 12
                }
            },
            {
                enableIntegration = {
                    key = 'general.integrationEnabled',
                    type = 'checkbox',
                    label = L["Enable Phoenix UI Integration"] or "Enable Phoenix UI Integration",
                    tooltip = L["Use Phoenix UI panel for CooldownTracker configuration"] or "Use Phoenix UI panel for CooldownTracker configuration",
                    get = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local db = DB.cooldownTracker and DB.cooldownTracker.general
                        return db and db.integrationEnabled ~= false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.general then DB.cooldownTracker.general = {} end
                        DB.cooldownTracker.general.integrationEnabled = value
                        
                        -- Update module settings
                        local cdt = GetCooldownTracker()
                        if cdt and cdt.UpdateSettings then
                            cdt:UpdateSettings()
                        end
                    end,
                    column = 12
                }
            },
            {
                divider1 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Module Status section
            {
                header2 = {
                    type = 'header',
                    label = L["Module Status"] or "Module Status"
                }
            },
            {
                description2 = {
                    type = 'description',
                    text = L["Enable or disable the CooldownTracker module and its components"] or "Enable or disable the CooldownTracker module and its components",
                    column = 12
                }
            },
            {
                enableCooldownTracker = {
                    key = 'general.enabled',
                    type = 'checkbox',
                    label = L["Enable Cooldown Tracker"] or "Enable Cooldown Tracker",
                    tooltip = L["Master toggle for the Cooldown Tracker module"] or "Master toggle for the Cooldown Tracker module",
                    get = function() 
                        if not IsCooldownTrackerLoaded() then return false end
                        return DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.general then DB.cooldownTracker.general = {} end
                        DB.cooldownTracker.general.enabled = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    column = 12
                }
            },
            {
                divider2 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Cooldown Text Section
            {
                header3 = {
                    type = 'header',
                    label = L["Cooldown Text"] or "Cooldown Text"
                }
            },
            {
                description3 = {
                    type = 'description',
                    text = L["Configure text display on cooldown buttons (similar to OmniCC)"] or "Configure text display on cooldown buttons (similar to OmniCC)",
                    column = 12
                }
            },
            {
                enableCooldownText = {
                    key = 'cooldownText.enabled',
                    type = 'checkbox',
                    label = L["Enable Cooldown Text"] or "Enable Cooldown Text",
                    tooltip = L["Show countdown timer text on buttons"] or "Show countdown timer text on buttons",
                    column = 4,
                    order = 1,
                    onChange = function(widget, value)
                        -- Update DB value
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        DB.cooldownTracker.cooldownText.enabled = value
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end
                },
                showCooldownSwipe = {
                    key = 'cooldownText.swipe',
                    type = 'checkbox',
                    label = L["Show Cooldown Swipe"] or "Show Cooldown Swipe",
                    tooltip = L["Display the standard cooldown animation along with text"] or "Display the standard cooldown animation along with text",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return true end
                        return DB.cooldownTracker.cooldownText.swipe or true
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        DB.cooldownTracker.cooldownText.swipe = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        return not (cdEnabled and textEnabled)
                    end,
                    column = 4
                },
                enableFinishEffects = {
                    key = 'cooldownText.finishEffects.enableFlash',
                    type = 'checkbox',
                    label = L["Enable Finish Effects"] or "Enable Finish Effects",
                    tooltip = L["Show visual effects when cooldowns complete (flash, pulse, etc.)"] or "Show visual effects when cooldowns complete (flash, pulse, etc.)",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return false end
                        return DB.cooldownTracker.cooldownText.finishEffects and DB.cooldownTracker.cooldownText.finishEffects.enableFlash or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        DB.cooldownTracker.cooldownText.finishEffects = { enableFlash = value }
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        return not (cdEnabled and textEnabled)
                    end,
                    column = 4
                }
            },
            {
                textSize = {
                    key = 'cooldownText.textSize',
                    type = 'slider',
                    label = L["Font Size"] or "Font Size",
                    min = 6,
                    max = 32,
                    column = 4,
                    order = 2,
                    onChange = function(widget, value)
                        -- Use our safe update function with default of 14
                        value = type(value) == "number" and value or 14
                        
                        -- Update DB value
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        DB.cooldownTracker.cooldownText.textSize = value
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end
                },
                expiringThreshold = {
                    key = 'cooldownText.expiringDuration',
                    type = 'slider',
                    label = L["Expiring Threshold"] or "Expiring Threshold",
                    tooltip = L["When cooldown is below this many seconds, use the expiring color"] or "When cooldown is below this many seconds, use the expiring color",
                    min = 1,
                    max = 10,
                    column = 4,
                    order = 3,
                    onChange = function(widget, value)
                        -- Update DB value
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        DB.cooldownTracker.cooldownText.expiringDuration = value
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end
                }
            },
            {
                textPosition = {
                    key = 'cooldownText.textPosition',
                    type = 'dropdown',
                    label = L["Text Position"] or "Text Position",
                    tooltip = L["Position of the cooldown text on the button"] or "Position of the cooldown text on the button",
                    options = {
                        { value = "CENTER", text = L["Center"] or "Center" },
                        { value = "TOP", text = L["Top"] or "Top" },
                        { value = "BOTTOM", text = L["Bottom"] or "Bottom" }
                    },
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return "CENTER" end
                        return DB.cooldownTracker.cooldownText.textPosition or "CENTER"
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        DB.cooldownTracker.cooldownText.textPosition = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        return not (cdEnabled and textEnabled)
                    end,
                    column = 6
                }
            },
            {
                divider3 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Expiring Effects Section
            {
                header4 = {
                    type = 'header',
                    label = L["Expiring Effects"] or "Expiring Effects"
                }
            },
            {
                description4 = {
                    type = 'description',
                    text = L["Configure special effects for cooldowns that are about to expire"] or "Configure special effects for cooldowns that are about to expire",
                    column = 12
                }
            },
            {
                enableExpiringEffects = {
                    key = 'cooldownText.expiringEffects.enabled',
                    type = 'checkbox',
                    label = L["Enable Expiring Effects"] or "Enable Expiring Effects",
                    tooltip = L["Show visual effects when cooldowns are about to expire"] or "Show visual effects when cooldowns are about to expire",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return false end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.enabled or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.enabled = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        return not (cdEnabled and textEnabled)
                    end,
                    column = 4
                },
                enablePulse = {
                    key = 'cooldownText.expiringEffects.enablePulse',
                    type = 'checkbox',
                    label = L["Enable Pulse Effect"] or "Enable Pulse Effect",
                    tooltip = L["Make expiring cooldown text pulse"] or "Make expiring cooldown text pulse",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return false end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.enablePulse or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.enablePulse = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        local effectsEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                               DB.cooldownTracker.cooldownText.expiringEffects.enabled
                        return not (cdEnabled and textEnabled and effectsEnabled)
                    end,
                    column = 4
                },
                enableScale = {
                    key = 'cooldownText.expiringEffects.enableScale',
                    type = 'checkbox',
                    label = L["Enable Scale Effect"] or "Enable Scale Effect",
                    tooltip = L["Make expiring cooldown text grow larger"] or "Make expiring cooldown text grow larger",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return false end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.enableScale or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.enableScale = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        local effectsEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                               DB.cooldownTracker.cooldownText.expiringEffects.enabled
                        return not (cdEnabled and textEnabled and effectsEnabled)
                    end,
                    column = 4
                }
            },
            {
                pulseIntensity = {
                    key = 'cooldownText.expiringEffects.pulseIntensity',
                    type = 'slider',
                    label = L["Pulse Intensity"] or "Pulse Intensity",
                    tooltip = L["How strong the pulse effect should be"] or "How strong the pulse effect should be",
                    min = 1.05,
                    max = 2.0,
                    step = 0.05,
                    initialValue = 1.2,
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return 1.2 end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.pulseIntensity or 1.2
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.pulseIntensity = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        local effectsEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                               DB.cooldownTracker.cooldownText.expiringEffects.enabled
                        local pulseEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                             DB.cooldownTracker.cooldownText.expiringEffects.enablePulse
                        return not (cdEnabled and textEnabled and effectsEnabled and pulseEnabled)
                    end,
                    column = 6
                },
                pulseDuration = {
                    key = 'cooldownText.expiringEffects.pulseDuration',
                    type = 'slider',
                    label = L["Pulse Speed"] or "Pulse Speed",
                    tooltip = L["How fast the pulse effect should be (lower is faster)"] or "How fast the pulse effect should be (lower is faster)",
                    min = 0.2,
                    max = 2.0,
                    step = 0.1,
                    initialValue = 0.6,
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return 0.6 end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.pulseDuration or 0.6
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.pulseDuration = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        local effectsEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                               DB.cooldownTracker.cooldownText.expiringEffects.enabled
                        local pulseEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                             DB.cooldownTracker.cooldownText.expiringEffects.enablePulse
                        return not (cdEnabled and textEnabled and effectsEnabled and pulseEnabled)
                    end,
                    column = 6
                }
            },
            {
                maxScale = {
                    key = 'cooldownText.expiringEffects.scaleMax',
                    type = 'slider',
                    label = L["Maximum Scale"] or "Maximum Scale",
                    tooltip = L["Maximum size for expiring cooldown text"] or "Maximum size for expiring cooldown text",
                    min = 1.1,
                    max = 2.0,
                    step = 0.1,
                    initialValue = 1.5,
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return 1.5 end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.scaleMax or 1.5
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.scaleMax = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        local effectsEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                               DB.cooldownTracker.cooldownText.expiringEffects.enabled
                        local scaleEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                             DB.cooldownTracker.cooldownText.expiringEffects.enableScale
                        return not (cdEnabled and textEnabled and effectsEnabled and scaleEnabled)
                    end,
                    column = 6
                },
                scaleMaxTime = {
                    key = 'cooldownText.expiringEffects.scaleMaxTime',
                    type = 'slider',
                    label = L["Scale Threshold"] or "Scale Threshold",
                    tooltip = L["When to start scaling (in seconds)"] or "When to start scaling (in seconds)",
                    min = 1,
                    max = 10,
                    step = 0.5,
                    initialValue = 3,
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.cooldownText then return 3 end
                        return DB.cooldownTracker.cooldownText.expiringEffects and DB.cooldownTracker.cooldownText.expiringEffects.scaleMaxTime or 3
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        if not DB.cooldownTracker.cooldownText.expiringEffects then DB.cooldownTracker.cooldownText.expiringEffects = {} end
                        DB.cooldownTracker.cooldownText.expiringEffects.scaleMaxTime = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local textEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.enabled
                        local effectsEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                               DB.cooldownTracker.cooldownText.expiringEffects.enabled
                        local scaleEnabled = DB.cooldownTracker and DB.cooldownTracker.cooldownText and DB.cooldownTracker.cooldownText.expiringEffects and 
                                             DB.cooldownTracker.cooldownText.expiringEffects.enableScale
                        return not (cdEnabled and textEnabled and effectsEnabled and scaleEnabled)
                    end,
                    column = 6
                }
            },
            {
                divider4 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Spell Tracker Section
            {
                header5 = {
                    type = 'header',
                    label = L["Spell Tracker"] or "Spell Tracker"
                }
            },
            {
                description5 = {
                    type = 'description',
                    text = L["Track your spell casts with a visual history (similar to TrufiGCD)"] or "Track your spell casts with a visual history (similar to TrufiGCD)",
                    column = 12
                }
            },
            {
                enableSpellTracker = {
                    key = 'spellTracker.enabled',
                    type = 'checkbox',
                    label = L["Enable Spell Tracker"] or "Enable Spell Tracker",
                    tooltip = L["Display recent spell casts in a visual tracker"] or "Display recent spell casts in a visual tracker",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker then return false end
                        return DB.cooldownTracker.spellTracker and DB.cooldownTracker.spellTracker.enabled or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.spellTracker then DB.cooldownTracker.spellTracker = {} end
                        DB.cooldownTracker.spellTracker.enabled = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        return not (DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled)
                    end,
                    column = 6
                }
            },
            {
                divider6 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Party Cooldowns Section
            {
                header6 = {
                    type = 'header',
                    label = L["Party Cooldowns"] or "Party Cooldowns"
                }
            },
            {
                description6 = {
                    type = 'description',
                    text = L["Track important cooldowns of your party and raid members (similar to OmniCD)"] or "Track important cooldowns of your party and raid members (similar to OmniCD)",
                    column = 12
                }
            },
            {
                enablePartyCooldowns = {
                    key = 'partyCD.enabled',
                    type = 'checkbox',
                    label = L["Enable Party Cooldowns"] or "Enable Party Cooldowns",
                    tooltip = L["Show tracking of party and raid cooldowns"] or "Show tracking of party and raid cooldowns",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker then return false end
                        return DB.cooldownTracker.partyCD and DB.cooldownTracker.partyCD.enabled or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.partyCD then DB.cooldownTracker.partyCD = {} end
                        DB.cooldownTracker.partyCD.enabled = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        return not (DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled)
                    end,
                    column = 6
                }
            },
            {
                divider7 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Raid Timeline Section
            {
                header8 = {
                    type = 'header',
                    label = L["Raid Timeline"] or "Raid Timeline"
                }
            },
            {
                description8 = {
                    type = 'description',
                    text = L["Configure the raid timeline display for tracking important cooldowns and events"] or "Configure the raid timeline display for tracking important cooldowns and events",
                    column = 12
                }
            },
            {
                enableRaidTimeline = {
                    key = 'timeline.enabled',
                    type = 'checkbox',
                    label = L["Enable Raid Timeline"] or "Enable Raid Timeline",
                    tooltip = L["Show a timeline of important raid events and cooldowns"] or "Show a timeline of important raid events and cooldowns",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker then return false end
                        return DB.cooldownTracker.timeline and DB.cooldownTracker.timeline.enabled or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.enabled = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        return not (DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled)
                    end,
                    column = 6
                },
                showPlayerOnly = {
                    key = 'timeline.trackPlayerOnly',
                    type = 'checkbox',
                    label = L["Track Player Only"] or "Track Player Only",
                    tooltip = L["Only show cooldowns and events from your character"] or "Only show cooldowns and events from your character",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.timeline then return false end
                        return DB.cooldownTracker.timeline.trackPlayerOnly or false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.trackPlayerOnly = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local timelineEnabled = DB.cooldownTracker and DB.cooldownTracker.timeline and DB.cooldownTracker.timeline.enabled
                        return not (cdEnabled and timelineEnabled)
                    end,
                    column = 6
                }
            },
            {
                timelineWidth = {
                    key = 'timeline.width',
                    type = 'slider',
                    label = L["Timeline Width"] or "Timeline Width",
                    tooltip = L["Set the width of the timeline window"] or "Set the width of the timeline window",
                    min = 200,
                    max = 600,
                    step = 10,
                    initialValue = 300,
                    defaultValue = 300,
                    get = function() 
                        local defaultWidth = 300
                        -- Ensure we have a valid value
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.timeline then 
                            return defaultWidth
                        end
                        
                        local width = DB.cooldownTracker.timeline.width
                        if width == nil or type(width) ~= "number" then
                            return defaultWidth
                        end
                        
                        return width
                    end,
                    set = function(value)
                        -- Ensure value is valid
                        if not value or type(value) ~= "number" then
                            value = 300
                        end
                        
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.width = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    onChange = function(widget, value)
                        -- Ensure value is valid (default to 300 if nil)
                        value = type(value) == "number" and value or 300
                        
                        -- Update DB value
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.width = value
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local timelineEnabled = DB.cooldownTracker and DB.cooldownTracker.timeline and DB.cooldownTracker.timeline.enabled
                        return not (cdEnabled and timelineEnabled)
                    end,
                    column = 4
                },
                timelineHeight = {
                    key = 'timeline.height',
                    type = 'slider',
                    label = L["Timeline Height"] or "Timeline Height",
                    tooltip = L["Set the height of the timeline window"] or "Set the height of the timeline window",
                    min = 100,
                    max = 400,
                    step = 10,
                    initialValue = 150,
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.timeline then return 150 end
                        return DB.cooldownTracker.timeline.height or 150
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.height = value or 150
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    onChange = function(widget, value)
                        -- Ensure value is valid (default to 150 if nil)
                        value = type(value) == "number" and value or 150
                        
                        -- Update DB value
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.height = value
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local timelineEnabled = DB.cooldownTracker and DB.cooldownTracker.timeline and DB.cooldownTracker.timeline.enabled
                        return not (cdEnabled and timelineEnabled)
                    end,
                    column = 4
                },
                timelineMinTime = {
                    key = 'timeline.minDisplayTime',
                    type = 'slider',
                    label = L["Minimum Timeline"] or "Minimum Timeline",
                    tooltip = L["Minimum time to display in seconds"] or "Minimum time to display in seconds",
                    min = 30,
                    max = 300,
                    step = 30,
                    initialValue = 60,
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.timeline then return 60 end
                        return DB.cooldownTracker.timeline.minDisplayTime or 60
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.minDisplayTime = value or 60
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    onChange = function(widget, value)
                        -- Ensure value is valid (default to 60 if nil)
                        value = type(value) == "number" and value or 60
                        
                        -- Update DB value
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.minDisplayTime = value
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local timelineEnabled = DB.cooldownTracker and DB.cooldownTracker.timeline and DB.cooldownTracker.timeline.enabled
                        return not (cdEnabled and timelineEnabled)
                    end,
                    column = 4
                }
            },
            {
                showLegend = {
                    key = 'timeline.showLegend',
                    type = 'checkbox',
                    label = L["Show Legend"] or "Show Legend",
                    tooltip = L["Display a legend explaining the color coding"] or "Display a legend explaining the color coding",
                    get = function() 
                        if not IsCooldownTrackerLoaded() or not DB.cooldownTracker or not DB.cooldownTracker.timeline then return true end
                        return DB.cooldownTracker.timeline.showLegend ~= false
                    end,
                    set = function(value)
                        if not IsCooldownTrackerLoaded() then return end
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.timeline then DB.cooldownTracker.timeline = {} end
                        DB.cooldownTracker.timeline.showLegend = value
                        local cooldownTracker = GetCooldownTracker()
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                    end,
                    disabled = function() 
                        if not IsCooldownTrackerLoaded() then return true end
                        local cdEnabled = DB.cooldownTracker and DB.cooldownTracker.general and DB.cooldownTracker.general.enabled
                        local timelineEnabled = DB.cooldownTracker and DB.cooldownTracker.timeline and DB.cooldownTracker.timeline.enabled
                        return not (cdEnabled and timelineEnabled)
                    end,
                    column = 4
                }
            },
            {
                divider8 = {
                    type = 'divider',
                    column = 12
                }
            },
            
            -- Live Preview Section
            {
                header7 = {
                    type = 'header',
                    label = L["Preview"] or "Preview"
                }
            },
            {
                description7 = {
                    type = 'description',
                    text = L["Preview your cooldown text styling with all current settings"] or "Preview your cooldown text styling with all current settings",
                    column = 12
                }
            },
            {
                previewButton = {
                    type = 'button',
                    label = L["Show Live Preview"] or "Show Live Preview",
                    tooltip = L["Display a preview of your current cooldown text style"] or "Display a preview of your current cooldown text style",
                    onClick = function()
                        -- Get the CooldownTracker module
                        local cooldownTracker = GetCooldownTracker()
                        if not cooldownTracker then
                            if DEFAULT_CHAT_FRAME then
                                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Phoenix UI:|r CooldownTracker module not found")
                            end
                            return
                        end
                        
                        -- Check if Styling module exists
                        if not cooldownTracker.Styling or type(cooldownTracker.Styling.PreviewStyle) ~= "function" then
                            if DEFAULT_CHAT_FRAME then
                                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Phoenix UI:|r Styling module not found or not properly initialized")
                            end
                            return
                        end
                        
                        -- Get current settings
                        local db = GetDB()
                        if not db or not db.cooldownText then
                            if DEFAULT_CHAT_FRAME then
                                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Phoenix UI:|r CooldownTracker settings not found")
                            end
                            return
                        end
                        
                        -- Create preview settings
                        local fontInfo = {
                            font = db.cooldownText.textFont,
                            size = db.cooldownText.textSize,
                            flags = db.cooldownText.textFlags or "OUTLINE"
                        }
                        
                        local colorInfo = {
                            r = db.cooldownText.normalColor and db.cooldownText.normalColor.r or 1,
                            g = db.cooldownText.normalColor and db.cooldownText.normalColor.g or 1,
                            b = db.cooldownText.normalColor and db.cooldownText.normalColor.b or 1,
                            a = db.cooldownText.normalColor and db.cooldownText.normalColor.a or 1,
                            expiring = {
                                r = db.cooldownText.expiringColor and db.cooldownText.expiringColor.r or 1,
                                g = db.cooldownText.expiringColor and db.cooldownText.expiringColor.g or 0,
                                b = db.cooldownText.expiringColor and db.cooldownText.expiringColor.b or 0,
                                a = db.cooldownText.expiringColor and db.cooldownText.expiringColor.a or 1
                            }
                        }
                        
                        local effectInfo = {
                            flashEnabled = db.cooldownText.finishEffects and db.cooldownText.finishEffects.enableFlash,
                            flashColor = db.cooldownText.finishEffects and db.cooldownText.finishEffects.flashColor,
                            flashDuration = db.cooldownText.finishEffects and db.cooldownText.finishEffects.flashDuration
                        }
                        
                        local positionInfo = {
                            position = db.cooldownText.textPosition or "CENTER",
                            xOffset = db.cooldownText.xOffset or 0,
                            yOffset = db.cooldownText.yOffset or 0
                        }
                        
                        -- Show the preview
                        pcall(function()
                            cooldownTracker.Styling:PreviewStyle(fontInfo, colorInfo, effectInfo, positionInfo)
                        end)
                    end,
                    column = 4,
                    order = 1
                },
                testingSection = {
                    type = 'button',
                    label = L["Test With Real Cooldowns"] or "Test With Real Cooldowns",
                    tooltip = L["Create test cooldowns on your action bars"] or "Create test cooldowns on your action bars",
                    onClick = function()
                        -- Get the CooldownTracker module
                        local cooldownTracker = GetCooldownTracker()
                        if not cooldownTracker then
                            return
                        end
                        
                        -- Create test cooldowns using the game's builtin test cooldown function
                        CooldownFrame_Set(_G["ActionButton1Cooldown"], GetTime(), 3, true)  -- 3 second cooldown
                        CooldownFrame_Set(_G["ActionButton2Cooldown"], GetTime(), 10, true) -- 10 second cooldown
                        CooldownFrame_Set(_G["ActionButton3Cooldown"], GetTime(), 30, true) -- 30 second cooldown
                        CooldownFrame_Set(_G["ActionButton4Cooldown"], GetTime(), 120, true) -- 2 minute cooldown
                        
                        -- Show a message
                        if DEFAULT_CHAT_FRAME then
                            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Phoenix UI:|r Created test cooldowns on action buttons 1-4")
                        end
                    end,
                    column = 4,
                    order = 2
                },
                resetButton = {
                    type = 'button',
                    label = L["Reset to Default Style"] or "Reset to Default Style",
                    tooltip = L["Reset cooldown text styling to default values"] or "Reset cooldown text styling to default values",
                    onClick = function()
                        -- Get the CooldownTracker module
                        local cooldownTracker = GetCooldownTracker()
                        if not cooldownTracker then
                            return
                        end
                        
                        -- Reset cooldown text settings to defaults
                        if not DB.cooldownTracker then DB.cooldownTracker = {} end
                        if not DB.cooldownTracker.cooldownText then DB.cooldownTracker.cooldownText = {} end
                        
                        -- Apply default values
                        DB.cooldownTracker.cooldownText.textSize = 14
                        DB.cooldownTracker.cooldownText.textFont = "Friz Quadrata TT"
                        DB.cooldownTracker.cooldownText.textFlags = "OUTLINE"
                        DB.cooldownTracker.cooldownText.swipe = true
                        DB.cooldownTracker.cooldownText.expiringColor = {r = 1, g = 0, b = 0, a = 1}
                        DB.cooldownTracker.cooldownText.normalColor = {r = 1, g = 1, b = 1, a = 1}
                        DB.cooldownTracker.cooldownText.expiringDuration = 3
                        DB.cooldownTracker.cooldownText.finishEffects = { enableFlash = true, flashColor = {r = 1, g = 1, b = 1, a = 0.7}, flashDuration = 0.8 }
                        DB.cooldownTracker.cooldownText.textPosition = "CENTER"
                        DB.cooldownTracker.cooldownText.xOffset = 0
                        DB.cooldownTracker.cooldownText.yOffset = 0
                        
                        -- Force save to disk
                        if Phoenix_UI and Phoenix_UI.SaveDB then
                            Phoenix_UI:SaveDB()
                            -- Ensure it's written to disk
                            if FlushSavedVariables then FlushSavedVariables() end
                        end
                        
                        -- Update module settings if available
                        if cooldownTracker and cooldownTracker.UpdateSettings then
                            cooldownTracker:UpdateSettings()
                        end
                        
                        -- Show confirmation message
                        if DEFAULT_CHAT_FRAME then
                            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Phoenix UI:|r Cooldown text style has been reset to defaults")
                        end
                    end,
                    column = 4,
                    order = 3
                }
            }
        }
    }
    
    -- Register the layout
    Phoenix_UI.layouts.CooldownTracker = layout
    
    -- Get the CooldownTracker module
    local CooldownTrackerModule = GetCooldownTracker()
    
    -- Connect the layout to the module
    if CooldownTrackerModule then
        CooldownTrackerModule.layout = layout
        if CooldownTrackerModule.OnLayoutRegistered then
            CooldownTrackerModule:OnLayoutRegistered(layout)
        end
    end
end

-- Helper function to add widgets to a frame
function module:AddWidgetsToFrame(parent, widgets)
    if not parent or not widgets or type(widgets) ~= "table" then return end
    
    -- Get the Phoenix_UIConfig library
    local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true)
    if not Phoenix_UIConfig then return end
    
    local lastWidget = nil
    local yOffset = -10
    
    for _, widget in ipairs(widgets) do
        local element = nil
        
        if widget.type == "Header" then
            element = Phoenix_UIConfig:Header(parent, widget.text)
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -20)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
            end
            
        elseif widget.type == "Description" then
            element = Phoenix_UIConfig:Label(parent, widget.text)
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -10)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
            end
            
        elseif widget.type == "CheckBox" then
            element = Phoenix_UIConfig:Checkbox(parent, widget.text)
            element.tooltipText = widget.tooltip
            if widget.get then element:SetChecked(widget.get()) end
            if widget.set then 
                element:SetScript("OnClick", function(self)
                    widget.set(self:GetChecked())
                end)
            end
            if widget.disabled and widget.disabled() then
                element:Disable()
            end
            
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -15)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
            end
            
        elseif widget.type == "Slider" then
            element = Phoenix_UIConfig:Slider(parent, widget.min, widget.max, widget.step)
            element.label:SetText(widget.text)
            element.tooltipText = widget.tooltip
            
            -- Safely get value or use initialValue as fallback
            local value
            if widget.get then 
                value = widget.get() 
                -- Ensure value is a valid number
                if value == nil or type(value) ~= "number" then
                    value = widget.initialValue
                end
            end
            
            -- Safely set initial value
            if value then
                pcall(function() element:SetValue(value) end)
            end
            
            if widget.set then 
                element:SetScript("OnValueChanged", function(self, value)
                    -- Ensure value is valid
                    if value == nil or type(value) ~= "number" then
                        value = widget.initialValue
                    end
                    widget.set(value)
                end)
            end
            
            if widget.disabled and widget.disabled() then
                element:Disable()
            end
            
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -25)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
            end
            
        elseif widget.type == "Dropdown" then
            local options = widget.options
            if type(options) == "function" then
                options = options()
            end
            
            element = Phoenix_UIConfig:Dropdown(parent, options)
            element.label:SetText(widget.text)
            element.tooltipText = widget.tooltip
            if widget.get then element:SetValue(widget.get()) end
            if widget.set then 
                element.SetValue = function(self, value)
                    widget.set(value)
                    self.text:SetText(options[value] or value)
                end
            end
            if widget.disabled and widget.disabled() then
                element:Disable()
            end
            
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -25)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
            end
            
        elseif widget.type == "ColorPicker" then
            element = Phoenix_UIConfig:ColorPicker(parent)
            element.label:SetText(widget.text)
            element.tooltipText = widget.tooltip
            if widget.get then 
                local r, g, b, a = widget.get()
                element:SetColor(r, g, b, a)
            end
            if widget.set then 
                element.SetColor = function(self, r, g, b, a)
                    widget.set(r, g, b, a)
                    self.color:SetColorTexture(r, g, b, a)
                end
            end
            if widget.disabled and widget.disabled() then
                element:Disable()
            end
            
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -15)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
            end
            
        elseif widget.type == "Divider" then
            element = Phoenix_UIConfig:HorizontalLine(parent, nil, 15)
            if lastWidget then
                element:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -15)
                element:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, 0)
            else
                element:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
                element:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, 0)
            end
        end
        
        if element then
            lastWidget = element
        end
    end
end

-- Helper function to patch slider functionality
local function PatchSliderFunctionality()
    local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true)
    if not Phoenix_UIConfig then return end
    
    -- Safely patch the SetValue method of sliders
    local originalSetValue = getmetatable(CreateFrame("Slider")).__index.SetValue
    if originalSetValue then
        hooksecurefunc(getmetatable(CreateFrame("Slider")).__index, "SetValue", function(self, value)
            -- If nil or invalid, use default
            if value == nil or type(value) ~= "number" then
                local min, max = self:GetMinMaxValues()
                value = min or 0
                
                -- Call the original with a valid value
                originalSetValue(self, value)
            end
        end)
    end
end

-- Run the patch when the addon loads
C_Timer.After(0.1, PatchSliderFunctionality) 