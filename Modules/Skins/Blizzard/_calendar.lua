local Module = Phoenix_UI:NewModule("Skins.Calendar");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Calendar" then
                Phoenix_UI:Skin(CalendarFrame, true)
                Phoenix_UI:Skin(CalendarCreateEventFrame, true)
                Phoenix_UI:Skin(CalendarCreateEventFrame.Header, true)
                Phoenix_UI:Skin(CalendarCreateEventFrame.Border, true)
                Phoenix_UI:Skin(CalendarViewHolidayFrame, true)
                Phoenix_UI:Skin(CalendarViewHolidayFrame.Header, true)
                Phoenix_UI:Skin(CalendarViewHolidayFrame.Border, true)
                Phoenix_UI:Skin({
                    CalendarCreateEventDivider,
                    CalendarCreateEventFrameButtonBackground,
                    CalendarCreateEventMassInviteButtonBorder,
                    CalendarCreateEventCreateButtonBorder
                }, true, true)
            end
        end)
    end
end



