local Module = Phoenix_UI:NewModule("Skins.EncounterJournal");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_EncounterJournal" then
                Phoenix_UI:Skin(EncounterJournal, true)
                Phoenix_UI:Skin(EncounterJournal.NineSlice, true)
                Phoenix_UI:Skin(EncounterJournalInset, true)
                Phoenix_UI:Skin(EncounterJournalInset.NineSlice, true)
                Phoenix_UI:Skin(EncounterJournalNavBar, true)
                Phoenix_UI:Skin(EncounterJournalNavBar.overlay, true)

                -- Tabs
                Phoenix_UI:Skin(EncounterJournalMonthlyActivitiesTab, true)
                Phoenix_UI:Skin(EncounterJournalSuggestTab, true)
                Phoenix_UI:Skin(EncounterJournalDungeonTab, true)
                Phoenix_UI:Skin(EncounterJournalRaidTab, true)
                Phoenix_UI:Skin(EncounterJournalLootJournalTab, true)
                EncounterJournalInset:SetAlpha(0)
            end
        end)
    end
end



