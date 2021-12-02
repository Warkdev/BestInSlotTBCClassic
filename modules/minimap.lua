-- This file is handling all minimap related stuff
local icon;
local launcher;

local function MinimapButtonOnClick(self, button)
    if button == "RightButton" then
        BIS:OpenConfigPane();
    elseif button == "LeftButton" then
        BIS:ShowManager();
    end
end

local function MinimapTooltipShow(tooltip)
    tooltip:AddLine("BestInSlot-Classic");
    tooltip:AddLine("Version: "..VERSION);
    tooltip:AddLine("Left-Click: Open the main window");
    tooltip:AddLine("Right-Click: Open the settings window");
end

function BIS:CreateMinimapIcon()
    launcher = LibStub("LibDataBroker-1.1"):NewDataObject("BestInSlotTBCClassic", {
        type = "launcher",
        icon = "Interface\\Addons\\BestInSlotTBCClassic\\assets\\logo_32x32",
        OnClick = MinimapButtonOnClick,
        OnTooltipShow = MinimapTooltipShow,
    });

    icon = LibStub("LibDBIcon-1.0");
    icon:Register("BestInSlotTBCClassic", launcher, BestInSlotTBCClassicDB.minimap);
end

function BIS:UpdateMinimapIcon()
    icon:Refresh("BestInSlotTBCClassic", BestInSlotTBCClassicDB.minimap);
end