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
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("CHAT_MSG_ADDON")
end

function ScubaLoot_OnEvent()
    if(event == "VARIABLES_LOADED") then
        this:UnregisterEvent("VARIABLES_LOADED")
        ScubaLoot_Init()
    elseif(event == "CHAT_MSG_ADDON") then
        DEFAULT_CHAT_FRAME:AddMessage("message")
    end
end

function ScubaLoot_Init()
    DEFAULT_CHAT_FRAME:AddMessage("Init")
end

function ScubaLootFrameTitleText_OnShow()
    ScubaLootFrameTitleText:SetText(ScubaLootTitle .. " v" .. ScubaLootVersion)
end