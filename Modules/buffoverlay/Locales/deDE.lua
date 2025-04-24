---@class BuffOverlay: AceModule
local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")

-- Only proceed if this is the current locale
if (GAME_LOCALE or GetLocale()) ~= "deDE" then return end

-- Get the locale reference
local L = BuffOverlay.L

local GetSpellInfo = BuffOverlay.GetSpellInfo

L["%s %s is already being tracked."] = "%s %s wird bereits verfolgt."
L["%s %s: Resets current profile to default settings. This does not remove any custom auras."] = "%s %s: Setzt das aktuelle Profil auf die Standardeinstellungen zurück. Dies entfernt keine benutzerdefinierten Auren."
L["%s %s: Shows a copyable version string for bug reports."] = "%s %s: Zeigt eine kopierbare Versionszeichenfolge für Fehlerberichte an."
L["%s %s: Shows test icons on all visible raid/party frames."] = "%s %s: Zeigt Test-Symbole auf allen sichtbaren Raid/Gruppenrahmen an."
L["%s %s: Toggles the minimap icon."] = "%s %s: Aktiviert/Deaktiviert das Minimap-Symbol."
L["%s Frames need to be visible in order to see test icons. If you are using a non-Blizzard frame addon, you will need to make the frames visible either by joining a group or through that addon's settings."] = "%s Rahmen müssen sichtbar sein, um Testsymbole zu sehen. Wenn Sie ein Addon von Nicht-Blizzard-Rahmen verwenden, müssen Sie die Rahmen entweder durch Beitritt zu einer Gruppe oder über die Einstellungen dieses Addons sichtbar machen."
L["%s is already being tracked as a child of %s and cannot be edited."] = "%s wird bereits als Kind von %s verfolgt und kann nicht bearbeitet werden."
L["%s is already being tracked under %s %s."] = "%s wird bereits unter %s %s verfolgt."
L["%s or %s: Toggles the options panel."] = "%s oder %s: Schaltet das Optionsfeld um."
L["%s to toggle options window."] = "%s zum Umschalten des Optionsfensters."
L["%s to toggle test icons."] = "%s aktivieren/deaktivieren um Test-Symbole zu ändern."
L["%s to toggle the minimap icon."] = "%s zum Umschalten des Minikarten-Symbols."
L["%s%sCopy this version number and send it to the author if you need help with a bug."] = "%s%sKopieren Sie diese Versionsnummer und senden Sie sie dem Autor, wenn Sie bei einem Fehler Hilfe benötigen."
L["(%s: This is a default spell. Deleting it from this tab will simply reset all of its values to their defaults, but it will not be removed from the spells tab.)"] = "(%s: Dies ist ein Standardzauber. Wenn Sie ihn auf dieser Registerkarte löschen, werden alle seine Werte auf die Standardwerte zurückgesetzt, aber er wird nicht aus dem Zauberregister entfernt.)"
--[[Translation missing --]]
L["(Note: This will be automatically disabled if Masque is enabled for this bar.)"] = "(Note: This will be automatically disabled if Masque is enabled for this bar.)"
L["Action Button"] = "Aktionstaste"
L["Add %s to the custom spell list, opening up global settings to edit for this spell."] = "Fügen Sie %s zur benutzerdefinierten Wortliste hinzu, um die globalen Einstellungen zur Bearbeitung dieses Zaubers zu öffnen."
L["Add a child spell ID to this spell. Child IDs will be checked like normal IDs but will use all the same settings (including icon) as its parent. Also, any changes to the parent will apply to all of its children. This is useful for spells that have multiple ids which are convenient to track as a single spell (e.g. different ranks of the same spell)."] = "Fügen Sie einer Kind-Zauber-ID zu diesem Zauber hinzu. Kind-IDs werden wie normale IDs überprüft, aber alle gleichen Einstellungen (einschließlich Symbol) wie sein Elternteil verwenden. Auch werden alle Änderungen am Elternteil auf alle seine Kinder angewendet. Dies ist nützlich für Zauber, die mehrere IDs haben, die bequem als einzelner Zauber verfolgt werden können (z.B. verschiedene Ränge desselben Zaubers)."
L["Add an additional aura bar with default settings."] = "Fügen Sie eine zusätzliche Aura-Leiste mit Standardeinstellungen hinzu."
L["Add Bar"] = "Bar hinzufügen"
L["Add Child Spell ID"] = "Füge Kind Zauber-ID hinzu"
L["Adds a pixel border around the icon. This will also zoom the icon in slightly to remove any default borders that may be present."] = "Fügt dem Symbol einen Pixel-Rahmen hinzu. Dadurch wird das Symbol auch leicht vergrößert, um eventuell vorhandene Standardrahmen zu entfernen."
L["Anchoring"] = "Ankerung"
L["Apply %s's custom settings (glow, glow color, glow type, own only, etc) to all auras in %s.%sThis does not include any global settings (prio, class, etc)."] = "Fügen Sie %s's benutzerdefinierte Einstellungen (Glanz, Glanzfarbe, Glanztyp, nur eigene, usw.) allen Auren in %s hinzu.%sDies schließt keine globalen Einstellungen (Prio, Klasse, usw.) ein."
L["Apply to All"] = "Auf alle anwenden"
L["Are you sure you want to delete this bar?%s%s%s"] = "Sind Sie sicher, dass Sie diese Bar löschen möchten?%s%s%s"
L["Are you sure you want to delete this spell?"] = "Bist du sicher, dass du diesen Zauber löschen möchtest?"
L["Aura List"] = "Aura-Liste"
L["Author"] = "Autor"
L["Bars"] = "Balken"
L["BOTTOM"] = "Unten"
L["BOTTOMLEFT"] = "UNTENLINKS"
L["BOTTOMRIGHT"] = "UNTEN RECHTS"
L["CENTER"] = "Zentrieren"
L["Change the icon border color based on the dispel type of the buff. This overrides the icon border color."] = "Ändere die Symbolrahmenfarbe basierend auf dem Abwehrtyp des Buffs. Dies überschreibt die Symbolrahmenfarbe."
L["Change the icon border color based on the dispel type of the debuff. This overrides the icon border color."] = "Ändere die Symbolrahmenfarbe basierend auf dem Abwehrtyp des Debuffs. Dies überschreibt die Symbolrahmenfarbe."
L["Change the icon border color."] = "Ändere die Symbolrahmenfarbe."
L["Change the icon border size (in pixels)."] = "Ändern Sie die Icon-Rahmengröße (in Pixel)."
L["Change the icon group's X-Offset."] = "Ändere den X-Offset der Symbolgruppe."
L["Change the icon group's Y-Offset."] = "Ändere den Y-Offset der Symbolgruppe."
L["Child Spell ID(s)"] = "Kinder-Zauber-ID(s)"
L["Color Buff Icon Border by Dispel Type"] = "Farb-Puffer-Symbol-Rand durch Dispel-Typ"
L["Color Debuff Icon Border by Dispel Type"] = "Farb-Debuff-Symbolrahmen nach Art der Bannung"
L["Command List"] = "Befehlsliste"
L["Cooldown Spiral"] = "Abkühlspirale"
L["Cooldown Text Scale"] = "Abklingzeit Textskalierung"
L["Copied settings, anchoring, and visibility tabs from %s to %s"] = "Einstellungen, Ankerungen und Sichtbarkeitstabellen von %s nach %s kopiert"
L["Copied spells from %s to %s."] = "Kopierte Zauber von %s nach %s."
L["Copy Settings From"] = "Einstellungen kopieren von"
L["Copy Spells From"] = "Kopiere Zauber Von"
L["Corrupted buff database found. This is likely due to updating from an older version of Buff Overlay. Resetting buff database to default. Your other settings (including custom buffs) will be preserved."] = "Korrupte Buff-Datenbank gefunden. Dies ist wahrscheinlich aufgrund des Updates von einer älteren Version von Buff Overlay. Setzen der Buff-Datenbank auf Standard zurück. Ihre anderen Einstellungen (einschließlich benutzerdefinierter Buffs) bleiben erhalten."
--[[Translation missing --]]
L["Custom Glow Color"] = "Custom Glow Color"
L["Custom Icon"] = "Benutzerdefiniertes Symbol"
L["Custom Spells"] = "Benutzerdefinierte Zauber"
L["Delete Bar"] = "Bar löschen"
L["Disable all spells."] = "Alle Zauber deaktivieren."
L["DOWN"] = "Herunter"
L["Eating/Drinking"] = "Essen/Trinken"
L["Edit Global Settings"] = "Globale Einstellungen bearbeiten"
L["Enable a glow border effect around the icon."] = "Aktivieren Sie einen Glanzrahmen-Effekt um das Symbol."
L["Enable all spells."] = "Alle Zauber aktivieren."
L["Enabled Auras Priority List"] = "Aktivierte Auren Prioritätenliste"
L["Enter the spell ID of the spell you want to keep track of."] = "Geben Sie die Zauber-ID des Zaubers ein, den Sie verfolgen möchten."
L["Exiting test mode. Frame visibility will update out of combat."] = "Beenden des Testmodus. Rahmen-Sichtbarkeit wird außerhalb des Kampfes aktualisiert."
L["Frame Attachment Point"] = "Rahmenbefestigungspunkt"
L["Frame Types"] = "Rahmentypen"
L["Glow"] = "Leuchten"
L["Glow Type"] = "Glanztyp"
L["Group Size"] = "Gruppengröße"
L["Grow Direction"] = "Wachstumsrichtung"
L["HORIZONTAL"] = "HORIZONTAL --> HORIZONTAL"
L["Icon Alpha"] = "Icon Alpha"
L["Icon Anchor"] = "Symbolanker"
L["Icon Border"] = "Symbolrahmen"
L["Icon Border Color"] = "Icon-Rahmenfarbe"
L["Icon Border Size"] = "Symbolrahmengröße"
L["Icon Count"] = "Symbolzählung"
L["Icon position relative to its parent frame."] = "Icon-Position relativ zu seinem übergeordneten Rahmen."
L["Icon Scale"] = "Symbolgröße"
L["Icon Spacing"] = "Symbolabstand"
L["Icon transparency."] = "Ikonentransparenz."
--[[Translation missing --]]
L[ [=[In addition to adding new spells here, you can also add any Spell ID from the spells tab to edit its default values.
(Note: anything you add here will persist through addon updates and profile resets.)]=] ] = [=[In addition to adding new spells here, you can also add any Spell ID from the spells tab to edit its default values.
(Note: anything you add here will persist through addon updates and profile resets.)]=]
L["In order for %s setting to work in BuffOverlay, cooldown text needs to be enabled in Blizzard settings. You can find this setting located at:%s%s%sWould you like BuffOverlay to enable this setting for you?%s"] = "Damit die %s-Einstellung in BuffOverlay funktioniert, muss die Abklingzeit-Text in den Blizzard-Einstellungen aktiviert werden. Diese Einstellung finden Sie hier:%s%s%sMöchten Sie, dass BuffOverlay diese Einstellung für Sie aktiviert?%s"
L["Interface > ActionBars > Show Numbers for Cooldowns"] = "Schnellauslöser > Aktionsleisten > Nummern für Abklingzeiten anzeigen"
L["Invalid input for custom icon: %s"] = "Ungültige Eingabe für benutzerdefiniertes Symbol: %s"
L["Invalid Spell ID %s"] = "Ungültige Zauber-ID %s"
L["Invalid Spell: %s"] = "Ungültige Rechtschreibung: %s"
--[[Translation missing --]]
L["Keep in mind you want to add the Spell ID of the aura that appears on the buff/debuff bar, not necessarily the Spell ID from the spell book or talent tree."] = "Keep in mind you want to add the Spell ID of the aura that appears on the buff/debuff bar, not necessarily the Spell ID from the spell book or talent tree."
L["LEFT"] = "Links"
L["Left-click"] = "Linksklick"
--[[Translation missing --]]
L["Legacy Blizzard"] = "Legacy Blizzard"
L["Minimap Icon"] = "Minimap-Symbol"
L["Minimap icon is now hidden. Type %s %s to show it again."] = "Minimap-Symbol ist jetzt ausgeblendet. Geben Sie %s %s ein, um es erneut anzuzeigen."
L["Never Show"] = "Niemals Zeigen"
L["Never show this bar."] = "Diese Leiste niemals anzeigen."
L["Number of icons you want to display (per frame)."] = "Anzahl der Symbole, die Sie pro Rahmen anzeigen möchten."
L["Only show the aura if you cast it."] = "Nur die Aura anzeigen, wenn du sie wirkst."
L["Open Options"] = "Optionen öffnen"
L["Options > Gameplay > Action Bars > Show Numbers for Cooldowns"] = "Optionen > Spielmechanik > Aktionsleisten > Anzeige der Abklingzeiten"
L["Own"] = "Selbst"
L["Pixel"] = "Pixel"
L["Priority"] = "Priorität"
L["Priority (Lower is Higher Prio)"] = "Priorität (Niedriger ist höherer Prio)"
L["Priority must be a positive integer from 0 to 999999"] = "Priorität muss eine positive Ganzzahl von 0 bis 999999 sein."
L["Remove Custom Child Spell ID"] = "Benutzerdefiniertes Kind-Zauber-ID entfernen"
L["RIGHT"] = "Rechts"
L["Right-click"] = "Rechtsklicken"
L["Scale the icon's cooldown text size."] = "Skaliere die Abklingzeit-Textgröße des Symbols."
L["Scale the icon's stack count text size."] = "Skaliere die Textgröße der Symbolstapelzählung."
L["Scale the size of the icon. Base icon size is proportionate to its parent frame."] = "Skaliere die Größe des Symbols. Die Grundsymbolgröße ist proportional zu seinem übergeordneten Rahmen."
L["Set Bar Name"] = "Setze Bar Namen"
L["Shift+Right-click"] = "Shift+Rechtsklick"
L["Show a test overlay for %s"] = "Zeige ein Testüberlagerung für %s"
L["Show Blizzard Cooldown Text"] = "Zeige Blizzard Abklingzeittext"
L["Show In Arena"] = "Zeige in Arena"
L["Show In Battleground"] = "Zeige im Schlachtfeld"
L["Show In Dungeon"] = "Zeige im Dungeon"
L["Show In Raid"] = "Zeige im Raid"
L["Show In Scenario"] = "Zeige im Szenario"
--[[Translation missing --]]
L["Show overlays on this frame type."] = "Show overlays on this frame type."
--[[Translation missing --]]
L[ [=[Show overlays on this frame type.

Blizzard frames do not currently support separate types.]=] ] = [=[Show overlays on this frame type.

Blizzard frames do not currently support separate types.]=]
L["Show Stack Count"] = "Zeige Stack-Anzahl"
L["Show test overlays for this bar."] = "Zeige Test-Overlays für diese Bar."
--[[Translation missing --]]
L[ [=[Show this bar when the group size is equal to or greater than this value.

0=Solo with no group.
1=Solo in a group.]=] ] = [=[Show this bar when the group size is equal to or greater than this value.

0=Solo with no group.
1=Solo in a group.]=]
--[[Translation missing --]]
L[ [=[Show this bar when the group size is equal to or less than this value.

0=Solo with no group.
1=Solo in a group.]=] ] = [=[Show this bar when the group size is equal to or less than this value.

0=Solo with no group.
1=Solo in a group.]=]
L["Show Tooltip On Hover"] = "Zeige Tooltip beim Überfahren"
L["Show When Non-Instanced"] = "Zeige, wenn nicht instanziert"
L["Shows a list of all enabled auras for this bar in order of priority."] = "Zeigt eine Liste aller aktivierten Auren für diese Leiste in Prioritätsreihenfolge an."
L["Spacing between icons. Spacing is scaled based on icon size for uniformity across different icon sizes."] = "Abstand zwischen Symbolen. Der Abstand wird anhand der Symboldimensionen skaliert, um eine einheitliche Darstellung bei unterschiedlichen Symboldimensionen zu gewährleisten."
L["Spell ID"] = "Zauber-ID"
L["Spell ID %s is invalid and has been removed."] = "ID %s des Zaubers ist ungültig und wurde entfernt."
L["Spell ID %s is invalid. If you haven't made any manual code changes, please report this to the author."] = "Spell ID %s ist ungültig. Wenn Sie keine manuellen Code-Änderungen vorgenommen haben, melden Sie dies bitte dem Autor."
L["Spell ID must be a positive integer from 0 to 9999999"] = "Spell ID muss eine positive Ganzzahl von 0 bis 9999999 sein."
L["Stack Count Scale"] = "Stapelzählungskala"
L["Test"] = "Testen"
L["Test All"] = "Alle testen"
L["Test Aura"] = "Teste Aura"
L["Test Bar"] = "Testleiste"
L["The icon ID to use for this spell. This will overwrite the default icon."] = "Die Icon-ID, die für diesen Zauber verwendet werden soll. Dies überschreibt das Standard-Icon."
L["The priority of this spell. Lower numbers are higher priority. If two spells have the same priority, it will show alphabetically."] = "Die Priorität dieses Zaubers. Niedrigere Zahlen haben eine höhere Priorität. Wenn zwei Zauber die gleiche Priorität haben, wird alphabetisch angezeigt."
L["There has been a major update and unfortunately your profiles need to be reset. Upside though, you can now add BuffOverlay aura bars in multiple locations on your frames! Check it out by typing %s in chat."] = "Es gab ein großes Update und leider müssen Ihre Profile zurückgesetzt werden. Aber es gibt auch einen positiven Aspekt: Sie können jetzt BuffOverlay-Auren in mehreren Positionen auf Ihren Rahmen hinzufügen! Probieren Sie es aus, indem Sie %s im Chat eingeben."
L["This copies settings from 'Settings', 'Anchoring', and 'Visibility' tabs."] = "Dies kopiert Einstellungen aus den Registerkarten 'Einstellungen', 'Anker' und 'Sichtbarkeit'."
L["This informational panel is the full list of spells currently enabled for %s in order of priority. Any aura changes made while this panel is open will be reflected here in real time."] = "Dieses Informationspanel ist die vollständige Liste der derzeit für %s aktivierten Zauber in Prioritätsreihenfolge. Alle Änderungen an Auren, die während dieses Panels geöffnet sind, werden hier in Echtzeit widergespiegelt."
L["Toggle showing of the cooldown spiral."] = "Zeige die Abklingzeitspirale an/aus schalten."
L["Toggle showing of the cooldown text."] = "Zeige Cooldown-Text an-/ausschalten."
L["Toggle showing of the stack count text on the icon."] = "Zeige den Stack-Zähler-Text auf dem Symbol an/aus."
L["Toggle showing of the tooltip when hovering over an icon."] = "Zeige den Tooltip beim Überfahren eines Symbols an/aus."
L["Toggle showing of the welcome message on login."] = "Zeige die Willkommensnachricht beim Anmelden an/aus."
L["Toggle showing this bar in a battleground."] = "Zeige diese Leiste in einem Schlachtfeld an/aus."
L["Toggle showing this bar in a dungeon instance."] = "Zeige diese Leiste in einer Dungeon-Instanz an-/ausschalten."
L["Toggle showing this bar in a raid instance."] = "Zeige diese Leiste in einer Raid-Instanz an/aus schalten."
L["Toggle showing this bar in a scenario."] = "Zeige diese Leiste in einem Szenario an/aus."
L["Toggle showing this bar in an arena."] = "Zeige diese Leiste in einer Arena an-/ausschalten."
L["Toggle showing this bar in the world/outside of instances."] = "Zeige diese Leiste in der Welt/außerhalb von Instanzen an/aus."
L["Toggle test overlays for all bars."] = "Alle Balken auf Test-Overlays umschalten."
L["Toggle the minimap icon."] = "Minimap-Symbol umschalten."
--[[Translation missing --]]
L["Toggle whether or not to use a custom color for glow."] = "Toggle whether or not to use a custom color for glow."
L["TOP"] = "Oben"
L["TOPLEFT"] = "OBENLINKS"
L["TOPRIGHT"] = "OBENRECHTS"
L["Type %s or %s to open the options panel or %s for more commands."] = "Geben Sie %s oder %s ein, um das Optionsfeld zu öffnen oder %s für weitere Befehle."
L["UP"] = "Hoch"
L["VERTICAL"] = "VERTIKAL"
L["Visibility"] = "Sichtbarkeit"
L["Welcome Message"] = "Willkommen Nachricht"
L["Where the anchor is on the icon."] = "Wo der Anker auf dem Symbol ist."
L["Where the icons will grow from the first icon."] = "Wo die Symbole vom ersten Symbol wachsen werden."
L["X-Offset"] = "X-Versatz"
L["Y-Offset"] = "Y-Versatz"




