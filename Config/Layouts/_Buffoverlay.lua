local Layout = Phoenix_UI:NewModule('Config.Layout.Buffoverlay')

function Layout:OnEnable()
    -- Helper function to access BuffOverlay
    local function GetBuffOverlay()
        return LibStub("AceAddon-3.0"):GetAddon("BuffOverlay", true)
    end

    -- Helper function to check if BuffOverlay is available
    local function IsBuffOverlayLoaded()
        return GetBuffOverlay() ~= nil
    end

    -- Simplified layout with just a single button
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Buff / Debuff / BuffOverlay'
                }
            },
            {
                openButton = {
                    type = 'button',
                    text = 'Open Buff / Debuff / BuffOverlay Panel',
                    column = 12,
                    order = 1,
                    onClick = function()
                        local BuffOverlay = GetBuffOverlay()
                        if BuffOverlay and BuffOverlay.OpenOptions then
                            BuffOverlay:OpenOptions()
                        else
                            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: BuffOverlay addon is not loaded or not available")
                        end
                    end
                }
            }
        }
    }
end 



