local Skin = Phoenix_UI:NewModule("Skins.ClassicUI");

function Skin:OnEnable()
    local ClassicUI = C_AddOns.IsAddOnLoaded("ClassicUI")
    if not (ClassicUI) then return end
    if (Phoenix_UI:Color()) then
        for i, v in pairs({
            MainMenuBarArtFrameBackground.BackgroundLarge2,
            MainMenuBarArtFrameBackground.BagsArt,
            MainMenuBarArtFrameBackground.MicroButtonArt,
        }) do
            v:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
        end
    end
end



