local Module = Phoenix_UI:NewModule("Skins.Petition");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(PetitionFrame, true)
        Phoenix_UI:Skin(PetitionFrame.NineSlice, true)
        Phoenix_UI:Skin(PetitionFrameInset, true)
    end
end



