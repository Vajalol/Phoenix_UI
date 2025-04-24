--- @type Phoenix_UIConfig
local Phoenix_UIConfig = LibStub and LibStub('Phoenix_UIConfig', true);
if not Phoenix_UIConfig then
	return
end

local module, version = 'Basic', 5;
if not Phoenix_UIConfig:UpgradeNeeded(module, version) then
	return
end

function Phoenix_UIConfig:Frame(parent, width, height, inherits)
	local frame = CreateFrame('Frame', nil, parent, inherits);
	self:InitWidget(frame);
	self:SetObjSize(frame, width, height);

	return frame;
end

--- @return ScrollFrame
function Phoenix_UIConfig:Panel(parent, width, height)
	local frame = CreateFrame('Frame', nil, parent, 'BackdropTemplate');
	self:SetObjSize(frame, width, height);

	self:InitWidget(frame);
	self:ApplyBackdrop(frame, 'panel');

	return frame;
end

function Phoenix_UIConfig:Border(parent, width, height, backdrop, name)
	local frame = CreateFrame('Frame', name, parent, 'BackdropTemplate');
	self:SetObjSize(frame, width, height);

	if backdrop then
		self:ApplyBackdrop(frame, 'panel');
	end

	return frame;
end

function Phoenix_UIConfig:PanelWithLabel(parent, width, height, inherits, text)
	local frame = self:Panel(parent, width, height, inherits);

	frame.label = self:Header(frame, text, 18);
	frame.label:SetAllPoints();
	--frame.label:SetJustifyH('MIDDLE');

	return frame;
end

function Phoenix_UIConfig:PanelWithTitle(parent, width, height, text)
	local frame = self:Panel(parent, width, height);

	local titlePanel = CreateFrame('Frame', nil, frame, 'BackdropTemplate');
	titlePanel:SetHeight(20);
	titlePanel:SetPoint('TOPLEFT', frame, 0, 0);
	titlePanel:SetPoint('TOPRIGHT', frame, 0, 0);
	--frame.titlePanel:SetBackdrop(nil);

	local title = titlePanel:CreateFontString(nil, 'OVERLAY');
	title:SetFontObject(GameFontNormal);
	title:SetPoint('CENTER', titlePanel, 'CENTER');
	title:SetText(text);
	title:SetTextColor(1, 1, 1);

	titlePanel.titletext = title;
	titlePanel.label = title;
	frame.titlePanel = titlePanel;

	return frame;
end

--- @return Texture
function Phoenix_UIConfig:Texture(parent, width, height, texture)
	local tex = parent:CreateTexture(nil, 'ARTWORK');
	
	-- Assign reference to Phoenix_UIConfig to prevent errors
	tex.Phoenix_UIConfig = self;

	self:SetObjSize(tex, width, height);
	if texture then
		tex:SetTexture(texture);
	end

	return tex;
end

--- @return Texture
function Phoenix_UIConfig:ArrowTexture(parent, direction)
	local texture = self:Texture(parent, 12, 6, [[Interface\Buttons\Arrow-Up-Down]]);

	if direction == 'UP' then
		texture:SetTexCoord(0, 1, 0.5, 1);
	else
		texture:SetTexCoord(0, 1, 1, 0.5);
	end

	return texture;
end

function Phoenix_UIConfig:SetPoint(obj, parent, point, offsetX, offsetY, relPoint)
	point = point or 'CENTER';
	relPoint = relPoint or point;
	offsetX = offsetX or 0;
	offsetY = offsetY or 0;
	
	if type(parent) == 'string' then
		obj:SetPoint(point, parent, relPoint, offsetX, offsetY);
	else
		obj:SetPoint(point, parent, relPoint, offsetX, offsetY);
	end
end

Phoenix_UIConfig:RegisterModule(module, version);



