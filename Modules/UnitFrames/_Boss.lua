-- Boss frames module - completely disabled to prevent errors
local Module = Phoenix_UI:NewModule("UnitFrames.Boss");

function Module:OnEnable()
    local db = Phoenix_UI.db.profile.general
    
    -- Function to safely apply textures and colors to boss frames
    local function ApplyBossFrameStyling(frame, event)
        if not frame or not frame.healthbar then return end
        
        -- Apply texture safely
        if db.texture and frame.healthbar.SetStatusBarTexture then
            pcall(function() 
                frame.healthbar:SetStatusBarTexture(db.texture)
            end)
        end
        
        -- Apply color safely
        if db.color and frame.healthbar.SetStatusBarColor then
            local r = db.color.r or 0
            local g = db.color.g or 0
            local b = db.color.b or 0
            
            pcall(function()
                frame.healthbar:SetStatusBarColor(r, g, b)
            end)
        end
        
        -- Apply frame texture color if frame supports it
        if frame.TargetFrameContainer and frame.TargetFrameContainer.FrameTexture then
            pcall(function()
                frame.TargetFrameContainer.FrameTexture:SetVertexColor(Phoenix_UI:Color(0.15))
            end)
        end
    end
    
    -- Register for OnEvent on each Boss frame
    for i = 1, 5 do
        local frame = _G["Boss"..i.."TargetFrame"]
        if frame then
            frame:HookScript("OnEvent", function(self, event)
                ApplyBossFrameStyling(self, event)
            end)
            
            -- Apply immediately
            ApplyBossFrameStyling(frame)
        end
    end
    
    -- Register for boss frame update event
    local updateFrame = CreateFrame("Frame")
    updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    updateFrame:RegisterEvent("ADDON_LOADED")
    updateFrame:RegisterEvent("ENCOUNTER_START")
    updateFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    updateFrame:SetScript("OnEvent", function()
        for i = 1, 5 do
            local frame = _G["Boss"..i.."TargetFrame"]
            ApplyBossFrameStyling(frame)
        end
    end)
end 