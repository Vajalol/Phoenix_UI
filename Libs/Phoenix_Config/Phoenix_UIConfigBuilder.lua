--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Builder', 6;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then
	return
end

local util = Phoenix_UIConfig.Util;

local function setDatabaseValue(db, key, value)
	if not db or not key then return end
	
	-- Handle case where key is not a string
	if type(key) ~= "string" then
		if type(key) == "table" then
			-- Enhanced table key handling
			if key.enabled ~= nil and key.setEnabled then
				-- This is a specific error case we've seen with idTip
				key = "setEnabled"
				print("Phoenix_UI: Converting table key to 'setEnabled'")
			elseif key.name then
				-- Try to use name field as key
				key = tostring(key.name)
				print("Phoenix_UI: Converting table key to name: " .. key)
			elseif key.id then
				-- Try to use id field as key
				key = tostring(key.id)
				print("Phoenix_UI: Converting table key to id: " .. key)
			else
				-- Attempt to extract any usable string from the table
				local potentialKey = nil
				for k, v in pairs(key) do
					if type(k) == "string" and potentialKey == nil then
						potentialKey = k
					end
					if type(v) == "string" and potentialKey == nil then
						potentialKey = v
					end
				end
				
				if potentialKey then
					key = potentialKey
					-- Debug message commented out to reduce console spam
					-- print("Phoenix_UI: Extracted key from table: " .. key)
				else
					-- Print table contents for debugging
					print("Phoenix_UI: Error in setDatabaseValue - key is a table without usable fields")
					for k, v in pairs(key) do
						print("  - Table key[" .. tostring(k) .. "] = " .. tostring(v))
					end
					return
				end
			end
		else
			-- Log error for debugging and return early
			print("Phoenix_UI: Error in setDatabaseValue - key is not a string:", type(key))
			return
		end
	end
	
	-- Treat value as nil if it's an empty string (common for text inputs)
	if value == "" then value = nil end
	
	-- Safe implementation for handling nested keys (dot notation)
	local path = {}
	for segment in key:gmatch("[^%.]+") do
		table.insert(path, segment)
	end
	
	local current = db
	local lastKey = table.remove(path)
	
	-- Navigate to the correct nested table
	for _, pathKey in ipairs(path) do
		if not current[pathKey] then
			current[pathKey] = {}
		elseif type(current[pathKey]) ~= "table" then
			-- If we encounter a non-table value in the path, convert it to a table
			current[pathKey] = {}
		end
		current = current[pathKey]
	end
	
	-- Check if this is actually a change - with special handling for tables
	local oldValue = current[lastKey]
	local isChange = true  -- Default to true to ensure saving
	
	-- Only do complex comparisons for simple values
	if type(oldValue) ~= "table" and type(value) ~= "table" then
	    isChange = (oldValue ~= value)
	end
	
	-- Set the value at the final path location
	current[lastKey] = value
	
	-- Special handling for theme changes to ensure they're applied immediately
	if (key == "general.theme" or key:match("^general%.theme%.") or key:match("^fonts%.")) and Phoenix_UI then
	    -- Detect theme change
	    if key == "general.theme" then
	        -- Apply theme immediately
	        C_Timer.After(0.1, function()
	            if Phoenix_UI.ApplyThemeToConfigUI then
	                Phoenix_UI:ApplyThemeToConfigUI()
	            end
	            
	            -- Also update fonts if needed
	            if Phoenix_UI.ApplyFontSettings then
	                Phoenix_UI:ApplyFontSettings()
	            end
	        end)
	        
	        -- Mark as critical setting 
	        isChange = true
	    end
	    
	    -- Detect font change
	    if key:match("^fonts%.") and Phoenix_UI.ApplyFontSettings then
	        C_Timer.After(0.1, function()
	            Phoenix_UI:ApplyFontSettings()
	        end)
	        
	        -- Also mark as changed
	        isChange = true
	    end
	end
	
	-- Only process further if the value actually changed
	if isChange then
		-- Extract the root module name (first segment before any dots)
		local rootModule = key:match("^([^%.]+)%.")
		if not rootModule then
		    rootModule = key  -- If there's no dot, use the whole key
		end
		
		-- Always consider all module settings as important
		local isImportantSetting = true
		
		-- Force an immediate save for all settings changes
		if Phoenix_UI then
		    -- Mark this module for update with detailed information
		    if Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile[rootModule] then
		        Phoenix_UI.db.profile[rootModule].__updated = GetTime()
		        Phoenix_UI.db.profile[rootModule].__last_key_changed = key
		        Phoenix_UI.db.profile[rootModule].__saved_from = "direct_setting"
		        
		        -- Update global savedvariables directly for better persistence
		        if _G["Phoenix_UIDB"] and _G["Phoenix_UIDB"].profiles then
		            local currentProfile = Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile or "Default"
		            if _G["Phoenix_UIDB"].profiles[currentProfile] then
		                -- Ensure the module exists in global vars
		                _G["Phoenix_UIDB"].profiles[currentProfile][rootModule] = _G["Phoenix_UIDB"].profiles[currentProfile][rootModule] or {}
		                
		                -- Safety copy with error handling
		                local success, errorMsg = pcall(function()
		                    -- Deep copy our updated module settings
		                    _G["Phoenix_UIDB"].profiles[currentProfile][rootModule] = CopyTable(Phoenix_UI.db.profile[rootModule])
		                    
		                    -- Also mark the update time and source 
		                    _G["Phoenix_UIDB"].profiles[currentProfile][rootModule].__updated = GetTime()
		                    _G["Phoenix_UIDB"].profiles[currentProfile][rootModule].__last_key_changed = key
		                    _G["Phoenix_UIDB"].profiles[currentProfile][rootModule].__saved_from = "direct_setting"
		                end)
		                
		                -- If we encounter an error during the copy, try individual field updates
		                if not success and Phoenix_UI.debug then
		                    print("Phoenix_UI: Error copying settings: " .. tostring(errorMsg))
		                    
		                    -- Try to set just the individual field if copying the whole module failed
		                    pcall(function()
		                        -- Recreate path navigation in global vars
		                        local globalCurrent = _G["Phoenix_UIDB"].profiles[currentProfile][rootModule]
		                        for i, pathKey in ipairs(path) do
		                            globalCurrent[pathKey] = globalCurrent[pathKey] or {}
		                            globalCurrent = globalCurrent[pathKey]
		                        end
		                        
		                        -- Set just the specific value
		                        globalCurrent[lastKey] = value
		                    end)
		                end
		            end
		        end
		    end
		    
		    -- Special handling for theme settings and UI scaling
		    if rootModule == "general" and (lastKey == "theme" or key:match("^general%.color")) then
		        -- Force immediate save for theme settings
		        if Phoenix_UI.SaveAllSettings then
		            C_Timer.After(0.1, function()
		                Phoenix_UI:SaveAllSettings()
		            end)
		            return -- Early return as SaveAllSettings will handle everything
		        end
		    end
		    
		    -- Additional handling for UI scaling - needs to be saved immediately
		    if rootModule == "uiscaling" and (lastKey == "scale") then
		        -- Force immediate save for scaling settings
		        if Phoenix_UI.SaveAllSettings then
		            Phoenix_UI:SaveAllSettings()
		            
		            -- Also apply UI scale directly
		            local scale = value
		            if scale and tonumber(scale) > 0 then
		                SetCVar("uiScale", scale)
		                UIParent:SetScale(scale)
		            end
		            
		            return -- Early return as SaveAllSettings will handle everything
		        end
		    end
		    
		    -- Additional handling for actionbars - needs to be saved immediately
		    if rootModule == "actionbars" then
		        -- Force immediate save for actionbar settings
		        if Phoenix_UI.SaveAllSettings then
		            C_Timer.After(0.1, function()
		                Phoenix_UI:SaveAllSettings()
		            end)
		            return -- Early return as SaveAllSettings will handle everything
		        end
		    end
		    
		    -- Additional handling for nameplates - needs to be saved immediately
		    if rootModule == "nameplates" then
		        -- Force immediate save for nameplates settings
		        if Phoenix_UI.SaveAllSettings then
		            C_Timer.After(0.1, function()
		                Phoenix_UI:SaveAllSettings()
		            end)
		            return -- Early return as SaveAllSettings will handle everything
		        end
		    end
		    
		    -- Additional handling for remaining critical modules - needs to be saved immediately
		    if rootModule == "tooltip" or rootModule == "mythicplus" or 
		       rootModule == "misc" or rootModule == "map" or
		       rootModule == "chat" or rootModule == "castbars" or
		       rootModule == "cooldowntracker" or rootModule == "weakauras" or
		       rootModule == "msbt" or rootModule == "buffoverlay" or
		       rootModule == "buffs" or rootModule == "idtip" then
		        -- Force immediate save for these module settings
		        if Phoenix_UI.SaveAllSettings then
		            C_Timer.After(0.1, function()
		                Phoenix_UI:SaveAllSettings()
		            end)
		            return -- Early return as SaveAllSettings will handle everything
		        end
		    end
		    
		    -- Use a short delay to batch multiple changes
		    C_Timer.After(0.1, function()
		        -- Try different save methods in order of preference
		        if Phoenix_UI.ForceSaveDB then
		            Phoenix_UI:ForceSaveDB()
		        elseif Phoenix_UI.SaveDB then
		            Phoenix_UI:SaveDB()
		        end
		        
		        -- Refresh UI if needed
		        if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
		            Phoenix_UI.UI:RefreshConfig()
		        end
		        
		        -- Force an immediate write to disk 
		        pcall(function()
		            if FlushSavedVariables then
		                FlushSavedVariables()
		            elseif FlushSettingsDB then
		                FlushSettingsDB()
		            end
		        end)
		    end)
		end
		
		-- Trigger refresh on UI changes
		if Phoenix_UI and Phoenix_UI.RefreshConfig then
			Phoenix_UI:RefreshConfig()
		end
	end
end

-- Add setDatabaseValue as a method to Phoenix_UIConfig
Phoenix_UIConfig.setDatabaseValue = setDatabaseValue

local function getDatabaseValue(db, key)
	if not db then return nil end

	if key:find('.') then
		local accessor = Phoenix_UIConfig.Util.stringSplit('.', key);
		local startPos = db;

		for i = 1, #accessor do
			if not startPos then return nil end
			
			local subKey = accessor[i];
			if i == #accessor then
				return startPos[subKey];
			end

			startPos = startPos[subKey];
		end
		return nil;
	else
		return db[key];
	end
end

-- Add getDatabaseValue as a method to Phoenix_UIConfig
Phoenix_UIConfig.getDatabaseValue = getDatabaseValue

---CreateLabel
--@param parent Frame
--@param text string
--@param width number
--@return FontString
function Phoenix_UIConfig:CreateLabel(parent, text, width)
	local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	if text ~= nil then
		label:SetText(tostring(text));
	else
		label:SetText("");
	end
	label:SetJustifyH("LEFT");
	label:SetWidth(width or 100);
	return label;
end

---BuildElement
--@param frame Frame
--@param row EasyLayoutRow
--@param info table
--@param dataKey string
--@param db table
function Phoenix_UIConfig:BuildElement(frame, row, info, dataKey, db)
	local element;

	local genericChangeEvent = function(el, value)
		-- Debug output
		if Phoenix_UI and Phoenix_UI.debug then
			print("PHX-UI: Change event triggered for", el.dataKey, "=", tostring(value))
		end
		
		-- Update the database value
		Phoenix_UIConfig.setDatabaseValue(el.dbReference, el.dataKey, value);
		
		-- Call custom change handler if registered
		if el.onChange then
			el:onChange(value);
		end
		
		-- Send a message that the setting has changed
		if Phoenix_UI and Phoenix_UI.SendMessage then
			Phoenix_UI:SendMessage("PHOENIX_UI_SETTING_CHANGED", el.dataKey, value)
		end
		
		-- Check if this is a general setting that needs immediate save
		local needsImmediateSave = el.dataKey and (
			el.dataKey:match("^general%.") or 
			el.dataKey:match("^theme") or 
			el.dataKey:match("^font") or
			el.dataKey:match("^display%.") or
			el.dataKey:match("^cosmetic%.") or
			el.dataKey:match("^automation%.") or
			el.dataKey:match("^nameplates%.") or
			el.dataKey:match("^actionbars%.") or 
			el.dataKey:match("^tooltip%.") or 
			el.dataKey:match("^mythicplus%.") or 
			el.dataKey:match("^map%.") or 
			el.dataKey:match("^chat%.") or 
			el.dataKey:match("^castbars%.") or 
			el.dataKey:match("^cooldowntracker%.") or 
			el.dataKey:match("^weakauras%.") or 
			el.dataKey:match("^msbt%.") or 
			el.dataKey:match("^buffs%.") or
			el.dataKey:match("^buffoverlay%.") or
			el.dataKey:match("^idtip%.") or
			el.dataKey:match("^misc%.")
		)
		
		-- Handle save based on importance
		if needsImmediateSave then
			-- Force an immediate save for important settings
			if Phoenix_UI and Phoenix_UI.UI and Phoenix_UI.UI.SaveNow then
				Phoenix_UI.UI:SaveNow()
			elseif Phoenix_UI and Phoenix_UI.SaveDB then
				Phoenix_UI:SaveDB()
			end
			
			-- Also save all tab settings to be absolutely sure
			if Phoenix_UI and Phoenix_UI.SaveAllTabSettings then
				Phoenix_UI:SaveAllTabSettings()
			end
		else
			-- Queue save operation for less critical changes
			if Phoenix_UI and Phoenix_UI.UI and Phoenix_UI.UI.QueueSave then
				Phoenix_UI.UI:QueueSave()
			end
			
			-- Also queue a save of all tab settings
			if Phoenix_UI and Phoenix_UI.SaveAllTabSettings then
				C_Timer.After(1, function()
					if Phoenix_UI then
						Phoenix_UI:SaveAllTabSettings()
					end
				end)
			end
		end
	end

	local hasLabel = false;
	if info.type == 'checkbox' then
		element = self:Checkbox(frame, info.label, nil, nil, info.tooltip);
	elseif info.type == 'toggle' then
		-- Map 'toggle' type to 'checkbox' as they serve the same purpose
		element = self:Checkbox(frame, info.label, nil, nil, info.tooltip);
	elseif info.type == 'editBox' then
		element = self:EditBox(frame, nil, 20);
		
		-- Ensure edit boxes have proper validation and saving behavior
		local originalValidate = element.Validate
		element.Validate = function(self, ...)
			local result = originalValidate(self, ...)
			
			-- Save the value to database when validated
			if result and self.dbReference and self.dataKey then
				local value = self:GetValue()
				setDatabaseValue(self.dbReference, self.dataKey, value)
				
				-- Trigger appropriate save mechanisms
				if Phoenix_UI and Phoenix_UI.SaveDB then
					-- Check if this is a setting that needs immediate save
					local needsImmediateSave = self.dataKey and (
						self.dataKey:match("^general%.") or 
						self.dataKey:match("^theme") or 
						self.dataKey:match("^font") or
						self.dataKey:match("^display%.") or
						self.dataKey:match("^cosmetic%.") or
						self.dataKey:match("^automation%.") or
						self.dataKey:match("^nameplates%.") or
						self.dataKey:match("^actionbars%.") or 
						self.dataKey:match("^tooltip%.") or 
						self.dataKey:match("^mythicplus%.") or 
						self.dataKey:match("^map%.") or 
						self.dataKey:match("^chat%.") or 
						self.dataKey:match("^castbars%.") or 
						self.dataKey:match("^cooldowntracker%.") or 
						self.dataKey:match("^weakauras%.") or 
						self.dataKey:match("^msbt%.") or 
						self.dataKey:match("^buffs%.") or
						self.dataKey:match("^buffoverlay%.") or
						self.dataKey:match("^idtip%.") or
						self.dataKey:match("^misc%.")
					)
					
					if needsImmediateSave then
						Phoenix_UI:SaveDB()
					else
						-- Use a timer to batch multiple edits
						if not self.saveTimer then
							self.saveTimer = C_Timer.After(0.5, function()
								self.saveTimer = nil
								Phoenix_UI:SaveDB()
							end)
						end
					end
				end
			end
			
			return result
		end
	elseif info.type == 'textfield' then
		element = self:EditBox(frame, nil, 20);
		if info.text then
			element:SetText(info.text);
		end
		
		-- Apply the same validation improvement as for editBox
		local originalValidate = element.Validate
		element.Validate = function(self, ...)
			local result = originalValidate(self, ...)
			
			-- Save the value to database when validated
			if result and self.dbReference and self.dataKey then
				local value = self:GetValue()
				setDatabaseValue(self.dbReference, self.dataKey, value)
				
				-- Trigger appropriate save mechanisms
				if Phoenix_UI and Phoenix_UI.SaveDB then
					-- Check if this is a setting that needs immediate save
					local needsImmediateSave = self.dataKey and (
						self.dataKey:match("^general%.") or 
						self.dataKey:match("^theme") or 
						self.dataKey:match("^font") or
						self.dataKey:match("^display%.") or
						self.dataKey:match("^cosmetic%.") or
						self.dataKey:match("^automation%.") or
						self.dataKey:match("^nameplates%.") or
						self.dataKey:match("^actionbars%.") or 
						self.dataKey:match("^tooltip%.") or 
						self.dataKey:match("^mythicplus%.") or 
						self.dataKey:match("^map%.") or 
						self.dataKey:match("^chat%.") or 
						self.dataKey:match("^castbars%.") or 
						self.dataKey:match("^cooldowntracker%.") or 
						self.dataKey:match("^weakauras%.") or 
						self.dataKey:match("^msbt%.") or 
						self.dataKey:match("^buffs%.") or
						self.dataKey:match("^buffoverlay%.") or
						self.dataKey:match("^idtip%.") or
						self.dataKey:match("^misc%.")
					)
					
					if needsImmediateSave then
						Phoenix_UI:SaveDB()
					else
						-- Use a timer to batch multiple edits
						if not self.saveTimer then
							self.saveTimer = C_Timer.After(0.5, function()
								self.saveTimer = nil
								Phoenix_UI:SaveDB()
							end)
						end
					end
				end
			end
			
			return result
		end
	elseif info.type == 'text' then
		-- Map 'text' type to 'textfield' as they serve the same purpose
		element = self:EditBox(frame, nil, 20);
		
		-- Handle label/text that might be a function
		local textValue = nil
		if info.text then
			if type(info.text) == "function" then
				-- Safely call the function to get the text value
				local success, result = pcall(info.text)
				if success and result then
					textValue = result
				else
					textValue = ""
				end
			else
				textValue = info.text
			end
		elseif info.label then
			if type(info.label) == "function" then
				-- Safely call the function to get the text value
				local success, result = pcall(info.label)
				if success and result then
					textValue = result
				else
					textValue = ""
				end
			else
				textValue = info.label
			end
		end
		
		-- Set text if we have a value
		if textValue then
			element:SetText(textValue);
		end
		
		-- Apply the same validation improvement as for editBox
		local originalValidate = element.Validate
		element.Validate = function(self, ...)
			local result = originalValidate(self, ...)
			
			-- Save the value to database when validated
			if result and self.dbReference and self.dataKey then
				local value = self:GetValue()
				setDatabaseValue(self.dbReference, self.dataKey, value)
				
				-- Trigger appropriate save mechanisms
				if Phoenix_UI and Phoenix_UI.SaveDB then
					-- Check if this is a setting that needs immediate save
					local needsImmediateSave = self.dataKey and (
						self.dataKey:match("^general%.") or 
						self.dataKey:match("^theme") or 
						self.dataKey:match("^font") or
						self.dataKey:match("^display%.") or
						self.dataKey:match("^cosmetic%.") or
						self.dataKey:match("^automation%.") or
						self.dataKey:match("^nameplates%.") or
						self.dataKey:match("^actionbars%.") or 
						self.dataKey:match("^tooltip%.") or 
						self.dataKey:match("^mythicplus%.") or 
						self.dataKey:match("^map%.") or 
						self.dataKey:match("^chat%.") or 
						self.dataKey:match("^castbars%.") or 
						self.dataKey:match("^cooldowntracker%.") or 
						self.dataKey:match("^weakauras%.") or 
						self.dataKey:match("^msbt%.") or 
						self.dataKey:match("^buffs%.") or
						self.dataKey:match("^buffoverlay%.") or
						self.dataKey:match("^idtip%.") or
						self.dataKey:match("^misc%.")
					)
					
					if needsImmediateSave then
						Phoenix_UI:SaveDB()
					else
						-- Use a timer to batch multiple edits
						if not self.saveTimer then
							self.saveTimer = C_Timer.After(0.5, function()
								self.saveTimer = nil
								Phoenix_UI:SaveDB()
							end)
						end
					end
				end
			end
			
			return result
		end
	elseif info.type == 'multiLineBox' then
		element = self:MultiLineBox(frame, 300, info.height or 20, info.text or '');
	elseif info.type == 'dropdown' then
		local options = info.options
		if type(options) == "function" then
			options = options()
		end
		element = self:Dropdown(frame, 300, 20, options or {}, nil, info.multi or nil, info.assoc or false);
	elseif info.type == 'select' then
		-- Map 'select' type to 'dropdown' as they serve the same purpose
		local options = info.options or info.values
		if type(options) == "function" then
			options = options()
		end
		element = self:Dropdown(frame, 300, 20, options or {}, nil, info.multi or nil, info.assoc or false);
	elseif info.type == 'autocomplete' then
		element = self:Autocomplete(frame, 300, 20, '');

		if info.validator then
			element.validator = info.validator;
		end
		if info.transformer then
			element.transformer = info.transformer;
		end
		if info.buttonCreate then
			element.buttonCreate = info.buttonCreate;
		end
		if info.buttonUpdate then
			element.buttonUpdate = info.buttonUpdate;
		end
		if info.items then
			element:SetItems(info.items);
		end
	elseif info.type == 'slider' or info.type == 'sliderWithBox' then
		element = self:SliderWithBox(frame, nil, 32, 0, info.min or 0, info.max or 2);

		if info.precision then
			element:SetPrecision(info.precision);
		end
	elseif info.type == 'color' then
		element = self:ColorInput(frame, info.label, 100, 20, info.color, info.update, info.cancel);
	elseif info.type == 'colorpicker' then
		-- Add compatibility for colorpicker type (alias for color type)
		element = self:ColorInput(frame, info.label, 100, 20, info.initialValue or info.color, info.update, info.cancel);
		
		-- Set additional properties
		if info.hasAlpha ~= nil then
			element.hasAlpha = info.hasAlpha
		end
	elseif info.type == 'button' then
		element = self:Button(frame, nil, 20, info.text or '');

		if info.onClick then
			element:SetScript('OnClick', info.onClick);
		end
	elseif info.type == 'header' then
		-- Handle function-based label for header
		local headerText = info.label
		if type(info.label) == "function" then
			-- Safely call the function to get the label text
			local success, result = pcall(info.label)
			if success and result then
				headerText = result
			else
				headerText = ""
			end
		end
		element = self:Header(frame, headerText);
	elseif info.type == 'label' then
		-- Handle function-based label for label
		local labelText = info.label
		if type(info.label) == "function" then
			-- Safely call the function to get the label text
			local success, result = pcall(info.label)
			if success and result then
				labelText = result
			else
				labelText = ""
			end
		end
		element = self:CreateLabel(frame, labelText, frame:GetWidth());
		element:SetSize(info.width or 10, info.height or 10);
	elseif info.type == 'texture' then
		element = self:Texture(frame, info.width or 24, info.height or 24, info.texture);
	elseif info.type == 'panel' then  -- Containers
		element = self:Panel(frame, 300, 20);
	elseif info.type == 'scroll' then
		element = self:ScrollFrame(
			frame,
			300,
			info.height or 20,
			type(info.scrollChild) == 'table' and info.scrollChild or nil
		);
		if type(info.scrollChild) == 'function' then
			info.scrollChild(element);
		end
	elseif info.type == 'fauxScroll' then
		element = self:FauxScrollFrame(
			frame,
			300,
			info.height or 20,
			info.displayCount or 5,
			info.lineHeight or 22,
			type(info.scrollChild) == 'table' and info.scrollChild or nil
		);
		if type(info.scrollChild) == 'function' then
			info.scrollChild(element);
		end
	elseif info.type == 'tab' then
		element = self:TabPanel(
			frame,
			300,
			20,
			info.tabs or {},
			info.vertical or false,
			info.buttonWidth,
			info.buttonHeight
		);
	elseif info.type == 'custom' then
		element = info.createFunction(frame, row, info, dataKey, db);
	elseif info.type == 'spacer' then
		element = CreateFrame("Frame", nil, frame);
		element:SetSize(info.width or 10, info.height or 10);
	elseif info.type == 'group' then
		element = CreateFrame("Frame", nil, frame);
		element:SetSize(info.width or 300, info.height or 20);
		
		if info.inline then
			-- Inline groups are directly built in the parent
			if info.args then
				if type(info.args) == "function" then
					info.children = { rows = { [1] = info.args() } };
				else
					info.children = { rows = { [1] = info.args } };
				end
			end
		end
	elseif info.type == 'description' then
		-- Add support for description type (similar to label but with different styling)
		-- Handle function-based text/label for description
		local descText = ""
		
		if info.text then
			if type(info.text) == "function" then
				-- Safely call the function to get the text
				local success, result = pcall(info.text)
				if success and result then
					descText = result
				end
			else
				descText = info.text
			end
		elseif info.label then
			if type(info.label) == "function" then
				-- Safely call the function to get the label
				local success, result = pcall(info.label)
				if success and result then
					descText = result
				end
			else
				descText = info.label
			end
		end
		
		element = self:CreateLabel(frame, descText or "", frame:GetWidth());
		element:SetSize(info.width or frame:GetWidth(), info.height or 20);
		element:SetJustifyH("LEFT");
		
		-- Apply styling for description text
		if element.SetFont then
			local font, size, flags = element:GetFont()
			if font then
				element:SetFont(font, info.fontSize or size, info.fontStyle or flags)
			end
		end
		
		if Phoenix_UI and Phoenix_UI.ApplyTextShadow then
			Phoenix_UI:ApplyTextShadow(element)
		end
		
		-- Apply text color if provided
		if info.color then
			element:SetTextColor(info.color.r or 0.8, info.color.g or 0.8, info.color.b or 0.8, info.color.a or 1)
		else
			element:SetTextColor(0.8, 0.8, 0.8, 1)
		end
	elseif info.type == 'divider' then
		-- Add support for divider type (horizontal line with optional text)
		element = CreateFrame("Frame", nil, frame)
		element:SetSize(info.width or (frame:GetWidth() - 20), info.height or 20)
		
		-- Create the line texture
		local line = element:CreateTexture(nil, "ARTWORK")
		line:SetColorTexture(0.3, 0.3, 0.3, 0.8)
		line:SetSize(element:GetWidth(), 1)
		line:SetPoint("CENTER", element, "CENTER")
		
		-- Create label if text is provided
		if info.text then
			local dividerText = info.text
			if type(info.text) == "function" then
				-- Safely call the function to get the text
				local success, result = pcall(info.text)
				if success and result then
					dividerText = result
				else
					dividerText = ""
				end
			end
			
			local label = element:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetText(dividerText or "")
			label:SetPoint("CENTER", element, "CENTER")
			
			-- Add padding around the text
			local bgTexture = element:CreateTexture(nil, "ARTWORK")
			bgTexture:SetColorTexture(0, 0, 0, 0.8)
			bgTexture:SetPoint("TOPLEFT", label, "TOPLEFT", -5, 5)
			bgTexture:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 5, -5)
			
			element.label = label
		end
		
		element.line = line
	end

	if not element then
		print('Could not build element with type: ', info.type);
		return nil; -- Return early if element couldn't be created
	end

	-- Widgets can have initialization code
	if info.init then
		info.init(element);
	end

	element.dbReference = db;
	element.dataKey = dataKey;
	if info.onChange then
		element.onChange = info.onChange;
	end

	if element.hasLabel then
		hasLabel = true;
	end

	local canHaveLabel = info.type ~= 'checkbox' and
		info.type ~= 'header' and
		info.type ~= 'label' and
		info.type ~= 'color';

	if info.label and canHaveLabel then
		-- Handle function-based labels
		local labelText = info.label
		if type(info.label) == "function" then
			-- Safely call the function to get the label text
			local success, result = pcall(info.label)
			if success and result then
				labelText = result
			else
				labelText = ""
			end
		end
		
		if labelText then -- Only add label if we have valid text
			self:AddLabel(frame, element, labelText);
			hasLabel = true;
		end
	end

	if info.initialValue then
		if element.SetChecked then
			element:SetChecked(info.initialValue);
		elseif element.SetColor then
			element:SetColor(info.initialValue);
		elseif element.SetValue then
			element:SetValue(info.initialValue);
		end
	end

	-- Handle disabled state
	if info.disabled and element.Disable then
		element:Disable();
	end

	-- Setting onValueChanged disqualifies from any writes to database
	if info.onValueChanged then
		element.OnValueChanged = info.onValueChanged;
	elseif db then
		local iVal = getDatabaseValue(db, dataKey);

		if info.type == 'checkbox' then
			element:SetChecked(iVal)
		elseif element.SetColor then
			element:SetColor(iVal);
		elseif element.SetValue then
			element:SetValue(iVal);
		end

		element.OnValueChanged = genericChangeEvent;
	end

	-- Technically, every frame can be a container
	if info.children then
		self:BuildWindow(element, info.children);
		self:EasyLayout(element, { padding = { top = 10 } });

		element:SetScript('OnShow', function(of)
			of:DoLayout();
		end);
	end

	row:AddElement(element, {
		column = info.column or 12,
		fullSize = info.fullSize or false,
		fullHeight = info.fullHeight or false,
		margin = info.layoutMargins or {
			top = (hasLabel and 20 or 0)
		}
	});

	return element;
end

---BuildRow
--@param frame Frame
--@param info table
--@param db table
function Phoenix_UIConfig:BuildRow(frame, info, db)
	local row = frame:AddRow();

	for key, element in util.orderedPairs(info) do
		-- Skip elements that are nil or have invalid configuration
		if element then
			local dataKey = element.key or key or nil;

			local el = self:BuildElement(frame, row, element, dataKey, db);
			if el then
				if not frame.elements then
					frame.elements = {};
				end

				frame.elements[key] = el;
			end
		end
	end
end

---BuildWindow
--@param frame Frame
--@param info table
function Phoenix_UIConfig:BuildWindow(frame, info)
	if not info then
		print("Error: BuildWindow called with nil info")
		return
	end

	local db = info.database or nil;

	-- Check if rows exists and is a valid table
	if not info.rows or type(info.rows) ~= "table" then
		print("Error: BuildWindow requires valid rows table, got: " .. type(info.rows))
		return
	end
	
	local rows = info.rows;

	self:EasyLayout(frame, info.layoutConfig);

	for key, row in util.orderedPairs(rows) do
		-- Skip invalid rows
		if row and type(row) == "table" then 
			self:BuildRow(frame, row, db);
		else
			print("Error: Invalid row data at index " .. tostring(key))
		end
	end

	frame:DoLayout();
end

---DisableElement
--@param element Frame
function Phoenix_UIConfig:DisableElement(element)
	if element and element.Disable then
		element:Disable();
	end
end

---EnableElement
--@param element Frame
function Phoenix_UIConfig:EnableElement(element)
	if element and element.Enable then
		element:Enable();
	end
end

---SetElementDisabled
--@param element Frame
--@param disabled boolean
function Phoenix_UIConfig:SetElementDisabled(element, disabled)
	if not element then return end
	
	if disabled and element.Disable then
		element:Disable();
	elseif not disabled and element.Enable then
		element:Enable();
	end
end

---SetElementDisabledIf
--@param element Frame
--@param condition function or boolean
function Phoenix_UIConfig:SetElementDisabledIf(element, condition)
	if not element then return end
	
	local disabled = false;
	if type(condition) == "function" then
		disabled = condition();
	else
		disabled = condition;
	end
	
	self:SetElementDisabled(element, disabled);
end

---SetContainerElementsDisabled
--@param container Frame
--@param disabled boolean
--@param recursive boolean (optional) Whether to process child containers
function Phoenix_UIConfig:SetContainerElementsDisabled(container, disabled, recursive)
	if not container or not container.elements then return end
	
	for _, element in pairs(container.elements) do
		self:SetElementDisabled(element, disabled);
		
		-- If this element is also a container and recursive is true, process its elements
		if recursive and element.elements then
			self:SetContainerElementsDisabled(element, disabled, recursive);
		end
	end
end

function Phoenix_UIConfig:OnValueChanged(info, value)
	local key = table.concat(info, ".")
	local db = self.db
	
	-- Update the database value
	setDatabaseValue(db, key, value)
	
	-- Determine if this is an important setting that requires immediate save
	local isImportantSetting = key:match("^general%.") or key:match("^display%.") or 
	                           key:match("^theme") or key:match("^font") or key:match("^profile") or
	                           key:match("^cosmetic%.") or key:match("^automation%.") or
                               key:match("^nameplates%.") or key:match("^actionbars%.") or 
                               key:match("^tooltip%.") or key:match("^mythicplus%.") or 
                               key:match("^map%.") or key:match("^chat%.") or key:match("^castbars%.") or 
                               key:match("^cooldowntracker%.") or key:match("^weakauras%.") or 
                               key:match("^msbt%.") or key:match("^buffs%.") or key:match("^buffoverlay%.") or
                               key:match("^idtip%.") or key:match("^misc%.")
	
	-- Trigger Phoenix_UI to save the database if available
	if Phoenix_UI and Phoenix_UI.SaveDB then
		if isImportantSetting then
			-- Immediate save for critical settings
			Phoenix_UI:SaveDB()
			
			-- Force an immediate write to disk for critical settings
			if _G.FlushSettingsDB then
				_G.FlushSettingsDB()
			elseif _G.FlushSavedVariables then
				_G.FlushSavedVariables()
			end
		else
			-- Short delay for other settings to batch multiple rapid changes
			if not self.saveTimer then
				self.saveTimer = C_Timer.After(0.2, function()
					self.saveTimer = nil
					Phoenix_UI:SaveDB()
				end)
			end
		end
	end
	
	-- Send a message that settings have changed
	if Phoenix_UI and Phoenix_UI.SendMessage then
		Phoenix_UI:SendMessage("PHOENIX_UI_SETTING_CHANGED", key, value)
	end
	
	-- Force refresh config for UI-affecting settings
	if isImportantSetting and Phoenix_UI and Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
		C_Timer.After(0.3, function()
			Phoenix_UI.UI:RefreshConfig()
		end)
	end
end

-- Global function to ensure settings are properly saved to disk
function Phoenix_UIConfig:SaveSettings()
    -- Get the database
    local Phoenix_UI = _G.Phoenix_UI
    if not Phoenix_UI or not Phoenix_UI.db then return end
    
    -- Force a database save
    if Phoenix_UI.SaveDB then
        Phoenix_UI:SaveDB()
        
        -- Ensure it's written to disk
        if FlushSavedVariables then
            FlushSavedVariables()
        elseif FlushSettingsDB then
            FlushSettingsDB()
        end
    end
    
    -- Also trigger UI refresh if available
    if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
        C_Timer.After(0.1, function()
            Phoenix_UI.UI:RefreshConfig()
        end)
    end
end

-- Hook into the default widget value change handlers to ensure proper saving
local originalOnValueChanged = Phoenix_UIConfig.Util.OnValueChanged
if originalOnValueChanged then
    Phoenix_UIConfig.Util.OnValueChanged = function(self, ...)
        local result = originalOnValueChanged(self, ...)
        Phoenix_UIConfig:SaveSettings()
        return result
    end
end

Phoenix_UIConfig:RegisterModule(module, version);



