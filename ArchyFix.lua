local f = CreateFrame("Frame")
f:Hide()

f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)

	local version = GetAddOnMetadata("Archy", "Version")
	if version ~= "@project-version@" then
		local x, y, z = strsplit(".", version)
		if tonumber(x) > 1 or tonumber(y) > 8 or tonumber(z) > 43 then
			DEFAULT_CHAT_FRAME:AddMessage("\124cffffb000ArchyFix:\124r Archy has been updated. Check for an update to ArchyFix in case some bugs have been fixed!")
		end
	end

	self:Show()
end)

local db, Media
local function FixAllTheThings()
	local settings = db.profile.artifact

	-- Fix wrong texture on the skill bar:
	ArchyArtifactFrameSkillBar:SetStatusBarTexture(Media:Fetch("statusbar", settings.fragmentBarTexture))

	-- Fix skill bar texture sometimes appearing behind the background:
	ArchyArtifactFrameSkillBarBar:SetDrawLayer("ARTWORK")

	-- Fix wrong fonts on the fragment bars:
	local fontA = Media:Fetch("font", settings.font.name)
	local sizeA, outlineA, colorA, shadowA = settings.font.size, settings.font.outline, settings.font.color, settings.font.shadow

	local fontF = Media:Fetch("font", settings.fragmentFont.name)
	local sizeF, outlineF, colorF, shadowF = settings.fragmentFont.size, settings.fragmentFont.outline, settings.fragmentFont.color, settings.fragmentFont.shadow

	for i = 1, #ArchyArtifactFrame.children do
		local Bar = ArchyArtifactFrame.children[i].fragmentBar

		Bar.artifact:SetFont(fontA, sizeA, outlineA)
		Bar.artifact:SetTextColor(colorA.r, colorA.g, colorA.b, colorA.a)
		Bar.artifact:SetShadowOffset(shadowA and 1 or 0, shadowA and -1 or 0)

		Bar.fragments:SetFont(fontF, sizeF, outlineF)
		Bar.fragments:SetTextColor(colorF.r, colorF.g, colorF.b, colorF.a)
		Bar.fragments:SetShadowOffset(shadowF and 1 or 0, shadowF and -1 or 0)
	end
end

local t = 5
f:SetScript("OnUpdate", function(self, elapsed)
	t = t - elapsed
	if t > 0 then return end
	self:Hide()

	Media = LibStub("LibSharedMedia-3.0")

	-- DB is annoyingly "hidden" so we have to dig for it:
	for tbl in pairs(LibStub("AceDB-3.0").db_registry) do
		if tbl.sv == ArchyDB then
			db = tbl
			break
		end
	end

	-- Fix digsite data failing to initialize when TomTom is enabled:
	SetMapZoom(GetCurrentMapContinent())
	Archy:ARTIFACT_DIG_SITE_UPDATED()
	Archy:UpdateDigSiteFrame()
	SetMapToCurrentZone()

	-- Fix settings failing to apply to artifact frame at load:
	Archy:ConfigUpdated()
	FixAllTheThings()

	-- And some settings revert to default when toggling the frame:
	if not self.hooked then
		ArchyArtifactFrame:HookScript("OnShow", FixAllTheThings)
		self.hooked = true
	end
end)

SLASH_ARCHYFIX1 = "/archyfix"
SlashCmdList.ARCHYFIX = function() f:Show() end