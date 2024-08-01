local MyBuffTracker = _G.MyBuffTracker

function MyBuffTracker:AddBuffToProfile(buffName)
    if self.currentProfile and self.profiles[self.currentProfile] then
        for _, buff in ipairs(self.profiles[self.currentProfile].buffs) do
            if buff == buffName then
                print("Buff already exists in the profile:", buffName)
                return
            end
        end

        table.insert(self.profiles[self.currentProfile].buffs, buffName)
        self:SaveCurrentProfile()
        print("Added buff to profile:", buffName)
    else
        print("No profile selected.")
    end
end

function MyBuffTracker:RemoveBuffFromProfile(buffName)
    if self.currentProfile and self.profiles[self.currentProfile] then
        for i, buff in ipairs(self.profiles[self.currentProfile].buffs) do
            if buff == buffName then
                table.remove(self.profiles[self.currentProfile].buffs, i)
                self:SaveCurrentProfile()
                print("Removed buff from profile:", buffName)
                return
            end
        end
        print("Buff not found in the profile:", buffName)
    else
        print("No profile selected.")
    end
end

function MyBuffTracker:ShowBuffManager()
    if not self.buffManagerFrame then
        self.buffManagerFrame = CreateFrame("Frame", "MyBuffTrackerBuffManager", UIParent, "BasicFrameTemplateWithInset")
        self.buffManagerFrame:SetSize(300, 400)
        self.buffManagerFrame:SetPoint("CENTER", UIParent, "CENTER")

        local title = self.buffManagerFrame:CreateFontString(nil, "OVERLAY")
        title:SetFontObject("GameFontHighlight")
        title:SetPoint("LEFT", self.buffManagerFrame.TitleBg, "LEFT", 5, 0)
        title:SetText("Buff Manager")

        local scrollFrame = CreateFrame("ScrollFrame", "MyBuffTrackerBuffScrollFrame", self.buffManagerFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(280, 280)
        scrollFrame:SetPoint("TOPLEFT", self.buffManagerFrame, "TOPLEFT", 10, -40)

        local contentFrame = CreateFrame("Frame", nil, scrollFrame)
        contentFrame:SetSize(260, 1)  
        scrollFrame:SetScrollChild(contentFrame)

        local addBuffInput = CreateFrame("EditBox", nil, self.buffManagerFrame, "InputBoxTemplate")
        addBuffInput:SetSize(200, 30)
        addBuffInput:SetPoint("TOP", title, "BOTTOM", 0, -10)

        local addBuffButton = CreateFrame("Button", nil, self.buffManagerFrame, "UIPanelButtonTemplate")
        addBuffButton:SetSize(100, 30)
        addBuffButton:SetText("Add Buff")
        addBuffButton:SetPoint("TOP", addBuffInput, "BOTTOM", 0, -10)
        addBuffButton:SetScript("OnClick", function()
            local buffName = addBuffInput:GetText():trim()
            if buffName ~= "" then
                self:AddBuffToProfile(buffName)
                self:UpdateBuffList(contentFrame)
                addBuffInput:SetText("")
            else
                print("Please enter a valid buff name.")
            end
        end)

        local removeBuffButton = CreateFrame("Button", nil, self.buffManagerFrame, "UIPanelButtonTemplate")
        removeBuffButton:SetSize(100, 30)
        removeBuffButton:SetText("Remove Buff")
        removeBuffButton:SetPoint("TOP", addBuffButton, "BOTTOM", 0, -10)
        removeBuffButton:SetScript("OnClick", function()
            local selectedBuff = self.selectedBuff
            if selectedBuff then
                self:RemoveBuffFromProfile(selectedBuff)
                self:UpdateBuffList(contentFrame)
                self.selectedBuff = nil
            else
                print("No buff selected.")
            end
        end)

        local closeButton = CreateFrame("Button", nil, self.buffManagerFrame, "UIPanelButtonTemplate")
        closeButton:SetSize(100, 30)
        closeButton:SetText("Close")
        closeButton:SetPoint("BOTTOM", self.buffManagerFrame, "BOTTOM", 0, 10)
        closeButton:SetScript("OnClick", function()
            self.buffManagerFrame:Hide()
        end)

        self.buffManagerFrame.contentFrame = contentFrame
        self:UpdateBuffList(contentFrame)
    end

    self.buffManagerFrame:Show()
end

function MyBuffTracker:UpdateBuffList(contentFrame)
    for _, button in ipairs(contentFrame.buttons or {}) do
        button:Hide()
    end

    contentFrame.buttons = {}
    local yOffset = 0

    if self.currentProfile and self.profiles[self.currentProfile] then
        for _, buffName in ipairs(self.profiles[self.currentProfile].buffs) do
            local button = CreateFrame("Button", nil, contentFrame, "UIPanelButtonTemplate")
            button:SetSize(240, 30)
            button:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -yOffset)
            button:SetText(buffName)
            button:SetScript("OnClick", function()
                self.selectedBuff = buffName
                print("Selected buff:", buffName)
            end)
            yOffset = yOffset + 35
            table.insert(contentFrame.buttons, button)
        end
    end

    contentFrame:SetHeight(yOffset)
end
