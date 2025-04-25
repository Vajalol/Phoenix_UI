# 🔥 PHOENIX UI 🔥

> *"Rise from the ashes of ordinary interfaces"*

A modern, feature-rich World of Warcraft UI addon designed for PvP players, offering extensive customization and optimization options.

-------------------🔥🔥🔥🔥🔥🔥🔥-------------------

## 📋 Table of Contents
- [Recent Updates](#-recent-updates)
- [Getting Started](#-getting-started)
  - [Installation](#-installation)
  - [Configuration](#️-configuration)
  - [Troubleshooting](#-troubleshooting)
- [Features](#-features)
  - [General](#-general)
  - [Unit Frames](#-unit-frames)
  - [Nameplates](#️-nameplates)
  - [Action Bars](#️-action-bars)
  - [Cast Bars](#-cast-bars)
  - [Tooltip](#-tooltip)
  - [Buffs & Debuffs](#-buffs--debuffs)
  - [Chat](#-chat)
  - [Maps](#️-maps)
  - [Integrations](#-integrations)
  - [Miscellaneous](#-miscellaneous)
- [Support & Community](#-support--community)
  - [Contact](#-contact--support)
  - [Contributing](#-contributing)
  - [License](#️-license)
  - [Acknowledgments](#-acknowledgments)

-------------------🔥🔥🔥🔥🔥🔥🔥-------------------

## 🔆 RECENT UPDATES

### ⚡ Version 11.0.53
- **🗺️ New Mythic+ Module**: Comprehensive toolkit for Mythic+ dungeons with timer, progress tracking, and keystones
- **📊 Details! Skin Integration**: Added custom Phoenix-themed skin for Details! damage meter
- **⏱️ Enhanced Dungeon Tools**: Auto-detect keystones, track deaths, and monitor time remaining
- **🔥 Seamless Integration**: Both modules integrate with Phoenix UI's existing themes and settings
- **⚙️ Customizable Appearance**: Fully configurable layouts for optimal gameplay

### ⚡ Version 11.0.52
- **🔥 Enhanced UI Experience**: Redesigned title panel with dynamic fire effects and styled "Phoenix UI By VortexQ8" text
- **✨ Authentic Fire Animation**: Added game-native fire textures and ember particles for a true Warcraft feel
- **⚡ Visual Improvements**: Symmetric flame decorations and enhanced glow effects for a more cohesive look
- **🛠️ Settings System**: Further improved data integrity with enhanced validation and settings synchronization
- **⚙️ Module Optimization**: Optimized module loading sequence for better performance and reliability

### ⚡ Version 11.0.51
- **🔄 Improved Interface Version Compatibility**: Updated addon to support WoW 10.2.5, WoW Classic 3.4.1, and Classic Era 1.15.1
- **🛠️ Performance Optimization**: Enhanced addon load time with streamlined initialization
- **🌐 Multi-Version Support**: Fixed version detection to properly load appropriate features for each WoW version
- **📊 Memory Usage Improvements**: Reduced addon memory footprint during gameplay

### ⚡ Version 11.0.50
- **😀 Chat Emoji System**: Added full emoji support with clickable panel and automatic text conversion
- **👤 Enhanced Player Identification**: Added class icons alongside names with configurable positioning
- **🔍 Advanced Chat History**: Implemented powerful chat history search with filtering options
- **📊 Message Organization**: Added smart message categorization and collapsing for cleaner chat
- **👥 Social Integration**: Enhanced friend and guild information display in chat
- **⚡ Performance Optimization**: Improved chat performance with compression and virtual scrolling

### ⚡ Version 11.0.49
- **⚙️ Config System Improvements**: Fixed issues where some settings weren't being saved properly
- **🔠 Enhanced Font Handling**: Improved font path retrieval with multiple fallback mechanisms
- **⚙️ Better Settings Management**: Added comprehensive validation and defaults for all configuration options
- **⏱️ Optimized Text Formatting**: Improved cooldown text display with consistent formatting and colors
- **🛡️ Stability Improvements**: Enhanced error prevention and safer cooldown hooking throughout module

### ⚡ Version 11.0.48
- **⚙️ Config System Improvements**: Fixed issues where some settings weren't being saved properly
- **🔠 Enhanced Font Handling**: Improved font path retrieval with multiple fallback mechanisms
- **⚙️ Better Settings Management**: Added comprehensive validation and defaults for all configuration options
- **⏱️ Optimized Text Formatting**: Improved cooldown text display with consistent formatting and colors
- **🛡️ Stability Improvements**: Enhanced error prevention and safer cooldown hooking throughout module

### ⚡ Version 11.0.47
- **🛠️ Bug Fixes**: Fixed errors in GetSpellTexture function in PartyCD module with proper fallback handling
- **⚡ Fixed Stats Frame**: Resolved 'attempt to concatenate local specName (a nil value)' with improved nil checks
- **🔧 Fixed Edit Mode**: Corrected SetPoint() calls in Editmode.lua to prevent SetPoint errors
- **🔄 Code Stability**: Improved error handling and nil value checking throughout the addon

### ⚡ Version 11.0.46
- **🔮 WeakAuras Integration**: Added dedicated configuration panel for WeakAuras integration
- **🎨 Themed Auras**: Apply Phoenix UI themes to WeakAuras elements including borders, bars, and fonts
- **⚡ Performance Optimization**: Enhanced WeakAuras performance during combat with adaptive throttling
- **🔄 Module Synchronization**: Coordinate WeakAuras with other Phoenix UI modules like BuffOverlay and CooldownTracker

### ⚡ Version 11.0.45
- **🛠️ Fixed Protected Function Calls**: Resolved "ADDON_ACTION_BLOCKED" errors with raid frames in combat
- **⚙️ Improved Combat Handling**: New queue system for safely applying UI updates after combat ends
- **🔄 Enhanced Frame Update System**: Complete rewrite of the frame update architecture with safety checks
- **⚡ Enhanced Error Prevention**: Added robust protection around all risky frame operations

### ⚡ Version 11.0.44
- **💬 Enhanced Chat Features**: Completely redesigned chat copy system with improved reliability
- **🛠️ Fixed Chat Module Errors**: Resolved scroll and clipboard issues in the chat history interface
- **⌨️ Added Chat Copy Commands**: New slash commands for chat: `/chatcopy`, `/phxcopy`, or `/phoenixcopy`
- **👁️ Improved Visibility**: Enhanced copy button visibility and added helpful status messages
- **🔧 Configuration Fixes**: Fixed type initialization issues throughout configuration system

### ⚡ Version 11.0.43
- **🛠️ Fixed Player Stats Frame**: Resolved compatibility issues with frame templates and backdrop handling
- **🔢 Enhanced Stats Display**: Added raw numeric values alongside percentages for all player stats
- **📊 Stack Overflow Fix**: Fixed recursive function calls in stats calculation
- **🔄 Improved Resize Functionality**: Implemented reliable manual resizing for the player stats window
- **💬 Enhanced Tooltips**: Added target of target, role indicators, and detailed aura information
- **⏱️ Enhanced Castbars**: Added latency indicator and target name display to player castbar

### ⚡ Version 11.0.42
- **🔧 Fixed RaidFrames Texture Issues**: Resolved heal prediction texture errors with comprehensive compatibility updates
- **🛠️ Fixed BuffOverlay Integration**: Improved event handling and resolved texture cache errors
- **🧮 Enhanced Spell Priority System**: Fixed comparison errors in spell priority handling for healers
- **🔄 Improved Error Handling**: Added robust texture fallback mechanisms and error prevention
- **✨ Enhanced UI Theming**: Better Phoenix UI color integration across all modules

### ⚡ Version 11.0.41
- **🛠️ Fixed Configuration System**: Improved saving mechanism for text fields and other edit box widgets
- **🔤 Enhanced Font Management**: Better handling of font settings across the UI
- **🔕 Startup Message Control**: Suppressed unnecessary messages during addon initialization
- **⚡ Performance Improvements**: Optimized database operations for smoother experience

-------------------🔥🔥🔥🔥🔥🔥🔥-------------------

## 🚀 GETTING STARTED

### 📥 Installation
1. Download the latest release
2. Extract to your World of Warcraft/_retail_/Interface/AddOns folder
3. Enable the addon in-game
4. Type `/pui` or `/phoenix` to access the configuration menu

### ⚙️ Configuration
- Use the in-game configuration menu (`/pui`) to customize all features
- Global configuration via Game Menu (ESC) > Phoenix UI button
- Important slash commands:
  ```
  /pui or /phoenix - Opens the main configuration panel
  /rl              - Reloads the UI
  /fs              - Shows the frame stack tool
  /uis-reset       - Resets UI scaling to default
  ```
- Settings are saved per-character by default
- Most changes take effect immediately without requiring UI reload

### 🔧 Troubleshooting
- If settings aren't being saved correctly, try using the Game Menu button instead of slash commands
- For font issues, try changing the font in the General settings and reload your UI
- If you encounter startup messages from other addons, check the suppression settings in Misc

-------------------🔥🔥🔥🔥🔥🔥🔥-------------------

## 🔥 FEATURES

### 📊 General
- **🎨 Theme System**: Multiple themes including Dark, Class-based, and Custom color schemes
- **⚙️ Automation**: 
  - Auto-delete junk items
  - Auto-repair equipment
  - Auto-sell gray items
  - Auto-stack buy
  - Auto-decline duels
  - Auto-release in battlegrounds
  - Auto-accept resurrection
  - Auto-skip cinematics
- **👁️ Display Options**:
  - Item level display
  - FPS and MS monitoring
  - Movement speed display
  - AFK screen customization
  - Talkhead frame control
  - Error message filtering

### 🧬 Unit Frames
- **👤 Player & Target Frames**:
  - Customizable size and style
  - Class color integration
  - Faction color options
  - PvP badge display
  - Combat icon indicators
  - Hit indicators
  - Totem icons
  - Class bar integration
  - Corner icon display
- **💪 Boss Frames**:
  - Custom health bar colors
  - Reputation-based coloring
  - Texture customization
- **👥 Raid Frames**:
  - Customizable size and layout
  - Always-on-top option
  - Custom textures
  - Height and width adjustments

### 🏷️ Nameplates
- **🔧 Customization**:
  - Multiple style options
  - Custom textures
  - Arena number display
  - Totem icons
  - Health text
  - Server name display
  - Color customization
  - Cast time display
  - Stacking mode
  - Height and width adjustments
  - Decimal precision control
- **🎯 NPC Colors**:
  - Extensive dungeon-specific NPC coloring
  - Customizable color schemes
  - Focus highlight options

### ⚔️ Action Bars
- **🔘 Button Features**:
  - Key binding display
  - Macro text display
  - Range indicator
  - Flash effect toggle
  - Customizable size
- **📑 Menu Options**:
  - Micro menu customization
  - Bag bar display options
- **⚡ Bar Configuration**:
  - Individual bar toggles (1-8)
  - Pet bar customization
  - Stance bar options

### 🔄 Cast Bars
- **🔮 Player Cast Bar**:
  - Custom style options
  - Timer display
  - Icon display
  - Latency indicator with ms display
  - Target name display with class coloring
- **🎯 Target Cast Bar**:
  - Customizable size
  - Position options
  - Timer and icon display
- **👁️ Focus Cast Bar**:
  - Customizable size
  - Position options
  - Timer and icon display

### 💬 Tooltip
- **🎨 Customization**:
  - Multiple style options
  - Life on top display
  - Mouse anchor options
  - Enhanced information display
- **🎯 Gameplay Enhancements**:
  - Target of target information
  - Role indicators (tank/healer/dps)
  - Detailed aura information:
    - Duration and time remaining
    - Aura source (who cast it)
    - Classification (Magic/Curse/Disease/Poison)

### ✨ Buffs & Debuffs
- **⬆️ Buff Display**:
  - Customizable size
  - Padding control
  - Icon count configuration
- **⬇️ Debuff Display**:
  - Customizable size
  - Padding control
  - Icon count configuration

### 💭 Chat
- **📝 Style & Core Features**
  - Custom style options with top/bottom input positioning
  - Clickable links for easy copying
  - Class-colored names and messages
  - Enhanced copy button with chat history access
  - Quick join options for friends and groups
  - Loot icon integration for better visibility

- **😀 Emoji System**
  - Full emoji support with clickable emoji panel
  - Automatic conversion of text patterns to emojis (`:)`, `:D`, etc.)
  - Custom emoji codes (`:smile:`, `:love:`, etc.)
  - Adjustable emoji size

- **👤 Enhanced Player Identification**
  - Class icons alongside names
  - Configurable icon positioning (before/after name)
  - Role icons display (tank/healer/dps)
  - Improved visual clarity with customizable indicators

- **🔍 Advanced History Features**
  - Searchable chat history with multiple filtering options
  - Date/time separators for better context
  - One-click copying from search results
  - Chat history retention with configurable duration

- **📊 Message Organization**
  - Smart message categorization (loot, combat, system, achievement)
  - Intelligent collapsing of repetitive messages
  - Visual category indicators with color-coding
  - Cleaner chat experience with reduced clutter

- **👥 Social Integration**
  - Enhanced friend status display
  - Guild rank indicators
  - Inline tooltips with player information
  - Friend note display
  - Battle.net integration

- **⚡ Performance Features**
  - Chat history compression to reduce memory usage
  - Automatic cleanup of old messages
  - Virtual scrolling for smooth performance with large histories
  - Update throttling during high chat activity

### 🗺️ Maps
- **🧭 Minimap**:
  - Size customization
  - Style options
  - Small mode toggle
  - Opacity control
  - Coordinate display
  - Clock display
  - Date display
  - Garrison button
  - Tracking options
  - Button display
  - Expansion button toggle

### 🔥 Integrations
- **⚡ WeakAuras Integration**:
  - Dedicated configuration tab in Phoenix UI settings
  - Apply Phoenix UI themes to WeakAuras elements
  - Themed borders for WeakAuras icons
  - Themed progress bars with Phoenix UI textures
  - Phoenix UI font integration
  - Performance optimization during combat
  - Adaptive FPS-based throttling
  - Synchronization with BuffOverlay
  - Prevention of duplicate aura displays
  - Coordination with other Phoenix UI modules

- **📊 Details! Damage Meter Skin**:
  - Custom phoenix/fire-themed skin for Details! windows
  - Orange and dark color scheme matching Phoenix UI
  - Custom texture and font settings
  - Default profile that can be imported directly
  - Easy apply button in Phoenix UI settings
  - Slash commands support: `/phoenixskin` and `/phoeniximport`

### 🗺️ Mythic+ Tools
- **⏱️ Dungeon Timer**:
  - Live timer showing time elapsed and time remaining
  - Color-coded progress tracking
  - Indicates 2-chest and 3-chest timings
  - Customizable position and appearance

- **📈 Objective Tracking**:
  - Real-time progress tracking with percentage and count
  - Enhanced objective display with completion status
  - Death counter with time penalty calculation
  - Automatic tracking of prideful/shrouded spawns

- **🔑 Keystone Enhancement**:
  - In-depth keystone information display
  - Weekly affix explanations
  - Auto-gossip for dungeon NPCs
  - Streamlined dungeon navigation

### 🔥 Miscellaneous
- **⚔️ PvP Features**:
  - Safe queue functionality
  - Tab binding options
  - Pull timer
  - Interrupt tracker
  - Dampening display
  - Arena nameplate options
  - Surrender options
- **🌟 Quality of Life**:
  - Loss of control display
  - Reputation bar
  - Menu button
  - Dragon flying support

-------------------🔥🔥🔥🔥🔥🔥🔥-------------------

## 🤝 SUPPORT & COMMUNITY

### 📞 Contact & Support
- 🐙 **GitHub**: [Github Repository](https://github.com/Vajalol/Phoenix_UI)
- 💬 **Discord**: [Community Discord](https://discord.gg/69q6YWmvks)
- 💰 **Donate**: [Paypal](https://www.paypal.com/donate/?hosted_button_id=67ASZ8FXPXMDY)

### 🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

### ⚖️ License
This project is licensed under the MIT License - see the LICENSE file for details.

### 👏 Acknowledgments
- Thanks to all contributors and testers
- Special thanks to the World of Warcraft addon community for inspiration and support 
