-- Phoenix_UI: Details! Skin Module - Textures
-- Defines and manages textures used by the Details! skin

local addonName, Phoenix = ...
local DetailsSkin = Phoenix.DetailsSkin

if not DetailsSkin then return end

-- Default texture paths relative to the addon
local defaultTextures = {
    -- Background textures
    ["Background"] = "Media/Textures/Background/DarkPanel.blp",
    ["Gradient"] = "Media/Textures/Background/Gradient.blp",
    
    -- Bar textures
    ["GradientBar"] = "Media/Textures/Status/Gradient.blp",
    ["GlossyBar"] = "Media/Textures/Status/Glossy.blp",
    ["SolidBar"] = "Media/Textures/Status/Solid.blp",
    
    -- Border textures
    ["PhoenixBorder"] = "Media/Textures/Border/Phoenix.blp",
    ["GlowBorder"] = "Media/Textures/Border/Glow.blp",
    
    -- Button textures
    ["CloseButton"] = "Media/Textures/Buttons/CloseButton.blp",
    ["MaximizeButton"] = "Media/Textures/Buttons/MaximizeButton.blp",
    ["MinimizeButton"] = "Media/Textures/Buttons/MinimizeButton.blp",
    
    -- Icon textures
    ["PhoenixIcon"] = "Media/Icons/Phoenix.blp",
    ["FireIcon"] = "Media/Icons/Fire.blp"
}

-- Texture fallbacks from Blizzard UI if our textures aren't available
local fallbackTextures = {
    ["Background"] = "Interface\\DialogFrame\\UI-DialogBox-Background",
    ["Gradient"] = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill",
    ["GradientBar"] = "Interface\\TargetingFrame\\UI-StatusBar",
    ["GlossyBar"] = "Interface\\AddOns\\Details\\images\\bar_background",
    ["SolidBar"] = "Interface\\Buttons\\WHITE8x8",
    ["PhoenixBorder"] = "Interface\\DialogFrame\\UI-DialogBox-Border",
    ["GlowBorder"] = "Interface\\Tooltips\\UI-Tooltip-Border",
    ["CloseButton"] = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up",
    ["MaximizeButton"] = "Interface\\Buttons\\UI-Panel-SmallerButton-Up",
    ["MinimizeButton"] = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up",
    ["PhoenixIcon"] = "Interface\\Icons\\INV_Misc_PheonixPet_01",
    ["FireIcon"] = "Interface\\Icons\\Spell_Fire_Fire"
}

-- Table to hold resolved texture paths
DetailsSkin.textures = {}

-- Function to get the full path for a texture
local function GetTexturePath(textureName)
    -- First try our addon path
    local addonPath = "Interface\\AddOns\\Phoenix_UI\\"
    local defaultPath = defaultTextures[textureName]
    
    if defaultPath then
        local fullPath = addonPath .. defaultPath
        -- Return the full path
        return fullPath
    end
    
    -- If not found, return fallback
    return fallbackTextures[textureName] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Initialize all textures
function DetailsSkin:InitializeTextures()
    for name, _ in pairs(defaultTextures) do
        self.textures[name] = GetTexturePath(name)
    end
    
    -- Debug texture paths
    self:Debug("Textures initialized")
end

-- Get a specific texture
function DetailsSkin:GetTexture(textureName)
    return self.textures[textureName] or fallbackTextures[textureName] or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Register with module OnEnable
local originalOnEnable = DetailsSkin.OnEnable
DetailsSkin.OnEnable = function(self)
    -- Initialize textures
    self:InitializeTextures()
    
    -- Call original OnEnable
    if originalOnEnable then
        originalOnEnable(self)
    end
end

-- Modify the skin to use our texture paths
local originalCreateSkinProfile = DetailsSkin.CreateSkinProfile
DetailsSkin.CreateSkinProfile = function(self)
    -- Initialize textures if not done yet
    if not self.textures or not next(self.textures) then
        self:InitializeTextures()
    end
    
    -- Call original function
    local skin = originalCreateSkinProfile and originalCreateSkinProfile(self) or {}
    
    -- Update skin with our textures
    if skin then
        -- Update background textures
        skin.backdrop_texture = self:GetTexture("Background")
        if skin.row_info then
            skin.row_info.texture = self:GetTexture("GradientBar")
            skin.row_info.texture_background = self:GetTexture("Background")
        end
        
        -- Update status bar
        if skin.statusbar_info then
            skin.statusbar_info.texture = self:GetTexture("GlossyBar")
        end
        
        -- Update icon
        if skin.total_bar then
            skin.total_bar.icon = self:GetTexture("PhoenixIcon")
        end
    end
    
    return skin
end

-- Add texture download/generation functions if we need to create textures on demand
function DetailsSkin:GenerateDefaultTextures()
    -- This function would generate basic textures programmatically if needed
    -- For example, creating solid color textures or gradients
    
    -- Note: In a real implementation, this would create and save the textures
    -- For this example, we'll just use fallbacks
    self:Debug("Using fallback textures")
end 