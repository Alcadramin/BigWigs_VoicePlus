local name, addon = ...

--------------------------------------------------------------------------------
-- Locals
--

local tostring = tostring
local format = format
addon.SendMessage = BigWigsLoader.SendMessage

--------------------------------------------------------------------------------
-- Event Handlers
--

local path = "Interface\\AddOns\\BigWigs_VoicePlus\\sounds\\%s.ogg"
local pathYou = "Interface\\AddOns\\BigWigs_VoicePlus\\sounds\\%sy.ogg"

local function handler(event, module, key, sound, isOnMe)
    local success = PlaySoundFile(format(isOnMe and pathYou or path, tostring(key)), "Master")
    if not success then
        addon:SendMessage("BigWigs_Sound", module, key, sound)
    end
end

BigWigsLoader.RegisterMessage(addon, "BigWigs_VoicePlus", handler)
BigWigsAPI.RegisterVoicePack("VoicePlus")

--------------------------------------------------------------------------------
-- Slash Command: /voiceplus play SPELL_NAME
--

SLASH_VOICEPLUS1 = "/voiceplus"
SlashCmdList["VOICEPLUS"] = function(msg)
    -- Parse the command and its arguments from the input text.
    local command, spell = msg:match("^(%S+)%s*(.-)%s*$")
    if command and command:lower() == "play" and spell and spell ~= "" then
        local spellName = spell:upper()
        local filePath = format("Interface\\AddOns\\BigWigs_VoicePlus\\sounds\\%s.ogg", spellName)
        if FileExists(filePath) then
            PlaySoundFile(filePath, "Master")
            print("Playing voice for " .. spellName)
        else
            print("Voice for " .. spellName .. " not found.")
        end
    else
        print("Usage: /voiceplus play SPELL_NAME")
    end
end
