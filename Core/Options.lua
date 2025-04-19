local addonName = ...

BigWigs_VoicePlusSV          = BigWigs_VoicePlusSV or {}
local sv                     = BigWigs_VoicePlusSV
sv.voicePack                 = sv.voicePack or "Nova"

local function AddSectionHeader(category, label)
    local varName = addonName:upper() .. "_HDR_" .. label:gsub("%s+", "_"):upper()

    local dummy = Settings.RegisterProxySetting(
        category, varName,
        Settings.VarType.Boolean,
        label,
        Settings.Default.False,
        function() return false end)

    local init = Settings.CreateControlInitializer(
        "SettingsListSectionHeaderTemplate",
        dummy)

    SettingsPanel:GetLayout(category):AddInitializer(init)
end

local function BuildOptions()
    local category = Settings.RegisterVerticalLayoutCategory("BigWigs - Voice+")

    AddSectionHeader(category, "Config")

    local SETTING_KEY = "VoicePlus_VoicePack"
    local setting = Settings.RegisterAddOnSetting(
        category, SETTING_KEY,
        SETTING_KEY, sv,
        Settings.VarType.String,
        "Voice Pack",
        sv.voicePack)

    setting:SetValueChangedCallback(function(_, value)
        if sv.voicePack ~= value then
            sv.voicePack = value
            C_Timer.After(0, ReloadUI)
        end
    end)

    local function GetVoicePackOptions()
        local c = Settings.CreateControlTextContainer()
        c:Add("Nova", "Nova")
        c:Add("Sage", "Sage")
        return c:GetData()
    end

    Settings.CreateDropdown(category, setting, GetVoicePackOptions,
                            "Select which voice pack to use.")

    Settings.RegisterAddOnCategory(category)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, evt, name)
    if evt == "ADDON_LOADED" and name == addonName then
        BuildOptions()
        frame:UnregisterEvent("ADDON_LOADED")
    end
end)
