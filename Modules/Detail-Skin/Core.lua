-- Phoenix_UI: Details! Skin Module
-- Adds a phoenix/fire themed skin to Details! damage meter

local addonName, Phoenix = ...

-- Create the module
local DetailsSkin = Phoenix_UI:NewModule("DetailsSkin", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
Phoenix.DetailsSkin = DetailsSkin

-- Localization
local L = Phoenix.L or {}
L["DETAILS_SKIN"] = "Details! Skin"
L["DETAILS_SKIN_DESC"] = "Apply the Phoenix UI skin to Details! damage meter"
L["DETAILS_SKIN_APPLY"] = "Apply Skin to Details!"
L["DETAILS_SKIN_APPLIED"] = "Phoenix skin has been applied to Details!"
L["DETAILS_SKIN_ERROR"] = "Details! addon is not loaded or not found"
L["DETAILS_SKIN_MISSING"] = "Details! addon is required for this feature"

-- Get a reference to the skin profile
local skinProfile = {}

-- Skin colors
local colors = {
    frame = {0.1, 0.1, 0.1, 0.9},         -- Dark background
    title = {1, 0.5, 0, 1},                -- Phoenix orange for title
    titleText = {1, 0.7, 0.3, 1},          -- Light orange for title text
    border = {0.7, 0.2, 0, 0.8},           -- Darker orange for border
    barFill = {1, 0.5, 0, 1},              -- Phoenix orange for bar fill
    barBackground = {0.1, 0.1, 0.1, 0.8},  -- Dark bar background
    highlight = {1, 0.8, 0.2, 0.7},        -- Golden highlight
    shadow = {0, 0, 0, 0.5},               -- Shadow effect
    statusbar = {0.9, 0.4, 0, 1}           -- Status bar color
}

-- Skin texture paths
local textures = {
    background = [[Interface\AddOns\Phoenix_UI\Media\Textures\Background\DarkPanel.blp]],
    barTexture = [[Interface\AddOns\Phoenix_UI\Media\Textures\Status\Gradient.blp]],
    border = [[Interface\AddOns\Phoenix_UI\Media\Textures\Border\Phoenix.blp]],
    icon = [[Interface\AddOns\Phoenix_UI\Media\Icons\Phoenix.blp]],
    statusbar = [[Interface\AddOns\Phoenix_UI\Media\Textures\Status\Glossy.blp]],
    closeButton = [[Interface\AddOns\Phoenix_UI\Media\Textures\Buttons\CloseButton.blp]],
    maximizeButton = [[Interface\AddOns\Phoenix_UI\Media\Textures\Buttons\MaximizeButton.blp]],
    minimizeButton = [[Interface\AddOns\Phoenix_UI\Media\Textures\Buttons\MinimizeButton.blp]]
}

-- Create textures for the skin if they don't exist in Phoenix_UI
local function EnsureTextures()
    -- Ensure the textures directory exists
    local texturesPath = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Textures\\"
    
    -- Copy texture files if they don't exist (placeholder - real implementation would check and create)
    DetailsSkin:Debug("Ensuring textures for Details! skin exist")
    
    -- Fallback to built-in textures if Phoenix_UI textures don't exist
    if not textures.background:find("^Interface\\AddOns\\Phoenix_UI") then
        textures.background = "Interface\\DialogFrame\\UI-DialogBox-Background"
        textures.barTexture = "Interface\\TargetingFrame\\UI-StatusBar"
        textures.border = "Interface\\DialogFrame\\UI-DialogBox-Border"
        textures.statusbar = "Interface\\TargetingFrame\\UI-StatusBar"
        textures.closeButton = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
        textures.maximizeButton = "Interface\\Buttons\\UI-Panel-SmallerButton-Up"
        textures.minimizeButton = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
    end
end

-- Debug function
function DetailsSkin:Debug(message)
    if Phoenix_UI and Phoenix_UI.Debug then
        Phoenix_UI:Debug("DetailsSkin", message)
    end
end

-- Check if Details! is loaded and available
function DetailsSkin:IsDetailsLoaded()
    return _G._detalhes ~= nil
end

-- Create the skin profile for Details!
function DetailsSkin:CreateSkinProfile()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        self:Debug("Details not found, cannot create skin profile")
        return nil
    end
    
    -- Get Details and the skin builder
    local Details = _G._detalhes
    
    -- Make sure textures are available
    EnsureTextures()
    
    -- Create the basic skin profile
    local skin = {
        -- Skin info
        skin_name = "Phoenix_UI",
        author = "Phoenix_UI",
        version = Phoenix_UI.version or "1.0",
        
        -- General appearance
        preset_file = "",
        is_first_run = false,
        
        -- Status bar
        statusbar_info = {
            ["overlay"] = {
                0.2, -- [1]
                0.2, -- [2]
                0.2, -- [3]
                0.8, -- [4]
            },
            ["center"] = {
                0.1, -- [1]
                0.1, -- [2]
                0.1, -- [3]
                0.5, -- [4]
            },
            ["center_texture"] = textures.statusbar,
            ["texture"] = textures.statusbar,
            ["alpha"] = 0.8,
            ["color"] = {
                unpack(colors.statusbar),
            },
        },
        
        -- Hide tooltips when no content
        tooltip = {
            ["tooltip_max_abilities"] = 5,
            ["bar_color"] = {
                1, -- [1]
                0.5, -- [2]
                0, -- [3]
                0.8, -- [4]
            },
            ["tooltip_max_targets"] = 3,
        },
        
        -- Instance settings
        instance_button_anchor = {
            -27, -- [1]
            1, -- [2]
        },
        hide_icon = false,
        hide_in_combat = false,
        hide_out_of_combat = false,
        color = {
            unpack(colors.frame),
        },
        attribute_text = {
            [1] = {
                ["enabled"] = true,
                ["shadow"] = true,
                ["anchorPoint"] = "TOPLEFT",
                ["xOffset"] = 15,
                ["fontSize"] = 12,
                ["yOffset"] = -12,
                ["text_color"] = {
                    unpack(colors.titleText),
                },
            },
            [2] = {
                ["enabled"] = false,
            },
            [3] = {
                ["enabled"] = false,
            },
            [4] = {
                ["enabled"] = false,
            },
            [5] = {
                ["enabled"] = false,
            },
        },
        
        -- Row settings
        row_show_animation = {
            ["anim"] = "Fade",
            ["options"] = {
                ["duration"] = 0.2,
                ["type"] = "originAlpha",
            },
        },
        row_info = {
            ["textL_outline"] = true,
            ["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
            ["textR_outline"] = true,
            ["icon_file"] = textures.barTexture,
            ["textL_outline_small"] = true,
            ["texture_background_file"] = textures.background,
            ["textL_outline_small_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                1, -- [4]
            },
            ["percent_type"] = 1,
            ["fixed_text_color"] = {
                1, -- [1]
                1, -- [2]
                1, -- [3]
            },
            ["space"] = {
                ["right"] = 0,
                ["left"] = 0,
                ["between"] = 1,
            },
            ["texture_background_class_color"] = false,
            ["start_after_icon"] = true,
            ["fast_ps_update"] = false,
            ["textR_separator_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                1, -- [4]
            },
            ["textR_show_data"] = {
                true, -- [1]
                true, -- [2]
                false, -- [3]
            },
            ["textL_enable_custom_text"] = false,
            ["fixed_texture_color"] = {
                unpack(colors.barFill),
            },
            ["textL_show_number"] = true,
            ["icon_size_offset"] = 0,
            ["texture_custom_file"] = textures.barTexture,
            ["backdrop"] = {
                ["enabled"] = false,
                ["size"] = 12,
                ["color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1, -- [4]
                },
                ["texture"] = "Details BarBorder 2",
            },
            ["textR_bracket"] = "(",
            ["models"] = {
                ["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
                ["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
                ["upper_alpha"] = 0.5,
                ["lower_enabled"] = false,
                ["lower_alpha"] = 0.1,
                ["upper_enabled"] = false,
            },
            ["textL_class_colors"] = true,
            ["alpha"] = 1,
            ["no_icon"] = false,
            ["texture"] = textures.barTexture,
            ["texture_background"] = textures.background,
            ["font_face_file"] = "Interface\\Addons\\Details\\fonts\\Accidental Presidency.ttf",
            ["height"] = 20,
            ["font_size"] = 12,
            ["texture_class_colors"] = true,
            ["font_face"] = "Accidental Presidency",
            ["textL_custom_text"] = "{data1}. {data3}{data2}",
            ["fixed_texture_background_color"] = {
                unpack(colors.barBackground),
            },
            ["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
            ["texture_custom"] = "",
            ["textR_class_colors"] = true,
            ["textR_outline_small_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                1, -- [4]
            },
            ["textL_class_colors"] = true,
            ["textR_enable_custom_text"] = false,
            ["fixed_text_color"] = {
                1, -- [1]
                1, -- [2]
                1, -- [3]
            },
            ["texture_background_class_color"] = false,
            ["textR_outline_small"] = true,
            ["texture_background_alpha"] = 0.8,
        },
        
        -- Window appearance
        wallpaper = {
            ["enabled"] = false,
            ["width"] = 266.000061035156,
            ["texcoord"] = {
                0.00100000001490116, -- [1]
                1, -- [2]
                0.00100000001490116, -- [3]
                0.703000030517578, -- [4]
            },
            ["overlay"] = {
                1, -- [1]
                1, -- [2]
                1, -- [3]
                1, -- [4]
            },
            ["anchor"] = "all",
            ["height"] = 225.999984741211,
            ["alpha"] = 0.8,
            ["texture"] = textures.background,
        },
        
        -- Overall data
        show_statusbar = true,
        menu_icons_size = 0.9,
        menu_anchor = {
            16, -- [1]
            0, -- [2]
            ["side"] = 2,
        },
        window_scale = 1.0,
        
        -- Window background and border
        backdrop_texture = textures.background,
        backdrop_color = {
            unpack(colors.frame),
        },
        bg_b = colors.frame[3],
        bg_g = colors.frame[2],
        bg_r = colors.frame[1],
        bg_alpha = colors.frame[4],
        
        -- Custom bar texture settings (overrides details settings)
        bars_inverted = false,
        bars_sort_direction = 1,
        bars_grow_direction = 1,
        
        -- Plugin support
        plugins_grow_direction = 1,
        micro_displays_side = 2,
        
        -- Icon settings
        desaturated_menu = false,
        
        -- Titlebar settings
        menu_alpha = {
            overall = 0.8,
            overlay = 0.8,
        },
        
        -- Custom titlebar settings
        use_multi_fontstrings = false,
        custom_title_bar = {
            enabled = true,
            height = 24,
            backdrop_texture = textures.background,
            backdrop_color = {
                unpack(colors.title),
            },
            text_color = {
                unpack(colors.titleText),
            },
            icon_texture = textures.icon,
            icon_size = 20,
            icon_color = {
                1, 1, 1, 1
            },
            close_button_texture = textures.closeButton,
            maximize_button_texture = textures.maximizeButton,
            minimize_button_texture = textures.minimizeButton,
        },
        
        -- Other settings
        use_spec_icons = true,
        micro_displays_locked = true,
        menu_anchor_down = {
            16, -- [1]
            -3, -- [2]
        },
        auto_hide_menu = {
            left = false,
            right = false,
        },
        grab_on_top = false,
        hide_on_combat = false,
        show_sidebars = false,
        auto_current = true,
    }
    
    -- Store the skin profile
    skinProfile = skin
    
    return skin
end

-- Apply the skin to Details!
function DetailsSkin:ApplySkin()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        self:Debug("Details not found, cannot apply skin")
        if Phoenix_UI and Phoenix_UI.ShowNotification then
            Phoenix_UI:ShowNotification(L["DETAILS_SKIN"], L["DETAILS_SKIN_ERROR"], "Interface\\Icons\\INV_Misc_PheonixPet_01", 5)
        end
        return false
    end
    
    local Details = _G._detalhes
    
    -- Create the skin if it doesn't exist
    if not skinProfile or next(skinProfile) == nil then
        skinProfile = self:CreateSkinProfile()
    end
    
    if not skinProfile then
        self:Debug("Failed to create skin profile")
        return false
    end
    
    -- Register the skin with Details!
    Details:InstallSkin("Phoenix_UI", skinProfile)
    
    -- Apply the skin to all windows
    for i = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(i)
        if instance then
            instance:ChangeSkin("Phoenix_UI")
        end
    end
    
    -- Save Details! settings
    Details:SaveConfig()
    
    -- Show success notification
    if Phoenix_UI and Phoenix_UI.ShowNotification then
        Phoenix_UI:ShowNotification(L["DETAILS_SKIN"], L["DETAILS_SKIN_APPLIED"], "Interface\\Icons\\INV_Misc_PheonixPet_01", 5)
    end
    
    self:Debug("Phoenix skin applied to Details!")
    return true
end

-- Handle button click from Phoenix_UI panel
function DetailsSkin:OnApplySkinButtonClick()
    self:ApplySkin()
end

-- Command to apply the skin
function DetailsSkin:ApplySkinCommand(input)
    self:ApplySkin()
end

-- Initialize the module
function DetailsSkin:OnInitialize()
    -- Register slash command
    self:RegisterChatCommand("phoenixskin", "ApplySkinCommand")
    
    -- Create the skin profile
    self:CreateSkinProfile()
    
    self:Debug("Details Skin module initialized")
end

-- Register with the general tab in Phoenix UI
function DetailsSkin:RegisterWithUI()
    -- Wait for Phoenix_UI to be ready
    if Phoenix_UI and Phoenix_UI.RegisterGeneralOption then
        Phoenix_UI:RegisterGeneralOption({
            name = "DetailsSkin",
            text = L["DETAILS_SKIN_APPLY"],
            tooltip = L["DETAILS_SKIN_DESC"],
            type = "button",
            onClick = function() DetailsSkin:OnApplySkinButtonClick() end,
            enabled = function() return DetailsSkin:IsDetailsLoaded() end,
            disabledTooltip = L["DETAILS_SKIN_MISSING"]
        })
    else
        -- Try again when Phoenix_UI is ready
        Phoenix_UI:RegisterMessage("PHOENIX_UI_READY", function()
            if Phoenix_UI and Phoenix_UI.RegisterGeneralOption then
                Phoenix_UI:RegisterGeneralOption({
                    name = "DetailsSkin",
                    text = L["DETAILS_SKIN_APPLY"],
                    tooltip = L["DETAILS_SKIN_DESC"],
                    type = "button",
                    onClick = function() DetailsSkin:OnApplySkinButtonClick() end,
                    enabled = function() return DetailsSkin:IsDetailsLoaded() end,
                    disabledTooltip = L["DETAILS_SKIN_MISSING"]
                })
            end
        end)
    end
end

-- Module enabled
function DetailsSkin:OnEnable()
    -- Register with Phoenix_UI
    self:RegisterWithUI()
    self:Debug("Details Skin module enabled")
end 