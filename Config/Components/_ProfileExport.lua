local ProfileExport = Phoenix_UI:NewModule('Config.Components.ProfileExport');

-- Load Libs
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local Phoenix_UIConfig = LibStub('Phoenix_UIConfig')

-- Export Profile Function
function ProfileExport:exportProfile(db)
    --AceSerialize
    local serialized_profile = Phoenix_UI:Serialize(db.profile)

    --LibDeflate
    local compressed_profile = LibDeflate:CompressZlib(serialized_profile)
    local encoded_profile    = LibDeflate:EncodeForPrint(compressed_profile)
    return encoded_profile
end

function ProfileExport:Show()
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

    local window = Phoenix_UIConfig:Window(UIParent, 500, 640, 'Profile Export')
    window:SetPoint('CENTER')
    window:SetFrameStrata('DIALOG');

    local fadeInfo = {}
    fadeInfo.mode = "IN"
    fadeInfo.timeToFade = 0.2
    fadeInfo.finishedFunc = function()
        window:Show()
    end
    UIFrameFade(window, fadeInfo)

    -- Export text
    local textBox = Phoenix_UIConfig:MultiLineBox(window, 450, 500, '', true)
    Phoenix_UIConfig:GlueTop(textBox, window, 0, -80)
    textBox.editBox:SetFocus()

    -- Export data
    local text = ''
    local data = Phoenix_UI.db

    -- Serialize
    local serializedData = LibStub:GetLibrary('AceSerializer-3.0'):Serialize(data)
    local compressedData = LibStub:GetLibrary('LibCompress'):Compress(serializedData)
    local encodedData = LibStub:GetLibrary('LibCompress'):GetAddonEncodeTable():Encode(compressedData)

    -- Apply
    textBox.editBox:SetText(encodedData)
    textBox.editBox:HighlightText()

    -- Select Text
    local selectAllButton = Phoenix_UIConfig:Button(window, 120, 20, 'Select All')
    Phoenix_UIConfig:GlueBelow(selectAllButton, textBox, 0, -10)
    selectAllButton:SetScript('OnClick', function()
        textBox.editBox:HighlightText()
        textBox.editBox:SetFocus()
    end)

    -- Close
    local closeButton = Phoenix_UIConfig:Button(window, 120, 20, 'Close')
    Phoenix_UIConfig:GlueBottom(closeButton, window, 0, 20)
    closeButton:SetScript('OnClick', function()
        local fadeInfo = {}
        fadeInfo.mode = "OUT"
        fadeInfo.timeToFade = 0.2
        fadeInfo.finishedFunc = function()
            window:Hide()
        end
        UIFrameFade(window, fadeInfo)
    end)
end



