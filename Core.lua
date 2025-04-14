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

local path = "Interface\\AddOns\\BigWigs_VoicePlus\\Sounds\\%s.ogg"
local pathYou = "Interface\\AddOns\\BigWigs_VoicePlus\\Sounds\\%sy.ogg"

local function handler(event, module, key, sound, isOnMe)
    local success = PlaySoundFile(format(isOnMe and pathYou or path, tostring(key)), "Master")
    if not success then
        addon:SendMessage("BigWigs_Sound", module, key, sound)
    end
end

BigWigsLoader.RegisterMessage(addon, "BigWigs_VoicePlus", handler)
BigWigsAPI.RegisterVoicePack("temp")

--------------------------------------------------------------------------------
-- Slash Command: /voiceplus SPELL_ID
--

SLASH_VOICEPLUS1 = "/voiceplus"
SlashCmdList["VOICEPLUS"] = function(msg)
    local trimmed = msg and msg:match("^%s*(.-)%s*$") or ""
    if trimmed == "" then
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /voiceplus SPELL_ID")
        return
    end

    local spell = trimmed:match("^(%S+)")
    if not spell then
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /voiceplus SPELL_ID")
        return
    end

    local filePath = format("Interface\\AddOns\\BigWigs_VoicePlus\\Sounds\\%s.ogg", spell)

    local played = PlaySoundFile(filePath, "Master")
    if played then
        DEFAULT_CHAT_FRAME:AddMessage("VoicePlus: Playing voice for " .. spell)
    else
        DEFAULT_CHAT_FRAME:AddMessage("VoicePlus: Failed to play voice for " .. spell)
    end
end
