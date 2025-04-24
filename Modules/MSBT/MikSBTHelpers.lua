local addonName, Phoenix = ...

-- This file adds helper methods to the embedded MikSBT that might be missing in some versions

-- Flag to track if we've already initialized
local hasInitialized = false

-- Function to initialize MikSBT helpers
local function InitMSBTHelpers()
    -- Don't run multiple times
    if hasInitialized then
        return true
    end
    
    -- Make sure MikSBT exists or wait for it to load
    if not _G.MikSBT then
        if Phoenix and Phoenix.debug then
            print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT not available yet. Waiting for it to load...")
        end
        return false -- Signal that MikSBT isn't ready yet
    end
    
    -- Add IsEnabled method if missing
    if not _G.MikSBT.IsEnabled then
        _G.MikSBT.IsEnabled = function()
            -- Check if MikSBT is enabled by looking at its registered events or other indicators
            if _G.MikSBT.isDisabled == true then
                return false
            end
            
            -- Check if the main frame exists and is shown
            if _G.MikSBT.mainFrame and _G.MikSBT.mainFrame:IsShown() then
                return true
            end
            
            -- Look for other indicators of being enabled
            if _G.MikSBT.modifyInterruptMsg or _G.MikSBT.ModifyInterruptMsg then
                return true
            end
            
            -- Check if any events are registered
            if _G.MikSBT.events and next(_G.MikSBT.events) then
                return true
            end
            
            -- Check if Main module is initialized
            if _G.MikSBT.Main and _G.MikSBT.Main.initialized then
                return true
            end
            
            -- Default to false if we can't determine the state
            -- This is safer than defaulting to true as it allows proper initialization
            return false
        end
    end
    
    -- Add EnableAddon method if missing
    if not _G.MikSBT.EnableAddon then
        _G.MikSBT.EnableAddon = function()
            -- Clear the disabled flag
            _G.MikSBT.isDisabled = nil
            
            -- If there's a main function to initialize, call it
            if _G.MikSBT.Main and _G.MikSBT.Main.Initialize then
                _G.MikSBT.Main:Initialize()
                _G.MikSBT.Main.initialized = true
            end
            
            -- Ensure the main frame is shown if it exists
            if _G.MikSBT.mainFrame then
                _G.MikSBT.mainFrame:Show()
            end
            
            -- Register events if the method exists
            if _G.MikSBT.RegisterEvents then
                _G.MikSBT:RegisterEvents()
            elseif _G.MikSBT.Main and _G.MikSBT.Main.RegisterEvents then
                _G.MikSBT.Main:RegisterEvents()
            end
            
            -- Initialize animations if needed
            if _G.MikSBT.Animations and _G.MikSBT.Animations.Initialize then
                _G.MikSBT.Animations:Initialize()
            end
            
            return true
        end
    end
    
    -- Add DisableAddon method if missing
    if not _G.MikSBT.DisableAddon then
        _G.MikSBT.DisableAddon = function()
            -- Set disabled flag
            _G.MikSBT.isDisabled = true
            
            -- Unregister events if the method exists
            if _G.MikSBT.UnregisterEvents then
                _G.MikSBT:UnregisterEvents()
            elseif _G.MikSBT.Main and _G.MikSBT.Main.UnregisterEvents then
                _G.MikSBT.Main:UnregisterEvents()
            end
            
            -- Hide the main frame if it exists
            if _G.MikSBT.mainFrame then
                _G.MikSBT.mainFrame:Hide()
            end
            
            return true
        end
    end
    
    -- Make sure MSBTOptions is available and works properly
    if _G.MSBTOptions and not _G.MSBTOptions.Main.ShowMainFrame then
        _G.MSBTOptions.Main.ShowMainFrame = function()
            -- Try to initialize if not already done
            if _G.MSBTOptions.Main.Initialize and not _G.MSBTOptions.initialized then
                _G.MSBTOptions.Main.Initialize()
                _G.MSBTOptions.initialized = true
            end
            
            -- Create and show the frame
            if _G.MSBTOptions.Main.CreateMainFrame then
                _G.MSBTOptions.Main.CreateMainFrame()
            end
            
            -- Try to show the frame if it exists
            if _G.MSBTOptions.mainFrame then
                _G.MSBTOptions.mainFrame:Show()
                return true
            elseif _G.MSBTOptions.Main.mainFrame then
                _G.MSBTOptions.Main.mainFrame:Show()
                return true
            end
            
            return false
        end
    end
    
    -- Mark as initialized
    hasInitialized = true
    
    -- Print success message with lower visibility
    if Phoenix and Phoenix.debug then
        print("|cffFF7D0APhoenix|r|cffFF0000_|r|cffFFD100UI|r: MikSBT helper methods added.")
    end
    
    return true -- Signal success
end

-- Create a global function to let other modules call initialization directly
_G.Phoenix_UI_InitMSBTHelpers = function()
    return InitMSBTHelpers()
end

-- Try to initialize when this file loads
InitMSBTHelpers()

-- Try again after a short delay to ensure MikSBT is loaded
C_Timer.After(1, InitMSBTHelpers)
-- And one more time with a longer delay as a fallback
C_Timer.After(5, InitMSBTHelpers)
-- Final attempt with an even longer delay for slow systems
C_Timer.After(10, InitMSBTHelpers) 