-- Make this module redirect to the main DetailSkin module
local Layout = Phoenix_UI:NewModule('Config.Layout.DetailsSkin')

function Layout:OnEnable()
    -- Redirect to the main DetailSkin module
    local MainModule = Phoenix_UI:GetModule('Config.Layout.DetailSkin', true)
    if not MainModule then
        if Phoenix_UI.debug then
            print("Phoenix UI: |cffff9900DetailSkin config module not found, creating redirection.|r")
        end
        
        -- Register ourselves to the layouts table
        if not Phoenix_UI.layouts then
            Phoenix_UI.layouts = {}
        end
        
        Phoenix_UI.layouts.DetailsSkin = {
            key = 'DetailSkin', -- redirect to the correct key
            parentKey = nil,
            text = 'Detail Skin',
            layoutOrder = 13,
            -- Basic placeholder layout that redirects to the main module
            rows = {
                {
                    header = {
                        type = 'header',
                        label = 'Detail Skin',
                        template = 'PhoenixHeaderTmpl',
                        column = 12,
                        order = 1
                    }
                },
                {
                    redirect = {
                        type = 'text',
                        label = 'Please use the DetailSkin tab for configuration.',
                        fontSize = 'medium',
                        fontStyle = 'normal',
                        column = 12,
                        order = 1
                    }
                }
            }
        }
    end
end 