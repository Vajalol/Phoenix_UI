local Module = Phoenix_UI:NewModule("Skins.Wardrobe");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Collections" or name == "Blizzard_Wardrobe" then
                Phoenix_UI:Skin(WardrobeFrame, true)
                Phoenix_UI:Skin(WardrobeFrame.NineSlice, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.ItemsCollectionFrame, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.SetsCollectionFrame, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.NineSlice, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.RightInset, true)
                Phoenix_UI:Skin(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.NineSlice, true)
                Phoenix_UI:Skin({
                    WardrobeCollectionFrameScrollFrameScrollBarBottom,
                    WardrobeCollectionFrameScrollFrameScrollBarMiddle,
                    WardrobeCollectionFrameScrollFrameScrollBarTop,
                    WardrobeCollectionFrameScrollFrameScrollBarThumbTexture
                }, true, true)
            end
        end)
    end
end



