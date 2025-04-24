local Module = Phoenix_UI:NewModule("Skins.Collections");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Collections" then
                -- Collections Frame
                Phoenix_UI:Skin(CollectionsJournal, true)
                Phoenix_UI:Skin(CollectionsJournal.NineSlice, true)

                -- Mount Journal
                Phoenix_UI:Skin(MountJournal, true)
                Phoenix_UI:Skin(MountJournal.MountDisplay, true)
                Phoenix_UI:Skin(MountJournal.LeftInset.NineSlice, true)
                Phoenix_UI:Skin(MountJournal.BottomLeftInset, true)
                Phoenix_UI:Skin(MountJournal.BottomLeftInset.NineSlice, true)
                Phoenix_UI:Skin(MountJournal.RightInset.NineSlice, true)
                Phoenix_UI:Skin(MountJournal.BottomLeftInset.SlotButton, true)
                select(2, MountJournal.BottomLeftInset.SlotButton:GetRegions()):SetVertexColor(1, 1, 1)

                -- ToyBox
                Phoenix_UI:Skin(ToyBox, true)
                Phoenix_UI:Skin(ToyBox.iconsFrame, true)
                Phoenix_UI:Skin(ToyBox.iconsFrame.NineSlice, true)

                -- Heirlooms Journal
                Phoenix_UI:Skin(HeirloomsJournal, true)
                Phoenix_UI:Skin(HeirloomsJournal.iconsFrame, true)
                Phoenix_UI:Skin(HeirloomsJournal.iconsFrame.NineSlice, true)

                -- Pet Journal
                Phoenix_UI:Skin(PetJournalLeftInset, true)
                Phoenix_UI:Skin(PetJournalLeftInset.NineSlice, true)
                Phoenix_UI:Skin(PetJournalPetCardInset, true)
                Phoenix_UI:Skin(PetJournalPetCardInset.NineSlice, true)
                Phoenix_UI:Skin(PetJournalPetCard, true)
                Phoenix_UI:Skin(PetJournalLoadoutPet1, true)
                Phoenix_UI:Skin(PetJournalLoadoutPet2, true)
                Phoenix_UI:Skin(PetJournalLoadoutPet3, true)
                Phoenix_UI:Skin(PetJournalLoadoutBorder, true)
                Phoenix_UI:Skin(PetJournalRightInset.NineSlice, true)

                -- Wardrobe
                Phoenix_UI:Skin(WardrobeCollectionFrame.ItemsCollectionFrame, true)

                -- Specific Frames
                Phoenix_UI:Skin({
                    CollectionsJournalBg,
                    MountJournalListScrollFrameScrollBarThumbTexture,
                    MountJournalListScrollFrameScrollBarTop,
                    MountJournalListScrollFrameScrollBarMiddle,
                    MountJournalListScrollFrameScrollBarBottom,
                    PetJournalListScrollFrameScrollBarThumbTexture,
                    PetJournalListScrollFrameScrollBarTop,
                    PetJournalListScrollFrameScrollBarMiddle,
                    PetJournalListScrollFrameScrollBarBottom
                }, true, true)

                -- Tabs
                Phoenix_UI:Skin(CollectionsJournalTab1, true)
                Phoenix_UI:Skin(CollectionsJournalTab2, true)
                Phoenix_UI:Skin(CollectionsJournalTab3, true)
                Phoenix_UI:Skin(CollectionsJournalTab4, true)
                Phoenix_UI:Skin(CollectionsJournalTab5, true)
                Phoenix_UI:Skin(WardrobeCollectionFrameTab1, true)
                Phoenix_UI:Skin(WardrobeCollectionFrameTab2, true)
            end
        end)
    end
end



