local CVarsBrowser = Phoenix_UI:NewModule('Config.Components.CVarsBrowser');

local Phoenix_UIConfig = LibStub('Phoenix_UIConfig')

function CVarsBrowser:Show()
    -- Config
    Phoenix_UIConfig.config = {
        font = {
            family    = STANDARD_TEXT_FONT,
            size      = 12,
            titleSize = 16,
            effect    = 'NONE',
            strata    = 'OVERLAY',
            color     = {
                normal   = { r = 1, g = 1, b = 1, a = 1 },
                disabled = { r = 1, g = 1, b = 1, a = 1 },
                header   = { r = 1, g = 0.9, b = 0, a = 1 },
            }
        },
        backdrop = {
            texture        = [[Interface\Buttons\WHITE8X8]],
            highlight      = { r = 0.40, g = 0.40, b = 0, a = 0.5 },
            panel          = { r = 0.065, g = 0.065, b = 0.065, a = 0.95 },
            slider         = { r = 0.15, g = 0.15, b = 0.15, a = 1 },
            checkbox       = { r = 0.125, g = 0.125, b = 0.125, a = 1 },
            dropdown       = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
            button         = { r = 0.055, g = 0.055, b = 0.055, a = 1 },
            buttonDisabled = { r = 0, g = 0.55, b = 1, a = 0.5 },
            border         = { r = 0.01, g = 0.01, b = 0.01, a = 1 },
            borderDisabled = { r = 0, g = 0.50, b = 1, a = 1 },
        },
        progressBar = {
            color = { r = 1, g = 0.9, b = 0, a = 0.5 },
        },
        highlight = {
            color = { r = 0, g = 0.55, b = 1, a = 0.5 },
            blank = { r = 0, g = 0, b = 0 }
        },
        dialog = {
            width  = 400,
            height = 100,
            button = {
                width  = 100,
                height = 20,
                margin = 5
            }
        },
        tooltip = {
            padding = 10
        }
    }

    -- Window
    local window = Phoenix_UIConfig:Window(UIParent, 800, 600, 'CVars Browser')
    window:SetPoint('CENTER')
    window:SetFrameStrata('DIALOG');

    local fadeInfo = {}
    fadeInfo.mode = "IN"
    fadeInfo.timeToFade = 0.2
    fadeInfo.finishedFunc = function()
        window:Show()
    end
    UIFrameFade(window, fadeInfo)

    -- CVars Table
    local allCVars = {}
    for cvar in pairs(C_Console.GetAllCommands()) do
        table.insert(allCVars, {
            name = cvar,
            value = GetCVar(cvar) or '',
            defaultValue = GetCVarDefault(cvar) or '',
            help = C_Console.GetHelpText(cvar) or '',
        })
    end
    table.sort(allCVars, function(a, b) return a.name < b.name end)

    -- Table
    local scrollFrame = Phoenix_UIConfig:ScrollFrame(window, window:GetWidth() - 150, window:GetHeight() - 120);
    Phoenix_UIConfig:GlueTop(scrollFrame, window, 65, -70);

    local tableContainer = Phoenix_UIConfig:Panel(scrollFrame.content, scrollFrame:GetWidth(), 1200);
    Phoenix_UIConfig:GlueTop(tableContainer, scrollFrame, 0, 0);

    local table = Phoenix_UIConfig:Table(
        tableContainer,
        tableContainer:GetWidth() - 10,
        tableContainer:GetHeight(),
        {
            { name = 'CVar', width = 0.2, align = 'LEFT' },
            { name = 'Value', width = 0.15, align = 'LEFT' },
            { name = 'Default Value', width = 0.15, align = 'LEFT' },
            { name = 'Help Text', width = 0.5, align = 'LEFT' },
        },
        true
    )

    local data = {}
    for _, cvar in ipairs(allCVars) do
        table:AddRow({
            cvar.name,
            cvar.value,
            cvar.defaultValue,
            cvar.help
        });
    end
    table:SetData(data);

    -- Search Section
    local searchSection = Phoenix_UIConfig:Panel(window, 250, 80);
    searchSection:SetPoint('TOPLEFT', window, 'TOPLEFT', 10, -70);

    local searchLabel = Phoenix_UIConfig:Label(searchSection, 'Search');
    searchLabel:SetPoint('TOPLEFT', searchSection, 'TOPLEFT', 10, -10);

    local searchBox = Phoenix_UIConfig:EditBox(searchSection, 230, 20, '');
    Phoenix_UIConfig:GlueBelow(searchBox, searchLabel, 0, -5);

    searchBox:SetScript('OnTextChanged', function(self)
        local searchText = self:GetText():lower()
        if searchText == '' then
            table:SetData(data)
            return
        end

        local filteredData = {}
        for _, row in ipairs(allCVars) do
            if row.name:lower():find(searchText, 1, true) or 
               row.value:lower():find(searchText, 1, true) or
               row.help:lower():find(searchText, 1, true) then
                table:AddRow({
                    row.name,
                    row.value,
                    row.defaultValue,
                    row.help
                });
            end
        end
        table:SetData(filteredData)
    end)

    -- Info Section
    local infoSection = Phoenix_UIConfig:Panel(window, 250, 120);
    Phoenix_UIConfig:GlueBelow(infoSection, searchSection, 0, -10);

    local infoLabel = Phoenix_UIConfig:Label(infoSection, 'CVar Info');
    infoLabel:SetPoint('TOPLEFT', infoSection, 'TOPLEFT', 10, -10);

    local nameLabel = Phoenix_UIConfig:Label(infoSection, 'Name:');
    Phoenix_UIConfig:GlueBelow(nameLabel, infoLabel, 0, -10);

    local nameValue = Phoenix_UIConfig:Label(infoSection, '');
    nameValue:SetPoint('LEFT', nameLabel, 'RIGHT', 10, 0);

    local currentLabel = Phoenix_UIConfig:Label(infoSection, 'Current:');
    Phoenix_UIConfig:GlueBelow(currentLabel, nameLabel, 0, -10);

    local currentValue = Phoenix_UIConfig:Label(infoSection, '');
    currentValue:SetPoint('LEFT', currentLabel, 'RIGHT', 10, 0);

    local defaultLabel = Phoenix_UIConfig:Label(infoSection, 'Default:');
    Phoenix_UIConfig:GlueBelow(defaultLabel, currentLabel, 0, -10);

    local defaultValue = Phoenix_UIConfig:Label(infoSection, '');
    defaultValue:SetPoint('LEFT', defaultLabel, 'RIGHT', 10, 0);

    -- Set Value Section
    local setSection = Phoenix_UIConfig:Panel(window, 250, 100);
    Phoenix_UIConfig:GlueBelow(setSection, infoSection, 0, -10);

    local setLabel = Phoenix_UIConfig:Label(setSection, 'Set CVar Value');
    setLabel:SetPoint('TOPLEFT', setSection, 'TOPLEFT', 10, -10);

    local valueBox = Phoenix_UIConfig:EditBox(setSection, 230, 20, '');
    Phoenix_UIConfig:GlueBelow(valueBox, setLabel, 0, -5);

    local setButton = Phoenix_UIConfig:Button(setSection, 100, 20, 'Set Value');
    Phoenix_UIConfig:GlueBelow(setButton, valueBox, 0, -10);

    local resetButton = Phoenix_UIConfig:Button(setSection, 100, 20, 'Reset');
    resetButton:SetPoint('LEFT', setButton, 'RIGHT', 10, 0);

    -- Help Text
    local helpBox = Phoenix_UIConfig:MultiLineBox(window, 250, 150, '', true);
    Phoenix_UIConfig:GlueBelow(helpBox, setSection, 0, -10);
    helpBox.editBox:SetText('Select a CVar to see and edit its value.');
    helpBox.editBox:Disable();

    -- Close Button
    local closeButton = Phoenix_UIConfig:Button(window, 120, 30, 'Close');
    Phoenix_UIConfig:GlueBottom(closeButton, window, 0, 20);

    -- Handle table selection
    table:SetScript('OnRowClicked', function(self, rowData, rowIndex)
        local cvar = allCVars[rowIndex]
        if not cvar then return end

        nameValue:SetText(cvar.name);
        currentValue:SetText(GetCVar(cvar.name) or '');
        defaultValue:SetText(cvar.defaultValue);
        valueBox:SetText(GetCVar(cvar.name) or '');
        helpBox.editBox:SetText(cvar.help);
        helpBox.editBox:SetCursorPosition(0);

        -- Enable the set and reset buttons when a cvar is selected
        setButton:Enable();
        resetButton:Enable();
    end);

    -- Set button logic
    setButton:SetScript('OnClick', function()
        local cvar = nameValue:GetText()
        if cvar and cvar ~= '' then
            local value = valueBox:GetText()
            SetCVar(cvar, value)
            currentValue:SetText(GetCVar(cvar) or '')
            C_UI.Reload() -- Reload the UI to apply changes
        end
    end);

    -- Reset button logic
    resetButton:SetScript('OnClick', function()
        local cvar = nameValue:GetText()
        if cvar and cvar ~= '' then
            local defValue = defaultValue:GetText()
            SetCVar(cvar, defValue)
            valueBox:SetText(defValue)
            currentValue:SetText(GetCVar(cvar) or '')
        end
    end);

    -- Close button logic
    closeButton:SetScript("OnClick", function()
        local fadeInfo = {}
        fadeInfo.mode = "OUT"
        fadeInfo.timeToFade = 0.2
        fadeInfo.finishedFunc = function()
            window:Hide();
        end
        UIFrameFade(window, fadeInfo);
    end);
end



