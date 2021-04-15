Rotation = {}

local abilities = {}
local time = 0
local persons = {t={},h={},r={},m={}}
local types = {t=L"Tank",h=L"Healer",r=L"Ranged",m=L"Melee"}
local function paint()
    local counter = 0
    for ability,settings in pairs(abilities) do
        local offset = 30 * counter
        local window = "RotationAbility"..ability
        if not DoesWindowExist(window) then
            CreateWindowFromTemplate( window, "RotationAbilityTemplate", "Root" )
            LabelSetText(window.."Ability", towstring(ability))
            ButtonSetText(window.."Start", L"Start")
            ButtonSetText(window.."Stop", L"Stop")
            WindowSetShowing(window.."Start", false)
            WindowSetShowing(window.."Stop", true)
        end
        WindowClearAnchors(window)
        LabelSetText(window.."Type", types[settings.chars])
        WindowAddAnchor(window, "topleft", "RotationAnchor", "topleft", 0, offset)
        WindowSetShowing(window, true)
        counter = counter + 1
    end
end
local function log(message)
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, towstring(message))
end
local function slash(input)
    local mode,ability = input:match("^([a-z1-6]+) ([A-Za-z0-9]+)")
    if not ability or not mode then
        log("You need to set ability("..tostring(ability)..") and mode("..tostring(mode)..")!")
        return
    elseif mode:match("^[tmhr]$") then
        local frequency = input:match(" ([0-9]+)$")
        frequency = tonumber(frequency)
        if frequency < 1 or frequency > 60 then
            log("Frequency out of bounds(1-60)")
            return
        end
        log("Ability "..ability.." turned on!")
        abilities[ability] = {
            frequency=frequency,
            chars=mode,
            counter=0,
            now=0,
            active=true
        }
        paint()
    elseif mode == "off" then
        log("Ability "..ability.." turned off!")
        abilities[ability] = nil
        DestroyWindow("RotationAbility"..ability)
        paint()
    else
        log("Mode "..mode.." unknown")
    end
end
function Rotation.OnUpdate(elapsed)
    time = time + elapsed
    if time < 1 then
        return
    end
    time = time - 1
    if false and not GameData.Player.inCombat then
        for ability,settings in pairs(abilities) do
            settings.now = 0
            settings.counter = 0
        end
        return
    end
    for ability,settings in pairs(abilities) do
        if settings.active and #persons[settings.chars] > 0 then
            settings.now = settings.now + 1
            local frequency = math.ceil(settings.frequency/#persons[settings.chars])
            if settings.now == frequency then
                local person = settings.counter%(#persons[settings.chars]) + 1
                AutoChannel.sendChatBandSay(L"@"..persons[settings.chars][person]..L" "..towstring(ability))
                settings.counter = settings.counter + 1
                if settings.counter > #persons[settings.chars] then
                    settings.counter = 1
                end
                settings.now = 0
                return
            end
        end
    end
end
function Rotation.OnInitialize()
    LibSlash.RegisterSlashCmd("rotate", slash)
    CreateWindow("RotationAnchor", true)
    WindowSetShowing("RotationAnchor", true)
    LayoutEditor.RegisterWindow( "RotationAnchor", L"RotationAnchor",L"", false, false, false, nil )
    RegisterEventHandler(SystemData.Events.GROUP_UPDATED, "Rotation.OnGroupChange")
    Rotation.OnGroupChange()
end
function Rotation.OnStop()
    local mouseWin = SystemData.MouseOverWindow.name
    local ability = mouseWin:match("^RotationAbility(.+)Stop")
    WindowSetShowing("RotationAbility"..ability.."Start", true)
    WindowSetShowing("RotationAbility"..ability.."Stop", false)
    if abilities[ability] then
        abilities[ability].active = false
    end
end
function Rotation.OnStart()
    local mouseWin = SystemData.MouseOverWindow.name
    local ability = mouseWin:match("^RotationAbility(.+)Start")
    WindowSetShowing("RotationAbility"..ability.."Start", false)
    WindowSetShowing("RotationAbility"..ability.."Stop", true)
    if abilities[ability] then
        abilities[ability].active = true
    end
end
function Rotation.SwitchMode()
    local mouseWin = SystemData.MouseOverWindow.name
    local ability = mouseWin:match("^RotationAbility(.+)Start")
    local isGroup = not ButtonGetCheckButtonFlag(SystemData.MouseOverWindow.name)
    ButtonSetCheckButtonFlag(SystemData.MouseOverWindow.name, isGroup)
    if isGroup and abilities[ability] then
        abilities[ability].groups = 1
    elseif abilities[ability] then
        abilities[ability].groups = 4
    end
end
function addPlayer(name, career)
    if not career then
        return
    end
    career = career:match(L"(.*)\^.*")
    if career == L"Disciple of Khaine" or career == L"Zealot" or career == L"Shaman" or career == L"Runepriest" or career == L"Archmage" or career == L"Warrior Priest" then
        persons.h[#persons.h +1] = name
    elseif career == L"Black Orc" or career == L"Blackguard" or career == L"Chosen" or career == L"Ironbreaker" or career == L"Swordmaster" or career == L"Knight of the Blazing Sun" then
        persons.t[#persons.h +1] = name
    elseif career == L"Choppa" or career == L"Marauder" or career == L"Witch Elf" or career == L"Witch Hunter" or career == L"White Lion" or career == L"Slayer" then
        persons.m[#persons.h +1] = name
    elseif career == L"Engineer" or career == L"Magus" or career == L"Squig Herder" or career == L"Sorcerer" or career == L"Bright Wizard" or career == L"Shadow Warrior" then
        persons.r[#persons.h +1] = name
    else
        d(career)
    end
end
function Rotation.OnGroupChange()
    persons = {t={},h={},r={},m={}}
    if IsWarBandActive() or AutoChannel.isScenario() then
        for group, members in pairs(GetBattlegroupMemberData()) do
            for _, player in pairs(members.players) do
                if player and player.name then
                    addPlayer(player.name, player.careerName)
                end
            end
        end
    else
        addPlayer(GameData.Player.name, GameData.Player.career.name)
        for _,player in pairs(GetGroupData()) do
            if player and player.name then
                addPlayer(player.name, player.careerName)
            end
        end
    end
    d(persons)
end