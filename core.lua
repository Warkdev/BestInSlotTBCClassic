BIS = {};

local function SetMinimapDefaults()
    if BestInSlotTBCClassicDB.minimap.hide == nil then
        BestInSlotTBCClassicDB.minimap.hide = false;
    end

    if BestInSlotTBCClassicDB.minimap.minimapPos == nil then
        BestInSlotTBCClassicDB.minimap.minimapPos = 175;
    end
end

local function SetTooltipDefaults()
    if BestInSlotTBCClassicDB.options == nil then
        BestInSlotTBCClassicDB.options = {};
    end

    if BestInSlotTBCClassicDB.options.bistooltip == nil then
        BestInSlotTBCClassicDB.options.bistooltip = true;
    end
end

local function SetLogLevelDefaults()
    if BestInSlotTBCClassicDB.loglevel == nil then
        BestInSlotTBCClassicDB.loglevel = "INFO";
    end
end

local function SetFilterDefaults()
    if BestInSlotTBCClassicDB.filter == nil then
        BestInSlotTBCClassicDB.filter = {};
    end

    if BestInSlotTBCClassicDB.filter.raid == nil then
        BestInSlotTBCClassicDB.filter.raid = true;
    end

    if BestInSlotTBCClassicDB.filter.worldboss == nil then
        BestInSlotTBCClassicDB.filter.worldboss = true;
    end

    if BestInSlotTBCClassicDB.filter.twohands == nil then
        BestInSlotTBCClassicDB.filter.twohands = false;
    end

    if BestInSlotTBCClassicDB.filter.pvp == nil then
        BestInSlotTBCClassicDB.filter.pvp = true;
    end

    if BestInSlotTBCClassicDB.filter.soulboundBis == nil then
        BestInSlotTBCClassicDB.filter.soulboundBis = true;
    end
end

local function SetDefaults()
    if BestInSlotTBCClassicDB == nil then
        -- First time loading add-on.
        BestInSlotTBCClassicDB = {};
        BestInSlotTBCClassicDB.minimap = {};
        BestInSlotTBCClassicDB.loglevel = nil;
        BestInSlotTBCClassicDB.options = {};
    end
    SetMinimapDefaults();
    SetLogLevelDefaults();
    SetFilterDefaults();
    SetTooltipDefaults();
end

function BIS:ResetDefaults()
    BestInSlotTBCClassicDB = nil;

    SetDefaults();
end

function BIS:LoadItemInfo()
    for idx, itemId in pairs(BIS_ITEM_LOAD) do
        GetItemInfo(itemId);
    end
end

function BIS:LoadPlayerInfo()
    -- Player name.
    name = UnitName("player");

    -- Player level.
    level = UnitLevel("player");

    -- Player faction.
    faction, localizedFaction = UnitFactionGroup("player");

    -- Player class info.
    localizedClass, class, classIndex = UnitClass("player");

    -- Player race info.
    localizedRace, race, raceID = UnitRace("player");

    -- Player spec info.
    local maxPoints = 0;
    spec = "Unknown";

    -- No need to check the spec when below level 65.
    if level < 65 then
        return;
    end

    -- Trying to find out which spec has this player to load the correct one by default.
    -- There are some specificities like druids (4 specs), rogue (2 specs-type although they are not spec).
    local numTalentTabs = GetNumTalentTabs();
    local talentsPoints = {};

    BIS:logmsg("Num Talent Tabs: "..numTalentTabs, LVL_DEBUG);

    for idx=1, numTalentTabs, 1 do
        local name, texture, pointsSpent, fileName = GetTalentTabInfo(idx);
        talentsPoints[idx] = tonumber(pointsSpent);
        if(tonumber(pointsSpent) > maxPoints) then
            spec = fileName;
            maxPoints = tonumber(pointsSpent);
        end
        BIS:logmsg(name..": "..pointsSpent..", "..fileName, LVL_DEBUG);
    end

    if class == "DRUID" and spec == "DruidFeralCombat" then
        -- Need to find out whether it's a Feral Tank or DPS.
        -- This is done by checking the talent thick skin.
        local talentName, iconTexture, tier, column, rank, maxRank, isExceptional, available = GetTalentInfo(2, 5);
        if rank == maxRank then
            spec = "DruidFeralTank";
        else
            spec = "DruidFeralDPS";
        end
    end

    -- BiS are apparently for PriestHybrid but nothing dedicated to Holy or Disc.
    if class == "PRIEST" and (spec == "PriestHoly" or spec == "PriestDiscipline") then
        spec = "PriestHybrid";
    end

    if class == "ROGUE" then
        spec = "RogueAny"
    end

    BIS:logmsg("Your spec is: "..spec, LVL_DEBUG);
end

function BIS:PrintPlayerInfo()
    BIS:logmsg("Player name: "..name, LVL_DEBUG);
    BIS:logmsg("Player faction: "..faction, LVL_DEBUG);
    BIS:logmsg("Player race: "..race, LVL_DEBUG);
    BIS:logmsg("Player class: "..class, LVL_DEBUG);
    BIS:logmsg("Player Spec: "..spec, LVL_DEBUG);
end

local function OnGameTooltipSetItem(tooltip)
    BIS:OnGameTooltipSetItem(tooltip);
end

BIS_LibExtraTip = LibStub("LibExtraTip-1");
-- Creating Event Frame.
local loaderFrame = CreateFrame("FRAME");
loaderFrame:RegisterEvent("ADDON_LOADED");

local function eventHandler(self, event, args1, ...)
    if event == "ADDON_LOADED" and args1 == "BestInSlotTBCClassic" then
        SetDefaults();
        BIS:CreateMinimapIcon();
        BIS:CreateSettingsInterface();
        BIS:SetUILocale();
        -- Attempt to prevent buggy display.
        BIS:LoadPlayerInfo();
        BIS:LoadItemInfo();
        BIS_LibExtraTip:AddCallback({type = "item", callback = OnGameTooltipSetItem, allevents = true})
        BIS_LibExtraTip:RegisterTooltip(GameTooltip);
        BIS_LibExtraTip:RegisterTooltip(ItemRefTooltip);
        BIS:logmsg("BestInSlotTBCClassic v"..VERSION.." loaded", LVL_INFO);
        loaderFrame:UnregisterAllEvents();
    end
end

loaderFrame:SetScript("OnEvent", eventHandler);