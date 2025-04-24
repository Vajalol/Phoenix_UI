local Module = Phoenix_UI:NewModule("Skins.Timer");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        TimerTracker:HookScript("OnEvent", function(self, event, timerType, timeSeconds, totalTime)
            for i = 1, #self.timerList do
                _G['TimerTrackerTimer' .. i .. 'StatusBarBorder']:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
            end
        end)
        for _, region in pairs({ StopwatchFrame:GetRegions() }) do
            region:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
        end
    end
end



