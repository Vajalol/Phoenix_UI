local Module = Phoenix_UI:NewModule("Skins.ActionHouse");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            -- Crafting Orders
            if name == "Blizzard_ProfessionsCustomerOrders" then
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrame, true)
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrame.NineSlice, true)
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.NineSlice, true)
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrame.MoneyFrameBorder, true)
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrame.MoneyFrameInset.NineSlice, true)

                -- Tabs
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrameBrowseTab, true)
                Phoenix_UI:Skin(ProfessionsCustomerOrdersFrameOrdersTab, true)
            end

            -- Auction House
            if name == "Blizzard_AuctionHouseUI" then
                Phoenix_UI:Skin(AuctionHouseFrame, true)
                Phoenix_UI:Skin(AuctionHouseFrame.NineSlice, true)
                Phoenix_UI:Skin(AuctionHouseFrame.NineSlice, true)
                Phoenix_UI:Skin(AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.NineSlice, true)
                Phoenix_UI:Skin(AuctionHouseFrame.BuyDialog, true)
                Phoenix_UI:Skin(AuctionHouseFrame.BuyDialog.Border, true)
                Phoenix_UI:Skin(AuctionHouseFrame.MoneyFrameBorder, true)
                Phoenix_UI:Skin(AuctionHouseFrame.MoneyFrameInset.NineSlice, true)
                Phoenix_UI:Skin(AuctionHouseFrame.CategoriesList, true)

                -- Tabs
                Phoenix_UI:Skin(AuctionHouseFrameBuyTab, true)
                Phoenix_UI:Skin(AuctionHouseFrameSellTab, true)
                Phoenix_UI:Skin(AuctionHouseFrameAuctionsTab, true)
                Phoenix_UI:Skin(AuctionHouseFrameAuctionsFrameAuctionsTab, true)
                Phoenix_UI:Skin(AuctionHouseFrameAuctionsFrameBidsTab, true)
            end
        end)
    end
end



