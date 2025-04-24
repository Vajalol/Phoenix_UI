local Module = Phoenix_UI:NewModule("Skins.ClassTrainer");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_TrainerUI" then
                Phoenix_UI:Skin(ClassTrainerFrame, true)
                Phoenix_UI:Skin(ClassTrainerFrame.NineSlice, true)
                Phoenix_UI:Skin(ClassTrainerFrameBottomInset.NineSlice, true)
                Phoenix_UI:Skin(ClassTrainerFrameInset.NineSlice, true)
            end
        end)
    end
end



