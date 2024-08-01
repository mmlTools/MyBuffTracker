local MyBuffTracker = {}

MyBuffTracker.defaultBuffs = {
    "Power Word: Fortitude",
    "Arcane Intellect"
}

MyBuffTracker.profiles = MyBuffTracker.profiles or {}
MyBuffTracker.currentProfile = "Default"

function MyBuffTracker:LoadSavedVariables()
    if not MyBuffTrackerDB then
        MyBuffTrackerDB = { profiles = {}, currentProfile = "Default" }
    end

    self.profiles = MyBuffTrackerDB.profiles
    self.currentProfile = MyBuffTrackerDB.currentProfile

    if not self.profiles[self.currentProfile] then
        self.profiles[self.currentProfile] = { buffs = self.defaultBuffs }
    end
end

function MyBuffTracker:SaveCurrentProfile()
    MyBuffTrackerDB.currentProfile = self.currentProfile
end

function MyBuffTracker:SetProfile(profileName)
    if self.profiles[profileName] then
        self.currentProfile = profileName
        self:SaveCurrentProfile()
        self:UpdateBuffs()
    else
        print("Profile does not exist.")
    end
end

function MyBuffTracker:InitializeFrame()
    if not self.frame then
        self.frame = CreateFrame("Frame", "MyBuffTrackerFrame", UIParent)
        self.frame:SetSize(300, 50)
        self.frame:SetPoint("CENTER", UIParent, "CENTER")

        self.frame.bg = self.frame:CreateTexture(nil, "BACKGROUND")
        self.frame.bg:SetAllPoints(true)
        self.frame.bg:SetColorTexture(0, 0, 0, 0.5)

        self.trackedIcons = {}
    end
end

function MyBuffTracker:UpdateBuffs()
    self:InitializeFrame()

    for _, icon in ipairs(self.trackedIcons) do
        icon:Hide()
    end
    self.trackedIcons = {}

    local lastIcon = nil
    local xOffset, yOffset = 10, 0
    local iconSize, spacing = 32, 5

    for i, buffName in ipairs(self.profiles[self.currentProfile].buffs) do
        local icon = CreateFrame("Button", nil, self.frame)
        icon:SetSize(iconSize, iconSize)
        icon:SetNormalTexture("Interface/Icons/INV_Misc_QuestionMark")
        icon:SetPoint("TOPLEFT", self.frame, "TOPLEFT", xOffset, -yOffset)
        icon.buffName = buffName

        icon:SetScript("OnClick", function(self)
            local buffName = self.buffName
            local canCast, spellName = MyBuffTracker:IsBuffCastable(buffName)
            if canCast then
                CastSpellByName(spellName, "player")
            else
                SendChatMessage("Missing " .. buffName .. ", please cast " .. buffName .. " on " .. UnitName("player") .. "!", "YELL")
            end
        end)

        table.insert(self.trackedIcons, icon)

        if lastIcon then
            icon:SetPoint("LEFT", lastIcon, "RIGHT", spacing, 0)
        else
            icon:SetPoint("TOPLEFT", self.frame, "TOPLEFT", xOffset, -yOffset)
        end
        lastIcon = icon

        if i % 10 == 0 then
            xOffset = 10
            yOffset = yOffset + iconSize + spacing
        end
    end

    self:UpdateBuffIcons()
end

function MyBuffTracker:UpdateBuffIcons()
    for i, icon in ipairs(self.trackedIcons) do
        local buffName = icon.buffName
        local found = false
        for j = 1, 40 do
            local name, _, iconTexture, _, _, expirationTime = UnitBuff("player", j)
            if not name then break end
            if name == buffName then
                found = true
                icon:SetNormalTexture(iconTexture)
                icon.cooldown:SetCooldown(GetTime(), expirationTime - GetTime())
                icon.cooldown:Show()
                icon.pulse:Stop()
                break
            end
        end

        if not found then
            icon:SetNormalTexture("Interface/Icons/INV_Misc_QuestionMark")
            icon.cooldown:Hide()
            icon.pulse:Play()
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "MyBuffTracker" then
        MyBuffTracker:LoadSavedVariables()
        MyBuffTracker:UpdateBuffs()
    end
end)

_G.MyBuffTracker = MyBuffTracker