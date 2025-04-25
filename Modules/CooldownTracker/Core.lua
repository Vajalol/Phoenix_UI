-- Phoenix_UI CooldownTracker - Core Module
local addonName, Phoenix = ...

-- Create the module
local CT = Phoenix_UI:NewModule("CooldownTracker")
CT.version = "1.0.0"
CT.activeFrames = {}
CT.timers = {}
CT.throttle = {}

-- Localization
local L = Phoenix.L or {}

-- Constants
local UPDATE_INTERVAL = 0.05       -- Base update interval (50ms)
local UPDATE_INTERVAL_DISTANT = 0.25  -- Less frequent updates for cooldowns > 10 seconds (250ms)
local UPDATE_INTERVAL_EXPIRING = 0.03 -- More frequent updates for cooldowns < 3 seconds (30ms)
local THROTTLE_COMBAT = 0.1        -- Less frequent updates during combat for non-critical cooldowns
local MIN_DURATION = 1.5           -- Minimum duration to show cooldown text
local MAX_DISPLAYED = 200          -- Maximum number of active cooldown frames to prevent memory issues
local BATCH_SIZE = 30              -- Number of cooldowns to update per batch

-- Cooldown priority levels
local PRIORITY = {
    HIGH = 1,    -- Critical cooldowns (player active abilities, < 3s remaining)
    MEDIUM = 2,  -- Important cooldowns (3-10s remaining)
    LOW = 3,     -- Other cooldowns (> 10s remaining)
}

-- Defaults
local defaults = {
    general = {
        enabled = true,
        performanceMode = false,
        minimapButton = true,
    },
    cooldownText = {
        enabled = true,
        swipe = true,
        textSize = 14,
        textFont = "Friz Quadrata TT",
        expiringDuration = 3,
        expiringColor = {r = 1, g = 0, b = 0, a = 1},
        normalColor = {r = 1, g = 1, b = 1, a = 1},
        finishEffects = { 
            enableFlash = true,
            flashColor = {r = 1, g = 1, b = 1, a = 0.7},
            flashDuration = 0.8
        },
        textPosition = "CENTER",
    }
}

-- GetDB is currently a local function but needs to be exposed to other modules
local function GetDB()
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile then
        -- Return a copy of defaults to avoid modifying the original
        return CopyTable(defaults)
    end
    
    -- Create cooldownTracker table if it doesn't exist
    if not Phoenix_UI.db.profile.cooldownTracker then
        Phoenix_UI.db.profile.cooldownTracker = CopyTable(defaults)
    end
    
    -- Ensure critical sections exist
    local db = Phoenix_UI.db.profile.cooldownTracker
    
    -- Check and repair general settings
    if not db.general then 
        db.general = CopyTable(defaults.general)
    end
    
    -- Check and repair cooldownText settings
    if not db.cooldownText then
        db.cooldownText = CopyTable(defaults.cooldownText)
    end
    
    return db
end

-- Expose GetDB for other modules to use
function CT:GetDB()
    return GetDB()
end

local function GetCurrentOptions()
    local db = GetDB()
    
    -- Return a validated options table
    local options = {
        enabled = db.general and db.general.enabled or defaults.general.enabled,
        performanceMode = db.general and db.general.performanceMode or defaults.general.performanceMode,
        cooldownText = {
            enabled = db.cooldownText and db.cooldownText.enabled or defaults.cooldownText.enabled,
            textSize = db.cooldownText and db.cooldownText.textSize or defaults.cooldownText.textSize,
            textFont = db.cooldownText and db.cooldownText.textFont or defaults.cooldownText.textFont,
            swipe = db.cooldownText and db.cooldownText.swipe ~= nil and db.cooldownText.swipe or defaults.cooldownText.swipe,
            expiringDuration = db.cooldownText and db.cooldownText.expiringDuration or defaults.cooldownText.expiringDuration,
            expiringColor = db.cooldownText and db.cooldownText.expiringColor or defaults.cooldownText.expiringColor,
            normalColor = db.cooldownText and db.cooldownText.normalColor or defaults.cooldownText.normalColor,
            finishEffects = db.cooldownText and db.cooldownText.finishEffects or defaults.cooldownText.finishEffects,
            textPosition = db.cooldownText and db.cooldownText.textPosition or defaults.cooldownText.textPosition,
        }
    }
    
    return options
end

-- Format time text based on remaining time
local function FormatTimeText(timeLeft)
    if timeLeft < 0 then
        return ""
    elseif timeLeft < 3 then
        return string.format("%.1f", timeLeft) -- Show with 1 decimal place under 3 seconds
    elseif timeLeft < 60 then
        return string.format("%d", floor(timeLeft)) -- Show as integer seconds
    elseif timeLeft < 3600 then
        return string.format("%d:%02d", floor(timeLeft/60), floor(timeLeft%60)) -- Minutes:Seconds
    else
        return string.format("%d:%02d", floor(timeLeft/3600), floor((timeLeft%3600)/60)) -- Hours:Minutes
    end
end

-- Determine cooldown priority based on remaining time and type
local function GetCooldownPriority(frame)
    if not frame or not frame.startTime or not frame.duration then
        return PRIORITY.LOW
    end
    
    local timeLeft = (frame.startTime + frame.duration) - GetTime()
    
    -- Expired cooldowns are low priority
    if timeLeft <= 0 then 
        return PRIORITY.LOW
    end
    
    -- Critical cooldowns are high priority
    if timeLeft < 3 then
        return PRIORITY.HIGH
    end
    
    -- Important cooldowns are medium priority
    if timeLeft < 10 then
        return PRIORITY.MEDIUM
    end
    
    -- Default to low priority
    return PRIORITY.LOW
end

-- Get Frame from FramePool
function CT:GetFrame()
    -- Use the frame pool module if available
    if self.FramePool then
        return self.FramePool:Acquire("CooldownFrames")
    else
        -- Legacy frame creation if FramePool module not loaded yet
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(10, 10)
        
        -- Create text for cooldown display
        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetPoint("CENTER", 0, 0)
        
        -- Create finish animation effect
        frame.flash = frame:CreateTexture(nil, "OVERLAY")
        frame.flash:SetAllPoints()
        frame.flash:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Flash")
        frame.flash:SetBlendMode("ADD")
        frame.flash:SetAlpha(0)
        
        -- Animation group for flash effect
        frame.flashAnim = frame:CreateAnimationGroup()
        local alpha = frame.flashAnim:CreateAnimation("Alpha")
        alpha:SetFromAlpha(0)
        alpha:SetToAlpha(0.7)
        alpha:SetDuration(0.3)
        alpha:SetOrder(1)
        local alpha2 = frame.flashAnim:CreateAnimation("Alpha")
        alpha2:SetFromAlpha(0.7)
        alpha2:SetToAlpha(0)
        alpha2:SetDuration(0.5)
        alpha2:SetOrder(2)
        
        frame.flashAnim:SetScript("OnPlay", function() 
            frame.flash:SetAlpha(1)
            frame.flash:Show()
        end)
        
        frame.flashAnim:SetScript("OnFinished", function()
            frame.flash:SetAlpha(0)
            frame.flash:Hide()
        end)
        
        -- Add Reset method
        frame.Reset = function(self)
            self:ClearAllPoints()
            self:SetAlpha(1)
            self:SetScale(1)
            if self.cooldown then
                self.cooldown:Clear()
            end
            self.text:SetText("")
            
            -- Stop animations
            if self.flashAnim:IsPlaying() then
                self.flashAnim:Stop()
            end
            
            -- Clear any stored data
            self.start = nil
            self.duration = nil
            self.spellID = nil
            self.itemID = nil
            self.priority = nil
            self.lastUpdateTime = nil
        end
        
        return frame
    end
end

function CT:RecycleFrame(frame)
    -- Use the frame pool module if available
    if self.FramePool then
        self.FramePool:Release(frame)
    else
        -- Legacy cleanup if FramePool module not loaded yet
        frame.cooldown = nil
        frame.startTime = nil
        frame.duration = nil
        frame.priority = nil
        frame.lastUpdateTime = nil
        frame.text:SetText("")
        frame:Hide()
    end
end

-- Apply settings to a cooldown frame
function CT:ConfigureFrame(frame, startTime, duration, cooldown)
    local options = GetCurrentOptions()
    local cdText = options.cooldownText
    
    if not cdText.enabled then return end
    
    -- Store timing information
    frame.startTime = startTime
    frame.duration = duration
    frame.cooldown = cooldown
    frame.lastUpdateTime = GetTime()
    
    -- Configure text appearance
    frame.text:SetFont(cdText.textFont, cdText.textSize, "OUTLINE")
    
    -- Position text
    frame.text:ClearAllPoints()
    frame.text:SetPoint(cdText.textPosition, 0, 0)
    
    -- Set initial priority
    frame.priority = GetCooldownPriority(frame)
    
    -- Check frame size
    local width, height = cooldown:GetSize()
    
    -- Add the frame to active tracking
    table.insert(self.activeFrames, frame)
    
    -- Make sure we're not exceeding the maximum number of displayed frames
    while #self.activeFrames > MAX_DISPLAYED do
        local oldestFrame = table.remove(self.activeFrames, 1)
        self:RecycleFrame(oldestFrame)
    end
    
    -- Ensure update timer is running
    self:EnsureUpdateTimerRunning()
end

-- Sort cooldowns by priority
function CT:SortCooldownsByPriority()
    table.sort(self.activeFrames, function(a, b)
        return (a.priority or PRIORITY.LOW) < (b.priority or PRIORITY.LOW)
    end)
end

-- Batched update function for cooldowns
function CT:UpdateCooldownBatch(batchIndex, batchSize)
    if not self.activeFrames or #self.activeFrames == 0 then
        return
    end
    
    local options = GetCurrentOptions()
    local cdText = options.cooldownText
    
    if not cdText.enabled then return end
    
    local startIndex = ((batchIndex - 1) * batchSize) + 1
    local endIndex = math.min(startIndex + batchSize - 1, #self.activeFrames)
    local currentTime = GetTime()
    local inCombat = InCombatLockdown()
    local performanceMode = options.performanceMode
    
    -- Process cooldowns in the current batch
    for i = startIndex, endIndex do
        local frame = self.activeFrames[i]
        if frame and frame.startTime and frame.duration then
            local timeLeft = (frame.startTime + frame.duration) - currentTime
            
            -- Determine if this cooldown needs an update based on priority
            local needsUpdate = true
            
            -- Skip updates for distant cooldowns in performance mode
            if performanceMode and inCombat and frame.priority == PRIORITY.LOW then
                -- Update low priority frames less frequently in combat
                needsUpdate = (not frame.lastUpdateTime or 
                             (currentTime - frame.lastUpdateTime) >= THROTTLE_COMBAT)
            end
            
            if needsUpdate then
                -- Update the cooldown text if needed
                if timeLeft > 0 then
                    local formattedTime = FormatTimeText(timeLeft)
                    frame.text:SetText(formattedTime)
                    
                    -- Change color for expiring cooldowns
                    if timeLeft < cdText.expiringDuration then
                        frame.text:SetTextColor(
                            cdText.expiringColor.r or 1, 
                            cdText.expiringColor.g or 0, 
                            cdText.expiringColor.b or 0, 
                            cdText.expiringColor.a or 1
                        )
                    else
                        frame.text:SetTextColor(
                            cdText.normalColor.r or 1, 
                            cdText.normalColor.g or 1, 
                            cdText.normalColor.b or 1, 
                            cdText.normalColor.a or 1
                        )
                    end
                    
                    -- Update priority based on current time left
                    frame.priority = GetCooldownPriority(frame)
                else
                    -- Cooldown has expired
                    frame.text:SetText("")
                    
                    -- Play finish animation if enabled
                    if cdText.finishEffects and cdText.finishEffects.enableFlash and not frame.played and frame.flashAnim then
                        local color = cdText.finishEffects.flashColor or {r = 1, g = 1, b = 1, a = 0.7}
                        frame.flash:SetVertexColor(color.r, color.g, color.b, color.a)
                        frame.flashAnim:Play()
                        frame.played = true
                    end
                    
                    -- Mark for recycling
                    frame.priority = PRIORITY.LOW
                end
                
                -- Update last update time
                frame.lastUpdateTime = currentTime
            end
        end
    end
    
    -- Schedule the next batch
    local nextBatch = batchIndex + 1
    if nextBatch * batchSize > #self.activeFrames then
        -- All batches processed, re-sort by priority for next update cycle
        self:SortCooldownsByPriority()
        
        -- Determine next update frequency based on highest priority cooldown
        local nextUpdateDelay = UPDATE_INTERVAL_DISTANT
        
        if self.activeFrames[1] and self.activeFrames[1].priority then
            if self.activeFrames[1].priority == PRIORITY.HIGH then
                nextUpdateDelay = UPDATE_INTERVAL_EXPIRING
            elseif self.activeFrames[1].priority == PRIORITY.MEDIUM then
                nextUpdateDelay = UPDATE_INTERVAL
            end
        end
        
        -- Adjust for performance mode in combat
        if performanceMode and inCombat then
            nextUpdateDelay = nextUpdateDelay * 1.5
        end
        
        -- Schedule next full update
        if #self.activeFrames > 0 then
            C_Timer.After(nextUpdateDelay, function() self:StartBatchedUpdate() end)
        else
            self.updateTimerRunning = false
        end
    else
        -- Process next batch immediately
        C_Timer.After(0.001, function() self:UpdateCooldownBatch(nextBatch, batchSize) end)
    end
end

-- Start cooldown update process with batches
function CT:StartBatchedUpdate()
    self:UpdateCooldownBatch(1, BATCH_SIZE)
    self.updateTimerRunning = true
end

-- Ensure the update timer is running
function CT:EnsureUpdateTimerRunning()
    if not self.updateTimerRunning and #self.activeFrames > 0 then
        self:StartBatchedUpdate()
    end
end

-- Update all cooldowns immediately (for settings changes)
function CT:UpdateAllCooldowns(immediate)
    if immediate then
        for _, frame in ipairs(self.activeFrames) do
            frame.lastUpdateTime = nil
        end
        self:StartBatchedUpdate()
    else
        self:EnsureUpdateTimerRunning()
    end
end

-- Cleanup stale cooldowns
function CT:CleanupStaleCooldowns()
    local currentTime = GetTime()
    local i = 1
    
    while i <= #self.activeFrames do
        local frame = self.activeFrames[i]
        
        if frame and frame.startTime and frame.duration then
            local timeLeft = (frame.startTime + frame.duration) - currentTime
            
            -- Remove expired cooldowns that have played their finish animation
            if timeLeft <= -1 and frame.played then
                table.remove(self.activeFrames, i)
                self:RecycleFrame(frame)
            else
                i = i + 1
            end
        else
            -- Remove invalid frames
            table.remove(self.activeFrames, i)
            if frame then
                self:RecycleFrame(frame)
            end
        end
    end
    
    -- Run cleanup every 2 seconds
    C_Timer.After(2, function() self:CleanupStaleCooldowns() end)
end

-- Main module initialization
function CT:OnInitialize()
    -- Initialize cooldown tracking
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:CleanupStaleCooldowns()
    end)
    
    -- Configure performance monitoring
    self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        -- Entering combat - adjust update frequency
        self:UpdateAllCooldowns(true)
    end)
    
    self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        -- Leaving combat - restore normal update frequency
        self:UpdateAllCooldowns(true)
    end)
end

-- Hook into cooldown functions to detect when cooldowns start
function CT:HookCooldowns()
    local options = GetCurrentOptions()
    if not options.enabled or not options.cooldownText.enabled then return end
    
    -- Hook Cooldown_OnSetCooldown - main method used by Blizzard for setting cooldowns
    hooksecurefunc(Cooldown, "SetCooldown", function(cooldown, startTime, duration, modRate)
        if startTime <= 0 or duration <= 0 or duration < MIN_DURATION then return end
        
        -- Skip frames we should ignore
        if cooldown.noCooldownCount then return end
        
        -- Only show countdown on reasonably sized frames
        local width, height = cooldown:GetSize()
        if width < 16 or height < 16 then return end
        
        -- Configure the cooldown display
        self:ConfigureFrame(self:GetFrame(), startTime, duration, cooldown)
    end)
    
    -- Set up update timer
    if not self.timers.update then
        self.timers.update = C_Timer.NewTicker(UPDATE_INTERVAL, function() 
            self:UpdateAllCooldowns()
        end)
    end
end

function CT:OnEnable()
    local options = GetCurrentOptions()
    
    -- Only proceed if we're enabled
    if not options.enabled then return end
    
    -- Set up cooldown hooks
    self:HookCooldowns()
    
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    
    -- Debug info
    Phoenix_UI:Debug("CooldownTracker enabled")
end

function CT:OnDisable()
    -- Cancel all timers
    if self.timers.update then
        self.timers.update:Cancel()
        self.timers.update = nil
    end
    
    -- Clear all active frames
    for cooldown, frame in pairs(self.activeFrames) do
        self:RecycleFrame(frame)
    end
    self.activeFrames = {}
    
    -- Unregister events
    self:UnregisterAllEvents()
    
    -- Debug info
    Phoenix_UI:Debug("CooldownTracker disabled")
end

function CT:PLAYER_ENTERING_WORLD()
    -- Force a refresh of all cooldowns
    self:UpdateAllCooldowns(true)
end

function CT:ADDON_LOADED(event, addon)
    if addon == "Phoenix_UI" then
        -- Double-check settings once our addon is fully loaded
        self:UpdateSettings()
    end
end

-- Update settings from UI
function CT:UpdateSettings()
    local options = GetCurrentOptions()
    
    -- Enable or disable based on settings
    if options.enabled and not self:IsEnabled() then
        self:Enable()
    elseif not options.enabled and self:IsEnabled() then
        self:Disable()
    end
    
    -- Update all cooldown frames if we're enabled
    if self:IsEnabled() then
        self:UpdateAllCooldowns(true)
    end
end

-- Expose a method for the config panel to call
Phoenix_UI.UpdateCooldownTracker = function()
    if CT and CT.UpdateSettings then
        CT:UpdateSettings()
    end
end

function CT:OnInitialize()
    -- Register our submodules
    self:RegisterModule("PartyCD")
    self:RegisterModule("RaidTimeline")
    
    -- Initialize modules
    self:InitializeTracker()
    self:InitializeIconTracker()
    self:InitializeBarTracker()
    self:InitializeRaidTimeline() -- Initialize the RaidTimeline module
end

-- Default configuration options
function CT:GetDefaultOptions()
    return {
        -- ... existing code ...
        
        -- Party cooldown tracking
        partyCD = {
            enabled = true,
            showInCombatOnly = false,
            iconSize = 30,
            showTooltip = true,
            position = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = 0,
            },
            filterByClass = false,
            showOnlyImportant = true
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
            },
            initialValue = {
                width = 300,
                height = 150,
                minDisplayTime = 60
            }
        },
        
        -- ... existing code ...
    }
end 