--==========================================================================================================

-- Init functions and globals

ScubaLootTitle = "CLC"
ScubaLootVersion = "1.0"

ScubaLoot_SessionOpen = true
ScubaLoot_QueuedItems = {} -- if multiple items are raid warning'd then they will go here
ScubaLoot_ItemBeingDecided = ""

ScubaLoot_RowsShown = 0

ScubaLoot_Sort = {
    Names = {}, -- names of the people linking
    Links = {} -- items that they linked
}

SlashCmdList["SLASH_SCUBALOOT"] = function() end

SLASH_SCUBALOOT1 = "/sl"
function SlashCmdList.SCUBALOOT(args)
    ScubaLoot_ToggleGUI()
end

function ScubaLoot_OnLoad()
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("CHAT_MSG_RAID")
    this:RegisterEvent("CHAT_MSG_RAID_LEADER")
    this:RegisterEvent("CHAT_MSG_RAID_WARNING")
    this:RegisterEvent("CHAT_MSG_OFFICER")
end

function ScubaLoot_Init()
    -- reinitialize globals
    ScubaLoot_Sort.Names = {}
    ScubaLoot_Sort.Links = {}

    --ScubaLoot_SessionOpen = false
    ScubaLoot_ItemBeingDecided = ""
    ScubaLoot_QueuedItems = {}

    ScubaLoot_RowsShown = 0
end

--==========================================================================================================

-- Main addon functions

-- arg1
--    chat message
-- arg2
--    author
-- arg3
--    lineID
function ScubaLoot_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
    if(event == "VARIABLES_LOADED") then
        this:UnregisterEvent("VARIABLES_LOADED")
        ScubaLoot_Init()
    elseif(event == "CHAT_MSG_RAID_WARNING") then
        ScubaLoot_OpenLootSession(arg1)
    elseif(event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") then
        if(ScubaLoot_SessionOpen) then
            ScubaLoot_AddToSort(arg1, arg2)
        end
    elseif(event == "CHAT_MSG_RAID_WARNING") then
        ScubaLoot_HandleOfficerMessage(arg1, arg2)
    end
end

-- arg1
--    chat message
-- arg2
--    author
function ScubaLoot_AddToSort(arg1, arg2)
    local itemLinks = ScubaLoot_GetItemLinks(arg1)
    if(itemLinks) then
        DEFAULT_CHAT_FRAME:AddMessage("Found Item Links")
        --if(ScubaLoot_HasValue(ScubaLoot_Sort.Names, arg2) == false) then
            table.insert(ScubaLoot_Sort.Names, arg2) -- add name
            table.insert(ScubaLoot_Sort.Links, arg1) -- add items
        --else
        --    for k, v in pairs(ScubaLoot_Sort.Names) do
        --        if(v == arg2) then
        --            ScubaLoot_Sort.Links[k] = arg1
        --        end
        --    end
        --end
        ScubaLoot_UpdateRows()
    end
end

-- arg1
--    chat message
function ScubaLoot_GetItemLinks(arg1)
    local items = {}
    local added = false
    -- matches one or more items similar to |Hitem:6948:0:0:0:0:0:0:0|h[Hearthstone]|h
    for item in string.gmatch(arg1, "|.-]|h") do
        table.insert(items, item)
        added = true
    end
    if(added) then
        return items
    else
        return nil
    end
end

-- arg1
--    chat message
function ScubaLoot_OpenLootSession(arg1)
    -- if only one item is linked in rw then start a loot session
    -- do not start if arg1 contains "roll"
    local itemLinks = ScubaLoot_GetItemLinks(arg1)
    if(itemLinks[1] and string.find(arg1, "roll") == nil) then
        ScubaLoot_UpdateMainItem(itemLinks)
    elseif(itemLinks[1] and string.find(arg1, "roll") ~= nil) then

    end
end

-- itemLinks
--    one or more linked items in a table
function ScubaLoot_UpdateMainItem(itemLinks)
    DEFAULT_CHAT_FRAME:AddMessage("ScubaLoot_UpdateMainItem")
    ScubaLoot_QueuedItems = itemLinks
    if(ScubaLoot_QueuedItems[1]) then
        local nextItem = table.remove(ScubaLoot_QueuedItems, 1)
        ScubaLoot_AddMainItemToGUI(nextItem)
        ScubaLoot_ItemBeingDecided = nextItem
        SendChatMessage("Link for " .. ScubaLoot_LinkToName(nextItem), "RAID")
    end
end

function ScubaLoot_HandleOfficerMessage()

end

function ScubaLoot_GetNameByID(itemLink)
    local name, _, quality, _, _, _, _, _, texture = GetItemInfo(ScubaLoot_LinkToID(itemLink))
    return name, texture, quality
end

function ScubaLoot_LinkToID(itemLink)
    -- item link format ex: |Hitem:6948:0:0:0:0:0:0:0|h[Hearthstone]|h
    -- matches anything inside the first 2 :'s ex: |Hitem:6948:0:0:0:0: -> 6948
    return string.match(itemLink, ":(%d+)")
end

function ScubaLoot_LinkToName(itemLink)
    -- item link format ex: |Hitem:6948:0:0:0:0:0:0:0|h[Hearthstone]|h
    -- matches anything inside square brackets ex: asdasd[abc]asdasd -> abc
    return string.match(itemLink, "%[(.+)%]")
end

function ScubaLoot_GetPlayerRGB(playerName)
    -- couldn't think of a quick way to do this w/o looping through the raid
    -- can't use UnitClass("UnitID") bc a players name is not a UnitID
    for i = 1, 40 do
        local name, _, _, _, class, _, _, _, _, _, _ = GetRaidRosterInfo(i)
        if(name == playerName) then
            -- colors from : https://wow.gamepedia.com/Class_colors
            if(class == "Warrior") then
                return 199, 156, 110
            elseif(class == "Rogue") then
                return 255, 245, 105
            elseif(class == "Mage") then
                return 64, 199, 235
            elseif(class == "Warlock") then
                return 135, 135, 237
            elseif(class == "Hunter") then
                return 171, 212, 115
            elseif(class == "Paladin") then
                return 245, 140, 186
            elseif(class == "Druid") then
                return 255, 125, 10
            elseif(class == "Priest") then
                return 255, 255, 255
            elseif(class == "Shaman") then
                return 0, 112, 222
            else
                DEFAULT_CHAT_FRAME:AddMessage("ScubaLoot_GetPlayerRGB - Error could not find " .. playerName .. "'s class")
            end
        end
    end
end


--==========================================================================================================

-- GUI specific code

-- itemLink
--    itemLink as a string
function ScubaLoot_AddMainItemToGUI(itemLink)
    local item = getglobal("ScubaLootMainItem")
    local itemText = getglobal("ScubaLootMainItemText")
    local itemName = getglobal("ScubaLootMainItemName")
    local itemIcon = getglobal("ScubaLootMainItemIcon")
    local name, texture, quality = ScubaLoot_GetNameByID(itemLink)
    itemIcon:SetTexture(texture)
    itemName:SetText(name)
    local r,g,b = GetItemQualityColor(quality)
    itemName:SetTextColor(r,g,b)
    itemIcon:SetVertexColor(1,1,1)
    itemText:SetText("Linking for: ")
    item:Show()
end

function ScubaLoot_UpdateRows()
    DEFAULT_CHAT_FRAME:AddMessage("ScubaLoot_UpdateRows")
    local list = ScubaLoot_Sort.Links

    if list then
        local r, g, b, found
        local texture, name, quality
        local item, itemPlayer, itemName, itemIcon
        for i = 1, 9 do
            item = getglobal("ScubaLootRow"..i)
            itemPlayer = getglobal("ScubaLootRow"..i.."Player")
            itemName = getglobal("ScubaLootRow"..i.."Name")
            itemIcon = getglobal("ScubaLootRow"..i.."Icon")
            if i <= table.getn(list) then
                DEFAULT_CHAT_FRAME:AddMessage("table.getn(list): " .. table.getn(list))
                name, texture, quality = ScubaLoot_GetNameByID(list[i])
                itemIcon:SetTexture(texture)
                itemName:SetText(name)
                itemPlayer:SetText(ScubaLoot_Sort.Names[i])
                r,g,b = ScubaLoot_GetPlayerRGB(ScubaLoot_Sort.Names[i])
                itemPlayer:SetTextColor(r,g,b)
                r,g,b = GetItemQualityColor(quality)
                itemName:SetTextColor(r,g,b)
                itemIcon:SetVertexColor(1,1,1)
                item:Show()
            else
                item:Hide()
            end
        end
    end
end

-- shows tooltip for items in the sort list
function ScubaLoot_ShowTooltip()
    --DEFAULT_CHAT_FRAME:AddMessage("ScubaLoot_ShowTooltip")
    local idx = this:GetID()
    if ScubaLoot_Sort.Links[idx] then
        local name, link = GetItemInfo(ScubaLoot_LinkToID(ScubaLoot_Sort.Links[idx]))
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end
end

function ScubaLoot_ShowMainItemToolTip()
    --DEFAULT_CHAT_FRAME:AddMessage("ScubaLoot_ShowMainItemToolTip")
    if ScubaLoot_ItemBeingDecided then
        local name, link = GetItemInfo(ScubaLoot_LinkToID(ScubaLoot_ItemBeingDecided))

        --DEFAULT_CHAT_FRAME:AddMessage("link to id: " .. ScubaLoot_LinkToID(ScubaLoot_ItemBeingDecided))
        --DEFAULT_CHAT_FRAME:AddMessage("getiteminfo link: " .. link)

        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end
end

function ScubaLootFrameTitleText_OnShow()
    ScubaLootFrameTitleText:SetText(ScubaLootTitle .. " v" .. ScubaLootVersion)
end

function ScubaLoot_ToggleGUI()
    if ScubaLootFrame:IsShown() then
        ScubaLootFrame:Hide()
    else
        ScubaLootFrame:Show()
    end
end

function ScubaLoot_FinishedVoting()
    local playerName = UnitName("player")
    if(FinishedVotingCheckbox:GetChecked()) then
        SendChatMessage(playerName .. " has finished voting", "RAID")
    end
end

--==========================================================================================================

-- Aditional functions

-- credit Sol
string.match = string.match or function(str, pattern)
    local tbl_res = { string.find(str, pattern) }

    if tbl_res[3] then
        return select(3, unpack(tbl_res))
    else
        return tbl_res[1], tbl_res[2]
    end
end

select = select or function(idx, ...)
    local len = table.getn(arg)

    if type(idx) == 'string' and idx == '#' then
        return len
    else
        local tbl = {}

        for i = idx, len do
            table.insert(tbl, arg[i])
        end

        return unpack(tbl)
    end
end

string.gmatch = string.gmatch or function(str, pattern)
    local init = 0

    return function()
        local tbl = { string.find(str, pattern, init) }

        local start_pos = tbl[1]
        local end_pos = tbl[2]

        if start_pos then
            init = end_pos + 1

            if tbl[3] then
                return unpack({select(3, unpack(tbl))})
            else
                return string.sub(str, start_pos, end_pos)
            end
        end
    end
end
--

function ScubaLoot_HasValue(tab, val)
    for _, value in tab do
        if value == val then
            return true
        end
    end
    return false
end

function ScubaLoot_tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            DEFAULT_CHAT_FRAME:AddMessage(formatting)
            tprint(v, indent+1)
        elseif type(v) == 'boolean' then
            DEFAULT_CHAT_FRAME:AddMessage(formatting .. tostring(v))
        else
            DEFAULT_CHAT_FRAME:AddMessage(formatting .. v)
        end
    end
end
