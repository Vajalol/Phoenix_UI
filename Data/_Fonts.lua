local Fonts = Phoenix_UI:NewModule('Data.Fonts');
local LSM = LibStub("LibSharedMedia-3.0")

local LSM_StatusBarFontsList = LSM:List('font')
local LSM_StatusBarFontsHash = LSM:HashTable('font')

local LSM_Fonts = Phoenix_UI:LSB_Helper(LSM_StatusBarFontsList, LSM_StatusBarFontsHash)

Fonts.data = LSM_Fonts



