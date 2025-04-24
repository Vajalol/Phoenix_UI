if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

local L = BuffOverlay.L

L["%s %s is already being tracked."] = "%s %s 已在法术监视列表中。"
L["%s %s: Resets current profile to default settings. This does not remove any custom auras."] = "%s %s：将当前配置重置为默认值，但不会清除自定义法术。"
L["%s %s: Shows a copyable version string for bug reports."] = "%s %s：显示版本信息，用于错误回报。"
L["%s %s: Shows test icons on all visible raid/party frames."] = "%s %s：启用测试模式，在所有可见的队伍框体上显示测试光环。"
L["%s %s: Toggles the minimap icon."] = "%s %s：切换小地图按钮。"
L["%s Frames need to be visible in order to see test icons. If you are using a non-Blizzard frame addon, you will need to make the frames visible either by joining a group or through that addon's settings."] = [=[框体 %s 必需是可见的，才能显示测试图标。如果你使用暴雪内置团队框体以外的团队框体插件，必需要进到团队中、或开启该插件的测试模式，使框体可见，才能启用 BuffOverlay 的测试模式。
]=]
L["%s is already being tracked as a child of %s and cannot be edited."] = "已作为 %s 的子法术被监视，无法被编辑。"
L["%s is already being tracked under %s %s."] = "%s 已在 %s %s 中被监视。"
L["%s or %s: Toggles the options panel."] = "%s 或 %s：开启设置选项。"
L["%s to toggle options window."] = "%s开启设置选项"
L["%s to toggle test icons."] = "%s开启测试模式"
L["%s to toggle the minimap icon."] = "%s隐藏小地图按钮"
L["%s%sCopy this version number and send it to the author if you need help with a bug."] = "%s%s当你要回报一个错误时，复制这串文本，告诉作者你使用的版本。"
L["(%s: This is a default spell. Deleting it from this tab will simply reset all of its values to their defaults, but it will not be removed from the spells tab.)"] = "(%s: 这个法术在预设的监视清单中。从这里删除不会停止监视这个法术，只会将监视条件设置为默认值。)"
--[[Translation missing --]]
L["(Note: This will be automatically disabled if Masque is enabled for this bar.)"] = "(Note: This will be automatically disabled if Masque is enabled for this bar.)"
L["Action Button"] = "动作条"
--[[Translation missing --]]
L["Add %s to the custom spell list, opening up global settings to edit for this spell."] = "Add %s to the custom spell list, opening up global settings to edit for this spell."
--[[Translation missing --]]
L["Add a child spell ID to this spell. Child IDs will be checked like normal IDs but will use all the same settings (including icon) as its parent. Also, any changes to the parent will apply to all of its children. This is useful for spells that have multiple ids which are convenient to track as a single spell (e.g. different ranks of the same spell)."] = "Add a child spell ID to this spell. Child IDs will be checked like normal IDs but will use all the same settings (including icon) as its parent. Also, any changes to the parent will apply to all of its children. This is useful for spells that have multiple ids which are convenient to track as a single spell (e.g. different ranks of the same spell)."
L["Add an additional aura bar with default settings."] = "建立一个新的光环群组条，该群组会自动载入默认配置。"
L["Add Bar"] = "创建新群组"
L["Add Child Spell ID"] = "添加子法术 ID"
L["Adds a pixel border around the icon. This will also zoom the icon in slightly to remove any default borders that may be present."] = "使用像素边框。这会使图标的尺寸被略微放大，以去除图标材质的原版边框。"
L["Anchoring"] = "锚点"
L["Apply %s's custom settings (glow, glow color, glow type, own only, etc) to all auras in %s.%sThis does not include any global settings (prio, class, etc)."] = "将 %s 的设置应用至 %s 群组的所有光环，包含高亮、高亮颜色、显示条件是否仅自身等等。%s不包含全局设置（优先级、职业等）"
L["Apply to All"] = "应用至群组"
L["Are you sure you want to delete this bar?%s%s%s"] = "你确定要删除这个光环群组吗？%s%s%s"
L["Are you sure you want to delete this spell?"] = "你确定要删除这个法术吗？"
L["Aura List"] = "光环列表"
L["Author"] = "作者"
--[[Translation missing --]]
L["Bars"] = "Bars"
L["BOTTOM"] = "下"
L["BOTTOMLEFT"] = "左下"
L["BOTTOMRIGHT"] = "右下"
L["CENTER"] = "中"
L["Change the icon border color based on the dispel type of the buff. This overrides the icon border color."] = "以增益类型替图标边框著色，取代原本的自定义边框颜色"
L["Change the icon border color based on the dispel type of the debuff. This overrides the icon border color."] = "以减益类型替图标边框著色，取代原本的自定义边框颜色。"
L["Change the icon border color."] = "更改图标边框颜色。"
L["Change the icon border size (in pixels)."] = "更改图标边框的粗细，单位是像素 (px)。"
L["Change the icon group's X-Offset."] = "整此光环群组位置的水平偏移。"
L["Change the icon group's Y-Offset."] = "调整此光环群组位置的垂直偏移。"
L["Child Spell ID(s)"] = "子法术 ID"
L["Color Buff Icon Border by Dispel Type"] = "依增益类型著色图标边框"
L["Color Debuff Icon Border by Dispel Type"] = "依减益类型著色图标边框"
--[[Translation missing --]]
L["Command List"] = "Command List"
L["Cooldown Spiral"] = "转圈动画"
L["Cooldown Text Scale"] = "时间文字大小"
L["Copied settings, anchoring, and visibility tabs from %s to %s"] = "将 %s 的设置、锚点和能见度三个页面的配置复制到 %s"
L["Copied spells from %s to %s."] = "将 %s 的法术复制到 %s。"
L["Copy Settings From"] = "复制配置自"
L["Copy Spells From"] = "复制法术自"
L["Corrupted buff database found. This is likely due to updating from an older version of Buff Overlay. Resetting buff database to default. Your other settings (including custom buffs) will be preserved."] = "发现损坏的法术数据库，这可能是旧版 BuffOverlay 的储存格式导致的。现在已将数据库重设为默认值，其他设置（包括自定义法术）仍会保留。"
--[[Translation missing --]]
L["Custom Glow Color"] = "Custom Glow Color"
L["Custom Icon"] = "自定义图标"
L["Custom Spells"] = "自定义法术"
L["Delete Bar"] = "删除此群组"
L["Disable all spells."] = "停用所有法术。"
--[[Translation missing --]]
L["DOWN"] = "DOWN"
L["Eating/Drinking"] = "进食中"
L["Edit Global Settings"] = "编辑全局设置"
L["Enable a glow border effect around the icon."] = "在图标周围显示一圈高亮动画效果。"
L["Enable all spells."] = "启用所有法术"
--[[Translation missing --]]
L["Enabled Auras Priority List"] = "Enabled Auras Priority List"
L["Enter the spell ID of the spell you want to keep track of."] = "输入你想监视的法术之法术 ID"
L["Exiting test mode. Frame visibility will update out of combat."] = "退出测试模式。框体可见性将在脱离战斗后刷新。"
L["Frame Attachment Point"] = "锚点于框体的"
L["Frame Types"] = "框体类型"
L["Glow"] = "高亮"
L["Glow Type"] = "高亮方式"
L["Group Size"] = "团队大小"
L["Grow Direction"] = "增长方向"
--[[Translation missing --]]
L["HORIZONTAL"] = "HORIZONTAL"
L["Icon Alpha"] = "透明度"
L["Icon Anchor"] = "图标锚点"
L["Icon Border"] = "图标边框"
L["Icon Border Color"] = "边框颜色"
L["Icon Border Size"] = "边框大小"
L["Icon Count"] = "图标数量"
L["Icon position relative to its parent frame."] = "整个光环群组锚点于其父级框体的位置。"
L["Icon Scale"] = "图标大小"
L["Icon Spacing"] = "图标间距"
L["Icon transparency."] = "图标透明度。"
--[[Translation missing --]]
L[ [=[In addition to adding new spells here, you can also add any Spell ID from the spells tab to edit its default values.
(Note: anything you add here will persist through addon updates and profile resets.)]=] ] = [=[In addition to adding new spells here, you can also add any Spell ID from the spells tab to edit its default values.
(Note: anything you add here will persist through addon updates and profile resets.)]=]
L["In order for %s setting to work in BuffOverlay, cooldown text needs to be enabled in Blizzard settings. You can find this setting located at:%s%s%sWould you like BuffOverlay to enable this setting for you?%s"] = "要启用 %s，必需先启用暴雪的冷确时间文字。这个选项位于：%s%s%s你希望 BuffOverlay 直接替你启用这个选项吗？%s"
--[[Translation missing --]]
L["Interface > ActionBars > Show Numbers for Cooldowns"] = "Interface > ActionBars > Show Numbers for Cooldowns"
L["Invalid input for custom icon: %s"] = "无效的自定义图标：%s"
L["Invalid Spell ID %s"] = "无效的法术 ID %s"
L["Invalid Spell: %s"] = "无效的法术: %s"
--[[Translation missing --]]
L["Keep in mind you want to add the Spell ID of the aura that appears on the buff/debuff bar, not necessarily the Spell ID from the spell book or talent tree."] = "Keep in mind you want to add the Spell ID of the aura that appears on the buff/debuff bar, not necessarily the Spell ID from the spell book or talent tree."
L["LEFT"] = "左"
L["Left-click"] = "左键点击"
--[[Translation missing --]]
L["Legacy Blizzard"] = "Legacy Blizzard"
L["Minimap Icon"] = "小地图按钮"
L["Minimap icon is now hidden. Type %s %s to show it again."] = "小地图按钮已隐藏。输入 %s %s 可以重新显示。"
L["Never Show"] = "永不显示"
L["Never show this bar."] = "隐藏此光环群组。"
L["Number of icons you want to display (per frame)."] = "每个框体要显示几个图标。"
L["Only show the aura if you cast it."] = "只显示自己施放的光环。"
L["Open Options"] = "开启设置选项"
L["Options > Gameplay > Action Bars > Show Numbers for Cooldowns"] = "选项 > 游戏功能 > 动作条 > 显示冷却时间"
L["Own"] = "自己"
L["Pixel"] = "像素"
L["Priority"] = "优先级"
L["Priority (Lower is Higher Prio)"] = "优先级（越小越高）"
L["Priority must be a positive integer from 0 to 999999"] = "优先级必需是 0 ~ 999999 的正整数。"
L["Remove Custom Child Spell ID"] = "移除自定义子法术 ID"
L["RIGHT"] = "右"
L["Right-click"] = "右键点击"
L["Scale the icon's cooldown text size."] = "光环持续时间的文字大小。"
L["Scale the icon's stack count text size."] = "光环层数的文字大小。"
L["Scale the size of the icon. Base icon size is proportionate to its parent frame."] = "缩放图标大小，图标的基础尺寸是根据父级框体自动设置的。"
L["Set Bar Name"] = "命名此群组"
L["Shift+Right-click"] = "Shift+右键点击"
L["Show a test overlay for %s"] = "替 %s 显示测试光环。"
L["Show Blizzard Cooldown Text"] = "显示时间"
L["Show In Arena"] = "竞技场"
L["Show In Battleground"] = "战场"
L["Show In Dungeon"] = "地城"
L["Show In Raid"] = "团队"
L["Show In Scenario"] = "场景战役"
--[[Translation missing --]]
L["Show overlays on this frame type."] = "Show overlays on this frame type."
--[[Translation missing --]]
L[ [=[Show overlays on this frame type.

Blizzard frames do not currently support separate types.]=] ] = [=[Show overlays on this frame type.

Blizzard frames do not currently support separate types.]=]
L["Show Stack Count"] = "显示层数"
L["Show test overlays for this bar."] = "单独为此光环群组开启测试模式。"
L[ [=[Show this bar when the group size is equal to or greater than this value.

0=Solo with no group.
1=Solo in a group.]=] ] = [=[当队伍人数大于__，显示此光环群组。

0=单人，无队伍。
1=单人，在队伍中。]=]
L[ [=[Show this bar when the group size is equal to or less than this value.

0=Solo with no group.
1=Solo in a group.]=] ] = [=[当队伍人数小于__，显示此群组。

0=单人，无队伍。
1=单人，在队伍中。]=]
L["Show Tooltip On Hover"] = "指向时显示鼠标提示"
L["Show When Non-Instanced"] = "野外"
L["Shows a list of all enabled auras for this bar in order of priority."] = "此群组监视的光环列表。会依显示优先级显示。"
L["Spacing between icons. Spacing is scaled based on icon size for uniformity across different icon sizes."] = "群组中图标彼此的间距，会根据图标大小自动调整缩放比例，保持整个光环组的一致性。"
L["Spell ID"] = "法术 ID"
L["Spell ID %s is invalid and has been removed."] = "法术 ID %s 已失效并自清单中移除。"
L["Spell ID %s is invalid. If you haven't made any manual code changes, please report this to the author."] = "无效的法术 ID：%s。如果你没有更改任何原始代码就看到这条信息，请回报此问题给作者。"
L["Spell ID must be a positive integer from 0 to 9999999"] = "法术 ID 必需是 0 ~ 999999 的正整数。"
L["Stack Count Scale"] = "层数文字大小"
L["Test"] = "测试"
L["Test All"] = "全局测试"
L["Test Aura"] = "测试光环"
L["Test Bar"] = "测试此群组"
L["The icon ID to use for this spell. This will overwrite the default icon."] = "输入图标 ID，用指定的图标材质取代这个法术原有的图标。"
L["The priority of this spell. Lower numbers are higher priority. If two spells have the same priority, it will show alphabetically."] = "设置此法术的显示优先级，必需是数字。数字越小，优先级越高。如果同时存在两个相同优先级的法术，会按字母排序。"
--[[Translation missing --]]
L["There has been a major update and unfortunately your profiles need to be reset. Upside though, you can now add BuffOverlay aura bars in multiple locations on your frames! Check it out by typing %s in chat."] = "There has been a major update and unfortunately your profiles need to be reset. Upside though, you can now add BuffOverlay aura bars in multiple locations on your frames! Check it out by typing %s in chat."
--[[Translation missing --]]
L["This copies settings from 'Settings', 'Anchoring', and 'Visibility' tabs."] = "This copies settings from 'Settings', 'Anchoring', and 'Visibility' tabs."
--[[Translation missing --]]
L["This informational panel is the full list of spells currently enabled for %s in order of priority. Any aura changes made while this panel is open will be reflected here in real time."] = "This informational panel is the full list of spells currently enabled for %s in order of priority. Any aura changes made while this panel is open will be reflected here in real time."
L["Toggle showing of the cooldown spiral."] = "显示转圈动画效果。"
L["Toggle showing of the cooldown text."] = "显示持续时间。"
L["Toggle showing of the stack count text on the icon."] = "显示光环层数。"
L["Toggle showing of the tooltip when hovering over an icon."] = "当鼠标指向光环图标时，显示鼠标提示。"
L["Toggle showing of the welcome message on login."] = "进入游戏时在聊天框显示欢迎信息。"
L["Toggle showing this bar in a battleground."] = "在战场中显示。"
L["Toggle showing this bar in a dungeon instance."] = "在地城副本中显示。"
L["Toggle showing this bar in a raid instance."] = "在团队副本中显示。"
L["Toggle showing this bar in a scenario."] = "在场景战役中显示。"
L["Toggle showing this bar in an arena."] = "在竞技场中显示。"
L["Toggle showing this bar in the world/outside of instances."] = "在非副本的野外环境中显示。"
L["Toggle test overlays for all bars."] = "测试所有的光环群组。"
L["Toggle the minimap icon."] = "启用小地图按钮。"
--[[Translation missing --]]
L["Toggle whether or not to use a custom color for glow."] = "Toggle whether or not to use a custom color for glow."
L["TOP"] = "上"
L["TOPLEFT"] = "左上"
L["TOPRIGHT"] = "右上"
L["Type %s or %s to open the options panel or %s for more commands."] = "输入 %s 或 %s 打开设置选项，也可以输入 %s 查看更多命令。"
--[[Translation missing --]]
L["UP"] = "UP"
--[[Translation missing --]]
L["VERTICAL"] = "VERTICAL"
L["Visibility"] = "能见度"
L["Welcome Message"] = "欢迎信息"
L["Where the anchor is on the icon."] = "图标在群组中的锚点位置。"
L["Where the icons will grow from the first icon."] = "显示复数图标时，图标的增长方向。"
L["X-Offset"] = "水平偏移"
L["Y-Offset"] = "垂直偏移"




