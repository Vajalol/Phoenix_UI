local Module = Phoenix_UI:NewModule("Skins.LFG");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(PVEFrame, true)
        Phoenix_UI:Skin(PVEFrame.shadows, true)
        Phoenix_UI:Skin(PVEFrame.NineSlice, true)
        Phoenix_UI:Skin(LFGListFrame.SearchPanel.ResultsInset, true)
        Phoenix_UI:Skin(LFGListFrame.SearchPanel.ResultsInset.NineSlice, true)
        Phoenix_UI:Skin(PVEFrameLeftInset, true)
        Phoenix_UI:Skin(PVEFrameLeftInset.NineSlice, true)
        Phoenix_UI:Skin(LFDParentFrameInset, true)
        Phoenix_UI:Skin(LFDParentFrameInset.NineSlice, true)
        Phoenix_UI:Skin(RaidFinderFrameRoleInset, true)
        Phoenix_UI:Skin(RaidFinderFrameRoleInset.NineSlice, true)
        Phoenix_UI:Skin(RaidFinderFrameBottomInset, true)
        Phoenix_UI:Skin(RaidFinderFrameBottomInset.NineSlice, true)
        Phoenix_UI:Skin(LFGListFrame, true)
        Phoenix_UI:Skin(LFGListFrame.CategorySelection, true)
        Phoenix_UI:Skin(LFGListFrame.CategorySelection.Inset, true)
        Phoenix_UI:Skin(LFGListFrame.CategorySelection.Inset.NineSlice, true)
        Phoenix_UI:Skin(LFGListFrame.ApplicationViewer, true)
        Phoenix_UI:Skin(LFGListFrame.ApplicationViewer.Inset, true)
        Phoenix_UI:Skin(LFGListFrame.ApplicationViewer.Inset.NineSlice, true)
        Phoenix_UI:Skin(LFGListFrame.EntryCreation, true)
        Phoenix_UI:Skin(LFGListFrame.EntryCreation.Inset, true)
        Phoenix_UI:Skin(LFGListFrame.EntryCreation.Inset.NineSlice, true)
        Phoenix_UI:Skin(LFGListFrame.ApplicationViewer.NameColumnHeader, true)
        Phoenix_UI:Skin(LFGListFrame.ApplicationViewer.RoleColumnHeader, true)
        Phoenix_UI:Skin(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, true)
        Phoenix_UI:Skin(LFGApplicationViewerRatingColumnHeader, true)
        Phoenix_UI:Skin(LFDRoleCheckPopup, true)
        Phoenix_UI:Skin(LFDRoleCheckPopup.Border, true)
        Phoenix_UI:Skin(PVPReadyDialog, true)
        Phoenix_UI:Skin(PVPReadyDialog.Border, true)

        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_PVPUI" then
                Phoenix_UI:Skin(PlunderstormFrame.Inset, true)
                Phoenix_UI:Skin(PlunderstormFrame.Inset.NineSlice, true)
            end
        end)

        Phoenix_UI:Skin({
            LFDQueueFrameBackground,
            LFDParentFrameRoleBackground,
            PVEFrameTopFiligree,
            PVEFrameBottomFiligree,
            PVEFrameBlueBg,
        }, true, true)

        -- Tabs
        Phoenix_UI:Skin(PVEFrameTab1, true)
        Phoenix_UI:Skin(PVEFrameTab2, true)
        Phoenix_UI:Skin(PVEFrameTab3, true)
        Phoenix_UI:Skin(PVEFrameTab4, true)
    end
end



