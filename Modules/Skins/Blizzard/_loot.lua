local Module = Phoenix_UI:NewModule("Skins.Loot");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(LootFrame, true)
        Phoenix_UI:Skin(LootFrame.NineSlice, true)
    end
end



