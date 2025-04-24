if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local L = BuffOverlay.L

L["%s %s is already being tracked."] = "%s %s 已在法術監視列表中。"
L["%s %s: Resets current profile to default settings. This does not remove any custom auras."] = "%s %s：將目前使用的設定檔重設為預設值，但不會清除自訂法術。"
L["%s %s: Shows a copyable version string for bug reports."] = "%s %s：顯示一串可複製的版本資訊文字，用於錯誤回報。"
L["%s %s: Shows test icons on all visible raid/party frames."] = "%s %s：開啟測試模式，在所有可見的隊伍框架上顯示測試用光環。"
L["%s %s: Toggles the minimap icon."] = "%s %s：切換小地圖按鈕。"
L["%s Frames need to be visible in order to see test icons. If you are using a non-Blizzard frame addon, you will need to make the frames visible either by joining a group or through that addon's settings."] = "框架 %s 必需是可見的，才能顯示測試圖示。如果你使用暴雪內建團隊以外的團隊框架插件，你要進到團隊中、或開啟該插件的測試模式，使框架可見，才能啟用 BuffOverlay 的測試模式。"
L["%s is already being tracked as a child of %s and cannot be edited."] = "%s 已作為 %s 的子法術被監視，無法被編輯。"
L["%s is already being tracked under %s %s."] = "%s 已在 %s %s 中被監視。"
L["%s or %s: Toggles the options panel."] = "%s 或 %s：開啟設定選項。"
L["%s to toggle options window."] = "%s開啟選項"
L["%s to toggle test icons."] = "%s開啟測試模式"
L["%s to toggle the minimap icon."] = "%s隱藏小地圖按鈕"
L["%s%sCopy this version number and send it to the author if you need help with a bug."] = "%s%s當你要回報一個錯誤時，複製這串文字，告訴作者你使用的版本。"
L["(%s: This is a default spell. Deleting it from this tab will simply reset all of its values to their defaults, but it will not be removed from the spells tab.)"] = "(%s: 這個法術在預設的監視清單中。從這裡刪除不會停止監視這個法術，只會將監視條件的設定恢復成預設值。)"
--[[Translation missing --]]
L["(Note: This will be automatically disabled if Masque is enabled for this bar.)"] = "(Note: This will be automatically disabled if Masque is enabled for this bar.)"
L["Action Button"] = "快捷鍵"
--[[Translation missing --]]
L["Add %s to the custom spell list, opening up global settings to edit for this spell."] = "Add %s to the custom spell list, opening up global settings to edit for this spell."
--[[Translation missing --]]
L["Add a child spell ID to this spell. Child IDs will be checked like normal IDs but will use all the same settings (including icon) as its parent. Also, any changes to the parent will apply to all of its children. This is useful for spells that have multiple ids which are convenient to track as a single spell (e.g. different ranks of the same spell)."] = "Add a child spell ID to this spell. Child IDs will be checked like normal IDs but will use all the same settings (including icon) as its parent. Also, any changes to the parent will apply to all of its children. This is useful for spells that have multiple ids which are convenient to track as a single spell (e.g. different ranks of the same spell)."
L["Add an additional aura bar with default settings."] = "建立一個新的光環群組條，該群組會自動載入預設的設定值。"
L["Add Bar"] = "創建新群組"
L["Add Child Spell ID"] = "添加子法術 ID"
L["Adds a pixel border around the icon. This will also zoom the icon in slightly to remove any default borders that may be present."] = "使用像素邊框。這會使圖示的尺寸被略微放大，以去除圖示材質既有的原版邊框。"
L["Anchoring"] = "錨點"
L["Apply %s's custom settings (glow, glow color, glow type, own only, etc) to all auras in %s.%sThis does not include any global settings (prio, class, etc)."] = "將 %s 的設定套用至 %s 群組的所有光環，包含高亮、高亮顏色、顯示條件是否僅自身等等。%s不包含全局設定（優先級、職業等）"
L["Apply to All"] = "套用至群組"
L["Are you sure you want to delete this bar?%s%s%s"] = "你確定要刪除這個光環群组條嗎？%s%s%s"
L["Are you sure you want to delete this spell?"] = "你確定要刪除這個法術嗎？"
L["Aura List"] = "光環列表"
L["Author"] = "作者"
--[[Translation missing --]]
L["Bars"] = "Bars"
L["BOTTOM"] = "下"
L["BOTTOMLEFT"] = "左下"
L["BOTTOMRIGHT"] = "右下"
L["CENTER"] = "中"
L["Change the icon border color based on the dispel type of the buff. This overrides the icon border color."] = "以增益效果的類型替圖示邊框染色，取代原本的自訂邊框顏色。"
L["Change the icon border color based on the dispel type of the debuff. This overrides the icon border color."] = "以減益效果的類型替圖示邊框染色，取代原本的自訂邊框顏色。"
L["Change the icon border color."] = "更改圖示邊框顏色。"
L["Change the icon border size (in pixels)."] = "更改圖示邊框的粗細，單位是像素 (px)。"
L["Change the icon group's X-Offset."] = "調整此光環群組位置的水平偏移。"
L["Change the icon group's Y-Offset."] = "調整此光環群組位置的垂直偏移。"
L["Child Spell ID(s)"] = "子法術 ID"
L["Color Buff Icon Border by Dispel Type"] = "依增益類型染色圖示邊框"
L["Color Debuff Icon Border by Dispel Type"] = "依減益類型染色圖示邊框"
--[[Translation missing --]]
L["Command List"] = "Command List"
L["Cooldown Spiral"] = "轉圈動畫"
L["Cooldown Text Scale"] = "時間文字大小"
L["Copied settings, anchoring, and visibility tabs from %s to %s"] = "將 %s 的設定、錨點和能見度三個頁面的設定複製到 %s"
L["Copied spells from %s to %s."] = "將 %s 的法術複製到 %s。"
L["Copy Settings From"] = "複製設定自"
L["Copy Spells From"] = "複製法術自"
L["Corrupted buff database found. This is likely due to updating from an older version of Buff Overlay. Resetting buff database to default. Your other settings (including custom buffs) will be preserved."] = "發現損壞的法術資料庫，這可能是舊版 BuffOverlay 的儲存格式導致的。現在已將資料庫重設為預設值，其他設定（包括自訂法術）仍會保留。"
--[[Translation missing --]]
L["Custom Glow Color"] = "Custom Glow Color"
L["Custom Icon"] = "自訂圖示"
L["Custom Spells"] = "自訂法術"
L["Delete Bar"] = "刪除此群組"
L["Disable all spells."] = "停用所有法術。"
--[[Translation missing --]]
L["DOWN"] = "DOWN"
L["Eating/Drinking"] = "進食中"
--[[Translation missing --]]
L["Edit Global Settings"] = "Edit Global Settings"
L["Enable a glow border effect around the icon."] = "在圖示周圍顯示一圈高亮動畫效果。"
L["Enable all spells."] = "啟用所有法術"
--[[Translation missing --]]
L["Enabled Auras Priority List"] = "Enabled Auras Priority List"
L["Enter the spell ID of the spell you want to keep track of."] = "輸入你想監視的法術之法術 ID。"
L["Exiting test mode. Frame visibility will update out of combat."] = "關閉測試模式。框架可見性會在離開戰鬥後更新。"
L["Frame Attachment Point"] = "錨點於框架的"
L["Frame Types"] = "框架類型"
L["Glow"] = "高亮"
L["Glow Type"] = "高亮方式"
L["Group Size"] = "團隊大小"
L["Grow Direction"] = "增長方向"
--[[Translation missing --]]
L["HORIZONTAL"] = "HORIZONTAL"
L["Icon Alpha"] = "透明度"
L["Icon Anchor"] = "圖示錨點"
L["Icon Border"] = "圖示邊框"
L["Icon Border Color"] = "邊框顏色"
L["Icon Border Size"] = "邊框大小"
L["Icon Count"] = "圖示數量"
L["Icon position relative to its parent frame."] = "整個光環群組錨點於其父級框架的位置。"
L["Icon Scale"] = "圖示大小"
L["Icon Spacing"] = "圖示間距"
L["Icon transparency."] = "圖示透明度。"
--[[Translation missing --]]
L[ [=[In addition to adding new spells here, you can also add any Spell ID from the spells tab to edit its default values.
(Note: anything you add here will persist through addon updates and profile resets.)]=] ] = [=[In addition to adding new spells here, you can also add any Spell ID from the spells tab to edit its default values.
(Note: anything you add here will persist through addon updates and profile resets.)]=]
L["In order for %s setting to work in BuffOverlay, cooldown text needs to be enabled in Blizzard settings. You can find this setting located at:%s%s%sWould you like BuffOverlay to enable this setting for you?%s"] = "要啟用 %s，必需先啟用暴雪的冷確時間文字。這個選項位於：%s%s%s你希望 BuffOverlay 直接替你啟用這個選項嗎？%s"
--[[Translation missing --]]
L["Interface > ActionBars > Show Numbers for Cooldowns"] = "Interface > ActionBars > Show Numbers for Cooldowns"
L["Invalid input for custom icon: %s"] = "無效的自訂圖示：%s"
L["Invalid Spell ID %s"] = "無效的法術 ID %s"
L["Invalid Spell: %s"] = "無效的法術: %s"
--[[Translation missing --]]
L["Keep in mind you want to add the Spell ID of the aura that appears on the buff/debuff bar, not necessarily the Spell ID from the spell book or talent tree."] = "Keep in mind you want to add the Spell ID of the aura that appears on the buff/debuff bar, not necessarily the Spell ID from the spell book or talent tree."
L["LEFT"] = "左"
L["Left-click"] = "左鍵點擊"
--[[Translation missing --]]
L["Legacy Blizzard"] = "Legacy Blizzard"
L["Minimap Icon"] = "小地圖按鈕"
L["Minimap icon is now hidden. Type %s %s to show it again."] = "小地圖按鈕已隱藏。輸入 %s %s 可以重新顯示。"
L["Never Show"] = "永不顯示"
L["Never show this bar."] = "隱藏此光環群組。"
L["Number of icons you want to display (per frame)."] = "每個框架要顯示幾個光環圖示。"
L["Only show the aura if you cast it."] = "只顯示自己施放的光環。"
L["Open Options"] = "開啟選項"
L["Options > Gameplay > Action Bars > Show Numbers for Cooldowns"] = "選項 > 遊戲體驗 > 快捷列 > 顯示冷卻時間"
L["Own"] = "自己"
L["Pixel"] = "像素"
L["Priority"] = "優先級"
L["Priority (Lower is Higher Prio)"] = "優先級（越小越高）"
L["Priority must be a positive integer from 0 to 999999"] = "優先級必需是 0 ~ 999999 的正整數。"
L["Remove Custom Child Spell ID"] = "移除自訂子法術 ID"
L["RIGHT"] = "右"
L["Right-click"] = "右鍵點擊"
L["Scale the icon's cooldown text size."] = "光環持續時間的文字大小。"
L["Scale the icon's stack count text size."] = "光環層數的文字大小。"
L["Scale the size of the icon. Base icon size is proportionate to its parent frame."] = "縮放圖示大小，圖示的基礎尺寸是根據父級框架自動設定的。"
L["Set Bar Name"] = "命名此群組"
L["Shift+Right-click"] = "Shift+右鍵點擊"
L["Show a test overlay for %s"] = "替 %s 顯示測試光環。"
L["Show Blizzard Cooldown Text"] = "顯示時間"
L["Show In Arena"] = "競技場"
L["Show In Battleground"] = "戰場"
L["Show In Dungeon"] = "地城"
L["Show In Raid"] = "團隊"
L["Show In Scenario"] = "場景戰役"
--[[Translation missing --]]
L["Show overlays on this frame type."] = "Show overlays on this frame type."
--[[Translation missing --]]
L[ [=[Show overlays on this frame type.

Blizzard frames do not currently support separate types.]=] ] = [=[Show overlays on this frame type.

Blizzard frames do not currently support separate types.]=]
L["Show Stack Count"] = "顯示層數"
L["Show test overlays for this bar."] = "單獨為此光環群組開啟測試模式。"
L[ [=[Show this bar when the group size is equal to or greater than this value.

0=Solo with no group.
1=Solo in a group.]=] ] = [=[當隊伍人數大於__，顯示此光環群組。

0=單人，無隊伍。
1=單人，在隊伍中。]=]
L[ [=[Show this bar when the group size is equal to or less than this value.

0=Solo with no group.
1=Solo in a group.]=] ] = [=[當隊伍人數小於__，顯示此群組。

0=單人，無隊伍。
1=單人，在隊伍中。]=]
L["Show Tooltip On Hover"] = "指向時顯示滑鼠提示"
L["Show When Non-Instanced"] = "野外"
L["Shows a list of all enabled auras for this bar in order of priority."] = "此群組監視的光環列表。會依顯示優先級顯示。"
L["Spacing between icons. Spacing is scaled based on icon size for uniformity across different icon sizes."] = "群組中圖示彼此的間距，會根據圖示大小自動調整縮放比例，保持整個光環組的一致性。"
L["Spell ID"] = "法術 ID"
L["Spell ID %s is invalid and has been removed."] = "法術 ID %s 已失效並自清單中移除。"
L["Spell ID %s is invalid. If you haven't made any manual code changes, please report this to the author."] = "無效的法術 ID：%s。如果你沒有更改任何原始代碼就看到這條訊息，請回報此問題給作者。"
L["Spell ID must be a positive integer from 0 to 9999999"] = "法術 ID 必需是 0 ~ 999999 的正整數。"
L["Stack Count Scale"] = "層數文字大小"
L["Test"] = "測試"
L["Test All"] = "全局測試"
L["Test Aura"] = "測試光環"
L["Test Bar"] = "測試此群組"
L["The icon ID to use for this spell. This will overwrite the default icon."] = "輸入圖示 ID，用指定的圖示材質取代這個法術原有的圖示。"
L["The priority of this spell. Lower numbers are higher priority. If two spells have the same priority, it will show alphabetically."] = "設定此法術的顯示優先級，必需是數字。數字越小，優先級越高。如果同時存在兩個相同優先級的法術，會按字母排序。"
--[[Translation missing --]]
L["There has been a major update and unfortunately your profiles need to be reset. Upside though, you can now add BuffOverlay aura bars in multiple locations on your frames! Check it out by typing %s in chat."] = "There has been a major update and unfortunately your profiles need to be reset. Upside though, you can now add BuffOverlay aura bars in multiple locations on your frames! Check it out by typing %s in chat."
--[[Translation missing --]]
L["This copies settings from 'Settings', 'Anchoring', and 'Visibility' tabs."] = "This copies settings from 'Settings', 'Anchoring', and 'Visibility' tabs."
--[[Translation missing --]]
L["This informational panel is the full list of spells currently enabled for %s in order of priority. Any aura changes made while this panel is open will be reflected here in real time."] = "This informational panel is the full list of spells currently enabled for %s in order of priority. Any aura changes made while this panel is open will be reflected here in real time."
L["Toggle showing of the cooldown spiral."] = "顯示轉圈動畫。"
L["Toggle showing of the cooldown text."] = "顯示持續時間。"
L["Toggle showing of the stack count text on the icon."] = "顯示光環層數。"
L["Toggle showing of the tooltip when hovering over an icon."] = "當滑鼠指向光環圖示時，顯示滑鼠提示。"
L["Toggle showing of the welcome message on login."] = "登入時在聊天框顯示歡迎訊息。"
L["Toggle showing this bar in a battleground."] = "在戰場中顯示。"
L["Toggle showing this bar in a dungeon instance."] = "在地城副本中顯示。"
L["Toggle showing this bar in a raid instance."] = "在團隊副本中顯示。"
L["Toggle showing this bar in a scenario."] = "在場景戰役中顯示。"
L["Toggle showing this bar in an arena."] = "在競技場中顯示。"
L["Toggle showing this bar in the world/outside of instances."] = "在非副本的野外環境中顯示。"
L["Toggle test overlays for all bars."] = "測試所有的光環群組。"
L["Toggle the minimap icon."] = "啟用小地圖按鈕。"
--[[Translation missing --]]
L["Toggle whether or not to use a custom color for glow."] = "Toggle whether or not to use a custom color for glow."
L["TOP"] = "上"
L["TOPLEFT"] = "左上"
L["TOPRIGHT"] = "右上"
L["Type %s or %s to open the options panel or %s for more commands."] = "輸入 %s 或 %s 打開選項設定，也可以輸入 %s 查看更多指令。"
--[[Translation missing --]]
L["UP"] = "UP"
--[[Translation missing --]]
L["VERTICAL"] = "VERTICAL"
L["Visibility"] = "能見度"
L["Welcome Message"] = "歡迎訊息"
L["Where the anchor is on the icon."] = "圖示在群組中的錨點位置。"
L["Where the icons will grow from the first icon."] = "圖示的增長方向。"
L["X-Offset"] = "水平偏移"
L["Y-Offset"] = "垂直偏移"




