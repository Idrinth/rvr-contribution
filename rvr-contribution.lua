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
local triesRezz = false
local win = {
    defence=10,
    keepDefense=50,
    keep=100,
    heal=0.0004,
    damage=0.0004,
    deaths=1,
    rezz=10,
    kills=10,
    assist=5,
    boxes=70,
    boxAssists=35,
    capture=5
}
local loss = {
    defence=10,
    keepDefense=50,
    keep=100,
    heal=0.0004,
    damage=0.0004,
    deaths=1,
    rezz=10,
    kills=10,
    assist=5,
    boxes=0,
    boxAssists=0,
    capture=5
}
local scale = {
    defence=1,
    keepDefense=1,
    keep=1,
    heal=100000,
    damage=100000,
    deaths=1,
    rezz=1,
    kills=1,
    assist=1,
    boxes=1,
    boxAssists=1,
    capture=1
}
local Keeps = {
    [L"Dok Karaz"]={"T2 Dwarf", "T2 Greenskin"},
    [L"Fangbreaka Swamp"]={"T2 Dwarf", "T2 Greenskin"},

    [L"Gnol Baraz"]={"T3 Dwarf", "T3 Greenskin"},
    [L"Thickmuck Pit"]={"T3 Dwarf", "T3 Greenskin"},

    [L"Karaz Drengi"]={"Kadrin Valley", "Kadrin Valley"},
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
    local counter=1
    for pairing, data in pairs(RvRContribution.Zones) do
        local window = "RvRContribution"..pairing:gsub(" ","_")
        if data.used then
            counter = counter + 1
            if not DoesWindowExist(window) then
                CreateWindowFromTemplate(window, "RvRContributionTemplate", "Root")
                LabelSetTextColor(window.."Pairing",255,255,255)
                LabelSetTextColor(window.."Win",255,255,255)
                LabelSetTextColor(window.."Loss",255,255,255)
            end
            WindowClearAnchors(window)
            WindowAddAnchor(window, "topleft", "RvRContribution", "topleft", 0, counter*30)
            LabelSetText(window.."Pairing", towstring(pairing))
            LabelSetText(window.."Win", towstring(math.floor(data.win)))
            LabelSetText(window.."Loss", towstring(math.floor(data.loss or 0)))
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
    notifications[name] = {towstring(name..": "..tostring(math.floor(values.win)).."|"..tostring(math.floor(values.loss)))}
end
local function add(key, amount, zone)
    if amount == nil then
        amount = 1
    end
    local zone = zone or RvRZones[GameData.Player.realm][GameData.Player.zone]
    if RvRContribution.Zones[zone] == nil then--to fix a weird bug where onload doesn't work
        RvRContribution.Zones[zone] = {}
    end
    if RvRContribution.Zones[zone].win == nil then
        RvRContribution.Zones[zone].win = 0
    end
    if RvRContribution.Zones[zone].loss == nil then
        RvRContribution.Zones[zone].loss = 0
    end
    if RvRContribution.Zones[zone][key] == nil then
        RvRContribution.Zones[zone][key] = 0
    end
    RvRContribution.Zones[zone].used = true
    local winValue = RvRContribution.Zones[zone].win
    local lossValue = RvRContribution.Zones[zone].loss
    for i=1,amount do
        RvRContribution.Zones[zone][key] = RvRContribution.Zones[zone][key] + 1
        RvRContribution.Zones[zone].win = RvRContribution.Zones[zone].win + win[key] * aao * keepBonus * flagBonus / math.pow(1.175, (RvRContribution.Zones[zone][key] - 1)/scale[key])
        RvRContribution.Zones[zone].loss = RvRContribution.Zones[zone].loss + loss[key] * aao * keepBonus * flagBonus / math.pow(1.175, (RvRContribution.Zones[zone][key] - 1)/scale[key]) 
    end
    if (math.floor(winValue) ~= math.floor(RvRContribution.Zones[zone].win) or math.floor(lossValue) ~= math.floor(RvRContribution.Zones[zone].loss)) and RvRContribution.Config.alert then
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
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, L"Alert enabled? "..towstring(RvRContribution.Config.alert))
    else
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, L"Avaible commands: alert, dump")
    end
end
function resetZone(zone)
    local message = zone;
    for key,value in pairs(RvRContribution.Zones[zone]) do
        if key ~= "used" and value ~= 0 then
            message = message.." "..key..": "..tostring(math.floor(value))
        end
    end
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.RVR, towstring(message))
    RvRContribution.Zones[zone] = nil
    local window = "RvRContribution"..zone:gsub(" ","_")
    if DoesWindowExist(window) then
        DestroyWindow(window)
    end
    RvRContribution.Zones[zone] = {heal=0,damage=0,rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,win=0,loss=0}
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
    Tooltips.SetTooltipText( 11, 1, towstring(values.defence or 0)..L" Defends")
    Tooltips.SetTooltipText( 12, 1, towstring(values.keep or 0)..L" Keeps")
    Tooltips.SetTooltipText( 13, 1, towstring(values.keepDefence or 0)..L" Keep Defends")
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
    --upgrade old stuff
    for key, values in pairs(RvRContribution.Zones) do
        if values.value then
            values.win = values.value
            values.value = nil
        end
    end
    --Zoning
    RegisterEventHandler(SystemData.Events.LOADING_END, "RvRContribution.OnZone")
    --AAO
    RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "RvRContribution.OnBuff")
    --Ressurection
    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "RvRContribution.OnCast")
    RegisterEventHandler(SystemData.Events.PLAYER_END_CAST, "RvRContribution.OnEndCast")
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
        LibSlash.RegisterSlashCmd( "rvrcontribution", slash )
        LibSlash.RegisterSlashCmd( "rvrc", slash )
    end
    -- ui
    CreateWindow("RvRContribution", true)
    LabelSetText("RvRContribution", L"RvRContribution")
    LabelSetTextColor("RvRContribution",255,255,255)
    LayoutEditor.RegisterWindow("RvRContribution", L"RvRContribution",L"", false, false, true, nil )
    local header = 'RvRContributionHeader';
    CreateWindow(header, true)
    LabelSetTextColor(header.."Pairing",255,255,255)
    LabelSetTextColor(header.."Win",255,255,255)
    LabelSetTextColor(header.."Loss",255,255,255)
    WindowAddAnchor(header, "topleft", "RvRContribution", "topleft", 0, 30)
    LabelSetText(header.."Pairing", L"Zone")
    LabelSetText(header.."Win", L"Win")
    LabelSetText(header.."Loss", L"Loss")
    ui()
end
function RvRContribution.OnPairingUpdate( pairingId )
    for zone, _ in pairs(RvRZones[1]) do
        RvRContribution.OnZoneUpdate(zone)
    end
end
function RvRContribution.OnEndCast(interupted)
    if triesRezz then
        if not interupted then
            add('rezz')
        end
        triesRezz = false
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
            triesRezz = true
            return
        end
    end
end
function RvRContribution.OnZone()
    aao = 1
    aaoBuffId = 0
    if isInAllowedZone() then
        if not RvRContribution.Zones[RvRZones[GameData.Player.realm][GameData.Player.zone]] then
            RvRContribution.Zones[RvRZones[GameData.Player.realm][GameData.Player.zone]] = {rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,win=0,loss=0}
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
    if filter == SystemData.ChatLogFilters.RVR then
        if not isInAllowedZone() then
            return
        end
        if not GameData.Player.isInRvRLake then
            return
        end
        local num = TextLogGetNumEntries("Chat") - 1
        local _, _, msg = TextLogGetEntry("Chat", num);
        if msg:match(L" successfully returned the supplies!$") then
            local name = msg:match(L"^(.+) successfully returned the supplies!$")
            local playername = GameData.Player.name:match(L"(.*)\^(.*)")
            if name == playername then
                add('boxes')
            else
                for _,player in pairs(GetGroupData()) do
                    if player and player.name and player.name == name and not player.isDistant then
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
            if not isInAllowedZone() then
                return
            end
            if not GameData.Player.isInRvRLake then
                return
            end
            add('assist')
        elseif msg:match(L"^You gain [0-9]+ renown from killing") then
            if not isInAllowedZone() then
                return
            end
            if not GameData.Player.isInRvRLake then
                return
            end
            add('kills')
        elseif msg:match(L"^You gain [0-9]+ renown from capturing (.+)\.$") then
            local keep = msg:match(L"^You gain [0-9]+ renown from capturing (.+)\.$")
            for keepName,pairing in pairs(Keeps) do
                if keep == keepName then
                    add('keep', 1, pairing[GameData.Player.realm])
                    break
                end
            end
        elseif msg:match(L"^You gain [0-9]+ renown from defending (.+)\.$") then
            local keep = msg:match(L"^You gain [0-9]+ renown from defending (.+)\.$")
            local found = false;
            for keepName,pairing in pairs(Keeps) do
                if keep == keepName then
                    add('keepDefense', 1, pairing[GameData.Player.realm])
                    found = true
                    break
                end
            end
            if not found then
                add('defense')
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