# Phoenix UI: Texture Downloader Script
# This script downloads necessary textures from web sources for the Detail-Skin module

# Define texture URLs (using GitHub raw URLs as examples)
$textures = @{
    # Background textures
    "DarkPanel" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/TALKINGHEAD/TH-generic-texture.PNG"
        "output" = "Media/Textures/Background/DarkPanel.blp"
    }
    "Gradient" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/TALKINGHEAD/TH-generic-texture.PNG"
        "output" = "Media/Textures/Background/Gradient.blp"
    }
    
    # Bar textures
    "GradientBar" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-CastingBar-Border.PNG"
        "output" = "Media/Textures/Status/Gradient.blp"
    }
    "GlossyBar" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-StatusBar.PNG"
        "output" = "Media/Textures/Status/Glossy.blp"
    }
    "SolidBar" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/WHITE8x8.PNG"
        "output" = "Media/Textures/Status/Solid.blp"
    }
    
    # Border textures
    "PhoenixBorder" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-DialogBox-Border.PNG"
        "output" = "Media/Textures/Border/Phoenix.blp"
    }
    "GlowBorder" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-Tooltip-Border.PNG"
        "output" = "Media/Textures/Border/Glow.blp"
    }
    
    # Button textures
    "CloseButton" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-Panel-MinimizeButton-Up.PNG"
        "output" = "Media/Textures/Buttons/CloseButton.blp"
    }
    "MaximizeButton" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-Panel-SmallerButton-Up.PNG"
        "output" = "Media/Textures/Buttons/MaximizeButton.blp"
    }
    "MinimizeButton" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/UI-Panel-MinimizeButton-Up.PNG"
        "output" = "Media/Textures/Buttons/MinimizeButton.blp"
    }
    
    # Icon textures
    "PhoenixIcon" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/SPELLS/INV_Misc_PheonixPet_01.PNG"
        "output" = "Media/Icons/Phoenix.blp"
    }
    "FireIcon" = @{
        "url" = "https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/SPELLS/Spell_Fire_Fire.PNG"
        "output" = "Media/Icons/Fire.blp"
    }
}

# Function to download a texture
function Download-Texture {
    param (
        [string]$url,
        [string]$output
    )
    
    $fullOutputPath = Join-Path -Path $PSScriptRoot -ChildPath $output
    $outputDir = Split-Path -Path $fullOutputPath -Parent
    
    # Create directory if it doesn't exist
    if (!(Test-Path -Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    Write-Host "Downloading $url to $fullOutputPath"
    
    try {
        # Set security protocol to use TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Create a new WebClient
        $webClient = New-Object System.Net.WebClient
        
        # Download the file
        $webClient.DownloadFile($url, $fullOutputPath)
        
        Write-Host "Download successful" -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading file: $_" -ForegroundColor Red
    }
}

# Main
Write-Host "Phoenix UI: Detail-Skin Texture Downloader" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

foreach ($textureName in $textures.Keys) {
    $textureInfo = $textures[$textureName]
    Download-Texture -url $textureInfo.url -output $textureInfo.output
}

Write-Host "Download complete. Check the Media/Textures directory for downloaded files." -ForegroundColor Green
Write-Host "You can use these textures with the Details! skin module." -ForegroundColor Cyan 