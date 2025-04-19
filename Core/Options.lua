local addonName = ...
local AceAddon        = LibStub("AceAddon-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

---@class VoicePlus: AceAddon
local VoicePlus = AceAddon:NewAddon(addonName)
_G.BigWigs_VoicePlus = VoicePlus

VoicePlus.optionOrder = 0
VoicePlus.colour      = "fff78c"

function VoicePlus:GetVoicePack()
    return self.db.voicePack
end

function VoicePlus:SetVoicePack(info, value)
    self.db.voicePack = value
    StaticPopup_Show("VOICEPLUS_RELOAD")
end

function VoicePlus:GetSoundChannel()
    return self.db.soundChannel or "Master"
end

function VoicePlus:SetSoundChannel(info, value)
    self.db.soundChannel = value
    StaticPopup_Show("VOICEPLUS_RELOAD")
end

function VoicePlus:IncrementAndFetchOptionOrder()
    self.optionOrder = self.optionOrder + 1
    return self.optionOrder
end

function VoicePlus:ColourText(text)
    return "|cff" .. self.colour .. text .. "|r"
end

function VoicePlus:CreateOptionsPanel()
    local prettyName = "BigWigs - Voice+"

    local options = {
        name    = prettyName,
        handler = VoicePlus,
        type    = "group",
        args    = {
            configHeader = {
                order = self:IncrementAndFetchOptionOrder(),
                type  = "header",
                name  = "Config",
            },
            spacer1 = {
                order = self:IncrementAndFetchOptionOrder(),
                type  = "description",
                name  = " ",
                width = "full",
            },
            desc = {
                order    = self:IncrementAndFetchOptionOrder(),
                type     = "description",
                name     = "Select your preferred voice pack.",
                fontSize = "medium",
                width    = "full",
            },
            voicePack = {
                order   = self:IncrementAndFetchOptionOrder(),
                type    = "select",
                name    = "Voice Pack",
                desc    = "Choose which voice pack to use.",
                values  = { Nova = "Nova", Sage = "Sage" },
                sorting = { "Nova", "Sage" },
                get     = "GetVoicePack",
                set     = "SetVoicePack",
                width   = "normal",
            },
            spacerBetweenSelectors = {
                order = self:IncrementAndFetchOptionOrder(),
                type  = "description",
                name  = " ",
                width = "full",
            },
            soundChannel = {
                order   = self:IncrementAndFetchOptionOrder(),
                type    = "select",
                name    = "Sound Channel",
                desc    = "Choose which sound channel to play the voice alerts through.",
                values  = {
                    Master = "Master",
                    Dialog = "Dialog",
                    SFX = "Sound Effects",
                    Ambience = "Ambience",
                    Music = "Music",
                },
                sorting = { "Master", "Dialog", "SFX", "Ambience", "Music" },
                get     = "GetSoundChannel",
                set     = "SetSoundChannel",
                width   = "normal",
            },
            spacer2 = {
                order = self:IncrementAndFetchOptionOrder(),
                type  = "description",
                name  = " ",
                width = "full",
            },
            descHeader = {
                order = self:IncrementAndFetchOptionOrder(),
                type  = "header",
                name  = "Help",
            },
            spacer3 = {
                order = self:IncrementAndFetchOptionOrder(),
                type  = "description",
                name  = " ",
                width = "full",
            },
            novaDesc = {
                order    = self:IncrementAndFetchOptionOrder(),
                type     = "description",
                name     = self:ColourText("Nova") .. ": Direct and focused — designed to shout ability names clearly in high-intensity moments.",
                fontSize = "medium",
                width    = "full",
            },
            sageDesc = {
                order    = self:IncrementAndFetchOptionOrder(),
                type     = "description",
                name     = self:ColourText("Sage") .. ": Calm and narrative — more natural phrasing, ideal if you prefer immersion or a softer tone.",
                fontSize = "medium",
                width    = "full",
            },
            howTo = {
                order    = self:IncrementAndFetchOptionOrder(),
                type     = "description",
                name     = "\nVoice alerts are played through the audio channel selected above — adjust the volume in Game Settings > System > Audio",
                fontSize = "small",
                width    = "full",
            },
        },
    }

    AceConfigRegistry:RegisterOptionsTable(prettyName, options)
    local panel = AceConfigDialog:AddToBlizOptions(prettyName)

    panel:HookScript("OnShow", function(self)
        if self._voiceplusLogo then return end
        local tex = self:CreateTexture(nil, "ARTWORK")
        tex:SetTexture("Interface\\AddOns\\BigWigs_VoicePlus\\Icon\\logo.png")
        tex:SetSize(128, 128)
        tex:SetPoint("BOTTOM", self, "BOTTOM", 0, 30)
        tex:SetTexCoord(0, 1, 0, 1)
        self._voiceplusLogo = tex
    end)
end

function VoicePlus:OnInitialize()
    BigWigs_VoicePlusSV = BigWigs_VoicePlusSV or {}
    local db = BigWigs_VoicePlusSV
    if type(db.voicePack) ~= "string" or (db.voicePack ~= "Nova" and db.voicePack ~= "Sage") then
        db.voicePack = "Nova"
    end
    self.db = db

    StaticPopupDialogs["VOICEPLUS_RELOAD"] = {
        text         = "Voice+ config changed.\nReload the UI now?",
        button1      = RELOADUI,
        button2      = CANCEL,
        OnAccept     = ReloadUI,
        timeout      = 0,
        whileDead    = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER")
        end,
    }

    self:CreateOptionsPanel()
end
