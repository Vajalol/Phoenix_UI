	# Phoenix UI Assets Guide

This directory contains media assets for the Phoenix UI addon, including fonts, textures, sounds, and icons. Some of these assets are placeholders and need to be replaced with actual files for the UI to display correctly.

## Required Fonts

The following fonts are required for Phoenix UI to display properly:

### Google Fonts (Free)

1. **Roboto Family**
   - Download from: https://fonts.google.com/specimen/Roboto
   - Required files:
     - `Roboto-Regular.ttf`
     - `Roboto-Bold.ttf`
   - Place in: `Media/Fonts/`

2. **Cinzel Family**
   - Download from: https://fonts.google.com/specimen/Cinzel
   - Required files:
     - `Cinzel-Bold.ttf`
   - Place in: `Media/Fonts/`

## Required Textures

### Basic UI Textures

The following textures are needed for basic UI elements:

1. **Button Textures**
   - `Button-Normal.tga` - Normal state for buttons
   - `Button-Highlight.tga` - Highlighted state for buttons
   - `Button-Pushed.tga` - Pushed state for buttons
   - Place in: `Media/Textures/`

2. **Frame Textures**
   - `Frame-Background.tga` - Background for UI frames
   - `Frame-Border.tga` - Border for UI frames
   - `StatusBar.tga` - Texture for status bars
   - Place in: `Media/Textures/`

3. **Special Effects**
   - `PhoenixLogo.tga` - Logo for Phoenix UI
   - `FireOverlay.tga` - Fire effect overlay
   - Place in: `Media/Textures/`

### Theme-Specific Textures

The following textures are used for specific UI themes:

1. **Bar Textures** (Place in `Media/Textures/Bars/`)
   - `Smooth.tga` - Smooth texture for status bars
   - `Gradient.tga` - Gradient texture for status bars

2. **Background Textures** (Place in `Media/Textures/Backgrounds/`)
   - `Dark.tga` - Dark background texture
   - `Gradient.tga` - Gradient background texture
   - `Transparent.tga` - Transparent background texture
   - `Tooltip.tga` - Tooltip background texture
   - `Notification.tga` - Notification background texture

## Creating Your Own Textures

If you want to create your own textures, the recommended dimensions are:

- Button textures: 256x64 pixels
- Status bars: 256x32 pixels
- Backgrounds: 256x256 pixels
- Borders: 64x64 pixels

You can use graphics software like GIMP (free) or Photoshop to create these textures.

## Finding UI Textures

You can find high-quality UI textures from these sources:

1. **OpenGameArt.org** - https://opengameart.org/
   - Free game assets including UI textures
   
2. **Game-Icons.net** - https://game-icons.net/
   - Free game icons that can be used in your UI

3. **UI8.net** - https://ui8.net/
   - Premium UI kits and textures

4. **ShareTextures** - https://www.sharetextures.com/
   - Free and premium textures

Remember to check the licensing terms of any assets you download to ensure they can be used in your addon. 