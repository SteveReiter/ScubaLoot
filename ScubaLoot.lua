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