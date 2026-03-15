local addonName, ns = ...
local ATONEMENT_ID = 194384

-- 1. Database Initialization
AtonementTrackerDB = AtonementTrackerDB or {
    size = 40,
    locked = false,
    alpha = 1.0,
    fontSize = 22,
    scanInterval = 0.2, -- Default update rate
}

--------------------------------------------------
-- 2. Main Tracker Icon
--------------------------------------------------
local frame = CreateFrame("Frame", "AtonementTrackerFrame", UIParent)
frame:SetPoint("CENTER", 0, 0)
frame:SetMovable(true)
frame:Hide()

local icon = frame:CreateTexture(nil, "BACKGROUND")
icon:SetAllPoints()
icon:SetTexture(C_Spell.GetSpellTexture(ATONEMENT_ID))

local timerText = frame:CreateFontString(nil, "OVERLAY")
timerText:SetPoint("CENTER")

local countText = frame:CreateFontString(nil, "OVERLAY")
countText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)

local function RefreshUI()
    frame:SetSize(AtonementTrackerDB.size, AtonementTrackerDB.size)
    frame:SetAlpha(AtonementTrackerDB.alpha)
    timerText:SetFont(STANDARD_TEXT_FONT, AtonementTrackerDB.fontSize, "THICKOUTLINE")
    countText:SetFont(STANDARD_TEXT_FONT, AtonementTrackerDB.fontSize * 0.7, "THICKOUTLINE")
    
    if AtonementTrackerDB.locked then
        frame:EnableMouse(false)
    else
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
    end
end

frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

--------------------------------------------------
-- 3. Core Logic (Midnight/Taint-Safe)
--------------------------------------------------
local shortestExpiration, atonementCount = 0, 0

local function ScanAtonements()
    shortestExpiration, atonementCount = 0, 0
    local atonementStr = tostring(ATONEMENT_ID)
    
    local units = {"player", "target", "focus"}
    if IsInRaid() then
        for i=1, GetNumGroupMembers() do table.insert(units, "raid"..i) end
    elseif IsInGroup() then
        for i=1, GetNumSubgroupMembers() do table.insert(units, "party"..i) end
    end

    local checkedGUIDs = {}

    for _, unit in ipairs(units) do
        if UnitExists(unit) and UnitIsFriend("player", unit) then
            local guid = UnitGUID(unit)
            if not checkedGUIDs[guid] then
                checkedGUIDs[guid] = true
                
                for i = 1, 40 do
                    local data = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
                    if not data then break end

                    local okSrc, isMine = pcall(function() return tostring(data.sourceUnit) == "player" end)
                    local okSpell, isAtone = pcall(function() return tostring(data.spellId) == atonementStr end)

                    if okSrc and isMine and okSpell and isAtone then
                        atonementCount = atonementCount + 1
                        local okExp, exp = pcall(function() return data.expirationTime end)
                        if okExp and exp then
                            if shortestExpiration == 0 or exp < shortestExpiration then
                                shortestExpiration = exp
                            end
                        end
                        break 
                    end
                end
            end
        end
    end

    if atonementCount > 0 then frame:Show() else frame:Hide() end
end

frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("ADDON_LOADED")

local lastScan = 0
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        RefreshUI()
    else
        -- Performance throttled scan
        local now = GetTime()
        if (now - lastScan) >= (AtonementTrackerDB.scanInterval or 0.2) then
            ScanAtonements()
            lastScan = now
        end
    end
end)

frame:SetScript("OnUpdate", function()
    if atonementCount == 0 then return end
    
    local now = GetTime()
    local remaining = shortestExpiration - now
    
    if remaining > 0 then
        timerText:SetText(string.format("%.0f", remaining))
        countText:SetText(atonementCount)
        
        if remaining <= 3 then
            timerText:SetTextColor(1, 0.3, 0.3)
        else
            timerText:SetTextColor(1, 1, 1)
        end
    else
        timerText:SetText("")
        ScanAtonements()
    end
end)

--------------------------------------------------
-- 4. Options Window
--------------------------------------------------
local options = CreateFrame("Frame", "AtonementOptionsWindow", UIParent, "BackdropTemplate")
options:SetSize(250, 320) -- Increased height for new slider
options:SetPoint("CENTER")
options:SetFrameStrata("DIALOG")
options:SetMovable(true)
options:EnableMouse(true)
options:RegisterForDrag("LeftButton")
options:SetScript("OnDragStart", options.StartMoving)
options:SetScript("OnDragStop", options.StopMovingOrSizing)
options:Hide()

options:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
options:SetBackdropColor(0, 0, 0, 0.9)

local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -12)
title:SetText("Atonement Tracker")

local close = CreateFrame("Button", nil, options, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -2, -2)

local function CreateSlider(name, label, min, max, y, dbKey)
    local s = CreateFrame("Slider", "AtTracker"..name, options, "OptionsSliderTemplate")
    s:SetPoint("TOP", 0, y)
    s:SetMinMaxValues(min, max)
    local step = (dbKey == "alpha" or dbKey == "scanInterval") and 0.1 or 1
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    s:SetWidth(180)
    
    s:SetScript("OnShow", function(self) self:SetValue(AtonementTrackerDB[dbKey]) end)
    s:SetScript("OnValueChanged", function(self, value)
        AtonementTrackerDB[dbKey] = value
        RefreshUI()
        local displayVal = (step < 1) and string.format("%.1f", value) or math.floor(value)
        _G[self:GetName().."Text"]:SetText(label .. ": " .. displayVal)
    end)
    return s
end

local lockCb = CreateFrame("CheckButton", "AtTrackerLockCB", options, "InterfaceOptionsCheckButtonTemplate")
lockCb:SetPoint("TOPLEFT", 20, -40)
_G[lockCb:GetName().."Text"]:SetText("Lock (Click-Through)")
lockCb:SetScript("OnShow", function(self) self:SetChecked(AtonementTrackerDB.locked) end)
lockCb:SetScript("OnClick", function(self)
    AtonementTrackerDB.locked = self:GetChecked()
    RefreshUI()
end)

CreateSlider("SizeSl", "Icon Size", 20, 150, -100, "size")
CreateSlider("AlphaSl", "Opacity", 0.1, 1.0, -150, "alpha")
CreateSlider("FontSl", "Text Size", 10, 50, -200, "fontSize")

-- Performance Slider
local perfSl = CreateSlider("PerfSl", "Update Rate", 0.1, 1.0, -260, "scanInterval")
local perfDesc = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
perfDesc:SetPoint("TOP", perfSl, "BOTTOM", 0, -2)
perfDesc:SetText("Seconds between scans. Default: 0.2\nLower is faster, higher is better CPU.")

SLASH_ATONEMENT1 = "/at"
SlashCmdList["ATONEMENT"] = function()
    if options:IsShown() then options:Hide() else options:Show() end
end
