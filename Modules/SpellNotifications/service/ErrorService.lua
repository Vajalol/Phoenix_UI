local _, SpellNotifications = ...

local errorFrame = CreateFrame("Frame")
errorFrame:SetScript("OnEvent", function(self, event, msg)
    if not msg then return end
    
    -- Check if SpellNotifications is enabled
    if not Phoenix_UI or not Phoenix_UI.db or not Phoenix_UI.db.profile or not Phoenix_UI.db.profile.general or not Phoenix_UI.db.profile.general.spellNotifications then
        return
    end
    
    -- Immune
    if msg == ERR_SPELL_IMMUNE_S or msg == ERR_SPELL_DAMAGE_RESULT_IMMUNE then
        SpellNotifications:print("|cFFFF2020IMMUNE|r")
    -- Miss
    elseif msg == ERR_SPELL_MISSED_S then
        SpellNotifications:print("|cFFFF2020MISS|r")
    -- Evade
    elseif msg == ERR_SPELL_EVADED then
        SpellNotifications:print("|cFFFF2020EVADE|r")
    -- Dodge
    elseif msg == ERR_SPELL_DODGED_S then
        SpellNotifications:print("|cFFFF2020DODGE|r")
    -- Parry
    elseif msg == ERR_SPELL_PARRIED_S then
        SpellNotifications:print("|cFFFF2020PARRY|r")
    -- Block
    elseif msg == ERR_SPELL_BLOCKED_S then
        SpellNotifications:print("|cFFFF2020BLOCK|r")
    -- Resist
    elseif msg == ERR_SPELL_RESIST_S then
        SpellNotifications:print("|cFFFF2020RESIST|r")
    -- Reflect
    elseif msg == ERR_SPELL_REFLECT_S then
        SpellNotifications:print("|cFFFF2020REFLECT|r")
    -- Target is not in line of sight
    elseif msg == ERR_SPELL_FAILED_LINE_OF_SIGHT then
        SpellNotifications:print("|cFFFF2020NOT IN LOS|r")
    end
end)

function SpellNotifications:RegisterErrorEvents()
    errorFrame:RegisterEvent("UI_ERROR_MESSAGE")
end

 