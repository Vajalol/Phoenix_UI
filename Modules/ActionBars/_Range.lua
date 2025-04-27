local Range = Phoenix_UI:NewModule("ActionBars.Range");

function Range:OnEnable()
    local db = Phoenix_UI.db.profile.actionbar

    if (db.buttons.range) then
        local Module = CreateFrame('Frame')
        local _G = _G
        local next = _G.next
        local pairs = _G.pairs
        local unpack = _G.unpack

        local HasAction = _G.HasAction
        local IsActionInRange = _G.IsActionInRange
        local IsUsableAction = _G.IsUsableAction

        local UPDATE_DELAY = .2
        local buttonColors, buttonsToUpdate = {}, {}
        local problemButtons = {}
        local updater = CreateFrame("Frame")

        local colors = {
            ["normal"] = { 1, 1, 1 },
            ["oor"] = { .8, .1, .1 },
            ["oom"] = { .5, .5, 1 },
            ["unusable"] = { .3, .3, .3 }
        }

        function Module:OnUpdateRange(elapsed)
            self.elapsed = (self.elapsed or UPDATE_DELAY) - elapsed
            if self.elapsed <= 0 then
                self.elapsed = UPDATE_DELAY

                if not Module:UpdateButtons() then
                    self:Hide()
                end
            end
        end

        updater:SetScript("OnUpdate", Module.OnUpdateRange)

        function Module:UpdateButtons()
            if next(buttonsToUpdate) then
                for button in pairs(buttonsToUpdate) do
                    self.UpdateButtonUsable(button)
                end
                return true
            end

            return false
        end

        function Module:UpdateButtonStatus()
            local action = self.action

            if action and self:IsVisible() and HasAction(action) and not problemButtons[self] then
                buttonsToUpdate[self] = true
            else
                buttonsToUpdate[self] = nil
            end

            if next(buttonsToUpdate) then
                updater:Show()
            end
        end

        function Module:UpdateButtonUsable(force)
            if force then
                buttonColors[self] = nil
            end

            local action = self.action
            local isUsable, notEnoughMana = IsUsableAction(action)

            if isUsable then
                local inRange = IsActionInRange(action)
                if inRange == false then
                    Module.SetButtonColor(self, "oor")
                else
                    Module.SetButtonColor(self, "normal")
                end
            elseif notEnoughMana then
                Module.SetButtonColor(self, "oom")
            else
                Module.SetButtonColor(self, "unusable")
            end
        end

        function Module:SetButtonColor(colorIndex)
            if buttonColors[self] == colorIndex then
                return
            end
            buttonColors[self] = colorIndex

            local r, g, b = unpack(colors[colorIndex])
            self.icon:SetVertexColor(r, g, b)
        end

        function Module:Register()
            self:HookScript("OnShow", Module.UpdateButtonStatus)
            self:HookScript("OnHide", Module.UpdateButtonStatus)
            self:SetScript("OnUpdate", nil)
            Module.UpdateButtonStatus(self)
        end

        local function button_UpdateUsable(button)
            if problemButtons[button] then return end
            
            button.phoenixUpdateUsableCount = (button.phoenixUpdateUsableCount or 0) + 1
            
            if button.phoenixUpdateUsableCount > 5 then
                problemButtons[button] = true
                button.phoenixUpdateUsableCount = 0
                if button.icon then
                    button.icon:SetVertexColor(1, 1, 1)
                end
                return
            end
            
            Module.UpdateButtonUsable(button, true)
            
            button.phoenixUpdateUsableCount = button.phoenixUpdateUsableCount - 1
        end

        function Module:RegisterButtonRange(button)
            if button.Update then
                Module.Register(button)
                hooksecurefunc(button, "Update", Module.UpdateButtonStatus)
                hooksecurefunc(button, "UpdateUsable", button_UpdateUsable)
            end
        end

        for i = 1, NUM_ACTIONBAR_BUTTONS do
            Module:RegisterButtonRange(_G["ActionButton" .. i])
            Module:RegisterButtonRange(_G["MultiBarBottomLeftButton" .. i])
            Module:RegisterButtonRange(_G["MultiBarBottomRightButton" .. i])
            Module:RegisterButtonRange(_G["MultiBarRightButton" .. i])
            Module:RegisterButtonRange(_G["MultiBarLeftButton" .. i])
            Module:RegisterButtonRange(_G["MultiBar5Button" .. i])
            Module:RegisterButtonRange(_G["MultiBar6Button" .. i])
            Module:RegisterButtonRange(_G["MultiBar7Button" .. i])
        end
    end

end
