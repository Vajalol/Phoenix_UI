-- Register our pet sound
local petDiesSoundPath = [[Interface\AddOns\Phoenix_UI\Modules\SpellNotifications\sounds\buzz.ogg]]

function SpellNotifications_PlayPetDeathSound()
    if Phoenix_UI and Phoenix_UI.db and Phoenix_UI.db.profile and Phoenix_UI.db.profile.general and Phoenix_UI.db.profile.general.spellNotifications then
        PlaySoundFile(petDiesSoundPath, "Master")
    end
end 