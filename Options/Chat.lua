local AntiRaidTools = AntiRaidTools

local reqVersionsTimer = nil

function AntiRaidTools:HandleChatCommand(input)
    if not input or input:trim() == "" then
        self:Print("Usage: /art [config,show,hide,versions]")
    else
        local trimmed = input:trim()
        
        if trimmed == "config" then
            InterfaceOptionsFrame_OpenToCategory("Anti Raid Tools")
        elseif trimmed == "show" or trimmed == "hide" then
            self.db.profile.overview.show = trimmed == "show" and true or false
            self:UpdateOverview()
        elseif trimmed == "versions" then
            if not reqVersionsTimer then
                self:SyncReqVersions()

                reqVersionsTimer = C_Timer.NewTimer(10, function()
                    reqVersionsTimer = nil

                    for version, players in pairs(self:SyncGetClientVersions()) do
                        if not version then
                            version = "Unknown"
                        end

                        print("[ART] " .. version .. ": " .. self:StringJoin(players))
                    end
                end)
            end
        elseif trimmed == "debug" then
            self.DEBUG = not self.DEBUG
            print("[ART] debug", self.DEBUG)
        elseif trimmed == "teststart" then
            self:InternalTestStart()
        elseif trimmed == "testend" then
            self:InternalTestEnd()
        end
    end
end
