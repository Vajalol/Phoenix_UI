local _, SpellNotifications = ...

local locStrings = {
    ["enUS"] = {
        ["PETDIED"] = "Your pet has died!",
    },
}

local locale = GetLocale()

-- Get a localized string, or fall back to enUS if not found
function SpellNotifications:GetLocalizedString(key)
    local locTable = locStrings[locale] or locStrings["enUS"]
    return locTable and locTable[key] or key
end 