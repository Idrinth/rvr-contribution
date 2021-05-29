RvRContribution = {}

local notifications = {}
local timeNotify = 0
local timePQ = 0
local lastBOStatus = ""
local previousBOStatus = ""
local keepBonus = 1
local flagBonus = 1
local aao = 1
local aaoBuffId = 0
local triesRezz = false
local gloriousHeraldsBoonId = 0
local gloriousHeraldsBoon = 1
local win = {
    defence=10,
    keepDefence=0,
    keep=100,
    heal=0.00015,
    damage=0.00015,
    deaths=1,
    rezz=10,
    kills=10,
    assist=5,
    boxes=70,
    boxAssists=35,
    capture=5,
}
local loss = {
    defence=10,
    keepDefence=50,
    keep=0,
    heal=0.00015,
    damage=0.00015,
    deaths=1,
    rezz=10,
    kills=10,
    assist=5,
    boxes=5,
    boxAssists=1,
    capture=5,
}
local scale = {
    defence=1,
    keepDefence=1,
    keep=1,
    heal=500000,
    damage=500000,
    deaths=1,
    rezz=1,
    kills=1,
    assist=1,
    boxes=1,
    boxAssists=1,
    capture=1,
}
local boBonus = {
    defence=false,
    keepDefence=false,
    keep=false,
    heal=true,
    damage=true,
    deaths=true,
    rezz=true,
    kills=true,
    assist=true,
    boxes=true,
    boxAssists=true,
    capture=false,
}
local bags = {
    ["white"] = 400,
    ["green"] = 500,
    ["blue"] = 600,
    ["purple"] = 700,
    ["gold"] = 800,
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
    [L"Mandred's Hold"]={"T2 Empire", "T2 Chaos"},

    [L"Stoneclaw Castle"]={"T3 Empire", "T3 Chaos"},
    [L"Passwatch Castle"]={"T3 Empire", "T3 Chaos"},

    [L"Morr's Response"]={"Reikland", "Reikland"},
    [L"Wilhelm's Fist"]={"Reikland", "Reikland"},

    [L"Southern Garrison"]={"Praag", "Praag"},
    [L"Garrison of Skulls"]={"Praag", "Praag"},

    [L"Charon's Keep"]={"Chaos Wastes", "Chaos Wastes"},
    [L"Zimmeron's Hold"]={"Chaos Wastes", "Chaos Wastes"},

    [L"Spite's Reach"]={"T2 Elf", "T2 Elf"},
    [L"Cascades of Thunder"]={"T2 Elf", "T2 Elf"},

    [L"Ghrond's Sacristy"]={"T3 Elf", "T3 Elf"},
    [L"The Well of Qhaysh"]={"T3 Elf", "T3 Elf"},

    [L"Pillars of Remembrance"]={"Eataine", "Eataine"},
    [L"Arbor of Light"]={"Eataine", "Eataine"},

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

        [206]="T1 Elf",
        [200]="T1 Elf",

        [201]="T2 Elf",
        [207]="T2 Elf",

        [202]="T3 Elf",
        [208]="T3 Elf",

        [209]="Eataine",
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

        [206]="T1 Elf",
        [200]="T1 Elf",

        [201]="T2 Elf",
        [207]="T2 Elf",

        [202]="T3 Elf",
        [208]="T3 Elf",

        [209]="Eataine",
        [205]="Dragonwake",
        [203]="Caledor",
    },
}
local Zones = {
    [L"Erkrund and Mount Bloodhorn"]={"T1 Dwarf", "T1 Greenskin"},
    [L"Mount Bloodhorn and Erkrund"]={"T1 Dwarf", "T1 Greenskin"},

    [L"Barak Varr and Marshes of Madness"]={"T2 Dwarf", "T2 Greenskin"},
    [L"Marshes of Madness and Barak Varr"]={"T2 Dwarf", "T2 Greenskin"},

    [L"Black Fire Pass and The Badlands"]={"T3 Dwarf", "T3 Greenskin"},
    [L"The Badlands and Black Fire Pass"]={"T3 Dwarf", "T3 Greenskin"},

    [L"Kadrin Valley"]={"Kadrin Valley", "Kadrin Valley"},
    [L"Thunder Mountain"]={"Thunder Mountain", "Thunder Mountain"},
    [L"Black Crag"]={"Black Crag", "Black Crag"},

    [L"Nordland and Norsca"]={"T1 Empire", "T1 Chaos"},
    [L"Norsca and Nordland"]={"T1 Empire", "T1 Chaos"},

    [L"Troll Country and Ostland"]={"T2 Empire", "T2 Chaos"},
    [L"Ostland and Troll Country"]={"T2 Empire", "T2 Chaos"},

    [L"High Pass and Talabecland"]={"T3 Empire","T3 Chaos"},
    [L"Talabecland and High Pass"]={"T3 Empire","T3 Chaos"},

    [L"Reikland"]={"Reikland","Reikland"},
    [L"Praag"]={"Praag","Praag"},
    [L"Chaos Wastes"]={"Chaos Wastes","Chaos Wastes"},

    [L"The Blighted Isle and Chrace"]={"T1 Elf","T1 Elf"},
    [L"Chrace and The Blighted Isle"]={"T1 Elf","T1 Elf"},

    [L"The Shadowlands and Ellyrion"]={"T2 Elf","T2 Elf"},
    [L"Ellyrion and The Shadowlands"]={"T2 Elf","T2 Elf"},

    [L"Avelorn and Saphery"]={"T3 Elf","T3 Elf"},
    [L"Saphery and Avelorn"]={"T3 Elf","T3 Elf"},

    [L"Eataine"]={"Eataine","Eataine"},
    [L"Dragonwake"]={"Dragonwake","Dragonwake"},
    [L"Caledor"]="Caledor",
}
local BattlefieldObjectives = {
    [L"Stonemine Tower"]={"T1 Dwarf", "T1 Greenskin",},
    [L"Cannon Battery"]={"T1 Dwarf", "T1 Greenskin",},
    [L"Ironmane Outpost"]={"T1 Dwarf", "T1 Greenskin",},
    [L"The Lookout"]={"T1 Dwarf", "T1 Greenskin",},

    [L"Goblin Armory"]={"T2 Dwarf", "T2 Greenskin",},
    [L"Alcadizzar's Tomb"]={"T2 Dwarf", "T2 Greenskin",},
    [L"The Ironclad"]={"T2 Dwarf", "T2 Greenskin",},
    [L"The Lighthouse"]={"T2 Dwarf", "T2 Greenskin",},

    [L"Karagaz"]={"T3 Dwarf", "T3 Greenskin",},
    [L"Goblin Artillery Range"]={"T3 Dwarf", "T3 Greenskin",},
    [L"Bugman's Brewery"]={"T3 Dwarf", "T3 Greenskin",},
    [L"Furrig's Fall"]={"T3 Dwarf", "T3 Greenskin",},

    [L"Lobba Mill"]={"Black Crag", "Black Crag",},
    [L"Rottenpike Ravine"]={"Black Crag", "Black Crag",},
    [L"Madcap Pickins"]={"Black Crag", "Black Crag",},
    [L"Squiggly Beast Pens"]={"Black Crag", "Black Crag",},

    [L"Gromril Kruk"]={"Thunder Mountain", "Thunder Mountain",},
    [L"Karak Palik"]={"Thunder Mountain", "Thunder Mountain",},
    [L"Doomstriker Vein"]={"Thunder Mountain", "Thunder Mountain",},
    [L"Thargrim's Headwall"]={"Thunder Mountain", "Thunder Mountain",},

    [L"Gromril Junction"]={"Kadrin Valley", "Kadrin Valley",},
    [L"Dolgrund's Cairn"]={"Kadrin Valley", "Kadrin Valley",},
    [L"Icehearth Crossing"]={"Kadrin Valley", "Kadrin Valley",},
    [L"Hardwater Falls"]={"Kadrin Valley", "Kadrin Valley",},

    [L"The Harvest Shrine"]={"T1 Empire", "T1 Chaos",},
    [L"Festenplatz"]={"T1 Empire", "T1 Chaos",},
    [L"The Nordland XI"]={"T1 Empire", "T1 Chaos",},

    [L"Ruins of Greystone Keep"]={"T2 Empire", "T2 Chaos",},
    [L"Monastery of Morr"]={"T2 Empire", "T2 Chaos",},
    [L"Kinschel's Stronghold"]={"T2 Empire", "T2 Chaos",},
    [L"Crypt of Weapons"]={"T2 Empire", "T2 Chaos",},

    [L"Feiten's Lock"]={"T3 Empire", "T3 Chaos",},
    [L"Ogrund's Tavern"]={"T3 Empire", "T3 Chaos",},
    [L"Hallenfurt Manor"]={"T3 Empire", "T3 Chaos",},
    [L"Verentane's Tower"]={"T3 Empire", "T3 Chaos",},

    [L"Runehammer Gunworks"]={"Reikland", "Reikland",},
    [L"Schwenderhalle Manor"]={"Reikland", "Reikland",},
    [L"Reikwatch"]={"Reikland", "Reikland",},
    [L"Frostbeard's Quarry"]={"Reikland", "Reikland",},

    [L"Russenscheller Graveyard"]={"Praag", "Praag",},
    [L"Manor of Ortel von Zaris"]={"Praag", "Praag",},
    [L"Martyr's Square"]={"Praag", "Praag",},
    [L"Kurlov's Armory"]={"Praag", "Praag",},

    [L"The Shrine of Time"]={"Chaos Wastes", "Chaos Wastes",},
    [L"The Statue of the Everchosen"]={"Chaos Wastes", "Chaos Wastes",},
    [L"Thaugamond Massif"]={"Chaos Wastes", "Chaos Wastes",},
    [L"Chokethorn Bramble"]={"Chaos Wastes", "Chaos Wastes",},

    [L"The House of Lorendyth"]={"T1 Elf", "T1 Elf",},
    [L"Altair of Khaine"]={"T1 Elf", "T1 Elf",},
    [L"The Tower of Nightflame"]={"T1 Elf", "T1 Elf",},
    [L"The Shard of Grief"]={"T1 Elf", "T1 Elf",},

    [L"Shadow Spire"]={"T2 Elf", "T2 Elf",},
    [L"Unicorn Siege Camp"]={"T2 Elf", "T2 Elf",},
    [L"The Reaver Stables"]={"T2 Elf", "T2 Elf",},
    [L"The Needle of Ellyrion"]={"T2 Elf", "T2 Elf",},

    [L"Wood Choppaz Camp"]={"T3 Elf", "T3 Elf",},
    [L"Maiden's Landing"]={"T3 Elf", "T3 Elf",},
    [L"The Spire of Teclis"]={"T3 Elf", "T3 Elf",},
    [L"Saei' Daroir"]={"T2 Elf", "T3 Elf",},

    [L"Druchii Baracks"]={"Caledor", "Caledor",},
    [L"Shrine of the Conqueror"]={"Caledor", "Caledor",},
    [L"Sarathanan Vale"]={"Caledor", "Caledor",},
    [L"Senlathain Stand"]={"Caledor", "Caledor",},

    [L"Fireguard Spire"]={"Dragonwake", "Dragonwake",},
    [L"Mournfire's Approach"]={"Dragonwake", "Dragonwake",},
    [L"Pelgorath's Ember"]={"Dragonwake", "Dragonwake",},
    [L"Milaith's Memory"]={"Dragonwake", "Dragonwake",},

    [L"Chillwind Manor"]={"Eataine", "Eataine",},
    [L"Bel-Korhadris' Solitude"]={"Eataine", "Eataine",},
    [L"Sanctuary of Dreams"]={"Eataine", "Eataine",},
    [L"Uthorin Siege Camp"]={"Eataine", "Eataine",},
}
local resses = {
    [L"Stand, Coward!"]=9558,--DoK
    [L"Gedup!"]=1908,--Shaman
    [L"Tzeentch Shall Remake You"]=8555,--Zelot
    [L"Rune of Life"]=1598,--RP
    [L"Breath of Sigmar"]=8248,--WP
    [L"Gift of Life"]=9246,--AM
    [L"Rally"]=14526,--Banner Ress
    [L"Alter Fate"]=697,--Morale 4 ress
}
local noBoxBonus = {
    ["T2 Greenskin"] = true,
    ["T2 Dwarf"] = true,
    ["T3 Greenskin"] = true,
    ["T3 Dwarf"] = true,
    ["T2 Chaos"] = true,
    ["T2 Empire"] = true,
    ["T3 Chaos"] = true,
    ["T3 Empire"] = true,
    ["T2 Elf"] = true,
    ["T3 Elf"] = true,
}
local Log = {
    name="RvRContribution",
    id=9799,
}
local zoneToReset = {zone="",time=0}
local function isInAllowedZone()
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
        return false
    end
    if RvRZones[GameData.Player.realm][GameData.Player.zone] == nil then
        return false
    end
    zone = GetCampaignZoneData( GameData.Player.zone )
    return zone and not zone.locked
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
    notifications[name] = {towstring(name.." Win: "..tostring(math.floor(values.win)).." Loss: "..tostring(math.floor(values.loss)))}
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
    local factor = gloriousHeraldsBoon
    if boBonus[key] then
        factor = aao * flagBonus
        if not noBoxBonus[zone] or (key ~= "boxes" and key ~= "boxAssists") then
            factor = factor * keepBonus
        end
    end
    for i=1,amount do
        RvRContribution.Zones[zone][key] = RvRContribution.Zones[zone][key] + 1
        local scaling = 1/ math.pow(1.175, (RvRContribution.Zones[zone][key] - 1)/scale[key])
        if scaling < 0.1 then
            scaling = 0.1
        end
        RvRContribution.Zones[zone].win = RvRContribution.Zones[zone].win + win[key] * factor * scaling
        RvRContribution.Zones[zone].loss = RvRContribution.Zones[zone].loss + loss[key] * factor * scaling 
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
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, towstring("Alert enabled? "..tostring(RvRContribution.Config.alert)))
    else
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, L"Avaible commands: alert, dump")
    end
end
local function resetZoneInternal(zone, log)
    local message = zone;
    for key,value in pairs(RvRContribution.Zones[zone]) do
        if key ~= "used" and value ~= 0 then
            message = message.." "..key..": "..tostring(math.floor(value))
        end
    end
    if PQData and PQData.playerData and PQData.playerData.contribution then
        message = message.." contribution: "..tostring(PQData.playerData.contribution)
    end
    if message ~= zone then
        TextLogAddEntry("Chat", SystemData.ChatLogFilters.RVR, towstring(message))
        if log then
            TextLogAddEntry(Log.name, Log.id, towstring(message))
        end
    end
    RvRContribution.Zones[zone] = nil
    local window = "RvRContribution"..zone:gsub(" ","_")
    if DoesWindowExist(window) then
        DestroyWindow(window)
    end
    RvRContribution.Zones[zone] = {heal=0,damage=0,rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false,win=0,loss=0}
    ui()
end
local function resetZone(zone, log)
    if log then
        zoneToReset={zone=zone,time=90}
        return
    end
    resetZoneInternal(zone, log)
end
function RvRContribution.OnUpdateReset(elapsed)
    if zoneToReset.zone == "" then
        return
    end
    if zoneToReset.time < 0 then
        resetZoneInternal(zoneToReset.zone, true)
        zoneToReset={zone="",time=0}
        return
    end
    if PQData and PQData.playerData and PQData.playerData.contribution then
        resetZoneInternal(zoneToReset.zone, true)
        zoneToReset={zone="",time=0}
    end
    zoneToReset.time = zoneToReset.time - elapsed
end
local function getTooltipAnchor()
    local mouseWin = SystemData.MouseOverWindow.name
    local rootWidth,rootHeight = WindowGetDimensions("Root")
    local mglX,mglY = WindowGetScreenPosition(mouseWin)
    local anchor = nil
    if mglX*2 > rootWidth then
        return { Point = "topleft",  RelativeTo = mouseWin, RelativePoint = "topright",   XOffset = -10, YOffset = 0 }
    end
    return { Point = "topright",  RelativeTo = mouseWin, RelativePoint = "topleft",   XOffset = 10, YOffset = 0 }
end
function RvRContribution.OnHoverWin()
    Tooltips.CreateTextOnlyTooltip ( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Zone Won")
    Tooltips.SetTooltipText( 2, 1, L"Your contribution on winning a zone is listed here. It differs from the contribution when losing a zone.")
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( getTooltipAnchor() )
end
function RvRContribution.OnHoverLoss()
    Tooltips.CreateTextOnlyTooltip ( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, L"Zone Lost")
    Tooltips.SetTooltipText( 2, 1, L"Your contribution on losing a zone or defending a keep is listed here. It differs from the contribution when winning a zone.")
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( getTooltipAnchor() )
end
function RvRContribution.OnHover()
    local mouseWin = SystemData.MouseOverWindow.name
    local zone = mouseWin:match("^RvRContribution(.+)$")
    zone = zone:gsub("_", " ")
    values = RvRContribution.Zones[zone]
    Tooltips.CreateTextOnlyTooltip ( SystemData.MouseOverWindow.name )
    Tooltips.SetTooltipText( 1, 1, towstring(zone))
    local i = 2
    if values.rezz and values.rezz > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.rezz)..L" Resses")
        i = i+1
    end
    if values.deaths and values.deaths > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.deaths)..L" Deaths")
        i = i+1
    end
    if values.heal and values.heal > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.heal)..L" Heal")
        i = i+1
    end
    if values.damage and values.damage > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.damage)..L" Damage")
        i = i+1
    end
    if values.kills and values.kills > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.kills)..L" Kills")
        i = i+1
    end
    if values.assist and values.assist > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.assist)..L" Assists")
        i = i+1
    end
    if values.boxes and values.boxes > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.boxes)..L" Boxes")
        i = i+1
    end
    if values.boxAssists and values.boxAssists > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.boxAssists)..L" Box-Assists")
        i = i+1
    end
    if values.capture and values.capture > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.capture)..L" Captures")
        i = i+1
    end
    if values.keep and values.keep > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.keep)..L" Keeps")
        i = i+1
    end
    if values.defence and values.defence > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.defence)..L" Defences")
        i = i+1
    end
    if values.keepDefence and values.keepDefence > 0 then
        Tooltips.SetTooltipText( i, 1, towstring(values.keepDefence)..L" Keep Defences")
        i = i+1
    end
    Tooltips.Finalize()
    Tooltips.AnchorTooltip( getTooltipAnchor() )
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
    LabelSetText(header.."Win", L"Offence")
    LabelSetText(header.."Loss", L"Defence")
    ui()
    --log
    TextLogCreate(Log.name, Log.id)
    TextLogSetIncrementalSaving(Log.name, true, L"logs/rvr-contribution.log")
    TextLogSetEnabled(Log.name, true ) 
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
    d(abilityId)
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
function RvRContribution.OnChat(updateType, filter)
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
            local found = false
            for keepName,pairing in pairs(Keeps) do
                if keep == keepName then
                    add('keep', 1, pairing[GameData.Player.realm])
                    found = true
                    break
                end
            end
            if not found then
                for zone, pairing in pairs(Zones) do
                    if keep == zone then
                        found = true
                        resetZone(pairing[GameData.Player.realm], true)
                        break
                    end
                end
            end
        elseif msg:match(L"^You gain [0-9]+ renown from defending (.+)\.$") then
            local keep = msg:match(L"^You gain [0-9]+ renown from defending (.+)\.$")
            local found = false
            for keepName,pairing in pairs(Keeps) do
                if keep == keepName then
                    add('keepDefence', 1, pairing[GameData.Player.realm])
                    found = true
                    break
                end
            end
            if not found then
                for zone, pairing in pairs(Zones) do
                    if keep == zone then
                        found = true
                        resetZone(pairing[GameData.Player.realm], true)
                        break
                    end
                end
            end
            if not found then
                for boName,pairing in pairs(BattlefieldObjectives) do
                    if keep == boName then
                        add('defence', 1, pairing[GameData.Player.realm])
                        found = true
                        break
                    end
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
        resetZone(name, true)
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
            flagBonus = 1.25
            for k,q in pairs(quest.Quest) do
                if lastBOStatus ~= quest.name..q.name then
                    previousBOStatus = quest.name..q.name
                else
                    previousBOStatus = ""
                end
                lastBOStatus = quest.name..q.name
            end
        elseif quest.isKeep then
            keepBonus = 1.5
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
    for buffId, buffData in pairs( updatedBuffsTable ) do
        if buffData.name ~= nil then
            if buffData.abilityId == 24658 then--AAO
                aaoBuffId = buffId
                local percentage = string.match(tostring(buffData.effectText), 'increased by ([0-9]+)%%')
                aao = 1 + tonumber(percentage)/100
            elseif buffData.name == "Glorious Herald's Boon" or buffData.name == L"Glorious Herald's Boon" then--Glorious Herald's Boon
                d(buffData.abilityId)
                gloriousHeraldsBoonId = buffId
                gloriousHeraldsBoon = 1.05
            end
        elseif aaoBuffId == buffId then
            aao = 1
            aaoBuffId = 0
        elseif gloriousHeraldsBoonId == buffId then
            gloriousHeraldsBoonId = 0
            gloriousHeraldsBoon = 1
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