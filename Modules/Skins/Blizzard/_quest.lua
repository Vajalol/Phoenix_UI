local Module = Phoenix_UI:NewModule("Skins.Quest");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(QuestFrame, true)
        Phoenix_UI:Skin(QuestFrame.NineSlice, true)
        Phoenix_UI:Skin(QuestFrameInset, true)
        Phoenix_UI:Skin(QuestFrameInset.NineSlice, true)
        Phoenix_UI:Skin(QuestLogPopupDetailFrame, true)
        Phoenix_UI:Skin(QuestLogPopupDetailFrame.NineSlice, true)
        Phoenix_UI:Skin(ObjectiveTrackerFrame, true)
        Phoenix_UI:Skin(ObjectiveTrackerFrame.Header, true)
        Phoenix_UI:Skin(CampaignQuestObjectiveTracker, true)
        Phoenix_UI:Skin(CampaignQuestObjectiveTracker.Header, true)
        Phoenix_UI:Skin(QuestObjectiveTracker, true)
        Phoenix_UI:Skin(QuestObjectiveTracker.Header, true)
        Phoenix_UI:Skin(ProfessionsRecipeTracker, true)
        Phoenix_UI:Skin(ProfessionsRecipeTracker.Header, true)
        Phoenix_UI:Skin(ScenarioObjectiveTracker, true)
        Phoenix_UI:Skin(ScenarioObjectiveTracker.Header, true)
        Phoenix_UI:Skin({
            QuestNPCModelTopBorder,
            QuestNPCModelRightBorder,
            QuestNPCModelTopRightCorner,
            QuestNPCModelBottomRightCorner,
            QuestNPCModelBottomBorder,
            QuestNPCModelBottomLeftCorner,
            QuestNPCModelLeftBorder,
            QuestNPCModelTopLeftCorner,
            QuestNPCModelTextTopBorder,
            QuestNPCModelTextRightBorder,
            QuestNPCModelTextTopRightCorner,
            QuestNPCModelTextBottomRightCorner,
            QuestNPCModelTextBottomBorder,
            QuestNPCModelTextBottomLeftCorner,
            QuestNPCModelTextLeftBorder,
            QuestNPCModelTextTopLeftCorner
        }, true, true)
    end
end



