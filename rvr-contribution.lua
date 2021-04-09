RvRContribution = {}

local notifications = {}
local timeNote = 0
local timeNotify = 0
local timePQ = 0
local lastBOStatus = ""
local previousBOStatus = ""
local points = {rezz=0,kills=25,assist=0,boxes=0,boxAssists=0,capture=0}
function slash(input)
    for zone, values in pairs(RvRContribution.Settings) do
        notify(zone)
    end
end
function RvRContribution.OnInitialize()
    RvRContribution.Settings = RvRContribution.Settings or {}
    RvRContribution.OnZone()
    --Zoning
    RegisterEventHandler(SystemData.Events.LOADING_END, "RvRContribution.OnZone")
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
    if LibSlash and LibSlash.RegisterSlashCmd then
        LibSlash.RegisterSlashCmd( "rvr-contribution", slash )
        LibSlash.RegisterSlashCmd( "rvrc", slash )
    end
end
function RvRContribution.OnCast(abilityId)
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
        return
    end
    local data = Player.GetAbilityData(abilityId)
    if not data then
        return
    end
    local name = data.name:match(L"(.*)\^(.*)")
    if name == L"Gedup!" or name == L"Tzeentch Shall Remake You" or name == L"Stand, Coward!" or name == L"Rune of Life" or name == L"Breath of Sigmar" or name == L"Gift of Life" then
        RvRContribution.Settings[GameData.Player.zone].rezz = RvRContribution.Settings[GameData.Player.zone].rezz + 1
        RvRContribution.Settings[GameData.Player.zone].used = true
        notify(GameData.Player.zone)
    end
end
function RvRContribution.OnZone()
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
        return
    end
    if not RvRContribution.Settings[GameData.Player.zone] then
        RvRContribution.Settings[GameData.Player.zone] = {rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false}
    end
    for zone, _ in pairs(RvRContribution.Settings) do
        RvRContribution.OnZoneUpdate(zone)
    end
end
function RvRContribution.OnChat(updateType, filter)--SystemData.ChatLogFilters
    if updateType ~= SystemData.TextLogUpdate.ADDED then
        return
    end
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
        return
    end
    if filter == SystemData.ChatLogFilters.RVR then
        local num = TextLogGetNumEntries("Chat") - 1
        local _, _, msg = TextLogGetEntry("Chat", num);
        if msg:match(L" successfully returned the supplies!$") then
            local name = msg:match(L"^(.+) successfully returned the supplies!$")
            local playername = GameData.Player.name:match(L"(.*)\^(.*)")
            if name == playername then
                RvRContribution.Settings[GameData.Player.zone].boxes = RvRContribution.Settings[GameData.Player.zone].boxes + 1
                RvRContribution.Settings[GameData.Player.zone].used = true
                notify(GameData.Player.zone)
            else
                for _,player in pairs(GetGroupData()) do
                    if player and player.name and player.name == name then
                        RvRContribution.Settings[GameData.Player.zone].boxAssists = RvRContribution.Settings[GameData.Player.zone].boxAssists + 1
                        RvRContribution.Settings[GameData.Player.zone].used = true
                        notify(GameData.Player.zone)
                        break
                    end
                end
            end
        end
    elseif filter == SystemData.ChatLogFilters.RENOWN then
        local num = TextLogGetNumEntries("Combat") - 1
        local _, _, msg = TextLogGetEntry("Combat", num);
        if msg:match(L"^You gain [0-9]+ renown from assisting") then
            RvRContribution.Settings[GameData.Player.zone].assist = RvRContribution.Settings[GameData.Player.zone].assist + 1
            RvRContribution.Settings[GameData.Player.zone].used = true
            notify(GameData.Player.zone)
        elseif msg:match(L"^You gain [0-9]+ renown from killing") then
            RvRContribution.Settings[GameData.Player.zone].kills = RvRContribution.Settings[GameData.Player.zone].kills + 1
            RvRContribution.Settings[GameData.Player.zone].used = true
            notify(GameData.Player.zone)
        end
    end
end
function notify(zone)
    local values = RvRContribution.Settings[zone]
    local message = towstring(tostring(GetZoneName(zone)).." Resses: "..tostring(values.rezz).." Kills: "..tostring(values.kills).." Assists: "..tostring(values.assist).." Boxes: "..tostring(values.boxes).." Box-Assists: "..tostring(values.boxAssists).." Captures: "..tostring(values.capture))
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.RVR, message)
    notifications[#notifications] = {message}
end
function RvRContribution.OnUpdateNote(elapsed)
    timeNote = timeNote + elapsed
    if timeNote < 300 then
        return
    end
    timeNote = timeNote - 300
    for zone, values in pairs(RvRContribution.Settings) do
        if values.used then
            notify(zone)
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
        RvRContribution.Settings[zoneId] = nil
    end
end
function RvRContribution.OnUpdatePQ(elapsed)
    timePQ = timePQ + elapsed
    if timePQ < 1 then
        return
    end
    lastBOStatus = ""
    timePQ = timePQ - 1
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
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
    if GameData.Player.isInSiege or GameData.Player.isInScenario then
        return
    end
    local quests = GetActiveObjectivesData()
    for key, quest in pairs(quests) do
        d(quest)
        if quest.isBattlefieldObjective and not quest.isKeep then
            for k,q in pairs(quest.Quest) do
                if quest.controllingRealm == GameData.Player.realm and q.name == L"GENERATING" and previousBOStatus ~= "" and quest.name..q.name ~= previousBOStatus then
                    RvRContribution.Settings[GameData.Player.zone].capture = RvRContribution.Settings[GameData.Player.zone].capture + 1
                    RvRContribution.Settings[GameData.Player.zone].used = true
                    notify(GameData.Player.zone)
                    return
                end
            end 
        end
    end
end
