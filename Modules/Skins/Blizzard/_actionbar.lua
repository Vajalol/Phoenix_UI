local Module = Phoenix_UI:NewModule("Skins.ActionBar");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(MainMenuBar, true)
        Phoenix_UI:Skin(MainMenuBar.EndCaps, true)
        Phoenix_UI:Skin(MainMenuBar.ActionBarPageNumber.UpButton, true)
        Phoenix_UI:Skin(MainMenuBar.ActionBarPageNumber.DownButton, true)
        MainMenuBar.ActionBarPageNumber.Text:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
        Phoenix_UI:Skin(StatusTrackingBarManager, true)
        Phoenix_UI:Skin(StatusTrackingBarManager.BottomBarFrameTexture, true)
        Phoenix_UI:Skin(StatusTrackingBarManager.MainStatusTrackingBarContainer, true)
        Phoenix_UI:Skin(StatusTrackingBarManager.SecondaryStatusTrackingBarContainer, true)
    end
end



