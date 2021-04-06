RvRContribution = {}

local data = {}
local time = 0
function RvRContribution.OnInitialize()
    --RegisterEventHandler( SystemData.Events.SHOW_ALERT_TEXT, "RvRContribution.handleEvent" )
    --battlefieldObjectiveTracker:capture
    -- Assists&Kills
    RegisterEventHandler(TextLogGetUpdateEventId( "Combat" ), "RvRContribution.OnChat" )
    --box carrying
    RegisterEventHandler(TextLogGetUpdateEventId( "Chat" ), "RvRContribution.OnChat" )
    --reset
    RegisterEventHandler(SystemData.Events.CAMPAIGN_ZONE_UPDATED, "RvRContribution.OnZoneUpdate" )
end
function RvRContribution.OnChat(updateType, filter)--SystemData.ChatLogFilters
    if updateType ~= SystemData.TextLogUpdate.ADDED then
        return
    end
    if not data[GameData.Player.zone] then
        data[GameData.Player.zone] = {kills=0,assist=0,boxes=0,boxAssists=0,used=false}
    end
    if filter == SystemData.ChatLogFilters.RVR then
        local num = TextLogGetNumEntries("Chat") - 1
        local _, _, msg = TextLogGetEntry("Chat", num);
        if tostring(msg):match(" successfully returned the supplies!$") then
            local name = tostring(msg):match("^([A-Z1-z]+) successfully returned the supplies!$")
            if name == GameData.Player.name then
                data[GameData.Player.zone].boxes = data[GameData.Player.zone].boxes + 1
                data[GameData.Player.zone].used = true
            else
                for _,player in pairs(GetGroupData()) do
                    if player and player.name and player.name == name then
                        data[GameData.Player.zone].boxAssists = data[GameData.Player.zone].boxAssists + 1
                        data[GameData.Player.zone].used = true
                        break
                    end
                end
            end
        end
    elseif filter == SystemData.ChatLogFilters.RENOWN then
        local num = TextLogGetNumEntries("Combat") - 1
        local _, _, msg = TextLogGetEntry("Combat", num);
        if tostring(msg):match("^You get [0-9]+ renown from assisting [a-zA-Z]\\.$") then
            data[GameData.Player.zone].assist = data[GameData.Player.zone].assist + 1
            data[GameData.Player.zone].used = true
        elseif tostring(msg):match("^You get [0-9]+ renown from killing [a-zA-Z]\\.$") then
            data[GameData.Player.zone].kills = data[GameData.Player.zone].kills + 1
            data[GameData.Player.zone].used = true
        end
    end
end
function RvRContribution.OnUpdate(elapsed)
    time = time + elapsed
    if time < 300 then
        return
    end
    time = time - 300
    for zone, values in pairs(data) do
        if values.used then
            AlertTextWindow.SetAlertData(
                {SystemData.AlertText.Types.RVR},
                {towstring("Zone "..tostring(GetZoneName(zone)).." Kills: "..tostring(values.kills).." Assists: "..tostring(values.assist).." Boxes: "..tostring(values.boxes).." Box-Assists: "..tostring(values.boxAssists))}
            )
        end
    end
end
function RvRContribution.OnZoneUpdate(zoneId)
    local zone = GetCampaignZoneData( zoneId )
    if zone.locked then
        data[zoneId] = nil
    end
end