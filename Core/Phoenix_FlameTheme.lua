-- Phoenix Flame Theme Integration for Phoenix_UI
local Phoenix_UI = LibStub("AceAddon-3.0"):GetAddon("Phoenix_UI")
local LSM = LibStub("LibSharedMedia-3.0")

-- Theme metadata
local PhoenixFlame = {
    name = "PhoenixFlame",
    displayName = "Phoenix Flame",
    description = "A fiery theme inspired by the phoenix, with warm colors and flame effects",
    author = "VortexQ8",
    version = "1.0",
    
    -- Color scheme
    colors = {
        primary = {r = 0.9, g = 0.3, b = 0.05, a = 1.0}, -- Fiery orange
        secondary = {r = 0.6, g = 0.2, b = 0.05, a = 1.0}, -- Darker orange
        background = {r = 0.1, g = 0.04, b = 0.02, a = 0.9}, -- Dark red/brown
        border = {r = 0.9, g = 0.3, b = 0.05, a = 1.0}, -- Fiery orange
        text = {r = 1.0, g = 0.96, b = 0.85, a = 1.0}, -- Cream
        highlight = {r = 1.0, g = 0.64, b = 0.1, a = 0.8}, -- Amber
    },
    
    fonts = {
        title = "Friz Quadrata TT",
        normal = "Friz Quadrata TT",
        header = "Friz Quadrata TT",
    },
    
    -- Theme textures
    textures = {
        -- Base UI textures
        button = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\button.tga",
        buttonHighlight = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\hover.tga",
        buttonPressed = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\pressed.tga",
        background = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\background.tga",
        border = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\border.tga",
        tabSelected = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\tab.tga",
        tabDeselected = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\tab.tga",
        
        -- Specialized textures
        actionButton = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\actionbutton.tga",
        auraIcon = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\auraicon.tga",
        castbar = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\castbar.tga",
        chatframe = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\chatframe.tga",
        dropdown = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\dropdown.tga",
        glow = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\glow.tga",
        itemButton = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\itembutton.tga",
        shadow = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\shadow.tga",
        slider = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\slider.tga",
        statusBar = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\statusbar.tga",
        tooltip = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\tooltip.tga",
        unitframe = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\unitframe.tga",
        
        -- Special effect textures
        flame = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\flame.tga",
        ash = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\ash.tga",
        embers = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\embers.tga",
        smoke = "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\smoke.tga",
        
        -- Animation frames
        animationFrames = {
            "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame1.tga",
            "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame2.tga",
            "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame3.tga",
            "Interface\\AddOns\\Phoenix_UI\\Core\\phoenix_flame_theme\\textures\\animation\\flame4.tga",
        }
    }
}

-- Register theme textures with LibSharedMedia
local function RegisterPhoenixFlameMedia()
    -- Register basic textures with LibSharedMedia
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-Background", PhoenixFlame.textures.background)
    LSM:Register(LSM.MediaType.BORDER, "PhoenixFlame-Border", PhoenixFlame.textures.border)
    LSM:Register(LSM.MediaType.STATUSBAR, "PhoenixFlame-StatusBar", PhoenixFlame.textures.statusBar)
    
    -- Register effect textures
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-Glow", PhoenixFlame.textures.glow)
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-Flame", PhoenixFlame.textures.flame)
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-Embers", PhoenixFlame.textures.embers)
    
    -- Register button textures
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-Button", PhoenixFlame.textures.button)
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-ButtonHover", PhoenixFlame.textures.buttonHighlight)
    LSM:Register(LSM.MediaType.BACKGROUND, "PhoenixFlame-ButtonPressed", PhoenixFlame.textures.buttonPressed)
end

-- Add flame animation to a frame
local function AddFlameAnimation(frame)
    if not frame or frame.flameAnimation then return end
    
    -- Create animation container
    frame.flameAnimation = CreateFrame("Frame", nil, frame)
    frame.flameAnimation:SetFrameLevel(frame:GetFrameLevel() + 5)
    frame.flameAnimation:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
    frame.flameAnimation:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
    
    -- Create animation textures
    frame.flameAnimation.textures = {}
    for i = 1, #PhoenixFlame.textures.animationFrames do
        local tex = frame.flameAnimation:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetTexture(PhoenixFlame.textures.animationFrames[i])
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        frame.flameAnimation.textures[i] = tex
    end
    
    -- Create animation group
    frame.flameAnimation.group = frame.flameAnimation:CreateAnimationGroup()
    frame.flameAnimation.group:SetLooping("REPEAT")
    
    -- Set up animation sequence
    local frameCount = #PhoenixFlame.textures.animationFrames
    local frameDuration = 0.8 / frameCount
    
    for i = 1, frameCount do
        -- Fade in
        local fadeIn = frame.flameAnimation.group:CreateAnimation("Alpha")
        fadeIn:SetTarget(frame.flameAnimation.textures[i])
        fadeIn:SetOrder(i * 2 - 1)
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(0.5)
        fadeIn:SetDuration(frameDuration / 2)
        
        -- Fade out
        local fadeOut = frame.flameAnimation.group:CreateAnimation("Alpha")
        fadeOut:SetTarget(frame.flameAnimation.textures[i])
        fadeOut:SetOrder(i * 2)
        fadeOut:SetFromAlpha(0.5)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(frameDuration / 2)
    end
    
    -- Start the animation
    frame.flameAnimation.group:Play()
    
    return frame.flameAnimation
end

-- Add ember particles to a frame
local function AddEmberParticles(frame)
    if not frame or frame.emberParticles then return end
    
    -- Create particle container
    frame.emberParticles = CreateFrame("Frame", nil, frame)
    frame.emberParticles:SetFrameLevel(frame:GetFrameLevel() + 4)
    frame.emberParticles:SetAllPoints(frame)
    
    -- Create particle textures
    frame.emberParticles.textures = {}
    local particleCount = 5
    
    for i = 1, particleCount do
        local tex = frame.emberParticles:CreateTexture(nil, "OVERLAY")
        local size = math.random(5, 12)
        
        tex:SetSize(size, size)
        tex:SetTexture(PhoenixFlame.textures.embers)
        tex:SetBlendMode("ADD")
        tex:SetAlpha(0)
        
        -- Random position within the frame
        local xOffset = math.random(0, frame:GetWidth() - size)
        local yOffset = math.random(0, frame:GetHeight() - size)
        tex:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, -yOffset)
        
        frame.emberParticles.textures[i] = tex
    end
    
    -- Create animation group
    frame.emberParticles.group = frame.emberParticles:CreateAnimationGroup()
    frame.emberParticles.group:SetLooping("REPEAT")
    
    -- Set up particles animations
    for i = 1, particleCount do
        local tex = frame.emberParticles.textures[i]
        local duration = math.random(20, 40) / 10  -- 2.0 to 4.0 seconds
        
        -- Create animation for each particle
        local anim = frame.emberParticles.group:CreateAnimation("Path")
        anim:SetTarget(tex)
        
        -- Starting position (varies randomly)
        local xStart = math.random(-20, 20)
        local yStart = math.random(-10, 0)
        
        -- Ending position (always going up)
        local xEnd = math.random(-30, 30)
        local yEnd = math.random(-40, -20)
        
        -- Create control points for the path
        local startPoint = anim:CreateControlPoint()
        startPoint:SetOffset(xStart, yStart)
        startPoint:SetOrder(1)
        
        local endPoint = anim:CreateControlPoint()
        endPoint:SetOffset(xEnd, yEnd)
        endPoint:SetOrder(2)
        
        anim:SetDuration(duration)
        
        -- Fade in animation
        local fadeIn = frame.emberParticles.group:CreateAnimation("Alpha")
        fadeIn:SetTarget(tex)
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(math.random(5, 10) / 10)  -- 0.5 to 1.0 alpha
        fadeIn:SetDuration(duration * 0.3)
        fadeIn:SetOrder(i)
        
        -- Fade out animation
        local fadeOut = frame.emberParticles.group:CreateAnimation("Alpha")
        fadeOut:SetTarget(tex)
        fadeOut:SetFromAlpha(math.random(5, 10) / 10)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(duration * 0.7)
        fadeOut:SetOrder(i + particleCount)
    end
    
    -- Start the animation
    frame.emberParticles.group:Play()
    
    return frame.emberParticles
end

-- Enhanced ApplyTheme function for Phoenix Flame
local function ApplyPhoenixFlameTheme(frame, options)
    if not frame then return end
    
    options = options or {}
    
    -- Default options
    options.withBorder = options.withBorder ~= false
    options.withBackground = options.withBackground ~= false
    options.withShadow = options.withShadow ~= false
    options.withAnimation = options.withAnimation ~= false
    options.withEmbers = options.withEmbers ~= false
    
    -- Apply Phoenix UI theme system styling
    -- Create backdrop if it doesn't exist
    if not frame.backdrop then
        if frame.CreateBackdrop then
            frame:CreateBackdrop()
        else
            frame.backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            frame.backdrop:SetAllPoints()
            frame.backdrop:SetFrameLevel(frame:GetFrameLevel())
        end
    end
    
    -- Apply background
    if options.withBackground then
        if frame.SetBackdrop then
            frame:SetBackdrop({
                bgFile = PhoenixFlame.textures.background,
                insets = {left = 3, right = 3, top = 3, bottom = 3}
            })
            frame:SetBackdropColor(
                PhoenixFlame.colors.background.r,
                PhoenixFlame.colors.background.g,
                PhoenixFlame.colors.background.b,
                PhoenixFlame.colors.background.a
            )
        elseif frame.backdrop and frame.backdrop.SetBackdrop then
            frame.backdrop:SetBackdrop({
                bgFile = PhoenixFlame.textures.background,
                insets = {left = 3, right = 3, top = 3, bottom = 3}
            })
            frame.backdrop:SetBackdropColor(
                PhoenixFlame.colors.background.r,
                PhoenixFlame.colors.background.g,
                PhoenixFlame.colors.background.b,
                PhoenixFlame.colors.background.a
            )
        end
    end
    
    -- Apply border
    if options.withBorder then
        if frame.SetBackdrop and frame:GetBackdrop() then
            local backdrop = frame:GetBackdrop()
            backdrop.edgeFile = PhoenixFlame.textures.border
            backdrop.edgeSize = 8
            frame:SetBackdrop(backdrop)
            
            frame:SetBackdropBorderColor(
                PhoenixFlame.colors.border.r,
                PhoenixFlame.colors.border.g,
                PhoenixFlame.colors.border.b,
                PhoenixFlame.colors.border.a
            )
        elseif frame.backdrop and frame.backdrop.SetBackdrop then
            local backdrop = frame.backdrop:GetBackdrop() or {}
            backdrop.edgeFile = PhoenixFlame.textures.border
            backdrop.edgeSize = 8
            frame.backdrop:SetBackdrop(backdrop)
            
            frame.backdrop:SetBackdropBorderColor(
                PhoenixFlame.colors.border.r,
                PhoenixFlame.colors.border.g,
                PhoenixFlame.colors.border.b,
                PhoenixFlame.colors.border.a
            )
        end
    end
    
    -- Apply shadow
    if options.withShadow then
        if not frame.shadow then
            frame.shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            frame.shadow:SetFrameLevel(frame:GetFrameLevel() - 1)
            frame.shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
            frame.shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
        end
        
        frame.shadow:SetBackdrop({
            edgeFile = PhoenixFlame.textures.shadow,
            edgeSize = 12,
        })
        
        frame.shadow:SetBackdropBorderColor(0, 0, 0, 0.75)
    end
    
    -- Apply flame animation effects
    if options.withAnimation then
        AddFlameAnimation(frame)
    end
    
    -- Apply ember particle effects
    if options.withEmbers then
        AddEmberParticles(frame)
    end
    
    return frame
end

-- Special handling for UI elements
local function ApplyToUIElement(frame, elementType)
    if not frame then return end
    
    -- Default options
    local options = {
        withBorder = true,
        withBackground = true,
        withShadow = false,
        withAnimation = false,
        withEmbers = false
    }
    
    -- Customize based on element type
    if elementType == "button" then
        options.withBackground = true
        options.withBorder = true
        options.withShadow = false
        
        -- Apply button textures
        if frame.SetNormalTexture then
            frame:SetNormalTexture(PhoenixFlame.textures.button)
        end
        
        if frame.SetHighlightTexture then
            frame:SetHighlightTexture(PhoenixFlame.textures.buttonHighlight)
        end
        
        if frame.SetPushedTexture then
            frame:SetPushedTexture(PhoenixFlame.textures.buttonPressed)
        end
        
    elseif elementType == "unitframe" then
        options.withBackground = true
        options.withBorder = true
        options.withShadow = true
        options.withAnimation = false
        
        -- Apply flame animation to player and target frames only
        if frame == PlayerFrame or frame == TargetFrame then
            options.withAnimation = true
        end
        
    elseif elementType == "panel" then
        options.withBackground = true
        options.withBorder = true
        options.withShadow = true
        
    elseif elementType == "statusbar" then
        if frame.SetStatusBarTexture then
            frame:SetStatusBarTexture(PhoenixFlame.textures.statusBar)
        end
        
    elseif elementType == "config" then
        options.withBackground = true
        options.withBorder = true
        options.withShadow = true
        options.withAnimation = true
        options.withEmbers = true
    end
    
    -- Apply the theme with the specified options
    return ApplyPhoenixFlameTheme(frame, options)
end

-- Register with Phoenix_UI theme system
function Phoenix_UI:RegisterPhoenixFlameTheme()
    -- Register media with LibSharedMedia
    RegisterPhoenixFlameMedia()
    
    -- Register the theme with Phoenix_UI
    Phoenix_UI:RegisterTheme("PhoenixFlame", PhoenixFlame)
    
    -- Add custom apply functions
    PhoenixFlame.ApplyToFrame = ApplyPhoenixFlameTheme
    PhoenixFlame.ApplyToUIElement = ApplyToUIElement
    PhoenixFlame.AddFlameAnimation = AddFlameAnimation
    PhoenixFlame.AddEmberParticles = AddEmberParticles
    
    -- Log success
    if Phoenix_UI.Debug then
        Phoenix_UI:Debug("Phoenix Flame theme registered!")
    end
    
    return true
end

-- Initialize the theme
Phoenix_UI:RegisterPhoenixFlameTheme() 