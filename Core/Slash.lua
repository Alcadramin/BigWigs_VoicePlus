local name, addon = ...

SLASH_VOICEPLUS1 = "/voiceplus"
SlashCmdList["VOICEPLUS"] = function(msg)
  local cmd, arg = msg:match("^(%S*)%s*(.-)$")
  if cmd:lower() == "play" and arg ~= "" then
    local id   = tostring(arg)
    local pack = BigWigs_VoicePlusSV.voicePack or "Nova"
    local file = ("Interface\\AddOns\\BigWigs_VoicePlus\\Sounds\\%s\\%s.ogg"):format(pack, id)
    if PlaySoundFile(file, "Dialog") then
      DEFAULT_CHAT_FRAME:AddMessage("VoicePlus: Playing voice for " .. id)
    else
      DEFAULT_CHAT_FRAME:AddMessage("VoicePlus: No voice found for " .. id)
    end
  else
    Settings.OpenToCategory("BigWigs - Voice+")
  end
end
