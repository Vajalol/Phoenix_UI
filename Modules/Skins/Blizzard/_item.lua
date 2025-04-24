local Module = Phoenix_UI:NewModule("Skins.Item");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(ItemTextFrame, true)
        Phoenix_UI:Skin(ItemTextFrame.NineSlice, true)
    end
end



