# Phoenix_UI Changelog

## Version 11.0.55 Updates

### SpellNotifications Module Fixes
- **Fixed Combat Event Registration**
  - Resolved "Attempt to register unknown event 'UNIT_DIED'" error that occurred when enabling the module
  - Improved event handling by using the COMBAT_LOG_EVENT_UNFILTERED event to detect unit deaths
  - Removed direct registrations of "UNIT_DIED", "UNIT_DESTROYED", and "UNIT_DISSIPATES" events
  - Implemented proper combat log event filtering to catch relevant death events
  - Added additional error prevention mechanisms to avoid similar issues

- **Enhanced Unit Death Detection**
  - Rewrote the pet death detection logic to work with combat log events
  - Implemented direct GUID comparison between combat log and player's pet
  - Improved reliability of death detection across all game activities
  - Fixed issues with the CheckPetDeath function receiving incorrect parameters
  - Enhanced handling of unitGUID and unitName to work properly with combat log format

- **Performance and Stability Improvements**
  - Optimized event handling with better parameter processing
  - Added defensive code to prevent nil value errors in event handling
  - Improved module initialization to properly register only valid events
  - Enhanced combat log processing for better performance
  - Added additional error logging to help diagnose future issues

## Version 11.0.54 Updates

### Enhanced PremadeGroupsFilter Module
- **Improved Phoenix UI Integration**
  - Enhanced profile data synchronization with the core Phoenix UI database
  - Added profile change detection to update filter settings automatically
  - Implemented automatic settings migration when switching between profiles
  - Created logout handler to ensure settings are saved when exiting the game
  - Added default setting validation to prevent missing configuration errors

- **Optimized Group Coloring System**
  - Implemented state caching to avoid redundant color changes for the same groups
  - Added memory-efficient caching system that cleans up after itself
  - Created automatic cache cleanup to prevent memory bloat during long sessions
  - Improved color application with priority system for different group states
  - Enhanced visual clarity for declined, new, and matched groups

- **Performance Improvements**
  - Added nil value protection throughout the module to prevent errors
  - Optimized member count handling to reduce unnecessary API calls
  - Enhanced error logging with friendlier user messages
  - Improved error resilience when evaluating user filter expressions
  - Fixed potential syntax issues with function definitions

## Version 11.0.53 Updates

### New Mythic+ Module
- **Core Mythic+ Features**
  - Implemented comprehensive Mythic+ dungeon toolkit
  - Created intuitive timer display with remaining and elapsed time
  - Added progress tracking with percentage and count display
  - Integrated death tracking with time penalty calculations
  - Implemented keystone detection and information display
  
- **Dungeon Enhancements**
  - Added auto-gossip feature for dungeon NPCs
  - Created detailed objective tracking with completion status
  - Implemented thorough affix explanation system
  - Added season notification and achievement tracking
  - Created configurable UI with movable and lockable frames

- **Integration and Configuration**
  - Added dedicated configuration panel in Phoenix UI settings
  - Implemented phoenix-themed visuals for all Mythic+ elements
  - Created slash commands for easier access to features
  - Added support for all current dungeons in The War Within Season 2
  - Implemented event system for seamless interaction with other modules

### Details! Damage Meter Skin
- **Phoenix-Themed Skin**
  - Created custom skin to match Phoenix UI's fire/orange theme
  - Implemented comprehensive texture replacement for all Details! elements
  - Added custom fonts to maintain consistent typography
  - Created default profile with optimized settings
  
- **Usability Features**
  - Added one-click skin application from Phoenix UI settings
  - Implemented slash commands: `/phoenixskin` and `/phoeniximport`
  - Created automatic texture downloader script for easy updates
  - Added texture fallbacks for better compatibility
  
- **Integration with Phoenix UI**
  - Ensured visual consistency with Phoenix UI color scheme
  - Implemented proper theme coordination with Phoenix UI modules
  - Added comprehensive configuration options in Phoenix UI panel
  - Created seamless background and border integration

## Version 11.0.52 Updates

### UI Enhancements
- **🔥 Redesigned Title Panel**: Replaced the VortexQ8 logo with styled "Phoenix UI By VortexQ8" text and dynamic fire effects
- **⚡ Enhanced Fire Animations**: Added authentic in-game fire effects and ember particles to the title panel
- **🌟 Improved Visual Elements**: Added symmetric flame decorations and enhanced glow effects
- **💾 Enhanced Settings System**: Further improved the settings saving mechanism for better data integrity
- **🔄 Module Synchronization**: Optimized module initialization order to ensure proper loading sequence

## Version 11.0.51 Updates

### API Compatibility Fixes
- **🛠️ Fixed GuildRoster API**: Resolved "attempt to call global 'GuildRoster' (a nil value)" error with proper API compatibility layer
- **🔄 Enhanced Version Detection**: Improved WoW version detection with better compatibility for all game versions
- **⚙️ API Compatibility Layer**: Added comprehensive API compatibility to handle different function names across WoW versions
- **👥 Social Module Fixes**: Improved guild roster handling to work correctly on retail and classic clients

## Version 11.0.50 Updates

### Comprehensive Chat Enhancement
- **Emoji System**
  - Implemented full emoji support with clickable emoji panel
  - Added automatic conversion of text patterns to emoji icons
  - Created custom emoji codes like `:smile:`, `:love:`, etc.
  - Integrated with existing chat features for seamless experience

- **Enhanced Player Identification**
  - Added class icons alongside class coloring for better visibility
  - Implemented configurable icon position (before or after name)
  - Improved player role identification with tank/healer/dps icons
  - Enhanced overall readability of player messages

- **Advanced Chat History**
  - Added powerful search functionality for chat history
  - Implemented date/time separators for better context
  - Created filtering options by chat type and content
  - Added easy copy functionality for search results

- **Message Organization**
  - Implemented smart message categorization (loot, combat, system, achievement)
  - Added intelligent message collapsing for repetitive content
  - Created visual category indicators with customizable colors
  - Reduced chat clutter through smart grouping of related messages

- **Social Integration**
  - Enhanced friend and guild member status display in chat
  - Added guild rank indicators next to guild members
  - Implemented inline tooltips with detailed player information
  - Added friend note display for easier identification

- **Performance Optimization**
  - Implemented chat history compression to reduce memory usage
  - Added automatic cleanup of old chat messages
  - Created virtual scrolling system for better performance with large histories
  - Added update throttling during high chat activity periods

- **Configuration Options**
  - Added comprehensive settings for all new chat features
  - Implemented toggle options to enable/disable individual enhancements
  - Created intuitive organization of settings in the configuration panel
  - Ensured all features maintain compatibility with existing chat modules

## Version 11.0.49 Updates

### Configuration System Improvements
- **Enhanced Settings Saving**
  - Fixed issue where some configuration changes weren't being saved
  - Added CommitPendingChanges function to ensure EditBox values are properly committed
  - Implemented SaveAllTabElements function to forcibly commit all UI element values
  - Added automatic saving after any configuration change is made
  - Ensured all modules are properly saved when configuration panel is closed

### CooldownText Module Improvements
- **Enhanced Font Handling**
  - Improved font path retrieval with multiple fallback mechanisms
  - Added better error handling to ensure text always displays properly
  - Fixed issues with missing or invalid font paths
  - Ensured compatibility with all WoW client versions

- **Improved Settings Management**
  - Added comprehensive validation for all settings
  - Implemented proper defaults for missing configuration options
  - Enhanced threshold handling for cooldown text appearance
  - Added safety checks for color and timing values

- **Enhanced Text Formatting**
  - Optimized cooldown time display with consistent formatting
  - Improved color application for different time ranges
  - Fixed tenths of seconds display for short cooldowns
  - Enhanced readability of all countdown text

- **Stability Enhancements**
  - Added robust error prevention throughout the module
  - Implemented safer cooldown hooking with fallback mechanisms
  - Added memory leak prevention through better cleanup
  - Improved combat performance optimization

## Version 11.0.48 Updates

### Configuration System Improvements
- **Enhanced Settings Saving**
  - Fixed issue where some configuration changes weren't being saved
  - Added CommitPendingChanges function to ensure EditBox values are properly committed
  - Implemented SaveAllTabElements function to forcibly commit all UI element values
  - Added automatic saving after any configuration change is made
  - Ensured all modules are properly saved when configuration panel is closed

### CooldownText Module Improvements
- **Enhanced Font Handling**
  - Improved font path retrieval with multiple fallback mechanisms
  - Added better error handling to ensure text always displays properly
  - Fixed issues with missing or invalid font paths
  - Ensured compatibility with all WoW client versions

- **Improved Settings Management**
  - Added comprehensive validation for all settings
  - Implemented proper defaults for missing configuration options
  - Enhanced threshold handling for cooldown text appearance
  - Added safety checks for color and timing values

- **Enhanced Text Formatting**
  - Optimized cooldown time display with consistent formatting
  - Improved color application for different time ranges
  - Fixed tenths of seconds display for short cooldowns
  - Enhanced readability of all countdown text

- **Stability Enhancements**
  - Added robust error prevention throughout the module
  - Implemented safer cooldown hooking with fallback mechanisms
  - Added memory leak prevention through better cleanup
  - Improved combat performance optimization

## Version 11.0.47 Updates

### Bug Fixes and Stability Improvements
- **Fixed GetSpellTexture Function in PartyCD Module**
  - Resolved errors when trying to retrieve spell textures for party cooldowns
  - Added proper fallback mechanism when C_Spell.GetSpellTexture API is unavailable
  - Implemented default question mark texture (134400) when no texture can be found
  - Improved error handling to prevent nil texture errors

- **Fixed Stats Frame Specialization Display**
  - Resolved "attempt to concatenate local 'specName' (a nil value)" error in _Stats.lua
  - Added robust nil checks for specialization name retrieval
  - Implemented fallback to display "Spec X" when specialization name is unavailable
  - Fixed similar issue in the loot specialization display

- **Fixed Edit Mode Frame Positioning**
  - Corrected SetPoint() function calls in _Editmode.lua
  - Fixed errors with StatsFrame and QueueStatusButton positioning
  - Added proper parameter formatting for frame anchor points
  - Implemented ClearAllPoints() before setting new position to prevent multiple anchor points

- **General Code Stability Improvements**
  - Enhanced error prevention with additional nil checks throughout the codebase
  - Improved function parameter validation to prevent common errors
  - Added fallback mechanisms for API functions that might return nil values
  - Implemented safer handling of frame operations to prevent UI errors

## Version 11.0.46 Updates

### WeakAuras Integration
- **Added WeakAuras Configuration Panel**
  - Created dedicated tab in Phoenix UI configuration for WeakAuras settings
  - Implemented comprehensive options for controlling WeakAuras integration
  - Added clear descriptions and tooltips for each option
  - Organized settings into logical categories for easy navigation

- **Enhanced Visual Integration**
  - Added theme synchronization between Phoenix UI and WeakAuras
  - Implemented themed borders for WeakAuras icons matching Phoenix UI style
  - Applied Phoenix UI textures to WeakAuras progress bars
  - Added font integration to maintain visual consistency
  - Ensured proper color matching with Phoenix UI theme colors

- **Performance Optimization Features**
  - Created combat-specific performance mode for WeakAuras
  - Implemented adjustable update frequency during combat situations
  - Added FPS-based throttling to reduce impact during graphically intensive moments
  - Created customizable FPS threshold for throttling activation
  - Implemented safe recovery when performance stabilizes

- **Module Synchronization**
  - Added coordination between WeakAuras and BuffOverlay to prevent duplicate displays
  - Implemented synchronization with CooldownTracker for better visual harmony
  - Created event messaging system between Phoenix UI modules and WeakAuras
  - Ensured proper integration with Phoenix UI media resources
  - Added template support for Phoenix UI-specific WeakAuras

## Version 11.0.45 Updates

### RaidFrames Protected Function Call Fixes
- **Fixed Combat Lockdown Errors**
  - Resolved "ADDON_ACTION_BLOCKED" errors with CompactPartyFrameMember SetSize() calls
  - Implemented comprehensive combat protection system for all raid frame modifications
  - Added queueing system to safely apply frame updates after combat ends
  - Enhanced combat state tracking to prevent protected function call attempts

- **Improved Frame Update Architecture**
  - Complete rewrite of the frame update system with multi-layered safety checks
  - Added pending updates queue to track frames that need resizing outside of combat
  - Implemented proper event management for GROUP_ROSTER_UPDATE and combat events
  - Added multiple redundant combat checks to ensure addon never attempts protected operations in combat

- **Enhanced Error Prevention and Recovery**
  - Added pcall protection around all potentially risky frame operations
  - Implemented robust nil checking and forbidden state verification
  - Improved positioning of frame elements without requiring protected function calls
  - Added intelligent combat state recovery to resume operations safely when combat ends

## Version 11.0.44 Updates

### Enhanced Chat Features
- **Improved Chat Copy Functionality**
  - Completely redesigned chat copy system with enhanced reliability and user experience
  - Fixed issues with empty chat copy window and proper text display
  - Added more visible copy button at the top-right corner of chat frames
  - Implemented slash commands for direct access to chat copy: `/chatcopy`, `/phxcopy`, or `/phoenixcopy`
  - Added fallback mechanisms to ensure copy functionality works in all environments

- **Fixed Critical Chat Module Errors**
  - Resolved "attempt to index local 'scroll' (a nil value)" error in the chat copy feature
  - Fixed "ADDON_ACTION_FORBIDDEN" error related to protected function calls
  - Implemented safer event handling with proper dependency checks
  - Enhanced error prevention to ensure stability during combat and high-load situations

- **Improved User Experience**
  - Added clearer visual indicators for copy functionality
  - Implemented helpful status messages when copy feature is enabled
  - Enhanced tooltip instructions for easier feature discovery
  - Fixed compatibility with all chat frame configurations and add-ons

- **Configuration Improvements**
  - Added proper initialization for UI components to ensure settings are preserved
  - Fixed issue where Phoenix_UI.UI.pendingChanges was incorrectly initialized
  - Ensured proper data types are used throughout the configuration system
  - Enhanced overall reliability of the settings framework

## Version 11.0.43 Updates

### Enhanced Castbar Features
- **Added Latency Indicator**
  - Shows your network latency on the player castbar
  - Displays both a visual indicator and precise ms value
  - Helps with timing spell casts and preventing clipping

- **Added Target Name Display**
  - Shows the name of your current target when casting spells
  - Names are colored by class for players and by reaction for NPCs
  - Provides immediate feedback about your spell target

- **Added Configuration Options**
  - Both features can be toggled on/off in the Castbars configuration panel
  - Settings are enabled by default but can be customized
  - All preferences are properly saved when changed

### Hotfix - API Updates
- **Fixed Player Stats Frame API Compatibility**
  - Resolved "attempt to call global 'UnitDebuff' (a nil value)" error in the stats frame
  - Updated code to use modern C_UnitAuras API instead of deprecated UnitDebuff function
  - Added backward compatibility for older WoW client versions
  - Maintained functionality for tracking Bloodlust/Heroism debuffs on all client versions

### Tooltip Gameplay Enhancements
- **Added Target of Target Information**
  - Shows the target's target in tooltip with proper class/reaction coloring
  - Indicates when target is targeting you with special highlighting

- **Added Role Indicator Icons**
  - Displays tank, healer, or DPS icons for player roles in group/raid content
  - Shows at the beginning of the tooltip for instant role recognition

- **Enhanced Aura Information**
  - Added detailed buff/debuff information:
    - Shows spell duration and time remaining in a readable format
    - Displays the name of the player or NPC who cast the aura
    - Shows aura classification (Magic/Curse/Disease/Poison) with appropriate coloring
  - Improves combat awareness by providing more complete information at a glance

- **Added Configuration Options**
  - All new tooltip features can be customized in the Tooltip section
  - Created easy toggle options for each enhancement
  - All features enabled by default but can be individually turned off

### Player Stats Frame Fixes
- **Fixed Backdrop and Frame Template Issues**
  - Resolved "attempt to call method 'SetBackdrop' (a nil value)" error in modern WoW clients
  - Implemented compatibility solution that works across all WoW API versions
  - Added proper BackdropTemplate usage with fallback mechanisms for older clients
  - Ensured proper resizing functionality without relying on unavailable methods

- **Fixed Stack Overflow in Stats Calculation**
  - Resolved "stack overflow" error caused by recursive function calls in the GetCritChance function
  - Fixed naming conflict between local function and WoW API function
  - Renamed local stats functions to avoid conflicts with WoW API
  - Implemented proper stats calculation with protection against infinite loops

- **Enhanced Stats Display Information**
  - Added raw numeric values alongside percentages for all player stats
  - Improved formatting to show "Rating (Percentage)" for all character stats
  - Enhanced readability with consistent formatting across all stats
  - Maintained proper color coding for different stat types

- **Improved Overall Stability**
  - Fixed dragging and resizing to save position and size reliably
  - Enhanced resize button functionality with proper constraints
  - Ensured proper database updates when modifying frame position or size
  - Added safety checks for database initialization

## Version 11.0.42 Updates

### Bug Fixes and Stability Improvements
- **Fixed RaidFrames Texture Issues**
  - Resolved heal prediction texture errors with comprehensive compatibility updates
  - Implemented robust texture fallback mechanisms to prevent UI errors
  - Enhanced texture handling across different WoW client versions
  - Added proper error handling with pcall to prevent crashes during frame updates

- **Fixed BuffOverlay Integration**
  - Improved event handling and registration to prevent conflicts
  - Resolved texture cache issues in the optimization function
  - Fixed comparison type errors in spell priority system
  - Updated version to match Phoenix_UI for better compatibility tracking

- **Enhanced Error Prevention**
  - Added protective wrapper code around texture application functions
  - Implemented default texture fallbacks to ensure UI consistency
  - Fixed border visibility handling for CompactPartyFrame
  - Improved overall addon stability during combat and high-stress situations