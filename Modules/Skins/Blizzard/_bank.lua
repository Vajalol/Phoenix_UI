local Module = Phoenix_UI:NewModule("Skins.Bank");

function Module:OnEnable()
    if (Phoenix_UI:Color()) then
        Phoenix_UI:Skin(BankFrame, true)
        Phoenix_UI:Skin(BankFrame.NineSlice, true)
        Phoenix_UI:Skin(BankSlotsFrame.NineSlice, true)
        Phoenix_UI:Skin(BankFrameMoneyFrameBorder, true)
        Phoenix_UI:Skin(AccountBankPanel.NineSlice, true)
        Phoenix_UI:Skin(AccountBankPanel.MoneyFrame.Border, true)

        ReagentBankFrame:HookScript("OnShow", function()
            Phoenix_UI:Skin(ReagentBankFrame, true)
            Phoenix_UI:Skin(ReagentBankFrame.NineSlice, true)
        end)

        -- Tabs
        Phoenix_UI:Skin(BankFrameTab1, true)
        Phoenix_UI:Skin(BankFrameTab2, true)
        Phoenix_UI:Skin(BankFrameTab3, true)
    end
end



