-- Phoenix_UI: Details! Skin Module - Default Profile
-- This is a default profile that can be imported directly into Details!

local addonName, Phoenix = ...
local DetailsSkin = Phoenix.DetailsSkin

if not DetailsSkin then return end

-- Default profile compatible with Details! import format
DetailsSkin.defaultProfile = {
    ["profile_name"] = "Phoenix_UI",
    ["auto_hide_menu"] = {
        ["left"] = false,
        ["right"] = false,
    },
    ["captured_spells"] = {
    },
    ["tooltip"] = {
        ["anchor_offset"] = {
            0, -- [1]
            0, -- [2]
        },
        ["bar_color"] = {
            1, -- [1]
            0.5, -- [2]
            0, -- [3]
            0.8, -- [4]
        },
        ["font_color"] = {
            1, -- [1]
            1, -- [2]
            1, -- [3]
            1, -- [4]
        },
        ["font_face"] = "Expressway",
        ["font_size"] = 10,
        ["max_targets"] = 20,
        ["max_abilities"] = 10,
        ["anchor_relative"] = "top",
        ["anchor_point"] = "bottom",
        ["textL_class_colors"] = true,
        ["textR_class_colors"] = true,
        ["show_amount"] = true,
    },
    ["data_cleanup_logout"] = false,
    ["all_players_are_group"] = false,
    ["use_row_animations"] = true,
    ["minimum_combat_time"] = 5,
    ["animate_scroll"] = false,
    ["player_details_window"] = {
        ["scale"] = 1,
        ["statusbar_texture"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Status\\Glossy.blp",
        ["tab_color"] = {
            1, -- [1]
            0.5, -- [2]
            0, -- [3]
            0.7, -- [4]
        },
        ["frame_bg_color"] = {
            0.1, -- [1]
            0.1, -- [2]
            0.1, -- [3]
            0.9, -- [4]
        },
        ["bg_color"] = {
            0.1, -- [1]
            0.1, -- [2]
            0.1, -- [3]
            0.9, -- [4]
        },
        ["tab_bg_color"] = {
            0.05, -- [1]
            0.05, -- [2]
            0.05, -- [3]
            0.7, -- [4]
        },
        ["fg_color"] = {
            1, -- [1]
            0.6, -- [2]
            0.2, -- [3]
            0.9, -- [4]
        },
        ["tab_bg"] = true,
        ["tab_title"] = true,
        ["border_color"] = {
            0.7, -- [1]
            0.2, -- [2]
            0, -- [3]
            0.8, -- [4]
        },
        ["statusbar_info"] = {
            ["alpha"] = 0.8,
            ["overlay"] = {
                0.2, -- [1]
                0.2, -- [2]
                0.2, -- [3]
                0.6, -- [4]
            },
        },
    },
    ["broker_text"] = "",
    ["animation_speed_triggertravel"] = 1.5,
    ["animation_speed_maxtravel"] = 3,
    ["clear_ungrouped"] = true,
    ["chat_tab_embed"] = {
        ["enabled"] = false,
        ["tab_name"] = "",
        ["x_offset"] = 0,
        ["y_offset"] = 0,
        ["single_window"] = false,
    },
    ["cloud_capture"] = true,
    ["event_tracker"] = {
        ["show_cast_bar"] = true,
        ["show_cooldowns"] = true,
        ["show_interrupts"] = true,
        ["show_buffs"] = true,
        ["text_color"] = {
            1, -- [1]
            1, -- [2]
            1, -- [3]
            1, -- [4]
        },
        ["cooldowns"] = true,
        ["enabled"] = true,
        ["frame"] = {
            ["height"] = 300,
            ["width"] = 250,
            ["show_title"] = true,
            ["locked"] = false,
            ["backdrop_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0.2, -- [4]
            },
            ["resizable"] = true,
            ["line_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0, -- [4]
            },
            ["font_size"] = 10,
            ["point"] = "CENTER",
            ["number_of_lines"] = 15,
            ["title_backdrop_color"] = {
                1, -- [1]
                0.5, -- [2]
                0, -- [3]
                0.6, -- [4]
            },
            ["scale"] = 1,
            ["backdrop"] = true,
            ["relative_points"] = {
                ["y"] = 3,
                ["x"] = -3,
                ["point"] = "RIGHT",
            },
            ["title_color"] = {
                1, -- [1]
                0.7, -- [2]
                0.3, -- [3]
                0.8, -- [4]
            },
            ["fixed_texture_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
            },
            ["fixed_texture_background_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0.15, -- [4]
            },
            ["texture"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Status\\Gradient.blp",
            ["text_color"] = {
                1, -- [1]
                1, -- [2]
                1, -- [3]
                1, -- [4]
            },
            ["texture_background_file"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp",
        },
        ["spell_interrupt"] = false,
        ["fonts"] = {
            ["main"] = "Expressway",
            ["secondary"] = "Expressway",
        },
    },
    
    -- Window 1 (main window)
    ["instances"] = {
        {
            ["__snapH"] = false,
            ["__snapV"] = false,
            ["menu_icons"] = {
                true, -- [1] Leave current segment
                true, -- [2] Menu
                true, -- [3] Control
                true, -- [4] Segment
                true, -- [5] Reset
                true, -- [6] Pots
                true, -- [7] Encounter Details
                true, -- [8] Report
            },
            ["StatusBarSaved"] = {
                ["center"] = "DETAILS_STATUSBAR_PLUGIN_CLOCK",
                ["right"] = "DETAILS_STATUSBAR_PLUGIN_PDPS",
                ["options"] = {
                    ["DETAILS_STATUSBAR_PLUGIN_THREAT"] = {
                        ["isHidden"] = false,
                        ["segmentType"] = 2,
                    },
                    ["DETAILS_STATUSBAR_PLUGIN_CLOCK"] = {
                        ["isHidden"] = false,
                        ["segmentType"] = 2,
                    },
                    ["DETAILS_STATUSBAR_PLUGIN_PSEGMENT"] = {
                        ["isHidden"] = false,
                        ["segmentType"] = 2,
                    },
                    ["DETAILS_STATUSBAR_PLUGIN_PDPS"] = {
                        ["isHidden"] = false,
                        ["segmentType"] = 2,
                    },
                },
                ["left"] = "DETAILS_STATUSBAR_PLUGIN_PSEGMENT",
            },
            ["__was_opened"] = true,
            ["hide_in_combat_type"] = 1,
            ["total_bar"] = {
                ["enabled"] = true,
                ["only_in_group"] = true,
                ["icon"] = "Interface\\ICONS\\INV_Misc_PheonixPet_01",
                ["color"] = {
                    1, -- [1]
                    0.5, -- [2]
                    0, -- [3]
                    0.8, -- [4]
                },
            },
            ["menu_anchor"] = {
                16, -- [1]
                0, -- [2]
                ["side"] = 2,
            },
            ["__pos"] = {
                ["scale"] = 1,
                ["normal"] = {
                    ["y"] = -500,
                    ["x"] = -80,
                    ["w"] = 250,
                    ["h"] = 130,
                },
                ["solo"] = {
                    ["y"] = 2,
                    ["x"] = 1,
                    ["w"] = 300,
                    ["h"] = 200,
                },
            },
            ["bars_inverted"] = false,
            ["skin"] = "Phoenix_UI",
            ["row_info"] = {
                ["spec_file"] = "Interface\\AddOns\\Details\\images\\spec_icons_normal",
                ["textL_outline"] = true,
                ["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
                ["textR_outline"] = true,
                ["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small",
                ["start_after_icon"] = true,
                ["percent_type"] = 1,
                ["textR_enable_custom_text"] = false,
                ["texture_background_class_color"] = false,
                ["alpha"] = 1,
                ["fast_ps_update"] = false,
                ["textR_separator"] = ",",
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
                ["backdrop"] = {
                    ["enabled"] = false,
                    ["size"] = 12,
                },
                ["use_spec_icons"] = true,
                ["textR_class_colors"] = true,
                ["texture_background_file"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp",
                ["textL_class_colors"] = true,
                ["textL_enable_custom_text"] = false,
                ["fixed_texture_color"] = {
                    1, -- [1]
                    0.5, -- [2]
                    0, -- [3]
                    0.7, -- [4]
                },
                ["texture"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Status\\Gradient.blp",
                ["textL_show_number"] = true,
                ["height"] = 18,
                ["font_size"] = 11,
                ["font_face"] = "Expressway",
                ["textL_custom_text"] = "{data1}. {data3}{data2}",
                ["texture_background"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp",
                ["fixed_texture_background_color"] = {
                    0.1, -- [1]
                    0.1, -- [2]
                    0.1, -- [3]
                    0.7, -- [4]
                },
                ["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
                ["textR_outline_small"] = true,
                ["textL_outline_small"] = true,
                ["texture_background_alpha"] = 0.8,
            },
            ["menu_icons_size"] = 0.85,
            ["menu_access_compare_boundtables"] = false,
            ["bars_grow_direction"] = 1,
            ["plugins_grow_direction"] = 1,
            ["bg_r"] = 0.1,
            ["auto_current"] = true,
            ["bg_g"] = 0.1,
            ["show_statusbar"] = true,
            ["toolbar_side"] = 1,
            ["instance_button_anchor"] = {
                -27, -- [1]
                1, -- [2]
            },
            ["hide_icon"] = false,
            ["bg_alpha"] = 0.9,
            ["statusbar_info"] = {
                ["alpha"] = 0.8,
                ["overlay"] = {
                    0.2, -- [1]
                    0.2, -- [2]
                    0.2, -- [3]
                    0.6, -- [4]
                },
            },
            ["desaturated_menu"] = false,
            ["micro_displays_side"] = 2,
            ["hide_on_combat"] = false,
            ["switch_tank_in_combat"] = false,
            ["switch_damager_in_combat"] = false,
            ["color"] = {
                0.1, -- [1]
                0.1, -- [2]
                0.1, -- [3]
                0.9, -- [4]
            },
            ["menu_anchor_down"] = {
                16, -- [1]
                -3, -- [2]
            },
            ["strata"] = "LOW",
            ["grab_on_top"] = false,
            ["backdrop_texture"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp",
            ["hide_in_combat"] = false,
            ["row_show_animation"] = {
                ["anim"] = "Fade",
                ["options"] = {
                    ["duration"] = 0.2,
                    ["type"] = "originAlpha",
                },
            },
            ["bg_b"] = 0.1,
            ["libwindow"] = {
                ["y"] = 0,
                ["x"] = 0,
                ["point"] = "CENTER",
                ["scale"] = 1,
            },
            ["switch_healer_in_combat"] = false,
            ["attribute_text"] = {
                ["enabled"] = true,
                ["shadow"] = true,
                ["side"] = 1,
                ["text_size"] = 12,
                ["custom_text"] = "{name}",
                ["text_face"] = "Expressway",
                ["anchor"] = {
                    -18, -- [1]
                    3, -- [2]
                },
                ["text_color"] = {
                    1, -- [1]
                    0.7, -- [2]
                    0.3, -- [3]
                    1, -- [4]
                },
                ["enable_custom_text"] = false,
                ["show_timer"] = {
                    true, -- [1]
                    true, -- [2]
                    true, -- [3]
                },
            },
            ["backdrop_color"] = {
                0.1, -- [1]
                0.1, -- [2]
                0.1, -- [3]
                0.9, -- [4]
            },
            ["bars_sort_direction"] = 1,
            ["micro_displays_locked"] = true,
            ["wallpaper"] = {
                ["enabled"] = false,
                ["texture"] = "Interface\\ARCHEOLOGY\\Arch-BookCompletedLeft",
                ["texcoord"] = {
                    0.00100000001490116, -- [1]
                    1, -- [2]
                    0.00100000001490116, -- [3]
                    0.703000030517578, -- [4]
                },
                ["overlay"] = {
                    0.999997794628143, -- [1]
                    0.999997794628143, -- [2]
                    0.999997794628143, -- [3]
                    0.799998223781586, -- [4]
                },
                ["anchor"] = "all",
                ["height"] = 225.999984741211,
                ["alpha"] = 0.8,
                ["width"] = 266.000061035156,
            },
            ["hide_out_of_combat"] = false,
            ["show_sidebars"] = false,
            ["window_scale"] = 1,
        },
    },
    
    -- Window 2 (optional)
    ["instances_amount"] = 2,
    ["time_type"] = 2,
    ["time_type_original"] = 2,
    ["numerical_system"] = 1,
    ["damage_meter"] = {
        ["enabled"] = true,
        ["frame"] = {
            ["backdrop_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0.2, -- [4]
            },
            ["relative_points"] = {
                ["y"] = 1,
                ["x"] = -3,
                ["point"] = "BOTTOMRIGHT",
            },
            ["text_color"] = {
                1, -- [1]
                1, -- [2]
                1, -- [3]
                1, -- [4]
            },
            ["backdrop"] = true,
            ["fixed_texture_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
            },
            ["color"] = {
                0.5, -- [1]
                0.5, -- [2]
                0.5, -- [3]
                0.9, -- [4]
            },
            ["fixed_texture_background_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0.2, -- [4]
            },
            ["font_face"] = "Expressway",
            ["font_size"] = 10,
            ["point"] = "LEFT",
            ["height"] = 120,
            ["backdrop_texture"] = "Interface\\AddOns\\Phoenix_UI\\Media\\Textures\\Background\\DarkPanel.blp",
            ["backdrop_border_color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                1, -- [4]
            },
            ["y"] = 1,
            ["x"] = 3,
            ["width"] = 200,
            ["show_title"] = true,
            ["scale"] = 1,
            ["title_color"] = {
                1, -- [1]
                0.7, -- [2]
                0.3, -- [3]
                0.8, -- [4]
            },
            ["title_backdrop_color"] = {
                1, -- [1]
                0.5, -- [2]
                0, -- [3]
                0.6, -- [4]
            },
        },
        ["font_color"] = {
            1, -- [1]
            1, -- [2]
            1, -- [3]
            1, -- [4]
        },
        ["font_shadow"] = true,
        ["font_size"] = 10,
        ["font_face"] = "Expressway",
        ["always_show"] = false,
        ["text_offset"] = 2,
        ["enabled_custom_text"] = false,
        ["custom_text"] = "{data1} ({data2}, {data3}%)",
        ["arena_enabled"] = true,
        ["mythic_dungeon_enabled"] = true,
    },
}

-- Import a pre-built profile into Details!
function DetailsSkin:ImportProfile()
    -- Check if Details exists
    if not self:IsDetailsLoaded() then
        self:Debug("Details not found, cannot import profile")
        if Phoenix_UI and Phoenix_UI.ShowNotification then
            Phoenix_UI:ShowNotification(L["DETAILS_SKIN"], L["DETAILS_SKIN_ERROR"], "Interface\\Icons\\INV_Misc_PheonixPet_01", 5)
        end
        return false
    end
    
    local Details = _G._detalhes
    
    -- Import the profile
    Details:ImportProfile(self.defaultProfile, nil, true)
    
    -- Show success notification
    if Phoenix_UI and Phoenix_UI.ShowNotification then
        Phoenix_UI:ShowNotification(L["DETAILS_SKIN"], L["DETAILS_SKIN_APPLIED"], "Interface\\Icons\\INV_Misc_PheonixPet_01", 5)
    end
    
    self:Debug("Phoenix profile imported to Details!")
    return true
end

-- Register slash command for direct import
DetailsSkin:RegisterChatCommand("phoeniximport", "ImportProfile") 