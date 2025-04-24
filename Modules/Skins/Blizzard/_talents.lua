local Module = Phoenix_UI:NewModule("Skins.Talents");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_PlayerSpells" then
                Phoenix_UI:Skin(PlayerSpellsFrame, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame.SearchPreviewContainer, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame.SearchPreviewContainer.DefaultResultButton, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame.SearchBox, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame.LoadSystem, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame.LoadSystem.Dropdown, true)
                Phoenix_UI:Skin(HeroTalentsSelectionDialog, true)
                Phoenix_UI:Skin(HeroTalentsSelectionDialog.NineSlice, true)
                Phoenix_UI:Skin({
                    ClassTalentFrameTitleBg,
                    ClassTalentFrameBg,
                    ClassTalentFrameTalentsPvpTalentFrameTalentListBg
                }, true, true)

                -- Tabs
                Phoenix_UI:Skin(PlayerSpellsFrame.TalentsFrame.ApplyButton, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TabSystem.tabs[1], true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TabSystem.tabs[2], true)
                Phoenix_UI:Skin(PlayerSpellsFrame.TabSystem.tabs[3], true)

                -- Reset Background
                select(4, PlayerSpellsFrame.TalentsFrame:GetRegions()):SetVertexColor(1, 1, 1, 0.7)
                select(4, PlayerSpellsFrame.TalentsFrame:GetRegions()):SetDesaturated(false)
            end
        end)
    end
end



