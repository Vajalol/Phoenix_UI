--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'ProgressBar', 3;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then return end;

----------------------------------------------------
--- ProgressBar
----------------------------------------------------

local ProgressBarMethods = {
	GetPercentageValue = function(self)
		local _, max = self:GetMinMaxValues();
		local value = self:GetValue();
		return (value/max) * 100;
	end,

	TextUpdate = function(self) -- min, max, value
		return Round(self:GetPercentageValue()) .. '%';
	end
};

local ProgressBarEvents = {
	OnValueChanged = function(self, value)
		local min, max = self:GetMinMaxValues();
		self.text:SetText(self:TextUpdate(min, max, value));
	end,

	OnMinMaxChanged = function(self)
		local min, max = self:GetMinMaxValues();
		local value = self:GetValue();
		self.text:SetText(self:TextUpdate(min, max, value));
	end
}

--- @return StatusBar
function Phoenix_UIConfig:ProgressBar(parent, width, height, vertical)
	vertical = vertical or false;

	local container = self:Frame(parent, width, height);
	local bar = CreateFrame('StatusBar', nil, container);
	bar:SetStatusBarTexture(self.config.backdrop.texture);
	bar:SetStatusBarColor(self.config.progressBar.color.r, self.config.progressBar.color.g, self.config.progressBar.color.b, self.config.progressBar.color.a);
	
	bar:SetMinMaxValues(0, 100);
	bar:SetValue(50);
	--bar:SetFrameLevel(parent:GetFrameLevel() + 1);

	bar.bg = self:Frame(bar, nil, nil, 'BackdropTemplate');
	bar.bg:SetAllPoints();
	self:ApplyBackdrop(bar.bg, 'button', 'border');

	bar.text = self:FontString(bar, '');
	self:GlueTop(bar.text, bar, 0, 0);

	if vertical then
		bar:SetOrientation('VERTICAL');
		bar:SetRotatesTexture(true);

		bar:SetPoint('BOTTOMLEFT', 0, 0);
		bar:SetPoint('BOTTOMRIGHT', 0, 0);
		--bar:SetWidth(width or 20);
		bar:SetHeight(height or 100);
	else
		bar:SetPoint('TOPLEFT', 0, 0);
		bar:SetPoint('BOTTOMLEFT', 0, 0);
		bar:SetWidth(width or 100);
		--bar:SetHeight(height or 20);
	end

	bar.TextUpdate = ProgressBarMethods.TextUpdate;
	bar.GetPercentageValue = ProgressBarMethods.GetPercentageValue;

	container.bar = bar;
	container.barFrame = bar;

	return container;
end

Phoenix_UIConfig:RegisterModule(module, version);



