local MAJOR, MINOR = 'Phoenix_UIConfig', 10;
--- @class Phoenix_UIConfig
local Phoenix_UIConfig = LibStub:NewLibrary(MAJOR, MINOR);

if not Phoenix_UIConfig then
	return
end

-- Initialize the Util namespace
Phoenix_UIConfig.Util = Phoenix_UIConfig.Util or {}

-- Create a default OnValueChanged function
Phoenix_UIConfig.Util.OnValueChanged = Phoenix_UIConfig.Util.OnValueChanged or function(self, ...)
	-- Default implementation - just pass through the value
	return ...
end

-- Define the SaveSetting function before using it
Phoenix_UIConfig.Util.SaveSetting = function(widget, value)
	-- Save the value to the database if possible
	if widget and widget.dbReference and widget.dataKey then
		-- Split the key into parts for nested tables
		local subkeys = {}
		for part in string.gmatch(widget.dataKey, "[^.]+") do
			table.insert(subkeys, part)
		end
		
		-- Navigate to the correct DB location
		local ref = widget.dbReference
		for i = 1, #subkeys - 1 do
			if not ref[subkeys[i]] then
				ref[subkeys[i]] = {}
			end
			ref = ref[subkeys[i]]
		end
		
		-- Set the value
		ref[subkeys[#subkeys]] = value
		
		-- Force save to disk using the most reliable method available
		local Phoenix_UI = _G.Phoenix_UI
		if Phoenix_UI then
			pcall(function()
				-- Try to use InstantSave first (most reliable)
				if Phoenix_UI.InstantSave and #subkeys >= 1 then
					local moduleName = subkeys[1]
					local key = ""
					
					-- Build the key path after the module name
					if #subkeys > 1 then
						for i = 2, #subkeys - 1 do
							key = key .. subkeys[i] .. "."
						end
						key = key .. subkeys[#subkeys]
					else
						key = subkeys[#subkeys]
					end
					
					-- Use InstantSave for immediate reliable saving
					Phoenix_UI:InstantSave(moduleName, key, value)
					
					-- Also mark save as needed for the auto-save guard
					if Phoenix_UI.MarkSaveNeeded then
						Phoenix_UI:MarkSaveNeeded()
					end
				else
					-- Fallback to traditional saving
					if Phoenix_UI.SaveDB then
						Phoenix_UI:SaveDB()
					end
				end
				
				-- Ensure it's written to disk
				if FlushSettingsDB then
					FlushSettingsDB()
				elseif FlushSavedVariables then
					FlushSavedVariables()
				end
				
				-- Trigger UI refresh if needed
				if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
					C_Timer.After(0.1, function()
						Phoenix_UI.UI:RefreshConfig()
					end)
				end
			end)
		end
	end
end

-- Now create the OnValueChanged hook with proper error handling
local function hookOnValueChanged()
	local originalOnValueChanged = Phoenix_UIConfig.Util.OnValueChanged
	if originalOnValueChanged then
		Phoenix_UIConfig.Util.OnValueChanged = function(self, ...)
			local success, result = pcall(function(...) return originalOnValueChanged(self, ...) end, ...)
			
			-- Ensure the value is properly saved to the database with error handling
			pcall(function()
				if self.dbReference and self.dataKey then
					local value
					if self.GetChecked then
						value = self:GetChecked()
					elseif self.GetColor then
						value = self:GetColor()
					elseif self.GetValue then
						value = self:GetValue()
					end
					
					if value ~= nil then
						Phoenix_UIConfig.Util.SaveSetting(self, value)
					end
				end
			end)
			
			if success then
				return result
			end
		end
	end
end

-- Call the hook function to install it
hookOnValueChanged()

-- Add improved database value setting function
function Phoenix_UIConfig:setDatabaseValue(db, key, value)
	if not db or not key then return false end
	
	-- Parse the key into component parts
	local parts = {}
	for part in string.gmatch(key, "[^.]+") do
		table.insert(parts, part)
	end
	
	-- Get module name (first component)
	local moduleName = parts[1]
	
	-- Try to use InstantSave if available (preferred method)
	local Phoenix_UI = _G.Phoenix_UI
	if Phoenix_UI and Phoenix_UI.InstantSave and moduleName and #parts > 1 then
		-- Extract the key part after module name
		local subKey = key:match("^[^%.]+%.(.+)$")
		if subKey then
			-- Use InstantSave directly
			return Phoenix_UI:InstantSave(moduleName, subKey, value)
		end
	end
	
	-- Fallback to traditional method if InstantSave not available or key doesn't have module prefix
	local current = db
	for i = 1, #parts - 1 do
		if not current[parts[i]] then
			current[parts[i]] = {}
		elseif type(current[parts[i]]) ~= "table" then
			-- Replace with table if not already a table
			current[parts[i]] = {}
		end
		current = current[parts[i]]
	end
	
	-- Set the value
	current[parts[#parts]] = value
	
	-- Mark module as updated if possible
	if moduleName and Phoenix_UI and Phoenix_UI.db and 
	   Phoenix_UI.db.profile and Phoenix_UI.db.profile[moduleName] then
		Phoenix_UI.db.profile[moduleName].__updated = GetTime()
		Phoenix_UI.db.profile[moduleName].__saved_from = "db_direct_set"
	end
	
	-- Mark save as needed for auto-save system
	if Phoenix_UI and Phoenix_UI.MarkSaveNeeded then
		Phoenix_UI:MarkSaveNeeded()
	end
	
	-- Attempt to trigger save
	if Phoenix_UI and Phoenix_UI.SaveDB then
		C_Timer.After(0.5, function() 
			pcall(function() Phoenix_UI:SaveDB() end)
		end)
	end
	
	return true
end

local TableInsert = tinsert;

Phoenix_UIConfig.moduleVersions = {};
if not Phoenix_UIConfigInstances then
	Phoenix_UIConfigInstances = {Phoenix_UIConfig};
else
	TableInsert(Phoenix_UIConfigInstances, Phoenix_UIConfig);
end

function Phoenix_UIConfig:NewInstance()
	local instance = CopyTable(self);
	instance:ResetConfig();
	TableInsert(Phoenix_UIConfigInstances, instance);
	return instance;
end

function Phoenix_UIConfig:RegisterModule(module, version)
	self.moduleVersions[module] = version;
end

function Phoenix_UIConfig:UpgradeNeeded(module, version)
	if not self.moduleVersions[module] then
		return true;
	end

	return self.moduleVersions[module] < version;
end

function Phoenix_UIConfig:RegisterWidget(name, func)
	if not self[name] then
		self[name] = func;
		return true;
	end

	return false;
end

function Phoenix_UIConfig:InitWidget(widget)
	widget.isWidget = true;

	function widget:GetChildrenWidgets()
		local children = {widget:GetChildren()};
		local result = {};
		for i = 1, #children do
			local child = children[i];
			if child.isWidget then
				TableInsert(result, child);
			end
		end

		return result;
	end
end

function Phoenix_UIConfig:SetObjSize(obj, width, height)
	if width then
		obj:SetWidth(width);
	end

	if height then
		obj:SetHeight(height);
	end
end

function Phoenix_UIConfig:SetTextColor(fontString, colorType)
	colorType = colorType or 'normal';
	if fontString.SetTextColor then
		local c = self.config.font.color[colorType];
		fontString:SetTextColor(c.r, c.g, c.b, c.a);
	end
end

-- Define improved handlers for button hover effects with fire-themed visuals
local function CreateFireEffect(button)
	-- Don't create effects if the button already has them
	if button.fireGlow then return end
	
	-- Create a glow effect
	button.fireGlow = button:CreateTexture(nil, "ARTWORK", nil, -1)
	button.fireGlow:SetPoint("CENTER")
	button.fireGlow:SetSize(button:GetWidth() * 1.3, button:GetHeight() * 1.3)
	button.fireGlow:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\FireGlow")
	button.fireGlow:SetBlendMode("ADD")
	button.fireGlow:SetAlpha(0)
	
	-- Create ember particles
	button.embers = {}
	for i = 1, 2 do
		local ember = button:CreateTexture(nil, "ARTWORK", nil, -1)
		ember:SetSize(button:GetHeight() * 0.4, button:GetHeight() * 0.4)
		
		-- Position randomly around the button
		local xOffset = (math.random() * button:GetWidth() * 0.8) - (button:GetWidth() * 0.4)
		local yOffset = (math.random() * button:GetHeight() * 0.6) - (button:GetHeight() * 0.3)
		ember:SetPoint("CENTER", button, "CENTER", xOffset, yOffset)
		
		ember:SetTexture("Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Effects\\Ember")
		ember:SetBlendMode("ADD")
		ember:SetAlpha(0)
		
		button.embers[i] = ember
	end
end

-- Improved enter/leave handlers for fire effects
local function ButtonOnEnter(self)
	if self.isDisabled then return end
	
	-- Get theme info if Phoenix_UI is available
	local theme = nil
	if _G.Phoenix_UI and _G.Phoenix_UI.themes and _G.Phoenix_UI.currentTheme then
		theme = _G.Phoenix_UI.themes[_G.Phoenix_UI.currentTheme]
	end
	
	-- Check if using Phoenix Flame theme
	local isPhoenixFlame = theme and theme.name == "Phoenix Flame"
	
	-- Apply highlight border effect
	if self.SetHighlightBorder then
		self:SetHighlightBorder()
	end
	
	-- Apply special fire effects for Phoenix Flame theme
	if isPhoenixFlame and theme.effects and theme.effects.enableGlow then
		CreateFireEffect(self)
		
		-- Animate the glow
		if self.fireGlow then
			self.fireGlow:SetVertexColor(theme.colors.primary.r, theme.colors.primary.g * 0.6, theme.colors.primary.b * 0.3)
			
			-- Create fade-in animation
			local fadeInfo = {}
			fadeInfo.mode = "IN"
			fadeInfo.timeToFade = 0.3
			fadeInfo.startAlpha = 0
			fadeInfo.endAlpha = 0.5
			fadeInfo.finishedFunc = function()
				-- Add subtle pulsing animation
				if not self.glowAnimGroup then
					self.glowAnimGroup = self.fireGlow:CreateAnimationGroup()
					self.glowAnimGroup:SetLooping("REPEAT")
					
					local grow = self.glowAnimGroup:CreateAnimation("Scale")
					grow:SetScale(1.1, 1.1)
					grow:SetDuration(1.2)
					grow:SetSmoothing("IN_OUT")
					grow:SetOrder(1)
					
					local shrink = self.glowAnimGroup:CreateAnimation("Scale")
					shrink:SetScale(1/1.1, 1/1.1)
					shrink:SetDuration(1.2)
					shrink:SetSmoothing("IN_OUT")
					shrink:SetOrder(2)
				end
				
				self.glowAnimGroup:Play()
			end
			
			UIFrameFade(self.fireGlow, fadeInfo)
			
			-- Animate embers
			for i, ember in ipairs(self.embers) do
				local emberFade = {}
				emberFade.mode = "IN"
				emberFade.timeToFade = 0.3 + (i * 0.1)
				emberFade.startAlpha = 0
				emberFade.endAlpha = 0.7
				emberFade.finishedFunc = function()
					-- Add ember movement animation
					if not ember.animGroup then
						ember.animGroup = ember:CreateAnimationGroup()
						ember.animGroup:SetLooping("REPEAT")
						
						-- Random movement
						local travel = ember.animGroup:CreateAnimation("Translation")
						travel:SetOffset(math.random(-8, 8), math.random(3, 15))
						travel:SetDuration(1.0 + math.random() * 0.5)
						travel:SetSmoothing("IN")
						travel:SetOrder(1)
						
						-- Fade out at peak
						local fade = ember.animGroup:CreateAnimation("Alpha")
						fade:SetFromAlpha(0.7)
						fade:SetToAlpha(0)
						fade:SetDuration(1.0 + math.random() * 0.5)
						fade:SetSmoothing("OUT")
						fade:SetOrder(1)
						
						-- Reset position after fade
						local reset = ember.animGroup:CreateAnimation("Translation")
						reset:SetOffset(0, 0)
						reset:SetDuration(0)
						reset:SetOrder(2)
						
						-- Reset alpha
						local resetAlpha = ember.animGroup:CreateAnimation("Alpha")
						resetAlpha:SetFromAlpha(0)
						resetAlpha:SetToAlpha(0.7)
						resetAlpha:SetDuration(0)
						resetAlpha:SetOrder(2)
					end
					
					ember.animGroup:Play()
				end
				
				UIFrameFade(ember, emberFade)
			end
		end
	end
end

local function ButtonOnLeave(self)
	if self.isDisabled then return end
	
	-- Restore original border color
	if self.origBackdropBorderColor then
		if self.SetBackdropBorderColor then
			self:SetBackdropBorderColor(unpack(self.origBackdropBorderColor))
		end
		self.origBackdropBorderColor = nil
	end
	
	-- Hide fire effects
	if self.fireGlow then
		-- Stop animations
		if self.glowAnimGroup then
			self.glowAnimGroup:Stop()
		end
		
		-- Fade out glow
		UIFrameFadeOut(self.fireGlow, 0.2, self.fireGlow:GetAlpha(), 0)
		
		-- Fade out and stop ember animations
		for _, ember in ipairs(self.embers) do
			if ember.animGroup then
				ember.animGroup:Stop()
			end
			UIFrameFadeOut(ember, 0.2, ember:GetAlpha(), 0)
		end
	end
end

-- Replace the original SetHighlightBorder with our enhanced version
Phoenix_UIConfig.SetHighlightBorder = function(self)
	if self.target then
		self = self.target
	end

	if self.isDisabled then
		return
	end
	
	-- Only proceed if this object supports backdrops
	if not self.GetBackdropBorderColor or not self.SetBackdropBorderColor then
		return
	end

	-- Get theme info if Phoenix_UI is available
	local theme = nil
	if _G.Phoenix_UI and _G.Phoenix_UI.themes and _G.Phoenix_UI.currentTheme then
		theme = _G.Phoenix_UI.themes[_G.Phoenix_UI.currentTheme]
	end
	
	if not self.Phoenix_UIConfig then
		-- Object doesn't have Phoenix_UIConfig reference, use default color
		if not self.origBackdropBorderColor then
			self.origBackdropBorderColor = {self:GetBackdropBorderColor()}
		end
		
		if theme and theme.colors and theme.colors.highlight then
			self:SetBackdropBorderColor(
				theme.colors.highlight.r, 
				theme.colors.highlight.g, 
				theme.colors.highlight.b, 
				1
			)
		else
			self:SetBackdropBorderColor(1, 1, 0, 1) -- Default yellow highlight
		end
		return
	end

	local hc = self.Phoenix_UIConfig.config.highlight.color
	if not self.origBackdropBorderColor then
		self.origBackdropBorderColor = {self:GetBackdropBorderColor()}
	end
	self:SetBackdropBorderColor(hc.r, hc.g, hc.b, 1)
end

-- Add the missing ResetHighlightBorder function
Phoenix_UIConfig.ResetHighlightBorder = function(self)
	if self.target then
		self = self.target
	end
	
	-- Only proceed if this object supports backdrops and we stored original colors
	if not self.SetBackdropBorderColor or not self.origBackdropBorderColor then
		return
	end
	
	-- Restore original border color
	self:SetBackdropBorderColor(
		self.origBackdropBorderColor[1], 
		self.origBackdropBorderColor[2], 
		self.origBackdropBorderColor[3], 
		self.origBackdropBorderColor[4] or 1
	)
	
	-- Stop any fire/glow effects if using the Phoenix Flame theme
	if self.fireGlow then
		-- Stop animation group if it exists
		if self.glowAnimGroup then
			self.glowAnimGroup:Stop()
		end
		
		-- Fade out the glow
		UIFrameFadeOut(self.fireGlow, 0.2, self.fireGlow:GetAlpha(), 0)
	end
	
	-- Also stop ember animations if they exist
	if self.embers then
		for _, ember in ipairs(self.embers) do
			if ember.animGroup then
				ember.animGroup:Stop()
			end
			UIFrameFadeOut(ember, 0.2, ember:GetAlpha(), 0)
		end
	end
end

function Phoenix_UIConfig:HookHoverBorder(object)
	if not object.SetBackdrop then
		return
	end
	
	Mixin(object, BackdropTemplateMixin)
	
	-- Ensure the object has a reference to Phoenix_UIConfig
	object.Phoenix_UIConfig = self;
	
	-- Fix: Pass function directly and capture the object in the function scope
	object:HookScript('OnEnter', function(frame)
		self.SetHighlightBorder(frame)
	end);
	
	object:HookScript('OnLeave', function(frame)
		self.ResetHighlightBorder(frame)
	end);
end

function Phoenix_UIConfig:ApplyBackdrop(frame, type, border, insets)
	local config = frame.config or self.config;
	local backdrop = {
		bgFile   = config.backdrop.texture,
		edgeFile = config.backdrop.texture,
		edgeSize = 1,
	};
	if insets then
		backdrop.insets = insets;
	end
	if not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end
	frame:SetBackdrop(backdrop);

	type = type or 'button';
	border = border or 'border';
	
	if config.backdrop[type] then
		frame:SetBackdropColor(
			config.backdrop[type].r,
			config.backdrop[type].g,
			config.backdrop[type].b,
			config.backdrop[type].a
		);
	end

	if config.backdrop[border] then
		frame:SetBackdropBorderColor(
			config.backdrop[border].r,
			config.backdrop[border].g,
			config.backdrop[border].b,
			config.backdrop[border].a
		);
	end
end

function Phoenix_UIConfig:ClearBackdrop(frame)
	if not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end
	frame:SetBackdrop(nil);
end

function Phoenix_UIConfig:ApplyDisabledBackdrop(frame, enabled)
	if not frame then return end
	
	if frame.target then
		frame = frame.target;
	end
	
	-- Only apply backdrop effects to frames that support them
	if not frame.SetBackdrop then
		-- Just update the isDisabled flag without applying backdrop
		frame.isDisabled = not enabled;
		return
	end

	if enabled then
		self:ApplyBackdrop(frame, 'button', 'border');
		self:SetTextColor(frame, 'normal');
		if frame.label then
			self:SetTextColor(frame.label, 'normal');
		end

		if frame.text then
			self:SetTextColor(frame.text, 'normal');
		end
		frame.isDisabled = false;
	else
		self:ApplyBackdrop(frame, 'buttonDisabled', 'borderDisabled');
		self:SetTextColor(frame, 'disabled');
		if frame.label then
			self:SetTextColor(frame.label, 'disabled');
		end

		if frame.text then
			self:SetTextColor(frame.text, 'disabled');
		end
		frame.isDisabled = true;
	end
end

function Phoenix_UIConfig:HookDisabledBackdrop(frame)
	-- Only apply to frames that support backdrops
	if not frame or not frame.SetBackdrop then
		return
	end
	
	local this = self;
	hooksecurefunc(frame, 'Disable', function(self)
		this:ApplyDisabledBackdrop(self, false);
	end);

	hooksecurefunc(frame, 'Enable', function(self)
		this:ApplyDisabledBackdrop(self, true);
	end);
end

function Phoenix_UIConfig:StripTextures(frame)
	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions());

		if region and region:GetObjectType() == 'Texture' then
			region:SetTexture(nil);
		end
	end
end

function Phoenix_UIConfig:MakeDraggable(frame, handle)
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:RegisterForDrag('LeftButton');
	frame:SetScript('OnDragStart', frame.StartMoving);
	frame:SetScript('OnDragStop', frame.StopMovingOrSizing);

	if handle then
		handle:EnableMouse(true);
		handle:SetMovable(true);
		handle:RegisterForDrag('LeftButton');

		handle:SetScript('OnDragStart', function(self)
			frame.StartMoving(frame);
		end);

		handle:SetScript('OnDragStop', function(self)
			frame.StopMovingOrSizing(frame);
		end);
	end
end

-- Make a frame resizable
function Phoenix_UIConfig:MakeResizable(frame, direction)
	-- Possible resize directions and handle rotation values
	local anchorDirections = {
		["TOP"] = 0,
		["TOPRIGHT"] = 1.5708,
		["RIGHT"] = 0,
		["BOTTOMRIGHT"] = 0,
		["BOTTOM"] = 0,
		["BOTTOMLEFT"] = -1.5708,
		["LEFT"] = 0,
		["TOPLEFT"] = 3.1416,
	}

	direction = string.upper(direction);

	-- Return if invalid direction
	if not anchorDirections[direction] then return false end

	frame:SetResizable(true);

	-- Create the resize anchor
	local anchor = CreateFrame("Button", nil, frame);
	anchor:SetPoint(direction, frame, direction);

	-- Attach side anchor to adjacent sides of frame
	if direction == "TOP" or direction == "BOTTOM" then
		anchor:SetHeight(self.config.resizeHandle.height);
		anchor:SetPoint("LEFT", frame, "LEFT", self.config.resizeHandle.width, 0);
		anchor:SetPoint("RIGHT", frame, "RIGHT", self.config.resizeHandle.width*-1, 0);
	elseif direction == "LEFT" or direction == "RIGHT" then
		anchor:SetWidth(self.config.resizeHandle.width);
		anchor:SetPoint("TOP", frame, "TOP", 0, self.config.resizeHandle.height*-1);
		anchor:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.config.resizeHandle.height);
	else
		-- Set the corner anchor textures
		anchor:SetNormalTexture(self.config.resizeHandle.texture.normal);
		anchor:SetHighlightTexture(self.config.resizeHandle.texture.highlight);
		anchor:SetPushedTexture(self.config.resizeHandle.texture.pushed);

		-- Set size and rotate corner anchor
		anchor:SetSize(self.config.resizeHandle.width, self.config.resizeHandle.height);
		anchor:GetNormalTexture():SetRotation(anchorDirections[direction]);
		anchor:GetHighlightTexture():SetRotation(anchorDirections[direction]);
		anchor:GetPushedTexture():SetRotation(anchorDirections[direction]);
	end

	-- Resize anchor click handlers
	anchor:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			frame:StartSizing(direction);
			frame:SetUserPlaced(true);
		end
	end)
	anchor:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			frame:StopMovingOrSizing();
		end
	end)
end

-- Add a function to force flushing settings to disk
function Phoenix_UIConfig:ForceFlush()
	-- Force immediate save of settings
	local Phoenix_UI = _G.Phoenix_UI
	if Phoenix_UI and Phoenix_UI.SaveDB then
		Phoenix_UI:SaveDB(true) -- true means force save
		
		-- Try to flush variables to disk using available methods
		pcall(function()
			-- Try methods that exist in different API versions
			if FlushSavedVariables then
				FlushSavedVariables()
			end
			
			if FlushSettingsDB then
				FlushSettingsDB()
			end
			
			-- These are additional direct writes to SavedVariables global table
			if _G.Phoenix_UIDB and Phoenix_UI.db and Phoenix_UI.db.keys and Phoenix_UI.db.keys.profile then
				local currentProfile = Phoenix_UI.db.keys.profile
				if _G.Phoenix_UIDB.profiles and _G.Phoenix_UIDB.profiles[currentProfile] then
					-- Force a direct update of the saved variables 
					pcall(function()
						-- Make sure CopyTable exists either as a global or Phoenix_UI method
						local copyFunc = CopyTable or Phoenix_UI.CopyTable or function(tbl)
							if type(tbl) ~= "table" then return tbl end
							local copy = {}
							for k, v in pairs(tbl) do
								if type(v) == "table" then
									copy[k] = copyFunc(v)
								else
									copy[k] = v
								end
							end
							return copy
						end
						
						_G.Phoenix_UIDB.profiles[currentProfile] = copyFunc(Phoenix_UI.db.profile)
						_G.Phoenix_UIDB.profiles[currentProfile].__lastSaved = time()
					end)
				end
			end
		end)
		
		-- Safety delay to ensure everything is properly saved
		C_Timer.After(0.5, function()
			if Phoenix_UI.UI and Phoenix_UI.UI.RefreshConfig then
				Phoenix_UI.UI:RefreshConfig()
			end
		end)
	end
end

-- Hook the widget value change handlers to always ensure proper saving
local saveHookInstalled = false
function Phoenix_UIConfig:InstallSaveHooks()
	if saveHookInstalled then return end
	saveHookInstalled = true
	
	-- Safely hook a method
	local function safeHook(obj, methodName, wrapper)
		-- Check if object and method exist
		if not obj or not obj[methodName] or type(obj[methodName]) ~= "function" then return end
		
		-- Get original method
		local originalMethod = obj[methodName]
		
		-- Create a safe wrapper function
		obj[methodName] = function(...)
			-- Store args for potential use
			local args = {...}
			
			-- Try to call original method
			local success, result = pcall(function() 
				return originalMethod(unpack(args))
			end)
			
			-- Always run wrapper function regardless of outcome above
			if type(wrapper) == "function" then
				pcall(wrapper)
			end
			
			-- Return original result if successful
			if success then
				return result
			end
			-- If we get here, the original call failed but we prevented an error
		end
	end
	
	-- Hook checkbox
	if self.Checkbox then
		safeHook(self.Checkbox, "OnClick", function()
			pcall(function() self:ForceFlush() end)
		end)
	end
	
	-- Hook slider
	if self.Slider then
		safeHook(self.Slider, "OnValueChanged", function()
			pcall(function() self:ForceFlush() end)
		end)
	end
	
	-- Hook color picker
	if self.ColorInput then
		safeHook(self.ColorInput, "OnValueChanged", function()
			pcall(function() self:ForceFlush() end)
		end)
	end
	
	-- Hook dropdown
	if self.Dropdown then
		safeHook(self.Dropdown, "OnValueChanged", function()
			pcall(function() self:ForceFlush() end)
		end)
	end
	
	-- Schedule initial hook installation after load with proper error handling
	C_Timer.After(1, function()
		pcall(function() self:ForceFlush() end)
	end)
end

-- Install hooks
Phoenix_UIConfig:InstallSaveHooks()

-- Enhance all instances of Phoenix_UIConfig
for _, instance in ipairs(Phoenix_UIConfigInstances or {Phoenix_UIConfig}) do
	-- Store the original OnEnter and OnLeave functions
	local origOnEnter = instance.SetHighlightBorder
	local origSetHighlightBorder = instance.SetHighlightBorder
	
	-- Replace with our enhanced versions
	instance.SetHighlightBorder = Phoenix_UIConfig.SetHighlightBorder
	
	-- Also enhance widget creation to add fire effects
	local origButton = instance.Button
	if origButton then
		instance.Button = function(...)
			local button = origButton(...)
			if button then
				-- Store the original OnEnter/OnLeave handlers
				local origOnEnter = button:GetScript("OnEnter")
				local origOnLeave = button:GetScript("OnLeave")
				
				-- Set up new handlers that call both our code and the original
				button:SetScript("OnEnter", function(self, ...)
					-- Call our fire effect code
					ButtonOnEnter(self)
					
					-- Call original handler if it exists
					if origOnEnter then
						origOnEnter(self, ...)
					end
				end)
				
				button:SetScript("OnLeave", function(self, ...)
					-- Call our cleanup code
					ButtonOnLeave(self)
					
					-- Call original handler if it exists
					if origOnLeave then
						origOnLeave(self, ...)
					end
				end)
			end
			return button
		end
	end
	
	-- Enhance checkboxes
	local origCheckbox = instance.Checkbox
	if origCheckbox then
		instance.Checkbox = function(...)
			local checkbox = origCheckbox(...)
			if checkbox then
				-- Store the original OnEnter/OnLeave handlers
				local origOnEnter = checkbox:GetScript("OnEnter")
				local origOnLeave = checkbox:GetScript("OnLeave")
				
				-- Set up new handlers
				checkbox:SetScript("OnEnter", function(self, ...)
					-- Call our fire effect code
					ButtonOnEnter(self)
					
					-- Call original handler if it exists
					if origOnEnter then
						origOnEnter(self, ...)
					end
				end)
				
				checkbox:SetScript("OnLeave", function(self, ...)
					-- Call our cleanup code
					ButtonOnLeave(self)
					
					-- Call original handler if it exists
					if origOnLeave then
						origOnLeave(self, ...)
					end
				end)
			end
			return checkbox
		end
	end
	
	-- Enhance dropdowns
	local origDropdown = instance.Dropdown
	if origDropdown then
		instance.Dropdown = function(...)
			local dropdown = origDropdown(...)
			if dropdown and dropdown.button then
				-- Store the original OnEnter/OnLeave handlers
				local origOnEnter = dropdown.button:GetScript("OnEnter")
				local origOnLeave = dropdown.button:GetScript("OnLeave")
				
				-- Set up new handlers
				dropdown.button:SetScript("OnEnter", function(self, ...)
					-- Call our fire effect code
					ButtonOnEnter(self)
					
					-- Call original handler if it exists
					if origOnEnter then
						origOnEnter(self, ...)
					end
				end)
				
				dropdown.button:SetScript("OnLeave", function(self, ...)
					-- Call our cleanup code
					ButtonOnLeave(self)
					
					-- Call original handler if it exists
					if origOnLeave then
						origOnLeave(self, ...)
					end
				end)
			end
			return dropdown
		end
	end
end




