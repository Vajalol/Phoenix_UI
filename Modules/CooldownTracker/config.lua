-- Build the options interface
function CT:BuildOptions()
    -- ... existing code ...
    
    options.args.timeline = {
        type = "group",
        name = L["Raid Timeline"],
        desc = L["Configure the raid cooldown timeline"],
        order = 50,
        args = {
            enabled = {
                type = "toggle",
                name = L["Enable Timeline"],
                desc = L["Show a timeline of raid cooldowns"],
                order = 1,
                width = "full",
                get = function() return self.db.profile.timeline.enabled end,
                set = function(_, val) 
                    self.db.profile.timeline.enabled = val 
                    if self:GetModule("RaidTimeline") then
                        if val then
                            self:GetModule("RaidTimeline"):Enable()
                        else
                            self:GetModule("RaidTimeline"):Disable()
                        end
                    end
                    self:FireCallback("ConfigChanged")
                end,
            },
            general = {
                type = "group",
                name = L["General Settings"],
                inline = true,
                order = 2,
                args = {
                    scale = {
                        type = "range",
                        name = L["Scale"],
                        desc = L["Adjust the size of the timeline"],
                        min = 0.5, max = 2, step = 0.05,
                        order = 1,
                        get = function() return self.db.profile.timeline.scale end,
                        set = function(_, val) 
                            self.db.profile.timeline.scale = val 
                            if self:GetModule("RaidTimeline") then
                                self:GetModule("RaidTimeline"):UpdateFrameSize()
                            end
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                    width = {
                        type = "range",
                        name = L["Width"],
                        desc = L["Adjust the width of the timeline"],
                        min = 200, max = 800, step = 10,
                        order = 2,
                        get = function() return self.db.profile.timeline.width end,
                        set = function(_, val) 
                            self.db.profile.timeline.width = val 
                            if self:GetModule("RaidTimeline") then
                                self:GetModule("RaidTimeline"):UpdateFrameSize()
                            end
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                    height = {
                        type = "range",
                        name = L["Height"],
                        desc = L["Adjust the height of the timeline"],
                        min = 100, max = 400, step = 10,
                        order = 3,
                        get = function() return self.db.profile.timeline.height end,
                        set = function(_, val) 
                            self.db.profile.timeline.height = val 
                            if self:GetModule("RaidTimeline") then
                                self:GetModule("RaidTimeline"):UpdateFrameSize()
                            end
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                    showLegend = {
                        type = "toggle",
                        name = L["Show Legend"],
                        desc = L["Display a legend for cooldown types"],
                        order = 4,
                        get = function() return self.db.profile.timeline.showLegend end,
                        set = function(_, val) 
                            self.db.profile.timeline.showLegend = val 
                            if self:GetModule("RaidTimeline") then
                                self:GetModule("RaidTimeline"):UpdateDisplay()
                            end
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                },
            },
            display = {
                type = "group",
                name = L["Display Settings"],
                inline = true,
                order = 3,
                args = {
                    showOffensive = {
                        type = "toggle",
                        name = L["Show Offensive Cooldowns"],
                        desc = L["Display offensive cooldowns on the timeline"],
                        order = 1,
                        get = function() return self.db.profile.timeline.showOffensive end,
                        set = function(_, val) 
                            self.db.profile.timeline.showOffensive = val 
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                    showDefensive = {
                        type = "toggle",
                        name = L["Show Defensive Cooldowns"],
                        desc = L["Display defensive cooldowns on the timeline"],
                        order = 2,
                        get = function() return self.db.profile.timeline.showDefensive end,
                        set = function(_, val) 
                            self.db.profile.timeline.showDefensive = val 
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                    showUtility = {
                        type = "toggle",
                        name = L["Show Utility Cooldowns"],
                        desc = L["Display utility cooldowns on the timeline"],
                        order = 3,
                        get = function() return self.db.profile.timeline.showUtility end,
                        set = function(_, val) 
                            self.db.profile.timeline.showUtility = val 
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                    timelineLength = {
                        type = "range",
                        name = L["Timeline Duration"],
                        desc = L["Length of time to display on the timeline (seconds)"],
                        min = 30, max = 300, step = 30,
                        order = 4,
                        get = function() return self.db.profile.timeline.timelineLength end,
                        set = function(_, val) 
                            self.db.profile.timeline.timelineLength = val 
                            self:FireCallback("ConfigChanged")
                        end,
                    },
                },
            },
        },
    }
    
    -- ... existing code ...
    
    return options
end 

function CT:InitializeDefaultSettings()
    -- ... existing code ...
    
    -- Add timeline defaults
    local defaults = {
        -- ... existing code ...
        
        timeline = {
            enabled = false,
            scale = 1,
            width = 400,
            height = 200,
            showLegend = true,
            showOffensive = true,
            showDefensive = true,
            showUtility = true,
            timelineLength = 120,
            position = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOffset = 0,
                yOffset = 0,
            },
        },
        
        -- ... existing code ...
    }
    
    -- ... existing code ...
end 