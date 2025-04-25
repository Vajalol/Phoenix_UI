local Module = Phoenix_UI:NewModule("Maps.Coords");

function Module:OnEnable()
	local db = Phoenix_UI.db.profile.maps
	if db.coords then
		-- Create improved world map coordinates
		local coords = CreateFrame("Frame", "Phoenix_UI_CoordsFrame", WorldMapFrame)
		coords:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
		coords:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		
		-- Create panel background for better visibility
		coords.bg = coords:CreateTexture(nil, "BACKGROUND")
		coords.bg:SetColorTexture(0, 0, 0, 0.5)
		coords.bg:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer, "BOTTOM", -60, 5)
		coords.bg:SetPoint("TOPRIGHT", WorldMapFrame.ScrollContainer, "BOTTOM", 70, 40)
		
		-- Enhanced player coordinates text
		coords.PlayerText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		coords.PlayerText:SetPoint("BOTTOM", WorldMapFrame.ScrollContainer, "BOTTOM", 5, 20)
		coords.PlayerText:SetJustifyH("LEFT")
		coords.PlayerText:SetText(UnitName("player") .. ": 0,0")
		-- Add highlight color based on theme
		if Phoenix_UI.themeColors and Phoenix_UI.themeColors.highlight then
			coords.PlayerText:SetTextColor(
				Phoenix_UI.themeColors.highlight.r or 1,
				Phoenix_UI.themeColors.highlight.g or 0.82,
				Phoenix_UI.themeColors.highlight.b or 0,
				1
			)
		end

		-- Enhanced mouse coordinates text
		coords.MouseText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		coords.MouseText:SetJustifyH("LEFT")
		coords.MouseText:SetPoint("BOTTOMLEFT", coords.PlayerText, "TOPLEFT", 0, 5)
		coords.MouseText:SetText(": 0,0")
		
		-- Copy button for easy coordinate copying
		coords.CopyButton = CreateFrame("Button", nil, coords)
		coords.CopyButton:SetSize(16, 16)
		coords.CopyButton:SetPoint("LEFT", coords.bg, "LEFT", 5, 0)
		coords.CopyButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
		coords.CopyButton:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
		coords.CopyButton:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Copy Coordinates")
			GameTooltip:Show()
		end)
		coords.CopyButton:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		coords.CopyButton:SetScript("OnClick", function()
			-- Get current coordinates text without the player name
			local coordText = coords.PlayerText:GetText():match(": (.+)") or "0,0"
			-- Copy to clipboard if available
			if ChatEdit_GetActiveWindow() then
				ChatEdit_InsertLink(coordText)
			else
				-- Open chat and insert
				ChatFrame_OpenChat(coordText)
			end
		end)

		-- Optimized update frequency
		local updateFrequency = 0.2 -- Update 5 times per second
		local int = 0
		
		WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
			int = int + elapsed
			if int >= updateFrequency then
				local UnitMap = C_Map.GetBestMapForUnit("player")
				local x, y = 0, 0

				if UnitMap then
					local GetPlayerMapPosition = C_Map.GetPlayerMapPosition(UnitMap, "player")
					if GetPlayerMapPosition then
						x, y = GetPlayerMapPosition:GetXY()
					end
				end

				-- Format coordinates with proper precision
				local precision = db.coordPrecision or 1
				local formatString = "%." .. precision .. "f,%." .. precision .. "f"
				
				x = math.floor(100 * x * 10^precision) / 10^precision
				y = math.floor(100 * y * 10^precision) / 10^precision
				
				if x ~= 0 and y ~= 0 then
					coords.PlayerText:SetText(UnitName("player") .. ": " .. string.format(formatString, x, y))
				else
					coords.PlayerText:SetText(UnitName("player") .. ": " .. "|cffff0000" .. "|r")
				end

				local scale = WorldMapFrame.ScrollContainer:GetEffectiveScale()
				local width = WorldMapFrame.ScrollContainer:GetWidth()
				local height = WorldMapFrame.ScrollContainer:GetHeight()
				local centerX, centerY = WorldMapFrame.ScrollContainer:GetCenter()
				local x, y = GetCursorPosition()
				local adjustedX = (x / scale - (centerX - (width / 2))) / width
				local adjustedY = (centerY + (height / 2) - y / scale) / height

				if adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1 then
					adjustedX = math.floor(100 * adjustedX * 10^precision) / 10^precision
					adjustedY = math.floor(100 * adjustedY * 10^precision) / 10^precision
					coords.MouseText:SetText("Mouse: " .. string.format(formatString, adjustedX, adjustedY))
				else
					coords.MouseText:SetText("|cffff0000" .. "|r")
				end
				int = 0
			end
		end)
		
		-- Add minimap coordinates if enabled
		if db.minimapCoords then
			-- Create minimap coordinates frame with improved styling
			local minimapCoords = CreateFrame("Frame", "Phoenix_UI_MinimapCoords", Minimap)
			minimapCoords:SetFrameLevel(Minimap:GetFrameLevel() + 10)
			minimapCoords:SetSize(80, 20)
			minimapCoords:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 2)
			
			-- Create nicer background with rounded corners
			minimapCoords.bg = CreateFrame("Frame", nil, minimapCoords, BackdropTemplateMixin and "BackdropTemplate")
			minimapCoords.bg:SetAllPoints()
			minimapCoords.bg:SetBackdrop({
				bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
				edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
				edgeSize = 1,
				insets = { left = 1, right = 1, top = 1, bottom = 1 }
			})
			minimapCoords.bg:SetBackdropColor(0, 0, 0, 0.6)
			minimapCoords.bg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
			
			-- Create text with theme-based coloring
			minimapCoords.text = minimapCoords:CreateFontString(nil, "OVERLAY")
			if Phoenix_UI.Media and Phoenix_UI.Media.Fonts and Phoenix_UI.Media.Fonts.Normal then
				minimapCoords.text:SetFont(Phoenix_UI.Media.Fonts.Normal, 10, "OUTLINE")
			else
				minimapCoords.text:SetFontObject(GameFontNormalSmall)
			end
			minimapCoords.text:SetPoint("CENTER")
			minimapCoords.text:SetText("00.0, 00.0")
			
			-- Apply theme colors if available
			if Phoenix_UI.themeColors and Phoenix_UI.themeColors.highlight then
				minimapCoords.text:SetTextColor(
					Phoenix_UI.themeColors.highlight.r or 1,
					Phoenix_UI.themeColors.highlight.g or 0.82,
					Phoenix_UI.themeColors.highlight.b or 0,
					1
				)
			end
			
			-- Make coordinates clickable to copy
			minimapCoords:EnableMouse(true)
			minimapCoords:SetScript("OnEnter", function(self)
				-- Highlight effect on hover
				minimapCoords.bg:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
				minimapCoords.bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
				
				-- Show tooltip
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:AddLine("Click to copy coordinates")
				GameTooltip:Show()
			end)
			
			minimapCoords:SetScript("OnLeave", function(self)
				-- Reset highlight
				minimapCoords.bg:SetBackdropColor(0, 0, 0, 0.6)
				minimapCoords.bg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
				
				-- Hide tooltip
				GameTooltip:Hide()
			end)
			
			minimapCoords:SetScript("OnMouseDown", function(self)
				-- Visual feedback
				self:SetScale(0.98)
				minimapCoords.bg:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
			end)
			
			minimapCoords:SetScript("OnMouseUp", function(self)
				-- Reset scale
				self:SetScale(1.0)
				minimapCoords.bg:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
				
				-- Copy coordinates to clipboard
				local coordText = minimapCoords.text:GetText()
				if coordText and coordText ~= "n/a" then
					-- Copy to clipboard if available
					if ChatEdit_GetActiveWindow() then
						ChatEdit_InsertLink(coordText)
					else
						-- Open chat and insert
						ChatFrame_OpenChat(coordText)
					end
					-- Visual feedback for successful copy
					UIFrameFlash(minimapCoords, 0.1, 0.1, 0.2, false, 0.1)
				end
			end)
			
			-- Optimized update with debouncing
			local minimapUpdateFreq = 0.2 -- 5 updates per second
			local minimapElapsed = 0
			local lastCoordText = ""
			
			minimapCoords:SetScript("OnUpdate", function(self, elapsed)
				minimapElapsed = minimapElapsed + elapsed
				if minimapElapsed >= minimapUpdateFreq then
					local uiMapID = C_Map.GetBestMapForUnit("player")
					if uiMapID then
						local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
						if position then
							local x, y = position:GetXY()
							-- Format with proper precision
							local precision = db.coordPrecision or 1
							local formatString = "%." .. precision .. "f, %." .. precision .. "f"
							x = math.floor(x * 100 * 10^precision) / 10^precision
							y = math.floor(y * 100 * 10^precision) / 10^precision
							
							-- Only update text if coordinates have changed (reduces CPU usage)
							local newCoordText = string.format(formatString, x, y)
							if newCoordText ~= lastCoordText then
								self.text:SetFormattedText(formatString, x, y)
								lastCoordText = newCoordText
							end
						else
							if lastCoordText ~= "n/a" then
								self.text:SetText("n/a")
								lastCoordText = "n/a"
							end
						end
					else
						if lastCoordText ~= "n/a" then
							self.text:SetText("n/a")
							lastCoordText = "n/a"
						end
					end
					minimapElapsed = 0
				end
			end)
			
			-- Smooth fade animation for mouseover
			if db.minimapCoordsOnHover then
				-- Create fade animation
				minimapCoords.fadeIn = minimapCoords:CreateAnimationGroup()
				local fadeIn = minimapCoords.fadeIn:CreateAnimation("Alpha")
				fadeIn:SetFromAlpha(0)
				fadeIn:SetToAlpha(1)
				fadeIn:SetDuration(0.3)
				fadeIn:SetSmoothing("OUT")
				
				minimapCoords.fadeOut = minimapCoords:CreateAnimationGroup()
				local fadeOut = minimapCoords.fadeOut:CreateAnimation("Alpha")
				fadeOut:SetFromAlpha(1)
				fadeOut:SetToAlpha(0)
				fadeOut:SetDuration(0.5)
				fadeOut:SetSmoothing("OUT")
				
				minimapCoords.fadeOut:SetScript("OnFinished", function()
					minimapCoords:SetAlpha(0)
				end)
				
				-- Initial state
				minimapCoords:SetAlpha(0)
				
				-- Improved handling of mouseOver
				Minimap:HookScript("OnEnter", function()
					-- Cancel any in-progress animations
					if minimapCoords.fadeOut:IsPlaying() then
						minimapCoords.fadeOut:Stop()
					end
					
					minimapCoords:SetAlpha(0)
					minimapCoords.fadeIn:Play()
				end)
				
				Minimap:HookScript("OnLeave", function()
					-- Use delayed fade out to prevent flickering
					C_Timer.After(0.5, function()
						if not MouseIsOver(Minimap) and not MouseIsOver(minimapCoords) then
							-- Cancel any in-progress animations
							if minimapCoords.fadeIn:IsPlaying() then
								minimapCoords.fadeIn:Stop()
							end
							
							minimapCoords.fadeOut:Play()
						end
					end)
				end)
				
				-- Also handle mouse over the coordinates itself
				minimapCoords:HookScript("OnEnter", function()
					if minimapCoords.fadeOut:IsPlaying() then
						minimapCoords.fadeOut:Stop()
					end
					
					minimapCoords:SetAlpha(1)
				end)
				
				minimapCoords:HookScript("OnLeave", function()
					C_Timer.After(0.5, function()
						if not MouseIsOver(Minimap) and not MouseIsOver(minimapCoords) then
							-- Cancel any in-progress animations
							if minimapCoords.fadeIn:IsPlaying() then
								minimapCoords.fadeIn:Stop()
							end
							
							minimapCoords.fadeOut:Play()
						end
					end)
				end)
			end
		end
	end
end



