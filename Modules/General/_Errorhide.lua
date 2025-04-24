local Module = Phoenix_UI:NewModule("General.Errorhide");

function Module:OnEnable()
    -- Use the safe GetDB accessor which will never return nil
    local db = Phoenix_UI:GetDB("general.cosmetic.errors", false)
    
    -- Implement error handling based on db setting
    if db then
        UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
        UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    else
        UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
        UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
    end
end 