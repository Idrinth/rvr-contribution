RvRContribution = {}

local data = {}
local notifications = {}
local timeNote = 0
local timeNotify = 0
local timePQ = 0
local lastBOStatus = ""
function RvRContribution.OnInitialize()
    --Zoning
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
end
function RvRContribution.OnCast(abilityId)
    RvRContribution.OnZone()
    local data = Player.GetAbilityData(actionId)
    if not data then
        return
    end
    local name = data.name:match(L"(.*)\^(.*)")
    if name == L"Gedup!" or name == L"Tzeentch Shall Remake You" or name == L"Stand, Coward!" or name == L"Rune of Life" or name == L"Breath of Sigmar" or name == L"Gift of Life" then
        data[GameData.Player.zone].rezz = data[GameData.Player.zone].rezz + 1
        data[GameData.Player.zone].used = true
        notify(GameData.Player.zone, data[GameData.Player.zone])
    end
end
function RvRContribution.OnZone()
    if not data[GameData.Player.zone] then
        data[GameData.Player.zone] = {rezz=0,kills=0,assist=0,boxes=0,boxAssists=0,capture=0,used=false}
    end
end
function RvRContribution.OnChat(updateType, filter)--SystemData.ChatLogFilters
    if updateType ~= SystemData.TextLogUpdate.ADDED then
        return
    end
    RvRContribution.OnZone()
    if filter == SystemData.ChatLogFilters.RVR then
        local num = TextLogGetNumEntries("Chat") - 1
        local _, _, msg = TextLogGetEntry("Chat", num);
        if tostring(msg):match(" successfully returned the supplies!$") then
            local name = tostring(msg):match("^([A-Za-z]+) successfully returned the supplies!$")
            if name == tostring(GameData.Player.name) then
                data[GameData.Player.zone].boxes = data[GameData.Player.zone].boxes + 1
                data[GameData.Player.zone].used = true
                notify(GameData.Player.zone, data[GameData.Player.zone])
            else
                for _,player in pairs(GetGroupData()) do
                    if player and player.name and tostring(player.name) == name then
                        data[GameData.Player.zone].boxAssists = data[GameData.Player.zone].boxAssists + 1
                        data[GameData.Player.zone].used = true
                        notify(GameData.Player.zone, data[GameData.Player.zone])
                        break
                    end
                end
            end
        end
    elseif filter == SystemData.ChatLogFilters.RENOWN then--and not GameData.Player.isInScenario and not GameData.Player.isInSiege then
        local num = TextLogGetNumEntries("Combat") - 1
        local _, _, msg = TextLogGetEntry("Combat", num);
        d(msg)
        if tostring(msg):match("^You get [0-9]+ renown from assisting [a-zA-Z]\\.$") then
            data[GameData.Player.zone].assist = data[GameData.Player.zone].assist + 1
            data[GameData.Player.zone].used = true
            notify(GameData.Player.zone, data[GameData.Player.zone])
        elseif tostring(msg):match("^You get [0-9]+ renown from killing [a-zA-Z]\\.$") then
            data[GameData.Player.zone].kills = data[GameData.Player.zone].kills + 1
            data[GameData.Player.zone].used = true
            notify(GameData.Player.zone, data[GameData.Player.zone])
        end
    end
end
function notify(zone, values)
    notifications[#notifications] = {towstring("Zone "..tostring(GetZoneName(zone)).." Kills: "..tostring(values.kills).." Assists: "..tostring(values.assist).." Boxes: "..tostring(values.boxes).." Box-Assists: "..tostring(values.boxAssists).." Captures: "..tostring(values.capture))}
end
function RvRContribution.OnUpdateNote(elapsed)
    timeNote = timeNote + elapsed
    if timeNote < 300 then
        return
    end
    timeNote = timeNote - 300
    for zone, values in pairs(data) do
        if values.used then
            notify(zone, values)
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
    if zone.locked then
        data[zoneId] = nil
    end
end
function RvRContribution.OnUpdatePQ(elapsed)
    timePQ = timePQ + elapsed
    if timePQ < 1 then
        return
    end
    lastBOStatus = ""
    timePQ = timePQ - 1
    local quests = GetActiveObjectivesData()
    for key, quest in pairs(quests) do
        if quest.isBattlefieldObjective and not quest.isKeep then
            for k,q in pairs(quest.Quest) do
                lastBOStatus = quest.name..q.name
            end 
        end
    end
end
function RvRContribution.OnPublicQuest()
    RvRContribution.OnZone()
    local quests = GetActiveObjectivesData()
    for key, quest in pairs(quests) do
        if quest.isBattlefieldObjective and not quest.isKeep then
            for k,q in pairs(quest.Quest) do
                if q.name == L"GENERATING" and lastBOStatus ~= "" and quest.name..q.name ~= lastBOStatus then
                    data[GameData.Player.zone].capture = data[GameData.Player.zone].capture + 1
                    data[GameData.Player.zone].used = true
                    lastBOStatus = quest.name..q.name
                    notify(GameData.Player.zone, data[GameData.Player.zone])
                    return
                end
            end 
        end
    end
end
