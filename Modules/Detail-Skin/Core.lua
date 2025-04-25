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
L["DETAILS_SKIN_TWW"] = "The War Within skin has been applied to Details!"
L["DETAILS_PROFILE_TWW"] = "The War Within profile has been imported to Details!"
L["DETAILS_RESET"] = "Details! has been reset to default settings"

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

-- Check if Details! is loaded, but never prevent UI display
function DetailsSkin:ShouldEnableOptions()
    return self:IsDetailsLoaded()
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
        skin_name = "The War Within",
        author = "Phoenix_UI (inspired by Karl-HeinzSchneider)",
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
            texture = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Media\\Textures\\bar.blp",
            texture_background = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Media\\Textures\\background.blp",
            texture_background_class_color = false,
            fixed_texture_background_color = {0.1254, 0.1254, 0.1254, 0.3},
            icon_file = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Media\\Textures\\ClassIconsTWW.blp",
            start_after_icon = true,
            percent_type = 1,
            alpha = 1,
            alpha_background = 0.8,
            textL_enable_custom_text = false,
            textR_enable_custom_text = false,
            textL_show_number = true,
            textR_show_number = false,
            textR_custom_text = "{data1} ({data2}, {data3}%)",
            texture_custom = "",
            texture_highlight = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
            textL_outline = true,
            textR_outline = true,
            textL_outline_small = true,
            textL_class_colors = true,
            textR_class_colors = true,
            textR_outline_small = true,
            fixed_text_color = {1, 1, 1},
            space = {
                right = 0,
                left = 0,
                between = 1,
            },
            point = "BOTTOM",
            textL_class_colors = true,
            textR_class_colors = true,
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

-- Apply the The War Within skin to Details!
function DetailsSkin:ApplySkin()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
        return false
    end
    
    local Details = _G._detalhes
    
    -- Create the skin profile
    local skin = self:CreateSkinProfile()
    if not skin then
        return false
    end
    
    -- Update with The War Within specific settings
    skin.skin_name = "The War Within"
    skin.icon_anchor_main = {-1, -5}
    skin.row_info = {
        texture = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Media\\Textures\\bar.blp",
        texture_background = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Media\\Textures\\background.blp",
        texture_background_class_color = false,
        fixed_texture_background_color = {0.1254, 0.1254, 0.1254, 0.3},
        icon_file = "Interface\\AddOns\\Phoenix_UI\\Modules\\Detail-Skin\\Media\\Textures\\ClassIconsTWW.blp",
        start_after_icon = true,
        percent_type = 1,
        alpha = 1,
        alpha_background = 0.8,
        textL_enable_custom_text = false,
        textR_enable_custom_text = false,
        textL_show_number = true,
        textR_show_number = false,
        textR_custom_text = "{data1} ({data2}, {data3}%)",
        texture_custom = "",
        texture_highlight = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
        textL_outline = true,
        textR_outline = true,
        textL_outline_small = true,
        textL_class_colors = true,
        textR_class_colors = true,
        textR_outline_small = true,
        fixed_text_color = {1, 1, 1},
        space = {
            right = 0,
            left = 0,
            between = 1,
        },
        point = "BOTTOM",
        textL_class_colors = true,
        textR_class_colors = true,
    }
    
    -- Try to install the skin
    local installed = false
    if Details.InstallSkin then
        installed = Details:InstallSkin(skin)
    else
        Phoenix_UI:Print("Error: Details! InstallSkin function not found.")
        return false
    end
    
    -- Check if installation was successful
    if installed then
        Phoenix_UI:Print(L["DETAILS_SKIN_TWW"])
        return true
    else
        Phoenix_UI:Print("Error: Failed to install The War Within skin to Details!")
        return false
    end
end

-- Import The War Within profile into Details!
function DetailsSkin:ImportProfile()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
        return false
    end
    
    -- Check if we have the profile data
    if not self.defaultProfile then
        Phoenix_UI:Print("Error: Default profile data not found!")
        return false
    end
    
    local Details = _G._detalhes
    
    -- Import the profile
    if Details.ImportProfile then
        local success = Details:ImportProfile(self.defaultProfile, "The War Within")
        if success then
            Phoenix_UI:Print(L["DETAILS_PROFILE_TWW"])
            return true
        else
            Phoenix_UI:Print("Error: Failed to import profile!")
            return false
        end
    else
        Phoenix_UI:Print("Error: Details! ImportProfile function not found.")
        return false
    end
end

-- Reset Details! to default settings
function DetailsSkin:ResetDetails()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        Phoenix_UI:Print(L["DETAILS_SKIN_ERROR"])
        return false
    end
    
    local Details = _G._detalhes
    
    -- Reset to default settings
    if Details.ResetProfile then
        Details:ResetProfile()
        Phoenix_UI:Print(L["DETAILS_RESET"])
        return true
    else
        Phoenix_UI:Print("Error: Details! ResetProfile function not found.")
        return false
    end
end

-- Apply the skin when the module is enabled if auto-apply is enabled
function DetailsSkin:OnEnable()
    -- Ensure DB structure
    if not Phoenix_UI.db.profile.addons then
        Phoenix_UI.db.profile.addons = {}
    end
    if not Phoenix_UI.db.profile.addons.details then
        Phoenix_UI.db.profile.addons.details = {
            enableSkin = true,
            autoApply = false
        }
    end
    
    -- Register slash command to apply the skin
    self:RegisterChatCommand("tww", function(input)
        if input == "import" then
            self:ImportProfile()
        else
            self:ApplySkin()
        end
    end)
    
    -- Apply the skin if auto-apply is enabled
    if Phoenix_UI.db.profile.addons.details.autoApply then
        C_Timer.After(2, function()
            self:ApplySkin()
        end)
    end
    
    -- Listen for Details! to load
    if not self:IsDetailsLoaded() then
        self:RegisterEvent("ADDON_LOADED", function(event, addonName)
            if addonName == "Details" or addonName == "Details!" then
                if Phoenix_UI.db.profile.addons.details.autoApply then
                    C_Timer.After(2, function()
                        self:ApplySkin()
                    end)
                end
                self:UnregisterEvent("ADDON_LOADED")
            end
        end)
    end
end 