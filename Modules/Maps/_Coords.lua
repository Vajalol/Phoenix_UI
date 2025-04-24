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
			-- Create minimap coordinates frame
			local minimapCoords = CreateFrame("Frame", "Phoenix_UI_MinimapCoords", Minimap)
			minimapCoords:SetFrameLevel(Minimap:GetFrameLevel() + 10)
			minimapCoords:SetSize(80, 20)
			minimapCoords:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 2)
			
			-- Create background
			minimapCoords.bg = minimapCoords:CreateTexture(nil, "BACKGROUND")
			minimapCoords.bg:SetAllPoints()
			minimapCoords.bg:SetColorTexture(0, 0, 0, 0.5)
			
			-- Create text
			minimapCoords.text = minimapCoords:CreateFontString(nil, "OVERLAY")
			minimapCoords.text:SetFontObject(GameFontNormalSmall)
			minimapCoords.text:SetPoint("CENTER")
			minimapCoords.text:SetText("00.0, 00.0")
			
			-- Optimized update
			local minimapUpdateFreq = 0.2 -- 5 updates per second
			local minimapElapsed = 0
			
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
							self.text:SetFormattedText(formatString, x, y)
						else
							self.text:SetText("n/a")
						end
					else
						self.text:SetText("n/a")
					end
					minimapElapsed = 0
				end
			end)
			
			-- Show/hide based on mouseover if configured
			if db.minimapCoordsOnHover then
				minimapCoords:SetAlpha(0)
				Minimap:HookScript("OnEnter", function()
					minimapCoords:SetAlpha(1)
				end)
				Minimap:HookScript("OnLeave", function()
					-- Use delayed fade out to prevent flickering
					C_Timer.After(0.5, function()
						if not MouseIsOver(Minimap) then
							minimapCoords:SetAlpha(0)
						end
					end)
				end)
			end
		end
	end
end



