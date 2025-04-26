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

		hooksecurefunc("CompactUnitFrame_UpdateAll", function(self)
			updateTextures(self)
		end)

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
