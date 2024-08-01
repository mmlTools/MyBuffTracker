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

MyBuffTracker.CreateDropdown = CreateDropdown
MyBuffTracker.CreateProfileManagerButton = CreateProfileManagerButton

local dropdown = MyBuffTracker:CreateDropdown()
local profileManagerButton = MyBuffTracker:CreateProfileManagerButton()
