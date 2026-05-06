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
local Faded2 = mainHUD:WaitForChild("Faded2") 
local panelOpen = false
local activeTab = "Challenges"
local activeTabText = "Boosts" -- For the hover label
local latestStats = {}

local function PlayUI(id) if shared.PlayUISound then shared.PlayUISound(id) end end

---------------------------------------------------------------
-- 1. THE CIRCULAR BUTTON (Right Side of Faded2)
---------------------------------------------------------------
local AchieveBtn = Instance.new("ImageButton", Faded2) -- ✨ PARENTED TO FADED2
AchieveBtn.Name = "AchievementButton"
AchieveBtn.Size = UDim2.new(0.85, 0, 0.85, 0) -- ✨ Takes up 85% of Faded2's height
AchieveBtn.Position = UDim2.new(0.95, 0, 0.5, 0) -- ✨ Placed on the far right
AchieveBtn.AnchorPoint = Vector2.new(1, 0.5) -- ✨ Anchored perfectly center-right
AchieveBtn.BackgroundColor3 = T.buttonSecondary
AchieveBtn.BorderSizePixel = 0
AchieveBtn.AutoButtonColor = false
AchieveBtn.ZIndex = 15
Instance.new("UICorner", AchieveBtn).CornerRadius = UDim.new(0.5, 0)

-- ✨ MOBILE FIX: Forces it to stay a perfect circle no matter the screen size!
local achieveAspect = Instance.new("UIAspectRatioConstraint", AchieveBtn)
achieveAspect.AspectRatio = 1.0 

local btnStroke = Instance.new("UIStroke", AchieveBtn)
btnStroke.Color = T.accentGold; btnStroke.Thickness = 1

local btnIcon = Instance.new("ImageLabel", AchieveBtn)
btnIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
btnIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
btnIcon.BackgroundTransparency = 1; btnIcon.ScaleType = Enum.ScaleType.Fit
btnIcon.Image = "rbxassetid://14916846070"

---------------------------------------------------------------
-- 2. THE MAIN PANEL & HEADER
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
local CloseBtn = Instance.new("TextButton", Header); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -36, 0.5, -14); CloseBtn.BackgroundColor3 = T.buttonRed; CloseBtn.Text = "X"; CloseBtn.TextColor3 = T.headerText; CloseBtn.TextScaled = true; CloseBtn.Font = T.font; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5); CloseBtn.ZIndex = 9999


---------------------------------------------------------------
-- 3. CIRCULAR TABS & HOVER LABEL
---------------------------------------------------------------
local TabContainer = Instance.new("Frame", Panel)
TabContainer.Size = UDim2.new(1, 0, 0, 75); TabContainer.Position = UDim2.new(0, 0, 0, 44); TabContainer.BackgroundTransparency = 1; TabContainer.ZIndex = 41

local HoverLabel = Instance.new("TextLabel", TabContainer)
HoverLabel.Size = UDim2.new(1, 0, 0, 20); HoverLabel.Position = UDim2.new(0, 0, 1, -15); HoverLabel.BackgroundTransparency = 1
HoverLabel.Text = "Boosts"; HoverLabel.TextColor3 = T.bodyText; HoverLabel.TextScaled = true; HoverLabel.Font = T.font

local TabButtonFrame = Instance.new("Frame", TabContainer)
TabButtonFrame.Size = UDim2.new(1, 0, 1, -20); TabButtonFrame.Position = UDim2.new(0, 0, 0, 0); TabButtonFrame.BackgroundTransparency = 1
local TabListLayout = Instance.new("UIListLayout", TabButtonFrame)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal; TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center; TabListLayout.Padding = UDim.new(0, 20)

local tabBtns = {}; local scrolls = {}

local function MakeTab(name, hoverText, iconId)
	local btn = Instance.new("ImageButton", TabButtonFrame)
	btn.Size = UDim2.new(0, 45, 0, 45); btn.BackgroundColor3 = T.buttonSecondary; btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)

	-- ✨ TUTORIAL TAG! Now your tutorial config can target "ChallengesTab", "IndexTab", etc.
	btn:SetAttribute("TutorialTarget", name .. "Tab")

	local tStroke = Instance.new("UIStroke", btn)
	tStroke.Color = T.panelStroke; tStroke.Thickness = 2

	local icon = Instance.new("ImageLabel", btn)
	icon.Size = UDim2.new(0.6, 0, 0.6, 0); icon.Position = UDim2.new(0.2, 0, 0.2, 0); icon.BackgroundTransparency = 1; icon.ScaleType = Enum.ScaleType.Fit; icon.Image = iconId
	tabBtns[name] = {btn = btn, stroke = tStroke}

	-- Mobile-responsive Scrolling Frame
	local sf = Instance.new("ScrollingFrame", Panel)
	sf.Size = UDim2.new(1, -20, 1, -135); sf.Position = UDim2.new(0, 10, 0, 125); sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 4; sf.Visible = false
	local layout = Instance.new("UIListLayout", sf); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end)
	scrolls[name] = sf

	-- Dynamic Hover Text Logic
	btn.MouseEnter:Connect(function() HoverLabel.Text = hoverText end)
	btn.MouseLeave:Connect(function() HoverLabel.Text = activeTabText end)

	btn.MouseButton1Down:Connect(function()
		PlayUI(SoundConfig.UIClick or "")
		activeTab = name; activeTabText = hoverText; HoverLabel.Text = activeTabText
		for k, t in pairs(tabBtns) do 
			t.btn.BackgroundColor3 = (k == name) and T.accentGold or T.buttonSecondary 
			t.stroke.Color = (k == name) and T.bodyText or T.panelStroke
		end
		for k, s in pairs(scrolls) do s.Visible = (k == name) end
	end)
end

-- 🖼️ PLACEHOLDERS: Replace "rbxassetid://14916846070" with your actual icon IDs!
MakeTab("Challenges", "Boosts", "rbxassetid://14916846070")
MakeTab("Index", "Auras", "rbxassetid://14916846070")
MakeTab("Badges", "Badges", "rbxassetid://14916846070")
MakeTab("Leaderboard", "Top 10", "rbxassetid://14916846070")

---------------------------------------------------------------
-- 4. DYNAMIC CONTENT BUILDER (SMART UPDATES)
---------------------------------------------------------------
local function UpdateOrCreateRow(parent, id, title, desc, hoverDesc, iconImage, iconColor, statusText, statusColor)
	-- Look for an existing row so we don't delete it while the player is hovering!
	local row = parent:FindFirstChild(id)

	if not row then
		-- Create it for the first time
		row = Instance.new("TextButton", parent) -- TextButtons track hovering much better than Frames!
		row.Name = id; row.Text = ""; row.AutoButtonColor = false
		row.Size = UDim2.new(1, -8, 0, 64); row.BackgroundColor3 = T.cardBG
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke", row); stroke.Name = "Stroke"; stroke.Thickness = 1

		local icon = Instance.new("ImageLabel", row); icon.Name = "Icon"; icon.Size = UDim2.new(0, 40, 0, 40); icon.Position = UDim2.new(0, 12, 0.5, -20); icon.ScaleType = Enum.ScaleType.Fit; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

		local tLbl = Instance.new("TextLabel", row); tLbl.Name = "Title"; tLbl.Size = UDim2.new(0.6, 0, 0, 20); tLbl.Position = UDim2.new(0, 64, 0, 10); tLbl.BackgroundTransparency = 1; tLbl.TextColor3 = T.bodyText; tLbl.TextScaled = true; tLbl.Font = T.font; tLbl.TextXAlignment = Enum.TextXAlignment.Left
		local dLbl = Instance.new("TextLabel", row); dLbl.Name = "Desc"; dLbl.Size = UDim2.new(0.6, 0, 0, 16); dLbl.Position = UDim2.new(0, 64, 0, 32); dLbl.BackgroundTransparency = 1; tLbl.TextColor3 = T.subText; dLbl.TextScaled = true; dLbl.Font = T.fontBody; dLbl.TextXAlignment = Enum.TextXAlignment.Left
		local sLbl = Instance.new("TextLabel", row); sLbl.Name = "Status"; sLbl.Size = UDim2.new(0, 80, 0, 24); sLbl.Position = UDim2.new(1, -90, 0.5, -12); sLbl.BackgroundTransparency = 1; sLbl.TextScaled = true; sLbl.Font = T.font; sLbl.TextXAlignment = Enum.TextXAlignment.Right

		UITheme.Apply(row, "Card")

		-- ✨ SMART HOVER LOGIC
		row:SetAttribute("IsHovering", false)
		row.MouseEnter:Connect(function() 
			row:SetAttribute("IsHovering", true)
			local hd = row:GetAttribute("HoverDesc")
			if hd and hd ~= "" then
				row.Desc.Text = hd; row.Desc.TextColor3 = T.accentGold
			end
		end)
		row.MouseLeave:Connect(function() 
			row:SetAttribute("IsHovering", false)
			row.Desc.Text = row:GetAttribute("NormalDesc") or ""; row.Desc.TextColor3 = T.subText 
		end)
	end

	-- ✨ UPDATE THE ROW LIVE (Without deleting it)
	row:SetAttribute("NormalDesc", desc)
	row:SetAttribute("HoverDesc", hoverDesc)

	row.Title.Text = title
	row.Status.Text = statusText
	row.Status.TextColor3 = statusColor
	row.Icon.Image = iconImage
	row.Icon.BackgroundColor3 = iconColor
	row.Stroke.Color = iconColor

	-- Keep the correct text showing based on if their mouse is currently on it
	if row:GetAttribute("IsHovering") and hoverDesc and hoverDesc ~= "" then
		row.Desc.Text = hoverDesc; row.Desc.TextColor3 = T.accentGold
	else
		row.Desc.Text = desc; row.Desc.TextColor3 = T.subText
	end
end

local function RefreshData()
	-- 1. Build Challenges
	for i, chal in ipairs(AchievementConfig.Challenges) do
		local current = latestStats[chal.statKey] or 0
		local isDone = current >= chal.goal
		local statusText = isDone and "UNLOCKED" or (current .. " / " .. chal.goal)
		local statusColor = isDone and T.buttonGreen or T.subText

		local hoverReq = not isDone and ("Requires: " .. chal.desc) or "Boost Unlocked!"

		UpdateOrCreateRow(scrolls["Challenges"], "Chal_"..i, chal.title, chal.rewardText, hoverReq, chal.iconId, T.accentBlue, statusText, statusColor)
	end

	-- 2. Build Aura Index
	for i, tier in ipairs(TierConfig.Tiers) do
		local discovered = (latestStats.totalCubesProduced or 0) > 0
		if tier.name == "Legendary" then discovered = (latestStats.totalLegendaryCubes or 0) > 0 end
		local statusText = discovered and "Found" or "???"
		local statusColor = discovered and T.buttonGreen or T.buttonRed
		UpdateOrCreateRow(scrolls["Index"], "Index_"..i, tier.name .. " Aura", "Multiplier: " .. tier.multiplier .. "x", nil, "rbxassetid://0", tier.color, statusText, statusColor)
	end

	-- 3. Build Badges
	for i, badge in ipairs(AchievementConfig.Badges) do
		UpdateOrCreateRow(scrolls["Badges"], "Badge_"..i, badge.title, badge.desc, nil, badge.iconId, T.accentGold, "BADGE", T.subText)
	end

	-- 4. Leaderboard Placeholder
	UpdateOrCreateRow(scrolls["Leaderboard"], "Leader_1", "1. MoldySugar2205", "Total Earnings", nil, "rbxassetid://0", T.accentGold, "Top Player", T.accentGreen)
end

UpdateHUD.OnClientEvent:Connect(function(stats)
	for key, value in pairs(stats) do latestStats[key] = value end
	if panelOpen then RefreshData() end
end)

---------------------------------------------------------------
-- 5. BUTTON JUICE & OPEN/CLOSE
---------------------------------------------------------------
local function AddButtonJuice(btn)
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	btn.MouseEnter:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1.08}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1}):Play() end)
	btn.MouseButton1Down:Connect(function() TweenService:Create(scale, TweenInfo.new(0.1), {Scale = 0.9}):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play() end)
end

AddButtonJuice(AchieveBtn); AddButtonJuice(CloseBtn)

-- Attach juice to the new circular tabs
for _, t in pairs(tabBtns) do AddButtonJuice(t.btn) end

AchieveBtn.MouseButton1Down:Connect(function()
	if panelOpen then
		-- Close Logic
		PlayUI(SoundConfig.UIClose or "")
		panelOpen = false
		TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0.85, 0, 0, 0)}):Play()
		UITheme.SetMenuVisible(false)
		task.delay(0.25, function() Panel.Visible = false end)
	else
		-- Open Logic
		PlayUI(SoundConfig.UIOpen or "")
		panelOpen = true; Panel.Visible = true; Panel.Size = UDim2.new(0.85, 0, 0, 0)

		for k, t in pairs(tabBtns) do 
			t.btn.BackgroundColor3 = (k == activeTab) and T.accentGold or T.buttonSecondary 
			t.stroke.Color = (k == activeTab) and T.bodyText or T.panelStroke
		end
		scrolls[activeTab].Visible = true
		HoverLabel.Text = activeTabText
		RefreshData()

		TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.85, 0, 0.75, 0)}):Play()
		UITheme.SetMenuVisible(true)
	end
end)

CloseBtn.MouseButton1Down:Connect(function()
	PlayUI(SoundConfig.UIClose or ""); panelOpen = false
	TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0.85, 0, 0, 0)}):Play()
	UITheme.SetMenuVisible(false); task.delay(0.25, function() Panel.Visible = false end)
end)

task.spawn(function()
	task.wait(1)
	UITheme.Apply(Panel, "Panel")
	UITheme.Apply(Header, "TitleBar")
	UITheme.ApplyShine(Panel)

end)



-- AreaTransitionController
-- Location: StarterPlayer > StarterPlayerScripts > AreaTransitionController
--
-- PER-AREA AURA PLACEMENT:
--   yOffset   = studs up/down from Position Part  (e.g. 5 = 5 studs above)
--   yRotation = degrees of Y-axis rotation        (e.g. 90 = quarter turn)
--   Both set in AreaRegistry per area.
--
-- AURA MODEL LOOKUP ORDER:
--   1. ReplicatedStorage/AreaAssets/Area{N}/AuraModel
--   2. workspace/Map/Ignore/Area{N}Aura
--
-- ALL TweenService:Create calls wrapped in pcall.
-- activeSwap has 10s timeout — no permanent deadlock.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local AreaRegistry = require(ReplicatedStorage.Modules.AreaRegistry)

-- ✨ NEW: Import the custom VFX API
local VFX_API = require(ReplicatedStorage:WaitForChild("vfx"))

local AreaChanged = ReplicatedStorage.RemoteEvents:WaitForChild("AreaChanged")
local AreaUpdated = ReplicatedStorage.RemoteEvents:WaitForChild("AreaUpdated")

local Map        = workspace:WaitForChild("Map")
local AuraHolder = workspace:WaitForChild("AuraHolder")
local HabitatHolder = workspace:WaitForChild("HabitatHolder") 
local AreaAssets = ReplicatedStorage:WaitForChild("AreaAssets")
local MapIgnore  = Map:FindFirstChild("Ignore")
local HabitatPositionPart = HabitatHolder:WaitForChild("Position") 
local PositionPart = AuraHolder:WaitForChild("Position")

local DECORATION_CONTAINER = Map:WaitForChild("Path")

local TWEEN_DURATION = 2.5
local FADE_DURATION  = 0.5
local SWAP_TIMEOUT   = 10

local MAP_PART_COLORS = {
	Floor      = "grassColor",
	AssetFloor = "grassColor",
	Path       = "pathColor",
}

local currentAuraModel = nil
local activeSwap       = false
local swapStartedAt    = 0

---------------------------------------------------------------
-- SAFE TWEEN
---------------------------------------------------------------
local function SafeTween(instance, tweenInfo, properties)
	pcall(function()
		TweenService:Create(instance, tweenInfo, properties):Play()
	end)
end

---------------------------------------------------------------
-- TRANSPARENCY HELPERS
---------------------------------------------------------------
local function SetTransparency(obj, alpha)
	if obj:IsA("BasePart") then
		pcall(function() obj.Transparency = alpha end)
	elseif obj:IsA("Model") then
		for _, p in ipairs(obj:GetDescendants()) do
			if p:IsA("BasePart") then
				pcall(function() p.Transparency = alpha end)
			end
		end
	end
end

local function TweenTransparency(obj, alpha, duration)
	local info   = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local tweens = {}
	local parts  = {}
	if obj:IsA("BasePart") then
		table.insert(parts, obj)
	elseif obj:IsA("Model") then
		for _, p in ipairs(obj:GetDescendants()) do
			if p:IsA("BasePart") then table.insert(parts, p) end
		end
	end
	for _, part in ipairs(parts) do
		local ok, t = pcall(function()
			return TweenService:Create(part, info, { Transparency = alpha })
		end)
		if ok and t then t:Play(); table.insert(tweens, t) end
	end
	return tweens
end

---------------------------------------------------------------
-- PLACE AT POSITION WITH OFFSET + ROTATION
-- Builds a CFrame from Position Part + yOffset + yRotation.
--   yOffset   = studs along world Y axis
--   yRotation = degrees around world Y axis
---------------------------------------------------------------
local function PlaceAtPosition(obj, yOffset, yRotation)
	local pos      = PositionPart.Position + Vector3.new(0, yOffset or 0, 0)
	local rotation = CFrame.Angles(0, math.rad(yRotation or 0), 0)
	local targetCF = CFrame.new(pos) * rotation

	pcall(function()
		if obj:IsA("Model") then
			obj:PivotTo(targetCF)
		elseif obj:IsA("BasePart") then
			obj.CFrame = targetCF
		end
	end)
end

---------------------------------------------------------------
-- AURA MODEL LOOKUP
---------------------------------------------------------------
local function GetAuraTemplate(areaIndex)
	local folder  = AreaAssets:FindFirstChild("Area" .. areaIndex)
	local rsModel = folder and folder:FindFirstChild("AuraModel")
	if rsModel then return rsModel end

	if MapIgnore then
		local ignoreModel = MapIgnore:FindFirstChild("Area" .. areaIndex .. "Aura")
		if ignoreModel then return ignoreModel end
	end

	warn("[AreaTransition] No AuraModel for area " .. areaIndex
		.. " — checked AreaAssets/Area" .. areaIndex .. "/AuraModel"
		.. " and Map/Ignore/Area" .. areaIndex .. "Aura")
	return nil
end

---------------------------------------------------------------
-- AURA HOLDER SWAP
---------------------------------------------------------------
local function SwapAuraHolder(areaIndex, instant)
	local template = GetAuraTemplate(areaIndex)
	if not template then
		warn("[AreaTransition] Skipping swap — no template for area " .. areaIndex)
		return
	end

	local yOffset   = AreaRegistry.GetYOffset(areaIndex)
	local yRotation = AreaRegistry.GetYRotation(areaIndex)

	if instant then
		for _, child in ipairs(AuraHolder:GetChildren()) do
			if child ~= PositionPart then 
				-- ✨ NEW: Disable old custom VFX before destroying the part
				pcall(function() VFX_API.disable(child) end)
				child:Destroy() 
			end
		end
		currentAuraModel = nil

		local newModel = template:Clone()
		newModel.Parent = AuraHolder
		PlaceAtPosition(newModel, yOffset, yRotation)
		currentAuraModel = newModel

		-- ✨ NEW: Instantly enable the custom VFX once placed in Workspace
		pcall(function() VFX_API.enable(newModel) end)

	else
		if activeSwap and (tick() - swapStartedAt) < SWAP_TIMEOUT then return end
		activeSwap    = true
		swapStartedAt = tick()

		task.spawn(function()
			if currentAuraModel and currentAuraModel.Parent then
				-- ✨ NEW: Disable old custom VFX smoothly as the model fades out
				pcall(function() VFX_API.disable(currentAuraModel) end)

				local outTweens = TweenTransparency(currentAuraModel, 1, FADE_DURATION)
				if #outTweens > 0 then
					outTweens[1].Completed:Wait()
				else
					task.wait(FADE_DURATION)
				end
				if currentAuraModel and currentAuraModel.Parent then
					currentAuraModel:Destroy()
				end
				currentAuraModel = nil
			else
				task.wait(FADE_DURATION)
			end

			local newModel = template:Clone()
			newModel.Parent = AuraHolder
			PlaceAtPosition(newModel, yOffset, yRotation)
			SetTransparency(newModel, 1)
			currentAuraModel = newModel

			-- ✨ NEW: Turn on the new custom VFX so it begins while fading in
			pcall(function() VFX_API.enable(newModel) end)

			TweenTransparency(newModel, 0, FADE_DURATION)

			task.wait(FADE_DURATION)
			activeSwap = false
		end)
	end
end

---------------------------------------------------------------
-- HABITAT MODEL LOOKUP
---------------------------------------------------------------
local function GetHabitatTemplate(areaIndex)
	local folder  = AreaAssets:FindFirstChild("Area" .. areaIndex)
	local rsModel = folder and folder:FindFirstChild("HabitatModel")
	if rsModel then return rsModel end

	if MapIgnore then
		local ignoreModel = MapIgnore:FindFirstChild("Area" .. areaIndex .. "Habitat")
		if ignoreModel then return ignoreModel end
	end

	warn("[AreaTransition] No HabitatModel for area " .. areaIndex
		.. " — checked AreaAssets/Area" .. areaIndex .. "/HabitatModel")
	return nil
end

---------------------------------------------------------------
-- HABITAT SWAP
---------------------------------------------------------------
local currentHabitatModel = nil

local function SwapHabitat(areaIndex, instant)
	local template = GetHabitatTemplate(areaIndex)
	if not template then
		warn("[AreaTransition] Skipping habitat swap — no template for area " .. areaIndex)
		return
	end

	-- Optional: If you want to add yOffset/yRotation to AreaRegistry for habitats later!
	local yOffset = 0 
	local yRotation = 0

	if instant then
		for _, child in ipairs(HabitatHolder:GetChildren()) do
			if child ~= HabitatPositionPart then child:Destroy() end
		end
		currentHabitatModel = nil

		local newModel = template:Clone()
		newModel.Parent = HabitatHolder

		-- Positions it at the HabitatPositionPart
		local targetCF = CFrame.new(HabitatPositionPart.Position + Vector3.new(0, yOffset, 0)) * CFrame.Angles(0, math.rad(yRotation), 0)
		newModel:PivotTo(targetCF)

		currentHabitatModel = newModel
	else
		-- Async Tweening Swap
		task.spawn(function()
			if currentHabitatModel and currentHabitatModel.Parent then
				local outTweens = TweenTransparency(currentHabitatModel, 1, FADE_DURATION)
				if #outTweens > 0 then
					outTweens[1].Completed:Wait()
				else
					task.wait(FADE_DURATION)
				end
				if currentHabitatModel and currentHabitatModel.Parent then
					currentHabitatModel:Destroy()
				end
				currentHabitatModel = nil
			else
				task.wait(FADE_DURATION)
			end

			local newModel = template:Clone()
			newModel.Parent = HabitatHolder

			local targetCF = CFrame.new(HabitatPositionPart.Position + Vector3.new(0, yOffset, 0)) * CFrame.Angles(0, math.rad(yRotation), 0)
			newModel:PivotTo(targetCF)

			SetTransparency(newModel, 1)
			currentHabitatModel = newModel
			TweenTransparency(newModel, 0, FADE_DURATION)
		end)
	end
end
---------------------------------------------------------------
-- MAP COLORS
---------------------------------------------------------------
local function ApplyMapColors(areaData, instant)
	local info = TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	for _, part in ipairs(Map:GetChildren()) do
		if part:IsA("BasePart") then
			local key   = MAP_PART_COLORS[part.Name]
			local color = key and areaData[key]
			if color then
				if instant then pcall(function() part.Color = color end)
				else SafeTween(part, info, { Color = color }) end
			end
		end
	end
end

local function ApplyLighting(areaIndex, instant)
	local preset = AreaRegistry.GetLighting(areaIndex)

	-- 1. Tween standard Lighting properties
	local props = {}
	if preset.ClockTime then props.ClockTime = preset.ClockTime end
	if preset.Brightness then props.Brightness = preset.Brightness end
	if preset.FogEnd then props.FogEnd = preset.FogEnd end
	if preset.FogStart then props.FogStart = preset.FogStart end
	if preset.Ambient then props.Ambient = preset.Ambient end
	if preset.FogColor then props.FogColor = preset.FogColor end 

	if instant then
		for prop, val in pairs(props) do pcall(function() Lighting[prop] = val end) end
	elseif next(props) then
		SafeTween(Lighting, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), props)
	end

	-- ✨ 2. Tween Atmosphere properties
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		local atmoProps = {}
		if preset.Density then atmoProps.Density = preset.Density end
		if preset.Haze then atmoProps.Haze = preset.Haze end
		if preset.AtmosphereColor then atmoProps.Color = preset.AtmosphereColor end

		if instant then
			for prop, val in pairs(atmoProps) do pcall(function() atmosphere[prop] = val end) end
		elseif next(atmoProps) then
			SafeTween(atmosphere, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), atmoProps)
		end
	end

	-- ✨ 3. Tween SunRays properties (NEW!)
	local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	if sunRays then
		local rayProps = {}

		-- Use the preset intensity, or default back to 0.25 if the preset forgot to mention it
		if preset.SunRaysIntensity ~= nil then 
			rayProps.Intensity = preset.SunRaysIntensity 
		else
			rayProps.Intensity = 0.25
		end

		if instant then
			for prop, val in pairs(rayProps) do pcall(function() sunRays[prop] = val end) end
		elseif next(rayProps) then
			SafeTween(sunRays, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), rayProps)
		end
	end
end

---------------------------------------------------------------
-- SKYBOX (Updated to use Presets)
---------------------------------------------------------------
local function ApplySkybox(areaIndex, instant)
	local preset = AreaRegistry.GetLighting(areaIndex)
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if not sky then return end

	local function DoSwap()
		if preset.skyboxBk and preset.skyboxBk ~= "" then pcall(function() sky.SkyboxBk = preset.skyboxBk end) end
		if preset.skyboxDn and preset.skyboxDn ~= "" then pcall(function() sky.SkyboxDn = preset.skyboxDn end) end
		if preset.skyboxFt and preset.skyboxFt ~= "" then pcall(function() sky.SkyboxFt = preset.skyboxFt end) end
		if preset.skyboxLf and preset.skyboxLf ~= "" then pcall(function() sky.SkyboxLf = preset.skyboxLf end) end
		if preset.skyboxRt and preset.skyboxRt ~= "" then pcall(function() sky.SkyboxRt = preset.skyboxRt end) end
		if preset.skyboxUp and preset.skyboxUp ~= "" then pcall(function() sky.SkyboxUp = preset.skyboxUp end) end
	end

	if instant then DoSwap()
	else task.delay(TWEEN_DURATION * 0.5, DoSwap) end
end

---------------------------------------------------------------
-- AURAHOLDER RING TINT
---------------------------------------------------------------
local function ApplyAuraHolderTint(areaData, instant)
	if not areaData.auraHolderColor and not areaData.auraHolderGlow then return end
	local info = TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	for _, part in ipairs(AuraHolder:GetDescendants()) do
		if currentAuraModel and part:IsDescendantOf(currentAuraModel) then continue end
		if part == PositionPart then continue end
		if part:IsA("BasePart") and areaData.auraHolderColor then
			if instant then pcall(function() part.Color = areaData.auraHolderColor end)
			else SafeTween(part, info, { Color = areaData.auraHolderColor }) end
		end
		if part:IsA("PointLight") and areaData.auraHolderGlow then
			if instant then pcall(function() part.Color = areaData.auraHolderGlow end)
			else SafeTween(part, info, { Color = areaData.auraHolderGlow }) end
		end
	end
end

---------------------------------------------------------------
-- DECORATIONS
---------------------------------------------------------------
local function FadeDecorations(alpha, duration)
	local info   = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local tweens = {}
	for _, obj in ipairs(DECORATION_CONTAINER:GetDescendants()) do
		if obj:IsA("BasePart") then
			local ok, t = pcall(function()
				return TweenService:Create(obj, info, { Transparency = alpha })
			end)
			if ok and t then t:Play(); table.insert(tweens, t) end
		end
	end
	if #tweens > 0 then tweens[1].Completed:Wait() end
end

---------------------------------------------------------------
-- DECORATIONS (With Memory Transparency Fix)
---------------------------------------------------------------
local function SwapDecorations(areaIndex)
	local folder = AreaAssets:FindFirstChild("Area" .. areaIndex)
	local newDec = folder and folder:FindFirstChild("Decorations")

	-- 1. Fade OUT old decorations
	for _, child in ipairs(DECORATION_CONTAINER:GetChildren()) do
		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
				SafeTween(desc, TweenInfo.new(TWEEN_DURATION * 0.5), {Transparency = 1})
			end
		end
	end

	task.wait(TWEEN_DURATION * 0.5)

	-- Destroy the old ones once they are invisible
	for _, child in ipairs(DECORATION_CONTAINER:GetChildren()) do 
		child:Destroy() 
	end

	-- 2. Fade IN new decorations
	if newDec then
		for _, obj in ipairs(newDec:GetChildren()) do
			local clone = obj:Clone()

			-- ✨ THE FIX: Save the original transparency before making it invisible!
			for _, desc in ipairs(clone:GetDescendants()) do
				if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
					-- Memorize its true transparency as an Attribute
					desc:SetAttribute("OrigTrans", desc.Transparency)
					-- Now hide it for the fade-in
					desc.Transparency = 1
				end
			end

			clone.Parent = DECORATION_CONTAINER

			-- ✨ THE FIX: Tween back to the saved value instead of 0!
			for _, desc in ipairs(clone:GetDescendants()) do
				if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
					local targetTrans = desc:GetAttribute("OrigTrans") or 0
					SafeTween(desc, TweenInfo.new(TWEEN_DURATION * 0.5), {Transparency = targetTrans})
				end
			end
		end
	end
end

---------------------------------------------------------------
-- MASTER
---------------------------------------------------------------
local function ApplyAreaConfig(areaIndex, instant)
	local areaData = AreaRegistry.Get(areaIndex)
	SwapAuraHolder(areaIndex, instant)
	SwapHabitat(areaIndex, instant) 
	if areaData then
		ApplyMapColors(areaData, instant)
		ApplyLighting(areaIndex, instant) -- ✨ FIX: Passing areaIndex
		ApplySkybox(areaIndex, instant)   -- ✨ FIX: Passing areaIndex
		ApplyAuraHolderTint(areaData, instant)
	end

	if instant then
		local folder = AreaAssets:FindFirstChild("Area" .. areaIndex)
		local newDec = folder and folder:FindFirstChild("Decorations")
		for _, child in ipairs(DECORATION_CONTAINER:GetChildren()) do child:Destroy() end
		if newDec then
			for _, obj in ipairs(newDec:GetChildren()) do obj:Clone().Parent = DECORATION_CONTAINER end
		end
	else
		task.spawn(function() SwapDecorations(areaIndex) end)
	end
end

---------------------------------------------------------------
-- STARTUP
---------------------------------------------------------------
task.defer(function()
	--print("[AreaTransition] Position Part at:", PositionPart.Position)
	--print("[AreaTransition] Ready — yOffset + yRotation read from AreaRegistry per area")
end)

---------------------------------------------------------------
-- CONNECTIONS
---------------------------------------------------------------
local appliedOnJoin = false

AreaUpdated.OnClientEvent:Connect(function(info)
	if not appliedOnJoin then
		appliedOnJoin = true
		print("[AreaTransition] Join → area", info.currentArea or 1)
		ApplyAreaConfig(info.currentArea or 1, true)
	end
end)

AreaChanged.OnClientEvent:Connect(function(info)
	print("[AreaTransition] AreaChanged →", info.newArea, "(" .. (info.travelType or "?") .. ")")
	ApplyAreaConfig(info.newArea or 1, false)
end)

-- AuraHologramBridge (LocalScript)
-- Location: StarterPlayer > StarterPlayerScripts > AuraHologramBridge

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Hologram = require(ReplicatedStorage.Modules:WaitForChild("HologramModule"))

local function ApplyHologram(prompt)
	-- Determine color based on rarity attribute
	local isElite = prompt:GetAttribute("IsElite")
	local holoColor = isElite and Color3.fromRGB(255, 50, 255) or Color3.fromRGB(50, 255, 255)

	-- Create the cool hologram beam
	local auraHolo = Hologram.New(prompt, Vector3.new(0, 3, 0), false, true)
	auraHolo:SetBillboardActive(true)
	auraHolo:SetAlwaysOnTop(true)
	auraHolo:SetPrimaryColour(holoColor)
	auraHolo:SetTertiaryColour(Color3.fromRGB(255, 255, 255))

	-- ✨ LOCAL JUICE TRIGGER & ANTI-SPAM LOCK ✨
	prompt.Triggered:Connect(function(player)
		-- Instantly lock the prompt locally so it can't be spammed
		if prompt:GetAttribute("ClaimedLocally") then return end
		prompt:SetAttribute("ClaimedLocally", true)
		prompt.Enabled = false

		if player == Players.LocalPlayer then
			local amount = isElite and 5 or 1
			local LocalJuiceEvent = ReplicatedStorage:FindFirstChild("LocalJuiceEvent")
			if LocalJuiceEvent then
				LocalJuiceEvent:Fire(amount, "Auras")
			end
		end
	end)
end

-- 1. Catch new auras that spawn while playing
CollectionService:GetInstanceAddedSignal("AuraHologram"):Connect(ApplyHologram)

-- 2. Catch any auras that were already on the ground when you joined
for _, prompt in ipairs(CollectionService:GetTagged("AuraHologram")) do
	ApplyHologram(prompt)
end

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

local BoostsBtn = Instance.new("ImageButton")
BoostsBtn.Name = "BoostsButton"
BoostsBtn.Size = UDim2.new(0, 60, 0, 60)
BoostsBtn.AnchorPoint = Vector2.new(1, 1) -- ✨ Anchors perfectly to bottom right
BoostsBtn.Position = UDim2.new(0.98, 0, 0.77, 0) -- ✨ Stacked neatly above Shop
BoostsBtn.BackgroundColor3 = T.buttonPrimary; BoostsBtn.BorderSizePixel = 0
BoostsBtn.AutoButtonColor = false
BoostsBtn.ZIndex = 10; BoostsBtn.Parent = mainHUD
BoostsBtn:SetAttribute("TutorialTarget", "BoostsButton")
Instance.new("UICorner", BoostsBtn).CornerRadius = UDim.new(0.5, 0)

local bbStroke = Instance.new("UIStroke", BoostsBtn)
bbStroke.Color = T.accentPurple; bbStroke.Thickness = 2

local boostIcon = Instance.new("ImageLabel", BoostsBtn)
boostIcon.Size = UDim2.new(0.6, 0, 0.6, 0); boostIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
boostIcon.BackgroundTransparency = 1; boostIcon.ScaleType = Enum.ScaleType.Fit
boostIcon.Image = "rbxassetid://14916846070" -- 🖼️ PLACEHOLDER: Lightning Icon ID
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
ShopClose.ZIndex = 9999; ShopClose.Parent = ShopHeader
Instance.new("UICorner", ShopClose).CornerRadius = UDim.new(0, 5)

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
	for boostId, refs in pairs(cardRefs) do
		local cfg         = BoostConfig.Get(boostId)
		local state       = boostState[boostId]
		local color       = refs.color
		local invCount    = state and (state.inventoryCount or 0) or 0
		local activeCount = state and (state.activeCount or 0) or 0
		local cost        = cfg and cfg.cost or 0
		local canAfford   = liveGold >= cost
		local atCap       = activeCount >= (cfg and cfg.maxStack or 1)

		local isUnlocked, lockReason = AchievementConfig.IsBoostUnlocked(boostId, latestStats)

		refs.invBadge.Text       = "x" .. invCount
		refs.invBadge.TextColor3 = invCount > 0 and T.bodyText or Color3.fromRGB(100,100,120)

		if not isUnlocked then
			-- ✨ VISUALLY LOCKED STATE
			refs.buyBtn.Text             = "LOCKED"
			refs.buyBtn.BackgroundColor3 = T.buttonRed
			refs.buyBtn.TextColor3       = T.bodyText

			refs.actBtn.Text             = "Locked"
			refs.actBtn.BackgroundColor3 = T.buttonDisabled
			refs.actBtn.TextColor3       = T.subText

			-- ✨ SHOW REQUIREMENT IN RED
			refs.descLbl.Text = "Requires: " .. lockReason
			refs.descLbl.TextColor3 = T.buttonRed
		else
			-- ✨ VISUALLY UNLOCKED STATE
			refs.descLbl.Text = cfg.description or ""
			refs.descLbl.TextColor3 = T.subText

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

local function AddButtonJuice(btn)
	local scale = btn:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = btn
	end

	btn.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Scale = 1.08}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Scale = 1}):Play()
	end)

	btn.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.9}):Play()
	end)

	btn.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play()
	end)
end

AddButtonJuice(BoostsBtn)

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

-- ClickHandler
-- Location: StarterPlayer > StarterPlayerScripts > ClickHandler

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local AdminConfig = require(ReplicatedStorage.Modules.AdminConfig)
local UITheme = require(game:GetService("ReplicatedStorage").Modules.UITheme)
local AreaRegistry = require(ReplicatedStorage.Modules.AreaRegistry) 
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)

local ProduceAura = ReplicatedStorage.RemoteEvents:WaitForChild("ProduceAura")
local AuraSpawned = ReplicatedStorage.RemoteEvents:WaitForChild("AuraSpawned")
local UpdateHatchery = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHatchery")
local ForceStopHold = ReplicatedStorage.RemoteEvents:WaitForChild("ForceStopHold")
local HabitatFull = ReplicatedStorage.RemoteEvents:WaitForChild("HabitatFull")
local UpdateMultiplier = ReplicatedStorage:WaitForChild("UpdateMultiplier")
local HabitatFullEvent = ReplicatedStorage:WaitForChild("HabitatFullEvent")
local CubeMutatedBatch = ReplicatedStorage.RemoteEvents:WaitForChild("CubeMutatedBatch")
local CubeSmushed = ReplicatedStorage.RemoteEvents:WaitForChild("CubeSmushed")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local holding = false
local fireRate = AdminConfig.FireRate
local holdStart = nil
local hatcheryEmpty = false
local habitatFull = false

local currentPassiveInterval = AdminConfig.PassiveInterval

local ClickButton = playerGui:WaitForChild("MainHUD"):WaitForChild("ClickButton")
local HatcheryBar = playerGui:WaitForChild("MainHUD"):WaitForChild("HatcheryBar")
local HatcheryFill = HatcheryBar:WaitForChild("Fill")
local HatcheryLabel = HatcheryBar:WaitForChild("Label")

local clickScale = ClickButton:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", ClickButton)
local clickStroke = ClickButton:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", ClickButton)
clickStroke.Color = Color3.fromRGB(255, 215, 0)
clickStroke.Thickness = 0
local basePos = ClickButton.Position
local tiltSide = 1

local Camera = workspace.CurrentCamera
local defaultFOV = 70 
local lastMilestone = 1

local MilestoneData = AdminConfig.MilestoneData

local playerMultSpeed = 1.0 
local playerMaxTier = 5     
local lastTierIndex = 1

local function FormatNumber(n)
	return NumberFormatter.Format(n)
end	

---------------------------------------------------------------
-- AURA MODEL FOLDERS & INSTANTIATION
---------------------------------------------------------------
local VFXFolder = ReplicatedStorage:FindFirstChild("VFX")
local cubeDataMap = {}

local TierScale = {
	Common    = 1.0,
	Uncommon  = 1.15,
	Rare      = 1.3,
	Epic      = 1.5,
	Legendary = 1.75,
}

local function CloneAuraModel(tierName, currentArea)
	currentArea = currentArea or 1
	local clone = AreaRegistry.FetchAuraModel(currentArea, tierName)
	if clone and not clone.PrimaryPart then
		warn("[Aura] Model '" .. tierName .. "' has no PrimaryPart set! Set PrimaryPart to the main BasePart for reliable positioning.")
	end
	return clone
end

local function CreatePlaceholderPart(color, glow)
	local part = Instance.new("Part")
	part.Size = Vector3.new(1.5, 1.5, 1.5)
	part.Color = color
	part.Anchored = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	if glow then
		local light = Instance.new("PointLight")
		light.Brightness = 3
		light.Range = 8
		light.Color = color
		light.Parent = part
	end
	return part
end

local function SpawnAuraInstance(tierName, color, glow, position, currentArea)
	local auraModel = CloneAuraModel(tierName, currentArea)
	if auraModel then
		auraModel:PivotTo(CFrame.new(position))
		auraModel.Parent = workspace
		if auraModel.PrimaryPart then
			auraModel.PrimaryPart.Anchored = false
			auraModel.PrimaryPart.CanCollide = true
			auraModel.PrimaryPart.CollisionGroup = "Auras"
		end
		return auraModel, true
	else
		local part = CreatePlaceholderPart(color, glow)
		part.Position = position
		part.CollisionGroup = "Auras"
		part.Parent = workspace
		return part, false
	end
end

local function GetRootPart(instance)
	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	end
	return instance
end

local function ScaleAura(instance, tierName, animated, fromTierName)
	local targetScale = TierScale[tierName] or 1.0
	local fromScale = fromTierName and (TierScale[fromTierName] or 1.0) or nil

	if instance:IsA("Model") then
		if animated then
			local scaleProxy = Instance.new("NumberValue")
			scaleProxy.Value = fromScale or 1.0

			local scaleTween = TweenService:Create(scaleProxy, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Value = targetScale
			})

			local conn
			conn = scaleProxy.Changed:Connect(function(val)
				if instance and instance.Parent then
					pcall(function() instance:ScaleTo(val) end)
				else
					conn:Disconnect()
				end
			end)

			scaleTween:Play()
			scaleTween.Completed:Connect(function()
				scaleProxy:Destroy()
				if conn then conn:Disconnect() end
			end)
		else
			pcall(function() instance:ScaleTo(targetScale) end)
		end
	elseif instance:IsA("BasePart") then
		local baseSize = 1.5
		local targetSize = Vector3.new(1, 1, 1) * (baseSize * targetScale)
		if animated then
			if fromScale then instance.Size = Vector3.new(1, 1, 1) * (baseSize * fromScale) end
			TweenService:Create(instance, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = targetSize
			}):Play()
		else
			instance.Size = targetSize
		end
	end
end

---------------------------------------------------------------
-- VFX SYSTEM
---------------------------------------------------------------
local function PlayVFX(effectName, position, duration)
	if not VFXFolder then return end
	local template = VFXFolder:FindFirstChild(effectName)
	if not template then return end

	local vfx = template:Clone()

	if vfx:IsA("Model") then vfx:PivotTo(CFrame.new(position))
	elseif vfx:IsA("BasePart") then vfx.Position = position end

	for _, obj in ipairs(vfx:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true; obj.Transparency = 1; obj.CanCollide = false; obj.CastShadow = false
		end
	end

	if vfx:IsA("BasePart") then
		vfx.Anchored = true; vfx.Transparency = 1; vfx.CanCollide = false; vfx.CastShadow = false
	end

	vfx.Parent = workspace

	for _, emitter in ipairs(vfx:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
			emitter:Emit(emitter:GetAttribute("BurstCount") or 15)
		end
	end

	task.delay((duration or 1.0) * 0.5, function()
		if vfx and vfx.Parent then
			for _, emitter in ipairs(vfx:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then emitter.Enabled = false end
			end
		end
	end)

	Debris:AddItem(vfx, duration or 1.5)
end

---------------------------------------------------------------
-- GAMEPLAY VISUAL LOGIC
---------------------------------------------------------------
local function GetCurrentMultiplier()
	if not holding or not holdStart then return 1.0, 1 end

	local holdTime = tick() - holdStart
	local effectiveTime = holdTime * playerMultSpeed 

	local currentTier = 1
	local nextTier = 1

	for i = 1, playerMaxTier do
		if effectiveTime >= MilestoneData[i].time then
			currentTier = i
			nextTier = math.min(i + 1, playerMaxTier)
		end
	end

	if currentTier == playerMaxTier then
		return MilestoneData[currentTier].mult, currentTier
	end

	local timePassedInTier = effectiveTime - MilestoneData[currentTier].time
	local timeNeededForNext = MilestoneData[nextTier].time - MilestoneData[currentTier].time
	local progressRatio = timePassedInTier / timeNeededForNext

	local currentMult = MilestoneData[currentTier].mult
	local nextMult = MilestoneData[nextTier].mult
	local smoothMult = currentMult + ((nextMult - currentMult) * progressRatio)

	return smoothMult, currentTier
end

local function PlayMilestoneSound(soundValue)
	if not soundValue or soundValue == "" then return end
	local sfxToPlay = nil

	if string.find(soundValue, "rbxassetid://") then
		sfxToPlay = Instance.new("Sound")
		sfxToPlay.SoundId = soundValue
		sfxToPlay.Volume = 0.6
	else
		local sfxFolder = ReplicatedStorage:FindFirstChild("SFX") or ReplicatedStorage:FindFirstChild("Sounds")
		if sfxFolder then
			local foundSound = sfxFolder:FindFirstChild(soundValue)
			if foundSound then
				sfxToPlay = foundSound:Clone()
				sfxToPlay.Volume = 0.6
			end
		end
	end

	if sfxToPlay then
		sfxToPlay.Parent = game:GetService("SoundService")
		sfxToPlay:Play()
		Debris:AddItem(sfxToPlay, sfxToPlay.TimeLength > 0 and sfxToPlay.TimeLength or 3)
	end
end

local function SpawnMilestonePopup(multFloor)
	local data = MilestoneData[multFloor]
	if not data then return end 

	PlayMilestoneSound(data.sound)

	local pop = Instance.new("TextLabel")
	pop.Text = data.name .. " (" .. string.format("%.1f", data.mult) .. "x)"
	pop.Font = Enum.Font.FredokaOne 
	pop.TextScaled = true
	pop.TextColor3 = data.color
	pop.BackgroundTransparency = 1
	pop.AnchorPoint = Vector2.new(0.5, 0.5)

	pop.Position = UDim2.new(
		ClickButton.Position.X.Scale, ClickButton.Position.X.Offset, 
		ClickButton.Position.Y.Scale - 0.15, ClickButton.Position.Y.Offset
	)
	pop.Parent = ClickButton.Parent

	local stroke = Instance.new("UIStroke", pop)
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(0, 0, 0)
	pop.Size = UDim2.new(0.1, 0, 0.02, 0) 

	TweenService:Create(pop, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.35, 0, 0.08, 0),
		Position = UDim2.new(
			pop.Position.X.Scale, pop.Position.X.Offset, 
			ClickButton.Position.Y.Scale - 0.25, ClickButton.Position.Y.Offset
		)
	}):Play()

	task.delay(0.6, function()
		TweenService:Create(pop, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
		task.delay(0.3, function() pop:Destroy() end)
	end)
end

local function UpdateButtonVisual()
	local col
	local mult = 1
	local currentTierIndex = 1

	if habitatFull then
		col = Color3.fromRGB(180, 60, 60)
	elseif not holding then
		col = Color3.fromRGB(255, 0, 0)
	else
		mult, currentTierIndex = GetCurrentMultiplier()
		col = MilestoneData[currentTierIndex].color
		UpdateMultiplier:Fire(mult)
	end

	local targetFOV = defaultFOV + (mult * 1.2)
	if not holding then targetFOV = defaultFOV end
	TweenService:Create(Camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = targetFOV}):Play()

	if holding then
		if currentTierIndex > lastTierIndex then
			if currentTierIndex > 1 then SpawnMilestonePopup(currentTierIndex) end
			lastTierIndex = currentTierIndex
		end
	else
		lastTierIndex = 1
	end

	TweenService:Create(ClickButton, TweenInfo.new(0.2), { BackgroundColor3 = col }):Play()

	if holding and not habitatFull then
		tiltSide = tiltSide * -1 
		if mult >= 5.0 then 
			TweenService:Create(ClickButton, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {
				Rotation = 8 * tiltSide
			}):Play()
			clickStroke.Thickness = 12
			clickStroke.Transparency = 0
			TweenService:Create(clickStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Thickness = 0, Transparency = 1}):Play()
		else
			TweenService:Create(ClickButton, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {
				Rotation = 3 * tiltSide
			}):Play()
		end
	elseif not holding then
		TweenService:Create(ClickButton, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 0}):Play()
		TweenService:Create(clickScale, TweenInfo.new(0.15), {Scale = 1}):Play()
	end
end

local function UpdateHatcheryBar(current, max)
	local ratio = math.clamp(current / max, 0, 1)
	TweenService:Create(HatcheryFill, TweenInfo.new(0.1), { Size = UDim2.new(ratio, 0, 1, 0) }):Play()

	local color = Color3.fromRGB(255, 60, 60)
	if ratio > 0.5 then color = Color3.fromRGB(80, 220, 80)
	elseif ratio > 0.25 then color = Color3.fromRGB(255, 200, 0) end

	TweenService:Create(HatcheryFill, TweenInfo.new(0.1), { BackgroundColor3 = color }):Play()
	HatcheryLabel.Text = "Hatchery: " .. math.floor(current) .. " / " .. max
	hatcheryEmpty = (current <= 0)
end

local function FlashEmpty()
	TweenService:Create(HatcheryFill, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	task.delay(0.1, function() TweenService:Create(HatcheryFill, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play() end)
end

local function ShowTierPopup(position, tierName, tierColor)
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(0.1, 0.1, 0.1); anchor.Anchored = true; anchor.Transparency = 1; anchor.CanCollide = false
	anchor.Position = position + Vector3.new(0, 3, 0); anchor.Parent = workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 120, 0, 40); bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = false; bb.Adornee = anchor; bb.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
	label.Text = tierName:upper(); label.TextColor3 = tierColor; label.TextScaled = true
	label.Font = Enum.Font.GothamBold; label.TextStrokeTransparency = 0.3; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Parent = bb

	TweenService:Create(bb, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 6, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, 2)
end

local function ShowCubeValue(position, value, color)
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(0.1, 0.1, 0.1); anchor.Anchored = true; anchor.Transparency = 1; anchor.CanCollide = false
	anchor.Position = position + Vector3.new(math.random(-1, 1), 2, math.random(-1, 1)); anchor.Parent = workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 80, 0, 25); bb.StudsOffset = Vector3.new(0, 0, 0)
	bb.AlwaysOnTop = false; bb.Adornee = anchor; bb.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
	label.Text = "Value: $" .. FormatNumber(value); label.TextColor3 = Color3.fromRGB(255, 255, 255); label.TextScaled = true
	label.Font = Enum.Font.Gotham; label.TextStrokeTransparency = 0.4; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Parent = bb

	TweenService:Create(bb, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 4, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, 1.5)
end

local function AttachPermanentRateLabel(auraInstance, baseValue)
	local rootPart = GetRootPart(auraInstance)
	if not rootPart then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "PermanentRateLabel"
	bb.Size = UDim2.new(0, 90, 0, 25)
	bb.StudsOffset = Vector3.new(0, 3.5, 0) 
	bb.AlwaysOnTop = false
	bb.Adornee = rootPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1

	local ratePerSec = baseValue / currentPassiveInterval
	label.Text = "+$" .. FormatNumber(ratePerSec) .. "/sec"

	label.TextColor3 = Color3.fromRGB(100, 255, 100) 
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Parent = bb

	bb.Parent = rootPart
	return label
end

---------------------------------------------------------------
-- ✨ NEW: DYNAMIC TRIGGER HOOKS (RECURSIVE)
---------------------------------------------------------------
local AuraHolder = workspace:WaitForChild("AuraHolder")
local HabitatHolder = workspace:WaitForChild("HabitatHolder")

local function HookAuraModel(model)
	-- Using task.delay and FindFirstChild(name, true) ensures it searches 
	-- through ALL sub-folders automatically as soon as it clones into Workspace
	task.delay(0.1, function()
		local smush = model:FindFirstChild("SmushTrigger", true)
		if smush then
			smush.Touched:Connect(function(hit)
				if hit:GetAttribute("AuraCube") and hit.Parent then
					for id, data in pairs(cubeDataMap) do
						if data.instance == hit or data.instance == hit.Parent then
							CubeSmushed:FireServer(id)
							PlayVFX("Spawn", hit.Position, 0.5) 
							if data.instance.Parent then data.instance:Destroy() end
							cubeDataMap[id] = nil
							break
						end
					end
				end
			end)
		end
	end)
end

local function HookHabitatModel(model)
	task.delay(0.1, function()
		local storage = model:FindFirstChild("StorageTrigger", true)
		if storage then
			storage.Touched:Connect(function(hit)
				if hit:GetAttribute("AuraCube") and hit.Parent then
					local label = hit:FindFirstChild("PermanentRateLabel", true)
					if label then label.Enabled = false end
				end
			end)
		end
	end)
end

-- Hook whenever AreaTransition loads new ones
AuraHolder.ChildAdded:Connect(function(child) if child:IsA("Model") then HookAuraModel(child) end end)
HabitatHolder.ChildAdded:Connect(function(child) if child:IsA("Model") then HookHabitatModel(child) end end)

-- Hook initial ones if they already exist
for _, child in ipairs(AuraHolder:GetChildren()) do if child:IsA("Model") then HookAuraModel(child) end end
for _, child in ipairs(HabitatHolder:GetChildren()) do if child:IsA("Model") then HookHabitatModel(child) end end

---------------------------------------------------------------
-- INPUT CONTROLS
---------------------------------------------------------------
local trackedInputs = {}

local function EvaluateHolding()
	local hasInput = false
	for _, _ in pairs(trackedInputs) do hasInput = true; break end

	if hasInput and not holding then
		if hatcheryEmpty then FlashEmpty() return end
		if habitatFull then return end
		holding = true
		holdStart = tick()
		TweenService:Create(clickScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.9}):Play()
		ProduceAura:FireServer("start")
	elseif not hasInput and holding then
		holding = false
		holdStart = nil
		ProduceAura:FireServer("stop")
		UpdateButtonVisual()
		UpdateMultiplier:Fire(1.0)
	end
end

ClickButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		trackedInputs[input] = true; EvaluateHolding()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if trackedInputs[input] then trackedInputs[input] = nil; EvaluateHolding() end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Space and not UserInputService:GetFocusedTextBox() then
		trackedInputs[input] = true; EvaluateHolding()
	end
end)

UserInputService.WindowFocusReleased:Connect(function()
	table.clear(trackedInputs); EvaluateHolding()
end)

ForceStopHold.OnClientEvent:Connect(function()
	table.clear(trackedInputs); EvaluateHolding()
end)

HabitatFull.OnClientEvent:Connect(function()
	habitatFull = true; 
	HabitatFullEvent:Fire(true); 
	table.clear(trackedInputs); 
	EvaluateHolding()
end)

HabitatFullEvent.Event:Connect(function(isFull)
	local auraModel = AuraHolder:FindFirstChildWhichIsA("Model")
	local conveyer = auraModel and auraModel:FindFirstChild("ConveyerPath", true)

	if isFull then 
		if conveyer then conveyer.AssemblyLinearVelocity = Vector3.new(20, 0, 0) end
	else 
		habitatFull = false; 
		UpdateButtonVisual() 
		if conveyer then conveyer.AssemblyLinearVelocity = Vector3.new(-20, 0, 0) end
	end
end)

UpdateHatchery.OnClientEvent:Connect(function(info)
	local finalMax = info.max
	local localHatchLvl = player:GetAttribute("LocalHatcheryLevel")

	if localHatchLvl then
		local UpgradeConfig = require(ReplicatedStorage.Modules.UpgradeConfig)
		local cfg = UpgradeConfig.GetUpgradeConfig("hatcheryCapacity")
		if cfg and cfg.apply then
			local predictedMax = cfg.apply({ upgrades = { hatcheryCapacity = localHatchLvl } })
			finalMax = math.max(info.max, predictedMax)
		end
	end
	UpdateHatcheryBar(info.current, finalMax)
end)

ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD").OnClientEvent:Connect(function(stats)
	if stats.passiveInterval ~= nil then
		currentPassiveInterval = stats.passiveInterval
	end

	if stats.pendingAuras and stats.habitatCapacity then
		if stats.pendingAuras < stats.habitatCapacity and habitatFull then
			habitatFull = false; HabitatFullEvent:Fire(false); UpdateButtonVisual()
		end
	end

	if stats.upgrades then
		local tierUnlocks = {
			{ upgradeId = "unlockOmniMult",      tier = 10 },
			{ upgradeId = "unlockUniversalMult", tier = 9 },
			{ upgradeId = "unlockGodlyMult",     tier = 8 },
			{ upgradeId = "unlockCosmicMult",    tier = 7 },
			{ upgradeId = "unlockMythicMult",    tier = 6 },
		}

		local calculatedMaxTier = 5 
		for _, data in ipairs(tierUnlocks) do
			local upgData = stats.upgrades[data.upgradeId]
			local level = (typeof(upgData) == "table" and upgData.level) or (typeof(upgData) == "number" and upgData) or 0
			if level > 0 then calculatedMaxTier = data.tier; break end
		end

		playerMaxTier = calculatedMaxTier

		local speedData = stats.upgrades["multiplierSpeed"]
		local speedLevel = (typeof(speedData) == "table" and speedData.level) or (typeof(speedData) == "number" and speedData) or 0
		playerMultSpeed = 1.0 + (speedLevel * 0.05) 
	end
end)

task.spawn(function()
	while true do
		if holding then
			if hatcheryEmpty or habitatFull then
				table.clear(trackedInputs); EvaluateHolding()
			else
				ProduceAura:FireServer(); UpdateButtonVisual()
			end
		end
		task.wait(fireRate)
	end
end)

---------------------------------------------------------------
-- AURA MUTATION RESPONSES (CLIENT BOUND)
---------------------------------------------------------------
AuraSpawned.OnClientEvent:Connect(function(info)
	local instance, isCustom = SpawnAuraInstance(info.tier, info.color, info.glow, info.spawnPos, info.currentArea)

	instance:SetAttribute("AuraCube", true)
	ScaleAura(instance, info.tier, false)
	ShowCubeValue(info.spawnPos, info.value, info.color)
	PlayVFX("Spawn", info.spawnPos, 1.0)

	local permLabel = AttachPermanentRateLabel(instance, info.value)

	if info.tier == "Legendary" then
		ShowTierPopup(info.spawnPos, "Legendary", Color3.fromRGB(255, 200, 0))
		PlayVFX("Legendary", info.spawnPos, 2.0)
	end

	if info.cubeId then
		cubeDataMap[info.cubeId] = { 
			instance = instance, 
			tierName = info.tier, 
			isCustom = isCustom,
			rateLabel = permLabel 
		}
		instance.AncestryChanged:Connect(function(_, parent)
			if not parent then cubeDataMap[info.cubeId] = nil end
		end)
	end
end)

CubeMutatedBatch.OnClientEvent:Connect(function(batchData)
	for _, info in ipairs(batchData) do
		local cubeData = cubeDataMap[info.cubeId]
		if not cubeData then continue end 

		local instance = cubeData.instance
		if not instance or not instance.Parent then continue end 

		local rootPart = GetRootPart(instance)
		if not rootPart then continue end 
		local position = rootPart.Position

		if info.mutationType == "tierUpgrade" then
			PlayVFX("TierUpgrade", position, 1.5)
			if info.tierName == "Legendary" then PlayVFX("Legendary", position, 2.0) end

			local oldTierName = cubeData.tierName
			local newAura = CloneAuraModel(info.tierName, info.currentArea)

			if newAura then
				newAura:PivotTo(CFrame.new(position))
				newAura.Parent = workspace
				newAura:SetAttribute("AuraCube", true)

				if newAura.PrimaryPart then
					newAura.PrimaryPart.Anchored = false
					newAura.PrimaryPart.CanCollide = true
					newAura.PrimaryPart.CollisionGroup = "Auras"
				end

				ScaleAura(newAura, info.tierName, true, oldTierName)

				if cubeData.rateLabel and cubeData.rateLabel.Parent then
					cubeData.rateLabel.Adornee = GetRootPart(newAura)
					cubeData.rateLabel.Parent = GetRootPart(newAura)
				end

				instance:Destroy()

				cubeData.instance = newAura
				cubeData.tierName = info.tierName
				cubeData.isCustom = true

				newAura.AncestryChanged:Connect(function(_, parent)
					if not parent then cubeDataMap[info.cubeId] = nil end
				end)
			else
				if rootPart:IsA("BasePart") then
					TweenService:Create(rootPart, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Color = info.newColor }):Play()
					if info.newGlow then
						local light = rootPart:FindFirstChildOfClass("PointLight")
						if not light then light = Instance.new("PointLight"); light.Parent = rootPart end
						TweenService:Create(light, TweenInfo.new(0.5), { Brightness = 3, Range = 8, Color = info.newColor }):Play()
					end
					ScaleAura(instance, info.tierName, true, oldTierName)
				end
				cubeData.tierName = info.tierName
			end
			ShowTierPopup(position, info.tierName, info.newColor)
		end
	end
end)

---------------------------------------------------------------
-- HUD BUTTON POLISH
---------------------------------------------------------------
local function AddBasicJuice(btn)
	if not btn then return end
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	btn.MouseEnter:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1.08}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1}):Play() end)
	btn.MouseButton1Down:Connect(function() TweenService:Create(scale, TweenInfo.new(0.1), {Scale = 0.9}):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play() end)
end

AddBasicJuice(playerGui:WaitForChild("MainHUD"):FindFirstChild("ModeToggle"))
AddBasicJuice(playerGui:WaitForChild("MainHUD"):FindFirstChild("SendButton"))

ReplicatedStorage.RemoteEvents.UpgradeUpdated.OnClientEvent:Connect(function(info)
	if not info or not info.upgrades then return end
	local speedData = info.upgrades["multiplierSpeed"]
	local speedLevel = (typeof(speedData) == "table" and speedData.level) or (typeof(speedData) == "number" and speedData) or 0
	playerMultSpeed = 1.0 + (speedLevel * 0.05) 

	local tierUnlocks = {
		{ upgradeId = "unlockOmniMult",      tier = 10 },
		{ upgradeId = "unlockUniversalMult", tier = 9 },
		{ upgradeId = "unlockGodlyMult",     tier = 8 },
		{ upgradeId = "unlockCosmicMult",    tier = 7 },
		{ upgradeId = "unlockMythicMult",    tier = 6 },
	}

	local calculatedMaxTier = 5 
	for _, data in ipairs(tierUnlocks) do
		local upgData = info.upgrades[data.upgradeId]
		local level = (typeof(upgData) == "table" and upgData.level) or (typeof(upgData) == "number" and upgData) or 0
		if level > 0 then calculatedMaxTier = data.tier; break end
	end

	playerMaxTier = calculatedMaxTier
end)

-- ForgeInit
-- Location: StarterPlayer > StarterPlayerScripts > ForgeInit
-- MUST run before VFXController. Name it "ForgeInit" so it
-- loads alphabetically before VFXController.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Replace "AuraSpawner" with whatever your Forge VFX module is named
-- and wherever it lives. Common locations:
local Forge = require(ReplicatedStorage:WaitForChild("ForgeVFX"))
-- OR if Forge is in a different location, e.g.:
-- local Forge = require(ReplicatedStorage:WaitForChild("Forge"))

Forge.init()
-- After this line, shared.vfx is set and VFXController can use it

	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")

	local SoundConfig = require(ReplicatedStorage.Modules.SoundConfig)
	local UITheme = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
	local T = UITheme.Get("Custom")
	local C = require(ReplicatedStorage.Modules.UIConfig)

	local Hologram = require(ReplicatedStorage.Modules:WaitForChild("HologramModule"))

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("MainHUD")
	local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

	local ClaimMail = RemoteEvents:WaitForChild("ClaimMail")
	local MailUpdated = RemoteEvents:WaitForChild("MailUpdated")

	local panelOpen = false
	local availableMail = {}
	local claimedIds = {}
	local cardRefs = {}
	local unreadCount = 0

	local PANEL_W = 360
	local PANEL_H = 420
	local HEADER_H = 44
	local CARD_H = 100
	local CARD_GAP = 8

	local function PlayUI(id)
		if shared.PlayUISound then shared.PlayUISound(id) end
	end

	local function FormatRewards(rewards)
		local parts = {}
		if rewards.goldenAuras and rewards.goldenAuras > 0 then
			table.insert(parts, "+" .. rewards.goldenAuras .. " Golden Auras")
		end
		if rewards.currency and rewards.currency > 0 then
			table.insert(parts, "+$" .. rewards.currency)
		end
		if rewards.boosts and type(rewards.boosts) == "table" then
			for id, count in pairs(rewards.boosts) do
				table.insert(parts, "+" .. count .. " " .. id)
			end
		end
		return #parts > 0 and table.concat(parts, ", ") or "No rewards"
	end

	---------------------------------------------------------------
	-- MAIL PANEL
	---------------------------------------------------------------
	local MailPanel = Instance.new("Frame")
	MailPanel.Name = "MailPanel"
	MailPanel.Size = UDim2.new(0.85, 0, 0.75, 0)
	MailPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	MailPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	MailPanel.BackgroundColor3 = T.panelBG; MailPanel.BorderSizePixel = 0
	MailPanel.Visible = false; MailPanel.ZIndex = 50; MailPanel.ClipsDescendants = true
	MailPanel.Parent = mainHUD
	Instance.new("UICorner", MailPanel).CornerRadius = UDim.new(0, 14)

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MaxSize = Vector2.new(PANEL_W, PANEL_H)
	sizeConstraint.Parent = MailPanel

	local pStroke = Instance.new("UIStroke")
	pStroke.Color = T.accentGold; pStroke.Thickness = 2; pStroke.Parent = MailPanel

	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, HEADER_H)
	Header.BackgroundColor3 = T.headerBG; Header.BorderSizePixel = 0; Header.ZIndex = 51; Header.Parent = MailPanel
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 14, 0, 0); TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "MAILBOX"; TitleLabel.TextColor3 = T.headerText; TitleLabel.TextScaled = true
	TitleLabel.Font = T.font; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.ZIndex = 52; TitleLabel.Parent = Header

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 28, 0, 28)
	CloseBtn.Position = UDim2.new(1, -36, 0.5, -14); CloseBtn.BackgroundColor3 = T.buttonRed
	CloseBtn.BorderSizePixel = 0; CloseBtn.Text = "X"; CloseBtn.TextColor3 = T.headerText
	CloseBtn.TextScaled = true; CloseBtn.Font = T.font; CloseBtn.ZIndex = 52; CloseBtn.Parent = Header
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

	local EmptyLabel = Instance.new("TextLabel")
	EmptyLabel.Size = UDim2.new(1, -20, 0, 40)
	EmptyLabel.Position = UDim2.new(0, 10, 0, HEADER_H + 20); EmptyLabel.BackgroundTransparency = 1
	EmptyLabel.Text = "No mail yet! Keep playing."; EmptyLabel.TextColor3 = T.subText
	EmptyLabel.TextScaled = true; EmptyLabel.Font = T.fontBody; EmptyLabel.ZIndex = 51
	EmptyLabel.Parent = MailPanel

	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Name = "ScrollContainer"
	ScrollFrame.Size = UDim2.new(1, 0, 1, -HEADER_H)
	ScrollFrame.Position = UDim2.new(0, 0, 0, HEADER_H)
	ScrollFrame.BackgroundTransparency = 1; ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 6; ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 255)
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollFrame.ZIndex = 51; ScrollFrame.Parent = MailPanel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, CARD_GAP)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = ScrollFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = ScrollFrame

	---------------------------------------------------------------
	-- BUILD CARDS
	---------------------------------------------------------------
	local function RebuildCards()
		for _, ref in pairs(cardRefs) do
			if ref.frame and ref.frame.Parent then ref.frame:Destroy() end
		end
		cardRefs = {}
		EmptyLabel.Visible = #availableMail == 0

		for _, mail in ipairs(availableMail) do
			local isClaimed = claimedIds[mail.id] == true
			local color = mail.color or T.accentGold
			local card = Instance.new("Frame"); card.Name = "Mail_" .. mail.id
			card.Size = UDim2.new(1, -20, 0, CARD_H)
			card.BackgroundColor3 = T.cardBG; card.BorderSizePixel = 0
			card.ZIndex = 52; card.Parent = ScrollFrame
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

			local cs = Instance.new("UIStroke"); cs.Color = isClaimed and T.buttonDisabled or color
			cs.Thickness = 1.5; cs.Parent = card

			local hasIcon = mail.icon and mail.icon ~= ""
			local textX = hasIcon and 52 or 10

			if hasIcon then
				local iconImg = Instance.new("ImageLabel")
				iconImg.Size = UDim2.new(0, 36, 0, 36); iconImg.Position = UDim2.new(0, 8, 0, 8)
				iconImg.BackgroundTransparency = 1; iconImg.Image = mail.icon
				iconImg.ScaleType = Enum.ScaleType.Fit; iconImg.ZIndex = 53; iconImg.Parent = card
			end

			local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(0.65, -textX, 0, 18)
			titleLbl.Position = UDim2.new(0, textX, 0, 6); titleLbl.BackgroundTransparency = 1
			titleLbl.Text = mail.title or ""; titleLbl.TextColor3 = isClaimed and T.subText or color
			titleLbl.TextScaled = true; titleLbl.Font = T.font
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 53; titleLbl.Parent = card

			local senderLbl = Instance.new("TextLabel"); senderLbl.Size = UDim2.new(0.65, -textX, 0, 14)
			senderLbl.Position = UDim2.new(0, textX, 0, 24); senderLbl.BackgroundTransparency = 1
			senderLbl.Text = "From: " .. (mail.sender or "Aura Inc")
			senderLbl.TextColor3 = T.subText; senderLbl.TextScaled = true; senderLbl.Font = T.fontBody
			senderLbl.TextXAlignment = Enum.TextXAlignment.Left; senderLbl.ZIndex = 53; senderLbl.Parent = card

			local bodyLbl = Instance.new("TextLabel"); bodyLbl.Size = UDim2.new(1, -(textX + 10), 0, 28)
			bodyLbl.Position = UDim2.new(0, textX, 0, 40); bodyLbl.BackgroundTransparency = 1
			bodyLbl.Text = mail.body or ""; bodyLbl.TextColor3 = T.bodyText
			bodyLbl.TextScaled = true; bodyLbl.Font = T.fontBody; bodyLbl.TextWrapped = true
			bodyLbl.TextXAlignment = Enum.TextXAlignment.Left; bodyLbl.ZIndex = 53; bodyLbl.Parent = card

			local rewardLbl = Instance.new("TextLabel"); rewardLbl.Size = UDim2.new(0.6, -textX, 0, 16)
			rewardLbl.Position = UDim2.new(0, textX, 0, 72); rewardLbl.BackgroundTransparency = 1
			rewardLbl.Text = FormatRewards(mail.rewards or {}); rewardLbl.TextColor3 = T.accentGold
			rewardLbl.TextScaled = true; rewardLbl.Font = T.fontBody
			rewardLbl.TextXAlignment = Enum.TextXAlignment.Left; rewardLbl.ZIndex = 53; rewardLbl.Parent = card

			local claimBtn = Instance.new("TextButton"); claimBtn.Size = UDim2.new(0, 80, 0, 32)
			claimBtn.Position = UDim2.new(1, -90, 0, 8); claimBtn.BorderSizePixel = 0
			claimBtn.TextScaled = true; claimBtn.Font = T.font; claimBtn.ZIndex = 53; claimBtn.Parent = card
			Instance.new("UICorner", claimBtn).CornerRadius = UDim.new(0, 6)

			if isClaimed then
				claimBtn.Text = "Claimed"; claimBtn.TextColor3 = T.subText
				claimBtn.BackgroundColor3 = T.buttonDisabled
			else
				claimBtn.Text = "Claim"; claimBtn.TextColor3 = T.bodyText
				claimBtn.BackgroundColor3 = T.buttonGreen
				claimBtn.MouseButton1Down:Connect(function()
					ClaimMail:FireServer(mail.id)
					PlayUI(SoundConfig.Purchase or "")
				end)
			end
			cardRefs[mail.id] = { frame = card }
		end
	end

	---------------------------------------------------------------
	-- OPEN / CLOSE
	---------------------------------------------------------------
	local function OpenMail()
		panelOpen = true
		MailPanel.Visible = true; MailPanel.Size = UDim2.new(0.85, 0, 0, 0)
		RebuildCards()
		TweenService:Create(MailPanel,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0.85, 0, 0.75, 0) }):Play()
		UITheme.SetMenuVisible(true)
		if shared.OnMailOpened then shared.OnMailOpened() end
	end

	local function CloseMail()
		panelOpen = false; PlayUI(SoundConfig.UIClose or "")
		TweenService:Create(MailPanel,
			TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Size = UDim2.new(0.85, 0, 0, 0) }):Play()
		UITheme.SetMenuVisible(false)
		task.delay(0.25, function() MailPanel.Visible = false end)
	end
	CloseBtn.MouseButton1Down:Connect(CloseMail)

	---------------------------------------------------------------
	-- MAIL STATE UPDATE (Updates Prompt Text)
	---------------------------------------------------------------
	local mailPrompt = nil

	MailUpdated.OnClientEvent:Connect(function(info)
		if info.available then availableMail = info.available end
		if info.claimed then
			claimedIds = {}
			for _, id in ipairs(info.claimed) do claimedIds[id] = true end
		end
		unreadCount = info.unreadCount or 0

		if mailPrompt then
			mailPrompt.ObjectText = unreadCount > 0 and ("Mailbox (" .. unreadCount .. ")") or "Mailbox"
		end
		if panelOpen then RebuildCards() end
	end)

	---------------------------------------------------------------
	-- SETUP MAILBOX PART & HOLOGRAM
	---------------------------------------------------------------
	task.spawn(function()
		local _menuGate = ReplicatedStorage:WaitForChild("MenuDismissed")
		if not _menuGate:GetAttribute("Fired") then _menuGate.Event:Wait() end

		local mailbox = workspace:WaitForChild("Mailbox", 30)
		if not mailbox then return end

		-- 1. Create the Prompt
		mailPrompt = Instance.new("ProximityPrompt")
		mailPrompt.Name = "MailPrompt"
		mailPrompt.ObjectText = "Mailbox"
		mailPrompt.ActionText = "Open Mail"
		mailPrompt.HoldDuration = 0.6 
		mailPrompt.MaxActivationDistance = 15

		-- 🛡️ CRITICAL: Stops the physical mailbox from blocking the click
		mailPrompt.RequiresLineOfSight = false 
		mailPrompt.Style = Enum.ProximityPromptStyle.Custom

		-- Attach directly to the Mailbox part!
		mailPrompt.Parent = mailbox

		-- 2. Initialize Hologram (Y-Offset set to 4.5 studs high, Beam is ON)
		local mailHolo = Hologram.New(mailPrompt, Vector3.new(0, 6, 0), false, true)

		-- 🛡️ 3. THE MAGIC FIX: Use the Module's built-in API functions!
		mailHolo:SetBillboardActive(true) -- Forces it to perfectly face the camera
		mailHolo:SetAlwaysOnTop(true)     -- Renders it over top of everything so it never vanishes

		-- 🎨 4. Change the Colors using the Module's API
		mailHolo:SetPrimaryColour(Color3.fromRGB(0, 200, 255)) -- The cool blue highlight
		mailHolo:SetTertiaryColour(Color3.fromRGB(255, 255, 255)) -- The white text

		mailPrompt.Triggered:Connect(function(p)
			if p == player then
				if panelOpen then CloseMail() else OpenMail() end
			end
		end)
	end)

-- MainMenuController
-- Location: StarterPlayer > StarterPlayerScripts > MainMenuController
--
-- Shows a title screen on join with the live game world as the background.
-- Camera locks to area-specific "MenuCamPos_N" Parts in Workspace.
-- Background is blurred using the existing UITheme MenuBlur system.
-- All sizes/positions driven by UIConfig.MainMenu, all colors from UITheme.
-- Player clicks PLAY → black fade transition → camera released → game begins.
--
-- GATE SYSTEM:
--   Creates a BindableEvent "MenuDismissed" in ReplicatedStorage.
--   Sets Attribute "Fired" = true and fires it after Play transition.
--   Other scripts check:
--     local _menuGate = ReplicatedStorage:WaitForChild("MenuDismissed")
--     if not _menuGate:GetAttribute("Fired") then _menuGate.Event:Wait() end
--
-- SETUP:
--   1. Place Parts in Workspace named "MenuCamPos_1", "MenuCamPos_2", etc.
--   2. Set each: Anchored=true, CanCollide=false, Transparency=1
--   3. Fly your Studio camera to the angle you want for that area
--   4. Run in Command Bar: workspace.MenuCamPos_1.CFrame = workspace.CurrentCamera.CFrame
--   5. Repeat for each area

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

local UITheme = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
local T = UITheme.Get("Custom")
local C = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIConfig"))
local M = C.MainMenu

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")
local camera    = workspace.CurrentCamera

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AreaUpdated  = RemoteEvents:WaitForChild("AreaUpdated")

---------------------------------------------------------------
-- GATE: Create the BindableEvent other scripts wait on
---------------------------------------------------------------
local MenuDismissed = Instance.new("BindableEvent")
MenuDismissed.Name = "MenuDismissed"
MenuDismissed.Parent = ReplicatedStorage

---------------------------------------------------------------
-- DEV TOGGLE: Set to false to skip the menu entirely
---------------------------------------------------------------
local MENU_ENABLED = true

if not MENU_ENABLED then
	MenuDismissed:SetAttribute("Fired", true)
	MenuDismissed:Fire()
	return
end

---------------------------------------------------------------
-- CONSTANTS (driven by UIConfig.MainMenu)
---------------------------------------------------------------
local FADE_IN_TIME   = M.FadeInTime
local FADE_HOLD_TIME = M.FadeHoldTime
local FADE_OUT_TIME  = M.FadeOutTime
local IDLE_SPEED     = M.IdleSpeed
local LEFT           = M.LeftMargin
local TITLE_FONT     = T.font or Enum.Font.FredokaOne
local BODY_FONT      = T.fontBody or Enum.Font.FredokaOne
local DEFAULT_AREA   = 1

---------------------------------------------------------------
-- STATE
---------------------------------------------------------------
local currentArea     = DEFAULT_AREA
local hasPlayed       = false
local idleConn        = nil
local areaConn        = nil

---------------------------------------------------------------
-- 1. HIDE THE GAME HUD IMMEDIATELY
---------------------------------------------------------------
mainHUD.Enabled = false

---------------------------------------------------------------
-- 2. LOCK CAMERA + BLUR
---------------------------------------------------------------
local savedCamType    = camera.CameraType
local savedCamSubject = camera.CameraSubject

camera.CameraType = Enum.CameraType.Scriptable

-- Enable the existing UITheme blur system
UITheme.SetMenuVisible(true)

---------------------------------------------------------------
-- CAMERA HELPERS
---------------------------------------------------------------
local function GetMenuAnchor(area)
	return workspace:FindFirstChild("MenuCamPos_" .. area)
		or workspace:FindFirstChild("MenuCamPos_1")
		or workspace:FindFirstChild("MenuCamPos")
		or workspace:WaitForChild("MenuCamPos", 5)
end

local function SnapCameraToArea(area)
	local anchor = GetMenuAnchor(area)
	if not anchor then
		warn("MainMenu: No MenuCamPos found for area " .. area)
		return
	end
	camera.CFrame = anchor.CFrame
end

local function StartIdleDrift(area)
	if idleConn then idleConn:Disconnect(); idleConn = nil end

	local anchor = GetMenuAnchor(area)
	if not anchor then return end

	local baseCF = anchor.CFrame
	local basePos = baseCF.Position
	local lookTarget = basePos + baseCF.LookVector * 50
	local angle = 0

	idleConn = RunService.RenderStepped:Connect(function(dt)
		angle += dt * IDLE_SPEED
		local offset = CFrame.Angles(0, math.rad(angle * 0.3), 0).LookVector * 0.5
		camera.CFrame = CFrame.lookAt(basePos + offset, lookTarget)
	end)
end

-- Set initial camera (defaults to area 1, updates when server sends real area)
SnapCameraToArea(DEFAULT_AREA)
StartIdleDrift(DEFAULT_AREA)

-- ✨ NEW: LIFT THE BLACKOUT CURTAIN ✨
-- The camera is now securely locked, so it is safe to reveal the screen!
local blackoutGui = playerGui:FindFirstChild("PreloadBlackout")
if blackoutGui then
	local blackoutFrame = blackoutGui:FindFirstChild("BlackoutFrame")
	if blackoutFrame then
		-- Smoothly fade from pitch black into your gorgeous blurred Main Menu
		TweenService:Create(blackoutFrame, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {
			BackgroundTransparency = 1
		}):Play()
	end
	-- Delete the GUI completely after it finishes fading
	task.delay(1.1, function() blackoutGui:Destroy() end)
end

-- Listen for the server to tell us the player's actual area
areaConn = AreaUpdated.OnClientEvent:Connect(function(info)
	if hasPlayed then return end
	local area = info.currentArea or DEFAULT_AREA
	if area ~= currentArea then
		currentArea = area
		SnapCameraToArea(area)
		StartIdleDrift(area)
	end
end)

---------------------------------------------------------------
-- 3. BUILD THE MENU UI (SCALING FIX)
---------------------------------------------------------------
local menuScreen = Instance.new("ScreenGui")
menuScreen.Name = "MainMenu"
menuScreen.DisplayOrder = 100
menuScreen.IgnoreGuiInset = true
menuScreen.ResetOnSpawn = false
menuScreen.Parent = playerGui

-- Vignette overlay
local vignette = Instance.new("Frame")
vignette.Name = "Vignette"
vignette.Size = UDim2.new(1, 0, 1, 0)
vignette.BackgroundColor3 = Color3.new(0, 0, 0)
vignette.BackgroundTransparency = M.VignetteDim or 0.5
vignette.BorderSizePixel = 0
vignette.ZIndex = 1
vignette.Parent = menuScreen

local vigGrad = Instance.new("UIGradient")
vigGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.4, 0.6),
	NumberSequenceKeypoint.new(1, 0),
})
vigGrad.Parent = vignette

-- NEW: Responsive Container bounded by a MaxSize constraint
local container = Instance.new("Frame")
container.Name = "MenuContainer"
container.Size = UDim2.new(0.9, 0, 0.6, 0) -- Uses 90% of screen width, 60% of height
container.Position = UDim2.new(0.05, 0, 0.2, 0) -- 5% from left, 20% down
container.BackgroundTransparency = 1
container.ZIndex = 2
container.Parent = menuScreen

-- Cap the maximum size so it looks great on massive PC screens too
local containerConstraint = Instance.new("UISizeConstraint")
containerConstraint.MaxSize = Vector2.new(600, 450)
containerConstraint.Parent = container

---------------------------------------------------------------
-- TITLE: "AURA INC" (Uses Scale instead of UIConfig Offsets)
---------------------------------------------------------------
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0.3, 0) -- 30% of the container height
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.AnchorPoint = Vector2.new(0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "AURA INC"
titleLabel.TextColor3 = T.headerText
titleLabel.TextScaled = true
titleLabel.Font = TITLE_FONT
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 10
titleLabel.Parent = container

local titleShadow = titleLabel:Clone()
titleShadow.Name = "TitleShadow"
titleShadow.TextColor3 = T.accentPurple
titleShadow.TextTransparency = 0.5
titleShadow.Position = UDim2.new(0, 0, 0, 4) -- Tiny offset for shadow
titleShadow.ZIndex = 9
titleShadow.Parent = container

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = T.accentPurple
titleStroke.Thickness = 2
titleStroke.Transparency = 0.3
titleStroke.Parent = titleLabel

---------------------------------------------------------------
-- SUBTITLE
---------------------------------------------------------------
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Name = "Subtitle"
subtitleLabel.Size = UDim2.new(0.8, 0, 0.15, 0) -- 15% of container height
subtitleLabel.Position = UDim2.new(0, 0, 0.3, 0) -- Just below title
subtitleLabel.AnchorPoint = Vector2.new(0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Idle Aura Factory"
subtitleLabel.TextColor3 = T.subText
subtitleLabel.TextScaled = true
subtitleLabel.Font = BODY_FONT
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 10
subtitleLabel.Parent = container

---------------------------------------------------------------
-- PLAY BUTTON (Scale size, constraint for aspect ratio)
---------------------------------------------------------------
local playBtn = Instance.new("TextButton")
playBtn.Name = "PlayButton"
playBtn.Size = UDim2.new(0.45, 0, 0.25, 0) -- 45% width of container, 25% height
playBtn.Position = UDim2.new(0, 0, 0.55, 0) -- Below subtitle
playBtn.AnchorPoint = Vector2.new(0, 0)
playBtn.BackgroundColor3 = T.buttonPrimary
playBtn.BorderSizePixel = 0
playBtn.Text = "PLAY"
playBtn.TextColor3 = T.headerText
playBtn.TextScaled = true
playBtn.Font = TITLE_FONT
playBtn.ZIndex = 10
playBtn.AutoButtonColor = false
playBtn.Parent = container

-- Keep the button looking like a rectangle, not a squished square
local btnConstraint = Instance.new("UIAspectRatioConstraint")
btnConstraint.AspectRatio = 2.5 
btnConstraint.Parent = playBtn

Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 12)

local playStroke = Instance.new("UIStroke")
playStroke.Color = T.accentPurple
playStroke.Thickness = T.StrokeThickness or 2
playStroke.Transparency = 0.2
playStroke.Parent = playBtn

local playGrad = Instance.new("UIGradient")
playGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 220)),
})
playGrad.Rotation = 90
playGrad.Parent = playBtn

---------------------------------------------------------------
-- UI JUICE: Floating Menu & Play Button Polish
---------------------------------------------------------------
-- 1. Make the entire menu container gently float up and down
TweenService:Create(container, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	Position = container.Position - UDim2.new(0, 0, 0, 12)
}):Play()

-- 2. The Play Button Interactive Juice
local btnScale = Instance.new("UIScale", playBtn)
local isHovering = false

-- Subtle idle pulse (only runs when you aren't hovering over it)
task.spawn(function()
	while playBtn and playBtn.Parent do
		if not isHovering then
			TweenService:Create(btnScale, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = 1.03}):Play()
		end
		task.wait(1)
		if not playBtn or not playBtn.Parent then break end

		if not isHovering then
			TweenService:Create(btnScale, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = 1.0}):Play()
		end
		task.wait(1)
	end
end)

-- Hover Effects (Grow and change color)
playBtn.MouseEnter:Connect(function()
	isHovering = true
	TweenService:Create(btnScale, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
	TweenService:Create(playBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.accentPurple}):Play() -- Gives it a nice glow!
end)

-- Leave Effects (Shrink back to normal)
playBtn.MouseLeave:Connect(function()
	isHovering = false
	TweenService:Create(btnScale, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Scale = 1.0}):Play()
	TweenService:Create(playBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.buttonPrimary}):Play()
end)

-- Click Down (Squish inwards)
playBtn.MouseButton1Down:Connect(function()
	TweenService:Create(btnScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.9}):Play()
	if shared.PlayUISound then shared.PlayUISound("6895079853") end -- Optional UI Click Sound
end)

-- Release Click (Bounce back out)
playBtn.MouseButton1Up:Connect(function()
	TweenService:Create(btnScale, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {Scale = 1.1}):Play()
end)

-- 3. Apply your UITheme Glass-ify features!
task.spawn(function()
	task.wait(0.5) -- Wait for UI to load
	if UITheme and UITheme.ApplyShine then
		UITheme.ApplyShine(playBtn)
	end
	if UITheme and UITheme.ApplyFlair then
		UITheme.ApplyFlair(titleLabel, "Ghost")
	end
end)

---------------------------------------------------------------
-- CREDITS LINE
---------------------------------------------------------------
local creditLabel = Instance.new("TextLabel")
creditLabel.Name = "Credits"
creditLabel.Size = UDim2.new(0.6, 0, 0.1, 0) -- 10% of container height
creditLabel.Position = UDim2.new(0, 0, 0.9, 0) -- Bottom of container
creditLabel.AnchorPoint = Vector2.new(0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "Made by MoldySugar2205"
creditLabel.TextColor3 = T.subText
creditLabel.TextTransparency = 0.3
creditLabel.TextScaled = true
creditLabel.Font = BODY_FONT
creditLabel.TextXAlignment = Enum.TextXAlignment.Left
creditLabel.ZIndex = 10
creditLabel.Parent = container

---------------------------------------------------------------
-- LOADING SCREEN OVERLAY (Starts invisible)
---------------------------------------------------------------
local blackFade = Instance.new("Frame")
blackFade.Name = "BlackFade"
blackFade.Size = UDim2.new(1, 0, 1, 0)
blackFade.BackgroundColor3 = Color3.new(0, 0, 0)
blackFade.BackgroundTransparency = 1
blackFade.BorderSizePixel = 0
blackFade.ZIndex = 50
blackFade.Parent = menuScreen

local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(1, 0, 0, 50)
loadingText.Position = UDim2.new(0, 0, 0.5, -25)
loadingText.BackgroundTransparency = 1
loadingText.Text = "INITIALIZING SYSTEMS..."
loadingText.TextColor3 = T.accentBlue or Color3.fromRGB(100, 200, 255)
loadingText.TextScaled = true
loadingText.Font = TITLE_FONT
loadingText.TextTransparency = 1 -- Hidden initially
loadingText.ZIndex = 51
loadingText.Parent = blackFade

playBtn.MouseButton1Down:Connect(function()
	if hasPlayed then return end
	hasPlayed = true

	-- Disable button
	playBtn.Active = false
	playBtn.Text = ""

	-- Stop listening for area changes
	if areaConn then areaConn:Disconnect(); areaConn = nil end

	-- PHASE 1: Fade to black and show LOADING text
	TweenService:Create(blackFade, TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(loadingText, TweenInfo.new(FADE_IN_TIME), {
		TextTransparency = 0
	}):Play()
	task.wait(FADE_IN_TIME)

	-- PHASE 2: While black — release camera, disable blur, show HUD
	if idleConn then idleConn:Disconnect(); idleConn = nil end

	-- Release camera
	camera.CameraType = savedCamType
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		camera.CameraSubject = humanoid
	end

	-- Disable blur and show HUD *behind* the black screen
	UITheme.SetMenuVisible(false)
	mainHUD.Enabled = true

	-- Destroy menu visuals behind the black
	vignette:Destroy()
	container:Destroy()

	-- THE LOADING BUFFER: Wait for Roblox to load, then give scripts 2 seconds to safely sync
	if not game:IsLoaded() then game.Loaded:Wait() end
	loadingText.Text = "LOADING AURAS..."
	task.wait(2) 

	-- PHASE 3: Fade out from black to reveal gameplay
	TweenService:Create(blackFade, TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(loadingText, TweenInfo.new(FADE_OUT_TIME), {
		TextTransparency = 1
	}):Play()
	task.wait(FADE_OUT_TIME)

	-- FIRE THE GATE — all waiting scripts now resume
	MenuDismissed:SetAttribute("Fired", true)
	MenuDismissed:Fire()

	-- Full cleanup
	menuScreen:Destroy()
end)

local function RefreshLook()
	UITheme.ApplyFlair(titleLabel, "Shine")	
	UITheme.ApplyFlair(subtitleLabel, "Shine")
	UITheme.ApplyFlair(creditLabel, "Shine")
	UITheme.ApplyFlair(playBtn, "Shine")
end

RefreshLook()

-- PlatformController
-- Location: StarterPlayer > StarterPlayerScripts > PlatformController

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local AdminConfig = require(ReplicatedStorage.Modules.AdminConfig)
local Formatter = require(ReplicatedStorage.Modules.NumberFormatter) 

local ShipAuras       = ReplicatedStorage.RemoteEvents:WaitForChild("ShipAuras")
local UpdateMultiplier = ReplicatedStorage:WaitForChild("UpdateMultiplier")
local HabitatFullEvent = ReplicatedStorage:WaitForChild("HabitatFullEvent")

local TRUCK_SPAWN = workspace:WaitForChild("TruckSpawn")
local TRUCK_DEST  = workspace:WaitForChild("TruckDestination")
local HabitatHolder = workspace:WaitForChild("HabitatHolder") 

local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD = playerGui:WaitForChild("MainHUD")
local currLabel = mainHUD:WaitForChild("CurrencyLabel")
local gaurasLabel = mainHUD:WaitForChild("GoldenAurasLabel")

local function GetHabitatPos()
	return HabitatHolder:WaitForChild("Position").Position
end

local currentMultiplier = 1.0
local platformQueue = {}
local processingPlatform = false

local MultiplierColors = {
	[1.0] = Color3.fromRGB(255, 255, 255),
	[1.5] = Color3.fromRGB(100, 200, 255),
	[2.0] = Color3.fromRGB(80, 255, 120),
	[3.0] = Color3.fromRGB(180, 60, 255),
	[5.0] = Color3.fromRGB(255, 200, 0),
}

local MultiplierNames = {
	[1.0] = "No Bonus",
	[1.5] = "1.5x Bonus",
	[2.0] = "2x Bonus",
	[3.0] = "3x Bonus",
	[5.0] = "5x Bonus",
}

UpdateMultiplier.Event:Connect(function(mult)
	currentMultiplier = mult
end)

local function FormatNumber(n)
	return Formatter.Format(math.floor(tonumber(n) or 0))
end

---------------------------------------------------------------
-- ✨ UNIVERSAL JUICY VISUALS (CASH & AURAS) ✨
---------------------------------------------------------------
local function PlayJuiceEffect(exactAmount, currencyType)
	local isAura = (currencyType == "Auras")
	local targetLabel = isAura and gaurasLabel or currLabel

	local pendingKey = isAura and "LocalPendingAuras" or "LocalPendingPayout"
	local addKey = isAura and "VisualAurasToAdd" or "VisualCashToAdd"

	local currentPending = player:GetAttribute(pendingKey) or 0
	player:SetAttribute(pendingKey, currentPending + exactAmount)

	local targetPos = targetLabel.AbsolutePosition
	local targetSize = targetLabel.AbsoluteSize

	local popupWidth = 250
	local popupHeight = 70
	local startX = targetPos.X - popupWidth - 40 
	local startY = targetPos.Y + (targetSize.Y / 2) - (popupHeight / 2) 

	local endPos2D = targetPos + (targetSize / 2)

	local effectGui = Instance.new("ScreenGui")
	effectGui.Name = "JuiceGui_" .. currencyType
	effectGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	effectGui.Parent = playerGui

	local popupText = Instance.new("TextLabel")
	popupText.Text = (isAura and "+" or "+$") .. FormatNumber(exactAmount)
	popupText.Font = Enum.Font.FredokaOne
	popupText.TextScaled = true
	popupText.TextColor3 = isAura and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(85, 255, 127)
	popupText.BackgroundTransparency = 1
	popupText.TextXAlignment = Enum.TextXAlignment.Right 
	popupText.Size = UDim2.new(0, popupWidth, 0, popupHeight)
	popupText.Position = UDim2.new(0, startX, 0, startY)
	popupText.ZIndex = 100
	popupText.Parent = effectGui

	local textStroke = Instance.new("UIStroke", popupText)
	textStroke.Color = isAura and Color3.fromRGB(80, 50, 0) or Color3.fromRGB(0, 50, 0)
	textStroke.Thickness = 3

	local textScale = Instance.new("UIScale", popupText)
	textScale.Scale = 0

	TweenService:Create(textScale, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1.2}):Play()

	task.delay(0.6, function()
		TweenService:Create(popupText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, startX - 120, 0, startY),
			TextTransparency = 1
		}):Play()
		TweenService:Create(textStroke, TweenInfo.new(0.8), {Transparency = 1}):Play()
	end)

	local sfxFolder = ReplicatedStorage:FindFirstChild("SFX") or ReplicatedStorage:FindFirstChild("Sounds")
	if sfxFolder and sfxFolder:FindFirstChild("CashRegister") then
		local sfx = sfxFolder.CashRegister:Clone()
		if isAura then sfx.Pitch = 1.3 end 
		sfx.Parent = game:GetService("SoundService")
		sfx:Play()
		Debris:AddItem(sfx, 2)
	end

	local iconCount = 10
	local iconSize = 40
	local iconId = "rbxassetid://14916846070" 

	if isAura then
		iconId = "rbxassetid://4483362458" 
		if exactAmount < 100 then
			iconCount = math.min(exactAmount, 30)
			iconSize = 35 
		elseif exactAmount < 1000 then
			iconCount = math.min(math.ceil(exactAmount / 10), 30)
			iconSize = 55 
		else
			iconCount = math.min(math.ceil(exactAmount / 100), 30)
			iconSize = 80 
		end
	end

	local chunkAmount = exactAmount / iconCount
	local coinsHit = 0

	for i = 1, iconCount do
		local coin = Instance.new("ImageLabel")
		coin.Image = iconId
		if isAura then coin.ImageColor3 = Color3.fromRGB(255, 215, 0) end 
		coin.BackgroundTransparency = 1
		coin.Size = UDim2.new(0, iconSize, 0, iconSize)

		local coinStartX = startX + popupWidth - (iconSize * 1.5)
		local coinStartY = startY + (popupHeight / 2) - (iconSize / 2)

		coin.Position = UDim2.new(0, coinStartX, 0, coinStartY)
		coin.ZIndex = 90
		coin.Parent = effectGui

		local randomOffsetX = math.random(-80, 80)
		local randomOffsetY = math.random(-80, 80)
		local burstPos = UDim2.new(0, coinStartX + randomOffsetX, 0, coinStartY + randomOffsetY)

		local burstTween = TweenService:Create(coin, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Position = burstPos,
			Rotation = math.random(-180, 180)
		})
		burstTween:Play()

		burstTween.Completed:Connect(function()
			local flyTween = TweenService:Create(coin, TweenInfo.new(0.4 + (i * 0.02), Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = UDim2.new(0, endPos2D.X - (iconSize/2), 0, endPos2D.Y - (iconSize/2)),
				Size = UDim2.new(0, iconSize/2, 0, iconSize/2),
				ImageTransparency = 0.3
			})
			flyTween:Play()

			flyTween.Completed:Connect(function()
				if coin.Parent then coin:Destroy() end
				coinsHit += 1

				player:SetAttribute(addKey, chunkAmount)

				local pending = player:GetAttribute(pendingKey) or 0
				player:SetAttribute(pendingKey, math.max(0, pending - chunkAmount))

				if sfxFolder and sfxFolder:FindFirstChild("CoinTick") then
					local sfx = sfxFolder.CoinTick:Clone()
					sfx.Pitch = (isAura and 1.8 or 1.5) + (math.random()*0.2)
					sfx.Parent = game:GetService("SoundService")
					sfx:Play()
					Debris:AddItem(sfx, 1)
				end

				local ts = targetLabel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", targetLabel)
				ts.Scale = 1.1
				TweenService:Create(ts, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 1}):Play()
			end)
		end)
	end

	task.delay(3, function()
		if effectGui.Parent then effectGui:Destroy() end
		if coinsHit < iconCount then
			local remaining = (iconCount - coinsHit) * chunkAmount
			player:SetAttribute(addKey, remaining)
			player:SetAttribute(pendingKey, 0)
		end
	end)
end

local function CreatePlatform()
	local platform = Instance.new("Part")
	platform.Name = "HoverPlatform"
	platform.Size = Vector3.new(8, 0.5, 8)
	platform.Anchored = true
	platform.CastShadow = false
	platform.Material = Enum.Material.Neon
	platform.Color = MultiplierColors[currentMultiplier] or Color3.fromRGB(255, 255, 255)
	platform.Position = TRUCK_SPAWN.Position + Vector3.new(0, AdminConfig.PlatformHoverHeight, 0)
	platform.Parent = workspace

	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Range = 12
	light.Color = platform.Color
	light.Parent = platform

	return platform
end

local function AttachLabels(platform, payout, multiplier)
	local payoutBB = Instance.new("BillboardGui")
	payoutBB.Size = UDim2.new(8, 0, 2.5, 0) 
	payoutBB.StudsOffset = Vector3.new(0, 5, 0)
	payoutBB.AlwaysOnTop = false
	payoutBB.Adornee = platform
	payoutBB.Parent = platform

	local payoutLabel = Instance.new("TextLabel")
	payoutLabel.Size = UDim2.new(1, 0, 1, 0)
	payoutLabel.BackgroundTransparency = 1
	payoutLabel.Text = "$" .. FormatNumber(payout)
	payoutLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	payoutLabel.TextScaled = true
	payoutLabel.Font = Enum.Font.GothamBold
	payoutLabel.TextStrokeTransparency = 1
	payoutLabel.TextTransparency = 1
	payoutLabel.Parent = payoutBB

	local payoutStroke = Instance.new("UIStroke", payoutLabel)
	payoutStroke.Thickness = 3
	payoutStroke.Color = Color3.fromRGB(0, 40, 0)

	local multBB = Instance.new("BillboardGui")
	multBB.Size = UDim2.new(6, 0, 1.5, 0) 
	multBB.StudsOffset = Vector3.new(0, 2.5, 0)
	multBB.AlwaysOnTop = false
	multBB.Adornee = platform
	multBB.Parent = platform

	local multLabel = Instance.new("TextLabel")
	multLabel.Size = UDim2.new(1, 0, 1, 0)
	multLabel.BackgroundTransparency = 1
	multLabel.Text = MultiplierNames[multiplier] or "No Bonus"
	multLabel.TextColor3 = MultiplierColors[multiplier] or Color3.fromRGB(255, 255, 255)
	multLabel.TextScaled = true
	multLabel.Font = Enum.Font.Gotham
	multLabel.TextStrokeTransparency = 1
	multLabel.TextTransparency = 1
	multLabel.Parent = multBB

	local multStroke = Instance.new("UIStroke", multLabel)
	multStroke.Thickness = 2.5
	multStroke.Color = Color3.fromRGB(0, 0, 0)

	TweenService:Create(payoutLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	TweenService:Create(multLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
end

local function PayoutPopup(position, payout, multiplier)
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(0.1, 0.1, 0.1)
	anchor.Anchored = true
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.Position = position
	anchor.Parent = workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(10, 0, 2.5, 0) 
	bb.StudsOffset = Vector3.new(0, 7, 0)
	bb.AlwaysOnTop = false
	bb.Adornee = anchor
	bb.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "+ $" .. FormatNumber(payout)
	label.TextColor3 = MultiplierColors[multiplier] or Color3.fromRGB(100, 255, 100)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 1
	label.TextTransparency = 0
	label.Parent = bb

	local lStroke = Instance.new("UIStroke", label)
	lStroke.Thickness = 3
	lStroke.Color = Color3.fromRGB(0, 0, 0)

	TweenService:Create(bb, TweenInfo.new(1.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { StudsOffset = Vector3.new(0, 18, 0) }):Play()
	task.delay(0.6, function()
		TweenService:Create(label, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
		TweenService:Create(lStroke, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
	end)
	Debris:AddItem(anchor, 2.5)
end

local function GetAuraBlocksNearHabitat()
	local blocks = {}
	local habitatPos = GetHabitatPos()  

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == "HoverPlatform" or obj == HabitatHolder
			or obj == TRUCK_SPAWN or obj == TRUCK_DEST then
			continue
		end

		local rootPart = nil
		local isCube = false

		if obj:GetAttribute("AuraCube") then
			isCube = true
			if obj:IsA("Model") then
				rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
			elseif obj:IsA("BasePart") then
				rootPart = obj
			end
		elseif obj:IsA("Part") and obj.Material == Enum.Material.Neon then
			isCube = true
			rootPart = obj
		end

		if isCube and rootPart then
			local dist = (rootPart.Position - habitatPos).Magnitude  
			if dist < 20 then
				table.insert(blocks, { instance = obj, rootPart = rootPart })
			end
		end
	end
	return blocks
end

local function MagnetBlocks(platform, blocks, count)
	local collected = math.min(#blocks, count)
	if collected == 0 then return end

	local tweensDone = 0
	local tweensStarted = 0

	for i = 1, collected do
		local block = blocks[i]
		if not block or not block.rootPart or not block.rootPart.Parent then continue end

		local rootPart = block.rootPart
		local instance = block.instance

		rootPart.Anchored = true

		local tweenProps = { Position = platform.Position }
		if instance:IsA("BasePart") then
			tweenProps.Size = Vector3.new(0.1, 0.1, 0.1)
		end

		local tween = TweenService:Create(rootPart,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			tweenProps
		)

		tweensStarted += 1
		tween.Completed:Connect(function()
			instance:Destroy()
			tweensDone += 1
		end)
		tween:Play()
		task.wait(0.05)
	end

	local timeout = tick() + 3
	while tweensDone < tweensStarted and tick() < timeout do
		task.wait(0.05)
	end
end

local function ProcessPlatform(info)
	if info.collected == 0 then return end

	local myPayout     = info.payout
	local myMultiplier = currentMultiplier
	local myDispatchId = info.dispatchId
	local platform     = CreatePlatform()

	local habitatPos = GetHabitatPos()

	local distIn = (TRUCK_SPAWN.Position - habitatPos).Magnitude
	local tweenIn = TweenService:Create(platform,
		TweenInfo.new(distIn / AdminConfig.PlatformSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = habitatPos + Vector3.new(0, AdminConfig.PlatformHoverHeight, 0) }
	)
	tweenIn:Play()
	tweenIn.Completed:Wait()

	AttachLabels(platform, myPayout, myMultiplier)
	PayoutPopup(platform.Position, myPayout, myMultiplier)

	local blocks = GetAuraBlocksNearHabitat()
	MagnetBlocks(platform, blocks, info.collected)

	task.wait(0.5)

	HabitatFullEvent:Fire(false)

	local distOut = (habitatPos - TRUCK_DEST.Position).Magnitude
	local tweenOut = TweenService:Create(platform,
		TweenInfo.new(distOut / AdminConfig.PlatformSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = TRUCK_DEST.Position + Vector3.new(0, AdminConfig.PlatformHoverHeight, 0) }
	)
	tweenOut:Play()
	tweenOut.Completed:Wait()

	platform:Destroy()
	ShipAuras:FireServer("payout", myDispatchId)
end

local function ProcessQueue()
	if processingPlatform then return end
	processingPlatform = true

	while #platformQueue > 0 do
		local nextInfo = table.remove(platformQueue, 1)
		ProcessPlatform(nextInfo)
	end

	processingPlatform = false
end

ShipAuras.OnClientEvent:Connect(function(info)
	if info.action == "payoutConfirmed" then
		PlayJuiceEffect(info.amount, "Currency")
	elseif info.action == "playJuice" then
		PlayJuiceEffect(info.amount, info.currencyType)
	else
		table.insert(platformQueue, info)
		task.spawn(ProcessQueue)
	end
end)

local LocalJuiceEvent = ReplicatedStorage:FindFirstChild("LocalJuiceEvent")
if not LocalJuiceEvent then
	LocalJuiceEvent = Instance.new("BindableEvent")
	LocalJuiceEvent.Name = "LocalJuiceEvent"
	LocalJuiceEvent.Parent = ReplicatedStorage
end
LocalJuiceEvent.Event:Connect(function(exactAmount, currencyType)
	PlayJuiceEffect(exactAmount, currencyType)
end)


-- PortalController
-- Location: StarterPlayer > StarterPlayerScripts > PortalController

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")

local AreaRegistry = require(ReplicatedStorage.Modules.AreaRegistry)
local SoundConfig  = require(ReplicatedStorage.Modules.SoundConfig)
local C            = require(ReplicatedStorage.Modules.UIConfig)
local Formatter    = require(ReplicatedStorage.Modules.NumberFormatter) 
local UITheme      = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
local T            = UITheme.Get("Custom")

local AreaUpdated      = ReplicatedStorage.RemoteEvents:WaitForChild("AreaUpdated")
local AreaUnlocked     = ReplicatedStorage.RemoteEvents:WaitForChild("AreaUnlocked")
local EnterPortal      = ReplicatedStorage.RemoteEvents:WaitForChild("EnterPortal")
local TravelToArea     = ReplicatedStorage.RemoteEvents:WaitForChild("TravelToArea")
local AreaChanged      = ReplicatedStorage.RemoteEvents:WaitForChild("AreaChanged")
local PrestigeComplete = ReplicatedStorage.RemoteEvents:WaitForChild("PrestigeComplete")
local UpdateHUD        = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local PositionPart = workspace:WaitForChild("AuraHolder"):WaitForChild("Position")

local promptAdded   = false
local currentArea   = 1
local portalReady   = false
local panelOpen     = false
local browseIndex   = 1
local liveFarmEval  = 0
local unlockedAreas = { 1 }
local MAX_AREA      = AreaRegistry.GetMaxArea()

local PW = C.Panels.AreaTravelW
local PH = C.Panels.AreaTravelH
local PR = C.Panels.CornerRadius
local BW = C.Banners.AreaBannerW
local BY = C.Banners.AreaBannerY
local BR = C.Banners.CornerRadius

local function PlayUI(id)
	if shared.PlayUISound then shared.PlayUISound(id) end
end

local function IsUnlocked(idx)
	for _, v in ipairs(unlockedAreas) do if v == idx then return true end end
	return false
end

local AreaAssets = ReplicatedStorage:WaitForChild("AreaAssets")

-- ✨ FLIPBOOK ANIMATION SYSTEM
local flipbookConnection = nil
local currentFlipbook = nil
local flipbookFrame = 1
local flipbookTime = 0

local function StopFlipbook()
	if flipbookConnection then
		flipbookConnection:Disconnect()
		flipbookConnection = nil
	end
	currentFlipbook = nil
end

local function StartFlipbook(areaIdx, AreaIcon)
	StopFlipbook()

	local flipbookData = AreaRegistry.GetFlipbook(areaIdx)
	if not flipbookData then return end

	currentFlipbook = flipbookData
	flipbookFrame = 1
	flipbookTime = 0

	if not AreaIcon then return end

	AreaIcon.Image = flipbookData.image
	AreaIcon.ImageRectSize = Vector2.new(flipbookData.frameW, flipbookData.frameH)
	AreaIcon.ImageRectOffset = Vector2.new(0, 0)

	flipbookConnection = RunService.RenderStepped:Connect(function(dt)
		flipbookTime += dt
		local frameTime = 1 / flipbookData.fps

		if flipbookTime >= frameTime then
			flipbookTime = flipbookTime % frameTime
			flipbookFrame = flipbookFrame + 1

			if flipbookFrame > flipbookData.frames then
				flipbookFrame = 1
			end

			local col = (flipbookFrame - 1) % flipbookData.columns
			local row = math.floor((flipbookFrame - 1) / flipbookData.columns)
			local offsetX = col * flipbookData.frameW
			local offsetY = row * flipbookData.frameH

			AreaIcon.ImageRectOffset = Vector2.new(offsetX, offsetY)
		end
	end)
end

-- UI Setup (StatsPanel)
local StatsPanel = Instance.new("Frame")
StatsPanel.Name="StatsPanel"; StatsPanel.Size = UDim2.new(0.88, 0, 0.82, 0)
StatsPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
StatsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
StatsPanel.BackgroundColor3=T.panelBG; StatsPanel.BorderSizePixel=0
StatsPanel.Visible=false; StatsPanel.ZIndex=30; StatsPanel.ClipsDescendants=true
StatsPanel.Parent=mainHUD
Instance.new("UICorner",StatsPanel).CornerRadius=UDim.new(0,PR)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(PW, PH) 
sizeConstraint.Parent = StatsPanel

local panelStroke=Instance.new("UIStroke"); panelStroke.Color=T.panelStroke; panelStroke.Thickness=2; panelStroke.Parent=StatsPanel

local HeaderBar=Instance.new("Frame"); HeaderBar.Size=UDim2.new(1,0,0,46); HeaderBar.BackgroundColor3=T.headerBG
HeaderBar.BorderSizePixel=0; HeaderBar.ZIndex=31; HeaderBar.Parent=StatsPanel
Instance.new("UICorner",HeaderBar).CornerRadius=UDim.new(0,PR)
local HeaderLabel=Instance.new("TextLabel"); HeaderLabel.Size=UDim2.new(1,-50,1,0); HeaderLabel.Position=UDim2.new(0,16,0,0)
HeaderLabel.BackgroundTransparency=1; HeaderLabel.Text="AREA TRAVEL"; HeaderLabel.TextColor3=T.headerText
HeaderLabel.TextScaled=true; HeaderLabel.Font=T.font; HeaderLabel.TextXAlignment=Enum.TextXAlignment.Left
HeaderLabel.ZIndex=32; HeaderLabel.Parent=HeaderBar
local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,32,0,32); CloseBtn.Position=UDim2.new(1,-40,0.5,-16)
CloseBtn.BackgroundColor3=T.buttonRed; CloseBtn.BorderSizePixel=0; CloseBtn.Text="X"; CloseBtn.TextColor3=T.bodyText
CloseBtn.TextScaled=true; CloseBtn.Font=T.font; CloseBtn.ZIndex=33; CloseBtn.Parent=HeaderBar
CloseBtn:SetAttribute("TutorialTarget", "PortalCloseBtn")
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,6)

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, 0, 1, -46) 
ScrollContainer.Position = UDim2.new(0, 0, 0, 46) 
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y 
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.Parent = StatsPanel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10) 
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
listLayout.Parent = ScrollContainer

local topPadding = Instance.new("UIPadding")
topPadding.PaddingTop = UDim.new(0, 10)
topPadding.PaddingBottom = UDim.new(0, 10)
topPadding.Parent = ScrollContainer

local GoalSection=Instance.new("Frame"); GoalSection.Size=UDim2.new(1,-24,0,90)
GoalSection.BackgroundColor3=T.cardBG; GoalSection.BorderSizePixel=0; GoalSection.ZIndex=31; GoalSection.Parent=ScrollContainer
Instance.new("UICorner",GoalSection).CornerRadius=UDim.new(0,8)
local FarmEvalTitle=Instance.new("TextLabel"); FarmEvalTitle.Size=UDim2.new(1,-12,0,16); FarmEvalTitle.Position=UDim2.new(0,12,0,6)
FarmEvalTitle.BackgroundTransparency=1; FarmEvalTitle.Text="FARM EVALUATION"; FarmEvalTitle.TextColor3=T.subText
FarmEvalTitle.TextScaled=true; FarmEvalTitle.Font=T.font; FarmEvalTitle.TextXAlignment=Enum.TextXAlignment.Left
FarmEvalTitle.ZIndex=32; FarmEvalTitle.Parent=GoalSection
local FarmEvalNumber=Instance.new("TextLabel"); FarmEvalNumber.Name="FarmEvalNumber"
FarmEvalNumber.Size=UDim2.new(1,-12,0,28); FarmEvalNumber.Position=UDim2.new(0,12,0,22)
FarmEvalNumber.BackgroundTransparency=1; FarmEvalNumber.Text="$0"; FarmEvalNumber.TextColor3=T.accentGreen
FarmEvalNumber.TextScaled=true; FarmEvalNumber.Font=T.font; FarmEvalNumber.TextXAlignment=Enum.TextXAlignment.Left
FarmEvalNumber.ZIndex=32; FarmEvalNumber.Parent=GoalSection
local ProgressBG=Instance.new("Frame"); ProgressBG.Size=UDim2.new(1,-24,0,8); ProgressBG.Position=UDim2.new(0,12,0,54)
ProgressBG.BackgroundColor3=Color3.fromRGB(40,50,70); ProgressBG.BorderSizePixel=0; ProgressBG.ZIndex=32; ProgressBG.Parent=GoalSection
Instance.new("UICorner",ProgressBG).CornerRadius=UDim.new(0,4)
local ProgressFill=Instance.new("Frame"); ProgressFill.Name="ProgressFill"; ProgressFill.Size=UDim2.new(0,0,1,0)
ProgressFill.BackgroundColor3=T.accentGreen; ProgressFill.BorderSizePixel=0; ProgressFill.ZIndex=33; ProgressFill.Parent=ProgressBG
Instance.new("UICorner",ProgressFill).CornerRadius=UDim.new(0,4)
local ProgressLabel=Instance.new("TextLabel"); ProgressLabel.Name="ProgressLabel"
ProgressLabel.Size=UDim2.new(1,-12,0,14); ProgressLabel.Position=UDim2.new(0,12,0,66)
ProgressLabel.BackgroundTransparency=1; ProgressLabel.Text=""; ProgressLabel.TextColor3=T.subText
ProgressLabel.TextScaled=true; ProgressLabel.Font=T.fontBody; ProgressLabel.TextXAlignment=Enum.TextXAlignment.Left
ProgressLabel.ZIndex=32; ProgressLabel.Parent=GoalSection

local AreaBrowser=Instance.new("Frame"); AreaBrowser.Size=UDim2.new(1,-24,0,260)
AreaBrowser.BackgroundColor3=T.cardBG; AreaBrowser.BorderSizePixel=0; AreaBrowser.ZIndex=31; AreaBrowser.Parent=ScrollContainer
Instance.new("UICorner",AreaBrowser).CornerRadius=UDim.new(0,8)
local BrowseAreaName=Instance.new("TextLabel"); BrowseAreaName.Size=UDim2.new(0.6, 0, 0, 24)
BrowseAreaName.AnchorPoint=Vector2.new(0.5, 0)
BrowseAreaName.Position=UDim2.new(0.5, 0, 0, 8)
BrowseAreaName.BackgroundTransparency=1; BrowseAreaName.Text="Starter Area"; BrowseAreaName.TextColor3=T.accentBlue
BrowseAreaName.TextScaled=true; BrowseAreaName.Font=T.font; BrowseAreaName.TextXAlignment=Enum.TextXAlignment.Center
BrowseAreaName.ZIndex=32; BrowseAreaName.Parent=AreaBrowser
local AreaIndexLabel=Instance.new("TextLabel"); AreaIndexLabel.Size=UDim2.new(0,60,0,20); AreaIndexLabel.Position=UDim2.new(1,-66,0,10)
AreaIndexLabel.BackgroundTransparency=1; AreaIndexLabel.Text="1/5"; AreaIndexLabel.TextColor3=T.subText
AreaIndexLabel.TextScaled=true; AreaIndexLabel.Font=T.fontBody; AreaIndexLabel.TextXAlignment=Enum.TextXAlignment.Right
AreaIndexLabel.ZIndex=32; AreaIndexLabel.Parent=AreaBrowser
local BrowseAreaMult=Instance.new("TextLabel"); BrowseAreaMult.Size=UDim2.new(1,-20,0,18); BrowseAreaMult.Position=UDim2.new(0,10,0,34)
BrowseAreaMult.BackgroundTransparency=1; BrowseAreaMult.Text="Cube Value: 1.0x base"; BrowseAreaMult.TextColor3=T.accentGold
BrowseAreaMult.TextScaled=true; BrowseAreaMult.Font=T.fontBody; BrowseAreaMult.TextXAlignment=Enum.TextXAlignment.Center
BrowseAreaMult.ZIndex=32; BrowseAreaMult.Parent=AreaBrowser
local LeftArrow=Instance.new("TextButton"); LeftArrow.Size=UDim2.new(0,36,0,36); LeftArrow.Position=UDim2.new(0,8,0,62)
LeftArrow.BackgroundColor3=T.headerBG; LeftArrow.BorderSizePixel=0; LeftArrow.Text="<"; LeftArrow.TextColor3=T.bodyText
LeftArrow.TextScaled=true; LeftArrow.Font=T.font; LeftArrow.ZIndex=33; LeftArrow.Parent=AreaBrowser
Instance.new("UICorner",LeftArrow).CornerRadius=UDim.new(0,18)
local RightArrow=Instance.new("TextButton"); RightArrow.Size=UDim2.new(0,36,0,36); RightArrow.Position=UDim2.new(1,-44,0,62)
RightArrow.BackgroundColor3=T.headerBG; RightArrow.BorderSizePixel=0; RightArrow.Text=">"; RightArrow.TextColor3=T.bodyText
RightArrow.TextScaled=true; RightArrow.Font=T.font; RightArrow.ZIndex=33; RightArrow.Parent=AreaBrowser
RightArrow:SetAttribute("TutorialTarget", "ArrowBtn")
Instance.new("UICorner",RightArrow).CornerRadius=UDim.new(0,18)
local AreaIcon = Instance.new("ImageLabel")
AreaIcon.Name = "AreaIcon" 
AreaIcon.AnchorPoint = Vector2.new(0.5, 0)
AreaIcon.Size = UDim2.new(0, 110, 0, 110)
AreaIcon.Position = UDim2.new(0.5, 0, 0, 54)
AreaIcon.BackgroundTransparency = 1
AreaIcon.BorderSizePixel = 0
AreaIcon.ZIndex = 33
AreaIcon.Image = "" 
AreaIcon.Parent = AreaBrowser
local BrowseStatus=Instance.new("TextLabel"); BrowseStatus.Size=UDim2.new(1,-24,0,20); BrowseStatus.Position=UDim2.new(0,12,0,172)
BrowseStatus.BackgroundTransparency=1; BrowseStatus.Text="CURRENT AREA"; BrowseStatus.TextColor3=T.subText
BrowseStatus.TextScaled=true; BrowseStatus.Font=T.font; BrowseStatus.TextXAlignment=Enum.TextXAlignment.Center
BrowseStatus.ZIndex=32; BrowseStatus.Parent=AreaBrowser
local BrowseProgress=Instance.new("TextLabel"); BrowseProgress.Size=UDim2.new(1,-24,0,28); BrowseProgress.Position=UDim2.new(0,12,0,194)
BrowseProgress.BackgroundTransparency=1; BrowseProgress.Text=""; BrowseProgress.TextColor3=T.subText
BrowseProgress.TextScaled=true; BrowseProgress.Font=T.fontBody; BrowseProgress.TextWrapped=true
BrowseProgress.TextXAlignment=Enum.TextXAlignment.Center; BrowseProgress.ZIndex=32; BrowseProgress.Parent=AreaBrowser
local TravelBtn=Instance.new("TextButton"); TravelBtn.Size=UDim2.new(1,-24,0,38); TravelBtn.Position=UDim2.new(0,12,0,220)
TravelBtn.BackgroundColor3=T.buttonGreen; TravelBtn.BorderSizePixel=0; TravelBtn.Text="TRAVEL"; TravelBtn.TextColor3=T.bodyText
TravelBtn.TextScaled=true; TravelBtn.Font=T.font; TravelBtn.Visible=false; TravelBtn.ZIndex=33; TravelBtn.Parent=AreaBrowser
TravelBtn:SetAttribute("TutorialTarget", "TravelBtn")
Instance.new("UICorner",TravelBtn).CornerRadius=UDim.new(0,8)

local function AddButtonJuice(btn)
	local scale = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	btn.MouseEnter:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Scale = 1.08}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Scale = 1}):Play() end)
	btn.MouseButton1Down:Connect(function() TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.9}):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play() end)
end

AddButtonJuice(LeftArrow)
AddButtonJuice(RightArrow)
AddButtonJuice(TravelBtn)
AddButtonJuice(CloseBtn)

TravelBtn.MouseButton1Down:Connect(function()
	if browseIndex == currentArea then return end
	TravelToArea:FireServer(browseIndex)
end)

local function UpdateGoalSection()
	FarmEvalNumber.Text = "$" .. Formatter.Format(liveFarmEval)
	local nextGoalArea, nextGoalThreshold = nil, nil
	for i = currentArea + 1, MAX_AREA do
		local area = AreaRegistry.Get(i)
		if area and liveFarmEval < (area.threshold or 0) then
			nextGoalArea = i; nextGoalThreshold = area.threshold; break
		end
	end
	if nextGoalThreshold and nextGoalThreshold > 0 then
		local pct = math.clamp(liveFarmEval / nextGoalThreshold, 0, 1)
		TweenService:Create(ProgressFill, TweenInfo.new(0.3), { Size = UDim2.new(pct,0,1,0) }):Play()
		ProgressFill.BackgroundColor3 = pct >= 1 and Color3.fromRGB(80,255,160) or T.accentGreen
		local needed = math.max(0, nextGoalThreshold - liveFarmEval)
		ProgressLabel.Text = needed <= 0
			and "New areas available! Browse below."
			or "$" .. Formatter.Format(needed) .. " to unlock " .. AreaRegistry.GetName(nextGoalArea)
		ProgressLabel.TextColor3 = needed <= 0 and T.accentTeal or T.subText
	elseif portalReady then
		ProgressFill.Size = UDim2.new(1,0,1,0); ProgressFill.BackgroundColor3 = T.accentTeal
		ProgressLabel.Text = "Areas available! Pick a destination."; ProgressLabel.TextColor3 = T.accentTeal
	elseif currentArea >= MAX_AREA then
		ProgressFill.Size = UDim2.new(1,0,1,0); ProgressFill.BackgroundColor3 = T.accentGold
		ProgressLabel.Text = "Maximum area reached."; ProgressLabel.TextColor3 = T.accentGold
	end
end

local function RefreshBrowser()
	local idx = browseIndex
	local areaData = AreaRegistry.Get(idx)	
	if not areaData then return end
	AreaIndexLabel.Text = idx .. " / " .. MAX_AREA
	LeftArrow.Visible  = idx > 1
	RightArrow.Visible = AreaRegistry.Get(idx+1) ~= nil

	local highestUnlocked = 1
	for _, v in ipairs(unlockedAreas) do
		if v > highestUnlocked then highestUnlocked = v end
	end

	local unlockReq = areaData.threshold or 0
	local discReq = areaData.discoveryThreshold or (unlockReq * 0.25) 

	if idx <= highestUnlocked then
		local flipbookData = AreaRegistry.GetFlipbook(idx)
		if flipbookData then
			StartFlipbook(idx, AreaIcon)
			AreaIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		else
			StopFlipbook()
			-- ✨ Check for static `icon` first, then fallback to `auraPreviewImage`
			AreaIcon.Image = areaData.icon or areaData.auraPreviewImage or ""
			AreaIcon.ImageRectSize = Vector2.new(0, 0)
			AreaIcon.ImageRectOffset = Vector2.new(0, 0)
			AreaIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
		BrowseAreaName.Text = AreaRegistry.GetName(idx)
		BrowseAreaMult.Text = "Cube Value: " .. string.format("%.1f", AreaRegistry.GetMultiplier(idx)) .. "x base"

		if idx == currentArea then
			BrowseStatus.Text = "CURRENT AREA"; BrowseStatus.TextColor3 = T.accentGreen
			BrowseProgress.Text = "This is your active farm."
			BrowseProgress.TextColor3 = T.accentTeal
			TravelBtn.Visible = false
		else
			BrowseStatus.Text = "PREVIOUS AREA"; BrowseStatus.TextColor3 = T.accentGreen
			BrowseProgress.Text = "Travel back for free (no reset)."
			BrowseProgress.TextColor3 = T.accentGreen
			TravelBtn.Visible = true; TravelBtn.Text = "Travel"
			TravelBtn.BackgroundColor3 = Color3.fromRGB(60,100,60)
		end

	elseif idx == highestUnlocked + 1 then
		if liveFarmEval >= unlockReq then
			local flipbookData = AreaRegistry.GetFlipbook(idx)
			if flipbookData then
				StartFlipbook(idx, AreaIcon)
				AreaIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			else
				StopFlipbook()
				-- ✨ Static Icon Fallback
				AreaIcon.Image = areaData.icon or areaData.auraPreviewImage or ""
				AreaIcon.ImageRectSize = Vector2.new(0, 0)
				AreaIcon.ImageRectOffset = Vector2.new(0, 0)
				AreaIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			end
			BrowseAreaName.Text = AreaRegistry.GetName(idx)
			BrowseAreaMult.Text = "Cube Value: " .. string.format("%.1f", AreaRegistry.GetMultiplier(idx)) .. "x base"
			BrowseStatus.Text = "UNLOCKED"; BrowseStatus.TextColor3 = T.accentTeal
			BrowseProgress.Text = "Travel here (resets current run)."
			BrowseProgress.TextColor3 = T.accentTeal
			TravelBtn.Visible = true; TravelBtn.Text = "TRAVEL"
			TravelBtn.BackgroundColor3 = T.buttonGreen

		elseif liveFarmEval >= discReq then
			local flipbookData = AreaRegistry.GetFlipbook(idx)
			if flipbookData then
				StartFlipbook(idx, AreaIcon)
				AreaIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
			else
				StopFlipbook()
				-- ✨ Static Icon Fallback + Color Consistency Fix
				AreaIcon.Image = areaData.icon or areaData.auraPreviewImage or ""
				AreaIcon.ImageRectSize = Vector2.new(0, 0)
				AreaIcon.ImageRectOffset = Vector2.new(0, 0)
				AreaIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
			end
			BrowseAreaName.Text = AreaRegistry.GetName(idx)
			BrowseAreaMult.Text = "Cube Value: " .. string.format("%.1f", AreaRegistry.GetMultiplier(idx)) .. "x base"
			BrowseStatus.Text = "DISCOVERED"; BrowseStatus.TextColor3 = T.accentPurple

			local needed = math.max(0, unlockReq - liveFarmEval)
			BrowseProgress.Text = "Requires $"..Formatter.Format(unlockReq).." Farm Eval\n$"..Formatter.Format(needed).." remaining"
			BrowseProgress.TextColor3 = T.subText
			TravelBtn.Visible = false

		else
			StopFlipbook()
			-- ✨ Static Icon Fallback
			AreaIcon.Image = areaData.icon or areaData.auraPreviewImage or ""
			AreaIcon.ImageRectSize = Vector2.new(0, 0)
			AreaIcon.ImageRectOffset = Vector2.new(0, 0)
			AreaIcon.ImageColor3 = Color3.fromRGB(0, 0, 0) 
			BrowseAreaName.Text = "???"
			BrowseAreaMult.Text = "???x base"
			BrowseStatus.Text = "UNDISCOVERED"; BrowseStatus.TextColor3 = T.subText

			local needed = math.max(0, discReq - liveFarmEval)
			BrowseProgress.Text = "Keep growing to discover what's next.\n$"..Formatter.Format(needed).." to Discover"
			BrowseProgress.TextColor3 = T.subText
			TravelBtn.Visible = false
		end

	else
		StopFlipbook()
		-- ✨ Static Icon Fallback
		AreaIcon.Image = areaData.icon or areaData.auraPreviewImage or ""
		AreaIcon.ImageRectSize = Vector2.new(0, 0)
		AreaIcon.ImageRectOffset = Vector2.new(0, 0)
		AreaIcon.ImageColor3 = Color3.fromRGB(0, 0, 0)
		BrowseAreaName.Text = "???"
		BrowseAreaMult.Text = "???x base"
		BrowseStatus.Text = "LOCKED"; BrowseStatus.TextColor3 = T.subText
		BrowseProgress.Text = "Unlock previous areas first."
		BrowseProgress.TextColor3 = T.subText
		TravelBtn.Visible = false
	end
end

LeftArrow.MouseButton1Down:Connect(function()
	if browseIndex > 1 then browseIndex -= 1; PlayUI(SoundConfig.UIArrow); RefreshBrowser() end
end)
RightArrow.MouseButton1Down:Connect(function()
	if AreaRegistry.Get(browseIndex+1) then browseIndex += 1; PlayUI(SoundConfig.UIArrow); RefreshBrowser() end
end)

local StatsBtn=Instance.new("TextButton"); StatsBtn.Name="NextAreaButton"
StatsBtn.Size=UDim2.new(0,C.HUD.NextAreaButtonW,0,C.HUD.NextAreaButtonH)
StatsBtn.Position=UDim2.new(0,156,1,C.HUD.BottomButtonY)
StatsBtn.BackgroundColor3=T.headerBG; StatsBtn.BorderSizePixel=0
StatsBtn.Text="Next Area"; StatsBtn.TextColor3=T.bodyText; StatsBtn.TextScaled=true; StatsBtn.Font=T.font
StatsBtn.Visible = false
StatsBtn.ZIndex=10; StatsBtn.Parent=mainHUD
StatsBtn:SetAttribute("TutorialTarget", "AreaTravelButton")
Instance.new("UICorner",StatsBtn).CornerRadius=UDim.new(0,8)
AddButtonJuice(StatsBtn)

local function OpenPanel()
	panelOpen=true; browseIndex=currentArea; UpdateGoalSection(); RefreshBrowser()
	StatsPanel.Visible=true
	StatsPanel.Size=UDim2.new(0.88, 0, 0, 0)
	TweenService:Create(StatsPanel, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{ Size=UDim2.new(0.88, 0, 0.82, 0) }):Play()
	UITheme.SetMenuVisible(true)
end

local function ClosePanel()
	panelOpen=false; StopFlipbook(); PlayUI(SoundConfig.UIClose)
	TweenService:Create(StatsPanel, TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
		{ Size=UDim2.new(0.88, 0, 0, 0) }):Play()
	UITheme.SetMenuVisible(false)
	task.delay(0.3, function() StatsPanel.Visible=false end)
end
StatsBtn.MouseButton1Down:Connect(function() if panelOpen then ClosePanel() else OpenPanel() end end)
CloseBtn.MouseButton1Down:Connect(ClosePanel)

local function ShowAreaBanner(info)
	if info.travelType == "backward" then return end
	local areaIndex = info.newArea or 2
	local areaData = AreaRegistry.Get(areaIndex)
	local areaName = info.areaName or AreaRegistry.GetName(areaIndex)
	local multText = "Cube Value: "..string.format("%.1f", info.areaMultiplier or 1.0).."x"
	local saText = (info.newSoulAuras and info.newSoulAuras > 0)
		and ("+"..Formatter.Format(info.newSoulAuras).." Soul Auras") or nil
	local accentColor = (areaData and areaData.auraHolderGlow) or T.accentTeal
	local bannerH = saText and 82 or 64
	local banner=Instance.new("Frame"); banner.Size=UDim2.new(0,BW,0,bannerH)
	banner.Position=UDim2.new(0,-(BW+10),0,BY); banner.BackgroundColor3=T.panelBG; banner.BorderSizePixel=0
	banner.ZIndex=55; banner.ClipsDescendants=true; banner.Parent=mainHUD
	Instance.new("UICorner",banner).CornerRadius=UDim.new(0,BR)
	local bs=Instance.new("UIStroke"); bs.Color=accentColor; bs.Thickness=1.5; bs.Parent=banner
	local nameLabel=Instance.new("TextLabel"); nameLabel.Size=UDim2.new(1,-12,0,22); nameLabel.Position=UDim2.new(0,10,0,6)
	nameLabel.BackgroundTransparency=1; nameLabel.Text=areaName; nameLabel.TextColor3=accentColor
	nameLabel.TextScaled=true; nameLabel.Font=T.font; nameLabel.TextXAlignment=Enum.TextXAlignment.Left
	nameLabel.ZIndex=56; nameLabel.Parent=banner
	local multLabel=Instance.new("TextLabel"); multLabel.Size=UDim2.new(1,-12,0,18); multLabel.Position=UDim2.new(0,10,0,30)
	multLabel.BackgroundTransparency=1; multLabel.Text=multText; multLabel.TextColor3=T.accentGold
	multLabel.TextScaled=true; multLabel.Font=T.fontBody; multLabel.TextXAlignment=Enum.TextXAlignment.Left
	multLabel.ZIndex=56; multLabel.Parent=banner
	if saText then
		local saLabel=Instance.new("TextLabel"); saLabel.Size=UDim2.new(1,-12,0,16); saLabel.Position=UDim2.new(0,10,0,52)
		saLabel.BackgroundTransparency=1; saLabel.Text=saText; saLabel.TextColor3=T.accentPurple
		saLabel.TextScaled=true; saLabel.Font=T.fontBody; saLabel.TextXAlignment=Enum.TextXAlignment.Left
		saLabel.ZIndex=56; saLabel.Parent=banner
	end
	TweenService:Create(banner, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{ Position=UDim2.new(0,10,0,BY) }):Play()
	task.delay(4, function()
		TweenService:Create(banner, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
			{ Position=UDim2.new(0,-(BW+10),0,BY) }):Play()
		task.delay(0.4, function() if banner and banner.Parent then banner:Destroy() end end)
	end)
end

UpdateHUD.OnClientEvent:Connect(function(stats)
	if stats.farmEvaluation ~= nil then liveFarmEval = stats.farmEvaluation end
	if panelOpen then UpdateGoalSection(); RefreshBrowser() end
end)

AreaUpdated.OnClientEvent:Connect(function(info)
	currentArea = info.currentArea or 1
	if currentArea > 1 then player:SetAttribute("TutorialCompleted", true) end
	portalReady = info.portalReady == true
	if info.unlockedAreas then unlockedAreas = info.unlockedAreas end
	MAX_AREA = info.maxArea or AreaRegistry.GetMaxArea()
	if info.portalReady then AddPortalPrompt() else RemovePortalPrompt() end
	if panelOpen then UpdateGoalSection(); RefreshBrowser() end
end)

AreaUnlocked.OnClientEvent:Connect(function(info)
	portalReady = true; AddPortalPrompt()
	if info.unlockedAreas then unlockedAreas = info.unlockedAreas end
	local count = info.newAreasCount or 1
	local highestName = info.highestNewName or "New Area"
	local PBW = C.Banners.PortalBannerW; local PBH = C.Banners.PortalBannerH
	local banner=Instance.new("Frame"); banner.Size=UDim2.new(0,PBW,0,PBH)
	banner.Position=UDim2.new(0.5,-PBW/2,0,-PBH-10); banner.BackgroundColor3=T.panelBG; banner.BorderSizePixel=0
	banner.ZIndex=60; banner.Parent=mainHUD
	Instance.new("UICorner",banner).CornerRadius=UDim.new(0,BR)
	local bStroke=Instance.new("UIStroke"); bStroke.Color=T.accentTeal; bStroke.Thickness=2; bStroke.Parent=banner
	local bLabel=Instance.new("TextLabel"); bLabel.Size=UDim2.new(1,-20,1,0); bLabel.Position=UDim2.new(0,10,0,0)
	bLabel.BackgroundTransparency=1
	bLabel.Text = count == 1
		and (highestName.." unlocked! Open Area Travel.")
		or (count.." new areas unlocked! Open Area Travel to choose.")
	bLabel.TextColor3=T.accentTeal; bLabel.TextScaled=true; bLabel.Font=T.font; bLabel.ZIndex=61; bLabel.Parent=banner
	TweenService:Create(banner, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{ Position=UDim2.new(0.5,-PBW/2,0,14) }):Play()
	task.delay(5, function()
		TweenService:Create(banner, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
			{ Position=UDim2.new(0.5,-PBW/2,0,-PBH-10) }):Play()
		task.delay(0.4, function() if banner and banner.Parent then banner:Destroy() end end)
	end)
end)

PrestigeComplete.OnClientEvent:Connect(function(info)
	if info.isPortalEntry then
		portalReady=false; liveFarmEval=0; RemovePortalPrompt()
		if panelOpen then ClosePanel() end
	end
end)

AreaChanged.OnClientEvent:Connect(function(info)
	currentArea = info.newArea or currentArea; browseIndex = currentArea; portalReady = false
	if info.unlockedAreas then unlockedAreas = info.unlockedAreas end
	if panelOpen then ClosePanel() end
	ShowAreaBanner(info)
end)

function AddPortalPrompt()
	if promptAdded then return end; promptAdded = true
	local prompt=Instance.new("ProximityPrompt"); prompt.Name="PortalPrompt"; prompt.ObjectText="Portal"
	prompt.ActionText="Open Area Travel"; prompt.HoldDuration=0.5; prompt.MaxActivationDistance=12
	prompt.Parent=PositionPart
	prompt.Triggered:Connect(function(p) if p == player and not panelOpen then OpenPanel() end end)
end

function RemovePortalPrompt()
	promptAdded=false; local e=PositionPart:FindFirstChild("PortalPrompt"); if e then e:Destroy() end
end

local function RefreshLook()
	UITheme.Apply(StatsPanel, "Panel")
	UITheme.Apply(HeaderBar, "TitleBar")
	UITheme.Apply(GoalSection, "ShopCard")
	UITheme.Apply(AreaBrowser, "ShopCard")
	UITheme.Apply(HeaderBar, "Panel")
	UITheme.Apply(RightArrow, "Panel")
	UITheme.Apply(LeftArrow, "Panel")
	UITheme.Apply(StatsBtn, "Panel")
	UITheme.ApplyShine(AreaBrowser)
	UITheme.ApplyShine(GoalSection)
	UITheme.ApplyShine(StatsPanel)
	GoalSection.BackgroundColor3 = T.cardBG 
	AreaBrowser.BackgroundColor3 = T.cardBG
	local outerStroke = StatsPanel:FindFirstChildWhichIsA("UIStroke")
	if outerStroke then outerStroke.Color = Color3.fromRGB(255, 255, 255) end
end

task.wait(2)
RefreshLook()

--PreloadBlackout Scripts
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

-- Instantly hide the default Roblox loading logo
ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a pitch-black curtain before the game renders the first frame
local gui = Instance.new("ScreenGui")
gui.Name = "PreloadBlackout"
gui.DisplayOrder = 999999 -- Forces it above absolutely everything
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "BlackoutFrame"
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = gui

gui.Parent = playerGui

-- PrestigeController
-- Location: StarterPlayer > StarterPlayerScripts > PrestigeController
--
-- FIXES:
--   Bigger Soul Aura display text (was 22/14/14, now 28/18/18)
--   Wider display frame (200px instead of UIConfig 160px)
--   "Used" properly resets from UpdateHUD on join when wipe flags are on
--   AreaChanged always resets prestige state

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local AdminConfig       = require(ReplicatedStorage.Modules.AdminConfig)
local PrestigeModule    = require(ReplicatedStorage.Modules.PrestigeModule)
local T                 = require(ReplicatedStorage.Modules.UITheme).Get()
local C                 = require(ReplicatedStorage.Modules.UIConfig)
local Formatter         = require(ReplicatedStorage.Modules.NumberFormatter)
local UITheme = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
local T = UITheme.Get("Custom")
local EXPONENT     = PrestigeModule.EXPONENT
local COEFFICIENT  = PrestigeModule.COEFFICIENT
local BONUS_PER_SA = PrestigeModule.BONUS_PER_SA

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local RequestPrestige  = ReplicatedStorage.RemoteEvents:WaitForChild("RequestPrestige")
local PrestigeComplete = ReplicatedStorage.RemoteEvents:WaitForChild("PrestigeComplete")
local PreviewPrestige  = ReplicatedStorage.RemoteEvents:WaitForChild("PreviewPrestige")
local AreaChanged      = ReplicatedStorage.RemoteEvents:WaitForChild("AreaChanged")

local PrestigeReady = Instance.new("BindableEvent")
PrestigeReady.Name   = "PrestigeReady"
PrestigeReady.Parent = ReplicatedStorage

local dialogOpen        = false
local dialogCanPrestige = false
local previewPending    = false

local serverTotalEarned    = 0
local displayedTotalEarned = 0
local ratePerSecond        = 0
local serverSoulAuras      = 0
local displayedRunSA       = 0
local barHighWaterMark     = 0
local hasPrestigedThisArea = false

local PRESTIGE_COLOR_ACTIVE   = Color3.fromRGB(120, 50,  160)
local PRESTIGE_COLOR_DISABLED = Color3.fromRGB(60,  55,  70)
local PRESTIGE_COLOR_PENDING  = Color3.fromRGB(80,  40,  110)
local PRESTIGE_COLOR_USED     = Color3.fromRGB(80,  60,  50)

local function CalcSoulAurasLocal(totalEarned)
	if totalEarned <= 0 then return 0 end
	return math.floor((totalEarned ^ EXPONENT) * COEFFICIENT)
end	
local function GetThreshold(n)
	if n <= 0 then return 0 end
	return (n / COEFFICIENT) ^ (1 / EXPONENT)
end
local function PlayUI(id) if shared.PlayUISound then shared.PlayUISound(id) end end

local function GetButtonColor()
	if hasPrestigedThisArea then return PRESTIGE_COLOR_USED end
	if CalcSoulAurasLocal(serverTotalEarned) > 0 then return PRESTIGE_COLOR_ACTIVE end
	return PRESTIGE_COLOR_DISABLED
end
local function GetButtonText()
	if hasPrestigedThisArea then return "Used" end
	return "Prestige"
end

---------------------------------------------------------------
-- Soul Aura display � FIX: BIGGER TEXT
---------------------------------------------------------------
local SA_DISPLAY_W = 220   -- was 160
local SA_DISPLAY_H = 90    -- was 70

local SADisplay = Instance.new("Frame")
SADisplay.Name = "SoulAuraDisplay"
SADisplay.Size = UDim2.new(0, SA_DISPLAY_W, 0, SA_DISPLAY_H)
SADisplay.Position = UDim2.new(0, 10, 1, -155)
SADisplay.BackgroundTransparency = 1; SADisplay.ZIndex = 5; SADisplay.Parent = mainHUD

local SACountLabel = Instance.new("TextLabel")
SACountLabel.Size = UDim2.new(1,0,0,28)       -- FIX: was 22
SACountLabel.Position = UDim2.new(0,0,0,0)
SACountLabel.BackgroundTransparency = 1; SACountLabel.Text = "0 Soul Auras"
SACountLabel.TextColor3 = Color3.fromRGB(200,160,255); SACountLabel.TextScaled = true
SACountLabel.Font = T.font; SACountLabel.TextXAlignment = Enum.TextXAlignment.Center
SACountLabel.ZIndex = 6; SACountLabel.Parent = SADisplay

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(1,0,0,12)              -- FIX: was 10
BarBG.Position = UDim2.new(0,0,0,32)
BarBG.BackgroundColor3 = Color3.fromRGB(60,30,80); BarBG.BorderSizePixel = 0
BarBG.ZIndex = 6; BarBG.Parent = SADisplay
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(0,5)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0,0,1,0)
BarFill.BackgroundColor3 = Color3.fromRGB(255,255,255); BarFill.BorderSizePixel = 0
BarFill.ZIndex = 7; BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0,5)

local RunSALabel = Instance.new("TextLabel")
RunSALabel.Size = UDim2.new(1,0,0,18)         -- FIX: was 14
RunSALabel.Position = UDim2.new(0,0,0,48)
RunSALabel.BackgroundTransparency = 1; RunSALabel.Text = "earning..."
RunSALabel.TextColor3 = Color3.fromRGB(160,140,180); RunSALabel.TextScaled = true
RunSALabel.Font = T.fontBody; RunSALabel.TextXAlignment = Enum.TextXAlignment.Left
RunSALabel.ZIndex = 6; RunSALabel.Parent = SADisplay

local MultDisplayLabel = Instance.new("TextLabel")
MultDisplayLabel.Size = UDim2.new(1,0,0,18)    -- FIX: was 14
MultDisplayLabel.Position = UDim2.new(0,0,0,68)
MultDisplayLabel.BackgroundTransparency = 1; MultDisplayLabel.Text = "+0% earnings bonus"
MultDisplayLabel.TextColor3 = Color3.fromRGB(140,120,170); MultDisplayLabel.TextScaled = true
MultDisplayLabel.Font = T.fontBody; MultDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
MultDisplayLabel.ZIndex = 6; MultDisplayLabel.Parent = SADisplay

---------------------------------------------------------------
-- Prestige button
---------------------------------------------------------------
local PrestigeButton = Instance.new("TextButton")
PrestigeButton.Name = "PrestigeButton"
PrestigeButton.Size = UDim2.new(0, C.HUD.PrestigeButtonW, 0, C.HUD.PrestigeButtonH)
PrestigeButton.Position = UDim2.new(0, 10, 1, C.HUD.BottomButtonY)
PrestigeButton.BackgroundColor3 = PRESTIGE_COLOR_DISABLED; PrestigeButton.BorderSizePixel = 0
PrestigeButton.Text = "Prestige"; PrestigeButton.TextColor3 = Color3.fromRGB(255,255,255)
PrestigeButton.TextScaled = true; PrestigeButton.Font = T.font
PrestigeButton.ZIndex = 5; PrestigeButton.Parent = mainHUD
PrestigeButton:SetAttribute("TutorialTarget", "MainPrestigeBtn")
Instance.new("UICorner", PrestigeButton).CornerRadius = UDim.new(0,6)

---------------------------------------------------------------
-- Prestige dialog (MOBILE SCROLL FIX)
---------------------------------------------------------------
local D=C.Dialog; local DW=D.W; local DH=D.H; local DHH=D.HeaderH; local GAP=D.LabelGap

local Dialog = Instance.new("Frame")
Dialog.Name="PrestigeDialog"
Dialog.Size=UDim2.new(0.88, 0, 0.72, 0)
Dialog.AnchorPoint=Vector2.new(0.5, 0.5)
Dialog.Position=UDim2.new(0.5, 0, 0.5, 0)
Dialog.BackgroundColor3=Color3.fromRGB(25,20,35); Dialog.BorderSizePixel=0
Dialog.Visible=false; Dialog.ZIndex=20; Dialog.Parent=mainHUD
Instance.new("UICorner",Dialog).CornerRadius=UDim.new(0,D.CornerRadius)
local dialogConstraint=Instance.new("UISizeConstraint"); dialogConstraint.MaxSize=Vector2.new(DW,DH); dialogConstraint.Parent=Dialog
local dialogStroke=Instance.new("UIStroke"); dialogStroke.Color=Color3.fromRGB(140,70,200); dialogStroke.Thickness=2; dialogStroke.Parent=Dialog

local DialogHeader=Instance.new("Frame"); DialogHeader.Size=UDim2.new(1,0,0,DHH)
DialogHeader.BackgroundColor3=Color3.fromRGB(60,25,90); DialogHeader.BorderSizePixel=0
DialogHeader.ZIndex=21; DialogHeader.Parent=Dialog
Instance.new("UICorner",DialogHeader).CornerRadius=UDim.new(0,D.CornerRadius)
local DialogTitle=Instance.new("TextLabel"); DialogTitle.Size=UDim2.new(1,-48,1,0); DialogTitle.Position=UDim2.new(0,14,0,0)
DialogTitle.BackgroundTransparency=1; DialogTitle.Text="Prestige?"
DialogTitle.TextColor3=Color3.fromRGB(200,140,255); DialogTitle.TextScaled=true
DialogTitle.Font=T.font; DialogTitle.TextXAlignment=Enum.TextXAlignment.Left; DialogTitle.ZIndex=22; DialogTitle.Parent=DialogHeader
local CBS=D.CloseBtnSize
local DialogCloseBtn=Instance.new("TextButton"); DialogCloseBtn.Size=UDim2.new(0,CBS,0,CBS)
DialogCloseBtn.Position=UDim2.new(1,-(CBS+8),0.5,-CBS/2)
DialogCloseBtn.BackgroundColor3=Color3.fromRGB(180,50,50); DialogCloseBtn.BorderSizePixel=0
DialogCloseBtn.Text="X"; DialogCloseBtn.TextColor3=Color3.fromRGB(255,255,255)
DialogCloseBtn.TextScaled=true; DialogCloseBtn.Font=T.font; DialogCloseBtn.ZIndex=22; DialogCloseBtn.Parent=DialogHeader
DialogCloseBtn:SetAttribute("TutorialTarget", "PrestigeCloseBtn")
Instance.new("UICorner",DialogCloseBtn).CornerRadius=UDim.new(0,5)

local CBH=D.ConfirmBtnH
local ConfirmBtn=Instance.new("TextButton"); ConfirmBtn.Size=UDim2.new(1,-30,0,CBH)
ConfirmBtn.Position=UDim2.new(0,15,1,-(CBH+8)) -- Anchored to the bottom
ConfirmBtn.BackgroundColor3=PRESTIGE_COLOR_ACTIVE; ConfirmBtn.BorderSizePixel=0
ConfirmBtn.Text="Prestige Now"; ConfirmBtn.TextColor3=Color3.fromRGB(255,255,255)
ConfirmBtn.TextScaled=true; ConfirmBtn.Font=T.font; ConfirmBtn.ZIndex=22; ConfirmBtn.Parent=Dialog
ConfirmBtn:SetAttribute("TutorialTarget", "PrestigeBtns")
Instance.new("UICorner",ConfirmBtn).CornerRadius=UDim.new(0,8)

-- THE SCROLL CONTAINER (Sits between Header and Confirm Button)
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
-- Size leaves room for Header (top) and ConfirmBtn + padding (bottom)
ScrollContainer.Size = UDim2.new(1, 0, 1, -(DHH + CBH + 20)) 
ScrollContainer.Position = UDim2.new(0, 0, 0, DHH + 5)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.Parent = Dialog

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, GAP) -- Uses your config gap!
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = ScrollContainer

-- Modified MakeLabel: No more manual labelY positioning, parented to ScrollContainer
local function MakeLabel(text, color, h, bold, wrapText)
	local l=Instance.new("TextLabel")
	l.Size=UDim2.new(1,-30,0,h) -- Width slightly smaller to fit scrollbar
	l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color
	l.TextScaled=true; l.Font=bold and T.font or T.fontBody
	l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=21
	if wrapText then l.TextWrapped=true end
	l.Parent=ScrollContainer -- Auto-stacks here!
	return l
end

local EarnedLabel  = MakeLabel("You will earn: +0 Soul Auras",  Color3.fromRGB(255,200,100), D.EarnedH, true)
local BoostLabel   = MakeLabel("",                              Color3.fromRGB(80,220,160),  D.BoostH,  true)
local MultLabel    = MakeLabel("Earnings Bonus: +0% -> +0%",    Color3.fromRGB(180,180,200), D.MultH,   false)
local TotalLabel   = MakeLabel("Total Soul Auras: 0",           Color3.fromRGB(140,140,160), D.TotalH,  false)
local HintLabel    = MakeLabel("Each Soul Aura gives +"..string.format("%.0f",BONUS_PER_SA*100).."% earnings!", Color3.fromRGB(200,160,255), D.HintH, true)
local BonusLabel   = MakeLabel("Kickstart Bonus: $50",          Color3.fromRGB(100,220,100), D.BonusH,  true)
local WarningLabel = MakeLabel("This will RESET your currency, upgrades, and all cubes. Soul Auras are permanent.", Color3.fromRGB(255,100,100), D.WarningH, false, true)

---------------------------------------------------------------
-- Dialog logic
---------------------------------------------------------------
local function CloseDialog()
	dialogOpen=false; dialogCanPrestige=false; Dialog.Visible=false; PlayUI("6895079853")
	UITheme.SetMenuVisible(false)
end

local function OpenDialogWithPreview(info)
	if dialogOpen then return end
	UITheme.SetMenuVisible(true)
	if info.hasPrestigedThisArea then
		dialogOpen=true; dialogCanPrestige=false
		EarnedLabel.Text="Already prestiged in this area!"; EarnedLabel.TextColor3=Color3.fromRGB(255,100,100)
		BoostLabel.Text=""
		MultLabel.Text="Travel to a new area to prestige again."; MultLabel.TextColor3=Color3.fromRGB(180,180,200)
		TotalLabel.Text="Total Soul Auras: "..Formatter.Format(info.currentSoulAuras or serverSoulAuras)
		BonusLabel.Text=""
		WarningLabel.Text="One prestige per area keeps progression fair. Keep farming or travel!"
		WarningLabel.TextColor3=Color3.fromRGB(200,180,140)
		ConfirmBtn.Text="USED"; ConfirmBtn.BackgroundColor3=PRESTIGE_COLOR_USED
		Dialog.Visible=true; return
	end
	if (info.newSoulAuras or 0) <= 0 then
		TweenService:Create(PrestigeButton,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(90,40,120)}):Play()
		task.delay(0.15, function()
			TweenService:Create(PrestigeButton,TweenInfo.new(0.15),{BackgroundColor3=GetButtonColor()}):Play()
		end); return
	end
	dialogCanPrestige=true; dialogOpen=true
	EarnedLabel.Text="You will earn: +"..Formatter.Format(info.newSoulAuras).." Soul Auras"
	EarnedLabel.TextColor3=Color3.fromRGB(255,200,100)
	BoostLabel.Text=info.soulBoostActive and "Soul Boost active - 2x Soul Auras!" or ""
	local currentBonus = (info.currentMultiplier - 1) * 100
	local newBonus = (info.newMultiplier - 1) * 100
	MultLabel.Text = "Earnings Bonus: +"..Formatter.Format(currentBonus).."% -> +"..Formatter.Format(newBonus).."%"
	TotalLabel.Text="Total Soul Auras: "..Formatter.Format(info.currentSoulAuras+info.newSoulAuras)
		.." (was "..Formatter.Format(info.currentSoulAuras)..")"
	BonusLabel.Text="Kickstart Bonus: $"..Formatter.Format(info.prestigeBonus).." to start your next run!"
	WarningLabel.Text="This will RESET your currency, upgrades, and all cubes. Soul Auras are permanent."
	WarningLabel.TextColor3=Color3.fromRGB(255,100,100)
	ConfirmBtn.BackgroundColor3=PRESTIGE_COLOR_ACTIVE; ConfirmBtn.Text="PRESTIGE"
	Dialog.Visible=true
end

PrestigeButton.MouseButton1Down:Connect(function()
	if dialogOpen then CloseDialog(); return end
	if hasPrestigedThisArea then
		dialogOpen=true; dialogCanPrestige=false
		UITheme.SetMenuVisible(true)
		EarnedLabel.Text="Already prestiged in this area!"; EarnedLabel.TextColor3=Color3.fromRGB(255,100,100)
		BoostLabel.Text=""; MultLabel.Text="Travel to a new area to prestige again."
		MultLabel.TextColor3=Color3.fromRGB(180,180,200)
		TotalLabel.Text="Total Soul Auras: "..Formatter.Format(serverSoulAuras)
		BonusLabel.Text=""
		WarningLabel.Text="One prestige per area. Keep farming or travel!"
		WarningLabel.TextColor3=Color3.fromRGB(200,180,140)
		ConfirmBtn.Text="USED"; ConfirmBtn.BackgroundColor3=PRESTIGE_COLOR_USED
		Dialog.Visible=true; return
	end
	if previewPending then return end
	if serverTotalEarned<=0 then
		TweenService:Create(PrestigeButton,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(90,40,120)}):Play()
		task.delay(0.15, function()
			TweenService:Create(PrestigeButton,TweenInfo.new(0.15),{BackgroundColor3=GetButtonColor()}):Play()
		end); return
	end
	previewPending=true
	TweenService:Create(PrestigeButton,TweenInfo.new(0.15),{BackgroundColor3=PRESTIGE_COLOR_PENDING}):Play()
	PreviewPrestige:FireServer()
	task.delay(5, function()
		if previewPending then previewPending=false
			TweenService:Create(PrestigeButton,TweenInfo.new(0.2),{BackgroundColor3=GetButtonColor()}):Play()
		end
	end)
end)

PreviewPrestige.OnClientEvent:Connect(function(info)
	previewPending=false
	if info.hasPrestigedThisArea~=nil then hasPrestigedThisArea=info.hasPrestigedThisArea end
	OpenDialogWithPreview(info)
end)

ConfirmBtn.MouseButton1Down:Connect(function()
	if not dialogCanPrestige then CloseDialog(); return end
	dialogCanPrestige=false; CloseDialog(); RequestPrestige:FireServer()
end)

DialogCloseBtn.MouseButton1Down:Connect(function()
	previewPending=false; CloseDialog()
	TweenService:Create(PrestigeButton,TweenInfo.new(0.2),{BackgroundColor3=GetButtonColor()}):Play()
end)

---------------------------------------------------------------
-- RenderStepped
---------------------------------------------------------------
local buttonWasEnabled = false
RunService.RenderStepped:Connect(function(dt)
	if ratePerSecond>0 then displayedTotalEarned+=ratePerSecond*dt end
	local runSA=CalcSoulAurasLocal(displayedTotalEarned)
	SACountLabel.Text=Formatter.Format(serverSoulAuras).." Soul Auras"
	if runSA>0 then
		RunSALabel.Text="+"..Formatter.Format(runSA).." on prestige"
		RunSALabel.TextColor3=hasPrestigedThisArea and Color3.fromRGB(140,120,100) or Color3.fromRGB(255,200,100)
	else
		RunSALabel.Text="earning..."
		RunSALabel.TextColor3=Color3.fromRGB(160,140,180)
	end
	local tc=GetThreshold(runSA); local tn=GetThreshold(runSA+1)
	local range=tn-tc; local progress=range>0 and math.clamp((displayedTotalEarned-tc)/range,0,1) or 0
	if runSA~=displayedRunSA then barHighWaterMark=0; displayedRunSA=runSA end
	if progress>barHighWaterMark then barHighWaterMark=progress end
	BarFill.Size=UDim2.new(barHighWaterMark,0,1,0)
	local canPrestige=CalcSoulAurasLocal(serverTotalEarned)>0 and not hasPrestigedThisArea
	if canPrestige~=buttonWasEnabled then
		buttonWasEnabled=canPrestige
		if canPrestige then PrestigeReady:Fire() end
		if not dialogOpen and not previewPending then
			PrestigeButton.Text=GetButtonText()
			TweenService:Create(PrestigeButton,TweenInfo.new(0.3),{BackgroundColor3=GetButtonColor()}):Play()
		end
	end
end)

---------------------------------------------------------------
-- UpdateHUD � FIX: always reads hasPrestigedThisArea from server
---------------------------------------------------------------
local UpdateHUD=ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")
UpdateHUD.OnClientEvent:Connect(function(stats)
	if stats.multiplier ~= nil then
		local mult = stats.multiplier
		-- Update your prestige label here (adjust name to match your GUI)
		local bonusText = mult > 1 and ("+" .. Formatter.Format((mult - 1) * 100) .. "% earnings bonus") or "+0% earnings bonus"
		-- Example: hud.PrestigeMenu.BonusLabel.Text = bonusText
	end
	if stats.totalEarned then
		serverTotalEarned=stats.totalEarned
		if serverTotalEarned>displayedTotalEarned then displayedTotalEarned=serverTotalEarned end
	end
	if stats.soulAuras then
		serverSoulAuras=stats.soulAuras
		local mult=1+(serverSoulAuras*BONUS_PER_SA)
		-- THE FIX: Replace the string.format line with this
		local bonusPercent = (mult - 1) * 100
		MultDisplayLabel.Text = mult > 1 and ("+" .. Formatter.Format(bonusPercent) .. "% earnings bonus") or "+0% earnings bonus"
		MultDisplayLabel.TextColor3=mult>1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
	end
	if stats.rate and stats.passiveInterval then
		local interval=stats.passiveInterval
		ratePerSecond=(interval>0 and stats.rate>0) and (stats.rate/interval) or 0
	end
	-- FIX: always sync prestige limit from server (fixes "Used" stuck after wipe)
	if stats.hasPrestigedThisArea~=nil then
		hasPrestigedThisArea=stats.hasPrestigedThisArea
		if not dialogOpen and not previewPending then
			PrestigeButton.Text=GetButtonText()
			TweenService:Create(PrestigeButton,TweenInfo.new(0.2),{BackgroundColor3=GetButtonColor()}):Play()
		end
	end
end)

---------------------------------------------------------------
-- PrestigeComplete
---------------------------------------------------------------
PrestigeComplete.OnClientEvent:Connect(function(info)
	if info.blocked then
		TweenService:Create(PrestigeButton,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(180,60,60)}):Play()
		task.delay(0.2, function() TweenService:Create(PrestigeButton,TweenInfo.new(0.2),{BackgroundColor3=PRESTIGE_COLOR_USED}):Play() end)
		PrestigeButton.Text="Used"; hasPrestigedThisArea=true; return
	end
	if info.hasPrestigedThisArea~=nil then hasPrestigedThisArea=info.hasPrestigedThisArea end

	for _,obj in ipairs(workspace:GetChildren()) do
		if obj:GetAttribute("AuraCube") then obj:Destroy() end
	end

	-- ✨ NEW BURST MATH LOGIC ✨
	local burstAmount = 0
	if info.newSoulAuras and info.newSoulAuras > 0 then
		-- The Custom Curve: 44->4, 440->12, 1500->20, 10000->43
		burstAmount = math.floor(math.pow(info.newSoulAuras, 0.4) * 1.1)
	elseif info.isPortalEntry then
		-- Flat amount if traveling to a new area with 0 soul auras (Early Game)
		burstAmount = 15 -- Change this flat number to whatever you want!
	end

	if burstAmount > 0 then
		burstAmount = math.clamp(burstAmount, 1, 50) -- Hard cap at 50 for safety
		local burstEvent = ReplicatedStorage.RemoteEvents:FindFirstChild("TutorialBurst")
		if burstEvent then burstEvent:FireServer(burstAmount) end
	end
	-- ✨ END BURST LOGIC ✨

	displayedTotalEarned=0; serverTotalEarned=0; displayedRunSA=0
	ratePerSecond=0; barHighWaterMark=0; previewPending=false
	serverSoulAuras=info.totalSoulAuras
	local flash=Instance.new("Frame"); flash.Size=UDim2.new(1,0,1,0)
	flash.BackgroundColor3=Color3.fromRGB(180,100,255); flash.BackgroundTransparency=0.2
	flash.ZIndex=50; flash.Parent=mainHUD
	TweenService:Create(flash,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1}):Play()
	task.delay(0.9, function() if flash and flash.Parent then flash:Destroy() end end)
	PrestigeButton.Text=GetButtonText()
	TweenService:Create(PrestigeButton,TweenInfo.new(0.2),{BackgroundColor3=GetButtonColor()}):Play()
	if not info.isPortalEntry then task.delay(0.3, function() ShowPrestigeResultCard(info) end) end
end)

---------------------------------------------------------------
-- AreaChanged � FIX: always reset prestige state
---------------------------------------------------------------
AreaChanged.OnClientEvent:Connect(function(info)
	hasPrestigedThisArea=info.hasPrestigedThisArea or false
	displayedTotalEarned=0; serverTotalEarned=0; displayedRunSA=0
	ratePerSecond=0; barHighWaterMark=0
	PrestigeButton.Text=GetButtonText()
	TweenService:Create(PrestigeButton,TweenInfo.new(0.2),{BackgroundColor3=GetButtonColor()}):Play()
end)

---------------------------------------------------------------
-- Result card
---------------------------------------------------------------
function ShowPrestigeResultCard(info)
	local CW=C.Cards.PrestigeCardW; local CH=C.Cards.PrestigeCardH
	local card=Instance.new("Frame"); card.Name="PrestigeResultCard"
	card.Size=UDim2.new(0,CW,0,CH); card.Position=UDim2.new(0.5,-CW/2,0,-CH-10)
	card.BackgroundColor3=Color3.fromRGB(22,16,32); card.BorderSizePixel=0
	card.ZIndex=55; card.Parent=mainHUD
	Instance.new("UICorner",card).CornerRadius=UDim.new(0,C.Cards.CornerRadius)
	local cs=Instance.new("UIStroke"); cs.Color=Color3.fromRGB(180,100,255); cs.Thickness=2; cs.Parent=card

	local function AddLabel(text,color,y,h)
		local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-20,0,h or 28); l.Position=UDim2.new(0,10,0,y)
		l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color
		l.TextScaled=true; l.Font=T.font; l.ZIndex=56; l.Parent=card
	end

	-- 1. HEADER
	AddLabel("PRESTIGE "..info.prestigeCount.." COMPLETE",Color3.fromRGB(210,160,255),10,36)

	-- 2. SOUL AURAS (FIXED)
	AddLabel("+"..Formatter.Format(info.newSoulAuras).." Soul Auras  ->  "..Formatter.Format(info.totalSoulAuras).." total",
		Color3.fromRGB(255,210,80),52,30)

	-- 3. MULTIPLIER (FIXED)
	local prevBonus = (info.previousMultiplier - 1) * 100
	local newBonus = (info.newMultiplier - 1) * 100
	AddLabel("Earnings Bonus: +"..Formatter.Format(prevBonus).."% -> +"..Formatter.Format(newBonus).."%",
		Color3.fromRGB(160,220,255),88,24)

	-- 4. KICKSTART BONUS
	AddLabel("Prestige Bonus: $"..Formatter.Format(info.prestigeBonus).." added to your wallet!",
		Color3.fromRGB(100,230,120),118,24)

	local cont=Instance.new("TextButton"); cont.Size=UDim2.new(0,130,0,36)
	cont.Position=UDim2.new(0.5,-65,1,-50)
	cont.BackgroundColor3=Color3.fromRGB(120,50,160); cont.BorderSizePixel=0
	cont.Text="Continue"; cont.TextColor3=Color3.fromRGB(255,255,255)
	cont.TextScaled=true; cont.Font=T.font; cont.ZIndex=57; cont.Parent=card
	Instance.new("UICorner",cont).CornerRadius=UDim.new(0,8)

	TweenService:Create(card,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Position=UDim2.new(0.5,-CW/2,0.22,0)}):Play()

	local dismissed=false
	local function Dismiss()
		if dismissed then return end; dismissed=true
		TweenService:Create(card,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
			{Position=UDim2.new(0.5,-CW/2,0,-CH-10)}):Play()
		task.delay(0.5, function() if card and card.Parent then card:Destroy() end end)
	end
	cont.MouseButton1Down:Connect(Dismiss); task.delay(10,Dismiss)
end

---------------------------------------------------------------
-- UI JUICE: Button Hover & Click Animations
---------------------------------------------------------------
local function AddButtonJuice(btn)
	-- Ensure the button has a UIScale object to animate
	local scale = btn:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = btn
	end

	-- Hover in: Slight grow
	btn.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Scale = 1.08}):Play()
	end)

	-- Hover out: Return to normal
	btn.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {Scale = 1}):Play()
	end)

	-- Click down: Shrink inwards
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Scale = 0.9}):Play()
	end)

	-- Release click: Bounce back to hover size
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play()
	end)
end

-- ✨ Apply the juice to your Area Browser buttons!
AddButtonJuice(PrestigeButton)
AddButtonJuice(ConfirmBtn)
AddButtonJuice(DialogCloseBtn)

local function RefreshLook()
	UITheme.Apply(PrestigeButton, "Panel")
	UITheme.Apply(ConfirmBtn, "Panel") -- 'Panel' usually looks best for big floating boxes
	UITheme.ApplyShine(Dialog)

	local outerStroke = Dialog:FindFirstChildWhichIsA("UIStroke")
	if outerStroke then
		outerStroke.Color = Color3.fromRGB(165, 20, 255) -- Change these RGB numbers to whatever color you want!
	end
end

task.wait(2)
RefreshLook()

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
local Faded2 = mainHUD:WaitForChild("Faded2") -- ✨ Get the container!

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
-- 2. SETTINGS BUTTON (Left Side of Faded2)
---------------------------------------------------------------
local SettingsBtn = Instance.new("ImageButton", Faded2) -- ✨ PARENTED TO FADED2
SettingsBtn.Name = "SettingsButton"
SettingsBtn.Size = UDim2.new(0.85, 0, 0.85, 0) -- ✨ Takes up 85% of Faded2's height
SettingsBtn.Position = UDim2.new(0.05, 0, 0.5, 0) -- ✨ Placed on the far left
SettingsBtn.AnchorPoint = Vector2.new(0, 0.5) -- ✨ Anchored perfectly center-left
SettingsBtn.BackgroundColor3 = T.buttonSecondary 
SettingsBtn.BorderSizePixel = 0
SettingsBtn.AutoButtonColor = false
SettingsBtn.ZIndex = 15
Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0.5, 0)

-- ✨ MOBILE FIX: Forces it to stay a perfect circle no matter the screen size!
local settingsAspect = Instance.new("UIAspectRatioConstraint", SettingsBtn)
settingsAspect.AspectRatio = 1.0 

local gearStroke = Instance.new("UIStroke", SettingsBtn)
gearStroke.Color = T.accentGold; gearStroke.Thickness = 1
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
local btnIcon = Instance.new("ImageLabel", SettingsBtn)
btnIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
btnIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
btnIcon.BackgroundTransparency = 1
btnIcon.ScaleType = Enum.ScaleType.Fit
btnIcon.Image = "rbxassetid://14923131909"
local scale = Instance.new("UIScale", SettingsBtn)
SettingsBtn.MouseEnter:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1.08}):Play() end)
SettingsBtn.MouseLeave:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), {Scale = 1}):Play() end)
SettingsBtn.MouseButton1Down:Connect(function() TweenService:Create(scale, TweenInfo.new(0.1), {Scale = 0.9}):Play() end)
SettingsBtn.MouseButton1Up:Connect(function() TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Scale = 1.08}):Play() end)
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

-- ShopController
-- Location: StarterPlayer > StarterPlayerScripts > ShopController

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

local UpgradeConfig     = require(ReplicatedStorage.Modules.UpgradeConfig)
local Formatter         = require(ReplicatedStorage.Modules.NumberFormatter)
local EpicUpgradeConfig = require(ReplicatedStorage.Modules.EpicUpgradeConfig)
local UITheme           = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UITheme"))
local T                 = UITheme.Get("Custom")
local SoundConfig       = require(ReplicatedStorage.Modules.SoundConfig)

local RemoteEvents        = ReplicatedStorage:WaitForChild("RemoteEvents")
local PurchaseUpgrade     = RemoteEvents:WaitForChild("PurchaseUpgrade", 15)
local UpgradeUpdated      = RemoteEvents:WaitForChild("UpgradeUpdated", 15)
local PurchaseEpicUpgrade = RemoteEvents:WaitForChild("PurchaseEpicUpgrade", 15)
local EpicUpgradeUpdated  = RemoteEvents:WaitForChild("EpicUpgradeUpdated", 15)

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local upgradeState      = {}
local epicUpgradeState  = {}
local currentCurrency   = 0
local liveGoldenAuras   = 0
local shopOpen          = false
local activeMainTab     = "Upgrades"
local regularCardRefs   = {}
local epicCardRefs      = {}
local isLoadingData     = true
local globalHoldActive  = false  -- Global flag to prevent multiple simultaneous holds
local globalHoldGeneration = 0    -- Global generation counter

-- ✨ FORWARD DECLARATIONS (functions defined later but needed earlier)
local UpdateLockedTierProgress = nil
local RebuildRegularShop = nil 

-- ─────────────────────────────────────────────────────────────────────────────
-- INITIALIZATION
-- ─────────────────────────────────────────────────────────────────────────────
for _, tierData in ipairs(UpgradeConfig.Tiers) do
	for upgradeId, cfg in pairs(tierData.upgrades) do
		upgradeState[upgradeId] = {
			level    = 0,
			maxLevel = cfg.maxLevel,
			cost     = UpgradeConfig.CalculateCost(upgradeId, 0),
			maxed    = false,
		}
	end
end

for _, tierData in ipairs(EpicUpgradeConfig.Tiers) do
	for upgradeId, cfg in pairs(tierData.upgrades) do
		epicUpgradeState[upgradeId] = {
			level    = 0,
			maxLevel = cfg.maxLevel,
			cost     = EpicUpgradeConfig.CalculateCost(upgradeId, 0),
			maxed    = false,
		}
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- VFX / SOUND HELPERS
-- ─────────────────────────────────────────────────────────────────────────────
local function PlayUIBurst(targetElement, amount, colorTheme)
	if not shopOpen then return end
	local burstGui = Instance.new("ScreenGui")
	burstGui.Name   = "JuiceBurst"
	burstGui.Parent = playerGui

	local absPos  = targetElement.AbsolutePosition
	local absSize = targetElement.AbsoluteSize
	local center  = absPos + (absSize / 2)

	for i = 1, amount do
		local particle = Instance.new("Frame")
		particle.BackgroundColor3 = colorTheme or Color3.fromRGB(255, 215, 0)
		particle.BorderSizePixel  = 0
		particle.Size             = UDim2.new(0, math.random(6, 12), 0, math.random(6, 12))
		particle.Position         = UDim2.new(0, center.X, 0, center.Y)
		particle.Rotation         = math.random(0, 360)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent       = particle
		particle.Parent     = burstGui

		local angle    = math.rad(math.random(0, 360))
		local distance = math.random(50, 150)
		local endPos   = UDim2.new(0, center.X + math.cos(angle) * distance, 0, center.Y + math.sin(angle) * distance + 50)

		local tInfo = TweenInfo.new(math.random(4, 7) / 10, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		TweenService:Create(particle, tInfo, {
			Position             = endPos,
			Size                 = UDim2.new(0, 0, 0, 0),
			Rotation             = particle.Rotation + math.random(-180, 180),
			BackgroundTransparency = 1,
		}):Play()
	end

	task.delay(1, function() burstGui:Destroy() end)
end

local comboPitch  = 1.0
local lastBuyTime = tick()

local function PlayPurchaseSound()
	if tick() - lastBuyTime < 0.3 then
		comboPitch = math.min(comboPitch + 0.05, 2.5)
	else
		comboPitch = 1.0
	end
	lastBuyTime = tick()

	local sfxFolder = ReplicatedStorage:FindFirstChild("SFX") or ReplicatedStorage:FindFirstChild("Sounds")
	if sfxFolder and sfxFolder:FindFirstChild("BuyPing") then
		local sfx = sfxFolder.BuyPing:Clone()
		sfx.PlaybackSpeed = comboPitch
		sfx.Parent        = game:GetService("SoundService")
		sfx:Play()
		game.Debris:AddItem(sfx, 2)
	end
end

local function PlayFeedbackSound(soundName, volume)
	local sfxFolder = ReplicatedStorage:FindFirstChild("SFX") or ReplicatedStorage:FindFirstChild("Sounds")
	if sfxFolder then
		local s = sfxFolder:FindFirstChild(soundName)
		if s then
			local sfx = s:Clone()
			sfx.Volume = volume or 0.5
			sfx.Parent = game:GetService("SoundService")
			sfx:Play()
			game.Debris:AddItem(sfx, 3)
			return
		end
	end
	warn("⚠️ UI Sound Missing: '" .. tostring(soundName) .. "' not found in ReplicatedStorage.SFX")
end

local lastErrorTime = tick()

local function PlayErrorFeedback(targetButton)
	if tick() - lastErrorTime < 0.25 then return end
	lastErrorTime = tick()

	local sfxFolder = ReplicatedStorage:FindFirstChild("Sounds") or ReplicatedStorage:FindFirstChild("SFX")
	if sfxFolder and sfxFolder:FindFirstChild("ErrorBuzz") then
		local sfx = sfxFolder.ErrorBuzz:Clone()
		sfx.Volume = 0.5
		sfx.Parent = workspace
		sfx:Play()
		game.Debris:AddItem(sfx, 2)
	end

	if targetButton and targetButton.Parent then
		local origPos    = targetButton.Position
		local wobbleInfo = TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true)
		TweenService:Create(targetButton, wobbleInfo, {
			Position = origPos + UDim2.new(0, 4, 0, 0)
		}):Play()
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MISC HELPERS
-- ─────────────────────────────────────────────────────────────────────────────
local function FormatNumber(n) return Formatter.Format(n) end
local function PlayUI(id) if shared.PlayUISound then shared.PlayUISound(id) end end

-- ─────────────────────────────────────────────────────────────────────────────
-- SHOP BUTTON
-- ─────────────────────────────────────────────────────────────────────────────
local ShopButton = Instance.new("ImageButton")
ShopButton.Name              = "ShopButton"
ShopButton.Size              = UDim2.new(0, 60, 0, 60)
ShopButton.AnchorPoint       = Vector2.new(1, 1)
ShopButton.Position          = UDim2.new(0.98, 0, 0.95, 0)
ShopButton.BackgroundColor3  = T.buttonSecondary
ShopButton.BorderSizePixel   = 0
ShopButton.AutoButtonColor   = false
ShopButton.ZIndex            = 5
ShopButton.Parent            = mainHUD
ShopButton:SetAttribute("TutorialTarget", "ShopButton")
Instance.new("UICorner", ShopButton).CornerRadius = UDim.new(0.5, 0)

local shopStroke = Instance.new("UIStroke", ShopButton)
shopStroke.Color     = T.accentGold
shopStroke.Thickness = 2

local shopIcon = Instance.new("ImageLabel", ShopButton)
shopIcon.Size               = UDim2.new(0.6, 0, 0.6, 0)
shopIcon.Position           = UDim2.new(0.2, 0, 0.2, 0)
shopIcon.BackgroundTransparency = 1
shopIcon.ScaleType          = Enum.ScaleType.Fit
shopIcon.Image              = "rbxassetid://14916846070"

-- ─────────────────────────────────────────────────────────────────────────────
-- SHOP PANEL
-- ─────────────────────────────────────────────────────────────────────────────
local PANEL_MAX_W = 420; local PANEL_MAX_H = 510; local HEADER_H = 42

local ShopPanel = Instance.new("Frame")
ShopPanel.Name              = "ShopPanel"
ShopPanel.Size              = UDim2.new(0.88, 0, 0.82, 0)
ShopPanel.AnchorPoint       = Vector2.new(0.5, 0.5)
ShopPanel.Position          = UDim2.new(0.5, 0, 0.5, 0)
ShopPanel.BackgroundColor3  = T.panelBG
ShopPanel.BorderSizePixel   = 0
ShopPanel.Visible           = false
ShopPanel.ZIndex            = 10
ShopPanel.ClipsDescendants  = true
ShopPanel.Parent            = mainHUD
Instance.new("UICorner", ShopPanel).CornerRadius = UDim.new(0, 10)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(PANEL_MAX_W, PANEL_MAX_H)
sizeConstraint.Parent  = ShopPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color     = T.panelStroke
panelStroke.Thickness = 2
panelStroke.Parent    = ShopPanel

local TitleBar = Instance.new("Frame")
TitleBar.Name                 = "TitleBar"
TitleBar.Size                 = UDim2.new(1, 0, 0, HEADER_H)
TitleBar.BackgroundColor3     = T.headerBG
TitleBar.BorderSizePixel      = 0
TitleBar.ZIndex               = 11
TitleBar.ClipsDescendants     = true
TitleBar.BackgroundTransparency = 1
TitleBar.Parent               = ShopPanel
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, -50, 1, 0)
TitleLabel.Position           = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "RESEARCH"
TitleLabel.TextColor3         = T.headerText
TitleLabel.TextScaled         = true
TitleLabel.Font               = T.font
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.ZIndex             = 12
TitleLabel.Parent             = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size             = UDim2.new(0, 30, 0, 30)
CloseButton.Position         = UDim2.new(1, -35, 0, 6)
CloseButton.BackgroundColor3 = T.buttonRed
CloseButton.BorderSizePixel  = 0
CloseButton.Text             = "X"
CloseButton.TextColor3       = T.bodyText
CloseButton.TextScaled       = true
CloseButton.Font             = T.font
CloseButton.ZIndex           = 9999
CloseButton.Parent           = TitleBar
CloseButton:SetAttribute("TutorialTarget", "ShopCloseBtn")
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- ─────────────────────────────────────────────────────────────────────────────
-- INFO POPUP
-- ─────────────────────────────────────────────────────────────────────────────
local InfoPopup = Instance.new("Frame")
InfoPopup.Name                 = "InfoPopup"
InfoPopup.Size                 = UDim2.new(0.85, 0, 0.6, 0)
InfoPopup.Position             = UDim2.new(0.5, 0, 0.5, 0)
InfoPopup.AnchorPoint          = Vector2.new(0.5, 0.5)
InfoPopup.BackgroundColor3     = T.cardBG
InfoPopup.BackgroundTransparency = 0
InfoPopup.ZIndex               = 50
InfoPopup.Visible              = false
InfoPopup.Parent               = ShopPanel
Instance.new("UICorner", InfoPopup).CornerRadius = UDim.new(0, 12)

local AspectConstraint = Instance.new("UIAspectRatioConstraint", InfoPopup)
AspectConstraint.AspectRatio = 1.0

local InfoScale = Instance.new("UIScale", InfoPopup)
InfoScale.Scale = 1

local InfoTitle = Instance.new("TextLabel", InfoPopup)
InfoTitle.Size                 = UDim2.new(1, -20, 0, 35)
InfoTitle.Position             = UDim2.new(0, 10, 0, 10)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text                 = ""
InfoTitle.TextColor3           = T.headerText
InfoTitle.TextScaled           = true
InfoTitle.Font                 = Enum.Font.GothamBold
InfoTitle.ZIndex               = 51

local InfoDesc = Instance.new("TextLabel", InfoPopup)
InfoDesc.Size                  = UDim2.new(1, -20, 1, -110)
InfoDesc.Position              = UDim2.new(0, 10, 0, 55)
InfoDesc.BackgroundTransparency = 1
InfoDesc.Text                  = ""
InfoDesc.TextColor3            = T.bodyText
InfoDesc.TextWrapped           = true
InfoDesc.TextScaled            = true
InfoDesc.Font                  = T.font
InfoDesc.TextYAlignment        = Enum.TextYAlignment.Top
InfoDesc.ZIndex                = 51

local InfoClose = Instance.new("TextButton", InfoPopup)
InfoClose.Size             = UDim2.new(0.6, 0, 0, 40)
InfoClose.Position         = UDim2.new(0.2, 0, 1, -50)
InfoClose.BackgroundColor3 = T.buttonPrimary
InfoClose.BorderSizePixel  = 0
InfoClose.Text             = "Close"
InfoClose.TextColor3       = T.headerText
InfoClose.TextScaled       = true
InfoClose.Font             = T.font
InfoClose.ZIndex           = 51
Instance.new("UICorner", InfoClose).CornerRadius = UDim.new(0, 8)

local function ShowInfo(title, desc)
	if shared.PlayUISound then shared.PlayUISound(SoundConfig.UIClick or "") end
	InfoTitle.Text = title
	InfoDesc.Text  = desc
	InfoPopup.BackgroundTransparency = 0

	InfoScale.Scale  = 0.5
	InfoPopup.Visible = true
	TweenService:Create(InfoScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

InfoClose.MouseButton1Down:Connect(function()
	if shared.PlayUISound then shared.PlayUISound(SoundConfig.UIClick or "") end
	local tween = TweenService:Create(InfoScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Scale = 0.5
	})
	tween:Play()
	tween.Completed:Once(function() InfoPopup.Visible = false end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- MAIN TAB BAR
-- ─────────────────────────────────────────────────────────────────────────────
local activeShopTabText = "Regular Upgrades"

local MainTabBar = Instance.new("Frame")
MainTabBar.Size                 = UDim2.new(1, -20, 0, 85)
MainTabBar.Position             = UDim2.new(0, 10, 0, HEADER_H + 4)
MainTabBar.BackgroundTransparency = 1
MainTabBar.ZIndex               = 11
MainTabBar.Parent               = ShopPanel

local ShopHoverLabel = Instance.new("TextLabel", MainTabBar)
ShopHoverLabel.Size                 = UDim2.new(1, 0, 0, 20)
ShopHoverLabel.Position             = UDim2.new(0, 0, 0, 0)
ShopHoverLabel.BackgroundTransparency = 1
ShopHoverLabel.TextColor3           = T.bodyText
ShopHoverLabel.TextScaled           = true
ShopHoverLabel.Font                 = T.font
ShopHoverLabel.Text                 = activeShopTabText

local TabBtnFrame = Instance.new("Frame", MainTabBar)
TabBtnFrame.Size                 = UDim2.new(1, 0, 1, -25)
TabBtnFrame.Position             = UDim2.new(0, 0, 0, 25)
TabBtnFrame.BackgroundTransparency = 1

local TabListLayout = Instance.new("UIListLayout", TabBtnFrame)
TabListLayout.FillDirection       = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabListLayout.Padding             = UDim.new(0, 25)

local TAB_COLOR_BASE   = T.buttonSecondary
local TAB_COLOR_HOVER  = T.buttonPrimary
local TAB_COLOR_ACTIVE = T.accentGold

local mainTabButtons = {}

local function MakeMainTab(name, hoverText, iconId)
	local btn = Instance.new("ImageButton", TabBtnFrame)
	btn.Name             = "MainTab_" .. name
	btn.Size             = UDim2.new(0, 48, 0, 48)
	btn.BackgroundColor3 = TAB_COLOR_BASE
	btn.AutoButtonColor  = false
	btn.ZIndex           = 12
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Color     = T.panelStroke
	stroke.Thickness = 2

	local icon = Instance.new("ImageLabel", btn)
	icon.Size               = UDim2.new(0.6, 0, 0.6, 0)
	icon.Position           = UDim2.new(0.2, 0, 0.2, 0)
	icon.BackgroundTransparency = 1
	icon.ScaleType          = Enum.ScaleType.Fit
	icon.Image              = iconId

	btn.MouseEnter:Connect(function()
		ShopHoverLabel.Text = hoverText
		if activeMainTab ~= name then btn.BackgroundColor3 = TAB_COLOR_HOVER end
	end)
	btn.MouseLeave:Connect(function()
		ShopHoverLabel.Text = activeShopTabText
		if activeMainTab ~= name then btn.BackgroundColor3 = TAB_COLOR_BASE end
	end)

	mainTabButtons[name] = { btn = btn, stroke = stroke }
	return btn
end

local tabEpic     = MakeMainTab("Epic",     "Epic Research",     "rbxassetid://14916846070")
local tabUpgrades = MakeMainTab("Upgrades", "Regular Upgrades",  "rbxassetid://14916846070")

-- ─────────────────────────────────────────────────────────────────────────────
-- CURRENCY LABEL
-- ─────────────────────────────────────────────────────────────────────────────
local CURRENCY_H = 0
local CurrencyLabel = Instance.new("TextLabel")
CurrencyLabel.Name              = "ShopCurrencyLabel"
CurrencyLabel.Size              = UDim2.new(1, -24, 0, CURRENCY_H)
CurrencyLabel.BackgroundTransparency = 1
CurrencyLabel.Text              = "$0"
CurrencyLabel.TextColor3        = T.currencyColor
CurrencyLabel.TextScaled        = true
CurrencyLabel.Font              = T.font
CurrencyLabel.TextXAlignment    = Enum.TextXAlignment.Right
CurrencyLabel.ZIndex            = 11
CurrencyLabel.Parent            = ShopPanel

-- ─────────────────────────────────────────────────────────────────────────────
-- SCROLL FRAMES
-- ─────────────────────────────────────────────────────────────────────────────
local function MakeScroll(name, yTop)
	local sf = Instance.new("ScrollingFrame")
	sf.Name                 = name
	sf.Size                 = UDim2.new(1, -20, 1, -(yTop + 10))
	sf.Position             = UDim2.new(0, 10, 0, yTop)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel      = 0
	sf.ScrollBarThickness   = 4
	sf.ScrollBarImageColor3 = T.subText
	sf.CanvasSize           = UDim2.new(0, 0, 0, 0)
	sf.ZIndex               = 11
	sf.Visible              = false
	sf.ClipsDescendants     = true
	sf.Parent               = ShopPanel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent  = sf
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)
	return sf
end

local REGULAR_SCROLL_TOP = HEADER_H + 95
local RegularScroll      = MakeScroll("RegularScroll", REGULAR_SCROLL_TOP)
local EPIC_SCROLL_TOP    = HEADER_H + 95
local EpicScroll         = MakeScroll("EpicScroll", EPIC_SCROLL_TOP)

-- ─────────────────────────────────────────────────────────────────────────────
-- CARD BUILDER
-- ─────────────────────────────────────────────────────────────────────────────
local function BuildCard(parent, upgradeId, cfg, isEpic, cardRefsTable)
	local card = Instance.new("Frame")
	card.Name             = "Card_" .. upgradeId
	card.Size             = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = T.cardBG
	card.BorderSizePixel  = 0
	card.Parent           = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

	local icon = Instance.new("ImageLabel", card)
	icon.Size               = UDim2.new(0, 50, 0, 50)
	icon.Position           = UDim2.new(0, 15, 0.5, -25)
	icon.BackgroundTransparency = 1
	icon.Image              = cfg.iconId or "rbxassetid://0"

	local infoBtn = Instance.new("TextButton", card)
	infoBtn.Size             = UDim2.new(0, 22, 0, 22)
	infoBtn.Position         = UDim2.new(0, 75, 0, 12)
	infoBtn.BackgroundColor3 = T.buttonSecondary
	infoBtn.Text             = "i"
	infoBtn.TextColor3       = T.bodyText
	infoBtn.Font             = Enum.Font.GothamBlack
	infoBtn.TextSize         = 14
	Instance.new("UICorner", infoBtn).CornerRadius = UDim.new(1, 0)
	infoBtn.MouseButton1Click:Connect(function() ShowInfo(cfg.displayName, cfg.description) end)

	local nameLabel = Instance.new("TextLabel", card)
	nameLabel.Size              = UDim2.new(0.74, -120, 0, 24)
	nameLabel.Position          = UDim2.new(0, 102, 0, 11)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text              = string.upper(cfg.displayName)
	nameLabel.TextColor3        = T.bodyText
	nameLabel.TextScaled        = true
	nameLabel.Font              = Enum.Font.FredokaOne
	nameLabel.TextXAlignment    = Enum.TextXAlignment.Left

	local descLabel = Instance.new("TextLabel", card)
	descLabel.Size              = UDim2.new(0.74, -95, 0, 36)
	descLabel.Position          = UDim2.new(0, 75, 0, 38)
	descLabel.BackgroundTransparency = 1
	descLabel.Text              = cfg.description
	descLabel.TextColor3        = T.subText
	descLabel.TextWrapped       = true
	descLabel.TextSize          = 16
	descLabel.Font              = Enum.Font.GothamMedium
	descLabel.TextXAlignment    = Enum.TextXAlignment.Left
	descLabel.TextYAlignment    = Enum.TextYAlignment.Top

	local levelLabel = Instance.new("TextLabel", card)
	levelLabel.Size             = UDim2.new(0.74, -95, 0, 18)
	levelLabel.Position         = UDim2.new(0, 75, 0, 76)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text             = "Lv. 0 / " .. cfg.maxLevel
	levelLabel.TextColor3       = T.accentGreen
	levelLabel.TextSize         = 16
	levelLabel.Font             = Enum.Font.FredokaOne
	levelLabel.TextXAlignment   = Enum.TextXAlignment.Left

	local buyButton = Instance.new("TextButton", card)
	buyButton.Name             = "PurchaseButton"
	buyButton.Size             = UDim2.new(0.24, 0, 0, 46)
	buyButton.AnchorPoint      = Vector2.new(1, 0.5)
	buyButton.Position         = UDim2.new(1, -12, 0.5, 0)
	buyButton.BackgroundColor3 = isEpic and T.accentPurple or T.buttonGreen
	buyButton.BorderSizePixel  = 0
	buyButton.TextColor3       = T.bodyText
	buyButton.TextScaled       = true
	buyButton.Font             = Enum.Font.FredokaOne
	Instance.new("UICorner", buyButton).CornerRadius = UDim.new(0, 8)

	cardRefsTable[upgradeId] = {
		frame      = card,
		levelLabel = levelLabel,
		buyButton  = buyButton,
		isEpic     = isEpic,
		tab        = cfg.category,
	}

	local holdingBuy    = false
	local buyGeneration = 0

	local tutorialLockLifted = false
	-- ✨ FIX: Check for the permanent persistent attribute to bypass the lock
	local function IsTutorialFinished()
		if tutorialLockLifted then return true end
		if player:GetAttribute("TutorialCompleted") then tutorialLockLifted = true; return true end
		if liveGoldenAuras > 0 then tutorialLockLifted = true; return true end
		for _, state in pairs(epicUpgradeState) do
			if state.level > 0 then tutorialLockLifted = true; return true end
		end
		local valState = upgradeState["blockValue"]
		if valState and valState.level > 0 then tutorialLockLifted = true; return true end
		return false
	end

	-- ✨ FIX: Stop any other card's hold when this one starts
	local function StopAllOtherHolds(myGen)
		if globalHoldGeneration ~= myGen then
			globalHoldGeneration = myGen
		end
	end

	local function TryBuy()
		if isLoadingData then return false end

		if isEpic then
			local state = epicUpgradeState[upgradeId]
			if not state or state.maxed then return false end
			if not IsTutorialFinished() then PlayErrorFeedback(buyButton); return false end

			local currentAuras = player:GetAttribute("LiveGoldenAuras") or 0
			local currentAuraSpend = player:GetAttribute("LocalAuraSpend") or 0
			local actualAuras = currentAuras - currentAuraSpend

			if actualAuras < state.cost then PlayErrorFeedback(buyButton); return false end

			local wasMaxedLocally = state.maxed
			player:SetAttribute("LocalAuraSpend", currentAuraSpend + state.cost)

			state.level += 1
			state.maxed  = (state.level >= state.maxLevel)
			state.cost   = state.maxed and 0 or EpicUpgradeConfig.CalculateCost(upgradeId, state.level)

			if state.maxed and not wasMaxedLocally then
				PlayFeedbackSound("MaxOut", 0.6); PlayUIBurst(buyButton, 20)
			else
				PlayPurchaseSound()
			end
			UpdateEpicCard(upgradeId)
			PurchaseEpicUpgrade:FireServer(upgradeId)
			return true
		else
			local state = upgradeState[upgradeId]
			if not state or state.maxed then return false end
			if not IsTutorialFinished() and upgradeId ~= "blockValue" then
				PlayErrorFeedback(buyButton); return false
			end

			local currentCash = player:GetAttribute("LiveCurrency") or 0
			local currentSpend = player:GetAttribute("LocalSpend") or 0
			local actualCash = currentCash - currentSpend

			if actualCash < state.cost then PlayErrorFeedback(buyButton); return false end

			local wasMaxedLocally = state.maxed
			player:SetAttribute("LocalSpend", currentSpend + state.cost)

			state.level += 1
			state.maxed  = (state.level >= state.maxLevel)
			state.cost   = state.maxed and 0 or UpgradeConfig.CalculateCost(upgradeId, state.level)

			if state.maxed and not wasMaxedLocally then
				PlayFeedbackSound("MaxOut", 0.6); PlayUIBurst(buyButton, 20)
			else
				PlayPurchaseSound()
			end
			UpdateRegularCard(upgradeId)
			UpdateLockedTierProgress() -- ✨ FIX: Update progress text immediately
			PurchaseUpgrade:FireServer(upgradeId)
			return true
		end
	end

	local pulseTween = nil

	buyButton.MouseButton1Down:Connect(function()
		-- ✨ FIX: Increment global generation to stop any other ongoing holds
		globalHoldGeneration += 1
		local myGlobalGen = globalHoldGeneration
		
		buyGeneration += 1
		local myGen   = buyGeneration
		holdingBuy    = true
		globalHoldActive = true

		local scale = buyButton:FindFirstChildOfClass("UIScale")
		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = buyButton
		end

		pulseTween = TweenService:Create(scale,
			TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Scale = 0.88 })
		pulseTween:Play()

		TryBuy()
		task.wait(0.3)
		local holdStart = tick()

		local UserInputService = game:GetService("UserInputService")
		local epicHoldSpeedLevel   = (epicUpgradeState["epicHoldSpeed"] and epicUpgradeState["epicHoldSpeed"].level) or 0
		local holdSpeedMultiplier  = 1 + (epicHoldSpeedLevel * 0.3)

		-- ✨ FIX: Check both local and global generation/flags
		while holdingBuy and buyGeneration == myGen and globalHoldGeneration == myGlobalGen do
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				holdingBuy = false; globalHoldActive = false; break
			end
			local success = TryBuy()
			if not success then holdingBuy = false; globalHoldActive = false; break end
			task.wait(math.max(0.02, (0.15 - ((tick() - holdStart) * 0.05)) / holdSpeedMultiplier))
		end

		globalHoldActive = false
		if pulseTween then pulseTween:Cancel() end
		if scale then
			TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Scale = 1 }):Play()
		end
	end)

	local function StopHold()
		holdingBuy = false
		globalHoldActive = false
		if pulseTween then pulseTween:Cancel() end
		local scale = buyButton:FindFirstChildOfClass("UIScale")
		if scale then
			TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Scale = 1 }):Play()
		end
	end

	buyButton.MouseButton1Up:Connect(StopHold)
	buyButton.MouseLeave:Connect(StopHold)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- BUILD EPIC CARDS
-- ─────────────────────────────────────────────────────────────────────────────
local epicOrderIndex = 1
for _, tierData in ipairs(EpicUpgradeConfig.Tiers) do
	for upgradeId, cfg in pairs(tierData.upgrades) do
		BuildCard(EpicScroll, upgradeId, cfg, true, epicCardRefs)

		local ref = epicCardRefs[upgradeId]
		if ref and ref.frame then
			ref.baseOrder      = epicOrderIndex
			ref.frame.LayoutOrder = epicOrderIndex
			epicOrderIndex    += 1
			ref.frame.Visible  = false
			ref.frame.Parent   = EpicScroll
			if UITheme and UITheme.Apply then UITheme.Apply(ref.frame, "ShopCard") end
		end
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CARD UPDATE FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────────
function UpdateRegularCard(upgradeId)
	local ref   = regularCardRefs[upgradeId]
	local state = upgradeState[upgradeId]
	if not ref or not state then return end
	if UITheme and UITheme.Apply then UITheme.Apply(ref.frame, "ShopCard") end

	ref.levelLabel.Text = "Lv. " .. state.level .. " / " .. state.maxLevel

	local currentCash   = player:GetAttribute("LiveCurrency") or 0
	local currentSpend  = player:GetAttribute("LocalSpend") or 0
	local actualCash    = currentCash - currentSpend

	if state.level >= state.maxLevel then
		ref.frame.LayoutOrder        = (ref.baseOrder or 0) + 100000
		ref.levelLabel.TextColor3    = Color3.fromRGB(255, 215, 0)
		ref.buyButton.Text           = "MAX"
		ref.buyButton.TextColor3     = Color3.fromRGB(255, 255, 255)
		ref.buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	else
		ref.frame.LayoutOrder      = ref.baseOrder or 0
		ref.buyButton.Text         = "$" .. FormatNumber(state.cost)
		ref.buyButton.TextColor3   = (actualCash < state.cost)
			and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
		ref.buyButton.BackgroundColor3 = Color3.fromRGB(60, 170, 80)
	end
end

function UpdateEpicCard(upgradeId)
	local ref   = epicCardRefs[upgradeId]
	local state = epicUpgradeState[upgradeId]
	if not ref or not state then return end
	if UITheme and UITheme.Apply then UITheme.Apply(ref.frame, "ShopCard") end

	ref.levelLabel.Text = "Lv. " .. state.level .. " / " .. state.maxLevel

	local currentAuras  = player:GetAttribute("LiveGoldenAuras") or 0
	local currentAuraSpend = player:GetAttribute("LocalAuraSpend") or 0
	local actualAuras   = currentAuras - currentAuraSpend

	if state.level >= state.maxLevel then
		ref.frame.LayoutOrder        = (ref.baseOrder or 0) + 100000
		ref.levelLabel.TextColor3    = Color3.fromRGB(255, 215, 0)
		ref.buyButton.Text           = "MAX"
		ref.buyButton.TextColor3     = Color3.fromRGB(255, 255, 255)
		ref.buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	else
		ref.frame.LayoutOrder      = ref.baseOrder or 0
		ref.buyButton.Text         = "✦ " .. FormatNumber(state.cost)
		ref.buyButton.TextColor3   = (actualAuras < state.cost)
			and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
		ref.buyButton.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
	end
end

function UpdateCurrencyDisplay()
	if activeMainTab == "Upgrades" then
		local currentCash = player:GetAttribute("LiveCurrency") or 0
		local currentSpend = player:GetAttribute("LocalSpend") or 0
		local actualCash = currentCash - currentSpend

		CurrencyLabel.Text       = "$" .. FormatNumber(actualCash)
		CurrencyLabel.TextColor3 = T.currencyColor
		CurrencyLabel.Position   = UDim2.new(0, 12, 0, HEADER_H + 34 + 8)
	end
end

local function UpdateAllRegularCards() for id in pairs(regularCardRefs) do UpdateRegularCard(id) end end
local function UpdateAllEpicCards()   for id in pairs(epicCardRefs)    do UpdateEpicCard(id)    end end

-- ✨ FIX: Update locked tier header progress without rebuilding the whole shop
UpdateLockedTierProgress = function()
	local totalUpgradesBought = 0
	for _, state in pairs(upgradeState) do
		totalUpgradesBought = totalUpgradesBought + (state.level or 0)
	end

	-- Find the locked tier header and update its progress text
	local lockedHeader = nil
	local required = 0
	
	for _, child in ipairs(RegularScroll:GetChildren()) do
		if child.Name == "TierHeader_Locked" then
			lockedHeader = child
			required = child:GetAttribute("Required") or 0
			local progressLabel = child:FindFirstChild("ProgressLabel")
			if progressLabel then
				progressLabel.Text = totalUpgradesBought .. " / " .. required .. " Upgrades Needed"
				
				-- Change color based on progress
				local progress = totalUpgradesBought / required
				if progress >= 1 then
					progressLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green when ready
				elseif progress >= 0.75 then
					progressLabel.TextColor3 = Color3.fromRGB(255, 200, 100) -- Orange when close
				else
					progressLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red when far
				end
			end
			break -- Only one locked header should exist
		end
	end
	
	-- ✨ FIX: If requirement met, rebuild the shop to unlock the tier!
	if lockedHeader and totalUpgradesBought >= required then
		-- ✨ Play tier unlock sound and VFX!
		PlayFeedbackSound("MaxOut", 0.8)
		PlayUIBurst(ShopPanel, 30, Color3.fromRGB(100, 255, 100))
		
		local scroll = ShopPanel:FindFirstChild("RegularScroll")
		local savedScroll = scroll and scroll.CanvasPosition or Vector2.new(0, 0)
		
		RebuildRegularShop()
		
		if scroll then scroll.CanvasPosition = savedScroll end
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TIER HEADERS
-- ─────────────────────────────────────────────────────────────────────────────
local function CreateTierHeader(tierName)
	local header = Instance.new("Frame")
	header.Name                 = "TierHeader"
	header.Size                 = UDim2.new(1, 0, 0, 30)
	header.BackgroundTransparency = 1

	local label = Instance.new("TextLabel")
	label.Size                  = UDim2.new(1, 0, 1, -5)
	label.BackgroundTransparency = 1
	label.Text                  = string.upper(tierName)
	label.TextColor3            = Color3.fromRGB(220, 220, 220)
	label.TextSize              = 16
	label.Font                  = Enum.Font.GothamBlack
	label.TextXAlignment        = Enum.TextXAlignment.Left
	label.Parent                = header

	local line = Instance.new("Frame")
	line.Size             = UDim2.new(1, 0, 0, 2)
	line.Position         = UDim2.new(0, 0, 1, -2)
	line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	line.BorderSizePixel  = 0
	line.Parent           = header
	return header
end

local function CreateLockedTierHeader(tierName, current, required)
	local header = Instance.new("Frame")
	header.Name                 = "TierHeader_Locked"
	header.Size                 = UDim2.new(1, 0, 0, 45)
	header.BackgroundTransparency = 1
	header:SetAttribute("Required", required)

	local label = Instance.new("TextLabel")
	label.Size                  = UDim2.new(1, 0, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Text                  = string.upper(tierName) .. " (LOCKED)"
	label.TextColor3            = Color3.fromRGB(150, 150, 150)
	label.TextSize              = 16
	label.Font                  = Enum.Font.GothamBlack
	label.TextXAlignment        = Enum.TextXAlignment.Left
	label.Parent                = header

	local progress = Instance.new("TextLabel")
	progress.Name               = "ProgressLabel"
	progress.Size               = UDim2.new(1, 0, 0.4, 0)
	progress.Position           = UDim2.new(0, 0, 0.6, 0)
	progress.BackgroundTransparency = 1
	progress.Text               = current .. " / " .. required .. " Upgrades Needed"
	progress.TextColor3         = Color3.fromRGB(255, 100, 100)
	progress.TextSize           = 12
	progress.Font               = Enum.Font.GothamBold
	progress.TextXAlignment     = Enum.TextXAlignment.Left
	progress.Parent             = header

	local line = Instance.new("Frame")
	line.Size             = UDim2.new(1, 0, 0, 2)
	line.Position         = UDim2.new(0, 0, 1, -2)
	line.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	line.BorderSizePixel  = 0
	line.Parent           = header
	return header
end

-- ─────────────────────────────────────────────────────────────────────────────
-- REBUILD REGULAR SHOP
-- ─────────────────────────────────────────────────────────────────────────────
RebuildRegularShop = function()
	for _, child in ipairs(RegularScroll:GetChildren()) do
		if child:IsA("Frame") and child.Name ~= "CardTemplate" then
			child:Destroy()
		end
	end
	regularCardRefs = {}

	local totalUpgradesBought = 0
	for _, state in pairs(upgradeState) do
		totalUpgradesBought = totalUpgradesBought + (state.level or 0)
	end

	local listOrder = 1

	for tierNum, tierData in ipairs(UpgradeConfig.Tiers) do
		if totalUpgradesBought >= tierData.unlockRequirement then
			local header = CreateTierHeader(tierData.tierName or "Tier " .. tierNum)
			header.LayoutOrder = listOrder
			listOrder += 1
			header.Parent = RegularScroll

			for upgradeId, cfg in pairs(tierData.upgrades) do
				BuildCard(RegularScroll, upgradeId, cfg, false, regularCardRefs)
				local ref = regularCardRefs[upgradeId]

				if ref and ref.frame then
					if ref.buyButton then
						ref.buyButton.Name = "Buy_" .. upgradeId
					end
					ref.baseOrder          = listOrder
					ref.frame.LayoutOrder  = listOrder
					listOrder             += 1
					ref.frame.Visible      = true
					ref.frame.Parent       = RegularScroll
					if UITheme and UITheme.Apply then UITheme.Apply(ref.frame, "ShopCard") end
					local myColor = Color3.fromRGB(45, 30, 55)
					ref.frame:SetAttribute("TierColor", myColor)
					ref.frame.BackgroundColor3 = myColor
				end
			end
		else
			local lockedHeader = CreateLockedTierHeader(
				tierData.tierName or "Tier " .. tierNum,
				totalUpgradesBought,
				tierData.unlockRequirement
			)
			lockedHeader.LayoutOrder = listOrder
			lockedHeader.Parent      = RegularScroll
			break
		end
	end
	UpdateAllRegularCards()
end

RebuildRegularShop()

-- 5 second fail-safe in case server takes extremely long to send fullState
task.delay(5, function() isLoadingData = false end)

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB SWITCHING
-- ─────────────────────────────────────────────────────────────────────────────
local function SwitchToMainTab(tabName)
	if shared.PlayUISound then shared.PlayUISound(SoundConfig.UIClick or "") end
	activeMainTab     = tabName
	activeShopTabText = (tabName == "Epic") and "Epic Research" or "Regular Upgrades"
	ShopHoverLabel.Text = activeShopTabText

	for name, data in pairs(mainTabButtons) do
		data.btn.BackgroundColor3 = (name == tabName) and TAB_COLOR_ACTIVE or TAB_COLOR_BASE
		data.stroke.Color         = (name == tabName) and T.bodyText or T.panelStroke
	end

	RegularScroll.Visible = (tabName == "Upgrades")
	EpicScroll.Visible    = (tabName == "Epic")

	if tabName == "Epic" then
		for _, ref in pairs(epicCardRefs) do
			if ref and ref.frame then ref.frame.Visible = true end
		end
		if EpicScroll then EpicScroll.CanvasPosition = Vector2.new(0, 0) end
	end
end

tabUpgrades.MouseButton1Down:Connect(function() PlayUI(SoundConfig.UIClick); SwitchToMainTab("Upgrades") end)
tabEpic.MouseButton1Down:Connect(function()     PlayUI(SoundConfig.UIClick); SwitchToMainTab("Epic")     end)

-- ─────────────────────────────────────────────────────────────────────────────
-- OPEN / CLOSE
-- ─────────────────────────────────────────────────────────────────────────────
local function OpenShop()
	shopOpen = true
	ShopPanel.Visible = true
	ShopPanel.Size    = UDim2.new(0.88, 0, 0, 0)
	SwitchToMainTab(activeMainTab)
	TweenService:Create(ShopPanel,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0.88, 0, 0.82, 0) }
	):Play()
	UITheme.SetMenuVisible(true)
	ShopButton.BackgroundColor3 = T.panelStroke
end

local function CloseShop()
	shopOpen = false
	PlayUI(SoundConfig.UIClose)
	TweenService:Create(ShopPanel,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = UDim2.new(0.88, 0, 0, 0) }
	):Play()
	UITheme.SetMenuVisible(false)
	task.delay(0.25, function() ShopPanel.Visible = false end)
	ShopButton.BackgroundColor3 = T.buttonSecondary
end

ShopButton.MouseButton1Down:Connect(function() if shopOpen then CloseShop() else OpenShop() end end)
CloseButton.MouseButton1Down:Connect(CloseShop)

-- ─────────────────────────────────────────────────────────────────────────────
-- LIVE UPDATE LOOP
-- ─────────────────────────────────────────────────────────────────────────────
local lastCardUpdate = 0
RunService.Heartbeat:Connect(function()
	if not shopOpen then return end
	local now = tick()
	if now - lastCardUpdate > 0.1 then
		lastCardUpdate = now
		if activeMainTab == "Upgrades" then UpdateAllRegularCards() else UpdateAllEpicCards() end
		UpdateCurrencyDisplay()
	end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVER EVENTS
-- ─────────────────────────────────────────────────────────────────────────────
if UpgradeUpdated then
	UpgradeUpdated.OnClientEvent:Connect(function(info)
		if info.type == "fullState" then
			isLoadingData = false
			upgradeState   = info.upgrades
			currentCurrency = info.currency
			RebuildRegularShop()
			UpdateCurrencyDisplay()

		elseif info.type == "purchased" then
			player:SetAttribute("LastServerPurchaseTick", tick())
			player:SetAttribute("LocalSpend", 0)
			-- ✨ FIX: Force sync currency to server value immediately
			player:SetAttribute("ForceSyncCurrency", info.currency)

			local current = upgradeState[info.upgradeId]
			if not current or info.level >= current.level then
				upgradeState[info.upgradeId] = {
					level    = info.level,
					maxLevel = info.maxLevel,
					cost     = info.cost,
					maxed    = info.maxed,
				}
			end
			currentCurrency = info.currency

			local scroll      = ShopPanel:FindFirstChild("RegularScroll")
			local savedScroll = scroll and scroll.CanvasPosition or Vector2.new(0, 0)

			RebuildRegularShop()
			UpdateCurrencyDisplay()

			if scroll then scroll.CanvasPosition = savedScroll end
		end
	end)
end

if EpicUpgradeUpdated then
	EpicUpgradeUpdated.OnClientEvent:Connect(function(info)
		if info.type == "fullState" then
			isLoadingData = false
			epicUpgradeState = info.upgrades
			liveGoldenAuras  = info.goldenAuras or liveGoldenAuras
			UpdateAllEpicCards()
			UpdateCurrencyDisplay()

		elseif info.type == "purchased" then
			player:SetAttribute("LastServerPurchaseTick", tick())
			player:SetAttribute("LocalAuraSpend", 0)

			local current = epicUpgradeState[info.upgradeId]
			if not current or info.level >= current.level then
				epicUpgradeState[info.upgradeId] = {
					level    = info.level,
					maxLevel = info.maxLevel,
					cost     = info.cost,
					maxed    = info.maxed,
				}
			end
			UpdateEpicCard(info.upgradeId)
			UpdateCurrencyDisplay()
		end
	end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- BUTTON JUICE
-- ─────────────────────────────────────────────────────────────────────────────
local function AddButtonJuice(btn)
	if not btn then return end
	local scale = btn:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = btn
	end

	btn.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Scale = 1.08 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Scale = 1 }):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.9 }):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Scale = 1.08 }):Play()
	end)
end

AddButtonJuice(ShopButton)
AddButtonJuice(CloseButton)
AddButtonJuice(tabUpgrades)
AddButtonJuice(tabEpic)

-- ─────────────────────────────────────────────────────────────────────────────
-- REFRESH LOOK
-- ─────────────────────────────────────────────────────────────────────────────
local shopShine    = nil
local titleFlair   = nil
local flairedExtra = false

local function RefreshLook()
	UITheme.Apply(ShopPanel, "Panel")
	UITheme.Apply(ShopPanel, "TitleBar")

	if not shopShine then
		shopShine  = UITheme.ApplyShine(ShopPanel)
		UITheme.ApplyShine(TitleBar)
	end

	if not titleFlair then
		titleFlair = UITheme.ApplyFlair(TitleLabel, "Ghost")
	end

	if not flairedExtra then flairedExtra = true end

	for _, scrollName in ipairs({ "RegularScroll", "EpicScroll" }) do
		local scroll = ShopPanel:FindFirstChild(scrollName)
		if scroll then
			local layout = scroll:FindFirstChildOfClass("UIListLayout")
			if layout then layout.SortOrder = Enum.SortOrder.LayoutOrder end
		end
	end

	local outerStroke = ShopPanel:FindFirstChildWhichIsA("UIStroke")
	if outerStroke then outerStroke.Color = Color3.fromRGB(255, 255, 255) end
end

task.wait(2)
RefreshLook()

-- SoundManager
-- Location: StarterPlayer > StarterPlayerScripts > SoundManager
--
-- MENU GATE: Only the initial area music waits for MenuDismissed.
-- shared.PlayUISound and all event connections work immediately.
-- This ensures other scripts can play sounds during loading.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")

local SoundConfig = require(ReplicatedStorage.Modules.SoundConfig)

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SoundGroup = Instance.new("SoundGroup")
SoundGroup.Name   = "AuraIncSounds"
SoundGroup.Volume = 1
SoundGroup.Parent = SoundService

local soundCache = {}

local function GetOrCreateSound(id, volume, looped)
	if not id or id == "" then return nil end
	local fullId = "rbxassetid://" .. id
	if not soundCache[id] then
		local s = Instance.new("Sound")
		s.SoundId = fullId; s.Volume = volume or 1
		s.Looped  = looped or false; s.RollOffMaxDistance = 0
		s.Parent  = SoundGroup
		soundCache[id] = s
	end
	return soundCache[id]
end

local sfxEnabled   = true
local musicEnabled = true
local MUSIC_VOL    = SoundConfig.Volume and SoundConfig.Volume.music or 0.4

local function Vol(category)
	return SoundConfig.Volume and SoundConfig.Volume[category] or 0.5
end

local function Play(id, volume)
	if not sfxEnabled then return end
	if not id or id == "" then return end
	local s = GetOrCreateSound(id, volume, false)
	if s then s:Play() end
end

-- Expose for other LocalScripts (PrestigeController, PortalController, etc.)
shared.PlayUISound = function(id, volume)
	Play(id, volume or Vol("ui"))
end

---------------------------------------------------------------
-- Hold loop
---------------------------------------------------------------
local loopingSound = nil

local function PlayLoop(id, volume)
	if not sfxEnabled then return end
	if not id or id == "" then return end
	local s = GetOrCreateSound(id, volume, true)
	if s and not s.IsPlaying then s:Play(); loopingSound = s end
end

local function StopLoop()
	if loopingSound and loopingSound.IsPlaying then loopingSound:Stop() end
	loopingSound = nil
end

---------------------------------------------------------------
-- Area music
---------------------------------------------------------------
local currentMusicSound = nil

local function PlayAreaMusic(areaIndex)
	local id = SoundConfig.AreaMusic and SoundConfig.AreaMusic[areaIndex]

	if not id or id == "" then
		if currentMusicSound and currentMusicSound.IsPlaying then
			local old = currentMusicSound; currentMusicSound = nil
			TweenService:Create(old, TweenInfo.new(1.5), { Volume = 0 }):Play()
			task.delay(1.6, function() old:Stop() end)
		end
		return
	end

	local fullId = "rbxassetid://" .. id
	if currentMusicSound and currentMusicSound.SoundId == fullId
		and currentMusicSound.IsPlaying then return end

	if currentMusicSound and currentMusicSound.IsPlaying then
		local old = currentMusicSound; currentMusicSound = nil
		TweenService:Create(old, TweenInfo.new(1.5), { Volume = 0 }):Play()
		task.delay(1.6, function() old:Stop() end)
	end

	task.delay(0.5, function()
		local s = GetOrCreateSound(id, 0, true)
		if not s then return end
		s:Play(); currentMusicSound = s
		local targetVol = musicEnabled and MUSIC_VOL or 0
		TweenService:Create(s, TweenInfo.new(1.5), { Volume = targetVol }):Play()
	end)
end

---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
task.spawn(function()
	local SettingsChanged = ReplicatedStorage:WaitForChild("SettingsChanged", 20)
	if not SettingsChanged then
		warn("[SoundManager] SettingsChanged not found — sound toggles won't work")
		return
	end

	SettingsChanged.Event:Connect(function(settingKey, isOn)
		if settingKey == "sfx" then
			sfxEnabled = isOn
			SoundGroup.Volume = isOn and 1 or 0
			if not isOn then StopLoop() end
		elseif settingKey == "music" then
			musicEnabled = isOn
			if currentMusicSound then
				if currentMusicSound.IsPlaying then
					TweenService:Create(currentMusicSound,
						TweenInfo.new(0.4), { Volume = isOn and MUSIC_VOL or 0 }):Play()
				elseif isOn then
					currentMusicSound:Play()
					TweenService:Create(currentMusicSound,
						TweenInfo.new(1.0), { Volume = MUSIC_VOL }):Play()
				end
			end
		end
	end)
end)

---------------------------------------------------------------
-- UI button hooks (main HUD buttons)
---------------------------------------------------------------
task.spawn(function()
	local mainHUD = playerGui:WaitForChild("MainHUD")

	local function HookOpen(name)
		local btn = mainHUD:WaitForChild(name, 10)
		if btn then
			btn.MouseButton1Down:Connect(function()
				Play(SoundConfig.UIOpen, Vol("ui"))
			end)
		end
	end

	HookOpen("ShopButton")
	HookOpen("StatsButton")
	HookOpen("PrestigeButton")
	HookOpen("SettingsButton")
	HookOpen("BoostsButton")
end)

---------------------------------------------------------------
-- PrestigeReady BindableEvent
---------------------------------------------------------------
task.spawn(function()
	local pr = ReplicatedStorage:WaitForChild("PrestigeReady", 30)
	if not pr then return end
	pr.Event:Connect(function()
		Play(SoundConfig.PrestigeReady, Vol("ui"))
	end)
end)

---------------------------------------------------------------
-- Game event sounds
---------------------------------------------------------------
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local AuraSpawned = RemoteEvents:WaitForChild("AuraSpawned")
AuraSpawned.OnClientEvent:Connect(function(info)
	if info.tier == "Legendary" then
		Play(SoundConfig.LegendarySpawn, Vol("mutation"))
	else
		Play(SoundConfig.Click, Vol("interaction"))
	end
end)

local CubeMutated = RemoteEvents:WaitForChild("CubeMutated")
CubeMutated.OnClientEvent:Connect(function(info)
	if info.mutationType == "tierUpgrade" then
		Play(info.tierName == "Legendary"
			and SoundConfig.LegendarySpawn or SoundConfig.TierUpgrade, Vol("mutation"))
	elseif info.mutationType == "valueBonus" then
		Play(SoundConfig.MutationBonus, Vol("mutation"))
	end
end)

local UpdateMultiplier = ReplicatedStorage:WaitForChild("UpdateMultiplier")
UpdateMultiplier.Event:Connect(function(mult)
	if mult > 1 then PlayLoop(SoundConfig.HoldLoop, Vol("interaction"))
	else StopLoop() end
end)

local ForceStopHold = RemoteEvents:WaitForChild("ForceStopHold")
ForceStopHold.OnClientEvent:Connect(function()
	StopLoop()
	Play(SoundConfig.HatcheryEmpty, Vol("interaction"))
end)

local HabitatFull = RemoteEvents:WaitForChild("HabitatFull")
HabitatFull.OnClientEvent:Connect(function()
	StopLoop()
	Play(SoundConfig.HabitatFull, Vol("interaction"))
end)

local ShipAuras = RemoteEvents:WaitForChild("ShipAuras")
ShipAuras.OnClientEvent:Connect(function(info)
	if info and info.collected then Play(SoundConfig.PlatformArrive, Vol("shipping")) end
end)

local UpgradeUpdated = RemoteEvents:WaitForChild("UpgradeUpdated")
UpgradeUpdated.OnClientEvent:Connect(function(info)
	if info.type == "purchased" then Play(SoundConfig.Purchase, Vol("mutation")) end
end)

local PrestigeComplete = RemoteEvents:WaitForChild("PrestigeComplete")
PrestigeComplete.OnClientEvent:Connect(function(info)
	StopLoop()
	if info.isPortalEntry then
		Play(SoundConfig.PortalEnter, Vol("portal"))
	else
		Play(SoundConfig.PrestigeComplete, Vol("prestige"))
	end
end)

local AreaUnlocked = RemoteEvents:WaitForChild("AreaUnlocked")
AreaUnlocked.OnClientEvent:Connect(function()
	Play(SoundConfig.PortalOpen, Vol("portal"))
end)

local AreaChanged = RemoteEvents:WaitForChild("AreaChanged")
AreaChanged.OnClientEvent:Connect(function(info)
	Play(SoundConfig.PortalEnter, Vol("portal"))
	PlayAreaMusic(info.newArea or 1)
end)

---------------------------------------------------------------
-- MENU GATE: Only the initial area music waits for the menu.
-- Everything else (SFX, event sounds, shared.PlayUISound) is live.
---------------------------------------------------------------
local AreaUpdated = RemoteEvents:WaitForChild("AreaUpdated")
local joinMusicStarted = false
AreaUpdated.OnClientEvent:Connect(function(info)
	if not joinMusicStarted then
		joinMusicStarted = true
		task.spawn(function()
			local _menuGate = ReplicatedStorage:WaitForChild("MenuDismissed")
			if not _menuGate:GetAttribute("Fired") then _menuGate.Event:Wait() end
			PlayAreaMusic(info.currentArea or 1)
		end)
	end
end)

-- TutorialController
-- Location: StarterPlayer > StarterPlayerScripts > TutorialController

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local TutorialConfig = require(ReplicatedStorage.Modules.TutorialConfig)
local UITheme = require(ReplicatedStorage.Modules.UITheme)
local T = UITheme.Get("Custom")
local C = require(ReplicatedStorage.Modules.UIConfig)
local SoundConfig = require(ReplicatedStorage.Modules.SoundConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD = playerGui:WaitForChild("MainHUD")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AreaChanged = RemoteEvents:WaitForChild("AreaChanged")
local AreaUnlocked = RemoteEvents:WaitForChild("AreaUnlocked")
local AuraSpawned = RemoteEvents:WaitForChild("AuraSpawned")
local ShipAuras = RemoteEvents:WaitForChild("ShipAuras")
local UpgradeUpdated = RemoteEvents:WaitForChild("UpgradeUpdated")
local PrestigeComplete = RemoteEvents:WaitForChild("PrestigeComplete")
local HabitatFull = RemoteEvents:WaitForChild("HabitatFull")
local UpdateHUD = RemoteEvents:WaitForChild("UpdateHUD")
local BoostUpdated = RemoteEvents:WaitForChild("BoostUpdated")
local TutorialStepComplete = RemoteEvents:WaitForChild("TutorialStepComplete", 10)

local activePointer = nil
local activeSpotlight = nil
local activeHighlight = nil
local pointerUpdate = nil

-- FORWARD DECLARATIONS
local ShowBanner = nil
local DismissBanner = nil

---------------------------------------------------------------
-- STATE
---------------------------------------------------------------
local completedSteps = {}
local tutorialComplete = false
local currentArea = 1

local liveCurrency = 0
local liveFarmEval = 0
local liveSoulAuras = 0
local liveGoldenAuras = 0
local livePrestigeCount = 0

local hasSpawnedCube = false
local hasShipped = false
local hasUpgraded = false
local hasPrestieged = false
local hasHabitatFulled = false
local hasHatcheryEmpty = false
local hasActivatedBoost = false
local hasCollectedGift = false
local hasOpenedMail = false

local areaEnterTime = tick()

---------------------------------------------------------------
-- PROGRESSIVE UI LOCKING SYSTEM
---------------------------------------------------------------
local progressiveLocks = {}
local hidden3DObjects = {}
local aggressivelyLockedUI = {}
local function ForceHideProgressiveUI(targetName)
	-- 1. 2D UI AGGRESSIVE LOCK
	local searchGui = mainHUD:FindFirstAncestorOfClass("PlayerGui") or mainHUD.Parent
	for _, desc in ipairs(searchGui:GetDescendants()) do
		if (desc.Name == targetName or desc:GetAttribute("TutorialTarget") == targetName) and desc:IsA("GuiObject") then

			if not desc:GetAttribute("OriginalSize") then
				desc:SetAttribute("OriginalSize", desc.Size)
			end

			-- Add to hit-list and hide
			aggressivelyLockedUI[desc] = true
			desc.Visible = false

			-- The Guard: Slap it back to false if the Mailbox script tries to un-hide it
			if not desc:GetAttribute("LockEnforcer") then
				desc:SetAttribute("LockEnforcer", true)
				desc:GetPropertyChangedSignal("Visible"):Connect(function()
					if aggressivelyLockedUI[desc] and desc.Visible == true then
						desc.Visible = false 
					end
				end)
			end
		end
	end

	-- 2. 3D WORKSPACE HIDE (Transparency Method)
	local wsTarget = workspace:FindFirstChild(targetName, true)
	if wsTarget then
		hidden3DObjects[targetName] = wsTarget

		local parts = wsTarget:IsA("Model") and wsTarget:GetDescendants() or {wsTarget}
		for _, desc in ipairs(parts) do
			if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
				if not desc:GetAttribute("OriginalTrans") then
					desc:SetAttribute("OriginalTrans", desc.Transparency)
				end
				desc.Transparency = 1 

				if desc:IsA("BasePart") then
					if desc:GetAttribute("OrigCollide") == nil then
						desc:SetAttribute("OrigCollide", desc.CanCollide)
					end
					desc.CanCollide = false
				end
			end
		end
	end
end

local function UnlockProgressiveUI(targetName, showEffect)
	-- 1. 2D UI UNLOCK
	local searchGui = mainHUD:FindFirstAncestorOfClass("PlayerGui") or mainHUD.Parent
	for _, desc in ipairs(searchGui:GetDescendants()) do
		if (desc.Name == targetName or desc:GetAttribute("TutorialTarget") == targetName) and desc:IsA("GuiObject") then

			-- Release the lock
			aggressivelyLockedUI[desc] = nil
			desc.Visible = true

			local targetSize = desc:GetAttribute("OriginalSize") or desc.Size 
			if showEffect then
				desc.Size = UDim2.new(0,0,0,0)

				-- ✨ THE SPEED & CLICK SHIELD FIX ✨
				-- 1. Find the actual button to temporarily disable
				local buttonToLock = desc:IsA("GuiButton") and desc or desc:FindFirstChildWhichIsA("GuiButton", true)
				if buttonToLock then 
					buttonToLock.Interactable = false 
				end

				-- 2. Lightning-fast 0.15s snappy tween instead of the slow 0.5s bounce
				local popupTween = TweenService:Create(desc, TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
				popupTween:Play()

				-- 3. Re-enable the button the exact millisecond the animation finishes
				popupTween.Completed:Connect(function()
					if buttonToLock then 
						buttonToLock.Interactable = true 
					end
				end)
			end
		end
	end

	-- 2. 3D WORKSPACE UNLOCK (Transparency Method)
	if hidden3DObjects[targetName] then
		local wsTarget = hidden3DObjects[targetName]

		local parts = wsTarget:IsA("Model") and wsTarget:GetDescendants() or {wsTarget}
		for _, desc in ipairs(parts) do
			if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
				local origTrans = desc:GetAttribute("OriginalTrans")
				desc.Transparency = origTrans ~= nil and origTrans or 0

				if desc:IsA("BasePart") then
					local origCollide = desc:GetAttribute("OrigCollide")
					desc.CanCollide = origCollide ~= nil and origCollide or true
				end
			end
		end

		hidden3DObjects[targetName] = nil 
	end
end

local function SyncProgressiveUI()
	for _, step in ipairs(TutorialConfig.Steps) do
		if step.unlockUI then
			local targets = type(step.unlockUI) == "table" and step.unlockUI or {step.unlockUI}
			if completedSteps[step.id] then
				for _, t in ipairs(targets) do UnlockProgressiveUI(t, false) end
			else
				for _, t in ipairs(targets) do ForceHideProgressiveUI(t) end
			end
		end
	end
end

---------------------------------------------------------------
-- THE GLASS WALL
---------------------------------------------------------------
local globalGlassWall = nil
local function ToggleGlassWall(enable)
	if enable then
		if not globalGlassWall then
			local pGui = mainHUD:FindFirstAncestorOfClass("PlayerGui") or mainHUD.Parent
			globalGlassWall = Instance.new("TextButton")
			globalGlassWall.Name = "TutorialGlassWall"
			globalGlassWall.Size = UDim2.new(4, 0, 4, 0)
			globalGlassWall.Position = UDim2.new(-1, 0, -1, 0)
			globalGlassWall.BackgroundTransparency = 1
			globalGlassWall.Text = ""
			globalGlassWall.ZIndex = 100000 
			globalGlassWall.Parent = pGui
		end
	else
		if globalGlassWall then
			globalGlassWall:Destroy()
			globalGlassWall = nil
		end
	end
end

---------------------------------------------------------------
-- BANNER LAYOUT & JUMBO MATH
---------------------------------------------------------------
local activeBanners = {}
local triggeredSteps = {}


local BANNER_W = (C.Banners and C.Banners.AreaBannerW or 280) + 40 
local ICON_SIZE = 48 
local BANNER_GAP = 8
local BASE_Y = mainHUD.AbsoluteSize.Y * 0.35
local SLIDE_IN = 0.4
local SLIDE_OUT = 0.3
local OFFSCREEN_X = -BANNER_W - 50
local ONSCREEN_X = 15

local TITLE_H = 28 
local TITLE_PAD_T = 12
local BODY_PAD_T = 8
local BODY_PAD_B = 26
local ICON_PAD = 10

local function CalcBannerHeight(step, isMandatory)
	local hasBody = step.body and step.body ~= ""
	local hasIcon = (step.icon or "") ~= ""

	local screenW = mainHUD.AbsoluteSize.X
	local isMobile = screenW < 800

	local actualW = isMandatory and (isMobile and 380 or 600) or BANNER_W
	local iconS = isMandatory and (isMobile and 68 or 96) or ICON_SIZE
	local titleH = isMandatory and (isMobile and 32 or 46) or TITLE_H

	if not hasBody then
		return hasIcon and (iconS + ICON_PAD * 2) or (titleH + TITLE_PAD_T * 2 + 4)
	end

	local charsPerLine = math.floor((actualW - (hasIcon and (iconS + 20) or 12) - 16) / 9)
	local bodyLen = #(step.body or "")
	local lines = math.max(1, math.ceil(bodyLen / math.max(charsPerLine, 1)))

	local bodyH = math.max(26, lines * 26)

	local total = TITLE_PAD_T + titleH + BODY_PAD_T + bodyH + BODY_PAD_B
	if hasIcon then total = math.max(total, iconS + ICON_PAD * 2) end
	return total
end

---------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------
local function PlaySound(id)
	if not id or id == "" then return end
	if shared.PlayUISound then shared.PlayUISound(id) end
end

local function IsStepComplete(id) return completedSteps[id] == true end

local function MarkComplete(id)
	if completedSteps[id] then return end
	completedSteps[id] = true
	if TutorialStepComplete then TutorialStepComplete:FireServer(id) end
end

---------------------------------------------------------------
-- CAMERA CONTROL & VISUAL POINTER
---------------------------------------------------------------
local activeBlur = nil
local currentCamera = workspace.CurrentCamera
local originalCamType = nil
local currentPanID = 0
local temporarilyHiddenMenus = {}

local function PanCameraTo(anchorName)
	currentPanID += 1
	local anchor = workspace:FindFirstChild(anchorName, true)
	if not anchor then return end

	ToggleGlassWall(true)

	temporarilyHiddenMenus = {}
	local pGui = mainHUD:FindFirstAncestorOfClass("PlayerGui") or mainHUD.Parent
	for _, desc in ipairs(pGui:GetDescendants()) do
		if desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
			if desc.Visible and desc ~= mainHUD then
				local nameLower = string.lower(desc.Name)
				local isMenu = string.find(nameLower, "menu") or string.find(nameLower, "dialog") or string.find(nameLower, "panel")
				local isGiantWindow = (desc.AbsoluteSize.X > 300 and desc.AbsoluteSize.Y > 300)

				if (isMenu or isGiantWindow) and not string.find(desc.Name, "Tutorial") then
					desc.Visible = false
					table.insert(temporarilyHiddenMenus, desc)
				end
			end
		end
	end

	if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
		originalCamType = currentCamera.CameraType
		currentCamera.CameraType = Enum.CameraType.Scriptable
	end
	TweenService:Create(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = anchor.CFrame}):Play()
end

local function ResetCamera()
	for _, menu in ipairs(temporarilyHiddenMenus) do
		if menu and menu.Parent then menu.Visible = true end
	end
	temporarilyHiddenMenus = {}

	if originalCamType then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local humanoid = char and char:FindFirstChild("Humanoid")

		if hrp and humanoid then
			local targetPos = hrp.Position + (hrp.CFrame.LookVector * -12) + Vector3.new(0, 5, 0)
			local targetCFrame = CFrame.new(targetPos, hrp.Position)
			local tweenTime = 0.8

			TweenService:Create(currentCamera, TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = targetCFrame
			}):Play()

			task.delay(tweenTime, function()
				currentCamera.CameraType = originalCamType
				currentCamera.CameraSubject = humanoid
				originalCamType = nil
			end)
		else
			currentCamera.CameraType = originalCamType
			if humanoid then currentCamera.CameraSubject = humanoid end
			originalCamType = nil
		end
	end
end

local function ClearVisuals()
	if activePointer then activePointer:Destroy(); activePointer = nil end
	if activeSpotlight then activeSpotlight:Destroy(); activeSpotlight = nil end
	if activeHighlight then activeHighlight:Destroy(); activeHighlight = nil end
	if pointerUpdate then pointerUpdate:Disconnect(); pointerUpdate = nil end

	if activeBlur then
		local blurToKill = activeBlur
		activeBlur = nil
		TweenService:Create(blurToKill, TweenInfo.new(0.3), {Size = 0}):Play()
		task.delay(0.3, function()
			if blurToKill and blurToKill.Parent then blurToKill:Destroy() end
		end)
	end
end

---------------------------------------------------------------
-- ✨ UPGRADED AUTO SCROLL (Math Fix + No Yielding)
---------------------------------------------------------------
local function AutoScrollToTarget(target)
	local scrollFrame = target:FindFirstAncestorOfClass("ScrollingFrame")
	if scrollFrame then
		local relativeY = (target.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y) + scrollFrame.CanvasPosition.Y
		local targetCanvasY = relativeY - (scrollFrame.AbsoluteSize.Y / 2) + (target.AbsoluteSize.Y / 2)

		-- ✨ MATH FIX: Must use AbsoluteCanvasSize for modern UI!
		local maxScroll = math.max(0, scrollFrame.AbsoluteCanvasSize.Y - scrollFrame.AbsoluteSize.Y)

		TweenService:Create(scrollFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(scrollFrame.CanvasPosition.X, math.clamp(targetCanvasY, 0, maxScroll))
		}):Play()
	end
end

local function ShowVisualPointer(targetName, dismissCallback, holdDuration)
	ClearVisuals()

	local target = nil
	local clickTarget = nil
	local attempts = 0
	local searchGui = mainHUD:FindFirstAncestorOfClass("PlayerGui") or mainHUD.Parent

	while not target and attempts < 60 do 
		for _, desc in ipairs(searchGui:GetDescendants()) do
			local isMatch = (desc.Name == targetName) or (desc:GetAttribute("TutorialTarget") == targetName)

			if isMatch and desc:IsA("GuiObject") then
				local isVisible = true
				local curr = desc
				while curr and curr ~= game do
					if curr:IsA("GuiObject") and not curr.Visible then 
						isVisible = false; break 
					elseif curr:IsA("LayerCollector") and not curr.Enabled then
						isVisible = false; break
					elseif curr:IsA("Folder") then 
						isVisible = false; break
					end
					curr = curr.Parent
				end

				if isVisible and desc.AbsoluteSize.Y > 0 then
					-- ✨ THE FIX: Prioritize a button named "BuyButton" so we don't accidentally target the info icon!
					clickTarget = desc:IsA("GuiButton") and desc or (desc:FindFirstChild("BuyButton", true) or desc:FindFirstChildWhichIsA("GuiButton", true))
					if clickTarget then target = desc; break end
				end
			end
		end
		if not target then task.wait(0.5); attempts += 1 end
	end

	if target and clickTarget and target:IsA("GuiObject") then

		AutoScrollToTarget(target)

		local freezeEvent = RemoteEvents:FindFirstChild("TutorialFreeze")
		if freezeEvent then freezeEvent:FireServer(true) end

		activeBlur = Instance.new("BlurEffect")
		activeBlur.Name = "TutorialBlur"
		activeBlur.Size = 0 
		activeBlur.Parent = game:GetService("Lighting")
		TweenService:Create(activeBlur, TweenInfo.new(0.5), {Size = 15}):Play()

		activeSpotlight = Instance.new("Frame")
		activeSpotlight.Name = "TutorialShield"
		activeSpotlight.Size = UDim2.new(4, 0, 4, 0)
		activeSpotlight.Position = UDim2.new(-1, 0, -1, 0)
		activeSpotlight.BackgroundColor3 = Color3.new(0, 0, 0)
		activeSpotlight.BackgroundTransparency = 1
		activeSpotlight.Active = true 
		activeSpotlight.ZIndex = 80
		activeSpotlight.Parent = mainHUD
		TweenService:Create(activeSpotlight, TweenInfo.new(0.5), {BackgroundTransparency = 0.65}):Play()

		local originalZIndex = target.ZIndex
		target.ZIndex = 90

		-- ✨ 1. Find the Main Window (StatsPanel, ShopPanel, etc.) and pull it forward!
		local rootPanel = target
		while rootPanel and rootPanel.Parent ~= mainHUD and rootPanel.Parent ~= game do
			rootPanel = rootPanel.Parent
		end

		local originalRootZ = nil
		if rootPanel and rootPanel:IsA("GuiObject") then
			originalRootZ = rootPanel.ZIndex
			rootPanel.ZIndex = 81 -- The dark shield is 80, so this puts the whole menu on top!
		end

		-- ✨ 2. Elevate the Scrolling Frame (Just to be mathematically safe)
		local scrollFrame = target:FindFirstAncestorOfClass("ScrollingFrame")
		local originalScrollZ = nil
		if scrollFrame then
			originalScrollZ = scrollFrame.ZIndex
			scrollFrame.ZIndex = 82 
		end

		-- ✨ 3. The Master Restore Function
		local function RestoreZ()
			if target then target.ZIndex = originalZIndex end
			if scrollFrame and originalScrollZ then scrollFrame.ZIndex = originalScrollZ end
			if rootPanel and originalRootZ then rootPanel.ZIndex = originalRootZ end
		end

		activeHighlight = Instance.new("Frame")
		activeHighlight.Name = "TutorialHighlight"
		activeHighlight.BackgroundColor3 = Color3.new(1, 1, 1) 
		activeHighlight.BackgroundTransparency = 0.85 
		activeHighlight.Interactable = false 
		activeHighlight.Active = false
		activeHighlight.ZIndex = 85
		activeHighlight.Parent = mainHUD

		local highlightStroke = Instance.new("UIStroke", activeHighlight)
		highlightStroke.Color = Color3.fromRGB(255, 255, 255)
		highlightStroke.Thickness = 3

		local targetCorner = target:FindFirstChildOfClass("UICorner")
		local highlightCorner = Instance.new("UICorner", activeHighlight)
		highlightCorner.CornerRadius = targetCorner and targetCorner.CornerRadius or UDim.new(0, 8)

		TweenService:Create(activeHighlight, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.65}):Play()

		activePointer = Instance.new("ImageLabel")
		activePointer.Name = "TutorialPointer"
		activePointer.Size = UDim2.new(0, 55, 0, 55)
		activePointer.BackgroundTransparency = 1
		activePointer.Image = "rbxassetid://14922084401"
		activePointer.ZIndex = 100
		activePointer.AnchorPoint = Vector2.new(0.5, 1)
		activePointer.Parent = mainHUD

		-- ✨ THE RE-SCROLL WATCHDOG SETUP
		local scrollFrame = target:FindFirstAncestorOfClass("ScrollingFrame")
		local isAutoScrolling = false

		pointerUpdate = RunService.RenderStepped:Connect(function()
			if not activePointer or not activeHighlight or not target or not target.Parent then
				ClearVisuals()
				RestoreZ() -- ✨ FIX: Restores both the target and the scroll frame!
				return
			end

			-- ✨ WATCHDOG LOGIC: Check if the button was pushed out of view!
			if scrollFrame and not isAutoScrolling then
				local targetY = target.AbsolutePosition.Y
				local scrollY = scrollFrame.AbsolutePosition.Y
				local scrollBottom = scrollY + scrollFrame.AbsoluteSize.Y

				-- Is the target entirely outside the visible scroll window?
				if (targetY + target.AbsoluteSize.Y < scrollY) or (targetY > scrollBottom) then

					-- Verify the menu is actually open before forcing a scroll
					local isMenuOpen = true
					local curr = target
					while curr and curr ~= game do
						if curr:IsA("GuiObject") and not curr.Visible then isMenuOpen = false; break end
						curr = curr.Parent
					end

					if isMenuOpen then
						isAutoScrolling = true
						AutoScrollToTarget(target)
						task.delay(0.5, function() isAutoScrolling = false end)
					end
				end
			end

			-- Update Highlight & Pointer Positions
			local tgtRelX = target.AbsolutePosition.X - mainHUD.AbsolutePosition.X
			local tgtRelY = target.AbsolutePosition.Y - mainHUD.AbsolutePosition.Y
			activeHighlight.Size = UDim2.new(0, target.AbsoluteSize.X + 8, 0, target.AbsoluteSize.Y + 8)
			activeHighlight.Position = UDim2.new(0, tgtRelX - 4, 0, tgtRelY - 4)

			local btnRelX = clickTarget.AbsolutePosition.X - mainHUD.AbsolutePosition.X
			local btnRelY = clickTarget.AbsolutePosition.Y - mainHUD.AbsolutePosition.Y
			local btnCenterX = btnRelX + (clickTarget.AbsoluteSize.X / 2)
			local bounceOffset = math.abs(math.sin(tick() * 5)) * 15

			activePointer.Position = UDim2.new(0, btnCenterX, 0, btnRelY - 5 - bounceOffset)
		end)

		if dismissCallback then
			if holdDuration and holdDuration > 0 then
				local holdAttempt = 0
				local uisConns = {}

				local function startHold()
					holdAttempt += 1
					local currentAttempt = holdAttempt
					task.delay(holdDuration, function()
						if holdAttempt == currentAttempt then
							holdAttempt = 0 
							for _, c in ipairs(uisConns) do c:Disconnect() end
							ToggleGlassWall(true)
							ClearVisuals() 
							RestoreZ() -- ✨ FIX

							if freezeEvent then freezeEvent:FireServer(false) end

							dismissCallback() 
						end
					end)
				end

				local function cancelHold() holdAttempt += 1 end

				clickTarget.MouseButton1Down:Connect(startHold)
				clickTarget.MouseButton1Up:Connect(cancelHold)
				clickTarget.MouseLeave:Connect(cancelHold)

				table.insert(uisConns, UserInputService.InputBegan:Connect(function(input, gpe)
					if input.KeyCode == Enum.KeyCode.Space and not gpe then startHold() end
				end))
				table.insert(uisConns, UserInputService.InputEnded:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space then cancelHold() end
				end))

				if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
					startHold()
				end
			else
				local clickConn, uisConn
				local function completeClick()
					if clickConn then clickConn:Disconnect() end
					if uisConn then uisConn:Disconnect() end
					ToggleGlassWall(true) 
					ClearVisuals() 
					RestoreZ() -- ✨ FIX

					if freezeEvent then freezeEvent:FireServer(false) end

					dismissCallback() 
				end

				clickConn = clickTarget.MouseButton1Down:Connect(completeClick)
				uisConn = UserInputService.InputBegan:Connect(function(input, gpe)
					if input.KeyCode == Enum.KeyCode.Space and not gpe then completeClick() end
				end)
			end
		end
	else
		warn("Tutorial Error: Target '"..targetName.."' not found after waiting!")
	end
end

---------------------------------------------------------------
-- REFLOW & DISMISS
---------------------------------------------------------------
local function ReflowBanners()
	local yOffset = 0
	for _, entry in ipairs(activeBanners) do
		if not entry.dismissed and not entry.isMandatory and entry.frame and entry.frame.Parent then
			local targetY = BASE_Y + yOffset
			TweenService:Create(entry.frame,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = UDim2.new(0, ONSCREEN_X, 0, targetY) }):Play()
			entry.currentY = targetY
			yOffset += entry.height + BANNER_GAP
		end
	end
end

DismissBanner = function(entry)
	if entry.dismissed then return end
	entry.dismissed = true
	local offscreenPos
	if entry.isMandatory and entry.frame then
		offscreenPos = UDim2.new(0.5, -(entry.frame.Size.X.Offset / 2), 0, -entry.height - 50)
	else
		offscreenPos = UDim2.new(0, OFFSCREEN_X, 0, entry.currentY or BASE_Y)
	end
	TweenService:Create(entry.frame, TweenInfo.new(SLIDE_OUT, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = offscreenPos }):Play()

	if entry.panID then
		local resetDelay = entry.step.cameraResetDelay or 0
		task.delay(resetDelay, function()
			if currentPanID == entry.panID then
				ResetCamera()
			end
		end)
	end

	task.delay(SLIDE_OUT + 0.1, function()
		if entry.frame and entry.frame.Parent then entry.frame:Destroy() end
		for i, e in ipairs(activeBanners) do
			if e == entry then table.remove(activeBanners, i); break end
		end
		ReflowBanners()
		if entry.step.nextStep and entry.step.nextStep ~= "" then
			local nextData = TutorialConfig.GetStep(entry.step.nextStep)
			if nextData and not triggeredSteps[entry.step.nextStep] then
				task.delay(entry.step.chainDelay or 0.5, function() ShowBanner(nextData) end)
			else
				ToggleGlassWall(false)
			end
		else
			ToggleGlassWall(false)
		end
	end)
end

---------------------------------------------------------------
-- SHOW BANNER
---------------------------------------------------------------
ShowBanner = function(step)
	if triggeredSteps[step.id] then return end
	triggeredSteps[step.id] = true

	if step.unlockUI then
		local targets = type(step.unlockUI) == "table" and step.unlockUI or {step.unlockUI}
		for _, t in ipairs(targets) do UnlockProgressiveUI(t, true) end
	end

	local isMandatory = step.isMandatory == true

	-- THE FIX: If it is mandatory, wait forever (0). Otherwise, use the step duration or default!
	local duration = 0
	if step.duration ~= nil then
		duration = step.duration
	elseif not isMandatory then
		duration = TutorialConfig.DefaultDuration or 8
	end

	local color = step.color or TutorialConfig.DefaultColor or T.accentTeal
	local iconId = step.icon or TutorialConfig.DefaultIcon or ""
	local hasBody = step.body and step.body ~= ""
	local hasIcon = iconId ~= ""

	if step.cameraPan and step.cameraPan ~= "" then
		PanCameraTo(step.cameraPan)
	end

	local screenW = mainHUD.AbsoluteSize.X
	local isMobile = screenW < 800
	local targetX = isMobile and (ONSCREEN_X + 45) or ONSCREEN_X
	local actualW = isMandatory and (isMobile and 380 or 600) or BANNER_W
	local iconS = isMandatory and (isMobile and 68 or 96) or ICON_SIZE
	local titleH = isMandatory and (isMobile and 32 or 46) or TITLE_H
	local bannerH = CalcBannerHeight(step, isMandatory)

	local currentBaseY = mainHUD.AbsoluteSize.Y * 0.35
	local yOffset = 0
	for _, e in ipairs(activeBanners) do
		if not e.dismissed and not e.isMandatory then yOffset += e.height + BANNER_GAP end
	end
	local targetY = currentBaseY + yOffset

	local entry = { step = step, height = bannerH, currentY = targetY, dismissed = false, isMandatory = isMandatory }

	if step.freezeGame then
		local freezeEvent = RemoteEvents:FindFirstChild("TutorialFreeze")
		if freezeEvent then freezeEvent:FireServer(true) end
	end

	local function triggerDismiss()
		if step.freezeGame then
			local freezeEvent = RemoteEvents:FindFirstChild("TutorialFreeze")
			if freezeEvent then freezeEvent:FireServer(false) end
		end
		MarkComplete(step.id)
		DismissBanner(entry) 
	end

	if step.target and step.target ~= "" then
		ShowVisualPointer(step.target, triggerDismiss, step.holdDuration)
	end

	if step.cameraTarget and step.cameraTarget ~= "" then
		local posPart = workspace:FindFirstChild(step.cameraTarget, true)
		if posPart and posPart:IsA("BasePart") then
			local currentPanID = os.clock()
			entry.panID = currentPanID
			local camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Scriptable
			TweenService:Create(camera, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = posPart.CFrame}):Play()

			-- ✨ THE AUTO-RESET FIX
			if step.cameraResetDelay and step.cameraResetDelay > 0 then
				task.delay(step.cameraResetDelay, function()
					-- Ensure we are still looking at THIS specific target
					if entry.panID == currentPanID then
						workspace.CurrentCamera.CameraType = Enum.CameraType.Custom -- Reset Camera

						-- If it's mandatory but has no button to click, auto-dismiss to unstick the player
						if step.isMandatory and (not step.target or step.target == "") then
							MarkComplete(step.id)
							DismissBanner(entry)
						end
					end
				end)
			end
		end
		if step.burstAuras and type(step.burstAuras) == "number" then
			local burstEvent = RemoteEvents:FindFirstChild("TutorialBurst")
			if burstEvent then
				burstEvent:FireServer(step.burstAuras)
			else
				warn("Tutorial: Please create a RemoteEvent named 'TutorialBurst' in ReplicatedStorage.RemoteEvents!")
			end
		end
	end

	-- ✨ THE FIX: Changed from TextButton to Frame with Active = false!
	local banner = Instance.new("Frame")
	banner.Name = "TutorialBanner_" .. step.id
	banner.Size = UDim2.new(0, actualW, 0, bannerH)
	banner.Active = false -- ✨ CRITICAL: Lets clicks pass through the banner to the UI underneath!
	banner.ZIndex = 95; banner.ClipsDescendants = false; banner.Parent = mainHUD
	UITheme.Apply(banner, "Panel")

	local bgGrad = Instance.new("UIGradient", banner)
	bgGrad.Rotation = 90
	bgGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })

	local stroke = banner:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = color; stroke.Thickness = 1.5; stroke.Transparency = 0.2
		local strokeGrad = Instance.new("UIGradient", stroke)
		strokeGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, color) })
		strokeGrad.Rotation = 45
	end

	local textX = hasIcon and (iconS + 20) or 14
	local textW = actualW - textX - 14

	if hasIcon then
		local iconFrame = Instance.new("Frame")
		iconFrame.Size = UDim2.new(0, iconS + 8, 0, iconS + 8)
		iconFrame.Position = UDim2.new(0, 6, 0.5, -(iconS + 8)/2)
		iconFrame.BackgroundColor3 = color; iconFrame.BackgroundTransparency = 0.8
		iconFrame.BorderSizePixel = 0; iconFrame.ZIndex = 96; iconFrame.Parent = banner
		Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 8)

		local iconStroke = Instance.new("UIStroke", iconFrame)
		iconStroke.Color = color; iconStroke.Transparency = 0.4; iconStroke.Thickness = 1.2

		local iconImg = Instance.new("ImageLabel")
		iconImg.Size = UDim2.new(0, iconS, 0, iconS)
		iconImg.Position = UDim2.new(0.5, -iconS/2, 0.5, -iconS/2)
		iconImg.BackgroundTransparency = 1; iconImg.Image = iconId
		iconImg.ScaleType = Enum.ScaleType.Fit; iconImg.ZIndex = 97; iconImg.Parent = iconFrame
	end

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, textW, 0, titleH)
	titleLabel.Position = UDim2.new(0, textX, 0, hasBody and TITLE_PAD_T or (bannerH/2 - titleH/2))
	titleLabel.BackgroundTransparency = 1; titleLabel.Text = step.title or ""
	titleLabel.TextColor3 = color; titleLabel.TextScaled = true; titleLabel.Font = T.font; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 96; titleLabel.Parent = banner

	local titleShadow = titleLabel:Clone()
	titleShadow.TextColor3 = Color3.new(0,0,0); titleShadow.TextTransparency = 0.5
	titleShadow.Position = UDim2.new(0, textX + 1, 0, (hasBody and TITLE_PAD_T or (bannerH/2 - titleH/2)) + 1)
	titleShadow.ZIndex = 95; titleShadow.Parent = banner

	if hasBody then
		local bodyTop = TITLE_PAD_T + titleH + BODY_PAD_T
		local bodyH = bannerH - bodyTop - BODY_PAD_B
		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.Size = UDim2.new(0, textW, 0, bodyH)
		bodyLabel.Position = UDim2.new(0, textX, 0, bodyTop)
		bodyLabel.BackgroundTransparency = 1; bodyLabel.Text = step.body
		bodyLabel.TextColor3 = T.bodyText; bodyLabel.TextScaled = true; bodyLabel.Font = T.fontBody; bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
		bodyLabel.TextWrapped = true; bodyLabel.ZIndex = 96; bodyLabel.Parent = banner
	end

	if not isMandatory or (isMandatory and (not step.target or step.target == "")) then
		-- ✨ ADDED: An invisible click-catcher only when the banner is meant to be dismissable!
		local clickCatcher = Instance.new("TextButton")
		clickCatcher.Size = UDim2.new(1, 0, 1, 0)
		clickCatcher.BackgroundTransparency = 1
		clickCatcher.Text = ""
		clickCatcher.ZIndex = 99
		clickCatcher.Parent = banner

		clickCatcher.MouseButton1Down:Connect(function()
			ToggleGlassWall(true)
			triggerDismiss()
		end)

		if not isMandatory then
			local hintLabel = Instance.new("TextLabel")
			hintLabel.Size = UDim2.new(0, 80, 0, 12)
			hintLabel.Position = UDim2.new(1, -86, 1, -14)
			hintLabel.BackgroundTransparency = 1; hintLabel.Text = "tap to dismiss"
			hintLabel.TextColor3 = T.subText; hintLabel.TextScaled = true; hintLabel.Font = T.fontBody; hintLabel.TextXAlignment = Enum.TextXAlignment.Right
			hintLabel.ZIndex = 96; hintLabel.Parent = banner
			TweenService:Create(hintLabel, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextTransparency = 0.7}):Play()
		end
	end

	if duration > 0 then
		task.delay(duration, function()
			ToggleGlassWall(true)
			triggerDismiss()
		end)
	end

	entry.frame = banner
	table.insert(activeBanners, entry)

	local snd = step.sound or SoundConfig.TutorialHint or ""
	PlaySound(snd)

	if isMandatory then
		local targetPos
		if step.bannerPos == "Top" then
			targetPos = UDim2.new(0.5, -actualW/2, 0, 40)
		elseif step.bannerPos == "Center" then
			targetPos = UDim2.new(0.5, -actualW/2, 0.5, -bannerH/2)
		else
			if step.target and step.target ~= "" then
				targetPos = UDim2.new(0.5, -actualW/2, 0, 40)
			else
				targetPos = UDim2.new(0.5, -actualW/2, 0.5, -bannerH/2)
			end
		end
		banner.Position = UDim2.new(0.5, -actualW/2, 0, -bannerH - 50)
		TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = targetPos }):Play()
	else
		banner.Position = UDim2.new(0, OFFSCREEN_X, 0, targetY)
		TweenService:Create(banner, TweenInfo.new(SLIDE_IN, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, targetX, 0, targetY)
		}):Play()
	end
	ToggleGlassWall(false)
end

---------------------------------------------------------------
-- TRIGGER SYSTEM
---------------------------------------------------------------
local function FireTrigger(triggerName, value)
	if tutorialComplete then return end
	if not mainHUD.Enabled then return end 

	-- THE ULTIMATE OVERLAP FIX: One banner at a time!
	if triggerName ~= "chain" then
		for _, entry in ipairs(activeBanners) do
			if not entry.dismissed then return end
		end
	end

	for _, step in ipairs(TutorialConfig.Steps) do
		if step.trigger == triggerName and not IsStepComplete(step.id) then

			-- Area Lock
			if step.area and step.area ~= currentArea then
				continue
			end

			-- Prestige Lock (FIXED: Now checks actual stats instead of a hardcoded step name)
			if step.requirePrestige and livePrestigeCount <= 0 and not hasPrestieged then
				continue
			end

			-- Sequence Lock
			if step.requireStep and not IsStepComplete(step.requireStep) then
				continue
			end

			-- Normal trigger value checking
			if step.triggerValue ~= nil then
				if type(value) == "number" and value >= step.triggerValue then
					ShowBanner(step)
				end
			else
				ShowBanner(step)
			end

		end
	end
end

local ManualTrigger = Instance.new("BindableEvent")
ManualTrigger.Name = "TutorialTrigger"; ManualTrigger.Parent = ReplicatedStorage
ManualTrigger.Event:Connect(function(stepId)
	if tutorialComplete then return end
	local step = TutorialConfig.GetStep(stepId)
	if step then
		MarkComplete(step.id)
		task.delay(step.delay or TutorialConfig.DefaultDelay, function() ShowBanner(step) end)
	end
end)
shared.FireTutorial = function(stepId) ManualTrigger:Fire(stepId) end

task.spawn(function()
	while true do
		task.wait(1)

		if tutorialComplete then continue end
		if not mainHUD.Enabled then continue end

		FireTrigger("areaEnter", currentArea)
		FireTrigger("farmEvalReached", liveFarmEval)
		FireTrigger("currencyReached", liveCurrency)
		FireTrigger("soulAurasReached", liveSoulAuras)

		-- THE FIX: Continually re-fire one-time events if they were blocked!
		if hasSpawnedCube then FireTrigger("firstCube") end
		if hasShipped then FireTrigger("firstShip") end
		if hasUpgraded then FireTrigger("firstUpgrade") end
		if hasPrestieged then FireTrigger("firstPrestige") end
		if hasHabitatFulled then FireTrigger("habitatFull") end
		if hasActivatedBoost then FireTrigger("boostActivated") end
		if hasCollectedGift then FireTrigger("giftCollected") end
		if hasOpenedMail then FireTrigger("mailOpened") end

		FireTrigger("timerElapsed", tick() - areaEnterTime)
	end
end)
---------------------------------------------------------------
-- EVENT LISTENERS
---------------------------------------------------------------
AreaChanged.OnClientEvent:Connect(function(info)
	currentArea = info.newArea or currentArea
	areaEnterTime = tick()
	hasSpawnedCube = false; hasShipped = false; hasUpgraded = false
	hasHabitatFulled = false; hasHatcheryEmpty = false
	hasActivatedBoost = false; hasCollectedGift = false; hasOpenedMail = false

	if info.isPortalEntry and currentArea > TutorialConfig.TutorialEndArea and not tutorialComplete then
		tutorialComplete = true
		if TutorialStepComplete then TutorialStepComplete:FireServer("__tutorialComplete__") end
	end
	task.delay(0.5, function()
		if SyncProgressiveUI then SyncProgressiveUI() end
		FireTrigger("areaEnter", currentArea)
	end)
end)

AuraSpawned.OnClientEvent:Connect(function()
	if not hasSpawnedCube then hasSpawnedCube = true; FireTrigger("firstCube") end
end)

ShipAuras.OnClientEvent:Connect(function()
	if not hasShipped then hasShipped = true; FireTrigger("firstShip") end
end)

UpgradeUpdated.OnClientEvent:Connect(function(info)
	if info.type == "purchased" then
		if not hasUpgraded then hasUpgraded = true; FireTrigger("firstUpgrade") end
		if info.level then FireTrigger("upgradeLevel", info.level) end
	end
end)

PrestigeComplete.OnClientEvent:Connect(function(info)
	if not info.isPortalEntry then
		if not hasPrestieged then hasPrestieged = true; FireTrigger("firstPrestige") end
		if info.prestigeCount then
			livePrestigeCount = info.prestigeCount
			FireTrigger("prestigeCount", livePrestigeCount)
		end
	end
end)

HabitatFull.OnClientEvent:Connect(function()
	if not hasHabitatFulled then hasHabitatFulled = true; FireTrigger("habitatFull") end
end)

AreaUnlocked.OnClientEvent:Connect(function() FireTrigger("portalReady") end)

BoostUpdated.OnClientEvent:Connect(function(info)
	if info and info.activated then
		if not hasActivatedBoost then hasActivatedBoost = true; FireTrigger("boostActivated") end
	end
end)

shared.OnPhysicsAuraCollected = function()
	if not hasCollectedGift then hasCollectedGift = true; FireTrigger("giftCollected") end
end

shared.OnMailOpened = function()
	if not hasOpenedMail then hasOpenedMail = true; FireTrigger("mailOpened") end
end

UpdateHUD.OnClientEvent:Connect(function(stats)
	if stats.tutorialProgress then
		for id, v in pairs(stats.tutorialProgress) do if v then completedSteps[id] = true end end
		SyncProgressiveUI()
	end
	if stats.tutorialComplete ~= nil then tutorialComplete = stats.tutorialComplete end
	if stats.currentArea then currentArea = stats.currentArea end

	-- ✨ FIX THESE TWO LINES: Map to the correct local variables!
	if stats.hasPrestigedThisArea ~= nil then hasPrestieged = stats.hasPrestigedThisArea end
	if stats.prestigeCount ~= nil then livePrestigeCount = stats.prestigeCount end

	if stats.currency ~= nil then
		local old = liveCurrency; liveCurrency = stats.currency
		if liveCurrency > old then FireTrigger("currencyReached", liveCurrency) end
	end
	if stats.farmEvaluation ~= nil then
		local old = liveFarmEval; liveFarmEval = stats.farmEvaluation
		if liveFarmEval > old then FireTrigger("farmEvalReached", liveFarmEval) end
	end
	if stats.soulAuras ~= nil then
		local old = liveSoulAuras; liveSoulAuras = stats.soulAuras
		if liveSoulAuras > old then FireTrigger("soulAurasReached", liveSoulAuras) end
	end
	if stats.goldenAuras ~= nil then
		local old = liveGoldenAuras; liveGoldenAuras = stats.goldenAuras
		if liveGoldenAuras > old then FireTrigger("goldenAurasReached", liveGoldenAuras) end
	end
end)

local joinFired = false
RemoteEvents:WaitForChild("AreaUpdated").OnClientEvent:Connect(function(info)
	if not joinFired then
		joinFired = true; currentArea = info.currentArea or 1; areaEnterTime = tick()
		task.delay(2, function() FireTrigger("areaEnter", currentArea) end)
	end
end)

---------------------------------------------------------------
-- STARTUP INITIALIZATION
---------------------------------------------------------------
task.spawn(function()
	task.wait(1)
	if SyncProgressiveUI then SyncProgressiveUI() end
end)





-- UIController
-- Location: StarterPlayer > StarterPlayerScripts > UIController

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Debris            = game:GetService("Debris")
local UserInputService  = game:GetService("UserInputService") 
local AdminConfig       = require(ReplicatedStorage.Modules.AdminConfig)
local Formatter         = require(ReplicatedStorage.Modules.NumberFormatter)
local UITheme           = require(ReplicatedStorage.Modules.UITheme)

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UpdateHUD = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHUD")
local ShipAuras = ReplicatedStorage.RemoteEvents:WaitForChild("ShipAuras")
local HabitatFull = ReplicatedStorage.RemoteEvents:WaitForChild("HabitatFull")
local UpdateHatchery = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateHatchery")
local mainHUD   = playerGui:WaitForChild("MainHUD")

local isAutoMode          = AdminConfig.AutoDispatch
local HabitatHolder       = workspace:WaitForChild("HabitatHolder")
local GoldenAurasLabel    = mainHUD:WaitForChild("GoldenAurasLabel")

local serverCurrency      = 0
local prevServerCurrency  = 0
local displayedCurrency   = 0
local ratePerSecond       = 0
local pendingAuras        = 0
local habitatCapacity     = AdminConfig.BaseHabitatCapacity
local passiveInterval     = AdminConfig.PassiveInterval
local currentCooldownTime = 15
local isShipOnCooldown    = false
local sharedCooldownEnd   = 0
local manualCooldownLoopID = 0
local lastSpendTick       = 0
local liveGoldenAuras     = 0
local autoLoopID          = 0

local currentHatcheryLevel = AdminConfig.HatcheryMax or 150 

-- [FIXED] Bypass math.floor so the formatter handles decimals properly
local function FormatNumber(n) return Formatter.Format(n) end

-- ─────────────────────────────────────────────────────────────────────────────
-- ✨ SYNCING VISUAL CASH & AURA TICK UP ✨
-- ─────────────────────────────────────────────────────────────────────────────
player:GetAttributeChangedSignal("VisualCashToAdd"):Connect(function()
	local addAmount = player:GetAttribute("VisualCashToAdd") or 0
	if addAmount > 0 then
		displayedCurrency += addAmount
		player:SetAttribute("VisualCashToAdd", 0) 
	end
end)

player:GetAttributeChangedSignal("VisualAurasToAdd"):Connect(function()
	local addAmount = player:GetAttribute("VisualAurasToAdd") or 0
	if addAmount > 0 then
		liveGoldenAuras += addAmount
		GoldenAurasLabel.Text = "GAURAS: " .. FormatNumber(liveGoldenAuras) 
		player:SetAttribute("VisualAurasToAdd", 0) 
	end
end)

player:GetAttributeChangedSignal("LocalSpend"):Connect(function()
	local spend = player:GetAttribute("LocalSpend") or 0
	if spend > 0 then
		displayedCurrency = math.max(0, displayedCurrency - spend)
		lastSpendTick = tick()
		player:SetAttribute("LocalSpend", 0)
	end
end)

player:GetAttributeChangedSignal("LocalAuraSpend"):Connect(function()
	local spend = player:GetAttribute("LocalAuraSpend") or 0
	if spend > 0 then
		liveGoldenAuras = math.max(0, (liveGoldenAuras or 0) - spend)
		GoldenAurasLabel.Text = "GAURAS: " .. FormatNumber(liveGoldenAuras) 
		lastSpendTick = tick()
		player:SetAttribute("LocalAuraSpend", 0)
	end
end)

player:GetAttributeChangedSignal("ForceSyncCurrency"):Connect(function()
	local serverValue = player:GetAttribute("ForceSyncCurrency")
	if serverValue and serverValue > 0 then
		displayedCurrency = serverValue
		player:SetAttribute("ForceSyncCurrency", 0)
	end
end)

local function FormatRate(perSecond)
	if perSecond <= 0 then return "$0/sec" end
	return "$" .. Formatter.Format(perSecond) .. "/sec"
end

local function GetRateColor(pending, capacity)
	local ratio = math.clamp((pending or 0) / (capacity or 50), 0, 1)
	if ratio >= 1        then return Color3.fromRGB(255, 60,  60)
	elseif ratio >= 0.75 then return Color3.fromRGB(255, 200,  0)
	elseif ratio >= 0.5  then return Color3.fromRGB(80,  255, 80)
	else                      return Color3.fromRGB(80,  180, 80)
	end
end

local function UpdateHabitatBar(pending, capacity)
	local ratio    = math.clamp((pending or 0) / (capacity or 50), 0, 1)
	local color    = GetRateColor(pending, capacity)
	local model    = HabitatHolder:FindFirstChild("HabitatModel")
	if model then
		local gui    = model:FindFirstChild("HabitatGui")
		local barBg  = gui and gui:FindFirstChild("BarBackground")
		local barFill = barBg and barBg:FindFirstChild("BarFill")
		if barFill then
			TweenService:Create(barFill, TweenInfo.new(0.3), {
				Size = UDim2.new(ratio, 0, 1, 0),
				BackgroundColor3 = color,
			}):Play()
		end
	end
end

local hud        = playerGui:WaitForChild("MainHUD")
local curr       = hud:WaitForChild("CurrencyLabel")
local rate       = hud:WaitForChild("RateLabel")
local sendButton = hud:WaitForChild("SendButton")
local modeToggle = hud:WaitForChild("ModeToggle")

-- ─────────────────────────────────────────────────────────────────────────────
-- ✨ WARNING POPUP SYSTEM
-- ─────────────────────────────────────────────────────────────────────────────
local activeAlerts = {}

local function ShowAlertPopup(alertType, text, iconColor)
	if tick() - (activeAlerts[alertType] or 0) < 2.5 then return end
	activeAlerts[alertType] = tick()

	local ratePos = rate.AbsolutePosition
	local rateSize = rate.AbsoluteSize

	local alertW = 200
	local alertH = 40
	local padding = 15

	local endX = ratePos.X - padding
	local startX = endX + 40
	local startY = ratePos.Y + (rateSize.Y / 2)

	local effectGui = Instance.new("ScreenGui")
	effectGui.Name = "AlertGui_" .. alertType
	effectGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	effectGui.Parent = playerGui

	local alertFrame = Instance.new("Frame")
	alertFrame.Size = UDim2.new(0, alertW, 0, alertH)
	alertFrame.AnchorPoint = Vector2.new(1, 0.5)
	alertFrame.Position = UDim2.new(0, startX, 0, startY)
	alertFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	alertFrame.BorderSizePixel = 0
	alertFrame.BackgroundTransparency = 1 
	alertFrame.Parent = effectGui

	local corner = Instance.new("UICorner", alertFrame)
	corner.CornerRadius = UDim.new(0.5, 0)

	local stroke = Instance.new("UIStroke", alertFrame)
	stroke.Color = iconColor
	stroke.Thickness = 2
	stroke.Transparency = 1

	local icon = Instance.new("ImageLabel", alertFrame)
	icon.Size = UDim2.new(0, 20, 0, 20)
	icon.Position = UDim2.new(0, 10, 0.5, -10)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://7733658504" 
	icon.ImageColor3 = iconColor
	icon.ImageTransparency = 1

	local msg = Instance.new("TextLabel", alertFrame)
	msg.Size = UDim2.new(1, -40, 1, 0)
	msg.Position = UDim2.new(0, 35, 0, 0)
	msg.BackgroundTransparency = 1
	msg.Text = text
	msg.TextColor3 = iconColor
	msg.Font = Enum.Font.GothamBold
	msg.TextScaled = true
	msg.TextTransparency = 1
	msg.TextXAlignment = Enum.TextXAlignment.Left

	local uipadding = Instance.new("UIPadding", msg)
	uipadding.PaddingTop = UDim.new(0, 6)
	uipadding.PaddingBottom = UDim.new(0, 6)

	local sfxFolder = ReplicatedStorage:FindFirstChild("SFX") or ReplicatedStorage:FindFirstChild("Sounds")
	if sfxFolder and sfxFolder:FindFirstChild("ErrorBuzz") then
		local sfx = sfxFolder.ErrorBuzz:Clone()
		sfx.Parent = game:GetService("SoundService")
		sfx.Volume = 0.5
		sfx:Play()
		Debris:AddItem(sfx, 2)
	end

	TweenService:Create(alertFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, endX, 0, startY),
		BackgroundTransparency = 0.1
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
	TweenService:Create(icon, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
	TweenService:Create(msg, TweenInfo.new(0.4), {TextTransparency = 0}):Play()

	task.delay(2, function()
		if not alertFrame.Parent then return end
		TweenService:Create(alertFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Position = UDim2.new(0, startX, 0, startY),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
		TweenService:Create(icon, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
		TweenService:Create(msg, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		Debris:AddItem(effectGui, 0.4)
	end)
end

HabitatFull.OnClientEvent:Connect(function()
	ShowAlertPopup("HabitatFull", "HABITAT FULL!", Color3.fromRGB(255, 80, 80))
end)

UpdateHatchery.OnClientEvent:Connect(function(info)
	currentHatcheryLevel = info.current
	if info.current <= 0 then
		ShowAlertPopup("HatcheryEmpty", "HATCHERY EMPTY!", Color3.fromRGB(255, 180, 50))
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

		local clickedMainButton = false
		if gameProcessed then
			local guis = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
			for _, gui in ipairs(guis) do
				if gui.Name == "ClickButton" then
					clickedMainButton = true
					break
				end
			end
		end

		if not clickedMainButton then return end

		if currentHatcheryLevel <= 0.5 then
			ShowAlertPopup("HatcheryEmpty", "HATCHERY EMPTY!", Color3.fromRGB(255, 180, 50))
		elseif pendingAuras >= habitatCapacity then
			ShowAlertPopup("HabitatFull", "HABITAT FULL!", Color3.fromRGB(255, 80, 80))
		end
	end
end)

local function SyncManualCooldownVisuals()
	if isAutoMode or not sendButton.Visible then return end

	local progressContainer = sendButton:FindFirstChild("CooldownProgress")
	local fillPart          = progressContainer and progressContainer:FindFirstChild("Fill")
	local textTarget        = sendButton:FindFirstChildOfClass("TextLabel") or sendButton

	local uiStroke = sendButton:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", sendButton)
	uiStroke.Thickness = 1.5

	if not fillPart then return end

	sendButton.ClipsDescendants = true
	progressContainer.Size     = UDim2.new(1, 0, 1, 0)
	progressContainer.Position = UDim2.new(0, 0, 0, 0)
	progressContainer.AnchorPoint = Vector2.new(0, 0)

	fillPart.BorderSizePixel = 0
	fillPart.AnchorPoint     = Vector2.new(0, 1)
	fillPart.Position        = UDim2.new(0, 0, 1, 0)
	for _, child in ipairs(fillPart:GetChildren()) do
		if child:IsA("UICorner") or child:IsA("UIAspectRatioConstraint") or child:IsA("UIStroke") then
			child:Destroy()
		end
	end

	manualCooldownLoopID += 1
	local currentLoop = manualCooldownLoopID
	local timeLeft    = sharedCooldownEnd - tick()

	sendButton.BackgroundColor3    = Color3.fromRGB(0, 160, 255)
	uiStroke.Color                 = Color3.fromRGB(0, 220, 255)
	fillPart.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
	fillPart.BackgroundTransparency = 0.55

	if timeLeft > 0 then
		isShipOnCooldown = true
		if textTarget ~= sendButton then sendButton.Text = "" end

		task.spawn(function()
			while timeLeft > 0 and manualCooldownLoopID == currentLoop do
				local pct = timeLeft / currentCooldownTime
				TweenService:Create(fillPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					Size = UDim2.new(1, 0, pct, 0)
				}):Play()
				task.wait(0.1)
				timeLeft = sharedCooldownEnd - tick()
			end

			if manualCooldownLoopID == currentLoop then
				isShipOnCooldown  = false
				textTarget.Text   = ""
				fillPart.Size     = UDim2.new(1, 0, 0, 0)
			end
		end)
	else
		isShipOnCooldown = false
		textTarget.Text  = ""
		fillPart.Size    = UDim2.new(1, 0, 0, 0)
	end
end

local function UpdateSendButton()
	if AdminConfig.DisableShipping then sendButton.Visible = false; return end
	sendButton.Visible = not isAutoMode and (pendingAuras or 0) > 0
	if sendButton.Visible then
		SyncManualCooldownVisuals()
	end
end

local autoProgressContainer = Instance.new("Frame")
autoProgressContainer.Name             = "AutoProgressContainer"
autoProgressContainer.Size             = UDim2.new(0, 12, 1, 0)
autoProgressContainer.Position         = UDim2.new(1, 8, 0, 0)
autoProgressContainer.BackgroundColor3 = Color3.fromRGB(24, 60, 24)
autoProgressContainer.BorderSizePixel  = 0
autoProgressContainer.Visible          = false
autoProgressContainer.Parent           = modeToggle
Instance.new("UICorner", autoProgressContainer).CornerRadius = UDim.new(0.5, 0)

local autoStroke = Instance.new("UIStroke")
autoStroke.Color     = Color3.fromRGB(0, 255, 128)
autoStroke.Thickness = 1.5
autoStroke.Parent    = autoProgressContainer

local autoFillClip = Instance.new("Frame")
autoFillClip.Size                 = UDim2.new(1, 0, 1, 0)
autoFillClip.BackgroundTransparency = 1
autoFillClip.ClipsDescendants     = true
autoFillClip.Parent               = autoProgressContainer
Instance.new("UICorner", autoFillClip).CornerRadius = UDim.new(0.5, 0)

local autoFill = Instance.new("Frame")
autoFill.Name             = "Fill"
autoFill.Size             = UDim2.new(1, 0, 1, 0)
autoFill.Position         = UDim2.new(0, 0, 1, 0)
autoFill.AnchorPoint      = Vector2.new(0, 1)
autoFill.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
autoFill.BorderSizePixel  = 0
autoFill.Parent           = autoFillClip

local function UpdateModeToggleVisuals()
	local textLabel = modeToggle:FindFirstChildOfClass("TextLabel") or modeToggle
	local uiStroke  = modeToggle:FindFirstChildOfClass("UIStroke")

	autoLoopID += 1
	local currentLoop = autoLoopID

	if isAutoMode then
		modeToggle.BackgroundColor3 = Color3.fromRGB(24, 60, 24)
		textLabel.Text              = "[AUTO ACTIVE]"
		textLabel.TextColor3        = Color3.fromRGB(0, 255, 128)
		if uiStroke then uiStroke.Color = Color3.fromRGB(0, 255, 128) end

		autoProgressContainer.Visible = true

		task.spawn(function()
			while isAutoMode and autoLoopID == currentLoop do
				local timeLeft = sharedCooldownEnd - tick()

				if timeLeft <= 0 then
					sharedCooldownEnd = tick() + currentCooldownTime
					timeLeft = currentCooldownTime

					if (pendingAuras or 0) > 0 then
						ShipAuras:FireServer("manual")
					end
				end

				local pct = timeLeft / currentCooldownTime
				autoFill.Size = UDim2.new(1, 0, pct, 0)

				local tween = TweenService:Create(autoFill, TweenInfo.new(timeLeft, Enum.EasingStyle.Linear), {
					Size = UDim2.new(1, 0, 0, 0)
				})
				tween:Play()

				local elapsed = 0
				while elapsed < timeLeft and isAutoMode and autoLoopID == currentLoop do
					task.wait(0.1)
					elapsed += 0.1
				end

				if tween then tween:Cancel() end
			end
		end)
	else
		modeToggle.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
		textLabel.Text              = "Mode: Manual"
		textLabel.TextColor3        = Color3.fromRGB(220, 230, 240)
		if uiStroke then uiStroke.Color = Color3.fromRGB(100, 180, 220) end

		autoProgressContainer.Visible = false
	end
end

sendButton.MouseButton1Down:Connect(function()
	if AdminConfig.DisableShipping then return end
	if isAutoMode or isShipOnCooldown or (pendingAuras or 0) <= 0 then return end

	ShipAuras:FireServer("manual")
	sharedCooldownEnd = tick() + currentCooldownTime
	SyncManualCooldownVisuals()
end)

modeToggle.MouseButton1Down:Connect(function()
	if AdminConfig.DisableShipping then return end

	isAutoMode = not isAutoMode
	ShipAuras:FireServer("setMode", isAutoMode and "auto" or "manual")

	UpdateModeToggleVisuals()
	UpdateSendButton()
end)

UpdateModeToggleVisuals()
sendButton.Visible = false

if AdminConfig.DisableShipping then
	isAutoMode         = false
	sendButton.Visible = false
	modeToggle.Visible = false
end

-- ─────────────────────────────────────────────────────────────────────────────
-- UpdateHUD EVENT
-- ─────────────────────────────────────────────────────────────────────────────
UpdateHUD.OnClientEvent:Connect(function(stats)
	local serverPurchaseTick = player:GetAttribute("LastServerPurchaseTick") or 0
	local safeToSync = (tick() - math.max(lastSpendTick, serverPurchaseTick)) > 2.5

	if stats.goldenAuras ~= nil and safeToSync then
		local pendingAuras = player:GetAttribute("LocalPendingAuras") or 0
		local effectiveServerAuras = stats.goldenAuras - pendingAuras

		if effectiveServerAuras ~= liveGoldenAuras then
			liveGoldenAuras = effectiveServerAuras
			GoldenAurasLabel.Text = "GAURAS: " .. FormatNumber(liveGoldenAuras) 
		end
	end

	if stats.currency ~= nil then
		local newServerCurrency = stats.currency

		if safeToSync then
			local dynamicInterval = math.max(5, (passiveInterval or 1) * 2) 
			local snapThreshold = math.max(500, ratePerSecond * dynamicInterval)

			local pendingPayout = player:GetAttribute("LocalPendingPayout") or 0
			local effectiveServerCurrency = newServerCurrency - pendingPayout

			local diff = effectiveServerCurrency - displayedCurrency

			if diff > snapThreshold then
				displayedCurrency = effectiveServerCurrency
				curr.TextColor3 = Color3.fromRGB(80, 255, 80)
				TweenService:Create(curr, TweenInfo.new(0.4), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()

			elseif diff < -snapThreshold then
				displayedCurrency = effectiveServerCurrency
				curr.TextColor3 = Color3.fromRGB(255, 80, 80)
				TweenService:Create(curr, TweenInfo.new(0.4), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			end
		end

		prevServerCurrency = newServerCurrency
		serverCurrency     = newServerCurrency
	end

	if stats.pendingAuras ~= nil then
		pendingAuras    = stats.pendingAuras
		habitatCapacity = stats.habitatCapacity or habitatCapacity
		UpdateHabitatBar(pendingAuras, habitatCapacity)
		UpdateSendButton()
	end

	if stats.rate ~= nil then
		passiveInterval = stats.passiveInterval or passiveInterval
		local serverRate = stats.rate
		ratePerSecond = (passiveInterval > 0 and serverRate > 0)
			and serverRate / passiveInterval or 0
		rate.Text = FormatRate(ratePerSecond)
		TweenService:Create(rate, TweenInfo.new(0.3), {
			TextColor3 = GetRateColor(pendingAuras, habitatCapacity)
		}):Play()
	end

	if stats.shipCooldown ~= nil then
		currentCooldownTime = stats.shipCooldown
	end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- SMOOTH TICKER
-- ─────────────────────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function(dt)
	if ratePerSecond > 0 then
		displayedCurrency += ratePerSecond * dt
	end

	player:SetAttribute("LiveCurrency",     displayedCurrency)
	player:SetAttribute("LiveGoldenAuras",  liveGoldenAuras)
	curr.Text = "Currency: $" .. FormatNumber(displayedCurrency)
end)

local function RefreshLook()
	UITheme.ApplyFlair(GoldenAurasLabel, "GoldStroke")
end
task.wait(2)
RefreshLook()

-- VFXController
-- Location: StarterPlayer > StarterPlayerScripts > VFXController
--
-- CHANGES:
--   VFX_CONFIG entries now support a `scale` field.
--   EmitVFX passes scale to shared.vfx.emit(scale, clone).
--   scale = 1 is default, 2 = double size, 0.5 = half size.
--
-- SETUP:
--   VFX templates in ReplicatedStorage/VFX/ OR directly in workspace.
--   InvertedDistortion is in workspace — the script finds it there automatically.
--
-- ADDING NEW VFX:
--   1. Add the VFX Model to workspace or ReplicatedStorage/VFX/
--   2. Add an entry to VFX_CONFIG with vfxName, positions, and scale
--   3. That's it — no other changes needed

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")

local player = Players.LocalPlayer

local VFX_FOLDER = ReplicatedStorage:FindFirstChild("VFX")
local AuraHolder = workspace:WaitForChild("AuraHolder")
local HabitatHolder = workspace:WaitForChild("HabitatHolder")
---------------------------------------------------------------
-- VFX CONFIG
-- vfxName  = name of Model in ReplicatedStorage/VFX/ or workspace
-- positions = where to emit: "AuraHolder", "Habitat", "Character", or Vector3
-- scale    = size multiplier passed to shared.vfx.emit(scale, ...)
--            1.0 = default, 2.0 = twice as big, 0.5 = half size
---------------------------------------------------------------
local VFX_CONFIG = {
	Prestige = {
		vfxName   = "InvertedDistortion",
		positions = { "Habitat" },
		scale     = 1.5,
	},
	PortalEnter = {
		vfxName   = "InvertedDistortion",
		positions = { "Habitat" },
		scale     = 2.0,
	},
	AreaUnlocked = {
		vfxName   = "InvertedDistortion",
		positions = { "Habitat" },
		scale     = 1.0,
	},
	ShopPurchase = {
		vfxName   = "",   -- fill in when you have a purchase VFX
		positions = { "Character" },
		scale     = 1.0,
	},
	BoostActivated = {
		vfxName   = "",
		positions = { "AuraHolder" },
		scale     = 7.0,
	},
	TierUpgrade = {
		vfxName   = "",
		positions = { "AuraHolder" },
		scale     = 1.0,
	},
	LegendarySpawn = {
		vfxName   = "",
		positions = { "AuraHolder" },
		scale     = 1.5,
	},
}

local EMIT_CLEANUP_DELAY = 6

---------------------------------------------------------------
-- GetWorldPosition
---------------------------------------------------------------
local function GetWorldPosition(target)
	if typeof(target) == "Vector3" then return target end

	if target == "AuraHolder" then
		return AuraHolder:GetPivot().Position
	end
	

	if target == "Habitat" then
		return HabitatHolder:WaitForChild("Position").Position
	end

	if target == "Character" then
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then return hrp.Position end
		end
		return AuraHolder:GetPivot().Position
	end

	return Vector3.new(0, 0, 0)
end

---------------------------------------------------------------
-- EmitVFX
-- Finds the VFX template, clones it, moves it to worldPos,
-- calls shared.vfx.emit(scale, clone), then Debris cleans it up.
---------------------------------------------------------------
local function EmitVFX(vfxName, worldPos, scale)
	if not vfxName or vfxName == "" then return end

	-- Wait for Forge to initialize (shared.vfx set by ForgeInit)
	if not shared.vfx then
		local waited = 0
		repeat task.wait(0.1); waited += 0.1
		until shared.vfx or waited >= 10
		if not shared.vfx then
			warn("[VFXController] shared.vfx not available — Forge not initialized")
			return
		end
	end

	scale = scale or 1

	-- Check ReplicatedStorage/VFX/ first, then workspace directly
	local template = VFX_FOLDER and VFX_FOLDER:FindFirstChild(vfxName)

	if template then
		-- Clone from template so the original is reusable
		local clone = template:Clone()
		clone.Parent = workspace

		if clone:IsA("Model") then
			clone:PivotTo(CFrame.new(worldPos))
		elseif clone:IsA("BasePart") then
			clone.CFrame = CFrame.new(worldPos)
		end

		local ok, err = pcall(function()
			if scale ~= 1 then
				shared.vfx.emit(scale, clone)
			else
				shared.vfx.emit(clone)
			end
		end)
		if not ok then warn("[VFXController] Emit error: " .. tostring(err)) end

		Debris:AddItem(clone, EMIT_CLEANUP_DELAY)

	else
		-- No template — look for it directly in workspace (e.g. InvertedDistortion)
		local wsObj = workspace:FindFirstChild(vfxName)
		if wsObj then
			-- Move it to the target position and emit in-place
			if wsObj:IsA("Model") then
				wsObj:PivotTo(CFrame.new(worldPos))
			elseif wsObj:IsA("BasePart") then
				wsObj.CFrame = CFrame.new(worldPos)
			end

			local ok, err = pcall(function()
				if scale ~= 1 then
					shared.vfx.emit(scale, wsObj)
				else
					shared.vfx.emit(wsObj)
				end
			end)
			if not ok then warn("[VFXController] Emit error: " .. tostring(err)) end
		else
			warn("[VFXController] VFX not found in VFX folder or workspace: '" .. vfxName .. "'")
		end
	end
end

---------------------------------------------------------------
-- FireEvent — looks up config and emits at all positions
---------------------------------------------------------------
local function FireEvent(eventName)
	local cfg = VFX_CONFIG[eventName]
	if not cfg or not cfg.vfxName or cfg.vfxName == "" then return end

	for _, target in ipairs(cfg.positions or {}) do
		EmitVFX(cfg.vfxName, GetWorldPosition(target), cfg.scale)
	end
end

---------------------------------------------------------------
-- Public API
-- shared.VFXController is set so other LocalScripts can use it:
--   shared.VFXController.Fire("Prestige")
--   shared.VFXController.FireAt("InvertedDistortion", Vector3.new(0,10,0), 2.0)
--   shared.VFXController.FireAtTarget("InvertedDistortion", "AuraHolder", 1.5)
---------------------------------------------------------------
local VFXController = {}

function VFXController.Fire(eventName)
	FireEvent(eventName)
end

function VFXController.FireAt(vfxName, worldPos, scale)
	EmitVFX(vfxName, worldPos, scale)
end

function VFXController.FireAtTarget(vfxName, target, scale)
	EmitVFX(vfxName, GetWorldPosition(target), scale)
end

shared.VFXController = VFXController

---------------------------------------------------------------
-- Event hooks — auto-fire VFX on game events
---------------------------------------------------------------
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- Prestige or portal entry
local PrestigeComplete = RemoteEvents:WaitForChild("PrestigeComplete")
PrestigeComplete.OnClientEvent:Connect(function(info)
	if info.isPortalEntry then
		FireEvent("PortalEnter")
	else
		FireEvent("Prestige")
	end
end)

-- Portal threshold hit
local AreaUnlocked = RemoteEvents:WaitForChild("AreaUnlocked")
AreaUnlocked.OnClientEvent:Connect(function()
	FireEvent("AreaUnlocked")
end)

-- Shop upgrade purchased
local UpgradeUpdated = RemoteEvents:WaitForChild("UpgradeUpdated")
UpgradeUpdated.OnClientEvent:Connect(function(info)
	if info.type == "purchased" then
		FireEvent("ShopPurchase")
	end
end)

-- Boost activated
local BoostUpdated = RemoteEvents:WaitForChild("BoostUpdated")
local prevActiveCounts = {}
BoostUpdated.OnClientEvent:Connect(function(state)
	for boostId, data in pairs(state) do
		if type(data) == "table" and data.activeCount then
			local prev = prevActiveCounts[boostId] or 0
			if data.activeCount > prev then
				FireEvent("BoostActivated")
			end
			prevActiveCounts[boostId] = data.activeCount
		end
	end
end)

-- Tier upgrade / legendary
local CubeMutated = RemoteEvents:WaitForChild("CubeMutated")
CubeMutated.OnClientEvent:Connect(function(info)
	if info.mutationType == "tierUpgrade" then
		if info.tierName == "Legendary" then
			FireEvent("LegendarySpawn")
		else
			FireEvent("TierUpgrade")
		end
	end
end)

--WeatherController
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local WeatherConfig = require(ReplicatedStorage.Modules.WeatherConfig)
local T = require(ReplicatedStorage.Modules.UITheme).Get("Custom")
local C = require(ReplicatedStorage.Modules.UIConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainHUD = playerGui:WaitForChild("MainHUD")
local WeatherChanged = ReplicatedStorage.RemoteEvents:WaitForChild("WeatherChanged")

local camera = workspace.CurrentCamera
local currentTween = nil

---------------------------------------------------------------
-- CAMERA CLOUD SETUP
---------------------------------------------------------------
local cloudPart = Instance.new("Part")
cloudPart.Name = "WeatherCloud"
cloudPart.Size = Vector3.new(100, 1, 100)
cloudPart.Transparency = 1
cloudPart.Anchored = true
cloudPart.CanCollide = false
cloudPart.Parent = workspace

local emitter = Instance.new("ParticleEmitter")
emitter.Name = "WeatherEmitter"
emitter.EmissionDirection = Enum.NormalId.Bottom
emitter.Rate = 0
emitter.Speed = NumberRange.new(30, 50)
emitter.Lifetime = NumberRange.new(1.5, 2.5)
emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0.4)})
emitter.Parent = cloudPart

RunService.RenderStepped:Connect(function()
	cloudPart.CFrame = camera.CFrame * CFrame.new(0, 40, -15)
end)

---------------------------------------------------------------
-- THE TOP DROP-DOWN BANNER
---------------------------------------------------------------
local function ShowWeatherBanner(cfg)
	-- Pulls sizes directly from your UIConfig just like the Portal banner
	local PBW = C.Banners.PortalBannerW or 300
	local PBH = C.Banners.PortalBannerH or 60
	local BR = C.Banners.CornerRadius or 8

	local banner = Instance.new("Frame")
	banner.Size = UDim2.new(0, PBW, 0, PBH)
	banner.Position = UDim2.new(0.5, -PBW/2, 0, -PBH - 10)
	banner.BackgroundColor3 = T.panelBG
	banner.BorderSizePixel = 0
	banner.ZIndex = 60
	banner.Parent = mainHUD
	Instance.new("UICorner", banner).CornerRadius = UDim.new(0, BR)

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = cfg.color
	bStroke.Thickness = 2
	bStroke.Parent = banner

	local bLabel = Instance.new("TextLabel")
	bLabel.Size = UDim2.new(1, -20, 1, 0)
	bLabel.Position = UDim2.new(0, 10, 0, 0)
	bLabel.BackgroundTransparency = 1
	bLabel.Text = cfg.bannerText
	bLabel.TextColor3 = cfg.color
	bLabel.TextScaled = true
	bLabel.Font = T.font
	bLabel.ZIndex = 61
	bLabel.Parent = banner

	-- Smooth drop down
	TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -PBW/2, 0, 14) }):Play()

	-- Retreat after 5 seconds
	task.delay(5, function()
		TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(0.5, -PBW/2, 0, -PBH - 10) }):Play()
		task.delay(0.4, function() if banner and banner.Parent then banner:Destroy() end end)
	end)
end

---------------------------------------------------------------
-- WEATHER EVENT LISTENER
---------------------------------------------------------------
WeatherChanged.OnClientEvent:Connect(function(weatherName)
	local cfg = WeatherConfig.Types[weatherName] or WeatherConfig.Types.Clear

	-- 1. Pop the beautiful UI Banner
	ShowWeatherBanner(cfg)

	-- 2. Tween Lighting
	if currentTween then currentTween:Cancel() end
	currentTween = TweenService:Create(Lighting, TweenInfo.new(4.0, Enum.EasingStyle.Sine), {
		Ambient = cfg.ambient,
		FogEnd = cfg.fogEnd
	})
	currentTween:Play()

	-- 3. Transition Particles
	if cfg.particle then
		emitter.Texture = cfg.particle
		emitter.Color = ColorSequence.new(cfg.color)
		TweenService:Create(emitter, TweenInfo.new(3.0), {Rate = cfg.rate}):Play()
	else
		TweenService:Create(emitter, TweenInfo.new(2.0), {Rate = 0}):Play()
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

CmdrClient:SetActivationKeys({Enum.KeyCode.F2})

