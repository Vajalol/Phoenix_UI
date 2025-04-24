local _, addon = ...

---@class Display
local Display = {}
addon.Display = Display

-- Add healer-oriented display enhancement
Display.IsHealerFrame = function(frame)
    -- Fast detection for common healer addons
    local frameName = frame and frame:GetName() or ""
    if frameName then
        -- Check if this is a healer addon frame based on name patterns
        if frameName:match("Vd%d+") or           -- VuhDo
           frameName:match("^Grid2LayoutHeader") or  -- Grid2
           frameName:match("^HealBot") or        -- HealBot
           frameName:match("^SUFHeader") or      -- ShadowUF raid frames
           frameName:match("^ElvUF_Raid") then   -- ElvUI raid frames
            return true
        end
    end
    
    -- For frames without obvious names, check other properties
    local unitId = frame.unit or (frame.GetAttribute and frame:GetAttribute("unit"))
    if unitId and (unitId:find("raid") or unitId:find("party")) then
        return true
    end
    
    return false
end

-- Enhanced priority system that considers frame type and context
Display.GetEnhancedPriority = function(spellId, frame, unitId)
    local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")
    local priority = BuffOverlay.defaultSpells[spellId] or 0
    
    -- If this is a healer frame, boost priority of certain spell types
    if Display.IsHealerFrame(frame) and BuffOverlay.PvECategories then
        -- In PvE context, prioritize tank CDs and healing cooldowns on raid/party frames
        if addon.Inspect and addon.Inspect.IsUnitTank and addon.Inspect:IsUnitTank(unitId) then
            -- Boost tank cooldown visibility on tank frames
            if priority >= BuffOverlay.PvECategories.TANK_CD then
                return priority + 2
            end
        end
        
        -- Boost healing cooldown priority on all raid/party frames
        if priority >= BuffOverlay.PvECategories.HEAL_PRIORITY then
            return priority + 2
        end
        
        -- Boost dangerous dungeon/raid mechanic visibility
        if priority >= BuffOverlay.PvECategories.DUNGEON_DANGEROUS or
           priority >= BuffOverlay.PvECategories.RAID_CRITICAL then
            return priority + 1
        end
    end
    
    return priority
end

-- Function to enhance aura visibility based on context
Display.ShouldEnhanceAura = function(spellId, frame, unitId)
    -- Skip if we don't have the PvE categories
    local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")
    if not BuffOverlay.PvECategories then return false end
    
    -- Get player specialization to highlight relevant spells
    local _, playerClass = UnitClass("player")
    local isHealer = false
    
    if GetSpecialization then
        local specIndex = GetSpecialization()
        if specIndex then
            local role = select(5, GetSpecializationInfo(specIndex))
            isHealer = (role == "HEALER")
        end
    end
    
    -- Only enhance display for healers
    if not isHealer then return false end
    
    -- Check if this is a healer-relevant spell in our PvE priority system
    for id, info in pairs(BuffOverlay.PvESpells or {}) do
        if id == spellId then
            -- Highly prioritize tank CDs and healing CDs
            if info.priority and (
                info.priority >= BuffOverlay.PvECategories.TANK_CD or
                info.priority >= BuffOverlay.PvECategories.HEAL_PRIORITY or
                (info.mechanic and info.priority >= BuffOverlay.PvECategories.DUNGEON_DANGEROUS)
            ) then
                return true
            end
        end
    end
    
    return false
end

-- Original code starts here
-- ... existing code ...

-- Enhance the CreateOverlayFrame function to use our new priority system
local CreateOverlayFrame_Original = Display.CreateOverlayFrame
Display.CreateOverlayFrame = function(self, parent, unit, spellID, options)
    -- Use the original function to create the frame
    local frame = CreateOverlayFrame_Original(self, parent, unit, spellID, options)
    if not frame then return nil end
    
    -- Apply enhanced priority if applicable
    local enhancedPriority = Display.GetEnhancedPriority(spellID, parent, unit)
    if enhancedPriority > (options.priority or 0) then
        options.priority = enhancedPriority
        
        -- Apply visual enhancements for high priority spells
        if Display.ShouldEnhanceAura(spellID, parent, unit) then
            -- Make more visible with larger size and border
            frame:SetScale(frame:GetScale() * 1.2)
            
            -- Add a glowing border for important spells if not already present
            if not frame.enhancedGlow and LibStub and LibStub("LibCustomGlow-1.0", true) then
                local LCG = LibStub("LibCustomGlow-1.0")
                LCG.ButtonGlow_Start(frame)
                frame.enhancedGlow = true
                
                -- Stop the glow when the frame is hidden
                frame:HookScript("OnHide", function()
                    if frame.enhancedGlow and LCG then
                        LCG.ButtonGlow_Stop(frame)
                        frame.enhancedGlow = nil
                    end
                end)
            end
        end
    end
    
    return frame
end 