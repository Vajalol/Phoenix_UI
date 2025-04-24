--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Group', 1;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then return end;

--- @return Frame
function Phoenix_UIConfig:Group(parent, title, width, height)
	local frame = self:Panel(parent, width, height);
	
	if title and title ~= '' then
		local titleLabel = self:Header(frame, title);
		titleLabel:SetPoint('TOPLEFT', 10, -10);
		
		frame.title = titleLabel;
		frame.hasLabel = true;
	end
	
	return frame;
end

Phoenix_UIConfig:RegisterModule(module, version); 