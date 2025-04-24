local Module = Phoenix_UI:NewModule("Skins.Dressup")

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(DressUpFrame, true)
        Phoenix_UI:Skin(DressUpFrame.NineSlice, true)
        Phoenix_UI:Skin(DressUpFrame.OutfitDetailsPanel, true)
        Phoenix_UI:Skin(DressUpFrameInset, true)
        Phoenix_UI:Skin(DressUpFrameInset.NineSlice, true)
    end
end



