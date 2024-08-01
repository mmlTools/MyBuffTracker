local MyBuffTracker = _G.MyBuffTracker

function MyBuffTracker:ShowProfileManager()
    if not self.profileManagerFrame then
        self.profileManagerFrame = CreateFrame("Frame", "MyBuffTrackerProfileManager", UIParent, "BasicFrameTemplateWithInset")
        self.profileManagerFrame:SetSize(300, 400)
        self.profileManagerFrame:SetPoint("CENTER", UIParent, "CENTER")
        
        local title = self.profileManagerFrame:CreateFontString(nil, "OVERLAY")
        title:SetFontObject("GameFontHighlight")
        title:SetPoint("LEFT", self.profileManagerFrame.TitleBg, "LEFT", 5, 0)
        title:SetText("Profile Manager")

        local scrollFrame = CreateFrame("ScrollFrame", "MyBuffTrackerProfileScrollFrame", self.profileManagerFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(280, 300)
        scrollFrame:SetPoint("TOPLEFT", self.profileManagerFrame, "TOPLEFT", 10, -40)

        local contentFrame = CreateFrame("Frame", nil, scrollFrame)
        contentFrame:SetSize(260, 1)  
        scrollFrame:SetScrollChild(contentFrame)

        local addProfileButton = CreateFrame("Button", nil, self.profileManagerFrame, "UIPanelButtonTemplate")
        addProfileButton:SetSize(100, 30)
        addProfileButton:SetText("Add Profile")
        addProfileButton:SetPoint("BOTTOMLEFT", self.profileManagerFrame, "BOTTOMLEFT", 10, 10)
        addProfileButton:SetScript("OnClick", function()
            self:OpenProfileEditDialog("Create")
        end)

        local deleteProfileButton = CreateFrame("Button", nil, self.profileManagerFrame, "UIPanelButtonTemplate")
        deleteProfileButton:SetSize(100, 30)
        deleteProfileButton:SetText("Delete Profile")
        deleteProfileButton:SetPoint("BOTTOMRIGHT", self.profileManagerFrame, "BOTTOMRIGHT", -10, 10)
        deleteProfileButton:SetScript("OnClick", function()
            self:DeleteProfile(self.currentProfile)
            self:UpdateProfileList(contentFrame)
        end)

        local renameProfileButton = CreateFrame("Button", nil, self.profileManagerFrame, "UIPanelButtonTemplate")
        renameProfileButton:SetSize(100, 30)
        renameProfileButton:SetText("Rename Profile")
        renameProfileButton:SetPoint("BOTTOM", self.profileManagerFrame, "BOTTOM", 0, 10)
        renameProfileButton:SetScript("OnClick", function()
            self:OpenProfileEditDialog("Rename")
        end)

        self.profileManagerFrame.contentFrame = contentFrame
        self:UpdateProfileList(contentFrame)
    end

    self.profileManagerFrame:Show()
end

function MyBuffTracker:UpdateProfileList(contentFrame)
    for _, button in ipairs(contentFrame.buttons or {}) do
        button:Hide()
    end

    contentFrame.buttons = {}

    local yOffset = 0
    for profileName, _ in pairs(self.profiles) do
        local button = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
        button:SetSize(240, 30)
        button:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -yOffset)
        button:SetText(profileName)
        button:SetScript("OnClick", function()
            self:SetProfile(profileName)
            print("Switched to profile:", profileName)
            self:UpdateProfileList(contentFrame)
        end)
        yOffset = yOffset + 35
        table.insert(contentFrame.buttons, button)
    end

    contentFrame:SetHeight(yOffset)
end

function MyBuffTracker:OpenProfileEditDialog(action, oldProfileName)
    local dialog = CreateFrame("Frame", "MyBuffTrackerProfileEditDialog", UIParent, "DialogBoxFrame")
    dialog:SetSize(300, 120)
    dialog:SetPoint("CENTER", UIParent, "CENTER")
    
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", dialog, "TOP", 0, -10)
    title:SetText(action .. " Profile")

    local nameInput = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    nameInput:SetSize(200, 30)
    nameInput:SetPoint("TOP", title, "BOTTOM", 0, -10)
    nameInput:SetText(oldProfileName or "")
    
    local okButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    okButton:SetSize(100, 30)
    okButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 10, 10)
    okButton:SetText("OK")
    okButton:SetScript("OnClick", function()
        local profileName = nameInput:GetText():trim()
        if action == "Create" then
            self:CreateProfile(profileName)
        elseif action == "Rename" and oldProfileName then
            self:RenameProfile(oldProfileName, profileName)
        end
        dialog:Hide()
        self:UpdateProfileList(self.profileManagerFrame.contentFrame)
    end)

    local cancelButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelButton:SetSize(100, 30)
    cancelButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -10, 10)
    cancelButton:SetText("Cancel")
    cancelButton:SetScript("OnClick", function()
        dialog:Hide()
    end)

    dialog:Show()
end

function MyBuffTracker:CreateProfile(profileName)
    if profileName and not self.profiles[profileName] then
        self.profiles[profileName] = { buffs = {} }
        self:SetProfile(profileName)
        self:SaveCurrentProfile()
        print("Profile created:", profileName)
    else
        print("Profile already exists or invalid name.")
    end
end

function MyBuffTracker:DeleteProfile(profileName)
    if self.profiles[profileName] and profileName ~= self.currentProfile then
        self.profiles[profileName] = nil
        if profileName == self.currentProfile then
            self:SetProfile("Default")
        end
        self:SaveCurrentProfile()
        print("Profile deleted:", profileName)
    else
        print("Cannot delete current profile or profile does not exist.")
    end
end

function MyBuffTracker:RenameProfile(oldName, newName)
    if self.profiles[oldName] and not self.profiles[newName] and oldName ~= newName then
        self.profiles[newName] = self.profiles[oldName]
        self.profiles[oldName] = nil
        if self.currentProfile == oldName then
            self:SetProfile(newName)
        end
        self:SaveCurrentProfile()
        print("Profile renamed from", oldName, "to", newName)
    else
        print("Rename failed. Profile may already exist or invalid names.")
    end
end
