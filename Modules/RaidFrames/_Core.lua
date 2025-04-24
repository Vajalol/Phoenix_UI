local Module = Phoenix_UI:NewModule("RaidFrames.Core");

function Module:OnEnable()
	local db = Phoenix_UI.db.profile.raidframes
	if db then
		-- Get the general texture if the raidframes doesn't have a specific one
		local statusBarTexture = db.texture or Phoenix_UI.db.profile.general.texture or "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\UI-StatusBar"
		
		-- Fallback texture if the custom one doesn't exist
		local defaultTexture = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\UI-StatusBar"
		local raidBarTexture = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\RaidFrames\\Raid-Bar-Hp-Fill"

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
									region:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
								end
							end
						end
					end

					self.vertLeftBorder:Hide()
					self.vertRightBorder:Hide()
					self.horizTopBorder:Hide()
					self.horizBottomBorder:Hide()
				end
			end
		end

		hooksecurefunc("CompactUnitFrame_UpdateAll", function(self)
			updateTextures(self)
		end)

		-- Create a frame to handle changes after combat
		local CombatQueue = CreateFrame("Frame")
		CombatQueue.frames = {}

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
							-- Set frame dimensions
							self:SetSize(width, height)
							
							-- Update internal elements as well
							if self.healthBar then
								self.healthBar:ClearAllPoints()
								self.healthBar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
								self.healthBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
							end
							
							if self.powerBar then
								self.powerBar:ClearAllPoints()
								self.powerBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
								self.powerBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
								self.powerBar:SetHeight(4)
							end
							
							if self.statusText then
								self.statusText:ClearAllPoints()
								self.statusText:SetPoint("CENTER", self, "CENTER")
							end
							
							if self.centerStatusIcon then
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
							self:SetWidth(width)
						end
					end)
				end
			end
		end

		-- Hide Titles only when not in combat
		if not InCombatLockdown() and CompactPartyFrameTitle then
			CompactPartyFrameTitle:Hide()
		end

		-- Update PartyFrame Size
		if (db.size) then
			local frameResizer = CreateFrame("Frame", "Phoenix_RaidFrameResizer")
			local pendingUpdates = {}
			local combatStatus = false
			
			-- Create a table to store original frame references before they might get updated
			local partyFrameCache = {}
			
			-- Initialize party frame references when safe
			local function cacheFrameReferences()
				if InCombatLockdown() then return end
				
				partyFrameCache = {
					CompactPartyFrameMember1,
					CompactPartyFrameMember2,
					CompactPartyFrameMember3,
					CompactPartyFrameMember4,
					CompactPartyFrameMember5
				}
				
				-- Pre-emptively set attributes on these frames (will be used when frames are created/refreshed)
				for i = 1, #partyFrameCache do
					if partyFrameCache[i] then
						-- Store desired dimensions as attributes
						partyFrameCache[i]:SetAttribute("phoenix_width", db.width)
						partyFrameCache[i]:SetAttribute("phoenix_height", db.height)
					end
				end
			end
			
			-- Perform actual updates only when completely safe
			local function performPendingUpdates()
				if InCombatLockdown() then return end
				
				for frame, _ in pairs(pendingUpdates) do
					if frame and not frame:IsForbidden() and frame:GetName() then
						updateSize(frame)
					end
				end
				
				wipe(pendingUpdates)
				
				-- Refresh the cache after updates
				cacheFrameReferences()
			end
			
			-- Intercept frame creation if possible, before any combat starts
			-- Use the most defensive approach possible
			hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
				if InCombatLockdown() then return end
				if not frame or frame:IsForbidden() then return end
				
				local name = frame:GetName()
				if name and name:match("^CompactPartyFrameMember") then
					-- Store desired dimensions as attributes
					frame:SetAttribute("phoenix_width", db.width)
					frame:SetAttribute("phoenix_height", db.height)
					
					-- Only attempt to set size when completely safe
					if not InCombatLockdown() then
						pcall(function()
							frame:SetWidth(db.width)
							frame:SetHeight(db.height)
						end)
					else
						pendingUpdates[frame] = true
					end
				end
			end)
			
			-- Register essential events
			frameResizer:RegisterEvent("PLAYER_REGEN_DISABLED")
			frameResizer:RegisterEvent("PLAYER_REGEN_ENABLED")
			frameResizer:RegisterEvent("PLAYER_ENTERING_WORLD")
			frameResizer:RegisterEvent("GROUP_ROSTER_UPDATE")
			
			frameResizer:SetScript("OnEvent", function(_, event)
				if event == "PLAYER_REGEN_DISABLED" then
					-- Combat started
					combatStatus = true
					-- Don't try to make any changes, just exit
				elseif event == "PLAYER_REGEN_ENABLED" then
					-- Combat ended
					combatStatus = false
					-- Wait a moment before processing updates to ensure combat state is stable
					C_Timer.After(0.5, function()
						if not InCombatLockdown() then
							performPendingUpdates()
						end
					end)
				elseif event == "PLAYER_ENTERING_WORLD" then
					C_Timer.After(2, function()
						-- Wait for frames to be fully loaded
						combatStatus = InCombatLockdown()
						if not combatStatus then
							-- Cache frame references and set attributes
							cacheFrameReferences()
							
							-- Queue frames for update
							for i = 1, #partyFrameCache do
								if partyFrameCache[i] then
									pendingUpdates[partyFrameCache[i]] = true
								end
							end
							
							performPendingUpdates()
						end
					end)
				elseif event == "GROUP_ROSTER_UPDATE" then
					-- Group composition changed
					if not combatStatus and not InCombatLockdown() then
						C_Timer.After(0.5, function()
							if InCombatLockdown() then return end
							
							-- Refresh references and queue updates
							cacheFrameReferences()
							
							-- Queue each frame for update
							for i = 1, #partyFrameCache do
								if partyFrameCache[i] then
									pendingUpdates[partyFrameCache[i]] = true
								end
							end
							
							performPendingUpdates()
						end)
					end
				end
			end)

			-- Ultra-safe hook with multiple combat checks
			local safeUpdateHook = function(frame)
				if not frame or frame:IsForbidden() then return end
				
				local name = frame:GetName()
				if not name or not name:match("^CompactPartyFrameMember") then return end
				
				-- NEVER modify the frame in combat - just queue it
				if combatStatus or InCombatLockdown() then
					pendingUpdates[frame] = true
					return
				end
				
				-- Triple-check combat status before proceeding
				C_Timer.After(0.1, function()
					if InCombatLockdown() then
						pendingUpdates[frame] = true
						return
					end
					
					-- Store desired dimensions as attributes regardless
					frame:SetAttribute("phoenix_width", db.width)
					frame:SetAttribute("phoenix_height", db.height)
					
					-- Only attempt sizing if definitely safe
					if not InCombatLockdown() and not frame:IsForbidden() then
						updateSize(frame)
					end
				end)
			end
			
			-- Use the hook
			hooksecurefunc("CompactUnitFrame_UpdateAll", safeUpdateHook)
			
			-- On combat start, completely disengage from party frames
			frameResizer:HookScript("OnEvent", function(_, event)
				if event == "PLAYER_REGEN_DISABLED" then
					-- Additional safety: neutralize existing hooks by making them no-ops
					hooksecurefunc("CompactUnitFrame_UpdateAll", function() end)
					
					-- Ensure we're not attached to anything that might cause protected updates
					if CompactPartyFrame then
						pcall(function()
							CompactPartyFrame:UnregisterAllEvents()
						end)
					end
				end
			end)
		end

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

			updateTextures(self)
			updateSize(self)
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
	end
end



