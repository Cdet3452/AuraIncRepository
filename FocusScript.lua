-- SettingsController
-- Location: StarterPlayer > StarterPlayerScripts > SettingsController
-- FIX: ClipsDescendants = true so close animation clips content.
-- MOBILE FIX: UIListLayout + AutomaticCanvasSize + NumberFormatter linked!

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local T                 = require(ReplicatedStorage.Modules.UITheme).Get()
local Formatter         = require(ReplicatedStorage.Modules.NumberFormatter)
local UITheme = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("UITheme"))
local T = UITheme.Get("Custom")
local UpdateHUD = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local SettingsChanged = Instance.new("BindableEvent")
SettingsChanged.Name   = "SettingsChanged"
SettingsChanged.Parent = ReplicatedStorage

local sfxEnabled   = true
local musicEnabled = true
local jumpEnabled  = true 
local panelOpen    = false

local liveSoulAuras   = 0
local liveRunEarnings = 0
local liveRate        = 0
local livePrestiges   = 0
local toggleRefs      = {}

---------------------------------------------------------------
-- GEAR BUTTON
---------------------------------------------------------------
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Name = "SettingsButton"
SettingsBtn.Size = UDim2.new(0, 36, 0, 36)
SettingsBtn.Position = UDim2.new(0, 30, 0, 86)
SettingsBtn.BackgroundColor3 = T.cardBG; SettingsBtn.BorderSizePixel = 0
SettingsBtn.Text = "⚙"; SettingsBtn.TextColor3 = T.subText
SettingsBtn.TextScaled = true; SettingsBtn.Font = T.font
SettingsBtn.ZIndex = 15; SettingsBtn.Parent = mainHUD
Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 7)
local gearStroke = Instance.new("UIStroke")
gearStroke.Color = T.panelStroke; gearStroke.Thickness = 1; gearStroke.Parent = SettingsBtn

---------------------------------------------------------------
-- PANEL (MOBILE RESPONSIVE)
---------------------------------------------------------------
local Panel = Instance.new("Frame")
Panel.Name = "SettingsPanel"
Panel.Size = UDim2.new(0.85, 0, 0.65, 0) -- Responsive Scale
Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.BackgroundColor3 = T.panelBG; Panel.BorderSizePixel = 0
Panel.Visible = false; Panel.ZIndex = 40
Panel.ClipsDescendants = true
Panel.Parent = mainHUD
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

-- Prevents Settings from being massive on PC
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(280, 380) 
sizeConstraint.Parent = Panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = T.panelStroke; panelStroke.Thickness = 2; panelStroke.Parent = Panel

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = T.headerBG; Header.BorderSizePixel = 0
Header.ZIndex = 41; Header.Parent = Panel
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, -44, 1, 0); HeaderLabel.Position = UDim2.new(0, 12, 0, 0)
HeaderLabel.BackgroundTransparency = 1; HeaderLabel.Text = "SETTINGS"
HeaderLabel.TextColor3 = T.headerText; HeaderLabel.TextScaled = true
HeaderLabel.Font = T.font; HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.ZIndex = 42; HeaderLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
CloseBtn.BackgroundColor3 = T.buttonRed; CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"; CloseBtn.TextColor3 = T.bodyText
CloseBtn.TextScaled = true; CloseBtn.Font = T.font
CloseBtn.ZIndex = 42; CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

---------------------------------------------------------------
-- SCROLL CONTAINER
---------------------------------------------------------------
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, 0, 1, -38) -- Fits under header
ScrollContainer.Position = UDim2.new(0, 0, 0, 38)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.Parent = Panel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = ScrollContainer

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = ScrollContainer

---------------------------------------------------------------
-- BUILD UI ELEMENTS
---------------------------------------------------------------
local function MakeToggleRow(labelText, settingKey)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -20, 0, 36) -- No Position needed!
	row.BackgroundColor3 = T.cardBG; row.BorderSizePixel = 0
	row.ZIndex = 41; row.Parent = ScrollContainer
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.58, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.Text = labelText
	lbl.TextColor3 = T.subText; lbl.TextScaled = true
	lbl.Font = T.fontBody; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 42; lbl.Parent = row

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 50, 0, 24); toggle.Position = UDim2.new(1, -58, 0.5, -12)
	toggle.BorderSizePixel = 0; toggle.TextScaled = true; toggle.Font = T.font
	toggle.ZIndex = 42; toggle.Parent = row
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)

	local function Refresh(isOn)
		toggle.Text             = isOn and "ON" or "OFF"
		toggle.TextColor3       = T.bodyText
		toggle.BackgroundColor3 = isOn and T.buttonGreen or T.buttonRed
	end

	-- FIX: Upgraded to handle all 3 settings
	local isOn = true
	if settingKey == "sfx" then isOn = sfxEnabled
	elseif settingKey == "music" then isOn = musicEnabled
	elseif settingKey == "jump" then isOn = jumpEnabled end

	Refresh(isOn)
	toggleRefs[settingKey] = Refresh

	toggle.MouseButton1Down:Connect(function()
		if settingKey == "sfx" then sfxEnabled = not sfxEnabled; isOn = sfxEnabled
		elseif settingKey == "music" then musicEnabled = not musicEnabled; isOn = musicEnabled
		elseif settingKey == "jump" then jumpEnabled = not jumpEnabled; isOn = jumpEnabled end

		Refresh(isOn)
		SettingsChanged:Fire(settingKey, isOn)
	end)
end

MakeToggleRow("Sound Effects", "sfx")
MakeToggleRow("Music",      "music")
MakeToggleRow("Jumping",       "jump") 

local div1 = Instance.new("Frame")
div1.Size = UDim2.new(1, -20, 0, 1)
div1.BackgroundColor3 = T.panelStroke; div1.BorderSizePixel = 0
div1.ZIndex = 41; div1.Parent = ScrollContainer

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -20, 0, 16)
statsTitle.BackgroundTransparency = 1; statsTitle.Text = "FARM STATS"
statsTitle.TextColor3 = T.subText; statsTitle.TextScaled = true
statsTitle.Font = T.font; statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.ZIndex = 41; statsTitle.Parent = ScrollContainer

local statValueRefs = {}

local function MakeStatRow(labelText, refKey)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -20, 0, 22)
	row.BackgroundTransparency = 1; row.ZIndex = 41; row.Parent = ScrollContainer

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.BackgroundTransparency = 1
	lbl.Text = labelText; lbl.TextColor3 = T.subText
	lbl.TextScaled = true; lbl.Font = T.fontBody
	lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 42; lbl.Parent = row

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.45, 0, 1, 0); val.Position = UDim2.new(0.55, 0, 0, 0)
	val.BackgroundTransparency = 1; val.Text = "0"
	val.TextColor3 = T.accentBlue; val.TextScaled = true
	val.Font = T.font; val.TextXAlignment = Enum.TextXAlignment.Right
	val.ZIndex = 42; val.Parent = row
	statValueRefs[refKey] = val
end

MakeStatRow("Soul Auras",  "soul")
MakeStatRow("This Run",    "run")
MakeStatRow("Rate",        "rate")
MakeStatRow("Prestiges",   "prestige")

local function RefreshStats()
	if statValueRefs.soul     then statValueRefs.soul.Text     = Formatter.Format(liveSoulAuras) end
	if statValueRefs.run      then statValueRefs.run.Text      = "$" .. Formatter.Format(liveRunEarnings) end
	if statValueRefs.rate     then statValueRefs.rate.Text     = "$" .. Formatter.Format(liveRate) .. "/s" end
	if statValueRefs.prestige then statValueRefs.prestige.Text = Formatter.Format(livePrestiges) end
end

local div2 = Instance.new("Frame")
div2.Size = UDim2.new(1, -20, 0, 1)
div2.BackgroundColor3 = T.panelStroke; div2.BorderSizePixel = 0
div2.ZIndex = 41; div2.Parent = ScrollContainer

local function Credit(text, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -20, 0, 14)
	l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = color
	l.TextScaled = true; l.Font = T.fontBody
	l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 41; l.Parent = ScrollContainer
end

Credit("Aura Inc",               Color3.fromRGB(85, 100, 135))
Credit("Made by MoldySugar2205", Color3.fromRGB(65, 80,  110))
Credit("Phase 4",                Color3.fromRGB(50, 65,  90))

---------------------------------------------------------------
-- PANEL TWEENS
---------------------------------------------------------------
local function OpenPanel()
	panelOpen = true; Panel.Visible = true; Panel.Size = UDim2.new(0.85, 0, 0, 0)
	RefreshStats()
	TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.85, 0, 0.65, 0) -- Responsive Target Size
	}):Play()
	UITheme.SetMenuVisible(true)
end

local function ClosePanel()
	panelOpen = false
	TweenService:Create(Panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0.85, 0, 0, 0)
	}):Play()
	UITheme.SetMenuVisible(false)
	task.delay(0.2, function() Panel.Visible = false end)
end

SettingsBtn.MouseButton1Down:Connect(function() if panelOpen then ClosePanel() else OpenPanel() end end)
CloseBtn.MouseButton1Down:Connect(ClosePanel)

UpdateHUD.OnClientEvent:Connect(function(stats)
	if stats.soulAuras   ~= nil then liveSoulAuras   = stats.soulAuras   end
	if stats.totalEarned ~= nil then liveRunEarnings = stats.totalEarned end
	if stats.rate ~= nil and stats.passiveInterval ~= nil and stats.passiveInterval > 0 then
		liveRate = stats.rate / stats.passiveInterval
	end
	if stats.prestigeCount ~= nil then livePrestiges = stats.prestigeCount end
	if stats.settings then
		if stats.settings.sfxEnabled ~= nil then
			sfxEnabled = stats.settings.sfxEnabled
			if toggleRefs.sfx then toggleRefs.sfx(sfxEnabled) end
			SettingsChanged:Fire("sfx", sfxEnabled)
		end
		if stats.settings.musicEnabled ~= nil then
			musicEnabled = stats.settings.musicEnabled
			if toggleRefs.music then toggleRefs.music(musicEnabled) end
			SettingsChanged:Fire("music", musicEnabled)
		end
		-- THIS is the only part that goes inside the HUD update:
		if stats.settings.jumpEnabled ~= nil then
			jumpEnabled = stats.settings.jumpEnabled
			if toggleRefs.jump then toggleRefs.jump(jumpEnabled) end
			SettingsChanged:Fire("jump", jumpEnabled)
		end
	end

	if panelOpen then RefreshStats() end
end)

---------------------------------------------------------------
-- JUMP ENFORCER LOGIC (FOOLPROOF FIX)
-- Must be OUTSIDE the UpdateHUD event at the bottom of the script!
---------------------------------------------------------------
local defaultJumpHeight = 7.2
local defaultJumpPower = 50

local function UpdateJumpState(character, canJump)
	if not character then return end
	local humanoid = character:WaitForChild("Humanoid", 3)
	if humanoid then
		-- Save their normal jump stats just in case you add jump upgrades later
		if humanoid.JumpHeight > 0 then defaultJumpHeight = humanoid.JumpHeight end
		if humanoid.JumpPower > 0 then defaultJumpPower = humanoid.JumpPower end

		if canJump then
			humanoid.UseJumpPower = not humanoid.UseJumpPower -- Forces an update
			humanoid.JumpHeight = defaultJumpHeight
			humanoid.JumpPower = defaultJumpPower
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		else
			humanoid.JumpHeight = 0
			humanoid.JumpPower = 0
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end
	end
end

-- 1. Apply when the player flips the setting switch
SettingsChanged.Event:Connect(function(key, value)
	if key == "jump" then
		UpdateJumpState(player.Character, value)
	end
end)

-- 2. Re-apply automatically if the player resets/respawns
player.CharacterAdded:Connect(function(char)
	-- Slight delay to ensure the character is fully loaded before changing stats
	task.wait(0.1) 
	UpdateJumpState(char, jumpEnabled)
end)

-- 3. Catch the player when they first load in
if player.Character then
	UpdateJumpState(player.Character, jumpEnabled)
end
