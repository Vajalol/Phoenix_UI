local NPCColors = Phoenix_UI:NewModule('Config.Components.NPCColors');

local Phoenix_UIConfig = LibStub('Phoenix_UIConfig')

function NPCColors:buildNPCColorsUI(parent, width, height)
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
    };
    
    -- Ensure the database path exists
    if not Phoenix_UI.db.profile.nameplates then
        Phoenix_UI.db.profile.nameplates = {}
    end
    
    if not Phoenix_UI.db.profile.nameplates.npclist then
        Phoenix_UI.db.profile.nameplates.npclist = {}
    end
    
    local db = Phoenix_UI.db.profile.nameplates.npclist;
    local currentNPC = '';
    
    local window = parent or Phoenix_UIConfig:Window(UIParent, width or 400, height or 230, 'NPC Colors');

    if not parent then
        window:SetPoint('CENTER')
        window:SetFrameStrata('DIALOG');
        local fadeInfo = {}
        fadeInfo.mode = "IN"
        fadeInfo.timeToFade = 0.2
        fadeInfo.finishedFunc = function()
            window:Show()
        end
        UIFrameFade(window, fadeInfo)
    end

    local scrollFrame = Phoenix_UIConfig:ScrollFrame(window, window:GetWidth() - 30, window:GetHeight() - 70);
    Phoenix_UIConfig:GlueTop(scrollFrame, window, 0, -35);

    local tableContainer = Phoenix_UIConfig:Panel(scrollFrame.content, scrollFrame:GetWidth(), scrollFrame:GetHeight());
    Phoenix_UIConfig:GlueTop(tableContainer, scrollFrame, 0, 0);

    -- Colors Table
    local table = Phoenix_UIConfig:ScrollTable(
        tableContainer,
        {
            {
                name = 'NPC Name',
                width = 150,
                align = 'LEFT',
            },
            {
                name = 'RGB Color',
                width = 120,
                align = 'LEFT',
            },
            {
                name = '',
                width = 80,
                align = 'CENTER',
            }
        },
        {
            rowHeight = 20,
            rowColors = {
                { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },
                { r = 0.05, g = 0.05, b = 0.05, a = 0.8 }
            },
            highlight = { r = 0.2, g = 0.2, b = 0.4, a = 0.8 }
        }
    );
    
    -- Set the table size
    table:SetWidth(tableContainer:GetWidth() - 5);
    table:SetHeight(tableContainer:GetHeight() - 5);
    
    -- Dialog for editing a new entry
    local function ColorDialogBuildRow(npcName, r, g, b)
        local nameLabel = npcName;
        local colorPreview = string.format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, nameLabel);
        
        -- Create a row with proper cell formatting
        local row = {
            [1] = colorPreview,
            [2] = string.format('%.2f, %.2f, %.2f', r, g, b),
            [3] = 'Delete'
        };
        
        -- Add metadata for identification
        row.npcName = npcName;
        
        return row;
    end
    
    -- Add cell click handler for delete button
    table:RegisterEvents({
        OnClick = function(_, cellFrame, data, _, _, rowIndex, columnIndex)
            if columnIndex == 3 then
                local npcName = data[rowIndex].npcName;
                if npcName then
                    db[npcName] = nil;
                    Phoenix_UI:RefreshConfig();
                    
                    -- Refresh the table data
                    local newData = {};
                    for name, color in pairs(db) do
                        table.insert(newData, ColorDialogBuildRow(name, unpack(color)));
                    end
                    table:SetData(newData);
                end
            end
        end
    });
    
    -- Update Table with Current Colors
    local function UpdateTableData()
        local tableData = {};
        
        -- Convert the DB entries to table rows
        for npcName, color in pairs(db) do
            table.insert(tableData, ColorDialogBuildRow(npcName, unpack(color)));
        end
        
        -- Set the table data
        table:SetData(tableData);
    end
    
    UpdateTableData();
    
    local addPanel = Phoenix_UIConfig:Panel(window, 350, 25);
    Phoenix_UIConfig:GlueBelow(addPanel, window, 0, 30);
    
    -- Create New Entry Fields
    local npcNameInput = Phoenix_UIConfig:EditBox(addPanel, 250, 20, '');
    npcNameInput:SetPoint('LEFT', addPanel, 'LEFT', 5, 0);
    npcNameInput:SetScript('OnEditFocusGained', function(self) currentNPC = self:GetText(); end);

    local colorPickerButton = Phoenix_UIConfig:Button(addPanel, 20, 20, '');
    Phoenix_UIConfig:GlueRight(colorPickerButton, npcNameInput, 4, 0);
    
    -- Set initial color
    local currentColor = {1, 1, 1, 1};
    colorPickerButton:SetBackdropColor(1, 1, 1, 1);
    
    -- Color Picker Setup
    colorPickerButton:SetScript('OnClick', function(self)
        local r, g, b, a = unpack(currentColor);
        
        local function UpdateColor()
            colorPickerButton:SetBackdropColor(ColorPickerFrame:GetColorRGB());
            currentColor = {ColorPickerFrame:GetColorRGB(), 1};
        end
        
        ColorPickerFrame.func = UpdateColor;
        ColorPickerFrame.hasOpacity = false;
        ColorPickerFrame:SetColorRGB(r, g, b);
        ColorPickerFrame:Hide();
        ColorPickerFrame:Show();
    end);
    
    -- Add Button
    local addButton = Phoenix_UIConfig:Button(addPanel, 60, 20, 'Add');
    Phoenix_UIConfig:GlueRight(addButton, colorPickerButton, 4, 0);
    
    addButton:SetScript('OnClick', function()
        local npcName = strtrim(npcNameInput:GetText());
        
        if npcName == '' then
            print('Please enter a valid NPC name.');
            return;
        end
        
        db[npcName] = {currentColor[1], currentColor[2], currentColor[3]};
        Phoenix_UI:RefreshConfig();
        
        npcNameInput:SetText('');
        
        -- Refresh the table data
        UpdateTableData();
    end);
    
    if not parent then
        -- Close Button
        local closeButton = Phoenix_UIConfig:Button(window, 65, 20, 'Close');
        Phoenix_UIConfig:GlueBottom(closeButton, window, 0, 10);
        
        closeButton:SetScript('OnClick', function()
            local fadeInfo = {}
            fadeInfo.mode = "OUT"
            fadeInfo.timeToFade = 0.2
            fadeInfo.finishedFunc = function()
                window:Hide();
            end
            UIFrameFade(window, fadeInfo);
        end);
    end
    
    return window;
end

function NPCColors:Show()
    -- Get a guaranteed reference to the module
    local module = Phoenix_UI:GetModule('Config.Components.NPCColors')
    if not module then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error loading NPC Colors module")
        return
    end
    
    -- Call the build function using the module reference
    module:buildNPCColorsUI()
end

function NPCColors:RemoveNPC(npcID)
    -- Ensure the database path exists
    if not Phoenix_UI.db.profile.nameplates then
        Phoenix_UI.db.profile.nameplates = {}
    end
    
    if not Phoenix_UI.db.profile.nameplates.npccolors then
        Phoenix_UI.db.profile.nameplates.npccolors = {}
    end
    
    local db = Phoenix_UI.db.profile.nameplates
    npcID = tonumber(npcID)

    for i, npc in pairs(db.npccolors) do
        if npc.id == npcID then
            print('|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: \'' .. npc.name .. '\' (ID: ' .. npc.id .. ') has been removed.')
            table.remove(db.npccolors, i)
            return
        end
    end

    print('|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: NPC with ID \'' .. npcID .. '\' does not exist.')
end

-- Global function to show NPC Colors UI
function Phoenix_UI_ShowNPCColors()
    local module = Phoenix_UI:GetModule('Config.Components.NPCColors')
    if module then
        module:Show()
    else
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: Error loading NPC Colors module")
    end
end



