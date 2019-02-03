--==========================================================================================================

-- Init functions and globals

ScubaLootTitle = "CLC"
ScubaLootVersion = "1.0"

ScubaLoot_SessionOpen = true
ScubaLoot_QueuedItems = {} -- if multiple items are raid warning'd then they will go here

ScubaLoot_Sort = {
    Names = {}, -- names of the people linking
    Links = {} -- items that they linked
}

SlashCmdList["SLASH_SCUBALOOT"] = function() end

SLASH_SCUBALOOT1 = "/sl"
function SlashCmdList.SCUBALOOT(args)
    ScubaLoot_ToggleGUI()

    -- todo remove this later
    args = {args}
    if(ScubaLoot_HasValue(args, "test")) then
        test()
    end
end

function ScubaLoot_OnLoad()
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("CHAT_MSG_RAID")
    this:RegisterEvent("CHAT_MSG_RAID_LEADER")
    this:RegisterEvent("CHAT_MSG_RAID_WARNING")
end

function ScubaLoot_Init()
    DEFAULT_CHAT_FRAME:AddMessage("Init")
    -- reinitialize globals
    ScubaLoot_Sort.Names = {}
    ScubaLoot_Sort.Links = {}
end

-- todo remove this later
function test()
    local id = "|Hitem:6948:0:0:0:0:0:0:0|h[Hearthstone]|h"
    local name, texture, quality = ScubaLoot_GetNameByID()
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
        if(ScubaLoot_HasValue(ScubaLoot_Sort.Names, arg2) == false) then
            table.insert(ScubaLoot_Sort.Names, arg2) -- add name
            table.insert(ScubaLoot_Sort.Links, arg1) -- add items
        else
            for k, v in pairs(ScubaLoot_Sort.Names) do
                if(v == arg2) then
                    ScubaLoot_Sort.Links[k] = arg1
                end
            end
        end
        ScubaLoot_ScrollFrameUpdate()
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
-- arg2
--    author
function ScubaLoot_OpenLootSession(arg1)
    -- if only one item is linked in rw then start a loot session
    -- do not start if arg1 contains "roll"
    local itemLinks = ScubaLoot_GetItemLinks(arg1)
    if(itemLinks[1] and string.find(arg1, "roll") == nil) then

        -- todo start a normal loot session
    elseif(itemLinks[1] and string.find(arg1, "roll") ~= nil) then
        -- todo start a roll loot session
    end
end

-- itemLinks
--    one or more linked items in a table
function ScubaLoot_UpdateMainItem(itemLinks)
    ScubaLoot_QueuedItems = itemLinks
    if(ScubaLoot_QueuedItems[1]) then
        local nextItem = table.remove(ScubaLoot_QueuedItems, 1)
        ScubaLoot_AddMainItemToGUI(nextItem)
    end
end

function ScubaLoot_GetNameByID(itemLink)
    local name, _, quality, _, _, _, _, _, texture = GetItemInfo(ScubaLoot_LinkToID(itemLink) or "")
    return name, texture, quality
end

function ScubaLoot_LinkToID(itemLink)
    -- item link format ex: |Hitem:6948:0:0:0:0:0:0:0|h[Hearthstone]|h
    -- matches anything inside the first 2 :'s ex: |Hitem:6948:0:0:0:0: -> 6948
    return string.match(itemLink, ":(%d+)")
end


--==========================================================================================================

-- GUI specific code

-- itemLink
--    itemLink as a string
function ScubaLoot_AddMainItemToGUI(itemLink)
    ScubaLootMainItem:SetText(itemLink)
end

function ScubaLoot_ScrollFrameUpdate()
    local offset = FauxScrollFrame_GetOffset(ScubaLootScrollFrame)
    local list = ScubaLoot_Sort.Links
    FauxScrollFrame_Update(ScubaLootScrollFrame, list and table.getn(list) or 0, 9, 24)

    if list then
        local r, g, b, found
        local texture, name, quality
        local item, itemName, itemIcon
        for i = 1, 9 do
            item = getglobal("ScubaLootSort"..i)
            itemName = getglobal("ScubaLootSort"..i.."Name")
            itemIcon = getglobal("ScubaLootSort"..i.."Icon")
            idx = offset+i
            if idx<=table.getn(list) then
                name, texture, quality = ScubaLoot_GetNameByID(list[idx])
                itemIcon:SetTexture(texture)
                itemName:SetText(ScubaLoot_Sort.Names[idx] .. ": " .. name)
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
    local idx = FauxScrollFrame_GetOffset(ScubaLootScrollFrame) + this:GetID()
    local _, itemLink = GetItemInfo(ScubaLoot_LinkToID(ScubaLoot_Sort.Links[idx]) or "")
    if itemLink and TrinketMenuOptions.ShowTooltips=="ON" then
        TrinketMenu.AnchorTooltip()
        GameTooltip:SetHyperlink(itemLink)
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
