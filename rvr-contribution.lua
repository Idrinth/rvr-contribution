RvRContribution = {}

local notifications = {}
local timeNote = 0
local timeNotify = 0
local timePQ = 0
local lastBOStatus = ""
local previousBOStatus = ""
local aao = 1
local aaoBuffId = 0
local points = {rezz=10,kills=25,assist=5,boxes=150,boxAssists=30,capture=5}
local RvRZones = {
    [1] = {
        [6]="T1 Dwarf",
        [11]="T1 Dwarf",

        [7]="T2 Dwarf",
        [1]="T2 Dwarf",

        [8]="T3 Dwarf",
        [2]="T3 Dwarf",

        [9]="T4 Dwarf",
        [5]="T4 Dwarf",
        [3]="T4 Dwarf",

        [106]="T1 Empire",
        [100]="T1 Empire",

        [101]="T2 Empire",
        [107]="T2 Empire",

        [102]="T3 Empire",
        [108]="T3 Empire",

        [109]="T4 Empire",
        [105]="T4 Empire",
        [103]="T4 Empire",

        [206]="T1 Elves",
        [200]="T1 Elves",

        [201]="T2 Elves",
        [207]="T2 Elves",

        [202]="T3 Elves",
        [208]="T3 Elves",

        [209]="T4 Elves",
        [205]="T4 Elves",
        [203]="T4 Elves",
    },
    [2] = {
        [6]="T1 Greenskin",
        [11]="T1 Greenskin",

        [7]="T2 Greenskin",
        [1]="T2 Greenskin",

        [8]="T3 Greenskin",
        [2]="T3 Greenskin",

        [9]="T4 Greenskin",
        [5]="T4 Greenskin",
        [3]="T4 Greenskin",

        [106]="T1 Chaos",
        [100]="T1 Chaos",

        [101]="T2 Chaos",
        [107]="T2 Chaos",

        [102]="T3 Chaos",
        [108]="T3 Chaos",

        [109]="T4 Chaos",
        [105]="T4 Chaos",
        [103]="T4 Chaos",

        [206]="T1 Elves",
        [200]="T1 Elves",

        [201]="T2 Elves",
        [207]="T2 Elves",

        [202]="T3 Elves",
        [208]="T3 Elves",

        [209]="T4 Elves",
        [205]="T4 Elves",
        [203]="T4 Elves",
    },
}
local resses = {
    [L"Stand, Coward!"]=9558,--DoK
    [L"Gedup!"]=1908,--Shaman
    [L"Tzeentch Shall Remake You"]=8555,--Zelot
    [L"Rune of Life"]=1598,--RP
    [L"Breath of Sigmar"]=8248,--WP
    [L"Gift of Life"]=9246,--AM
}
local function isInAllowedZone()
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
        return false
    end
    if RvRZones[GameData.Player.realm][GameData.Player.zone] ~= nil then
        return true
    end
    return false
end
local function ui()
    local counter=0
    for pairing, data in pairs(RvRContribution.Settings) do
        local window = "RvRContribution"..pairing:gsub(" ","_")
        if data.used then
            counter = counter + 1
            if not DoesWindowExist(window) then
                CreateWindowFromTemplate(window, "RvRContributionTemplate", "Root")
            end
            WindowClearAnchors(window)
            WindowAddAnchor(window, "topleft", "RvRContribution", "topleft", 0, counter*30)
            LabelSetText(window.."Pairing", towstring(pairing))
            LabelSetText(window.."Points", towstring(data.value))
            LabelSetTextColor(window.."Pairing",255,255,255)
            LabelSetTextColor(window.."Points",255,255,255)
        elseif DoesWindowExist(window) then
            DestroyWindow(window)
        end
    end
end
local function notify(zone)
    local values = RvRContribution.Settings[zone]
    if not values then
        return
    end
    local message = towstring(
        zone
        .." Resses: "..tostring(values.rezz)
        .." Kills: "..tostring(values.kills)
        .." Assists: "..tostring(values.assist)
        .." Boxes: "..tostring(values.boxes)
        .." Box-Assists: "..tostring(values.boxAssists)
        .." Captures: "..tostring(values.capture)
        .." Contribution: "..tostring(values.value)
    )
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.RVR, message)
    notifications[zone] = {"Contribution: "..tostring(values.value)}
end
local function add(key)
    if RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]].value == nil then
        RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]].value = 0
    end
    RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]][key] = RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]][key] + 1
    RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]].used = true
    RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]].value = RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]].value + points[key] * aao
    notify(GameData.Player.zone)
    ui()
end
local function slash(input)
    for zone, values in pairs(RvRContribution.Settings) do
        notify(zone)
    end
end
function RvRContribution.OnHover()
    local mouseWin = SystemData.MouseOverWindow.name
    local zone = mouseWin:match("^RvRContribution(.+)$")
    zone = zone:gsub("_", " ")
    values = RvRContribution.Settings[zone]
    Tooltips.CreateTextOnlyTooltip ( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, towstring(zone))
    Tooltips.SetTooltipText( 2, 1, towstring(values.rezz)..L" Resses")
    Tooltips.SetTooltipText( 3, 1, towstring(values.kills)..L" Kills")
    Tooltips.SetTooltipText( 4, 1, towstring(values.assist)..L" Assists")
    Tooltips.SetTooltipText( 5, 1, towstring(values.boxes)..L" Boxes")
    Tooltips.SetTooltipText( 6, 1, towstring(values.boxAssists)..L" Box-Assists")
    Tooltips.SetTooltipText( 7, 1, towstring(values.capture)..L" Captures")
    Tooltips.Finalize()
    local rootWidth,rootHeight = WindowGetDimensions("Root")
    local mglX,mglY = WindowGetScreenPosition(mouseWin)
    local anchor = nil
    if mglX*2 > rootWidth then
        anchor = { Point = "topleft",  RelativeTo = mouseWin, RelativePoint = "topright",   XOffset = -10, YOffset = 0 }
    else
        anchor = { Point = "topright",  RelativeTo = mouseWin, RelativePoint = "topleft",   XOffset = 10, YOffset = 0 }
    end
    Tooltips.AnchorTooltip( anchor )
end
function RvRContribution.OnRButtonUp()
    local mouseWin = SystemData.MouseOverWindow.name
    local zone = mouseWin:match("^RvRContribution(.+)$")
    zone = zone:gsub("_", " ")
    RvRContribution.Settings[zone] = {rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,value=0}
    ui()
end
function RvRContribution.OnInitialize()
    RvRContribution.Settings = RvRContribution.Settings or {}
    RvRContribution.OnZone()
    --Zoning
    RegisterEventHandler(SystemData.Events.LOADING_END, "RvRContribution.OnZone")
    --AAO
    RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "RvRContribution.OnBuff")
    --Ressurection
    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "RvRContribution.OnCast")
    --Battlefield-Objective capture
    RegisterEventHandler(SystemData.Events.PUBLIC_QUEST_UPDATED, "RvRContribution.OnPublicQuest")
    -- Assists&Kills
    RegisterEventHandler(TextLogGetUpdateEventId( "Combat" ), "RvRContribution.OnChat" )
    --box carrying
    RegisterEventHandler(TextLogGetUpdateEventId( "Chat" ), "RvRContribution.OnChat" )
    --reset
    RegisterEventHandler(SystemData.Events.CAMPAIGN_ZONE_UPDATED, "RvRContribution.OnZoneUpdate" )
    RegisterEventHandler(SystemData.Events.CAMPAIGN_PAIRING_UPDATED, "RvRContribution.OnPairingUpdate" )
    -- commands
    if LibSlash and LibSlash.RegisterSlashCmd then
        LibSlash.RegisterSlashCmd( "rvr-contribution", slash )
        LibSlash.RegisterSlashCmd( "rvrc", slash )
    end
    -- ui
    CreateWindow("RvRContribution", true)
    LabelSetText("RvRContribution", L"RvRContribution")
    LabelSetTextColor("RvRContribution",255,255,255)
    LayoutEditor.RegisterWindow("RvRContribution", L"RvRContribution",L"", false, false, true, nil )
    ui()
end
function RvRContribution.OnPairingUpdate( pairingId )
    for zone, _ in pairs(RvRZones[1]) do
        RvRContribution.OnZoneUpdate(zone)
    end
end
function RvRContribution.OnCast(abilityId)
    if not isInAllowedZone() then
        return
    end
    if not GameData.Player.isInRvRLake then
        return
    end
    for _, id in pairs(resses) do
        if abilityId == id then
            add('rezz')
            return
        end
    end
end
function RvRContribution.OnZone()
    if isInAllowedZone() then
        if not RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]] then
            RvRContribution.Settings[RvRZones[GameData.Player.realm][GameData.Player.zone]] = {rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,value=0}
        end
    end
    for zone, _ in pairs(RvRZones[1]) do
        RvRContribution.OnZoneUpdate(zone)
    end
end
function RvRContribution.OnChat(updateType, filter)--SystemData.ChatLogFilters
    if updateType ~= SystemData.TextLogUpdate.ADDED then
        return
    end
    if not isInAllowedZone() then
        return
    end
    if not GameData.Player.isInRvRLake then
        return
    end
    if filter == SystemData.ChatLogFilters.RVR then
        local num = TextLogGetNumEntries("Chat") - 1
        local _, _, msg = TextLogGetEntry("Chat", num);
        if msg:match(L" successfully returned the supplies!$") then
            local name = msg:match(L"^(.+) successfully returned the supplies!$")
            local playername = GameData.Player.name:match(L"(.*)\^(.*)")
            if name == playername then
                add('boxes')
            else
                for _,player in pairs(GetGroupData()) do
                    if player and player.name and player.name == name then
                        add('boxAssists')
                        break
                    end
                end
            end
        end
    elseif filter == SystemData.ChatLogFilters.RENOWN then
        local num = TextLogGetNumEntries("Combat") - 1
        local _, _, msg = TextLogGetEntry("Combat", num);
        if msg:match(L"^You gain [0-9]+ renown from assisting") then
            add('assist')
        elseif msg:match(L"^You gain [0-9]+ renown from killing") then
            add('kills')
        end
    end
end
function RvRContribution.OnUpdateNotification(elapsed)
    timeNotify = timeNotify + elapsed
    if timeNotify < 5 then
        return
    end
    timeNotify = timeNotify - 5
    for key, text in pairs(notifications) do
        AlertTextWindow.SetAlertData(
            {SystemData.AlertText.Types.RVR},
            text
        )
        notifications[key] = nil
        return
    end
end
function RvRContribution.OnZoneUpdate(zoneId)
    local zone = GetCampaignZoneData( zoneId )
    if not zone or zone.locked then
        RvRContribution.Settings[RvRZones[GameData.Player.realm][zoneId]] = nil
        local window = "RvRContribution"..RvRZones[GameData.Player.realm][zoneId]:gsub(" ","_")
        if DoesWindowExist(window) then
            DestroyWindow(window)
        end
    end
end
function RvRContribution.OnUpdatePQ(elapsed)
    timePQ = timePQ + elapsed
    if timePQ < 1 then
        return
    end
    lastBOStatus = ""
    timePQ = timePQ - 1
    if not isInAllowedZone() then
        return
    end
    if not GameData.Player.isInRvRLake then
        return
    end
    local quests = GetActiveObjectivesData()
    for key, quest in pairs(quests) do
        if quest.isBattlefieldObjective and not quest.isKeep then
            for k,q in pairs(quest.Quest) do
                if lastBOStatus ~= quest.name..q.name then
                    previousBOStatus = quest.name..q.name
                else
                    previousBOStatus = ""
                end
                lastBOStatus = quest.name..q.name
            end 
        end
    end
end
function RvRContribution.OnPublicQuest()
    if not isInAllowedZone() then
        return
    end
    if not GameData.Player.isInRvRLake then
        return
    end
    local quests = GetActiveObjectivesData()
    for key, quest in pairs(quests) do
        if quest.isBattlefieldObjective and not quest.isKeep then
            for k,q in pairs(quest.Quest) do
                if quest.controllingRealm == GameData.Player.realm and q.name == L"GENERATING" and previousBOStatus ~= "" and quest.name..q.name ~= previousBOStatus then
                    add('capture')
                    return
                end
            end 
        end
    end
end
function RvRContribution.OnBuff(updatedBuffsTable, isFullList)
    if not updatedBuffsTable then
        return
    end
    local deactivate = false
    for buffId, buffData in pairs( updatedBuffsTable ) do
        if buffData.name ~= nil then
            if buffData.ID == 24658 then
                aaoBuffId = buffId
                local percentage = string.match(tostring(buffData.effectText), '%d%d%d')
                aao = tonumber(percentage)/100
                d(aao)
                return
            end
        elseif aaoBuffId == buffId then
            aao = 1
            aaoBuffId = 0
            d(aao)
            return    
        end
    end
end