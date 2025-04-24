--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Spell', 2;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then
	return
end

----------------------------------------------------
--- SpellBox
----------------------------------------------------

local SpellBoxMethods = {
	SetSpell = function(self, spellId)
		self.spellId = spellId;

		if not self.spellId then
			self.icon:SetTexture('');
		else
			local _, _, icon = GetSpellInfo(spellId);

			self.icon:SetTexture(icon);
		end

		if self.OnSpellChanged then
			self:OnSpellChanged(spellId);
		end
	end,

	GetSpell = function(self)
		return self.spellId;
	end
};

function Phoenix_UIConfig:SpellBox(parent, width, height, iconSize, spellValidator)
	local frame = self:Frame(parent, width, height);

	frame.editBox = self:Autocomplete(frame, nil, nil, nil, spellValidator);
	frame.editBox:SetAllPoints();

	if not iconSize then
		iconSize = 24;
	end

	local icon = self:Texture(frame, iconSize, iconSize);
	self:GlueLeft(icon, frame, 2, 0);
	frame.icon = icon;

	frame.editBox:SetPoint('LEFT', icon, 'RIGHT', 5, 0);

	for k, v in pairs(SpellBoxMethods) do
		frame[k] = v;
	end

	return frame;
end

----------------------------------------------------
--- SpellInfo
----------------------------------------------------

local function PickupSpell(id)
	if not id then
		return false;
	end

	if GetSpellInfo(id) then
		PickupSpell(id, 'spell');
		return true;
	end

	return false;
end

function Phoenix_UIConfig:SpellInfo(parent, width, height, iconSize)
	local frame = self:Frame(parent, width, height);

	local icon = self:Texture(frame, iconSize or height, iconSize or height, nil);
	self:GlueLeft(icon, frame, 0, 0);
	frame.Icon = icon;

	local btn = self:Button(frame, nil, nil, nil);
	btn:SetAllPoints();
	btn:SetScript('OnClick', function(self)
		PickupSpell(self:GetParent().spellId);
	end);

	Phoenix_UIConfig:GlueRight(btn, frame, -3, 0, true);

	frame.spellId = nil;

	function frame:SetSpell(id)
		self.spellId = id;

		if id and GetSpellInfo(id) then
			local name, _, icon = GetSpellInfo(id);
			self.Icon:SetTexture(icon);

			if self.OnUpdateSpell then
				self:OnUpdateSpell(id, name)
			end
		else
			if self.OnUpdateSpell then
				self:OnUpdateSpell(nil)
			end
		end
	end

	function frame:GetSpell()
		return self.spellId;
	end

	return frame;
end

----------------------------------------------------
--- Checkbox
----------------------------------------------------

local SpellCheckboxChanged = function(self, flag)
	if self.spellIcon and flag then
		self.spellIcon:SetSpell(self.spellId);
	elseif self.spellIcon then
		self.spellIcon:SetSpell(nil);
	end
end

function Phoenix_UIConfig:SpellCheckbox(parent, width, height, iconSize)
	local frame = self:Frame(parent, width, height);

	local checkbox = self:Checkbox(frame, 'Spell Checkbox', nil);
	self:GlueTop(checkbox, frame, 0, 0, 'LEFT');

	local spellIcon = self:SpellInfo(frame, height, height, iconSize);
	self:GlueTop(spellIcon, frame, 0, 0, 'RIGHT');

	frame.check = checkbox;
	frame.spellIcon = spellIcon;
	frame.spellId = nil;

	function frame:OnValueChanged(callback)
		checkbox.OnValueChanged = callback;
	end

	function frame:SetSpell(id)
		self.spellId = id;
		if self.check:GetChecked() then
			self.spellIcon:SetSpell(id);
		end
	end

	function frame:GetSpell()
		return self.spellId;
	end

	checkbox.oldChanged = checkbox.OnValueChanged;
	checkbox.OnValueChanged = SpellCheckboxChanged;

	return frame;
end

Phoenix_UIConfig:RegisterModule(module, version);



