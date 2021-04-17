RvRContribution = {}

local notifications = {}
local timeNotify = 0
local timePQ = 0
local lastBOStatus = ""
local previousBOStatus = ""
local keepBonus = 1
local keepName = L""
local flagBonus = 1
local aao = 1
local aaoBuffId = 0
local points = {keep=50,heal=0.025,damage=0.02,deaths=0,rezz=10,kills=10,assist=5,boxes=50,boxAssists=10,capture=5}
local Keeps = {
    [L"Dok Karaz"]={"T2 Dwarf", "T2 Greenskin"},
    [L"Fangbreaka Swamp"]={"T2 Dwarf", "T2 Greenskin"},

    [L"Gnol Baraz"]={"T3 Dwarf", "T3 Greenskin"},
    [L"Thickmuck Pit"]={"T3 Dwarf", "T3 Greenskin"},

    [L"Karaz Drengi"]={"Kadrin Valley", "Kadrin Valleyn"},
    [L"Kazad Dammaz"]={"Kadrin Valley", "Kadrin Valley"},

    [L"Bloodfist Rock"]={"Thunder Mountain", "Thunder Mountain"},
    [L"Karak Karag"]={"Thunder Mountain", "Thunder Mountain"},

    [L"Ironskin Skar"]={"Black Crag", "Black Crag"},
    [L"Badmoon Hole"]={"Black Crag", "Black Crag"},

    [L"Stonetroll Keep"]={"T2 Empire", "T2 Chaos"},
    [L"Manded's Hold"]={"T2 Empire", "T2 Chaos"},

    [L"Stonetroll Castle"]={"T3 Empire", "T3 Chaos"},
    [L"Passwatch Castle"]={"T3 Empire", "T3 Chaos"},

    [L"Morr's Response"]={"Reikland", "Reikland"},
    [L"Wilhelm's Fist"]={"Reikland", "Reikland"},

    [L"Southern Garrison"]={"Praag", "Praag"},
    [L"Garrison of Skulls"]={"Praag", "Praag"},

    [L"Charon's Keep"]={"Chaos Wastes", "Chaos Wastes"},
    [L"Zimmeron's Hold"]={"Chaos Wastes", "Chaos Wastes"},

    [L"Spite's Reach"]={"T2 Elves", "T2 Elves"},
    [L"Cascades of Thunder"]={"T2 Elves", "T2 Elves"},

    [L"Ghrond's Sacristy"]={"T3 Elves", "T3 Elves"},
    [L"Well of Qhaysh"]={"T3 Elves", "T3 Elves"},

    [L"Pillars of Remembrance"]={"Eateine", "Eateine"},
    [L"Arbor of Light"]={"Eateine", "Eateine"},

    [L"Drakebreaker's Scourge"]={"Dragonwake", "Dragonwake"},
    [L"Covenant of Flame"]={"Dragonwake", "Dragonwake"},

    [L"Hatred's Way"]={"Caledor", "Caledor"},
    [L"Wrath's Resolve"]={"Caledor", "Caledor"},
}
local RvRZones = {
    [1] = {
        [6]="T1 Dwarf",
        [11]="T1 Dwarf",

        [7]="T2 Dwarf",
        [1]="T2 Dwarf",

        [8]="T3 Dwarf",
        [2]="T3 Dwarf",

        [9]="Kadrin Valley",
        [5]="Thunder Mountain",
        [3]="Black Crag",

        [106]="T1 Empire",
        [100]="T1 Empire",

        [101]="T2 Empire",
        [107]="T2 Empire",

        [102]="T3 Empire",
        [108]="T3 Empire",

        [109]="Reikland",
        [105]="Praag",
        [103]="Chaos Wastes",

        [206]="T1 Elves",
        [200]="T1 Elves",

        [201]="T2 Elves",
        [207]="T2 Elves",

        [202]="T3 Elves",
        [208]="T3 Elves",

        [209]="Eateine",
        [205]="Dragonwake",
        [203]="Caledor",
    },
    [2] = {
        [6]="T1 Greenskin",
        [11]="T1 Greenskin",

        [7]="T2 Greenskin",
        [1]="T2 Greenskin",

        [8]="T3 Greenskin",
        [2]="T3 Greenskin",

        [9]="Kadrin Valley",
        [5]="Thunder Mountain",
        [3]="Black Crag",

        [106]="T1 Chaos",
        [100]="T1 Chaos",

        [101]="T2 Chaos",
        [107]="T2 Chaos",

        [102]="T3 Chaos",
        [108]="T3 Chaos",

        [109]="Reikland",
        [105]="Praag",
        [103]="Chaos Wastes",

        [206]="T1 Elves",
        [200]="T1 Elves",

        [201]="T2 Elves",
        [207]="T2 Elves",

        [202]="T3 Elves",
        [208]="T3 Elves",

        [209]="Eateine",
        [205]="Dragonwake",
        [203]="Caledor",
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
    for pairing, data in pairs(RvRContribution.Zones) do
        local window = "RvRContribution"..pairing:gsub(" ","_")
        if data.used then
            counter = counter + 1
            if not DoesWindowExist(window) then
                CreateWindowFromTemplate(window, "RvRContributionTemplate", "Root")
            end
            WindowClearAnchors(window)
            WindowAddAnchor(window, "topleft", "RvRContribution", "topleft", 0, counter*30)
            LabelSetText(window.."Pairing", towstring(pairing))
            LabelSetText(window.."Points", towstring(math.floor(data.value)))
            LabelSetTextColor(window.."Pairing",255,255,255)
            LabelSetTextColor(window.."Points",255,255,255)
        elseif DoesWindowExist(window) then
            DestroyWindow(window)
        end
    end
end
local function notify(zone)
    local name = RvRZones[GameData.Player.realm][zone]
    local values = RvRContribution.Zones[name]
    if not values then
        return
    end
    notifications[name] = {towstring(name..": "..tostring(math.floor(values.value)))}
end
local function add(key, amount, zone)
    if amount == nil then
        amount = 1
    end
    local zone = zone or RvRZones[GameData.Player.realm][GameData.Player.zone]
    if RvRContribution.Zones[zone] == nil then--to fix a weird bug where onload doesn't work
        RvRContribution.Zones[zone] = {}
    end
    if RvRContribution.Zones[zone].value == nil then
        RvRContribution.Zones[zone].value = 0
    end
    if RvRContribution.Zones[zone][key] == nil then
        RvRContribution.Zones[zone][key] = 0
    end
    RvRContribution.Zones[zone].used = true
    local value = RvRContribution.Zones[zone].value
    for i=1,amount do
        RvRContribution.Zones[zone][key] = RvRContribution.Zones[zone][key] + 1
        RvRContribution.Zones[zone].value = RvRContribution.Zones[zone].value + points[key] * aao * keepBonus * flagBonus / math.pow(1.1, RvRContribution.Zones[zone][key] - 1) 
    end
    if math.floor(value) ~= math.floor(RvRContribution.Zones[zone].value) and RvRContribution.Config.alert then
        notify(GameData.Player.zone)
    end
    ui()
end
local function slash(input)
    if input == "dump" then
        for zone, values in pairs(RvRContribution.Zones) do
            notify(zone)
        end
    elseif input == "alert" then
        RvRContribution.Config.alert = not RvRContribution.Config.alert
    else
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, L"Avaible commands: alert, dump")
    end
end
function resetZone(zone)
    local message = zone;
    for key,value in pairs(RvRContribution.Zones[zone]) do
        if key ~= "used" then
            message = message.." "..key..": "..tostring(math.floor(value))
        end
    end
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.RVR, towstring(message))
    TextLogAddEntry("RvRContribution", 90000, towstring(message))
    RvRContribution.Zones[zone] = nil
    local window = "RvRContribution"..zone:gsub(" ","_")
    if DoesWindowExist(window) then
        DestroyWindow(window)
    end
    RvRContribution.Zones[zone] = {heal=0,damage=0,rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,value=0}
    ui()
end
function RvRContribution.OnHover()
    local mouseWin = SystemData.MouseOverWindow.name
    local zone = mouseWin:match("^RvRContribution(.+)$")
    zone = zone:gsub("_", " ")
    values = RvRContribution.Zones[zone]
    Tooltips.CreateTextOnlyTooltip ( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, towstring(zone))
    Tooltips.SetTooltipText( 2, 1, towstring(values.rezz or 0)..L" Resses")
    Tooltips.SetTooltipText( 3, 1, towstring(values.heal or 0)..L" Heal")
    Tooltips.SetTooltipText( 4, 1, towstring(values.deaths or 0)..L" Deaths")
    Tooltips.SetTooltipText( 5, 1, towstring(values.kills or 0)..L" Kills")
    Tooltips.SetTooltipText( 6, 1, towstring(values.assist or 0)..L" Assists")
    Tooltips.SetTooltipText( 7, 1, towstring(values.damage or 0)..L" Damage")
    Tooltips.SetTooltipText( 8, 1, towstring(values.boxes or 0)..L" Boxes")
    Tooltips.SetTooltipText( 9, 1, towstring(values.boxAssists or 0)..L" Box-Assists")
    Tooltips.SetTooltipText( 10, 1, towstring(values.capture or 0)..L" Captures")
    Tooltips.SetTooltipText( 11, 1, towstring(values.keep or 0)..L" Keeps")
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
    if not zone then
        return
    end
    zone = zone:gsub("_", " ")
    resetZone(zone)
end
function RvRContribution.OnInitialize()
    RvRContribution.Zones = RvRContribution.Zones or {}
    RvRContribution.Config = RvRContribution.Config or {alert=true}
    RvRContribution.OnZone()
    --Zoning
    RegisterEventHandler(SystemData.Events.LOADING_END, "RvRContribution.OnZone")
    --AAO
    RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "RvRContribution.OnBuff")
    --Ressurection
    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "RvRContribution.OnCast")
    --Battlefield-Objective capture
    RegisterEventHandler(SystemData.Events.PUBLIC_QUEST_UPDATED, "RvRContribution.OnPublicQuest")
    --Deaths
    RegisterEventHandler(SystemData.Events.PLAYER_DEATH, "RvRContribution.OnDeath")
    -- Assists&Kills
    RegisterEventHandler(TextLogGetUpdateEventId( "Combat" ), "RvRContribution.OnChat" )
    --box carrying
    RegisterEventHandler(TextLogGetUpdateEventId( "Chat" ), "RvRContribution.OnChat" )
    --reset
    RegisterEventHandler(SystemData.Events.CAMPAIGN_ZONE_UPDATED, "RvRContribution.OnZoneUpdate" )
    RegisterEventHandler(SystemData.Events.CAMPAIGN_PAIRING_UPDATED, "RvRContribution.OnPairingUpdate" )
    -- combat actions
    RegisterEventHandler( SystemData.Events.WORLD_OBJ_COMBAT_EVENT, "RvRContribution.OnCombatAction")
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
    --log
    TextLogCreate("RvRContribution", 9000)
    TextLogSetIncrementalSaving( "RvRContribution", true, L"logs/rvrcontribution.log")
    TextLogSetEnabled("RvRContribution", true )
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
    aao = 1
    aaoBuffId = 0
    if isInAllowedZone() then
        if not RvRContribution.Zones[RvRZones[GameData.Player.realm][GameData.Player.zone]] then
            RvRContribution.Zones[RvRZones[GameData.Player.realm][GameData.Player.zone]] = {rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,value=0}
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
        elseif msg:match(L"^You gain [0-9]+ renown from capturing (.+)$") then
            local keep = msg:match(L"^You gain [0-9]+ renown from capturing (.+)$")
            for keepName,pairing in pairs(Keeps) do
                if keep == keepName then
                    add('keep', 1, pairing[GameData.Player.realm])
                    break
                end
            end
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
        local name = RvRZones[GameData.Player.realm][zoneId]
        if not name or not RvRContribution.Zones[name] then
            return
        end
        resetZone(name)
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
    keepBonus = 1
    flagBonus = 1
    keepName = L""
    local quests = GetActiveObjectivesData()
    for key, quest in pairs(quests) do
        if quest.isBattlefieldObjective and not quest.isKeep then
            flagBonus = 1.1
            for k,q in pairs(quest.Quest) do
                if lastBOStatus ~= quest.name..q.name then
                    previousBOStatus = quest.name..q.name
                else
                    previousBOStatus = ""
                end
                lastBOStatus = quest.name..q.name
            end
        elseif quest.isKeep then
            keepBonus = 1.25
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
            if buffData.abilityId == 24658 then--AAO
                aaoBuffId = buffId
                local percentage = string.match(tostring(buffData.effectText), 'increased by ([0-9]+)%%')
                aao = 1 + tonumber(percentage)/100
                return
            end
        elseif aaoBuffId == buffId then
            aao = 1
            aaoBuffId = 0
            return    
        end
    end
end
function RvRContribution.OnDeath()
    if not isInAllowedZone() then
        return
    end
    if not GameData.Player.isInRvRLake then
        return
    end
    if GameData.Player.hitPoints.current > 0 then
        return
    end
    if GameData.Player.killerName == L"" then
        return
    end
    add('deaths')
end
function RvRContribution.OnCombatAction( hitTargetObjectNumber, hitAmount, textType )
    if not isInAllowedZone() then
        return
    end
    if not GameData.Player.isInRvRLake then
        return
    end
    if GameData.Player.worldObjNum ~= hitTargetObjectNumber then
        if textType == GameData.CombatEvent.HIT or textType == GameData.CombatEvent.ABILITY_HIT or textType == GameData.CombatEvent.CRITICAL or textType == GameData.CombatEvent.ABILITY_CRITICAL then
            if hitAmount < 0 then
                add('damage', -1 * hitAmount)
            elseif hitAmount > 0 then
                add('heal', hitAmount)
            end
        end
    end
end