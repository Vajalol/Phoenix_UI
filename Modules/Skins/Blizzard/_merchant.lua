local Module = Phoenix_UI:NewModule("Skins.Merchant");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(MerchantFrame, true)
        Phoenix_UI:Skin(MerchantFrame.NineSlice, true)
        Phoenix_UI:Skin(MerchantFrameInset, true)
        Phoenix_UI:Skin(MerchantFrameInset.NineSlice, true)
        Phoenix_UI:Skin(StackSplitFrame, true)
        Phoenix_UI:Skin(MerchantMoneyBg, true)
        Phoenix_UI:Skin(MerchantMoneyInset, true)
        Phoenix_UI:Skin(MerchantMoneyInset.NineSlice, true)
        Phoenix_UI:Skin({
            MerchantBuyBackItemSlotTexture,
        }, true, true)

        -- Merchant Buttons
        select(1, select(1, MerchantRepairItemButton:GetRegions())):SetVertexColor(.15, .15, .15)
        select(1, select(1, MerchantRepairAllButton:GetRegions())):SetVertexColor(.15, .15, .15)
        select(1, select(1, MerchantGuildBankRepairButton:GetRegions())):SetVertexColor(.15, .15, .15)
        select(1, select(1, MerchantSellAllJunkButton:GetRegions())):SetVertexColor(.15, .15, .15)

        -- Tabs
        Phoenix_UI:Skin(MerchantFrameTab1, true)
        Phoenix_UI:Skin(MerchantFrameTab2, true)
    end
end



