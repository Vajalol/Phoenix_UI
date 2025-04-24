-- Phoenix_UI CooldownTracker - Frame Pool Module
local addonName, Phoenix = ...

-- Get the main module
local CT = Phoenix_UI:GetModule("CooldownTracker")
if not CT then return end

-- Create the frame pool module
local FramePool = CT:NewModule("FramePool")

-- Initialize variables
local activePools = {}
local frameCounter = 0

-- Default pool size
local DEFAULT_POOL_SIZE = 50

-- Create a new pool of frames
function FramePool:CreatePool(name, parent, frameTemplate, initialSize)
    if activePools[name] then
        return activePools[name]
    end
    
    initialSize = initialSize or DEFAULT_POOL_SIZE
    
    local pool = {
        name = name,
        parent = parent,
        template = frameTemplate,
        active = {},
        inactive = {},
        count = 0
    }
    
    -- Pre-create frames
    for i = 1, initialSize do
        local frame = self:CreateFrame(pool)
        frame:Hide()
        table.insert(pool.inactive, frame)
        pool.count = pool.count + 1
    end
    
    activePools[name] = pool
    CT:Debug("Created frame pool: " .. name .. " with " .. initialSize .. " frames")
    
    return pool
end

-- Create a single frame for a pool
function FramePool:CreateFrame(pool)
    frameCounter = frameCounter + 1
    local frameName = "PhoenixCDT_" .. pool.name .. frameCounter
    
    local frame
    if pool.template then
        frame = CreateFrame("Frame", frameName, pool.parent, pool.template)
    else
        frame = CreateFrame("Frame", frameName, pool.parent)
    end
    
    -- Store the pool reference
    frame.pool = pool
    
    -- Setup basic frame properties
    frame:SetSize(36, 36) -- Default size
    
    -- Text for cooldown
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetPoint("CENTER")
    
    -- Setup cooldown model
    frame.cooldown = CreateFrame("Cooldown", frameName .. "Cooldown", frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    
    -- Flash animation for finish effect
    frame.flash = frame:CreateTexture(nil, "OVERLAY")
    frame.flash:SetAllPoints()
    frame.flash:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    frame.flash:SetBlendMode("ADD")
    frame.flash:SetAlpha(0)
    
    -- Flash animation group
    frame.flashAnim = frame:CreateAnimationGroup()
    frame.flashAnim:SetLooping("NONE")
    
    local fadeIn = frame.flashAnim:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.3)
    fadeIn:SetOrder(1)
    
    local fadeOut = frame.flashAnim:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(2)
    
    -- Animation callbacks
    frame.flashAnim:SetScript("OnPlay", function()
        frame.flash:Show()
    end)
    
    frame.flashAnim:SetScript("OnFinished", function()
        frame.flash:Hide()
    end)
    
    -- Method to play flash animation
    frame.PlayFlash = function(self, r, g, b, a, duration)
        -- Set color if provided
        if r and g and b then
            self.flash:SetVertexColor(r, g, b, a or 1)
        end
        
        -- Set duration if provided
        if duration then
            local fadeIn = self.flashAnim:GetAnimations()
            local fadeOut = select(2, self.flashAnim:GetAnimations())
            
            fadeIn:SetDuration(duration * 0.3)
            fadeOut:SetDuration(duration * 0.7)
        end
        
        -- Play the animation
        self.flashAnim:Play()
    end
    
    -- Reset method to prepare frame for reuse
    frame.Reset = function(self)
        self:ClearAllPoints()
        self:SetAlpha(1)
        self:SetScale(1)
        self.cooldown:Clear()
        self.text:SetText("")
        
        -- Stop animations
        if self.flashAnim:IsPlaying() then
            self.flashAnim:Stop()
        end
        
        -- Clear any stored data
        self.start = nil
        self.duration = nil
        self.charges = nil
        self.spellID = nil
        self.itemID = nil
        self.trackingType = nil
    end
    
    -- Return the frame
    return frame
end

-- Acquire a frame from the pool
function FramePool:Acquire(poolName)
    local pool = activePools[poolName]
    if not pool then
        CT:Debug("No pool named " .. poolName .. " exists, creating one")
        pool = self:CreatePool(poolName, UIParent)
    end
    
    local frame
    
    -- Get a frame from the inactive list
    if #pool.inactive > 0 then
        frame = table.remove(pool.inactive)
    else
        -- Create a new frame if needed
        CT:Debug("Pool " .. poolName .. " is empty, creating new frame")
        frame = self:CreateFrame(pool)
        pool.count = pool.count + 1
    end
    
    -- Reset the frame to a clean state
    frame:Reset()
    
    -- Add to active list
    table.insert(pool.active, frame)
    
    return frame
end

-- Release a frame back to the pool
function FramePool:Release(frame)
    if not frame or not frame.pool then return end
    
    local pool = frame.pool
    
    -- Remove from active list
    for i, activeFrame in ipairs(pool.active) do
        if activeFrame == frame then
            table.remove(pool.active, i)
            break
        end
    end
    
    -- Hide and reset the frame
    frame:Hide()
    frame:Reset()
    
    -- Add to inactive list
    table.insert(pool.inactive, frame)
end

-- Release all frames in a pool
function FramePool:ReleaseAll(poolName)
    local pool = activePools[poolName]
    if not pool then return end
    
    -- Move all active frames to inactive
    for i = #pool.active, 1, -1 do
        local frame = pool.active[i]
        self:Release(frame)
    end
    
    -- Ensure active table is empty
    wipe(pool.active)
end

-- Get pool statistics
function FramePool:GetPoolStats(poolName)
    local pool = activePools[poolName]
    if not pool then
        return nil
    end
    
    return {
        total = pool.count,
        active = #pool.active,
        inactive = #pool.inactive
    }
end

-- Clean up unused frames to save memory
function FramePool:CleanupUnused(poolName, maxInactive)
    local pool = activePools[poolName]
    if not pool then return end
    
    maxInactive = maxInactive or 20 -- Default maximum inactive frames to keep
    
    -- If we have too many inactive frames, remove the excess
    if #pool.inactive > maxInactive then
        local numToRemove = #pool.inactive - maxInactive
        
        for i = 1, numToRemove do
            local frame = table.remove(pool.inactive)
            frame:Hide()
            
            -- Let the garbage collector handle it
            for k in pairs(frame) do
                if type(frame[k]) == "table" then
                    wipe(frame[k])
                end
                frame[k] = nil
            end
            
            pool.count = pool.count - 1
        end
        
        CT:Debug("Cleaned up " .. numToRemove .. " unused frames from pool " .. poolName)
    end
end

-- Initialize module
function FramePool:OnInitialize()
    CT.FramePool = self
    
    -- Create the default cooldown frame pool
    self:CreatePool("CooldownFrames", UIParent, nil, DEFAULT_POOL_SIZE)
    
    -- Set up cleaning timer for memory management
    C_Timer.NewTicker(60, function()
        for poolName, _ in pairs(activePools) do
            self:CleanupUnused(poolName)
        end
    end)
end

-- Hook into CT module load
if CT.OnEnable then
    local originalOnEnable = CT.OnEnable
    CT.OnEnable = function(self, ...)
        -- Call original function
        originalOnEnable(self, ...)
        
        -- Initialize frame pool
        if self.FramePool then
            self.FramePool:OnInitialize()
        end
    end
end 