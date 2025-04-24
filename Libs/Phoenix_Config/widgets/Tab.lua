--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Tab', 4;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then
	return
end

----------------------------------------------------
--- TabPanel
----------------------------------------------------

local TabPanelMethods = {
	--- Runs callback thru all tabs, if callback returns truthy value, enumeration stops and function returns result
	EnumerateTabs = function(self, callback, ...)
		local result;

		for i = 1, #self.tabs do
			local tab = self.tabs[i];
			result = callback(tab, self, i, ...);
			if result then
				break
			end
		end

		return result;
	end,

	HideAllFrames = function(self)
		for _, tab in pairs(self.tabs) do
			if tab.frame then
				tab.frame:Hide();
			end
		end
	end,

	DrawButtons = function(self)
		local prevBtn;
		for _, tab in pairs(self.tabs) do
			if tab.button then
				tab.button:Hide();
			end

			local btn = tab.button;
			local btnContainer = self.buttonContainer;

			if not btn then
				btn = self.Phoenix_UIConfig:Button(btnContainer, nil, self.buttonHeight);
				tab.button = btn;
				btn.tabFrame = self;

				btn:SetScript('OnClick', function(bt)
					bt.tabFrame:SelectTab(bt.tab.name);
				end);
			end

			btn.tab = tab;
			btn:SetText(tab.title);
			btn:ClearAllPoints();

			if self.vertical then
				btn:SetWidth(self.buttonWidth);
			else
				self.Phoenix_UIConfig:ButtonAutoWidth(btn);
			end

			if self.vertical then
				if not prevBtn then
					self.Phoenix_UIConfig:GlueTop(btn, btnContainer, 0, 0, 'CENTER');
				else
					self.Phoenix_UIConfig:GlueBelow(btn, prevBtn, 0, -1);
				end
			else
				if not prevBtn then
					self.Phoenix_UIConfig:GlueTop(btn, btnContainer, 0, 0, 'LEFT');
				else
					self.Phoenix_UIConfig:GlueRight(btn, prevBtn, 5, 0);
				end
			end

			btn:Show();
			prevBtn = btn;
		end
	end,

	DrawFrames = function(self)
		for _, tab in pairs(self.tabs) do
			if not tab.frame then
				tab.frame = self.Phoenix_UIConfig:Frame(self.container);
			end

			tab.frame:ClearAllPoints();
			tab.frame:SetAllPoints();

			if tab.layout then
				-- Add error handling for tab building
				local success, errorMsg = pcall(function()
					self.Phoenix_UIConfig:BuildWindow(tab.frame, tab.layout);
					self.Phoenix_UIConfig:EasyLayout(tab.frame, { padding = { top = 10, left = 5, right = 5 } });
				end)
				
				if not success then
					-- Create error message to display in the tab
					print("Error building tab '" .. (tab.name or "unknown") .. "': " .. tostring(errorMsg))
					
					-- Add error message to the tab frame
					local errorLabel = self.Phoenix_UIConfig:Label(tab.frame, "Error loading tab content.\nPlease report this issue.\n\n" .. tostring(errorMsg))
					errorLabel:SetPoint("CENTER")
					errorLabel:SetTextColor(1, 0.3, 0.3)
					
					-- Still make the tab navigable but with an error message
					if not tab.frame.elements then
						tab.frame.elements = {}
					end
				end

				tab.frame:SetScript('OnShow', function(of)
					of:DoLayout();
				end);
			end

			if tab.onHide then
				tab.frame:SetScript('OnHide', tab.onHide);
			end
		end
	end,

	Update = function(self, newTabs)
		if newTabs then
			self.tabs = newTabs;
		end
		self:DrawButtons();
		self:DrawFrames();
	end,

	GetTabByName = function(self, name)
		for _, tab in pairs(self.tabs) do
			if tab.name == name then
				return tab;
			end
		end
	end,

	SelectTab = function(self, name)
		-- First, ensure any pending changes in current tab are saved before switching tabs
		if self.selectedTab and self.selectedTab.name and Phoenix_UI and Phoenix_UI.UI then
			-- Save current tab's data before switching
			if Phoenix_UI.UI.CommitPendingChanges then
				Phoenix_UI.UI:CommitPendingChanges()
			end
			
			-- Process all elements in the current tab to ensure all values are saved
			if self.selectedTab.frame and self.selectedTab.frame.elements then
				for _, element in pairs(self.selectedTab.frame.elements) do
					-- Process regular elements
					if element and element.GetValue and element.dbReference and element.dataKey then
						local value = element:GetValue()
						if value ~= nil then
							if Phoenix_UIConfig.setDatabaseValue then
								Phoenix_UIConfig.setDatabaseValue(element.dbReference, element.dataKey, value)
							end
						end
					end
					
					-- Process edit boxes specifically
					if element and element.editBox and element.editBox.GetValue and 
					   element.editBox.dbReference and element.editBox.dataKey then
						-- Force validation to commit value
						if element.editBox.Validate then
							pcall(function() element.editBox:Validate() end)
						end
						
						local value = element.editBox:GetValue()
						if value ~= nil then
							if Phoenix_UIConfig.setDatabaseValue then
								Phoenix_UIConfig.setDatabaseValue(element.editBox.dbReference, element.editBox.dataKey, value)
							end
						end
					end
				end
			end
			
			-- Mark the module as updated in the database
			local currentModule = self.selectedTab.name:lower()
			if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile[currentModule] then
				Phoenix_UI.db.profile[currentModule].__updated = GetTime()
				Phoenix_UI.db.profile[currentModule].__saved_from = "tab_switch"
				
				-- Also synchronize with global variable
				local currentProfile = Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile or "Default"
				if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles and 
				   _G["Phoenix_UIDB"].profiles[currentProfile] then
					-- Ensure module exists in global variable
					if not _G["Phoenix_UIDB"].profiles[currentProfile][currentModule] then
						_G["Phoenix_UIDB"].profiles[currentProfile][currentModule] = {}
					end
					
					-- Copy latest settings to global variable
					_G["Phoenix_UIDB"].profiles[currentProfile][currentModule] = CopyTable(Phoenix_UI.db.profile[currentModule])
				end
			end
			
			-- Force an immediate save when switching tabs
			if Phoenix_UI.ForceSaveDB then
				Phoenix_UI:ForceSaveDB()
			elseif Phoenix_UI.SaveDB then
				Phoenix_UI:SaveDB()
			end
		end
		
		self.selected = name;
		if self.selectedTab then
			self.selectedTab.button:Enable();
		end

		self:HideAllFrames();
		local foundTab = self:GetTabByName(name);

		if foundTab.name == name and foundTab.frame then
			foundTab.button:Disable();
			foundTab.frame:Show();
			self.selectedTab = foundTab;
			
			-- Mark the new module as active in the database
			if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile then
				local moduleName = foundTab.name:lower()
				if Phoenix_UI.db.profile[moduleName] then
					Phoenix_UI.db.profile[moduleName].__active = true
					Phoenix_UI.db.profile[moduleName].__last_viewed = GetTime()
				end
				
				-- Also save the last selected tab globally
				Phoenix_UI.db.profile.lastSelectedTab = foundTab.name
			end
			
			-- Force a flush to disk
			pcall(function()
				if FlushSettingsDB then
					FlushSettingsDB()
				elseif FlushSavedVariables then
					FlushSavedVariables()
				end
			end)
			
			return true;
		end
	end,

	GetSelectedTab = function(self)
		return self.selectedTab;
	end,

	DoLayout = function(self)
		-- redoing layout as container
		local tab = self:GetSelectedTab();
		if tab then
			if tab.frame and tab.frame.DoLayout then
				tab.frame:DoLayout();
			end
		end
	end,

	-- Add a Refresh method to allow refreshing tab content with latest data
	Refresh = function(self)
		-- First refresh all tabs
		for _, tab in pairs(self.tabs) do
			if tab.frame then
				-- Call the tab frame's Refresh method if it exists
				if tab.frame.Refresh then
					tab.frame:Refresh()
				end
				
				-- Also check for content.Refresh (alternative pattern)
				if tab.content and tab.content.Refresh then
					tab.content:Refresh()
				end
				
				-- Refresh all elements in the tab if they have a Refresh method
				if tab.frame.elements then
					for _, element in pairs(tab.frame.elements) do
						if element and element.Refresh then
							element:Refresh()
						end
					end
				end
			end
		end
		
		-- Then refresh the current tab specifically
		local currentTab = self:GetSelectedTab()
		if currentTab and currentTab.frame then
			-- If the tab frame has a DoLayout method, call it
			if currentTab.frame.DoLayout then
				currentTab.frame:DoLayout()
			end
			
			-- Also update the tab data from database if possible
			if currentTab.name and Phoenix_UI and Phoenix_UI.db and 
			   Phoenix_UI.db.profile and Phoenix_UI.db.profile[currentTab.name:lower()] and
			   currentTab.frame and currentTab.frame.layout then
				-- Update the database reference for the current tab
				currentTab.frame.layout.database = Phoenix_UI.db.profile[currentTab.name:lower()]
			end
		end
	end
};

function Phoenix_UIConfig:TabPanel(parent, width, height, tabs, vertical, buttonWidth, buttonHeight)
	vertical = vertical or false;
	buttonWidth = buttonWidth or 160;
	buttonHeight = buttonHeight or 20;

	local tabFrame = self:Frame(parent, width, height);
	tabFrame.Phoenix_UIConfig = self;
	tabFrame.tabs = tabs;
	tabFrame.vertical = vertical;
	tabFrame.buttonWidth = buttonWidth;
	tabFrame.buttonHeight = buttonHeight;

	tabFrame.buttonContainer = self:Frame(tabFrame);
	tabFrame.container = self:Frame(tabFrame);

	if vertical then
		tabFrame.buttonContainer:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 0, 0);
		tabFrame.buttonContainer:SetPoint('BOTTOMLEFT', tabFrame, 'BOTTOMLEFT', 0, 0);
		tabFrame.buttonContainer:SetWidth(buttonWidth);

		tabFrame.container:SetPoint('TOPLEFT', tabFrame.buttonContainer, 'TOPRIGHT', 5, 0);
		tabFrame.container:SetPoint('BOTTOMLEFT', tabFrame.buttonContainer, 'BOTTOMRIGHT', 5, 0);
		tabFrame.container:SetPoint('TOPRIGHT', tabFrame, 'TOPRIGHT', 0, 0);
		tabFrame.container:SetPoint('BOTTOMRIGHT', tabFrame, 'BOTTOMRIGHT', 0, 0);
	else
		tabFrame.buttonContainer:SetPoint('TOPLEFT', tabFrame, 'TOPLEFT', 0, 0);
		tabFrame.buttonContainer:SetPoint('TOPRIGHT', tabFrame, 'TOPRIGHT', 0, 0);
		tabFrame.buttonContainer:SetHeight(buttonHeight);

		tabFrame.container:SetPoint('TOPLEFT', tabFrame.buttonContainer, 'BOTTOMLEFT', 0, -5);
		tabFrame.container:SetPoint('TOPRIGHT', tabFrame.buttonContainer, 'BOTTOMRIGHT', 0, -5);
		tabFrame.container:SetPoint('BOTTOMLEFT', tabFrame, 'BOTTOMLEFT', 0, 0);
		tabFrame.container:SetPoint('BOTTOMRIGHT', tabFrame, 'BOTTOMRIGHT', 0, 0);
	end

	for k, v in pairs(TabPanelMethods) do
		tabFrame[k] = v;
	end

	tabFrame:Update();
	if #tabFrame.tabs > 0 then
		tabFrame:SelectTab(tabFrame.tabs[1].name);
	end

	return tabFrame;
end

Phoenix_UIConfig:RegisterModule(module, version);



