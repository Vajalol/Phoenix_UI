local Module = Phoenix_UI:NewModule("RaidFrames.Show");

function Module:OnEnable()
	local db = Phoenix_UI.db.profile.maps

	local t = {
		Blizzard_CompactRaidFrames = true,
		Blizzard_CUFProfiles = true
	}

	-- Thou shalt not hard disable the Raid Frames
	hooksecurefunc("C_AddOns.DisableAddOn", function(addon)
		if t[addon] then
			C_AddOns.EnableAddOn(addon)
		end
	end)

	-- So It Has Come To This
	if not C_AddOns.IsAddOnLoaded("Blizzard_CompactRaidFrames") then
		for k in pairs(t) do
			C_AddOns.EnableAddOn(k)
		end

		local old = SetItemRef

		function SetItemRef(...)
			local link = ...
			if link == "reload" then
				ReloadUI()
			else
				old(...)
			end
		end

		print("|cff33FF99ShowRaidFrame:|r Requires |cffFF8040|Hreload|h[Reload]|h|r")
		return
	end

	local noop = function()
	end

	-- Instead of directly manipulating protected frames, set the relevant CVars and use official APIs
	local function SetupRaidFramesVisibility()
		-- These operations are safe even in combat
		SetCVar("useCompactPartyFrames", 1)
		
		-- Only perform frame operations when out of combat
		if not InCombatLockdown() then
			-- Use official API to show the manager if available
			if CompactRaidFrameManager_SetSetting and CompactRaidFrameManager_GetSetting then
				if CompactRaidFrameManager_GetSetting("IsShown") ~= true then
					CompactRaidFrameManager_SetSetting("IsShown", true)
				end
			end
			
			-- Use attributes for CompactRaidFrameContainer instead of direct Show method
			if CompactRaidFrameContainer and not CompactRaidFrameContainer:IsForbidden() then
				-- Set the state-visibility attribute instead of calling Show directly
				CompactRaidFrameContainer:SetAttribute("state-visibility", "show")
				
				-- Try to use the raid frame manager too
				if CompactRaidFrameManager and not CompactRaidFrameManager:IsForbidden() then
					CompactRaidFrameManager:SetAttribute("state-visibility", "show")
				end
			end
		end
	end
	
	-- Create a frame for monitoring system events
	local frameMonitor = CreateFrame("Frame")
	
	-- These events are safe to react to
	frameMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")
	frameMonitor:RegisterEvent("PLAYER_REGEN_ENABLED") -- Safe to execute after combat
	frameMonitor:RegisterEvent("CVAR_UPDATE")          -- React to CVar changes
	frameMonitor:RegisterEvent("GROUP_ROSTER_UPDATE")  -- React to group changes
	
	frameMonitor:SetScript("OnEvent", function(self, event)
		-- Delay all operations by a small amount to avoid conflicts
		C_Timer.After(0.5, function()
			-- Only perform operations when completely safe
			if not InCombatLockdown() then
				SetupRaidFramesVisibility()
			end
		end)
	end)
	
	-- Initial setup attempt - use C_Timer to delay the initial setup to avoid loading conflicts
	C_Timer.After(1, function()
		if not InCombatLockdown() then
			SetupRaidFramesVisibility()
		end
	end)

	-- yes I'm a noob with libraries >.<
	if not FixRaidTaint then
		local container = CompactRaidFrameContainer

		local t = {
			discrete = "flush",
			flush = "discrete"
		}

		-- refresh the (tainted) raid frames after combat
		local function OnEvent(self)
			-- secure (probably not) or still in combat somehow
			if issecurevariable("CompactRaidFrame1") or InCombatLockdown() or not container:IsShown() then
				return
			end

			-- Bug #1: left/joined players not updated
			-- Bug #2: sometimes selecting different than the intended target

			-- Instead of directly modifying frames, use a safer approach
			if CompactRaidFrameContainer and not CompactRaidFrameContainer:IsForbidden() then
				-- Use attribute-based setup which is safer for protected frames
				local mode = container.groupMode
				if mode and t[mode] then
					-- Use SetAttribute instead of direct function calls when possible
					CompactRaidFrameContainer:SetAttribute("groupMode", t[mode])
					C_Timer.After(0.1, function()
						if not InCombatLockdown() then
							CompactRaidFrameContainer:SetAttribute("groupMode", mode)
						end
					end)
					
					-- Only use direct API calls if out of combat
					if not InCombatLockdown() then
						CompactRaidFrameContainer_SetGroupMode(container, t[mode])
						C_Timer.After(0.1, function()
							if not InCombatLockdown() then
								CompactRaidFrameContainer_SetGroupMode(container, mode)
							end
						end)
					end
				end
			end
		end

		local f = CreateFrame("Frame", "FixRaidTaint")
		f:RegisterEvent("PLAYER_REGEN_ENABLED")
		f:SetScript("OnEvent", OnEvent)

		f.version = 0.2
	end

	-- maybe disable the option to show party frames since we can't hide the raid frames anymore
	--CompactUnitFrameProfilesRaidStylePartyFrames:Disable()
end



