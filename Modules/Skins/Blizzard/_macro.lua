local Module = Phoenix_UI:NewModule("Skins.Macro");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_MacroUI" then
                Phoenix_UI:Skin(MacroFrame, true)
                Phoenix_UI:Skin(MacroFrame.NineSlice, true)
                Phoenix_UI:Skin(MacroFrameInset, true)
                Phoenix_UI:Skin(MacroFrameInset.NineSlice, true)
                Phoenix_UI:Skin(MacroFrameTextBackground, true)
                Phoenix_UI:Skin(MacroFrameTextBackground.NineSlice, true)
                Phoenix_UI:Skin({
                    MacroButtonScrollFrameTop,
                    MacroButtonScrollFrameMiddle,
                    MacroButtonScrollFrameBottom,
                    MacroButtonScrollFrameScrollBarThumbTexture
                }, true, true)

                -- Tabs
                Phoenix_UI:Skin(MacroFrameTab1, true)
                Phoenix_UI:Skin(MacroFrameTab2, true)
            end
        end)
    end
end



