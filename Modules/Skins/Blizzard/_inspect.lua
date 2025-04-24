local Module = Phoenix_UI:NewModule("Skins.Inspect");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_InspectUI" then
                Phoenix_UI:Skin(InspectFrame, true)
                Phoenix_UI:Skin(InspectFrame.NineSlice, true)
                Phoenix_UI:Skin(InspectFrameInset, true)
                Phoenix_UI:Skin(InspectFrameInset.NineSlice, true)
                Phoenix_UI:Skin(InspectPaperDollItemsFrame, true)
                Phoenix_UI:Skin(InspectPaperDollItemsFrame.InspectTalents, true)
                Phoenix_UI:Skin(InspectPVPFrame, true)
                Phoenix_UI:Skin({
                    InspectModelFrameBorderLeft,
                    InspectModelFrameBorderRight,
                    InspectModelFrameBorderTop,
                    InspectModelFrameBorderTopLeft,
                    InspectModelFrameBorderTopRight,
                    InspectModelFrameBorderBottom,
                    InspectModelFrameBorderBottomLeft,
                    InspectModelFrameBorderBottomRight,
                    InspectModelFrameBorderBottom2,
                    InspectFeetSlotFrame,
                    InspectHandsSlotFrame,
                    InspectWaistSlotFrame,
                    InspectLegsSlotFrame,
                    InspectFinger0SlotFrame,
                    InspectFinger1SlotFrame,
                    InspectTrinket0SlotFrame,
                    InspectTrinket1SlotFrame,
                    InspectWristSlotFrame,
                    InspectTabardSlotFrame,
                    InspectShirtSlotFrame,
                    InspectChestSlotFrame,
                    InspectBackSlotFrame,
                    InspectShoulderSlotFrame,
                    InspectNeckSlotFrame,
                    InspectHeadSlotFrame,
                    InspectSecondaryHandSlotFrame,
                }, true, true)

                -- Tabs
                Phoenix_UI:Skin(InspectFrameTab1, true)
                Phoenix_UI:Skin(InspectFrameTab2, true)
                Phoenix_UI:Skin(InspectFrameTab3, true)

                -- Hide
                InspectMainHandSlotFrame:Hide()
                _G.select(InspectMainHandSlot:GetNumRegions(), InspectMainHandSlot:GetRegions()):Hide()
                _G.select(InspectSecondaryHandSlot:GetNumRegions(), InspectSecondaryHandSlot:GetRegions()):Hide()
            end

            if name == "Blizzard_Professions" then
                Phoenix_UI:Skin(InspectRecipeFrame, true)
                Phoenix_UI:Skin(InspectRecipeFrame.NineSlice, true)
            end
        end)
    end
end



