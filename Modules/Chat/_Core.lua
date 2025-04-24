local Module = Phoenix_UI:NewModule("Chat.Core");

function Module:OnEnable()
	local db = Phoenix_UI.db.profile.chat
	local ChatUtils = Phoenix_UI:GetModule("Chat.Utils")
	
	-- Ensure chat settings are properly initialized with defaults if missing
	if not db.history then
	    db.history = {
	        enabled = true,
	        lines = 500
	    }
	end
	
	if not db.expandedView then
	    db.expandedView = {
	        enabled = true
	    }
	end
	
	if not db.classSpec then
	    db.classSpec = {
	        enabled = true,
	        showIcons = true
	    }
	end
	
	-- Add special handling only for channels that need special treatment
	-- Let the Chat.Utils module handle general filtering for all chat types
	if not ChatUtils then
		-- Fallback if Chat.Utils is not available
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(self, event, message, sender, ...)
			-- Skip processing completely for trade messages with profession quality items
			if message and (message:find("Professions%-ChatlIcon%-Quality%-Tier") or 
			                message:find("|c%x+|Hitem:") or 
			                message:find("%[.*%]")) then
				-- Return the original message untouched
				return false, message, sender, ...
			end
			
			-- Let other filters handle normal messages
			return false, message, sender, ...
		end)
	else
		-- If ChatUtils exists, register a pre-filter for trade channel messages
		-- This ensures complex trade messages are handled correctly before emoji processing
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(self, event, message, sender, ...)
			local messageType = select(9, ...)
			
			-- Special handling for trade channel (type 2)
			if messageType == 2 then
				-- Skip emoji processing for item links, profession links, and other complex messages
				if message and (message:find("Professions%-ChatlIcon%-Quality%-Tier") or 
							   message:find("|c%x+|Hitem:") or 
							   message:find("|T") or
							   message:find("|H")) then
					return false
				end
			end
			
			-- Let other filters handle the message
			return false
		end)
	end
	
	-- Fix for message display in all chat types
	-- These are now handled centrally by the Chat.Utils module
	-- Removing to avoid duplicate registrations
	--[[
	for _, chatEvent in pairs({
	    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
	    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
	    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", 
	    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_BN_WHISPER",
	    "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_CHANNEL", "CHAT_MSG_BN_CONVERSATION"
	}) do
		ChatFrame_AddMessageEventFilter(chatEvent, function(self, event, message, sender, ...)
			-- Process only simple messages, skip any with complex formatting
			if message and (message:find("|c%x+|Hitem:") or 
			                message:find("Professions%-ChatlIcon%-Quality%-Tier") or
			                message:find("|T.*:.*|t")) then
				return false, message, sender, ...
			end
			
			return false, message, sender, ...
		end)
	end
	]]--
	
	-- Force save to ensure settings are persisted
	if Phoenix_UI.SaveDB then
	    C_Timer.After(1, function()
	        Phoenix_UI:SaveDB()
	    end)
	end
	
	if (db.style == 'Custom') then

		CHAT_FRAME_FADE_TIME = 0.3
		CHAT_FRAME_FADE_OUT_TIME = 1
		CHAT_TAB_HIDE_DELAY = 0.3
		CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
		--CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
		--CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
		--CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
		--CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0

		-- Initialize chat history storage if enabled
		if db.history and db.history.enabled then
			-- Create or ensure chat history table
			Phoenix_UI.chatHistory = Phoenix_UI.chatHistory or {}
			
			-- Set up chat message buffer size
			local maxHistoryLines = db.history.lines or 500
			for i = 1, NUM_CHAT_WINDOWS do
				if not Phoenix_UI.chatHistory[i] then
					Phoenix_UI.chatHistory[i] = {}
				end
				
				-- Limit history to configured maximum
				while #Phoenix_UI.chatHistory[i] > maxHistoryLines do
					table.remove(Phoenix_UI.chatHistory[i], 1)
				end
			end
			
			-- Function to store chat messages
			local function StoreChatMessage(self, event, text, ...)
				local chatFrame = self
				local chatID = chatFrame:GetID()
				
				-- Store in history (limited to maxHistoryLines)
				if Phoenix_UI.chatHistory[chatID] then
					-- Add message to history
					table.insert(Phoenix_UI.chatHistory[chatID], {text = text, timestamp = time()})
					
					-- Trim if exceeds max
					while #Phoenix_UI.chatHistory[chatID] > maxHistoryLines do
						table.remove(Phoenix_UI.chatHistory[chatID], 1)
					end
				end
				
				return false
			end
			
			-- Function to restore chat history
			local function RestoreChatHistory()
				for i = 1, NUM_CHAT_WINDOWS do
					local chat = _G[format("ChatFrame%s", i)]
					
					-- Only restore if we have history and the chat window exists
					if chat and Phoenix_UI.chatHistory[i] and #Phoenix_UI.chatHistory[i] > 0 then
						-- Start with a separator to indicate restored messages
						chat:AddMessage("|cFF999999----- Restored Chat History -----|r")
						
						-- Add each message from history
						for _, messageData in ipairs(Phoenix_UI.chatHistory[i]) do
							if messageData and messageData.text then
								-- Decompress message text if it's compressed (starts with marker bytes)
								local text = messageData.text
								if type(text) == "string" and text:sub(1, 2) == "\002\001" then
									-- Use the decompression function if available
									if Phoenix_UI.modules and Phoenix_UI.modules["Chat.Performance"] and 
									   Phoenix_UI.modules["Chat.Performance"].DecompressText then
										text = Phoenix_UI.modules["Chat.Performance"]:DecompressText(text)
									else
										-- Fallback decompression using LibDeflate
										local LibDeflate = LibStub and LibStub:GetLibrary("LibDeflate")
										if LibDeflate then
											local compressed = text:sub(3)
											local decompressed = LibDeflate:DecompressDeflate(compressed)
											if decompressed then
												text = decompressed
											end
										end
									end
								end
								
								chat:AddMessage(text)
							end
						end
						
						-- Add separator at the end
						chat:AddMessage("|cFF999999----- End of History -----|r")
					end
				end
			end
			
			-- Hook AddMessage to catch all messages for history
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				if chat then
					-- First hook to decompress compressed messages
					local originalAddMessage = chat.AddMessage
					chat.AddMessage = function(self, text, ...)
						-- Check if text is compressed (starts with marker bytes)
						if text and type(text) == "string" and text:sub(1, 2) == "\002\001" then
							-- Use the decompression function if available
							if Phoenix_UI.modules and Phoenix_UI.modules["Chat.Performance"] and 
							   Phoenix_UI.modules["Chat.Performance"].DecompressText then
								text = Phoenix_UI.modules["Chat.Performance"]:DecompressText(text)
							else
								-- Fallback decompression using LibDeflate
								local LibDeflate = LibStub and LibStub:GetLibrary("LibDeflate")
								if LibDeflate then
									local compressed = text:sub(3)
									local decompressed = LibDeflate:DecompressDeflate(compressed)
									if decompressed then
										text = decompressed
									end
								end
							end
						end
						
						-- Call the original AddMessage with decompressed text
						return originalAddMessage(self, text, ...)
					end
					
					-- Second hook to store messages in history
					hooksecurefunc(chat, "AddMessage", function(self, text, ...)
						-- Only store if it's not a history separator
						if not text:match("----- Restored Chat History -----") and 
						   not text:match("----- End of History -----") then
							StoreChatMessage(self, nil, text, ...)
						end
					end)
				end
			end
			
			-- Restore chat history on login
			RestoreChatHistory()
		end

		-- Set chat style
		local function SetChatStyle(frame)
			local id = frame:GetID()
			local chat = frame:GetName()

			_G[chat]:SetFrameLevel(5)

			-- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen
			_G[chat]:SetClampedToScreen(false)

			-- Stop the chat chat from fading out
			_G[chat]:SetFading(true)

			-- Move the chat edit box
			_G[chat .. "EditBox"]:ClearAllPoints()

			if (db.top) then
				_G[chat .. "EditBox"]:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -7, 25)
				_G[chat .. "EditBox"]:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 10, 25)
			else
				_G[chat .. "EditBox"]:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -7, -5)
				_G[chat .. "EditBox"]:SetPoint("TOPRIGHT", ChatFrame1, "BOTTOMRIGHT", 10, -5)
			end

			-- Hide textures
			for j = 1, #CHAT_FRAME_TEXTURES do
				if chat .. CHAT_FRAME_TEXTURES[j] ~= chat .. "Background" then
					_G[chat .. CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
				end
			end

			-- Removes Default ChatFrame Tabs texture
			_G[format("ChatFrame%sTab", id)].Left:SetTexture(nil)
			_G[format("ChatFrame%sTab", id)].Middle:SetTexture(nil)
			_G[format("ChatFrame%sTab", id)].Right:SetTexture(nil)

			_G[format("ChatFrame%sTab", id)].ActiveLeft:SetTexture(nil)
			_G[format("ChatFrame%sTab", id)].ActiveMiddle:SetTexture(nil)
			_G[format("ChatFrame%sTab", id)].ActiveRight:SetTexture(nil)

			_G[format("ChatFrame%sTab", id)].HighlightLeft:SetTexture(nil)
			_G[format("ChatFrame%sTab", id)].HighlightMiddle:SetTexture(nil)
			_G[format("ChatFrame%sTab", id)].HighlightRight:SetTexture(nil)

			-- Hiding off the new chat tab selected feature
			_G[format("ChatFrame%sButtonFrameMinimizeButton", id)]:Hide()
			_G[format("ChatFrame%sButtonFrame", id)]:Hide()

			-- Hides off the retarded new circle around the editbox
			_G[format("ChatFrame%sEditBoxLeft", id)]:Hide()
			_G[format("ChatFrame%sEditBoxMid", id)]:Hide()
			_G[format("ChatFrame%sEditBoxRight", id)]:Hide()

			_G[format("ChatFrame%sTabGlow", id)]:Hide()

			-- Hide scroll bar
			_G[format("ChatFrame%s", id)].ScrollBar.Back:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Forward:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.Begin:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.Middle:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.End:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.Thumb:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.Thumb.Begin:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.Thumb.Middle:Hide()
			_G[format("ChatFrame%s", id)].ScrollBar.Track.Thumb.End:Hide()

			-- Hide off editbox artwork
			local a, b, c = select(6, _G[chat .. "EditBox"]:GetRegions())
			a:Hide()
			b:Hide()
			c:Hide()

			-- Hide bubble tex/glow
			if _G[chat .. "Tab"].conversationIcon then _G[chat .. "Tab"].conversationIcon:Hide() end

			-- Disable alt key usage
			_G[chat .. "EditBox"]:SetAltArrowKeyMode(false)

			-- Hide editbox on login
			_G[chat .. "EditBox"]:Hide()

			-- Script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
			_G[chat .. "EditBox"]:HookScript("OnEditFocusGained", function(self) self:Show() end)
			_G[chat .. "EditBox"]:HookScript("OnEditFocusLost", function(self) if self:GetText() == "" then self:Hide() end end)

			-- Hide edit box every time we click on a tab
			_G[chat .. "Tab"]:HookScript("OnClick", function() _G[chat .. "EditBox"]:Hide() end)

			frame.skinned = true
		end

		-- Setup chatframes 1 to 10 on login
		local function SetupChat()
			for i = 1, NUM_CHAT_WINDOWS do
				local frame = _G[format("ChatFrame%s", i)]
				SetChatStyle(frame)
			end
		end

		local function SetupChatPosAndFont()
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local id = chat:GetID()
				local _, fontSize = FCF_GetChatWindowInfo(id)

				-- Min. size for chat font
				if fontSize < 11 then
					FCF_SetChatWindowFontSize(nil, chat, 11)
				else
					FCF_SetChatWindowFontSize(nil, chat, fontSize)
				end

				-- Font and font style for chat
				chat:SetFont(STANDARD_TEXT_FONT, fontSize, "")
			end
		end

		-- Setup temp chat (BN, WHISPER) when needed
		local function SetupTempChat()
			local frame = FCF_GetCurrentChatFrame()
			if frame.skinned then return end
			SetChatStyle(frame)
		end

		hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

		--	Loot icons
		if (db.looticons) then
			local function AddLootIcons(_, _, message, ...)
				-- Skip messages with profession quality info to prevent conflicts
				if message:find("Professions%-ChatlIcon%-Quality%-Tier") then
					return false, message, ...
				end
				
				local function Icon(link)
					local texture = GetItemIcon(link)
					return "\124T" .. texture .. ":12:12:0:0:64:64:5:59:5:59\124t" .. link
				end

				message = message:gsub("(\124c%x+\124Hitem:.-\124h\124r)", Icon)
				return false, message, ...
			end

			ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", AddLootIcons)
		end

		-- init
		SetupChat()
		SetupChatPosAndFont()
	end

	-- Apply theme styling to chat frames
	local function ApplyChatTheme(frame)
		-- Get current theme information
		local currentTheme = "Default"
		local theme = nil
		
		if Phoenix_UI.currentTheme then
			currentTheme = Phoenix_UI.currentTheme
			-- Get theme colors
			if Phoenix_UI.themes and Phoenix_UI.themes[currentTheme] then
				theme = Phoenix_UI.themes[currentTheme]
			end
		end
		
		-- Skip if no theme found
		if not theme then return end
		
		-- Check if we're using the Phoenix Flame theme
		local isPhoenixFlame = (currentTheme == "PhoenixFlame")
		
		-- Apply theme to chat frames
		if frame and frame.SetFont then
			-- Tab styling
			local tab = _G[frame:GetName().."Tab"]
			if tab then
				-- Apply theme-specific styling to tabs
				if tab.text then
					tab.text:SetTextColor(
						theme.colors.text.r or 1.0,
						theme.colors.text.g or 1.0,
						theme.colors.text.b or 1.0
					)
				end
				
				-- Special styling for Phoenix Flame theme
				if isPhoenixFlame and theme.colors.primary then
					-- Add glow effect to chat tabs
					if not tab.glowTexture then
						tab.glowTexture = tab:CreateTexture(nil, "BACKGROUND", nil, -1)
						tab.glowTexture:SetSize(tab:GetWidth() * 1.2, tab:GetHeight() * 1.2)
						tab.glowTexture:SetPoint("CENTER", tab, "CENTER", 0, 0)
						tab.glowTexture:SetTexture(theme.textures.glow or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\FireGlow")
						tab.glowTexture:SetBlendMode("ADD")
						tab.glowTexture:SetAlpha(0.2)
						
						-- Create animation
						local glowAnim = tab.glowTexture:CreateAnimationGroup()
						glowAnim:SetLooping("REPEAT")
						
						local fadeIn = glowAnim:CreateAnimation("Alpha")
						fadeIn:SetFromAlpha(0.2)
						fadeIn:SetToAlpha(0.3)
						fadeIn:SetDuration(1.5)
						fadeIn:SetSmoothing("IN")
						fadeIn:SetOrder(1)
						
						local fadeOut = glowAnim:CreateAnimation("Alpha")
						fadeOut:SetFromAlpha(0.3)
						fadeOut:SetToAlpha(0.2)
						fadeOut:SetDuration(1.5)
						fadeOut:SetSmoothing("OUT")
						fadeOut:SetOrder(2)
						
						glowAnim:Play()
					end
					
					tab.glowTexture:SetVertexColor(
						theme.colors.primary.r or 1.0,
						theme.colors.primary.g * 0.6 or 0.6,
						theme.colors.primary.b * 0.3 or 0.3
					)
				end
			end
			
			-- Apply chat frame background
			if frame.SetBackdrop then
				-- Check if we're using Phoenix Flame with custom textures
				local useCustomTextures = isPhoenixFlame and theme.effects and theme.effects.useCustomEffects
				
				if useCustomTextures and theme.textures.chatframe then
					-- Use the special phoenix_flame_theme chat frame texture
					frame:SetBackdrop({
						bgFile = theme.textures.chatframe,
						edgeFile = theme.textures.border,
						tile = true, tileSize = 16, edgeSize = 16,
						insets = { left = 3, right = 3, top = 3, bottom = 3 }
					})
				else
					-- Use standard backdrop
					frame:SetBackdrop({
						bgFile = "Interface\\Buttons\\WHITE8X8",
						edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
						tile = true, tileSize = 16, edgeSize = 16,
						insets = { left = 3, right = 3, top = 3, bottom = 3 }
					})
				end
				
				-- Apply theme background colors
				frame:SetBackdropColor(
					theme.colors.background.r or 0.1,
					theme.colors.background.g or 0.1,
					theme.colors.background.b or 0.1,
					0.7 -- Keep background semi-transparent
				)
				
				frame:SetBackdropBorderColor(
					theme.colors.border.r or 0.3,
					theme.colors.border.g or 0.3,
					theme.colors.border.b or 0.3,
					0.8
				)
			end
		end
	end

	-- Apply styling to all chat frames
	for i = 1, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame" .. i]
		if chatFrame then
			ApplyChatTheme(chatFrame)
		end
	end
	
	-- Listen for theme changes
	Phoenix_UI:RegisterMessage("PHOENIX_UI_THEME_CHANGED", function()
		-- Re-apply theme to all chat frames
		for i = 1, NUM_CHAT_WINDOWS do
			local chatFrame = _G["ChatFrame" .. i]
			if chatFrame then
				ApplyChatTheme(chatFrame)
			end
		end
	end)
end



