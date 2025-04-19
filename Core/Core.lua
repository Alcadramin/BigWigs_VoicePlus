local name, addon = ...

--------------------------------------------------------------------------------
-- SavedVariables & Default Pack
--
BigWigs_VoicePlusSV = BigWigs_VoicePlusSV or {}
local db = BigWigs_VoicePlusSV

if type(db.voicePack) ~= "string" then
    db.voicePack = "Nova"
end
if type(db.soundChannel) ~= "string" or db.soundChannel == "" then
    db.soundChannel = "Master"
end

--------------------------------------------------------------------------------
-- BigWigs Registration & Handler
--

addon.SendMessage = BigWigsLoader.SendMessage

local DEFAULT_VOICE_PACK = "Nova"
local DEFAULT_SOUND_CHANNEL = "Master"

local function handler(event, module, key, sound, isOnMe)
    local currentVoicePack = (type(db.voicePack) == "string" and db.voicePack ~= "") and db.voicePack or DEFAULT_VOICE_PACK
    local soundChannel = (type(db.soundChannel) == "string" and db.soundChannel ~= "") and db.soundChannel or DEFAULT_SOUND_CHANNEL

    local fileFormat = isOnMe and
        "Interface\\AddOns\\BigWigs_VoicePlus\\Sounds\\%s\\%sy.ogg" or
        "Interface\\AddOns\\BigWigs_VoicePlus\\Sounds\\%s\\%s.ogg"
    local file = string.format(fileFormat, currentVoicePack, tostring(key))

    if not PlaySoundFile(file, soundChannel) then
        addon:SendMessage("BigWigs_Sound", module, key, sound)
    end
end

BigWigsLoader.RegisterMessage(addon, "BigWigs_Voice", handler)
BigWigsAPI.RegisterVoicePack("VoicePlus")
