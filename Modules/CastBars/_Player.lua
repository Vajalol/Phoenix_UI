local Module = Phoenix_UI:NewModule("CastBars.Player");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.castbars

    if (db.style == 'Custom') then
        -- Create latency indicator
        local latencyIndicator = PlayerCastingBarFrame:CreateTexture(nil, "OVERLAY")
        latencyIndicator:SetColorTexture(1, 0, 0, 0.5) -- Red with 50% opacity
        latencyIndicator:Hide()
        
        -- Create target text
        local targetText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY")
        targetText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        targetText:SetPoint("RIGHT", PlayerCastingBarFrame, "RIGHT", -5, 0)
        targetText:SetTextColor(0.8, 0.8, 0.8)
        targetText:Hide()
        
        -- Create latency text
        local latencyText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY")
        latencyText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        latencyText:SetPoint("LEFT", PlayerCastingBarFrame, "LEFT", 5, 0)
        latencyText:SetTextColor(1, 0.7, 0)
        latencyText:Hide()
        
        -- Store these elements on the castbar frame
        PlayerCastingBarFrame.latencyIndicator = latencyIndicator
        PlayerCastingBarFrame.targetText = targetText
        PlayerCastingBarFrame.latencyText = latencyText
        
        -- Main hook for castbar updates
        PlayerCastingBarFrame:HookScript("OnEvent", function(self, event, ...)
            self.StandardGlow:Hide()
            self.TextBorder:Hide()
            self:SetSize(209, 18)
            self.TextBorder:ClearAllPoints()
            self.TextBorder:SetAlpha(0)
            self.Border:ClearAllPoints()
            self.Border:SetAlpha(0)
            self.Text:ClearAllPoints()
            self.Text:SetPoint("TOP", self, "TOP", 0, -1)
            self.Text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")

            if Phoenix_UI:Color() then
                self.Background:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
            end

            if db.icon then
                self.Icon:Show()
                self.Icon:SetSize(20, 20)
            end
            
            -- Update latency indicator if enabled
            if event == "UNIT_SPELLCAST_START" and db.showLatency then
                local unit = ...
                if unit == "player" then
                    -- Get player's current latency
                    local _, _, _, latencyMS = GetNetStats()
                    
                    -- Calculate cast time and position for latency indicator
                    local castTime = select(5, UnitCastingInfo("player")) or 0
                    local startTime = select(4, UnitCastingInfo("player")) or 0
                    local endTime = startTime + castTime
                    
                    if castTime > 0 then
                        -- Calculate the width percentage for latency
                        local latencyWidth = self:GetWidth() * (latencyMS / 1000) / (castTime / 1000)
                        
                        -- Position and size the latency indicator
                        latencyIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
                        latencyIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
                        latencyIndicator:SetWidth(latencyWidth)
                        latencyIndicator:Show()
                        
                        -- Update latency text
                        latencyText:SetText(string.format("%dms", latencyMS))
                        latencyText:Show()
                    end
                end
            elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
                latencyIndicator:Hide()
                latencyText:Hide()
                targetText:Hide()
            end
            
            -- Show target of cast if available and enabled
            if event == "UNIT_SPELLCAST_START" and db.showTarget then
                local unit = ...
                if unit == "player" then
                    -- Get the target of the spell if available
                    local unitTarget = "target"
                    if UnitExists(unitTarget) then
                        local name = UnitName(unitTarget)
                        if name then
                            -- Format target name (limit length if needed)
                            if strlen(name) > 12 then
                                name = strsub(name, 1, 10) .. "..."
                            end
                            
                            -- Colorize by reaction
                            local _, class = UnitClass(unitTarget)
                            if UnitIsPlayer(unitTarget) and class and RAID_CLASS_COLORS[class] then
                                local color = RAID_CLASS_COLORS[class]
                                targetText:SetText(string.format("|cff%02x%02x%02x%s|r", 
                                    color.r * 255, color.g * 255, color.b * 255, name))
                            else
                                -- NPC color by reaction
                                local reaction = UnitReaction(unitTarget, "player") or 4
                                local color = FACTION_BAR_COLORS[reaction] or {r=1, g=1, b=1}
                                targetText:SetText(string.format("|cff%02x%02x%02x%s|r", 
                                    color.r * 255, color.g * 255, color.b * 255, name))
                            end
                            
                            targetText:Show()
                        end
                    end
                end
            end
        end)
        
        -- Additional hook for OnUpdate to ensure latency is shown correctly
        PlayerCastingBarFrame:HookScript("OnUpdate", function(self, elapsed)
            -- Make sure our elements stay visible if enabled
            if db.showLatency and self.casting and self.latencyIndicator and not self.latencyIndicator:IsShown() then
                local _, _, _, latencyMS = GetNetStats()
                local castTime = select(5, UnitCastingInfo("player")) or 0
                local startTime = select(4, UnitCastingInfo("player")) or 0
                local endTime = startTime + castTime
                
                if castTime > 0 then
                    -- Calculate the width percentage for latency
                    local latencyWidth = self:GetWidth() * (latencyMS / 1000) / (castTime / 1000)
                    
                    -- Position and size the latency indicator
                    self.latencyIndicator:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
                    self.latencyIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
                    self.latencyIndicator:SetWidth(latencyWidth)
                    self.latencyIndicator:Show()
                    
                    -- Update latency text
                    self.latencyText:SetText(string.format("%dms", latencyMS))
                    self.latencyText:Show()
                end
            end
            
            -- Hide elements when not casting
            if not self.casting and not self.channeling then
                if self.latencyIndicator then self.latencyIndicator:Hide() end
                if self.latencyText then self.latencyText:Hide() end
                if self.targetText then self.targetText:Hide() end
            end
        end)
    end
end



