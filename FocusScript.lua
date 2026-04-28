-- AchievementController
-- Location: StarterPlayer > StarterPlayerScripts > AchievementController

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local UITheme           = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
local T                 = UITheme.Get("Custom")
local SoundConfig       = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SoundConfig"))
local AchievementConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AchievementConfig"))
local TierConfig        = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("TierConfig"))
local UpdateHUD         = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local panelOpen = false
local activeTab = "Challenges"
local latestStats = {}

local function PlayUI(id) if shared.PlayUISound then shared.PlayUISound(id) end end

---------------------------------------------------------------
-- 1. THE CIRCULAR BUTTON (Top Left, Next to Settings)
---------------------------------------------------------------
local AchieveBtn = Instance.new("ImageButton", mainHUD)
AchieveBtn.Name = "AchievementButton"
AchieveBtn.Size = UDim2.new(0, 46, 0, 46)
AchieveBtn.Position = UDim2.new(0, 80, 0, 20) -- Positioned right next to Settings!
AchieveBtn.BackgroundColor3 = T.buttonSecondary
AchieveBtn.BorderSizePixel = 0
AchieveBtn.AutoButtonColor = false
AchieveBtn.ZIndex = 15
Instance.new("UICorner", AchieveBtn).CornerRadius = UDim.new(0.5, 0)
local btnStroke = Instance.new("UIStroke", AchieveBtn)
btnStroke.Color = T.accentGold; btnStroke.Thickness = 2

-- Use an ImageLabel for your custom Icon
local btnIcon = Instance.new("ImageLabel", AchieveBtn)
btnIcon.Size = UDim2.new(0.6, 0, 0.6, 0); btnIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
btnIcon.BackgroundTransparency = 1; btnIcon.ScaleType = Enum.ScaleType.Fit
btnIcon.Image = "rbxassetid://0" -- PLACEHOLDER ICON ID

---------------------------------------------------------------
-- 2. THE MAIN PANEL
---------------------------------------------------------------
local Panel = Instance.new("Frame", mainHUD)
Panel.Name = "AchievementPanel"; Panel.Size = UDim2.new(0.85, 0, 0.75, 0); Panel.Position = UDim2.new(0.5, 0, 0.5, 0); Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.BackgroundColor3 = T.panelBG; Panel.BorderSizePixel = 0; Panel.Visible = false; Panel.ZIndex = 40; Panel.ClipsDescendants = true
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)
local sizeConstraint = Instance.new("UISizeConstraint", Panel); sizeConstraint.MaxSize = Vector2.new(500, 550) 
local panelStroke = Instance.new("UIStroke", Panel); panelStroke.Color = T.panelStroke; panelStroke.Thickness = 2

local Header = Instance.new("Frame", Panel)
Header.Size = UDim2.new(1, 0, 0, 44); Header.BackgroundColor3 = T.headerBG; Header.BorderSizePixel = 0; Header.ZIndex = 41
local TitleLabel = Instance.new("TextLabel", Header); TitleLabel.Size = UDim2.new(1, -50, 1, 0); TitleLabel.Position = UDim2.new(0, 14, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "PROGRESSION"; TitleLabel.TextColor3 = T.headerText; TitleLabel.TextScaled = true; TitleLabel.Font = T.font; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
local CloseBtn = Instance.new("TextButton", Header); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -36, 0.5, -14); CloseBtn.BackgroundColor3 = T.buttonRed; CloseBtn.Text = "X"; CloseBtn.TextColor3 = T.headerText; CloseBtn.TextScaled = true; CloseBtn.Font = T.font; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local TabBar = Instance.new("Frame", Panel)
TabBar.Size = UDim2.new(1, -20, 0, 36); TabBar.Position = UDim2.new(0, 10, 0, 50); TabBar.BackgroundTransparency = 1; TabBar.ZIndex = 41
local tabBtns = {}; local scrolls = {}

local function MakeTab(name, text, scaleX)
	local btn = Instance.new("TextButton", TabBar); btn.Size = UDim2.new(0.25, -4, 1, 0); btn.Position = UDim2.new(scaleX, 0, 0, 0); btn.BackgroundColor3 = T.buttonSecondary; btn.Text = text; btn.TextColor3 = T.bodyText; btn.TextScaled = true; btn.Font = T.font; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	tabBtns[name] = btn

	local sf = Instance.new("ScrollingFrame", Panel); sf.Size = UDim2.new(1, -20, 1, -96); sf.Position = UDim2.new(0, 10, 0, 96); sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 4; sf.Visible = false
	local layout = Instance.new("UIListLayout", sf); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end)
	scrolls[name] = sf

	btn.MouseButton1Down:Connect(function()
		PlayUI(SoundConfig.UIClick or "")
		activeTab = name
		for k, b in pairs(tabBtns) do b.BackgroundColor3 = (k == name) and T.panelStroke or T.buttonSecondary end
		for k, s in pairs(scrolls) do s.Visible = (k == name) end
	end)
end

MakeTab("Challenges", "Boosts", 0)
MakeTab("Index", "Auras", 0.25)
MakeTab("Badges", "Badges", 0.50)
MakeTab("Leaderboard", "Top 10", 0.75)

---------------------------------------------------------------
-- 3. DYNAMIC CONTENT BUILDER
---------------------------------------------------------------
local function CreateRow(parent, title, desc, iconImage, iconColor, statusText, statusColor)
	local row = Instance.new("Frame", parent); row.Size = UDim2.new(1, 0, 0, 64); row.BackgroundColor3 = T.cardBG; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", row); stroke.Color = iconColor; stroke.Thickness = 1

	-- Image Support Added!
	local icon = Instance.new("ImageLabel", row); icon.Size = UDim2.new(0, 40, 0, 40); icon.Position = UDim2.new(0, 12, 0.5, -20); icon.BackgroundColor3 = iconColor; icon.Image = iconImage; icon.ScaleType = Enum.ScaleType.Fit; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

	local tLbl = Instance.new("TextLabel", row); tLbl.Size = UDim2.new(0.6, 0, 0, 20); tLbl.Position = UDim2.new(0, 64, 0, 10); tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = T.bodyText; tLbl.TextScaled = true; tLbl.Font = T.font; tLbl.TextXAlignment = Enum.TextXAlignment.Left
	local dLbl = Instance.new("TextLabel", row); dLbl.Size = UDim2.new(0.6, 0, 0, 16); dLbl.Position = UDim2.new(0, 64, 0, 32); dLbl.BackgroundTransparency = 1; dLbl.Text = desc; dLbl.TextColor3 = T.subText; dLbl.TextScaled = true; dLbl.Font = T.fontBody; dLbl.TextXAlignment = Enum.TextXAlignment.Left
	local sLbl = Instance.new("TextLabel", row); sLbl.Size = UDim2.new(0, 80, 0, 24); sLbl.Position = UDim2.new(1, -90, 0.5, -12); sLbl.BackgroundTransparency = 1; sLbl.Text = statusText; sLbl.TextColor3 = statusColor; sLbl.TextScaled = true; sLbl.Font = T.font; sLbl.TextXAlignment = Enum.TextXAlignment.Right

	UITheme.Apply(row, "Card")
end

local function RefreshData()
	-- 1. Clear Old Data
	for _, sf in pairs(scrolls) do
		for _, child in ipairs(sf:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
	end

	-- 2. Build Challenges
	for _, chal in ipairs(AchievementConfig.Challenges) do
		local current = latestStats[chal.statKey] or 0
		local isDone = current >= chal.goal
		local statusText = isDone and "UNLOCKED" or (current .. " / " .. chal.goal)
		local statusColor = isDone and T.buttonGreen or T.subText
		CreateRow(scrolls["Challenges"], chal.title, chal.rewardText, chal.iconId, T.accentBlue, statusText, statusColor)
	end

	-- 3. Build Aura Index
	for i, tier in ipairs(TierConfig.Tiers) do
		local discovered = (latestStats.totalCubesProduced or 0) > 0 -- Simplified discovery check
		if tier.name == "Legendary" then discovered = (latestStats.totalLegendaryCubes or 0) > 0 end

		local statusText = discovered and "Found" or "???"
		local statusColor = discovered and T.buttonGreen or T.buttonRed
		CreateRow(scrolls["Index"], tier.name .. " Aura", "Multiplier: " .. tier.multiplier .. "x", "rbxassetid://0", tier.color, statusText, statusColor)
	end

	-- 4. Build Badges (Static for now, driven by Server granting them)
	for _, badge in ipairs(AchievementConfig.Badges) do
		CreateRow(scrolls["Badges"], badge.title, badge.desc, badge.iconId, T.accentGold, "BADGE", T.subText)
	end

	-- 5. Leaderboard Placeholder
	CreateRow(scrolls["Leaderboard"], "1. MoldySugar2205", "Total Earnings", "rbxassetid://0", T.accentGold, "Top Player", T.accentGreen)
end

UpdateHUD.OnClientEvent:Connect(function(stats)
	-- ✨ THE FIX: Merges new data instead of deleting old data!
	for key, value in pairs(stats) do
		latestStats[key] = value
	end
	
	if panelOpen then RefreshData() end
end)

---------------------------------------------------------------
-- 4. BUTTON JUICE & OPEN/CLOSE
---------------------------------------------------------------
local function AddButtonJuice(btn)
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	btn.MouseEnter:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1.08}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1}):Play() end)
	btn.MouseButton1Down:Connect(function() TweenService:Create(scale, TweenInfo.new(0.1), {Scale = 0.9}):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play() end)
end

AddButtonJuice(AchieveBtn); AddButtonJuice(CloseBtn)

AchieveBtn.MouseButton1Down:Connect(function()
	PlayUI(SoundConfig.UIOpen or ""); panelOpen = true; Panel.Visible = true; Panel.Size = UDim2.new(0.85, 0, 0, 0)
	tabBtns[activeTab].BackgroundColor3 = T.panelStroke; scrolls[activeTab].Visible = true
	RefreshData()
	TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.85, 0, 0.75, 0)}):Play()
	UITheme.SetMenuVisible(true)
end)

CloseBtn.MouseButton1Down:Connect(function()
	PlayUI(SoundConfig.UIClose or ""); panelOpen = false
	TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0.85, 0, 0, 0)}):Play()
	UITheme.SetMenuVisible(false); task.delay(0.25, function() Panel.Visible = false end)
end)

task.spawn(function()
	task.wait(1)
	UITheme.Apply(Panel, "Panel"); UITheme.Apply(Header, "TitleBar"); UITheme.ApplyShine(Panel)
end)


-- BoostController
-- Location: StarterPlayer > StarterPlayerScripts > BoostController
-- FIX: Active boost strip now stacks vertically (was horizontal).
--      Active Boosts use Scale + AspectRatio to fit mobile and PC.
--      Shop Cards fixed and restored to original sizes.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local AdminConfig       = require(ReplicatedStorage.Modules.AdminConfig)
local T                 = require(ReplicatedStorage.Modules.UITheme).Get()
local SoundConfig       = require(ReplicatedStorage.Modules.SoundConfig)
local BoostConfig       = require(ReplicatedStorage.Modules.BoostConfig) 
local AchievementConfig = require(ReplicatedStorage.Modules.AchievementConfig)
local UITheme = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("UITheme"))
local T = UITheme.Get("Custom")
local BuyBoost      = ReplicatedStorage.RemoteEvents:WaitForChild("BuyBoost")
local ActivateBoost = ReplicatedStorage.RemoteEvents:WaitForChild("ActivateBoost")
local BoostUpdated  = ReplicatedStorage.RemoteEvents:WaitForChild("BoostUpdated")
local UpdateHUD     = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local boostState = {}
local panelOpen  = false
local liveGold   = 0

local BOOST_ORDER  = { "AuraRush", "SpawnBoost", "SoulBoost", "BoostBeacon50x", "CashCheck" } -- Add your new IDs here!
local BOOST_COLORS = {
	AuraRush       = Color3.fromRGB(60,  160, 255),
	SpawnBoost     = Color3.fromRGB(255, 160, 40),
	SoulBoost      = Color3.fromRGB(180, 60,  255),
	BoostBeacon50x = Color3.fromRGB(255, 50,  50),  -- Example red
	CashCheck      = Color3.fromRGB(50,  255, 100), -- Example green
}

local function PlayUI(id)
	if shared.PlayUISound then shared.PlayUISound(id) end
end

local function FormatTime(s)
	s = math.ceil(s or 0)
	if s <= 0 then return "0:00" end
	return string.format("%d:%02d", math.floor(s/60), s % 60)
end

---------------------------------------------------------------
-- ACTIVE BOOST STRIP (MOBILE & PC SCALING FIX)
---------------------------------------------------------------
local BoostStrip = Instance.new("Frame")
BoostStrip.Name = "ActiveBoostStrip"
BoostStrip.Size = UDim2.new(0.14, 0, 0.5, 0) 
BoostStrip.AnchorPoint = Vector2.new(1, 0)
BoostStrip.Position = UDim2.new(0.98, 0, 0.5, 0) 
BoostStrip.BackgroundTransparency = 1

-- FIX 1: Pushed ZIndex to 60 so it appears on top of the Shop Menu!
BoostStrip.ZIndex = 60; BoostStrip.Visible = false; BoostStrip.Parent = mainHUD

local StripLayout = Instance.new("UIListLayout")
StripLayout.FillDirection = Enum.FillDirection.Vertical
StripLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right 
StripLayout.VerticalAlignment = Enum.VerticalAlignment.Top
StripLayout.Padding = UDim.new(0, 6)
StripLayout.Parent = BoostStrip

local stripSlots = {}

for _, boostId in ipairs(BOOST_ORDER) do
	local cfg   = BoostConfig.Get(boostId)
	if not cfg then continue end
	local color = BOOST_COLORS[boostId]

	local slot = Instance.new("Frame")
	slot.Name = "Slot_" .. boostId
	-- FIX 2: 100% responsive width, but guaranteed 40px readable height! (No more invisible squish)
	slot.Size = UDim2.new(1, 0, 0, 40)  
	slot.BackgroundColor3 = T.cardBG; slot.BorderSizePixel = 0
	slot.ZIndex = 61; slot.Visible = false; slot.Parent = BoostStrip
	Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 7)
	local ss = Instance.new("UIStroke"); ss.Color = color; ss.Thickness = 1.5; ss.Parent = slot

	-- Icon on the left
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0.2, 0, 1, 0)
	iconLbl.Position = UDim2.new(0, 4, 0, 0)
	iconLbl.BackgroundTransparency = 1; iconLbl.Text = cfg.icon or "?"
	iconLbl.TextScaled = true; iconLbl.Font = T.font
	iconLbl.ZIndex = 62; iconLbl.Parent = slot

	-- Boost name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0.55, 0)
	nameLbl.Position = UDim2.new(0.25, 0, 0, 2)
	nameLbl.BackgroundTransparency = 1; nameLbl.Text = cfg.displayName or boostId
	nameLbl.TextColor3 = color; nameLbl.TextScaled = true
	nameLbl.Font = T.font; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.ZIndex = 62; nameLbl.Parent = slot

	-- Timer on the right
	local timeLbl = Instance.new("TextLabel")
	timeLbl.Name = "TimeLabel"
	timeLbl.Size = UDim2.new(0.25, 0, 0.55, 0)
	timeLbl.Position = UDim2.new(0.7, -4, 0, 2)
	timeLbl.BackgroundTransparency = 1; timeLbl.Text = "0:30"
	timeLbl.TextColor3 = color; timeLbl.TextScaled = true
	timeLbl.Font = T.font; timeLbl.TextXAlignment = Enum.TextXAlignment.Right
	timeLbl.ZIndex = 62; timeLbl.Parent = slot

	-- Stack count below name
	local stackLbl = Instance.new("TextLabel")
	stackLbl.Name = "StackLabel"
	stackLbl.Size = UDim2.new(0.5, 0, 0.4, 0)
	stackLbl.Position = UDim2.new(0.25, 0, 0.5, 0)
	stackLbl.BackgroundTransparency = 1; stackLbl.Text = ""
	stackLbl.TextColor3 = T.subText; stackLbl.TextScaled = true
	stackLbl.Font = T.fontBody; stackLbl.TextXAlignment = Enum.TextXAlignment.Left
	stackLbl.ZIndex = 62; stackLbl.Parent = slot

	stripSlots[boostId] = { slot = slot, timeLbl = timeLbl, stackLbl = stackLbl }
end

---------------------------------------------------------------
-- BOOSTS BUTTON
---------------------------------------------------------------
local BoostsBtn = Instance.new("TextButton")
BoostsBtn.Name = "BoostsButton"
BoostsBtn.Size = UDim2.new(0, 80, 0, 40)
BoostsBtn.Position = UDim2.new(1, -90, 1, -100)
BoostsBtn.BackgroundColor3 = T.buttonPrimary; BoostsBtn.BorderSizePixel = 0
BoostsBtn.Text = "Boosts"; BoostsBtn.TextColor3 = T.headerText
BoostsBtn.TextScaled = true; BoostsBtn.Font = T.font
BoostsBtn.ZIndex = 10; BoostsBtn.Parent = mainHUD
BoostsBtn:SetAttribute("TutorialTarget", "BoostsButton")
Instance.new("UICorner", BoostsBtn).CornerRadius = UDim.new(0, 8)
local bbStroke = Instance.new("UIStroke")
bbStroke.Color = T.accentPurple; bbStroke.Thickness = 0; bbStroke.Parent = BoostsBtn

---------------------------------------------------------------
-- BOOST SHOP PANEL
---------------------------------------------------------------
local ShopPanel = Instance.new("Frame")
ShopPanel.Name = "BoostShopPanel"
ShopPanel.Size = UDim2.new(0.85, 0, 0.8, 0) 
ShopPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
ShopPanel.AnchorPoint = Vector2.new(0.5, 0.5) 
ShopPanel.BackgroundColor3 = T.panelBG; ShopPanel.BorderSizePixel = 0
ShopPanel.Visible = false; ShopPanel.ZIndex = 40
ShopPanel.ClipsDescendants = true
ShopPanel.Parent = mainHUD
Instance.new("UICorner", ShopPanel).CornerRadius = UDim.new(0, 14)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(340, 480)
sizeConstraint.Parent = ShopPanel

local shopStroke = Instance.new("UIStroke")
shopStroke.Color = T.panelStroke; shopStroke.Thickness = 2; shopStroke.Parent = ShopPanel

local ShopHeader = Instance.new("Frame")
ShopHeader.Size = UDim2.new(1, 0, 0, 44)
ShopHeader.BackgroundColor3 = T.headerBG; ShopHeader.BorderSizePixel = 0
ShopHeader.ZIndex = 41; ShopHeader.Parent = ShopPanel
Instance.new("UICorner", ShopHeader).CornerRadius = UDim.new(0, 14)

local ShopTitle = Instance.new("TextLabel")
ShopTitle.Size = UDim2.new(1, -50, 1, 0); ShopTitle.Position = UDim2.new(0, 14, 0, 0)
ShopTitle.BackgroundTransparency = 1; ShopTitle.Text = "BOOST SHOP"
ShopTitle.TextColor3 = T.headerText; ShopTitle.TextScaled = true
ShopTitle.Font = T.font; ShopTitle.TextXAlignment = Enum.TextXAlignment.Left
ShopTitle.ZIndex = 42; ShopTitle.Parent = ShopHeader

local ShopClose = Instance.new("TextButton")
ShopClose.Size = UDim2.new(0, 28, 0, 28); ShopClose.Position = UDim2.new(1, -36, 0.5, -14)
ShopClose.BackgroundColor3 = T.buttonRed; ShopClose.BorderSizePixel = 0
ShopClose.Text = "X"; ShopClose.TextColor3 = T.headerText
ShopClose.TextScaled = true; ShopClose.Font = T.font
ShopClose.ZIndex = 42; ShopClose.Parent = ShopHeader
Instance.new("UICorner", ShopClose).CornerRadius = UDim.new(0, 5)

local GoldLabel = Instance.new("TextLabel")
GoldLabel.Size = UDim2.new(1, -24, 0, 22); GoldLabel.Position = UDim2.new(0, 12, 0, 50)
GoldLabel.BackgroundTransparency = 1; GoldLabel.Text = "? 0 Golden Auras"
GoldLabel.TextColor3 = T.accentGold; GoldLabel.TextScaled = true
GoldLabel.Font = T.font; GoldLabel.TextXAlignment = Enum.TextXAlignment.Right
GoldLabel.ZIndex = 41; GoldLabel.Parent = ShopPanel

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, 0, 1, -80) 
ScrollContainer.Position = UDim2.new(0, 0, 0, 80)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.Parent = ShopPanel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = ScrollContainer

local cardRefs = {}

local function BuildCards()
	for i, boostId in ipairs(BOOST_ORDER) do
		local cfg = BoostConfig.Get(boostId)
		if not cfg then continue end
		local color = BOOST_COLORS[boostId]

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -16, 0, 98) -- ORIGINAL SHOP CARD SIZE IS BACK!
		card.BackgroundColor3 = T.cardBG; card.BorderSizePixel = 0
		card.ZIndex = 41; card.Parent = ScrollContainer
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

		local cs = Instance.new("UIStroke"); cs.Color = color; cs.Thickness = 1.5; cs.Parent = card

		local iconLbl = Instance.new("TextLabel")
		iconLbl.Size = UDim2.new(0, 36, 0, 36); iconLbl.Position = UDim2.new(0, 8, 0, 8)
		iconLbl.BackgroundTransparency = 1; iconLbl.Text = cfg.icon or "?"
		iconLbl.TextScaled = true; iconLbl.Font = T.font; iconLbl.ZIndex = 42; iconLbl.Parent = card

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.5, 0, 0, 22); nameLbl.Position = UDim2.new(0, 50, 0, 6)
		nameLbl.BackgroundTransparency = 1; nameLbl.Text = cfg.displayName or boostId
		nameLbl.TextColor3 = color; nameLbl.TextScaled = true
		nameLbl.Font = T.font; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.ZIndex = 42; nameLbl.Parent = card

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(0.7, 0, 0, 16); descLbl.Position = UDim2.new(0, 50, 0, 30)
		descLbl.BackgroundTransparency = 1; descLbl.Text = cfg.description or ""
		descLbl.TextColor3 = T.subText; descLbl.TextScaled = true
		descLbl.Font = T.fontBody; descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.ZIndex = 42; descLbl.Parent = card

		local durLbl = Instance.new("TextLabel")
		durLbl.Size = UDim2.new(0.7, 0, 0, 14); durLbl.Position = UDim2.new(0, 50, 0, 48)
		durLbl.BackgroundTransparency = 1; durLbl.Text = FormatTime(cfg.duration) .. " duration"
		durLbl.TextColor3 = Color3.fromRGB(110, 115, 140); durLbl.TextScaled = true
		durLbl.Font = T.fontBody; durLbl.TextXAlignment = Enum.TextXAlignment.Left
		durLbl.ZIndex = 42; durLbl.Parent = card

		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0, 82, 0, 38); buyBtn.Position = UDim2.new(1, -94, 0, 6)
		buyBtn.BorderSizePixel = 0; buyBtn.TextScaled = true; buyBtn.Font = T.font
		buyBtn.ZIndex = 42; buyBtn.Parent = card
		Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 7)

		local actBtn = Instance.new("TextButton")
		actBtn.Size = UDim2.new(0, 82, 0, 38); actBtn.Position = UDim2.new(1, -94, 0, 54)
		actBtn.BorderSizePixel = 0; actBtn.TextScaled = true; actBtn.Font = T.font
		actBtn.ZIndex = 42; actBtn.Parent = card
		Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 7)

		local invBadge = Instance.new("TextLabel")
		invBadge.Size = UDim2.new(0, 28, 0, 18); invBadge.Position = UDim2.new(0, 6, 1, -22)
		invBadge.BackgroundColor3 = Color3.fromRGB(40, 40, 60); invBadge.BorderSizePixel = 0
		invBadge.Text = "x0"; invBadge.TextColor3 = T.subText
		invBadge.TextScaled = true; invBadge.Font = T.font
		invBadge.ZIndex = 43; invBadge.Parent = card
		Instance.new("UICorner", invBadge).CornerRadius = UDim.new(0, 4)

		cardRefs[boostId] = { card=card, cs=cs, buyBtn=buyBtn, actBtn=actBtn, invBadge=invBadge, descLbl=descLbl, color=color }

		buyBtn.MouseButton1Down:Connect(function() BuyBoost:FireServer(boostId) end)
		actBtn.MouseButton1Down:Connect(function()
			local state = boostState[boostId]
			if not state or (state.inventoryCount or 0) <= 0 then return end
			ActivateBoost:FireServer(boostId)
		end)
	end
end

BuildCards()
local latestStats = {}
local function RefreshCards()
	GoldLabel.Text = "⭐ " .. math.floor(liveGold) .. " Golden Auras"
	for boostId, refs in pairs(cardRefs) do
		local cfg         = BoostConfig.Get(boostId)
		local state       = boostState[boostId]
		local color       = refs.color
		local invCount    = state and (state.inventoryCount or 0) or 0
		local activeCount = state and (state.activeCount or 0) or 0
		local cost        = cfg and cfg.cost or 0
		local canAfford   = liveGold >= cost
		local atCap       = activeCount >= (cfg and cfg.maxStack or 1)

		refs.invBadge.Text       = "x" .. invCount
		refs.invBadge.TextColor3 = invCount > 0 and T.bodyText or Color3.fromRGB(100,100,120)

		refs.buyBtn.Text             = cost .. " ⭐"
		refs.buyBtn.TextColor3       = T.bodyText
		refs.buyBtn.BackgroundColor3 = canAfford and T.buttonGreen or T.buttonDisabled

		local isUnlocked, lockReason = AchievementConfig.IsBoostUnlocked(boostId, latestStats)

		if not isUnlocked then
			refs.buyBtn.Text             = "LOCKED"
			refs.buyBtn.BackgroundColor3 = T.buttonRed
			refs.actBtn.Text             = lockReason
			refs.actBtn.BackgroundColor3 = T.buttonDisabled
			refs.actBtn.TextColor3       = T.subText
		elseif invCount <= 0 then
			refs.actBtn.Text             = "No stock"
			refs.actBtn.BackgroundColor3 = T.buttonDisabled
			refs.actBtn.TextColor3       = T.subText
		elseif atCap then
			refs.actBtn.Text             = "MAX " .. FormatTime(state and state.activeTimes and state.activeTimes[1] or 0)
			refs.actBtn.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
			refs.actBtn.TextColor3       = color
		else
			refs.actBtn.Text             = "Activate"
			refs.actBtn.BackgroundColor3 = color
			refs.actBtn.TextColor3       = T.bodyText
		end
	end
end

local function RefreshStrip()
	local anyActive = false
	for _, boostId in ipairs(BOOST_ORDER) do
		local state = boostState[boostId]
		local refs  = stripSlots[boostId]
		if not refs then continue end
		if state and (state.activeCount or 0) > 0 then
			anyActive = true; refs.slot.Visible = true
			local minTime = math.huge
			for _, t in ipairs(state.activeTimes or {}) do if t < minTime then minTime = t end end
			refs.timeLbl.Text  = FormatTime(minTime)
			refs.stackLbl.Text = state.activeCount > 1 and ("x" .. state.activeCount) or ""
		else
			refs.slot.Visible = false
		end
	end
	BoostStrip.Visible = anyActive
end

local function OpenPanel()
	panelOpen = true; ShopPanel.Visible = true
	ShopPanel.Size = UDim2.new(0.85, 0, 0, 0)
	RefreshCards()
	TweenService:Create(ShopPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.85, 0, 0.8, 0)
	}):Play()
	UITheme.SetMenuVisible(true)
end

local function ClosePanel()
	panelOpen = false
	PlayUI(SoundConfig.UIClose)
	TweenService:Create(ShopPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0.85, 0, 0, 0)
	}):Play()
	UITheme.SetMenuVisible(false)
	task.delay(0.22, function() ShopPanel.Visible = false end)
end

BoostsBtn.MouseButton1Down:Connect(function() if panelOpen then ClosePanel() else OpenPanel() end end)
ShopClose.MouseButton1Down:Connect(ClosePanel)

BoostUpdated.OnClientEvent:Connect(function(state)
	if state._goldenAuras ~= nil then liveGold = state._goldenAuras; state._goldenAuras = nil end
	boostState = state; RefreshStrip()
	if panelOpen then RefreshCards() end
end)
UpdateHUD.OnClientEvent:Connect(function(stats)
for key, value in pairs(stats) do
		latestStats[key] = value
	end
		if stats.goldenAuras ~= nil then liveGold = stats.goldenAuras end
	if stats.boostInventory then
		for boostId, count in pairs(stats.boostInventory) do
			if boostState[boostId] then boostState[boostId].inventoryCount = count end
		end
	end
	if panelOpen then RefreshCards() end
end)

RunService.RenderStepped:Connect(function(dt)
	local anyActive = false
	for _, boostId in ipairs(BOOST_ORDER) do
		local state = boostState[boostId]
		if state and state.activeTimes and #state.activeTimes > 0 then
			anyActive = true
			local clean = {}
			for _, t in ipairs(state.activeTimes) do
				local newT = math.max(0, t - dt)
				if newT > 0 then table.insert(clean, newT) end
			end
			state.activeTimes = clean; state.activeCount = #clean
			local refs = stripSlots[boostId]
			if refs then
				if #clean > 0 then
					local minTime = math.huge
					for _, t in ipairs(clean) do if t < minTime then minTime = t end end
					refs.timeLbl.Text  = FormatTime(minTime)
					refs.stackLbl.Text = #clean > 1 and ("x" .. #clean) or ""
					refs.slot.Visible  = true
				else
					refs.slot.Visible = false
				end
			end
		end
	end
	BoostStrip.Visible = anyActive
end)

local shopShine = nil

-- Add this at the end of the script to 'Glass-ify' the existing UI
local function RefreshLook()
	-- Apply to the main panel
	UITheme.Apply(ShopPanel, "Panel") -- or whatever your frame is named

	if not shopShine then
		shopShine = UITheme.ApplyShine(ShopPanel)
	end
	-- Apply to each existing upgrade card
	for _, card in ipairs(ScrollContainer:GetChildren()) do
		if card:IsA("Frame") then
			UITheme.Apply(card, "Card")
		end
	end
end

-- Run it once on start
task.wait(1) 
RefreshLook()

-- AchievementConfig
-- Location: ReplicatedStorage > Modules > AchievementConfig

local AchievementConfig = {}

-- 🏆 YOUR CHALLENGES / BOOST UNLOCKS
AchievementConfig.Challenges = {
	{
		id = "unlock_aurarush",
		boostId = "AuraRush",
		title = "Aura Tycoon",
		desc = "Spawn 1,000 Auras",
		iconId = "rbxassetid://0", -- PLACEHOLDER
		statKey = "totalCubesProduced", -- The exact variable in your datastore
		goal = 10,
		rewardText = "Unlocks: Aura Rush Boost"
	},
	{
		id = "unlock_spawnboost",
		boostId = "SpawnBoost",
		title = "Explorer",
		desc = "Reach Area 2",
		iconId = "rbxassetid://0", -- PLACEHOLDER
		statKey = "currentArea",
		goal = 2,
		rewardText = "Unlocks: Value Boost"
	},
	{
		id = "unlock_soulboost",
		boostId = "SoulBoost",
		title = "Soul Searcher",
		desc = "Prestige 5 Times",
		iconId = "rbxassetid://0", -- PLACEHOLDER
		statKey = "prestigeCount",
		goal = 5,
		rewardText = "Unlocks: Soul Boost"
	}
}

-- 🏅 YOUR ROBLOX BADGES
AchievementConfig.Badges = {
	{ id = 000000000, title = "First Prestige", desc = "Prestige for the first time.", iconId = "rbxassetid://0" }, -- PLACEHOLDER
	{ id = 000000000, title = "Millionaire", desc = "Hold $1,000,000 at once.", iconId = "rbxassetid://0" }, -- PLACEHOLDER
}

-- Helper function to check if a boost is unlocked
function AchievementConfig.IsBoostUnlocked(boostId, playerData)
	for _, challenge in ipairs(AchievementConfig.Challenges) do
		if challenge.boostId == boostId then
			local currentAmount = playerData[challenge.statKey] or 0
			if currentAmount < challenge.goal then
				return false, challenge.desc -- Returns false and tells you why!
			end
		end
	end
	return true, ""
end

return AchievementConfig

local AdminConfig = {}

AdminConfig.FireRate             = 0.25
AdminConfig.BaseAuraValue        = 1
AdminConfig.BaseHabitatCapacity  = 60
AdminConfig.ShipInterval         = 6
AdminConfig.TierOverride         = nil
AdminConfig.WipeMoneyOnLoad      = true
AdminConfig.WipePrestigeOnLoad   = true  
AdminConfig.WipeAchievementsOnLoad = true
AdminConfig.WipeAreaOnLoad       = true  
AdminConfig.WipeEpicOnLoad = true
AdminConfig.AutoDispatch         = false

AdminConfig.PlatformCapacity     = 25
AdminConfig.PlatformSpeed        = 20
AdminConfig.PlatformHoverHeight  = 5
AdminConfig.MaxTrucks            = 3
AdminConfig.PassiveInterval      = 10

AdminConfig.MilestoneData = {
	[1] = {time = 0, mult = 1.0, luck = 0,    name = "NORMAL",     color = Color3.fromRGB(255, 0, 0),    sound = "rbxassetid://6102885137"},
	[2] = {time = 1, mult = 1.5, luck = 0.05, name = "UNCOMMON!",  color = Color3.fromRGB(100, 200, 100), sound = "Landing"},
	[3] = {time = 2, mult = 2.0, luck = 0.10, name = "RARE!",      color = Color3.fromRGB(80, 120, 220),  sound = "rbxassetid://4767117600"},
	[4] = {time = 4, mult = 3.0, luck = 0.15, name = "EPIC!",      color = Color3.fromRGB(180, 80, 220),  sound = "Epic"},
	[5] = {time = 7, mult = 5.0, luck = 0.20, name = "LEGENDARY!", color = Color3.fromRGB(255, 200, 50),  sound = "rbxassetid://6875009415"},
	[6] = {time = 12, mult = 10.0, luck = 0.30, name = "MYTHIC!",  color = Color3.fromRGB(157, 0, 255),   sound = "rbxassetid://1843115950"},
	-- ✨ THE COSMIC TIERS (Egg Inc style exponential leaps!)
	[7] = {time = 20, mult = 25.0, luck = 0.45, name = "COSMIC!",  color = Color3.fromRGB(0, 255, 255),   sound = "rbxassetid://123182143898652"},
	[8] = {time = 35, mult = 100.0,luck = 0.60, name = "GODLY!",   color = Color3.fromRGB(255, 255, 0),   sound = "rbxassetid://73678054568493"},
	[9] = {time = 55, mult = 500.0,luck = 0.80, name = "UNIVERSAL!",color= Color3.fromRGB(255, 255, 255), sound = "rbxassetid://4914399472"},
	[10]= {time = 90, mult = 2500.0,luck=1.00,  name = "OMNI!",    color = Color3.fromRGB(20, 20, 20),    sound = "rbxassetid://6176998903"},
}

AdminConfig.HatcheryMax              = 150
AdminConfig.HatcheryDrainRate        = 8
AdminConfig.HatcheryRefillRate       = 12
AdminConfig.HatcheryInstantLegendary = false
AdminConfig.HatcheryFastRefill       = false

AdminConfig.MutationSpeedMultiplier  = 1
AdminConfig.MutationTickInterval     = 1
AdminConfig.MutationInstantMax       = false
AdminConfig.MutationMaxTierIndex     = 3

AdminConfig.PrestigeStartBonusPercent = 0.05
AdminConfig.TestTimerDuration         = 0
AdminConfig.DisableShipping           = false

AdminConfig.AdminUserIds = { 2359024102, 305557572 }

-- Kept for backwards compat — AreaRegistry is authoritative
AdminConfig.AreaThresholds       = { [1]=0, [2]=5e5, [3]=5e6, [4]=5e7, [5]=5e8}
AdminConfig.AreaValueMultipliers = { [1]=1.0, [2]=1.5, [3]=3.0, [4]=8.0, [5]=20.0}
AdminConfig.AreaNames            = { [1]="Starter Area",[2]="Uncommon Area",[3]="Rare Area",[4]="Epic Area",[5]="Legendary Area"}
AdminConfig.MaxArea              = 25

AdminConfig.GoldenAuraStart = 0

-- AURA PHYSICS (CRANKED UP)
AdminConfig.PhysicsSpawnMin = 10
AdminConfig.PhysicsSpawnMax = 30
AdminConfig.PhysicsEliteChance = 20

AdminConfig.PhysicsRegularDespawn = 8
AdminConfig.PhysicsEliteDespawn = 4

-- AURA PHYSICS (MAX AIR TIME & WALL BOUNCES)
AdminConfig.PhysicsUpwardForceMin = 180   -- High launch to stay in air
AdminConfig.PhysicsUpwardForceMax = 240   
AdminConfig.PhysicsOutwardForceMin = 150  -- High horizontal to reach the walls
AdminConfig.PhysicsOutwardForceMax = 220  

-- Bounce Control
AdminConfig.PhysicsMaxBouncesRegular = 0 
AdminConfig.PhysicsMaxBouncesElite = 2

AdminConfig.PhysicsErraticIntervalMin = 0.3
AdminConfig.PhysicsErraticIntervalMax = 0.8
AdminConfig.PhysicsErraticForceH = 70    -- Increased for more air-time chaos
AdminConfig.PhysicsErraticForceV = 10

AdminConfig.PhysicsRegularMultiplier = 10
AdminConfig.PhysicsEliteMultiplier = 50

AdminConfig.PhysicsEliteGoldenChance = 10
AdminConfig.PhysicsGoldenReward = 1

return AdminConfig

-- GameManager
-- Location: ServerScriptService > GameManager (ModuleScript)
--
-- FIXES:
--   hasPrestigedThisArea now resets in WipePrestigeOnLoad AND WipeAreaOnLoad
--   AND WipeMoneyOnLoad. Any wipe = fresh prestige state.
--   All Phase 4 fields in DefaultData + safety net after wipes.
--   TutorialStepComplete handler at bottom.

local DataStoreService  = game:GetService("DataStoreService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDB      = DataStoreService:GetDataStore("PlayerData_v1")
local AdminConfig   = require(ReplicatedStorage.Modules.AdminConfig)
local UpgradeConfig = require(ReplicatedStorage.Modules.UpgradeConfig)
local MutationConfig = require(ReplicatedStorage.Modules.MutationConfig)

local SAVE_COOLDOWN = 7

local function DefaultData()
	return {
		currency      = 0,
		totalEarned   = 0,
		soulAuras     = 0,
		prestigeCount = 0,

		pendingAuras        = 0,
		pendingPayout       = 0,
		pendingBonusPayout  = 0,
		lastPayout          = 0,

		upgrades = {
			dropRate           = 0,
			blockValue         = 0,
			habitatCapacity    = 0,
			autoShipper        = 0,
			mutationSpeed      = 0,
			mutationTierChance = 0,
			passiveTickSpeed   = 0,
			hatcheryCapacity   = 0,
		},

		piggyBank       = 0,
		piggyBankBroken = 0,

		totalCubesProduced    = 0,
		totalPlatformsShipped = 0,
		totalLegendaryCubes   = 0,

		missions = {},

		settings = {
			sfxEnabled   = true,
			musicEnabled = true,
		},

		farmEvaluation = 0,
		currentArea    = 1,
		unlockedAreas  = { 1 },

		goldenAuras = AdminConfig.GoldenAuraStart or 10,

		boostInventory = {
			AuraRush   = 0,
			SpawnBoost = 0,
			SoulBoost  = 0,
		},

		hasPrestigedThisArea = false,
		epicUpgrades         = {},
		tutorialProgress     = {},
		tutorialComplete     = false,
		claimedMail          = {},
		unlockedMail         = {},
	}
end

local function DefaultRuntime()
	return {
		cubes          = {},
		cubeOrder      = {},
		cubeCount      = 0,
		nextCubeId     = 1,
		totalMutatedValue = 0, -- NEW: Track the total value instantly
		lastActiveTime = tick(),
		sessionStart   = tick(),
	}
end

local PlayerData    = {}
local PlayerRuntime = {}
local lastSaveTick  = {}
local pendingSave   = {}

local function DeepMerge(saved, defaults)
	for key, defaultValue in pairs(defaults) do
		if saved[key] == nil then
			saved[key] = defaultValue
		elseif type(defaultValue) == "table" and type(saved[key]) == "table"
			and not getmetatable(saved[key]) then
			if defaultValue[1] == nil then
				DeepMerge(saved[key], defaultValue)
			end
		end
	end
end

local function EnsureUnlockedAreas(data)
	if type(data.unlockedAreas) ~= "table" then data.unlockedAreas = { 1 } end
	local has1, hasCurrent = false, false
	for _, v in ipairs(data.unlockedAreas) do
		if v == 1 then has1 = true end
		if v == data.currentArea then hasCurrent = true end
	end
	if not has1 then table.insert(data.unlockedAreas, 1) end
	if not hasCurrent and data.currentArea ~= 1 then
		table.insert(data.unlockedAreas, data.currentArea)
	end
end

local function SaveData(player)
	local uid  = player.UserId
	local data = PlayerData[uid]
	if not data then return end
	local now, last = tick(), lastSaveTick[uid] or 0
	if now - last >= SAVE_COOLDOWN then
		lastSaveTick[uid] = now
		local ok, err = pcall(function() PlayerDB:SetAsync("Player_" .. uid, data) end)
		if not ok then warn("[GameManager] SaveData failed for", player.Name, ":", err) end
	else
		if not pendingSave[uid] then
			pendingSave[uid] = true
			task.delay(SAVE_COOLDOWN - (now - last) + 0.5, function()
				pendingSave[uid] = nil
				if player and player.Parent and PlayerData[uid] then
					local ok, err = pcall(function() PlayerDB:SetAsync("Player_" .. uid, PlayerData[uid]) end)
					lastSaveTick[uid] = tick()
					if not ok then warn("[GameManager] Deferred save failed for", player.Name, ":", err) end
				end
			end)
		end
	end
end

local function LoadData(player)
	local key      = "Player_" .. player.UserId
	local ok, data = pcall(function() return PlayerDB:GetAsync(key) end)

	if ok and data then
		DeepMerge(data, DefaultData())
		PlayerData[player.UserId] = data
	else
		PlayerData[player.UserId] = DefaultData()
	end

	EnsureUnlockedAreas(PlayerData[player.UserId])
	PlayerRuntime[player.UserId] = DefaultRuntime()

	local d = PlayerData[player.UserId]

	if AdminConfig.WipeMoneyOnLoad then
		d.currency           = 0
		d.totalEarned        = 0
		d.pendingAuras       = 0
		d.pendingPayout      = 0
		d.pendingBonusPayout = 0
		d.lastPayout         = 0
		for k in pairs(d.upgrades) do d.upgrades[k] = 0 end
		d.totalCubesProduced    = 0
		d.totalPlatformsShipped = 0
		d.totalLegendaryCubes   = 0
		d.piggyBank             = 0
		d.piggyBankBroken       = 0
		d.farmEvaluation        = 0
		d.goldenAuras           = AdminConfig.GoldenAuraStart or 10
		d.boostInventory        = { AuraRush = 0, SpawnBoost = 0, SoulBoost = 0 }
		d.hasPrestigedThisArea  = false   -- FIX: reset on money wipe
		d.claimedMail = {}           -- ADD THIS: reset claimed mail
		d.tutorialProgress = {}      -- ADD THIS: reset tutorial popups
		d.tutorialComplete = false   -- ADD THIS: reset tutorial lockout
	end

	if AdminConfig.WipePrestigeOnLoad then
		d.soulAuras            = 0
		d.prestigeCount        = 0
		d.hasPrestigedThisArea = false   -- FIX: reset on prestige wipe
	end

	if AdminConfig.WipeAreaOnLoad then
		d.currentArea          = 1
		d.farmEvaluation       = 0
		d.unlockedAreas        = { 1 }
		d.hasPrestigedThisArea = false   -- FIX: reset on area wipe
	end
	
	if AdminConfig.WipeEpicOnLoad then
		d.GoldenAuras = 0
		d.epicUpgrades = {}
	end
	
	if AdminConfig.WipeAchievementsOnLoad then
		d.totalCubesProduced = 0
		d.totalLegendaryCubes = 0
		d.totalPlatformsShipped = 0
	end

	-- Safety: Phase 4 fields always exist, never wiped
	if not d.epicUpgrades     then d.epicUpgrades     = {} end
	if not d.tutorialProgress then d.tutorialProgress = {} end
	if d.tutorialComplete == nil then d.tutorialComplete = false end
	if not d.claimedMail      then d.claimedMail      = {} end
	if not d.unlockedMail     then d.unlockedMail     = {} end
	if d.hasPrestigedThisArea == nil then d.hasPrestigedThisArea = false end

	task.wait(1)

	local habCfg = UpgradeConfig.GetUpgradeConfig("habitatCapacity")
	local habCap  = (habCfg and habCfg.apply) and habCfg.apply(d) or AdminConfig.BaseHabitatCapacity
	local tickCfg = UpgradeConfig.GetUpgradeConfig("passiveTickSpeed")
	local passInt = (tickCfg and tickCfg.apply) and tickCfg.apply(d) or AdminConfig.PassiveInterval

	ReplicatedStorage.RemoteEvents.UpdateHUD:FireClient(player, {
		currency             = d.currency,
		pendingAuras         = 0,
		habitatCapacity      = habCap,
		rate                 = 0,
		passiveInterval      = passInt,
		totalEarned          = d.totalEarned        or 0,
		soulAuras            = d.soulAuras          or 0,
		farmEvaluation       = d.farmEvaluation     or 0,
		goldenAuras          = d.goldenAuras        or 0,
		boostInventory       = d.boostInventory     or {},
		settings             = d.settings           or {},
		prestigeCount        = d.prestigeCount      or 0,
		hasPrestigedThisArea = d.hasPrestigedThisArea or false,
		tutorialProgress     = d.tutorialProgress   or {},
		tutorialComplete     = d.tutorialComplete   or false,
		epicUpgrades         = d.epicUpgrades       or {},
		totalCubesProduced   = d.totalCubesProduced or 0,
		currentArea          = d.currentArea or 1,
	})

	-- FIX: Send UpgradeUpdated fullState so ShopController has data on join
	-- This fires AFTER UpdateHUD so the shop has both currency AND upgrade state
	-- FIX: Send UpgradeUpdated fullState so ShopController has data on join
	task.delay(0.5, function()
		if not player or not player.Parent then return end
		local resetState = {}

		-- SURGICAL FIX: Use Tiered Loop and New CalculateCost function
		for tierNum, tierData in ipairs(UpgradeConfig.Tiers) do
			for upgradeId, cfg in pairs(tierData.upgrades) do
				local lv = d.upgrades[upgradeId] or 0
				local maxed = lv >= cfg.maxLevel

				resetState[upgradeId] = {
					level    = lv,
					maxLevel = cfg.maxLevel,
					cost     = maxed and 0 or UpgradeConfig.CalculateCost(upgradeId, lv),
					maxed    = maxed,
				}
			end
		end

		local UpgradeUpdated = ReplicatedStorage.RemoteEvents:FindFirstChild("UpgradeUpdated")
		if UpgradeUpdated then
			UpgradeUpdated:FireClient(player, {
				type     = "fullState",
				upgrades = resetState,
				currency = d.currency,
			})
		end
	end)
end

Players.PlayerAdded:Connect(LoadData)
Players.PlayerRemoving:Connect(function(player)
	local uid  = player.UserId
	local data = PlayerData[uid]
	if data then pcall(function() PlayerDB:SetAsync("Player_" .. uid, data) end) end
	pendingSave[uid]   = nil
	lastSaveTick[uid]  = nil
	PlayerData[uid]    = nil
	PlayerRuntime[uid] = nil
end)

local lastPeriodicSave = tick()
game:GetService("RunService").Heartbeat:Connect(function()
	if tick() - lastPeriodicSave >= 60 then
		lastPeriodicSave = tick()
		for _, p in ipairs(Players:GetPlayers()) do SaveData(p) end
	end
end)

---------------------------------------------------------------
-- TutorialStepComplete handler
---------------------------------------------------------------
task.spawn(function()
	local TutorialStepComplete = ReplicatedStorage.RemoteEvents:WaitForChild("TutorialStepComplete", 10)
	if not TutorialStepComplete then return end
	TutorialStepComplete.OnServerEvent:Connect(function(player, stepId)
		local uid  = player.UserId
		local data = PlayerData[uid]
		if not data then return end
		if not data.tutorialProgress then data.tutorialProgress = {} end
		if stepId == "__tutorialComplete__" then
			data.tutorialComplete = true
		elseif type(stepId) == "string" and #stepId < 100 then
			data.tutorialProgress[stepId] = true
		end
	end)
end)

---------------------------------------------------------------
-- Public API
---------------------------------------------------------------
local GameManager = {}

function GameManager.GetData(uid)    return PlayerData[uid]    end
function GameManager.GetRuntime(uid) return PlayerRuntime[uid] end
function GameManager.SavePlayer(p)   SaveData(p)               end

function GameManager.AddCube(uid, cubeRecord)
	local runtime = PlayerRuntime[uid]
	if not runtime then return nil end
	local id = runtime.nextCubeId
	runtime.nextCubeId += 1	
	runtime.cubes[id] = cubeRecord
	runtime.totalMutatedValue += MutationConfig.GetMutatedValue(cubeRecord)
	table.insert(runtime.cubeOrder, id)
	runtime.cubeCount += 1
	return id
end

function GameManager.RemoveCube(uid, cubeId)
	local runtime = PlayerRuntime[uid]
	if not runtime or not runtime.cubes[cubeId] then return end
	runtime.cubes[cubeId] = nil
	runtime.cubeCount -= 1
end

function GameManager.CollectOldestCubes(uid, count)
	local runtime = PlayerRuntime[uid]
	if not runtime then return {}, {} end
	local collected, collectedCubes, newOrder = {}, {}, {}
	local needed = count
	for _, cubeId in ipairs(runtime.cubeOrder) do
		if runtime.cubes[cubeId] then
			if needed > 0 then
				table.insert(collected, cubeId)
				table.insert(collectedCubes, runtime.cubes[cubeId])

				-- 1. Grab the value BEFORE deleting it!
				local valToRemove = MutationConfig.GetMutatedValue(runtime.cubes[cubeId])
				runtime.totalMutatedValue -= valToRemove

				-- 2. NOW delete it
				runtime.cubes[cubeId] = nil
				runtime.cubeCount -= 1
				needed -= 1
			else
				table.insert(newOrder, cubeId)
			end
		end
	end
	runtime.cubeOrder = newOrder
	return collected, collectedCubes
end

game:BindToClose(function()
	print("[GameManager] Server shutting down. Forcing final save for all players...")
	for _, player in ipairs(Players:GetPlayers()) do
		SaveData(player)
	end
	task.wait(2) -- Give DataStoreService a moment to flush the queues
end)

return GameManager



-- AuraSpawner
-- Location: ServerScriptService > AuraSpawner
-- FIX: areaMult now reads from AreaRegistry.GetMultiplier() — the authoritative source.
--      AdminConfig.AreaValueMultipliers is no longer used here.
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TierConfig     = require(ReplicatedStorage.Modules.TierConfig)
local UpgradeConfig  = require(ReplicatedStorage.Modules.UpgradeConfig)
local PrestigeModule = require(ReplicatedStorage.Modules.PrestigeModule)
local AdminConfig    = require(ReplicatedStorage.Modules.AdminConfig)
local MutationConfig = require(ReplicatedStorage.Modules.MutationConfig)
local AreaRegistry   = require(ReplicatedStorage.Modules.AreaRegistry)
local GameManager    = require(ServerScriptService.GameManager)
local BoostManager   = require(ServerScriptService.BoostManager)
local WeatherManager = require(ServerScriptService.WeatherManager) 

local AuraSpawned    = ReplicatedStorage.RemoteEvents:WaitForChild("AuraSpawned")
local ProduceAura    = ReplicatedStorage.RemoteEvents:WaitForChild("ProduceAura")
local UpdateHatchery = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHatchery")
local UpdateHUD      = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")
local HabitatFull    = ReplicatedStorage.RemoteEvents:WaitForChild("HabitatFull")
local CubeMutated    = ReplicatedStorage.RemoteEvents:WaitForChild("CubeMutated")

local HABITAT_PART = workspace:WaitForChild("Habitat").Position

local lastFire          = {}
local holdStart         = {}
local hatchery          = {}
local clickSessionStart = {}
local function GetHatcheryMax(data)
	local cfg = UpgradeConfig.GetUpgradeConfig("hatcheryCapacity")
	return (cfg and cfg.apply) and cfg.apply(data) or AdminConfig.HatcheryMax
end

local function GetHabitatCapacity(data)
	local cfg = UpgradeConfig.GetUpgradeConfig("habitatCapacity")
	return (cfg and cfg.apply) and cfg.apply(data) or AdminConfig.BaseHabitatCapacity
end

local function GetMutationSpeedMult(data)
	local cfg = UpgradeConfig.GetUpgradeConfig("mutationSpeed")
	return (cfg and cfg.apply) and cfg.apply(data) or 1
end

Players.PlayerAdded:Connect(function(p)
	hatchery[p.UserId] = AdminConfig.HatcheryMax
	clickSessionStart[p.UserId] = nil
end)
Players.PlayerRemoving:Connect(function(p)
	hatchery[p.UserId]=nil; holdStart[p.UserId]=nil
	lastFire[p.UserId]=nil; clickSessionStart[p.UserId]=nil
end)

task.spawn(function()
	local PR = ServerScriptService:WaitForChild("PrestigeReset", 30)
	if PR then
		PR.Event:Connect(function(player)
			local uid = player.UserId
			local data = GameManager.GetData(uid)
			hatchery[uid] = data and GetHatcheryMax(data) or AdminConfig.HatcheryMax
			holdStart[uid]=nil; lastFire[uid]=nil; clickSessionStart[uid]=nil
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local uid = player.UserId
			local data = GameManager.GetData(uid)
			local hatchMax = data and GetHatcheryMax(data) or AdminConfig.HatcheryMax
			local prev = hatchery[uid] or hatchMax
			if holdStart[uid] then
				hatchery[uid] = math.max(0, prev - AdminConfig.HatcheryDrainRate * 0.1)
			else
				hatchery[uid] = math.min(hatchMax, prev + AdminConfig.HatcheryRefillRate * 0.1)
			end
			if hatchery[uid] ~= prev then
				UpdateHatchery:FireClient(player, { current=hatchery[uid], max=hatchMax })
			end
			if hatchery[uid] <= 0 and holdStart[uid] then
				holdStart[uid] = nil
				ReplicatedStorage.RemoteEvents.ForceStopHold:FireClient(player)
			end
		end
	end
end)

local function GetAFKSpeed(runtime)
	local idleTime = tick() - runtime.lastActiveTime
	local speed = MutationConfig.AFKDecay[1].speed
	for _, e in ipairs(MutationConfig.AFKDecay) do
		if idleTime >= e.time then speed = e.speed end
	end
	return speed
end

local function SendHUDUpdate(player)
	local uid = player.UserId
	local data = GameManager.GetData(uid)
	local runtime = GameManager.GetRuntime(uid)
	if not data or not runtime then return end
	local totalMV = runtime.totalMutatedValue or 0
	local pending = runtime.cubeCount
	local avgVal  = pending > 0 and (totalMV/pending) or AdminConfig.BaseAuraValue
	local rate    = math.floor(pending * avgVal)
	local passTickCfg = UpgradeConfig.GetUpgradeConfig("passiveTickSpeed")
	
	local passInt = (passTickCfg and passTickCfg.apply) and passTickCfg.apply(data) or AdminConfig.PassiveInterval
	local displayRate = math.floor(rate * BoostManager.GetValueMultiplier(uid) * BoostManager.GetSpawnRateMultiplier(uid))
	UpdateHUD:FireClient(player, {
		currency=data.currency, pendingAuras=pending,
		habitatCapacity=GetHabitatCapacity(data), rate=displayRate,
		passiveInterval=passInt, totalEarned=data.totalEarned or 0,
		soulAuras=data.soulAuras or 0, farmEvaluation=data.farmEvaluation or 0,
		goldenAuras=data.goldenAuras or 0, boostInventory=data.boostInventory or {},
		prestigeCount=data.prestigeCount or 0,
		upgrades=data.upgrades or {},
		totalCubesProduced   = data.totalCubesProduced or 0,
		currentArea          = data.currentArea or 1,
	})
end

task.spawn(function()
	while true do
		local tickInterval = AdminConfig.MutationTickInterval or MutationConfig.CheckInterval
		task.wait(tickInterval)
		for _, player in ipairs(Players:GetPlayers()) do
			local uid = player.UserId
			local data = GameManager.GetData(uid)
			local runtime = GameManager.GetRuntime(uid)
			if not data or not runtime then continue end

			local dt = tickInterval * GetAFKSpeed(runtime) * GetMutationSpeedMult(data) * (AdminConfig.MutationSpeedMultiplier or 1)

			-- 1. Initialize our batch for this specific tick
			local mutationBatch = {}

			for cubeId, cube in pairs(runtime.cubes) do
				-- 2. Store the value before any mutations happen
				local oldMutatedValue = MutationConfig.GetMutatedValue(cube)
				local mutated = false

				local prev = cube.effectiveElapsed
				cube.effectiveElapsed += dt
				local pl = MutationConfig.GetValueBonusLevel(prev)
				local nl = MutationConfig.GetValueBonusLevel(cube.effectiveElapsed)

				if nl > pl then
					mutated = true
					local be = MutationConfig.ValueBonuses[nl]
					-- Add to batch instead of firing immediately
					table.insert(mutationBatch, { 
						cubeId = cubeId, 
						mutationType = "valueBonus",
						bonusLevel = nl, 
						bonusPercent = be and math.floor(be.bonus * 100) or 0 
					})
				end

				local maxTier = AdminConfig.MutationMaxTierIndex or 3
				local upgrades = 0

				while cube.tierIndex < maxTier and cube.tierIndex < #TierConfig.Tiers and upgrades < 5 do
					local timeSince = cube.effectiveElapsed - (cube.lastUpgradeElapsed or 0)
					local bestChance, bestTime = 0, 0

					for _, threshold in ipairs(MutationConfig.TierUpgrades) do
						if timeSince >= threshold.time then 
							bestChance = threshold.chance
							bestTime = threshold.time 
						end
					end

					if bestChance <= 0 then break end

					if math.random() <= bestChance then
						local oldTier = TierConfig.Tiers[cube.tierIndex]
						cube.tierIndex += 1
						local newTier = TierConfig.Tiers[cube.tierIndex]

						cube.baseValue = math.floor(cube.baseValue * (newTier.multiplier/oldTier.multiplier))
						cube.color = newTier.color
						cube.glow = newTier.glow
						cube.tierName = newTier.name
						cube.lastUpgradeElapsed = (cube.lastUpgradeElapsed or 0) + bestTime
						upgrades += 1
						mutated = true

						-- Add to batch instead of firing immediately
						table.insert(mutationBatch, { 
							cubeId = cubeId, 
							mutationType = "tierUpgrade",
							newColor = newTier.color, 
							newGlow = newTier.glow, 
							tierName = newTier.name 
						})

						if newTier.name == "Legendary" then
							data.totalLegendaryCubes = (data.totalLegendaryCubes or 0) + 1
						end
					else 
						break 
					end
				end

				-- 3. Calculate the delta and apply it to the running total
				if mutated then
					local newMutatedValue = MutationConfig.GetMutatedValue(cube)
					runtime.totalMutatedValue = (runtime.totalMutatedValue or 0) + (newMutatedValue - oldMutatedValue)
				end
			end

			-- 4. Send the entire batch in ONE RemoteEvent
			if #mutationBatch > 0 then
				ReplicatedStorage.RemoteEvents.CubeMutatedBatch:FireClient(player, mutationBatch)
			end

			SendHUDUpdate(player)
		end
	end
end)

local function GetHoldMultiplier(holdTime, data)
	local upgrades = data and data.upgrades or {}

	-- Extract speed level
	local speedData = upgrades["multiplierSpeed"]
	local speedLevel = (typeof(speedData) == "table" and speedData.level) or (typeof(speedData) == "number" and speedData) or 0
	local playerMultSpeed = 1.0 + (speedLevel * 0.05)

	-- Extract Mythic Unlock (Tier 6)
	local playerMaxTier = 5
	local mythicData = upgrades["unlockMythicMult"]
	local mythicLevel = (typeof(mythicData) == "table" and mythicData.level) or (typeof(mythicData) == "number" and mythicData) or 0
	if mythicLevel > 0 then playerMaxTier = 6 end

	local effectiveTime = holdTime * playerMultSpeed
	local currentTier = 1

	for i = 1, playerMaxTier do
		if AdminConfig.MilestoneData[i] and effectiveTime >= AdminConfig.MilestoneData[i].time then
			currentTier = i
		end
	end

	-- Smooth Math to perfectly match the client
	local nextTier = math.min(currentTier + 1, playerMaxTier)
	if currentTier == playerMaxTier then
		return AdminConfig.MilestoneData[currentTier].mult, AdminConfig.MilestoneData[currentTier].luck
	end

	local timePassed = effectiveTime - AdminConfig.MilestoneData[currentTier].time
	local timeNeeded = AdminConfig.MilestoneData[nextTier].time - AdminConfig.MilestoneData[currentTier].time
	local ratio = timePassed / timeNeeded

	local cMult = AdminConfig.MilestoneData[currentTier].mult
	local nMult = AdminConfig.MilestoneData[nextTier].mult
	local smoothMult = cMult + ((nMult - cMult) * ratio)

	return smoothMult, AdminConfig.MilestoneData[currentTier].luck
end

local function RollWithLuck(luckBonus)
	local tiers = TierConfig.Tiers
	local adjusted, total = {}, 0
	for _, tier in ipairs(tiers) do
		local chance = tier.chance
		if tier.name ~= "Common" then chance += luckBonus/(#tiers-1) end
		table.insert(adjusted, { tier=tier, chance=chance }); total += chance
	end
	local r, cum = math.random()*total, 0
	for _, e in ipairs(adjusted) do
		cum += e.chance; if r <= cum then return e.tier end
	end
	return tiers[1]
end

local function SpawnAura(player, data, runtime, holdMult, luckBonus)
	local uid  = player.UserId
	local tier = RollWithLuck(luckBonus)
	local tierIndex = 1
	for i, t in ipairs(TierConfig.Tiers) do if t.name == tier.name then tierIndex=i; break end end

	-- ✨ THE ADDITIVE MATH FIX: Gather ALL Value Upgrades!
	local totalValueMultiplier = 1.0 -- Starts at 100% base value
	local valueUpgrades = {
		"blockValue", "blockValueT2", "auraValueT3", 
		"auraValueT4", "auraValueT6", "auraValueT8", "auraValueT10"
	}

	for _, upgradeId in ipairs(valueUpgrades) do
		local cfg = UpgradeConfig.GetUpgradeConfig(upgradeId)
		if cfg and cfg.apply then
			totalValueMultiplier += cfg.apply(data) -- Additively stack the percentages!
		end
	end

	local prestigeMult    = PrestigeModule.GetMultiplier(data.soulAuras)
	local areaMult        = AreaRegistry.GetMultiplier(data.currentArea or 1)
	local boostValueMult  = BoostManager.GetValueMultiplier(uid)
	local _, weatherValueMult = WeatherManager.GetMultipliers(uid)

	-- Apply the strictly additive totalValueMultiplier
	local baseValue  = math.floor(AdminConfig.BaseAuraValue * tier.multiplier * totalValueMultiplier * prestigeMult * areaMult * boostValueMult * weatherValueMult)
	local totalValue = baseValue + math.floor(baseValue * (holdMult - 1))

	local spawnPos = HABITAT_PART.Position + Vector3.new(math.random(-3,3), 10, math.random(-3,3))
	local cubeRecord = {
		spawnTime=tick(), effectiveElapsed=0, lastUpgradeElapsed=0,
		baseValue=totalValue, tierIndex=tierIndex,
		tierName=tier.name, color=tier.color, glow=tier.glow,
	}
	if AdminConfig.MutationInstantMax then
		local mb = MutationConfig.ValueBonuses[#MutationConfig.ValueBonuses]
		if mb then cubeRecord.effectiveElapsed = mb.time + 1 end
	end

	local cubeId = GameManager.AddCube(uid, cubeRecord)
	if not cubeId then return end
	data.totalCubesProduced = (data.totalCubesProduced or 0) + 1
	if tier.name == "Legendary" then data.totalLegendaryCubes = (data.totalLegendaryCubes or 0) + 1 end
	runtime.lastActiveTime = tick()

	AuraSpawned:FireClient(player, {
		cubeId=cubeId, tier=tier.name, color=tier.color,
		glow=tier.glow, value=totalValue, spawnPos=spawnPos,
	})
end

ProduceAura.OnServerEvent:Connect(function(player, action)
	local uid = player.UserId
	local now = tick()
	if action == "start" then if (hatchery[uid] or 0) > 0 then holdStart[uid]=now end; return end
	if action == "stop"  then holdStart[uid]=nil; return end
	if (hatchery[uid] or 0) <= 0 then return end
	if not holdStart[uid] then return end

	local rushMult = BoostManager.GetSpawnRateMultiplier(uid)
	local weatherSpawnMult, _ = WeatherManager.GetMultipliers(uid)
	local effectiveFireRate = AdminConfig.FireRate / (rushMult * weatherSpawnMult)
	if lastFire[uid] then
		local timeSinceLast = now - lastFire[uid]
		if timeSinceLast > 3 then clickSessionStart[uid] = now end
		if not clickSessionStart[uid] then clickSessionStart[uid] = now end
		local sessionLength = now - clickSessionStart[uid]
		if sessionLength > 300 then effectiveFireRate *= 2 end
		if sessionLength > 600 then effectiveFireRate *= 4 end
		if timeSinceLast < effectiveFireRate then return end
	else
		clickSessionStart[uid] = now
	end
	lastFire[uid] = now

	local data    = GameManager.GetData(uid)
	local runtime = GameManager.GetRuntime(uid)
	if not data or not runtime then return end
	if runtime.cubeCount >= GetHabitatCapacity(data) then HabitatFull:FireClient(player); return end

	local holdTime = now - holdStart[uid]
	local holdMult, luckBonus = GetHoldMultiplier(holdTime, data)
	SpawnAura(player, data, runtime, holdMult, luckBonus)
	SendHUDUpdate(player)
	UpdateHatchery:FireClient(player, { current=hatchery[uid], max=GetHatcheryMax(data) })
end)

-- BoostManager
-- Location: ServerScriptService > BoostManager (ModuleScript)
--
-- STACKING CHANGE: Additive like Egg Inc Bird Feed.
--   OLD (multiplicative): 3x AuraRush stacks = 2 × 2 × 2 = 8x
--   NEW (additive):       3x AuraRush stacks = 1 + (1+1+1) = 4x
--
--   Formula: total = 1 + (multiplier - 1) * activeStackCount
--   So 1 stack of 2x = 2x, 2 stacks = 3x, 3 stacks = 4x
--   Much more balanced — same as Egg Inc's Bird Feed behaviour.

local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AdminConfig = require(ReplicatedStorage.Modules.AdminConfig)
local GameManager = require(ServerScriptService.GameManager)
local BoostConfig = require(ReplicatedStorage.Modules.BoostConfig)
local AchievementConfig = require(ReplicatedStorage.Modules.AchievementConfig)
local function GetOrCreate(name)
	local existing = ReplicatedStorage.RemoteEvents:FindFirstChild(name)
	if existing then return existing end
	local re = Instance.new("RemoteEvent")
	re.Name   = name
	re.Parent = ReplicatedStorage.RemoteEvents
	return re
end

local BuyBoost      = GetOrCreate("BuyBoost")
local ActivateBoost = GetOrCreate("ActivateBoost")
local BoostUpdated  = GetOrCreate("BoostUpdated")

local activeStacks = {}  -- [uid] = { {boostId, endsAt}, ... }

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function GetActiveStacks(uid, boostId)
	local stacks = activeStacks[uid] or {}
	local count, now = 0, tick()
	for _, entry in ipairs(stacks) do
		if entry.boostId == boostId and entry.endsAt > now then
			count += 1
		end
	end
	return count
end

local function PruneExpired(uid)
	local stacks = activeStacks[uid]
	if not stacks then return end
	local now, pruned = tick(), {}
	for _, entry in ipairs(stacks) do
		if entry.endsAt > now then table.insert(pruned, entry) end
	end
	activeStacks[uid] = pruned
end

---------------------------------------------------------------
-- ADDITIVE multiplier helper
-- Returns: 1 + (bonus_per_stack) * activeCount
-- Example: 2x boost, 3 stacks → 1 + 1×3 = 4x  (not 8x)
---------------------------------------------------------------
local function AdditiveMultiplier(uid, boostId)
	PruneExpired(uid)
	local cfg = BoostConfig.Get(boostId) -- NEW	if not cfg then return 1 end
	local bonus  = (cfg.multiplier or 2) - 1   -- bonus per stack (e.g. 2x → bonus = 1)
	local count  = GetActiveStacks(uid, boostId)
	return 1 + bonus * count
end

---------------------------------------------------------------
-- Public API
---------------------------------------------------------------
local BoostManager = {}

-- Additive spawn rate multiplier for AuraRush
-- AuraSpawner divides its fire interval by this value
function BoostManager.GetSpawnRateMultiplier(uid)
	return AdditiveMultiplier(uid, "AuraRush")
end

-- Additive value multiplier for SpawnBoost
function BoostManager.GetValueMultiplier(uid)
	return AdditiveMultiplier(uid, "SpawnBoost")
end



function BoostManager.IsActive(uid, boostId)
	return GetActiveStacks(uid, boostId) > 0
end

-- Soul aura multiplier (SoulBoost, max 1 active — no stacking needed)
function BoostManager.GetSoulMultiplier(uid)
	PruneExpired(uid)
	local stacks = activeStacks[uid] or {}
	local now    = tick()
	local cfg = BoostConfig.Get("SoulBoost") -- Changed boostId to the string "SoulBoost"
	for _, entry in ipairs(stacks) do
		if entry.boostId == "SoulBoost" and entry.endsAt > now then
			return cfg and cfg.multiplier or 2
		end
	end
	return 1
end

local function BuildState(uid)
	PruneExpired(uid)
	local stacks = activeStacks[uid] or {}
	local data   = GameManager.GetData(uid)
	local now    = tick()

	local state = {}

	-- THE FIX: Iterate through BoostConfig instead of AdminConfig!
	for boostId, cfg in pairs(BoostConfig.Boosts or {}) do

		local activeList = {}
		for _, entry in ipairs(stacks) do
			if entry.boostId == boostId and entry.endsAt > now then
				table.insert(activeList, math.max(0, entry.endsAt - now))
			end
		end
		state[boostId] = {
			inventoryCount = data and (data.boostInventory and data.boostInventory[boostId] or 0) or 0,
			activeCount    = #activeList,
			activeTimes    = activeList,
			duration       = cfg.duration,
			cost           = cfg.cost,
			multiplier     = cfg.multiplier,
			displayName    = cfg.displayName,
			description    = cfg.description,
			icon           = cfg.icon,
			maxStack       = cfg.maxStack,
			stackable      = cfg.stackable,
		}
	end

	state._goldenAuras = data and (data.goldenAuras or 0) or 0
	return state
end

local function SendState(player)
	BoostUpdated:FireClient(player, BuildState(player.UserId))
end

---------------------------------------------------------------
-- BUY
---------------------------------------------------------------
BuyBoost.OnServerEvent:Connect(function(player, boostId)
	local uid  = player.UserId
	local data = GameManager.GetData(uid)
	if not data then return end

	local cfg = BoostConfig.Get(boostId) -- NEW
	if not cfg then warn("[BoostManager] Unknown boost:", boostId); return end

	local cost = cfg.cost or 0
	if (data.goldenAuras or 0) < cost then return end
	local isUnlocked = AchievementConfig.IsBoostUnlocked(boostId, data)
	if not isUnlocked then return end 
	data.goldenAuras = (data.goldenAuras or 0) - cost
	data.boostInventory = data.boostInventory or {}
	data.boostInventory[boostId] = (data.boostInventory[boostId] or 0) + 1

	SendState(player)
	ReplicatedStorage.RemoteEvents.UpdateHUD:FireClient(player, {
		goldenAuras    = data.goldenAuras,
		boostInventory = data.boostInventory,
	})
end)

---------------------------------------------------------------
-- ACTIVATE
---------------------------------------------------------------
ActivateBoost.OnServerEvent:Connect(function(player, boostId)
	local uid  = player.UserId
	local data = GameManager.GetData(uid)
	if not data then return end

	local cfg = BoostConfig.Get(boostId)
	if not cfg then return end

	data.boostInventory = data.boostInventory or {}
	if (data.boostInventory[boostId] or 0) <= 0 then return end

	PruneExpired(uid)
	local currentStacks = GetActiveStacks(uid, boostId)
	if currentStacks >= (cfg.maxStack or 1) then return end

	data.boostInventory[boostId] = data.boostInventory[boostId] - 1

	activeStacks[uid] = activeStacks[uid] or {}
	table.insert(activeStacks[uid], {
		boostId = boostId,
		endsAt  = tick() + cfg.duration,
	})

	SendState(player)

	task.delay(cfg.duration, function()
		PruneExpired(uid)
		if player and player.Parent then SendState(player) end
	end)
end)

---------------------------------------------------------------
-- Player lifecycle
---------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	activeStacks[player.UserId] = {}
	task.wait(2)
	SendState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	activeStacks[player.UserId] = nil
end)

-- Periodic sync for countdown accuracy
task.spawn(function()
	while true do
		task.wait(5)
		for _, player in ipairs(Players:GetPlayers()) do
			if activeStacks[player.UserId] and #activeStacks[player.UserId] > 0 then
				SendState(player)
			end
		end
	end
end)

return BoostManager
