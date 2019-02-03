ScubaLootTitle = "ScubaLoot"
ScubaLootVersion = "1.0"

SlashCmdList["SLASH_SCUBALOOT"] = function() end

SLASH_SCUBALOOT1 = "/sl"
function SlashCmdList.SCUBALOOT(args)
    DEFAULT_CHAT_FRAME:AddMessage("Check")
    if ScubaLootFrame:IsShown() then
        ScubaLootFrame:Hide();
    else
        ScubaLootFrame:Show();
    end

end

function ScubaLoot_OnLoad()
    DEFAULT_CHAT_FRAME:AddMessage("onload")
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("CHAT_MSG_RAID")
    this:RegisterEvent("CHAT_MSG_RAID_LEADER")
end

function ScubaLoot_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
    if(event == "VARIABLES_LOADED") then
        this:UnregisterEvent("VARIABLES_LOADED")
        ScubaLoot_Init()
    elseif(event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") then
        checkForItemLinks(arg1, arg2)
    end
end

-- arg1
--    chat message
-- arg2
--    author
function checkForItemLinks(arg1, arg2)
    local items = ""
    local added = false
    for item in string.gmatch(arg1, "|.-]|h") do
        items = items .. item
        added = true
    end
    -- output to raid
    if(added == true) then
        DEFAULT_CHAT_FRAME:AddMessage(arg2 .. " linked: " .. items)
    end
end

function ScubaLoot_OnUpdate()
    DEFAULT_CHAT_FRAME:AddMessage("onupdate")
end

function ScubaLoot_Init()
    DEFAULT_CHAT_FRAME:AddMessage("Init")
end

function ScubaLootFrameTitleText_OnShow()
    ScubaLootFrameTitleText:SetText(ScubaLootTitle .. " v" .. ScubaLootVersion)
end

-- credit Sol
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
