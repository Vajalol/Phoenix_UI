local Module = Phoenix_UI:NewModule("Skins.AddonList");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(AddonList.NineSlice, true)
        Phoenix_UI:Skin(AddonList, true)
        Phoenix_UI:Skin({ AddonListBg }, true, true)
    end
end



