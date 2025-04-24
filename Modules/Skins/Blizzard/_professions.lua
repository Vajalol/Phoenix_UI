local Module = Phoenix_UI:NewModule("Skins.Professions");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Professions" then
                Phoenix_UI:Skin(ProfessionsFrame, true)
                Phoenix_UI:Skin(ProfessionsFrame.NineSlice, true)
                Phoenix_UI:Skin(ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice, true)
                Phoenix_UI:Skin(ProfessionsFrame.CraftingPage.SchematicForm.NineSlice, true)
                Phoenix_UI:Skin(ProfessionsFrame.CraftingPage.SchematicForm.Details, true)
                Phoenix_UI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.OrderList.NineSlice, true)
                Phoenix_UI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.BackgroundNineSlice, true)

                -- Tabs
                Phoenix_UI:Skin(ProfessionsFrame.TabSystem.tabs[1], true)
                Phoenix_UI:Skin(ProfessionsFrame.TabSystem.tabs[2], true)
                Phoenix_UI:Skin(ProfessionsFrame.TabSystem.tabs[3], true)
                Phoenix_UI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton, true)
                Phoenix_UI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.GuildOrdersButton, true)
                Phoenix_UI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.NpcOrdersButton, true)
                Phoenix_UI:Skin(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton, true)
            end
        end)
    end
end



