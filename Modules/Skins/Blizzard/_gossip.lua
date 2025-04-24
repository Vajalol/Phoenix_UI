local Module = Phoenix_UI:NewModule("Skins.Gossip");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(GossipFrame, true)
        Phoenix_UI:Skin(GossipFrame.NineSlice, true)
        Phoenix_UI:Skin(GossipFrameInset, true)
        Phoenix_UI:Skin(GossipFrameInset.NineSlice, true)
    end
end



