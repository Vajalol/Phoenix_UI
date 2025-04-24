-- Phoenix_UI Skin Fixer Module
-- This module applies fixes to ensure all skin modules work correctly

local Module = Phoenix_UI:NewModule("Skins.SkinFix", "AceEvent-3.0", "AceHook-3.0")

function Module:OnInitialize()
    -- Register for ADDON_LOADED to catch all skin modules
    self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
    
    -- Apply patches immediately for modules that might already be loaded
    self:ApplyPatches()
end

function Module:OnAddonLoaded(event, addonName)
    if addonName:match("Phoenix_UI") then
        -- Apply patches when any Phoenix_UI addon or module loads
        self:ApplyPatches()
    end
end

local patchedModules = {}

function Module:ApplyPatches()
    -- Apply Core fixes first
    self:EnsureCoreSkinnersExist()
    
    -- Find and patch all skin modules
    for moduleName, module in Phoenix_UI:IterateModules() do
        if moduleName:match("^Skins%.") and not patchedModules[moduleName] then
            self:PatchSkinModule(moduleName, module)
            patchedModules[moduleName] = true
        end
    end
end

function Module:EnsureCoreSkinnersExist()
    -- Ensure the core Skin function exists
    if not Phoenix_UI.Skin then
        function Phoenix_UI:Skin(frame, noBackdrop)
            if not frame then return nil end
            
            -- Simple fallback implementation
            local r, g, b, a = 0.15, 0.15, 0.15, 1.0 -- Default fallback colors
            
            pcall(function()
                -- Apply vertex color if possible
                if frame.SetVertexColor and not noBackdrop then
                    frame:SetVertexColor(r, g, b, a)
                end
                
                -- Apply backdrop if it has one and noBackdrop is not true
                if not noBackdrop and frame.SetBackdropColor then
                    frame:SetBackdropColor(r, g, b, a)
                    
                    -- Also set border color if available
                    if frame.SetBackdropBorderColor then
                        frame:SetBackdropBorderColor(r, g, b, a * 1.5)
                    end
                end
            end)
            
            return frame
        end
    end
    
    -- Ensure the Color function exists
    if not Phoenix_UI.Color then
        function Phoenix_UI:Color(alpha, force)
            -- Default theme color (fiery orange)
            return 0.9, 0.4, 0.13, alpha or 1.0
        end
    end
end

function Module:PatchSkinModule(moduleName, module)
    -- Skip if already patched
    if module._patchedSkin then return end
    
    -- Hook the OnEnable function to ensure it doesn't error
    if module.OnEnable then
        self:SecureHook(module, "OnEnable", function()
            -- Check for failed initializations and retry
            if module._skinFailed then
                self:FixModule(module)
            end
        end)
    end
    
    -- Apply patched versions of common skin operations
    self:FixModule(module)
    
    -- Mark as patched
    module._patchedSkin = true
end

function Module:FixModule(module)
    -- Create a safe wrapper for Color
    module.SafeColor = function(alpha, force)
        if Phoenix_UI.Color then
            return Phoenix_UI:Color(alpha, force)
        else
            return 0.15, 0.15, 0.15, alpha or 1.0
        end
    end
    
    -- Create a safe wrapper for Skin
    module.SafeSkin = function(frame, noBackdrop)
        if Phoenix_UI.Skin then
            return Phoenix_UI:Skin(frame, noBackdrop)
        elseif frame then
            -- Basic fallback implementation if Phoenix_UI.Skin doesn't exist
            local r, g, b, a = 0.15, 0.15, 0.15, 1.0 -- Default fallback colors
            
            if frame.SetVertexColor and not noBackdrop then
                pcall(function() frame:SetVertexColor(r, g, b, a) end)
            end
            
            if not noBackdrop and frame.SetBackdropColor then
                pcall(function() frame:SetBackdropColor(r, g, b, a) end)
                
                if frame.SetBackdropBorderColor then
                    pcall(function() frame:SetBackdropBorderColor(r, g, b, a * 1.5) end)
                end
            end
            
            return frame
        end
        return nil
    end
    
    -- Mark as fixed
    module._skinFailed = false
end

-- Initialize right away
Module:OnInitialize() 