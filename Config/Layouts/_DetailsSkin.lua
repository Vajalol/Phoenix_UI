local Layout = Phoenix_UI:NewModule('Config.Layout.DetailsSkin')

function Layout:OnEnable()
    -- Database
    local db = Phoenix_UI.db

    -- Ensure defaults exist
    if not db.profile.addons then
        db.profile.addons = {}
    end
    if not db.profile.addons.details then
        db.profile.addons.details = {
            enableSkin = true,
            autoApply = false
        }
    end

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.addons.details,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Details! Skin - The War Within'
                }
            },
            {
                enableSkin = {
                    key = 'enableSkin',
                    type = 'checkbox',
                    label = 'Enable Skin',
                    tooltip = 'Enable The War Within skin for Details!',
                    column = 4,
                    order = 1
                },
                autoApply = {
                    key = 'autoApply',
                    type = 'checkbox',
                    label = 'Auto Apply',
                    tooltip = 'Automatically apply the skin when Details! is loaded',
                    column = 4,
                    order = 2
                },
                applyButton = {
                    type = 'button',
                    label = 'Apply Skin Now',
                    tooltip = 'Apply The War Within skin to Details! right now',
                    width = 200,
                    column = 8,
                    order = 3,
                    click = function()
                        -- Check if DetailsSkin module exists
                        if Phoenix_UI.DetailsSkin then
                            -- Call ApplySkin function on the module
                            if Phoenix_UI.DetailsSkin.ApplySkin then
                                Phoenix_UI.DetailsSkin:ApplySkin()
                                -- Show confirmation message
                                Phoenix_UI:Print("The War Within skin has been applied to Details!")
                            else
                                Phoenix_UI:Print("Could not find ApplySkin function!")
                            end
                        else
                            Phoenix_UI:Print("DetailsSkin module not found!")
                        end
                    end
                }
            },
            {
                importButton = {
                    type = 'button',
                    label = 'Import Profile',
                    tooltip = 'Import The War Within profile into Details! (use this if the skin doesn\'t apply correctly)',
                    width = 200,
                    column = 4,
                    order = 1,
                    click = function()
                        -- Check if DetailsSkin module exists
                        if Phoenix_UI.DetailsSkin then
                            -- Call ImportProfile function on the module
                            if Phoenix_UI.DetailsSkin.ImportProfile then
                                Phoenix_UI.DetailsSkin:ImportProfile()
                                -- Show confirmation message
                                Phoenix_UI:Print("The War Within profile has been imported to Details!")
                            else
                                Phoenix_UI:Print("Could not find ImportProfile function!")
                            end
                        else
                            Phoenix_UI:Print("DetailsSkin module not found!")
                        end
                    end
                },
                resetButton = {
                    type = 'button',
                    label = 'Reset Details',
                    tooltip = 'Reset Details! to default settings',
                    width = 200,
                    column = 4,
                    order = 2,
                    click = function()
                        -- Check if DetailsSkin module exists
                        if Phoenix_UI.DetailsSkin then
                            -- Call ResetDetails function on the module
                            if Phoenix_UI.DetailsSkin.ResetDetails then
                                Phoenix_UI.DetailsSkin:ResetDetails()
                                -- Show confirmation message
                                Phoenix_UI:Print("Details! has been reset to default settings")
                            else
                                Phoenix_UI:Print("Could not find ResetDetails function!")
                            end
                        else
                            Phoenix_UI:Print("DetailsSkin module not found!")
                        end
                    end
                }
            }
        },
    }
end 