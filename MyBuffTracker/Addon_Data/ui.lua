local MyBuffTracker = _G.MyBuffTracker

local function CreateDropdown()
    local dropdown = CreateFrame("Frame", "MyBuffTrackerProfileDropdown", UIParent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, 150)
    
    function dropdown:OnSelect(profileName)
        MyBuffTracker:SetProfile(profileName)
    end

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for profileName, _ in pairs(MyBuffTracker.profiles) do
            info.text = profileName
            info.checked = (profileName == MyBuffTracker.currentProfile)
            info.menuList = profileName
            info.func = function()
                UIDropDownMenu_SetSelectedName(dropdown, profileName)
                dropdown:OnSelect(profileName)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedName(dropdown, MyBuffTracker.currentProfile)
    dropdown:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10)

    return dropdown
end

local function CreateProfileManagerButton()
    local button = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
    button:SetSize(100, 30)
    button:SetText("Profiles")
    button:SetPoint("TOPLEFT", MyBuffTrackerProfileDropdown, "BOTTOMLEFT", 0, -10)

    button:SetScript("OnClick", function()
        MyBuffTracker:ShowProfileManager()
    end)
    
    return button
end

local minimapButton = CreateFrame("Button", "MyBuffTrackerMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)

minimapButton:SetNormalTexture("Interface\\AddOns\\MyBuffTracker\\Textures\\MinimapButton")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
minimapButton:SetPushedTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT")

minimapButton:SetScript("OnClick", function()
    if MyBuffTrackerFrame:IsShown() then
        MyBuffTrackerFrame:Hide()
    else
        MyBuffTrackerFrame:Show()
    end
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("My Buff Tracker", 1, 1, 1)
    GameTooltip:AddLine("Click to toggle the addon.", nil, nil, nil, true)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

minimapButton:RegisterForDrag("LeftButton")
minimapButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

function MyBuffTracker:Toggle()
    if MyBuffTrackerFrame:IsShown() then
        MyBuffTrackerFrame:Hide()
    else
        MyBuffTrackerFrame:Show()
    end
end

MyBuffTrackerFrame = CreateFrame("Frame", "MyBuffTrackerFrame", UIParent)
MyBuffTrackerFrame:SetSize(400, 300)
MyBuffTrackerFrame:SetPoint("CENTER")
MyBuffTrackerFrame:Hide()

local dropdown = MyBuffTracker:CreateDropdown()
local profileManagerButton = MyBuffTracker:CreateProfileManagerButton()

MyBuffTrackerFrame:SetScript("OnShow", function()
    dropdown:Show()
    profileManagerButton:Show()
end)

MyBuffTrackerFrame:SetScript("OnHide", function()
    dropdown:Hide()
    profileManagerButton:Hide()
end)
