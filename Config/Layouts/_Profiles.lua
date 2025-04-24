local Layout = Phoenix_UI:NewModule('Config.Layout.Profiles')

function Layout:OnEnable()
    -- Components
    local Phoenix_UIConfig = LibStub('Phoenix_UIConfig')
    local db = Phoenix_UI.db
    
    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                createHeader = {
                    type = 'header',
                    label = 'Profiles'
                }
            },
            {
                create = {
                    type = 'textfield',
                    label = 'Name',
                    text = '',
                    column = 7,
                    order = 0
                },
                createHeader = {
                    type = 'header',
                    label = '',
                    column = 1,
                    order = 1
                },
                createSubmit = {
                    type = 'button',
                    text = 'Create',
                    onClick = function(self)
                        local field = Layout.create
                        local profileName = field:GetText()
                        if profileName and profileName ~= '' then
                            db:SetProfile(profileName)
                            field:SetText('')
                        end
                    end,
                    column = 4,
                    order = 2
                }
            },
            {
                profile = {
                    type = 'dropdown',
                    label = 'Profile',
                    value = function() return db:GetCurrentProfile() end,
                    options = function() return db:GetProfiles() end,
                    onClick = function(self, option, checked)
                        if option.value then
                            db:SetProfile(option.value)
                        end
                    end,
                    column = 7,
                    order = 0,
                },
                profileHeader = {
                    type = 'header',
                    label = '',
                    column = 1,
                    order = 1
                },
                reset = {
                    type = 'button',
                    text = 'Reset',
                    onClick = function()
                        local buttons = {
                            accept = {
                                text = 'Accept',
                                onClick = function() 
                                    db:ResetProfile()
                                    ReloadUI()
                                end
                            }
                        }
                        Phoenix_UIConfig:Confirm('Reset UI', 'This will reset all your Phoenix_UI settings!', buttons)
                    end,
                    column = 4,
                    order = 2
                }
            }
        }
    }
end



