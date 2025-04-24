local Module = Phoenix_UI:NewModule("Skins.Bags");

function Module:OnEnable()

    function Phoenix_UICombinedBags()
        local container = ContainerFrameCombinedBags
        Phoenix_UIStyleBG(container)
        Phoenix_UIStyleNineSlice(container)
        container.MoneyFrame.Border.Left:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        container.MoneyFrame.Border.Middle:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        container.MoneyFrame.Border.Right:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))

        hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
            for button, _ in self.itemButtonPool:EnumerateActive() do
                button.NormalTexture:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
            end
        end)
    end

    function Phoenix_UIDefaultBags()
        for i = 1, 13 do
            local container = _G["ContainerFrame" .. i]

            Phoenix_UIStyleNineSlice(container)
            Phoenix_UIStyleBG(container)

            -- Bag Slots
            local bagSlots = _G["ContainerFrame" .. i]
            hooksecurefunc(bagSlots, "Update", function(self)
                for button, _ in self.itemButtonPool:EnumerateActive() do
                    button.NormalTexture:SetVertexColor(unpack(Phoenix_UI:Color(0.15)))
                end
            end)
            --print(bagSlots.NormalTexture)
        end

        ContainerFrame1MoneyFrame.Border.Left:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        ContainerFrame1MoneyFrame.Border.Middle:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        ContainerFrame1MoneyFrame.Border.Right:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))

        BackpackTokenFrame.Border.Left:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        BackpackTokenFrame.Border.Middle:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        BackpackTokenFrame.Border.Right:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
    end

    function Phoenix_UIStyleBG(container)
        container.Bg.TopSection:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        container.Bg.BottomEdge:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        container.Bg.BottomLeft:SetVertexColor(0, 0, 0, 0.78)
        container.Bg.BottomRight:SetVertexColor(0, 0, 0, 0.78)
    end

    function Phoenix_UIStyleNineSlice(container)
        local nineSlice = {
            "BottomEdge",
            "BottomLeftCorner",
            "BottomRightCorner",
            "Center",
            "LeftEdge",
            "RightEdge",
            "TopEdge",
            "TopLeftCorner",
            "TopRightCorner"
        }

        container.NineSlice:SetVertexColor(unpack(Phoenix_UI:Color(1)))

        for _, ns in pairs(nineSlice) do
            container.NineSlice[ns]:SetVertexColor(unpack(Phoenix_UI:Color(0.1)))
        end
    end

    if (Phoenix_UI:Color()) then
        Phoenix_UICombinedBags()
        Phoenix_UIDefaultBags()
    end
end



