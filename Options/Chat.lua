local AntiRaidTools = AntiRaidTools

function AntiRaidTools:HandleChatCommand(input)
    if not input or input:trim() == "" then
        self:Print("Usage: /art [config,show,hide]")
    else
        local trimmed = input:trim()
        
        if trimmed == "config" then
            InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
        elseif trimmed == "show" or trimmed == "hide" then
            self.db.profile.overview.show = trimmed == "show" and true or false
            self:UpdateOverview()
        elseif trimmed == "teststart" then
            self:InternalTestStart()
        elseif trimmed == "testend" then
            self:InternalTestEnd()
        end
    end
end
