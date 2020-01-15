local CombatLogMilliseconds = CreateFrame("Frame")

function CombatLogMilliseconds:Print(...)
	print("|cffF0E68C[CombatLogMilliseconds]|cffFFFFFF:", ...)
end

function CombatLogMilliseconds:OnAddonLoaded()
	self:Print("Loaded")
end

function CombatLogMilliseconds:AddTimestamp(timestamp, text)
	if timestamp then
		local millisec = (timestamp - math.floor(timestamp)) * 1000
		return "|cFFA6A6A6["..format("%s.%03d", date("%H:%M:%S", timestamp), millisec).."]|r "..text
	else
		return text
	end
end

CombatLogMilliseconds:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == "CombatLogMilliseconds" then
			self:OnAddonLoaded()
		elseif ... == "Blizzard_CombatLog" then
			for _, filter in ipairs(Blizzard_CombatLog_Filters.filters) do
				filter.settings.timestamp = false
			end

			self.OG_COMBATLOG_AddMessage = COMBATLOG.AddMessage
			COMBATLOG.AddMessage = function(o, text, r, g, b, a, ...)
				local timestamp = CombatLogGetCurrentEventInfo()
				text = self:AddTimestamp(timestamp, text)
				return self.OG_COMBATLOG_AddMessage(o, text, r, g, b, a, ...)
			end

			self.OG_COMBATLOG_BackFillMessage = COMBATLOG.BackFillMessage
			COMBATLOG.BackFillMessage = function(o, text, r, g, b, a, ...)
				local timestamp = CombatLogGetCurrentEntry()
				text = self:AddTimestamp(timestamp, text)
				return self.OG_COMBATLOG_BackFillMessage(o, text, r, g, b, a, ...)
			end
		end
	end
end)

CombatLogMilliseconds:RegisterEvent("ADDON_LOADED")
