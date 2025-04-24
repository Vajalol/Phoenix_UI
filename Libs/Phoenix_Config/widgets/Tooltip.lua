--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Tooltip', 3;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then
	return
end

Phoenix_UIConfig.tooltips = {};
Phoenix_UIConfig.frameTooltips = {};

----------------------------------------------------
--- Tooltip
----------------------------------------------------

local TooltipEvents = {
	OnEnter = function(self)
		local tip = self.Phoenix_UIConfigTooltip;
		tip:SetOwner(tip.owner or UIParent, tip.anchor or 'ANCHOR_NONE');

		if type(tip.text) == 'string' then
			tip:SetText(tip.text,
				tip.Phoenix_UIConfig.config.font.color.r,
				tip.Phoenix_UIConfig.config.font.color.g,
				tip.Phoenix_UIConfig.config.font.color.b,
				tip.Phoenix_UIConfig.config.font.color.a
			);
		elseif type(tip.text) == 'function' then
			tip.text(tip);
		end

		tip:Show();
		tip:ClearAllPoints();
		tip.Phoenix_UIConfig:GlueOpposite(tip, tip.owner, 0, 0, tip.anchor);
	end,

	OnLeave = function(self)
		local tip = self.Phoenix_UIConfigTooltip;
		tip:Hide();
	end
}

--- Standard blizzard tooltip
--@return GameTooltip
function Phoenix_UIConfig:Tooltip(owner, text, tooltipName, anchor, automatic)
	--- @type GameTooltip
	local tip;

	if tooltipName and self.tooltips[tooltipName] then
		tip = self.tooltips[tooltipName];
	else
		tip = CreateFrame('GameTooltip', tooltipName, UIParent, 'GameTooltipTemplate');
		self:ApplyBackdrop(tip, 'panel');
	end

	tip.owner = owner;
	tip.anchor = anchor;
	tip.text = text;
	tip.Phoenix_UIConfig = self;
	owner.Phoenix_UIConfigTooltip = tip;

	if automatic then
		for k, v in pairs(TooltipEvents) do
			owner:HookScript(k, v);
		end
	end

	return tip;
end

----------------------------------------------------
--- Tooltip
----------------------------------------------------

local FrameTooltipMethods = {
	SetText         = function(self, text, r, g, b)
		if r and g and b then
			text = self.Phoenix_UIConfig.Util.WrapTextInColor(text, r, g, b, 1);
		end
		self.text:SetText(text);

		self:RecalculateSize();
	end,

	GetText         = function(self)
		return self.text:GetText();
	end,

	AddLine         = function(self, text, r, g, b)
		local txt = self:GetText();
		if not txt then
			txt = '';
		else
			txt = txt .. '\n'
		end
		if r and g and b then
			text = self.Phoenix_UIConfig.Util.WrapTextInColor(text, r, g, b, 1);
		end
		self:SetText(txt .. text);
	end,

	RecalculateSize = function(self)
		self:SetSize(
			self.text:GetWidth() + self.padding * 2,
			self.text:GetHeight() + self.padding * 2
		);
	end
};

local OnShowFrameTooltip = function(self)
	self:RecalculateSize();
	self:ClearAllPoints();

	local _, _, _, xOfs, _ = self.owner:GetPoint()
	
	if xOfs == 15 then
		self.Phoenix_UIConfig:GlueLeft(self, self.owner, 0, 25, self.anchor);
	elseif xOfs > 275 then
		self.Phoenix_UIConfig:GlueRight(self, self.owner, 0, 25, self.anchor);
	else
		self.Phoenix_UIConfig:GlueOpposite(self, self.owner, 0, 0, self.anchor);
	end
end

local FrameTooltipEvents = {
	OnEnter = function(self)
		self.Phoenix_UIConfigTooltip:Show();
	end,

	OnLeave = function(self)
		self.Phoenix_UIConfigTooltip:Hide();
	end,
};

function Phoenix_UIConfig:FrameTooltip(owner, text, tooltipName, anchor, automatic, manualPosition)
	local tip;

	if tooltipName and self.frameTooltips[tooltipName] then
		tip = self.frameTooltips[tooltipName];
	else
		tip = self:Panel(owner, 10, 10);
		tip.Phoenix_UIConfig = self;
		tip:SetFrameStrata('TOOLTIP');
		self:ApplyBackdrop(tip, 'panel');

		tip.padding = self.config.tooltip.padding;

		tip.text = self:FontString(tip, '');
		self:GlueTop(tip.text, tip, tip.padding, -tip.padding, 'LEFT');

		for k, v in pairs(FrameTooltipMethods) do
			tip[k] = v;
		end

		if not manualPosition then
			hooksecurefunc(tip, 'Show', OnShowFrameTooltip);
		end
	end

	tip.owner = owner;
	tip.anchor = anchor;

	owner.Phoenix_UIConfigTooltip = tip;

	if type(text) == 'string' then
		tip:SetText(text);
	elseif type(text) == 'function' then
		text(tip);
	end

	if automatic then
		for k, v in pairs(FrameTooltipEvents) do
			owner:HookScript(k, v);
		end
	end

	return tip;
end

Phoenix_UIConfig:RegisterModule(module, version);



