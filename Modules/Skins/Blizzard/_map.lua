local Module = Phoenix_UI:NewModule("Skins.Map");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(WorldMapFrame, true)
        Phoenix_UI:Skin(WorldMapFrame.BorderFrame, true)
        Phoenix_UI:Skin(WorldMapFrame.BorderFrame.NineSlice, true)
        Phoenix_UI:Skin(WorldMapFrame.NavBar, true)
        Phoenix_UI:Skin(WorldMapFrame.NavBar.overlay, true)
    end
end



