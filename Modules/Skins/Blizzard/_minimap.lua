local Module = Phoenix_UI:NewModule("Skins.Minimap");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local compass = MinimapCompassTexture
        compass:SetDesaturated(true)
        compass:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
    end
end



