local Module = Phoenix_UI:NewModule("Skins.Character");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(CharacterFrame, true)
        Phoenix_UI:Skin(CharacterFrame.NineSlice, true)
        Phoenix_UI:Skin(CharacterFrameInset, true)
        Phoenix_UI:Skin(CharacterFrameInset.NineSlice, true)
        Phoenix_UI:Skin(CharacterFrameInsetRight, true)
        Phoenix_UI:Skin(CharacterFrameInsetRight.NineSlice, true)
        Phoenix_UI:Skin(TokenFramePopup, true)
        Phoenix_UI:Skin(TokenFramePopup.Border, true)
        Phoenix_UI:Skin(CharacterStatsPane, true)
        Phoenix_UI:Skin(ReputationFrame.ReputationDetailFrame, true)
        Phoenix_UI:Skin(ReputationFrame.ReputationDetailFrame.Border, true)
        Phoenix_UI:Skin(CurrencyTransferLog, true)
        Phoenix_UI:Skin(CurrencyTransferLog.TitleContainer, true)
        Phoenix_UI:Skin(CurrencyTransferLog.NineSlice, true)
        Phoenix_UI:Skin(CurrencyTransferLogInset.NineSlice, true)
        Phoenix_UI:Skin({
            CharacterFeetSlotFrame,
            CharacterHandsSlotFrame,
            CharacterWaistSlotFrame,
            CharacterLegsSlotFrame,
            CharacterFinger0SlotFrame,
            CharacterFinger1SlotFrame,
            CharacterTrinket0SlotFrame,
            CharacterTrinket1SlotFrame,
            CharacterWristSlotFrame,
            CharacterTabardSlotFrame,
            CharacterShirtSlotFrame,
            CharacterChestSlotFrame,
            CharacterBackSlotFrame,
            CharacterShoulderSlotFrame,
            CharacterNeckSlotFrame,
            CharacterHeadSlotFrame,
            CharacterMainHandSlotFrame,
            CharacterSecondaryHandSlotFrame,
            _G.select(CharacterMainHandSlot:GetNumRegions(), CharacterMainHandSlot:GetRegions()),
            _G.select(CharacterSecondaryHandSlot:GetNumRegions(), CharacterSecondaryHandSlot:GetRegions()),
            PaperDollInnerBorderLeft,
            PaperDollInnerBorderRight,
            PaperDollInnerBorderTop,
            PaperDollInnerBorderTopLeft,
            PaperDollInnerBorderTopRight,
            PaperDollInnerBorderBottom,
            PaperDollInnerBorderBottomLeft,
            PaperDollInnerBorderBottomRight,
            PaperDollInnerBorderBottom2
        }, true, true)

        -- Tabs
        Phoenix_UI:Skin(CharacterFrameTab1, true)
        Phoenix_UI:Skin(CharacterFrameTab2, true)
        Phoenix_UI:Skin(CharacterFrameTab3, true)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_ItemSocketingUI" then
                Phoenix_UI:Skin(ItemSocketingFrame, true)
                Phoenix_UI:Skin(ItemSocketingFrame.NineSlice, true)
            end
        end)
    end
end



