local Module = Phoenix_UI:NewModule("Skins.Dungeon");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(GameMenuFrame, true)
        Phoenix_UI:Skin(GameMenuFrame.Border, true)
        Phoenix_UI:Skin(StaticPopup1, true)
        Phoenix_UI:Skin(StaticPopup1.Border, true)
        Phoenix_UI:Skin(StaticPopup2, true)
        Phoenix_UI:Skin(StaticPopup2.Border, true)
        Phoenix_UI:Skin(StaticPopup3, true)
        Phoenix_UI:Skin(StaticPopup3.Border, true)
    end
end



