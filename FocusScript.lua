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
local BoostConfig       = require(ReplicatedStorage.Modules.BoostConfig) -- ADD THIS LINE
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

		cardRefs[boostId] = { card=card, cs=cs, buyBtn=buyBtn, actBtn=actBtn, invBadge=invBadge, color=color }

		buyBtn.MouseButton1Down:Connect(function() BuyBoost:FireServer(boostId) end)
		actBtn.MouseButton1Down:Connect(function()
			local state = boostState[boostId]
			if not state or (state.inventoryCount or 0) <= 0 then return end
			ActivateBoost:FireServer(boostId)
		end)
	end
end

BuildCards()

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

		if invCount <= 0 then
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

-- AchievementController
-- Location: StarterPlayer > StarterPlayerScripts > AchievementController

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local UITheme = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
local T = UITheme.Get("Custom")
local SoundConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SoundConfig"))

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local panelOpen = false
local activeTab = "Challenges"

local function PlayUI(id) if shared.PlayUISound then shared.PlayUISound(id) end end

---------------------------------------------------------------
-- 1. THE CIRCULAR BUTTON (Top Left)
---------------------------------------------------------------
local AchieveBtn = Instance.new("ImageButton")
AchieveBtn.Name = "AchievementButton"
AchieveBtn.Size = UDim2.new(0, 46, 0, 46)
AchieveBtn.Position = UDim2.new(0, 20, 0, 20) -- Top Left Corner
AchieveBtn.BackgroundColor3 = T.buttonSecondary
AchieveBtn.BorderSizePixel = 0
AchieveBtn.AutoButtonColor = false
AchieveBtn.ZIndex = 15
AchieveBtn.Parent = mainHUD

-- Make it a perfect circle
Instance.new("UICorner", AchieveBtn).CornerRadius = UDim.new(0.5, 0)
local btnStroke = Instance.new("UIStroke", AchieveBtn)
btnStroke.Color = T.accentGold; btnStroke.Thickness = 2

-- PLACEHOLDER: Add your own Trophy or Star Icon ID here!
local btnIcon = Instance.new("ImageLabel", AchieveBtn)
btnIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
btnIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
btnIcon.BackgroundTransparency = 1
btnIcon.Image = "rbxassetid://0" -- <-- PUT YOUR ICON ID HERE
btnIcon.ScaleType = Enum.ScaleType.Fit

---------------------------------------------------------------
-- 2. THE MAIN PANEL
---------------------------------------------------------------
local Panel = Instance.new("Frame")
Panel.Name = "AchievementPanel"
Panel.Size = UDim2.new(0.85, 0, 0.75, 0)
Panel.Position = UDim2.new(0.5, 0, 0.5, 0)
Panel.AnchorPoint = Vector2.new(0.5, 0.5)
Panel.BackgroundColor3 = T.panelBG; Panel.BorderSizePixel = 0
Panel.Visible = false; Panel.ZIndex = 40; Panel.ClipsDescendants = true
Panel.Parent = mainHUD
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

local sizeConstraint = Instance.new("UISizeConstraint", Panel)
sizeConstraint.MaxSize = Vector2.new(500, 550) 
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color = T.panelStroke; panelStroke.Thickness = 2

-- Header
local Header = Instance.new("Frame", Panel)
Header.Size = UDim2.new(1, 0, 0, 44); Header.BackgroundColor3 = T.headerBG; Header.BorderSizePixel = 0; Header.ZIndex = 41
local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -50, 1, 0); TitleLabel.Position = UDim2.new(0, 14, 0, 0); TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PROGRESSION"; TitleLabel.TextColor3 = T.headerText; TitleLabel.TextScaled = true; TitleLabel.Font = T.font; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -36, 0.5, -14); CloseBtn.BackgroundColor3 = T.buttonRed; CloseBtn.Text = "X"; CloseBtn.TextColor3 = T.headerText; CloseBtn.TextScaled = true; CloseBtn.Font = T.font; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- Tab Bar
local TabBar = Instance.new("Frame", Panel)
TabBar.Size = UDim2.new(1, -20, 0, 36); TabBar.Position = UDim2.new(0, 10, 0, 50); TabBar.BackgroundTransparency = 1; TabBar.ZIndex = 41
local tabBtns = {}
local scrolls = {}

local function MakeTab(name, text, scaleX)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.25, -4, 1, 0); btn.Position = UDim2.new(scaleX, 0, 0, 0)
	btn.BackgroundColor3 = T.buttonSecondary; btn.Text = text; btn.TextColor3 = T.bodyText; btn.TextScaled = true; btn.Font = T.font
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	tabBtns[name] = btn

	local sf = Instance.new("ScrollingFrame", Panel)
	sf.Size = UDim2.new(1, -20, 1, -96); sf.Position = UDim2.new(0, 10, 0, 96)
	sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 4; sf.Visible = false
	local layout = Instance.new("UIListLayout", sf)
	layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
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
-- 3. CONTENT BUILDERS (PLACEHOLDERS)
---------------------------------------------------------------
local function CreateRow(parent, title, desc, iconColor, statusText, statusColor)
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1, 0, 0, 64); row.BackgroundColor3 = T.cardBG; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", row); stroke.Color = iconColor; stroke.Thickness = 1

	local icon = Instance.new("Frame", row)
	icon.Size = UDim2.new(0, 40, 0, 40); icon.Position = UDim2.new(0, 12, 0.5, -20); icon.BackgroundColor3 = iconColor; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

	local tLbl = Instance.new("TextLabel", row)
	tLbl.Size = UDim2.new(0.6, 0, 0, 20); tLbl.Position = UDim2.new(0, 64, 0, 10); tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = T.bodyText; tLbl.TextScaled = true; tLbl.Font = T.font; tLbl.TextXAlignment = Enum.TextXAlignment.Left

	local dLbl = Instance.new("TextLabel", row)
	dLbl.Size = UDim2.new(0.6, 0, 0, 16); dLbl.Position = UDim2.new(0, 64, 0, 32); dLbl.BackgroundTransparency = 1; dLbl.Text = desc; dLbl.TextColor3 = T.subText; dLbl.TextScaled = true; dLbl.Font = T.fontBody; dLbl.TextXAlignment = Enum.TextXAlignment.Left

	local sLbl = Instance.new("TextLabel", row)
	sLbl.Size = UDim2.new(0, 80, 0, 24); sLbl.Position = UDim2.new(1, -90, 0.5, -12); sLbl.BackgroundTransparency = 1; sLbl.Text = statusText; sLbl.TextColor3 = statusColor; sLbl.TextScaled = true; sLbl.Font = T.font; sLbl.TextXAlignment = Enum.TextXAlignment.Right
end

-- [ PLACEHOLDER: BOOST CHALLENGES ]
CreateRow(scrolls["Challenges"], "Spawn 1,000 Auras", "Unlocks: Aura Rush Boost", T.accentBlue, "0/1000", T.subText)
CreateRow(scrolls["Challenges"], "Reach Area 2", "Unlocks: Soul Boost", T.accentPurple, "LOCKED", T.buttonRed)
CreateRow(scrolls["Challenges"], "Prestige 5 Times", "Unlocks: 50x Beacon", T.buttonRed, "DONE", T.buttonGreen)

-- [ PLACEHOLDER: AURA INDEX ]
CreateRow(scrolls["Index"], "Common Aura", "Multiplier: 1.0x", Color3.fromRGB(220, 220, 220), "Discovered", T.buttonGreen)
CreateRow(scrolls["Index"], "Uncommon Aura", "Multiplier: 1.5x", Color3.fromRGB(80, 200, 80), "Discovered", T.buttonGreen)
CreateRow(scrolls["Index"], "Legendary Aura", "Multiplier: 25.0x", Color3.fromRGB(255, 200, 0), "???", T.subText)

-- [ PLACEHOLDER: ROBLOX BADGES ]
-- To award these, you will use BadgeService:AwardBadge(player.UserId, BADGE_ID) in your server scripts!
CreateRow(scrolls["Badges"], "First Prestige", "Prestige for the first time.", T.accentGold, "LOCKED", T.subText)
CreateRow(scrolls["Badges"], "Millionaire", "Hold $1,000,000 at once.", T.accentGreen, "EARNED", T.buttonGreen)

-- [ PLACEHOLDER: LEADERBOARD ]
CreateRow(scrolls["Leaderboard"], "1. MoldySugar2205", "Total Earnings", T.accentGold, "$5.2B", T.accentGreen)
CreateRow(scrolls["Leaderboard"], "2. PlayerName", "Total Earnings", Color3.fromRGB(192,192,192), "$1.1B", T.accentGreen)

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

AddButtonJuice(AchieveBtn)
AddButtonJuice(CloseBtn)

AchieveBtn.MouseButton1Down:Connect(function()
	PlayUI(SoundConfig.UIOpen or "")
	panelOpen = true; Panel.Visible = true; Panel.Size = UDim2.new(0.85, 0, 0, 0)

	-- Force trigger click on the active tab so it displays properly
	tabBtns[activeTab].BackgroundColor3 = T.panelStroke
	scrolls[activeTab].Visible = true

	TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.85, 0, 0.75, 0)}):Play()
	UITheme.SetMenuVisible(true)
end)

CloseBtn.MouseButton1Down:Connect(function()
	PlayUI(SoundConfig.UIClose or "")
	panelOpen = false
	TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0.85, 0, 0, 0)}):Play()
	UITheme.SetMenuVisible(false)
	task.delay(0.25, function() Panel.Visible = false end)
end)

-- Glass theme apply
task.spawn(function()
	task.wait(1)
	UITheme.Apply(Panel, "Panel")
	UITheme.Apply(Header, "TitleBar")
	UITheme.ApplyShine(Panel)
	for _, s in pairs(scrolls) do
		for _, row in ipairs(s:GetChildren()) do
			if row:IsA("Frame") then UITheme.Apply(row, "Card") end
		end
	end
end)

