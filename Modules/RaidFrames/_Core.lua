local Module = Phoenix_UI:NewModule("RaidFrames.Core");

--- @class RaidFramesModule
--- @field OnEnable function
function Module:OnEnable()
	local db = Phoenix_UI.db.profile.raidframes
	if db then
		-- Get the general texture if the raidframes doesn't have a specific one
		local statusBarTexture = db.texture or Phoenix_UI.db.profile.general.texture or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\UI-StatusBar"
		
		-- Fallback texture if the custom one doesn't exist
		local defaultTexture = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\UI-StatusBar"
		local raidBarTexture = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\RaidFrames\\Raid-Bar-Hp-Fill"

		-- Create a frame to handle changes after combat
		local CombatQueue = CreateFrame("Frame")
		CombatQueue.frames = {}
		
		-- Track frames that we've already applied protection to
		local protectedFrames = {}

		-- Add function to queue a frame for updates after combat
		local function QueueFrameForUpdate(frame)
			if not frame or frame:IsForbidden() then return end
			if not frame:GetName() then return end
			
			-- Store the frame in our queue if not already there
			local name = frame:GetName()
			if name then
				-- Store dimensions as attributes which can be read during combat
				frame:SetAttribute("phoenix_width", db.width)
				frame:SetAttribute("phoenix_height", db.height)
				
				-- Add to queue if not already included
				if not CombatQueue.frames[name] then
					CombatQueue.frames[name] = frame
				end
			end
		end

		local function updateTextures(self)
			if self:IsForbidden() then return end
			if self and self:GetName() then
				local name = self:GetName()
				if name and name:match("^Compact") then
					if self:IsForbidden() then return end
					
					-- Use the statusbar texture
					if statusBarTexture ~= [[Interface\Default]] then
						-- Safely set textures with pcall to prevent errors
						if self.healthBar and self.healthBar.SetStatusBarTexture then
							pcall(function() 
								self.healthBar:SetStatusBarTexture(statusBarTexture) 
								if self.healthBar:GetStatusBarTexture() then
									self.healthBar:GetStatusBarTexture():SetDrawLayer("BORDER")
								end
							end)
						end
						
						if self.powerBar and self.powerBar.SetStatusBarTexture then
							pcall(function() 
								self.powerBar:SetStatusBarTexture(statusBarTexture)
								if self.powerBar:GetStatusBarTexture() then
									self.powerBar:GetStatusBarTexture():SetDrawLayer("BORDER")
								end
							end)
						end
						
						-- Fix for myHealPrediction and otherHealPrediction - use correct API
						if self.myHealPrediction then
							if self.myHealPrediction.SetTexture then
								pcall(function() self.myHealPrediction:SetTexture(statusBarTexture) end)
							elseif self.myHealPrediction.SetStatusBarTexture then
								pcall(function() self.myHealPrediction:SetStatusBarTexture(statusBarTexture) end)
							elseif self.myHealPrediction.SetColorTexture then
								pcall(function() self.myHealPrediction:SetColorTexture(0.0, 0.659, 0.608, 0.7) end)
							end
						end
						
						if self.otherHealPrediction then
							if self.otherHealPrediction.SetTexture then
								pcall(function() self.otherHealPrediction:SetTexture(statusBarTexture) end)
							elseif self.otherHealPrediction.SetStatusBarTexture then
								pcall(function() self.otherHealPrediction:SetStatusBarTexture(statusBarTexture) end)
							elseif self.otherHealPrediction.SetColorTexture then
								pcall(function() self.otherHealPrediction:SetColorTexture(0.0, 0.659, 0.608, 0.7) end)
							end
						end
					end

					if name:find('CompactPartyFrame') then
						if Phoenix_UI:Color() then
							self.horizDivider:SetVertexColor(.3, .3, .3)
							for _, region in pairs({ CompactPartyFrameBorderFrame:GetRegions() }) do
								if region:IsObjectType("Texture") then
									local r, g, b, a = Phoenix_UI:Color()
									if type(r) == "number" then
										region:SetVertexColor(r * 0.15, g * 0.15, b * 0.15, a)
									end
								end
							end
						end
					end

					self.vertLeftBorder:Hide()
					self.vertRightBorder:Hide()
					self.horizTopBorder:Hide()
					self.horizBottomBorder:Hide()
					
					-- Apply debuff highlighting if enabled
					if db.enableDebuffHighlight and self.dispelDebuffFrames then
						for _, debuffFrame in pairs(self.dispelDebuffFrames) do
							if debuffFrame then
								-- Set border texture for debuff highlight
								local border = debuffFrame:GetParent() and debuffFrame:GetParent().healthBar and debuffFrame:GetParent().healthBar.border
								if border then
									border:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\RaidFrames\\Raid-Border-Highlight")
								end
							end
						end
					end
				end
			end
		end

		-- Define updateSize function before it's used
		local function updateSize(self)
			-- Check if frame is forbidden or we're in combat - both situations prevent modifications
			if self:IsForbidden() or InCombatLockdown() then
				-- Queue for later if in combat
				QueueFrameForUpdate(self)
				return
			end
			if not self or not self:GetName() then return end
			
			local name = self:GetName()

			if name and name:match("^CompactPartyFrameMember") then
				-- Triple check combat status for maximum safety
				if InCombatLockdown() then
					QueueFrameForUpdate(self)
					return
				end
				
				-- Get our stored dimensions from attributes or fallback to db values
				local width = self:GetAttribute("phoenix_width") or db.width
				local height = self:GetAttribute("phoenix_height") or db.height
				
				-- Only proceed if we're DEFINITELY out of combat
				if not InCombatLockdown() and not self:IsForbidden() then
					-- Use pcall for maximum safety to avoid any errors breaking the addon
					pcall(function()
						-- Only modify if we're still out of combat (triple check)
						if not InCombatLockdown() then
							-- CHANGE: Use SetAttribute instead of direct SetSize to avoid taint issues
							-- self:SetSize(width, height)
							self:SetAttribute("customWidth", width)
							self:SetAttribute("customHeight", height)
							
							-- Safely update frame layout if permitted method exists
							if type(CompactUnitFrameProfiles) == "table" and 
							   type(CompactUnitFrameProfiles.ApplyToFrame) == "function" then
								CompactUnitFrameProfiles.ApplyToFrame(self)
							end
							
							-- Use CVar approach as a backup to influence frame size
							if not InCombatLockdown() then
								-- We can safely set these CVars
								SetCVar("compactPartyFrameHeight", height)
								SetCVar("compactPartyFrameWidth", width)
							end
							
							-- Update internal elements as well - only if they're not protected
							if self.healthBar and not self.healthBar:IsForbidden() then
								self.healthBar:ClearAllPoints()
								self.healthBar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
								self.healthBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
							end
							
							if self.powerBar and not self.powerBar:IsForbidden() then
								self.powerBar:ClearAllPoints()
								self.powerBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
								self.powerBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
								self.powerBar:SetHeight(4)
							end
							
							if self.statusText and not self.statusText:IsForbidden() then
								self.statusText:ClearAllPoints()
								self.statusText:SetPoint("CENTER", self, "CENTER")
							end
							
							if self.centerStatusIcon and not self.centerStatusIcon:IsForbidden() then
								self.centerStatusIcon:ClearAllPoints()
								self.centerStatusIcon:SetPoint("CENTER", self, "CENTER")
							end
						end
					end)
				end
			elseif name and name:match("^CompactPartyFramePet") then
				-- Triple check combat status for maximum safety
				if InCombatLockdown() or self:IsForbidden() then
					QueueFrameForUpdate(self)
					return
				end
				
				-- Only proceed if we're DEFINITELY out of combat
				if not InCombatLockdown() and not self:IsForbidden() then
					pcall(function()
						-- One final check
						if not InCombatLockdown() then
							local width = self:GetAttribute("phoenix_width") or db.width
							-- CHANGE: Use SetAttribute instead of directly modifying
							-- self:SetWidth(width)
							self:SetAttribute("customWidth", width)
							
							-- Safely update frame layout if permitted method exists
							if type(CompactUnitFrameProfiles) == "table" and 
							   type(CompactUnitFrameProfiles.ApplyToFrame) == "function" then
								CompactUnitFrameProfiles.ApplyToFrame(self)
							end
						end
					end)
				end
			end
		end
		
		-- IMPORTANT: Protect against direct SetSize calls by adding a metatable interceptor
		-- This is the most robust defense mechanism against taint
		local function ProtectCompactPartyFrame(frame)
			if not frame or frame:IsForbidden() or protectedFrames[frame] then
				return
			end
			
			local name = frame:GetName()
			if not name or not name:match("^CompactPartyFrameMember") then
				return
			end
			
			-- Mark this frame as protected
			protectedFrames[frame] = true
			
			-- Store the original SetSize method
			local originalSetSize = frame.SetSize
			
			-- Replace SetSize with our safe version
			frame.SetSize = function(self, width, height)
				-- Only call the original if not in combat
				if not InCombatLockdown() then
					return originalSetSize(self, width, height)
				else
					-- Store the desired size as attributes
					self:SetAttribute("customWidth", width)
					self:SetAttribute("customHeight", height)
					QueueFrameForUpdate(self)
					return -- Silently fail, no error
				end
			end
			
			-- Also protect SetWidth and SetHeight
			local originalSetWidth = frame.SetWidth
			frame.SetWidth = function(self, width)
				if not InCombatLockdown() then
					return originalSetWidth(self, width)
				else
					self:SetAttribute("customWidth", width)
					QueueFrameForUpdate(self)
					return
				end
			end
			
			local originalSetHeight = frame.SetHeight
			frame.SetHeight = function(self, height)
				if not InCombatLockdown() then
					return originalSetHeight(self, height)
				else
					self:SetAttribute("customHeight", height)
					QueueFrameForUpdate(self)
					return
				end
			end
		end

		-- Update the hook to be more defensive by adding pre-hooks
		-- This is a defensive approach that catches SetSize calls BEFORE they happen
		if _G.CompactUnitFrame_SetUpFrame then
			hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
				-- If this is a party frame, protect it from getting SetSize during combat
				if frame and not frame:IsForbidden() and frame:GetName() and 
				   frame:GetName():match("^CompactPartyFrameMember") then
					ProtectCompactPartyFrame(frame)
					
					-- Queue any size updates for when we're out of combat
					if InCombatLockdown() then
						QueueFrameForUpdate(frame)
					end
				end
			end)
		end
		
		-- Also hook the update function to add protection and queue updates
		if _G.CompactUnitFrame_UpdateAll then
			hooksecurefunc("CompactUnitFrame_UpdateAll", function(self)
				-- Only proceed if it's safe
				if InCombatLockdown() or (self and self:IsForbidden()) then return end
				
				-- Protect the frame if it's a party frame
				if self and not self:IsForbidden() and self:GetName() and 
				   self:GetName():match("^CompactPartyFrameMember") then
					ProtectCompactPartyFrame(self)
				end
				
				-- Only run texture updates (which are safe) and queue size updates for later
				if self and not self:IsForbidden() and self:GetName() then
					updateTextures(self)
					
					-- Instead of calling updateSize directly, queue it for after combat
					if self:GetName():match("^CompactPartyFrameMember") or self:GetName():match("^CompactPartyFramePet") then
						QueueFrameForUpdate(self)
					end
				end
			end)
		end

		-- Register events for combat tracking
		CombatQueue:RegisterEvent("PLAYER_REGEN_ENABLED")
		CombatQueue:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_ENABLED" then
				-- Process all queued frames
				for name, frame in pairs(self.frames) do
					if frame and not frame:IsForbidden() then
						updateSize(frame)
					end
				end
				-- Clear the queue
				wipe(self.frames)
			end
		end)

		local function updateFrame(self)
			-- Avoid any updates if frame is forbidden or we're in combat
			if not self or self:IsForbidden() or InCombatLockdown() then
				-- Only queue valid frames
				if self and not self:IsForbidden() and self:GetName() then
					QueueFrameForUpdate(self)
				end
				return
			end
			
			if not self:GetName() then return end

			-- Always safe to update textures
			updateTextures(self)
			
			-- Only attempt size updates when out of combat
			if not InCombatLockdown() then
				updateSize(self)
			else
				QueueFrameForUpdate(self)
			end
		end

		local function unblockFrameUpdates()
			-- Don't process queue if we're in combat
			if InCombatLockdown() then return end
			
			local validFrames = {}
			for name, frame in pairs(CombatQueue.frames) do
				if frame and not frame:IsForbidden() and frame:GetName() then
					validFrames[name] = frame
				end
			end
			
			for name, frame in pairs(validFrames) do
				updateFrame(frame)
				-- Remove from queue after processing
				CombatQueue.frames[name] = nil
			end
			
			-- Only clear the table if we're out of combat and processed the updates
			if not InCombatLockdown() then
				wipe(CombatQueue.frames)
			end
		end

		-- Add additional init for compatibility with Blizzard frames
		local initFrame = CreateFrame("Frame")
		initFrame:RegisterEvent("ADDON_LOADED")
		initFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		initFrame:RegisterEvent("GROUP_JOINED")
		initFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		
		local initPending = true -- Used to track if we need to do initialization
		
		initFrame:SetScript("OnEvent", function(self, event, addonName)
			-- For any event, if in combat, simply mark that initialization is pending
			if InCombatLockdown() then
				initPending = true
				return
			end
			
			-- If this is PLAYER_REGEN_ENABLED and we have init pending, trigger all checks
			if event == "PLAYER_REGEN_ENABLED" and initPending then
				initPending = false
				-- Artificial GROUP_ROSTER_UPDATE to initialize frames
				self:GetScript("OnEvent")(self, "GROUP_ROSTER_UPDATE")
				return
			end
			
			-- Setup party frames when needed
			if event == "ADDON_LOADED" and (addonName == "Blizzard_CompactRaidFrames" or addonName == "Blizzard_CUFProfiles") then
				-- Apply settings to compact raid frame container if it exists
				if CompactRaidFrameContainer and not InCombatLockdown() then
					-- Set attributes rather than directly modifying
					CompactRaidFrameContainer:SetAttribute("phoenix_styled", true)
				end
			elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" or event == "GROUP_JOINED" then
				-- Handle existing frames when group composition changes
				-- Check if party frames exist
				if CompactPartyFrame and not InCombatLockdown() then
					CompactPartyFrame:SetAttribute("phoenix_styled", true)
					
					-- Safety timer to ensure frames are fully created
					C_Timer.After(0.5, function()
						if InCombatLockdown() then
							initPending = true
							return
						end
						
						-- Set CVars that influence frame sizing
						SetCVar("compactPartyFrameHeight", db.height)
						SetCVar("compactPartyFrameWidth", db.width)
						
						-- Attempt to set initial attributes on party member frames if they exist
						for i = 1, 5 do
							local memberFrame = _G["CompactPartyFrameMember" .. i]
							if memberFrame and not memberFrame:IsForbidden() and not InCombatLockdown() then
								-- Protect this frame from direct SetSize calls
								ProtectCompactPartyFrame(memberFrame)
								
								-- Add to queue for safer processing
								QueueFrameForUpdate(memberFrame)
								
								-- Just update textures which is safe
								updateTextures(memberFrame)
								
								-- Set attributes but don't modify appearance directly
								memberFrame:SetAttribute("phoenix_width", db.width)
								memberFrame:SetAttribute("phoenix_height", db.height)
								memberFrame:SetAttribute("phoenix_styled", true)
							end
							
							-- Also process pet frames
							local petFrame = _G["CompactPartyFramePet" .. i]
							if petFrame and not petFrame:IsForbidden() and not InCombatLockdown() then
								QueueFrameForUpdate(petFrame)
								updateTextures(petFrame)
								petFrame:SetAttribute("phoenix_width", db.width)
								petFrame:SetAttribute("phoenix_styled", true)
							end
						end
						
						-- Trigger frame updates when out of combat
						C_Timer.After(0.5, function()
							if not InCombatLockdown() then
								unblockFrameUpdates()
							end
						end)
					end)
				end
			end
		end)
	end
end
