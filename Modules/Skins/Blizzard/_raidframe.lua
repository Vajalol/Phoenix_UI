local Module = Phoenix_UI:NewModule("Skins.RaidFrame");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(CompactRaidFrameManager, true)
    end
end



