--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Checkbox', 5;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then
	return
end

----------------------------------------------------
--- Helpers
----------------------------------------------------

-- Helper function to safely call original widget methods
local function callOriginalMethod(self, methodName, arg1, arg2, arg3)
	-- Skip if self is nil
	if not self then return end
	
	-- Store the current implementation
	local ourMethod = self[methodName]
	
	-- Try different approaches to call the original method
	local success = pcall(function()
		-- Try metatable approach first
		local mt = getmetatable(self)
		if mt and mt.__index and mt.__index[methodName] then
			-- Call through metatable
			if arg3 ~= nil then
				mt.__index[methodName](self, arg1, arg2, arg3)
			elseif arg2 ~= nil then
				mt.__index[methodName](self, arg1, arg2)
			elseif arg1 ~= nil then
				mt.__index[methodName](self, arg1)
			else
				mt.__index[methodName](self)
			end
			return
		end
		
		-- Try looking for super/parent implementation
		if self.__super and self.__super[methodName] then
			-- Call through super
			if arg3 ~= nil then
				self.__super[methodName](self, arg1, arg2, arg3)
			elseif arg2 ~= nil then
				self.__super[methodName](self, arg1, arg2)
			elseif arg1 ~= nil then
				self.__super[methodName](self, arg1)
			else
				self.__super[methodName](self)
			end
			return
		end
		
		-- Last resort: temporarily replace our method
		if ourMethod then
			-- Remove our implementation
			self[methodName] = nil
			
			-- Check if there's a method now
			if self[methodName] then
				-- Call the method that was revealed
				if arg3 ~= nil then
					self[methodName](self, arg1, arg2, arg3)
				elseif arg2 ~= nil then
					self[methodName](self, arg1, arg2)
				elseif arg1 ~= nil then
					self[methodName](self, arg1)
				else
					self[methodName](self)
				end
			end
			
			-- Restore our implementation
			self[methodName] = ourMethod
		end
	end)
end

----------------------------------------------------
--- Checkbox
----------------------------------------------------

local CheckboxMethods = {
	--- Set checkbox state
	---
	--- @param flag boolean
	--- @param internal boolean - indicates to not run OnValueChanged
	SetCheckedState = function(self, flag, internal)
		self.isChecked = flag;
		self.check:SetShown(flag);
		
		if not internal and self.OnValueChanged then
			self:OnValueChanged(flag, self.value);
		end
	end,

	GetChecked = function(self)
		return self.isChecked;
	end,

	SetText = function(self, t)
		if self.text then
			self.text:SetText(t);
		end
	end,

	SetValue = function(self, value)
		self.value = value;
	end,

	GetValue = function(self)
		if self.isChecked then
			return self.value;
		else
			return nil;
		end
	end,

	Disable = function(self)
		self.isDisabled = true;
		self.box:SetAlpha(0.5);
		if self.text then
			self.text:SetTextColor(0.5, 0.5, 0.5);
		end
	end,

	Enable = function(self)
		self.isDisabled = false;
		self.box:SetAlpha(1.0);
		if self.text then
			self.text:SetTextColor(1, 1, 1);
		end
	end,

	AutoWidth = function(self)
		if self.text then
			self:SetWidth(16 + self.text:GetWidth() + 8);
		end
	end,
	
	-- Alias for compatibility
	SetChecked = function(self, flag, internal)
		self:SetCheckedState(flag, internal);
	end
};

local CheckboxEvents = {
	OnClick = function(self, button)
		if button == "LeftButton" and not self.isDisabled then
			-- Force the check state to change
			self:SetCheckedState(not self:GetChecked(), false);
		end
	end
}

--@return CheckButton
function Phoenix_UIConfig:Checkbox(parent, text, width, height, tooltip)
	-- Create a simple button-based checkbox for better control and performance
	local checkbox = CreateFrame('Button', nil, parent);
	checkbox.Phoenix_UIConfig = self;

	-- Size and initialize
	self:SetObjSize(checkbox, width or 16, height or 16);
	self:InitWidget(checkbox);
	checkbox:EnableMouse(true);
	
	-- Create the checkbox box
	checkbox.box = CreateFrame('Frame', nil, checkbox);
	checkbox.box:SetSize(16, 16);
	checkbox.box:SetPoint('LEFT', 0, 0);
	self:ApplyBackdrop(checkbox.box, 'dropdown', 'border');
	
	-- Create the check texture
	checkbox.check = checkbox.box:CreateTexture(nil, 'ARTWORK');
	checkbox.check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]]);
	checkbox.check:SetAllPoints(checkbox.box);
	checkbox.check:Hide();
	
	-- Store value and state
	checkbox.value = true;
	checkbox.isChecked = false;
	checkbox.isDisabled = false;
	
	-- Add text
	if text then
		checkbox.text = self:Label(checkbox, text);
		checkbox.text:SetPoint('LEFT', checkbox.box, 'RIGHT', 5, 0);
		
		if width == nil then
			checkbox:SetWidth(16 + checkbox.text:GetWidth() + 8);
		end
	end
	
	-- Add our methods
	for k, v in pairs(CheckboxMethods) do
		checkbox[k] = v;
	end
	
	-- Add tooltip if provided
	if (tooltip) then 
		self:FrameTooltip(checkbox, tooltip, 'simp_tooltip', 'TOP', true);
	end
	
	-- Set up click handling
	checkbox:SetScript('OnClick', function(self)
		if not self.isDisabled then
			self.isChecked = not self.isChecked;
			self.check:SetShown(self.isChecked);
			
			if self.OnValueChanged then
				self.OnValueChanged(self, self.isChecked, self.value);
			end
			
			-- Only save if not already in a config panel that handles saving
			if Phoenix_UI and not (Phoenix_UI.UI and Phoenix_UI.UI:IsVisible()) then
				-- Try to use InstantSave first (preferred method for immediate saving)
				if Phoenix_UI.InstantSave and self.dbReference and self.dataKey then
					-- Extract module name from the dataKey (first part before the dot)
					local moduleName = self.dataKey:match("^([^%.]+)")
					if moduleName then
						-- Extract the key from the dataKey (everything after the dot)
						local key = self.dataKey:match("^[^%.]+%.(.+)$")
						if key then
							-- Save immediately using the new InstantSave function
							Phoenix_UI:InstantSave(moduleName, key, self.isChecked)
							
							-- Also refresh if needed
							if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
								C_Timer.After(0.1, function()
									Phoenix_UI.UI:RefreshConfig()
								end)
							end
						else
							-- Fallback to direct setting if key can't be parsed
							if Phoenix_UIConfig and Phoenix_UIConfig.setDatabaseValue then
								Phoenix_UIConfig:setDatabaseValue(self.dbReference, self.dataKey, self.isChecked)
							end
							
							-- Use delayed timer for fallback saving
							if not self.saveTimer and Phoenix_UI.SaveDB then
								self.saveTimer = C_Timer.After(0.5, function()
									self.saveTimer = nil
									Phoenix_UI:SaveDB()
									
									-- Also refresh if needed
									if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
										Phoenix_UI.UI:RefreshConfig()
									end
								end)
							end
						end
					else
						-- Fallback for legacy widgets without proper key format
						if not self.saveTimer and Phoenix_UI.SaveDB then
							self.saveTimer = C_Timer.After(0.5, function()
								self.saveTimer = nil
								Phoenix_UI:SaveDB()
								
								-- Also refresh if needed
								if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
									Phoenix_UI.UI:RefreshConfig()
								end
							end)
						end
					end
				else
					-- Traditional delayed saving as fallback
					if not self.saveTimer and Phoenix_UI.SaveDB then
						self.saveTimer = C_Timer.After(0.5, function()
							self.saveTimer = nil
							Phoenix_UI:SaveDB()
							
							-- Also refresh if needed
							if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
								Phoenix_UI.UI:RefreshConfig()
							end
						end)
					end
				end
			else
				-- If we're in a config panel, register this change in the UI's pending changes
				if Phoenix_UI and Phoenix_UI.UI and self.dbReference and self.dataKey then
					-- Ensure pendingChanges exists
					Phoenix_UI.UI.pendingChanges = Phoenix_UI.UI.pendingChanges or {}
					
					-- Register this element as having pending changes
					Phoenix_UI.UI.pendingChanges[self] = true
					
					-- Also directly update the database value for redundancy
					if Phoenix_UIConfig and Phoenix_UIConfig.setDatabaseValue then
						-- Ensure we pass the dataKey as a string, not a table or other type
						local dataKey = self.dataKey
						if type(dataKey) == "string" then
							Phoenix_UIConfig:setDatabaseValue(self.dbReference, dataKey, self.isChecked)
							
							-- Try to use InstantSave for immediate persistence if available
							if Phoenix_UI.InstantSave then
								local moduleName = dataKey:match("^([^%.]+)")
								local key = dataKey:match("^[^%.]+%.(.+)$")
								if moduleName and key then
									Phoenix_UI:InstantSave(moduleName, key, self.isChecked)
								end
							end
						else
							print("Phoenix_UI: Warning - invalid dataKey type in checkbox:", type(dataKey))
						end
					end
					
					-- Queue a save operation if not already pending
					if Phoenix_UI.UI.QueueSave then
						Phoenix_UI.UI:QueueSave()
					end
				end
			end
		end
	end);

	return checkbox;
end

----------------------------------------------------
--- IconCheckbox
----------------------------------------------------

function Phoenix_UIConfig:IconCheckbox(parent, icon, text, width, height, iconSize)
	iconSize = iconSize or 16
	local checkbox = self:Checkbox(parent, text, width, height);
	
	-- Add the icon
	checkbox.icon = self:Texture(checkbox, iconSize, iconSize, icon);
	checkbox.icon:SetPoint('LEFT', checkbox, 'RIGHT', 2, 0);

	-- Reposition the text if it exists
	if checkbox.text then
		checkbox.text:ClearAllPoints();
		checkbox.text:SetPoint('LEFT', checkbox.icon, 'RIGHT', 5, 0);
		
		if width == nil then
			checkbox:SetWidth(checkbox:GetWidth() + iconSize + 5);
		end
	end

	return checkbox;
end

----------------------------------------------------
--- Radio
----------------------------------------------------

local RadioEvents = {
	OnClick = function(self)
		if not self.isDisabled then
			self:SetChecked(true);
		end
	end
};

--@return CheckButton
function Phoenix_UIConfig:Radio(parent, text, groupName, width, height)
	-- Create a simple button-based radio button
	local radio = CreateFrame('Button', nil, parent);
	radio.Phoenix_UIConfig = self;
	
	-- Size and initialize
	self:SetObjSize(radio, width or 16, height or 16);
	self:InitWidget(radio);
	radio:EnableMouse(true);
	
	-- Create the radio button circle
	radio.box = CreateFrame('Frame', nil, radio);
	radio.box:SetSize(16, 16);
	radio.box:SetPoint('LEFT', 0, 0);
	self:ApplyBackdrop(radio.box, 'dropdown', 'border');
	radio.box:SetBackdropBorderColor(0.6, 0.6, 0.6);
	
	-- Create a check mark texture
	radio.check = radio.box:CreateTexture(nil, 'ARTWORK');
	radio.check:SetTexture([[Interface\Buttons\UI-RadioButton]]);
	radio.check:SetTexCoord(0.25, 0.5, 0, 1);
	radio.check:SetAllPoints(radio.box);
	radio.check:Hide();
	
	-- Store value and state
	radio.value = true;
	radio.isChecked = false;
	radio.isDisabled = false;
	
	-- Add text
	if text then
		radio.text = self:Label(radio, text);
		radio.text:SetPoint('LEFT', radio.box, 'RIGHT', 5, 0);
		
		if width == nil then
			radio:SetWidth(16 + radio.text:GetWidth() + 8);
		end
	end
	
	-- Add our methods
	for k, v in pairs(CheckboxMethods) do
		radio[k] = v;
	end
	
	-- Add tooltip if provided
	if tooltip then
		self:FrameTooltip(radio, tooltip, 'simp_tooltip', 'TOP', true);
	end
	
	-- Set up click handling
	radio:SetScript('OnClick', function(self)
		if not self.isDisabled then
			-- Always set to checked for radio buttons
			self.isChecked = true;
			self.check:Show();
			
			-- If part of a group, uncheck others
			if self.radioGroup then
				for i = 1, #self.radioGroup do
					if self.radioGroup[i] ~= self then
						self.radioGroup[i].isChecked = false;
						self.radioGroup[i].check:Hide();
					end
				end
			end
			
			if self.OnValueChanged then
				self.OnValueChanged(self, true, self.value);
			end
		end
	end);
	
	if groupName then
		self:AddToRadioGroup(radio, groupName);
	end
	
	return radio;
end

Phoenix_UIConfig.radioGroups = {};
Phoenix_UIConfig.radioGroupValues = {};

--@return CheckButton[]
function Phoenix_UIConfig:RadioGroup(groupName)
	if not self.radioGroups[groupName] then
		self.radioGroups[groupName] = {};
	end

	if not self.radioGroupValues[groupName] then
		self.radioGroupValues[groupName] = {};
	end

	return self.radioGroups[groupName];
end

function Phoenix_UIConfig:GetRadioGroupValue(groupName)
	local group = self:RadioGroup(groupName);

	for i = 1, #group do
		local radio = group[i];
		if radio.isChecked then
			return radio.value;
		end
	end

	return nil;
end

function Phoenix_UIConfig:SetRadioGroupValue(groupName, value)
	local group = self:RadioGroup(groupName);

	for i = 1, #group do
		local radio = group[i];
		radio:SetCheckedState(radio.value == value, true);
	end

	return nil;
end

local radioGroupOnValueChanged = function(radio)
	radio.notified = true;
	local group = radio.radioGroup;
	local groupName = radio.radioGroupName;

	-- We must get all notifications from group
	for i = 1, #group do
		if not group[i].notified then
			return
		end
	end

	local newValue = radio.Phoenix_UIConfig:GetRadioGroupValue(groupName);
	if radio.Phoenix_UIConfig.radioGroupValues[groupName] ~= newValue then
		radio.OnValueChangedCallback(newValue, groupName);
	end
	radio.Phoenix_UIConfig.radioGroupValues[groupName] = newValue;

	for i = 1, #group do
		group[i].notified = false;
	end
end

function Phoenix_UIConfig:AddToRadioGroup(radio, groupName, valueChangedCallback)
	local group = self:RadioGroup(groupName);

	TableInsert(group, radio);
	radio.radioGroup = group;
	radio.radioGroupName = groupName;
	radio.Phoenix_UIConfig = self;

	radio.OnValueChangedCallback = valueChangedCallback or function(value, group) end;

	radio.oldOnValueChanged = radio.OnValueChanged;
	radio.OnValueChanged = function(r, isChecked, value)
		if r.oldOnValueChanged then
			r:oldOnValueChanged(isChecked, r.value);
		end

		if isChecked then
			-- Uncheck all others visually
			for i = 1, #r.radioGroup do
				if r.radioGroup[i] ~= r then
					r.radioGroup[i].isChecked = false;
					if r.radioGroup[i].check then
						r.radioGroup[i].check:Hide();
					end
				end
			end
		end

		radioGroupOnValueChanged(r);
	end
end

Phoenix_UIConfig:RegisterModule(module, version);



