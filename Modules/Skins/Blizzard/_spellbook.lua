local Module = Phoenix_UI:NewModule("Skins.SpellBook");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            -- Professions
            if name == "Blizzard_ProfessionsBook" then
                Phoenix_UI:Skin(ProfessionsBookFrame, true)
                Phoenix_UI:Skin(ProfessionsBookFrame.NineSlice, true)
                Phoenix_UI:Skin(ProfessionsBookFrameInset, true)
                Phoenix_UI:Skin(ProfessionsBookFrameInset.NineSlice, true)
                Phoenix_UI:Skin({
                    ProfessionsBookPage1,
                    ProfessionsBookPage2
                }, true, true)

                for i, v in pairs({
                    SecondaryProfession1Missing,
                    SecondaryProfession1.missingText,
                    SecondaryProfession2Missing,
                    SecondaryProfession2.missingText,
                    SecondaryProfession3Missing,
                    SecondaryProfession3.missingText,
                }) do
                    v:SetVertexColor(0.8, 0.8, 0.8)
                end
            end

            -- Spellbook
            if name == "Blizzard_PlayerSpells" then
                Phoenix_UI:Skin(PlayerSpellsFrame, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.SpellBookFrame, true)
                Phoenix_UI:Skin(PlayerSpellsFrame.NineSlice, true)

                -- Tabs
                Phoenix_UI:Skin(PlayerSpellsFrame.SpellBookFrame.CategoryTabSystem.tabs[1], true)
                Phoenix_UI:Skin(PlayerSpellsFrame.SpellBookFrame.CategoryTabSystem.tabs[2], true)
                PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.PagingControls.PageText:SetVertexColor(0.8, 0.8, 0.8)
                hooksecurefunc(SpellBookItemMixin, "UpdateVisuals", function(self)
                    self.Name:SetTextColor(0.8, 0.8, 0.8)
                    self.Button.Border:SetVertexColor(0.5, 0.5, 0.5)
                end)
            end
        end)
    end
end



