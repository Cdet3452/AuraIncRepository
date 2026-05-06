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
		iconId = "rbxassetid://14916846070", -- PLACEHOLDER
		statKey = "totalCubesProduced", -- The exact variable in your datastore
		goal = 10,
		rewardText = "Unlocks: Aura Rush Boost"
	},
	{
		id = "unlock_spawnboost",
		boostId = "SpawnBoost",
		title = "Explorer",
		desc = "Reach Area 2",
		iconId = "rbxassetid://14916846070", -- PLACEHOLDER
		statKey = "currentArea",
		goal = 2,
		rewardText = "Unlocks: Value Boost"
	},
	{
		id = "unlock_soulboost",
		boostId = "SoulBoost",
		title = "Soul Searcher",
		desc = "Prestige 5 Times",
		iconId = "rbxassetid://14916846070", -- PLACEHOLDER
		statKey = "prestigeCount",
		goal = 5,
		rewardText = "Unlocks: Soul Boost"
	}
}

-- 🏅 YOUR ROBLOX BADGES
AchievementConfig.Badges = {
	{ id = 000000000, title = "First Prestige", desc = "Prestige for the first time.", iconId = "rbxassetid://14916846070" }, 
	{ id = 000000000, title = "Millionaire", desc = "Hold $1,000,000 at once.", iconId = "rbxassetid://14916846070" }, 
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
AdminConfig.BaseHabitatCapacity  = 80
AdminConfig.ShipInterval         = 30
AdminConfig.TierOverride         = nil
AdminConfig.WipeMoneyOnLoad      = true
AdminConfig.WipePrestigeOnLoad   = true  
AdminConfig.WipeAchievementsOnLoad = true
AdminConfig.WipeAreaOnLoad       = true  
AdminConfig.WipeEpicOnLoad = true
AdminConfig.AutoDispatch         = false

AdminConfig.PlatformCapacity     = 20
AdminConfig.PlatformSpeed        = 20
AdminConfig.PlatformHoverHeight  = 5
AdminConfig.MaxTrucks            = 3
AdminConfig.PassiveInterval      = 60

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

AdminConfig.HatcheryMax              = 1500
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



-- =====================================================================
-- 1. MODULE: AreaRegistry
-- Location: ReplicatedStorage > Modules > AreaRegistry
-- =====================================================================
local AreaRegistry = {}

AreaRegistry.LightingPresets = {

	-- 🏭 PHASE 1: THE GRIME (Areas 1-3)
	["Area1_DeepScrapyard"] = {
		ClockTime = 12, Brightness = 0.3, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(70, 60, 50), FogColor = Color3.fromRGB(90, 80, 65),
		FogStart = 20, FogEnd = 60, Density = 0.7, Haze = 10, AtmosphereColor = Color3.fromRGB(90, 80, 65)
	},
	["Area2_RustyWastes"] = {
		ClockTime = 14, Brightness = 0.4, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(80, 65, 50), FogColor = Color3.fromRGB(100, 85, 60),
		FogStart = 20, FogEnd = 80, Density = 0.6, Haze = 8, AtmosphereColor = Color3.fromRGB(100, 85, 60)
	},
	["Area3_IndustrialOutskirts"] = {
		ClockTime = 16, Brightness = 0.5, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(85, 75, 65), FogColor = Color3.fromRGB(110, 100, 90),
		FogStart = 30, FogEnd = 100, Density = 0.55, Haze = 6, AtmosphereColor = Color3.fromRGB(110, 100, 90)
	},

	-- ☣️ PHASE 2: TOXIC ZONES (Areas 4-5)
	["Area4_ChemicalSpill"] = {
		ClockTime = 17, Brightness = 0.4, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(60, 75, 50), FogColor = Color3.fromRGB(75, 90, 55),
		FogStart = 50, FogEnd = 110, Density = 0.5, Haze = 7, AtmosphereColor = Color3.fromRGB(75, 90, 55)
	},
	["Area5_BioHazard"] = {
		ClockTime = 17.5, Brightness = 0.3, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(40, 60, 40), FogColor = Color3.fromRGB(45, 80, 45),
		FogStart = 60, FogEnd = 120, Density = 0.4, Haze = 5, AtmosphereColor = Color3.fromRGB(45, 80, 45)
	},

	-- 🌆 PHASE 3: TWILIGHT SLUMS (Areas 6-8)
	["Area6_SunsetStrip"] = {
		ClockTime = 17.8, Brightness = 0.6, SunRaysIntensity = 0.1, -- Sun peeks through!
		Ambient = Color3.fromRGB(70, 40, 40), FogColor = Color3.fromRGB(90, 40, 30),
		FogStart = 20, FogEnd = 150, Density = 0.5, Haze = 4, AtmosphereColor = Color3.fromRGB(120, 50, 40)
	},
	["Area7_TwilightSector"] = {
		ClockTime = 18.2, Brightness = 0.4, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(40, 30, 60), FogColor = Color3.fromRGB(35, 25, 55),
		FogStart = 20, FogEnd = 180, Density = 0.55, Haze = 4, AtmosphereColor = Color3.fromRGB(35, 25, 55)
	},
	["Area8_NeonSlums"] = {
		ClockTime = 0, Brightness = 0.5, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(30, 20, 50), FogColor = Color3.fromRGB(20, 10, 40),
		FogStart = 25, FogEnd = 200, Density = 0.5, Haze = 3, AtmosphereColor = Color3.fromRGB(40, 20, 80)
	},

	-- 🌃 PHASE 4: CYBER CITY (Areas 9-10)
	["Area9_LowerCyber"] = {
		ClockTime = 0, Brightness = 0.7, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(25, 25, 55), FogColor = Color3.fromRGB(15, 15, 45),
		FogStart = 30, FogEnd = 250, Density = 0.4, Haze = 2, AtmosphereColor = Color3.fromRGB(20, 20, 60)
	},
	["Area10_CyberCore"] = {
		ClockTime = 0, Brightness = 1, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(20, 30, 60), FogColor = Color3.fromRGB(10, 20, 50),
		FogStart = 50, FogEnd = 400, Density = 0.25, Haze = 1, AtmosphereColor = Color3.fromRGB(15, 25, 65)
	},

	-- 🌐 PHASE 5: CORPORATE STERILITY (Areas 11-13)
	["Area11_GlassFacility"] = {
		ClockTime = 12, Brightness = 2.0, SunRaysIntensity = 0.4, -- Blinding sudden daylight
		Ambient = Color3.fromRGB(130, 130, 140), FogColor = Color3.fromRGB(200, 220, 240),
		FogStart = 100, FogEnd = 1500, Density = 0.15, Haze = 0, AtmosphereColor = Color3.fromRGB(200, 220, 240)
	},
	["Area12_CrystalLab"] = {
		ClockTime = 14, Brightness = 2.5, SunRaysIntensity = 0.5,
		Ambient = Color3.fromRGB(150, 150, 150), FogColor = Color3.fromRGB(220, 240, 255),
		FogStart = 150, FogEnd = 2500, Density = 0.1, Haze = 0, AtmosphereColor = Color3.fromRGB(220, 240, 255)
	},
	["Area13_QuantumGrid"] = {
		ClockTime = 14, Brightness = 2.2, SunRaysIntensity = 0.3,
		Ambient = Color3.fromRGB(100, 180, 200), FogColor = Color3.fromRGB(150, 255, 255),
		FogStart = 200, FogEnd = 3000, Density = 0.05, Haze = 0, AtmosphereColor = Color3.fromRGB(150, 255, 255)
	},

	-- 🌌 PHASE 6: REALITY BREAKING (Areas 14-16)
	["Area14_PlasmaCore"] = {
		ClockTime = 17.5, Brightness = 1.8, SunRaysIntensity = 0.3,
		Ambient = Color3.fromRGB(150, 80, 150), FogColor = Color3.fromRGB(200, 100, 200),
		FogStart = 100, FogEnd = 2000, Density = 0.2, Haze = 2, AtmosphereColor = Color3.fromRGB(200, 100, 200)
	},
	["Area15_CosmicRift"] = {
		ClockTime = 6, Brightness = 1.5, SunRaysIntensity = 0.2,
		Ambient = Color3.fromRGB(100, 30, 150), FogColor = Color3.fromRGB(70, 0, 100),
		FogStart = 50, FogEnd = 1000, Density = 0.3, Haze = 4, AtmosphereColor = Color3.fromRGB(150, 0, 255)
	},
	["Area16_DarkMatter"] = {
		ClockTime = 0, Brightness = 0.8, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(80, 10, 20), FogColor = Color3.fromRGB(40, 0, 5),
		FogStart = 30, FogEnd = 600, Density = 0.5, Haze = 6, AtmosphereColor = Color3.fromRGB(120, 0, 10)
	},

	-- ⬛ PHASE 7: THE VOID (Areas 17-20)
	["Area17_EventHorizon"] = {
		ClockTime = 0, Brightness = 0.4, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(30, 10, 40), FogColor = Color3.fromRGB(15, 5, 20),
		FogStart = 50, FogEnd = 800, Density = 0.3, Haze = 3, AtmosphereColor = Color3.fromRGB(20, 5, 30)
	},
	["Area18_DeepSpace"] = {
		ClockTime = 0, Brightness = 0.2, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(15, 15, 25), FogColor = Color3.fromRGB(5, 5, 15),
		FogStart = 100, FogEnd = 1500, Density = 0.15, Haze = 1, AtmosphereColor = Color3.fromRGB(5, 5, 15)
	},
	["Area19_TheAbyss"] = {
		ClockTime = 0, Brightness = 0.05, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(5, 5, 5), FogColor = Color3.fromRGB(2, 2, 2),
		FogStart = 200, FogEnd = 3000, Density = 0.05, Haze = 0, AtmosphereColor = Color3.fromRGB(2, 2, 2)
	},
	["Area20_UniversalVoid"] = {
		ClockTime = 0, Brightness = 0, SunRaysIntensity = 0,
		Ambient = Color3.fromRGB(0, 0, 0), FogColor = Color3.fromRGB(0, 0, 0),
		FogStart = 500, FogEnd = 5000, Density = 0, Haze = 0, AtmosphereColor = Color3.fromRGB(0, 0, 0)
	}
}

AreaRegistry.Areas = {
	[1] = { 
		name             = "Green Scrapyard",     
		threshold        = 0,   
		valueMultiplier  = 1.0, 
		yOffset          = -2.7, 
		yRotation        = 180, 
		auraPreviewColor = Color3.fromRGB(200, 200, 200), 
		grassColor       = Color3.fromRGB(92, 197, 53), 
		pathColor        = Color3.fromRGB(163, 130, 88), 
		ambientColor     = Color3.fromRGB(90, 90, 100), 
		fogColor         = Color3.fromRGB(180, 200, 220), 
		auraHolderColor  = Color3.fromRGB(255, 255, 255), 
		auraHolderGlow   = Color3.fromRGB(255, 255, 255), 
		lightingPreset   = "Area1_DeepScrapyard", 
		icon = "rbxassetid://71630626823279",
		auraModels       = { Common = "GearAura", Uncommon = "ScrewAura", Rare = "BottleAura", Epic = "TireAura", Legendary = "RadioAura" }
	},
	[2] = { 
		name             = "Industrial Rust",    
		threshold        = 5e4, 
		valueMultiplier  = 1.5, 
		yOffset          = -4.5, 
		yRotation        = 180, 
		auraPreviewColor = Color3.fromRGB(180, 100, 50), 
		grassColor       = Color3.fromRGB(104, 160, 98), 
		pathColor        = Color3.fromRGB(132, 140, 81), 
		ambientColor     = Color3.fromRGB(80, 100, 80), 
		fogColor         = Color3.fromRGB(160, 200, 160), 
		auraHolderColor  = Color3.fromRGB(187, 255, 183), 
		auraHolderGlow   = Color3.fromRGB(100, 255, 100), 
		lightingPreset   = "Area2_RustyWastes", 
		flipbookImage    = "rbxassetid://1234567891", 
		flipbookFrames   = 8, 
		flipbookFPS      = 12, 
		flipbookFrameW   = 128, 
		flipbookFrameH   = 128, 
		flipbookColumns  = 4,
		auraModels       = { Common = "RustedNail", Uncommon = "ScrapPipe", Rare = "BentGear", Epic = "EngineScrap", Legendary = "CorrodedCore" }
	},
	[3] = { 
		name             = "Foil Scrapyard",        
		threshold        = 5e5, 
		valueMultiplier  = 4.0, 
		yOffset          = -2.8, 
		yRotation        = 180, 
		auraPreviewColor = Color3.fromRGB(220, 230, 255), 
		grassColor       = Color3.fromRGB(180, 190, 200), 
		pathColor        = Color3.fromRGB(150, 160, 170), 
		ambientColor     = Color3.fromRGB(100, 110, 120), 
		fogColor         = Color3.fromRGB(200, 210, 220), 
		auraHolderColor  = Color3.fromRGB(220, 230, 255), 
		auraHolderGlow   = Color3.fromRGB(240, 250, 255), 
		lightingPreset   = "Area3_IndustrialOutskirts", 
		flipbookImage    = "rbxassetid://1234567892", 
		flipbookFrames   = 12, 
		flipbookFPS      = 15, 
		flipbookFrameW   = 128, 
		flipbookFrameH   = 128, 
		flipbookColumns  = 4,
		auraModels       = { Common = "FoilBall", Uncommon = "CandyWrapper", Rare = "AluminumSheet", Epic = "SilverLeaf", Legendary = "MylarBalloon" }
	},
	[4] = { 
		name             = "Cheap Metal",        
		threshold        = 5e6, 
		valueMultiplier  = 8.0, 
		yOffset          = -2.8, 
		yRotation        = 180, 
		auraPreviewColor = Color3.fromRGB(150, 150, 160), 
		grassColor       = Color3.fromRGB(130, 130, 140), 
		pathColor        = Color3.fromRGB(100, 100, 110), 
		ambientColor     = Color3.fromRGB(80, 80, 90), 
		fogColor         = Color3.fromRGB(140, 140, 150), 
		auraHolderColor  = Color3.fromRGB(170, 170, 180), 
		auraHolderGlow   = Color3.fromRGB(190, 190, 200), 
		lightingPreset   = "Area4_ChemicalSpill", 
		flipbookImage    = "rbxassetid://1234567893", 
		flipbookFrames   = 16, 
		flipbookFPS      = 20, 
		flipbookFrameW   = 128, 
		flipbookFrameH   = 128, 
		flipbookColumns  = 4,
		auraModels       = { Common = "TinBlock", Uncommon = "ZincPlate", Rare = "LeadPipe", Epic = "NickelCoin", Legendary = "PewterIdol" }
	},
	[5] = { 
		name             = "Solid Metal",   
		threshold        = 5e7, 
		valueMultiplier  = 20.0,
		yOffset          = -3.0,   
		yRotation        = 0,   
		auraPreviewColor = Color3.fromRGB(90, 95, 100), 
		grassColor       = Color3.fromRGB(80, 85, 90), 
		pathColor        = Color3.fromRGB(60, 65, 70), 
		ambientColor     = Color3.fromRGB(50, 55, 60), 
		fogColor         = Color3.fromRGB(100, 105, 110), 
		auraHolderColor  = Color3.fromRGB(120, 125, 130), 
		auraHolderGlow   = Color3.fromRGB(140, 145, 150), 
		lightingPreset   = "Area5_BioHazard", 
		flipbookImage    = "rbxassetid://1234567894", 
		flipbookFrames   = 20, 
		flipbookFPS      = 24, 
		flipbookFrameW   = 128, 
		flipbookFrameH   = 128, 
		flipbookColumns  = 5,
		auraModels       = { Common = "IronOre", Uncommon = "SteelBeam", Rare = "CastIronWheel", Epic = "ChromeBumper", Legendary = "TungstenRod" }
	},
	[6] = {
		name             = "Refined Alloys",
		threshold        = 5e9,
		valueMultiplier  = 75.0,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(200, 120, 50),
		grassColor       = Color3.fromRGB(160, 90, 40),
		pathColor        = Color3.fromRGB(120, 70, 30),
		ambientColor     = Color3.fromRGB(90, 50, 20),
		fogColor         = Color3.fromRGB(180, 100, 60),
		auraHolderColor  = Color3.fromRGB(220, 140, 80),
		auraHolderGlow   = Color3.fromRGB(255, 180, 100),
		lightingPreset   = "Area6_RefinedAlloys", 
		auraModels       = { Common = "CopperWire", Uncommon = "BrassGear", Rare = "BronzeStatue", Epic = "TitaniumPlate", Legendary = "CobaltShard" }
	},
	[7] = {
		name             = "Precious Metals",
		threshold        = 5e12,
		valueMultiplier  = 350.0,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(255, 215, 0),
		grassColor       = Color3.fromRGB(200, 170, 0),
		pathColor        = Color3.fromRGB(150, 120, 0),
		ambientColor     = Color3.fromRGB(120, 100, 20),
		fogColor         = Color3.fromRGB(255, 230, 100),
		auraHolderColor  = Color3.fromRGB(255, 240, 150),
		auraHolderGlow   = Color3.fromRGB(255, 255, 200),
		lightingPreset   = "Area7_PreciousMetals", 
		auraModels       = { Common = "SilverBar", Uncommon = "GoldNugget", Rare = "PlatinumRing", Epic = "PalladiumCoin", Legendary = "RhodiumIngot" }
	},
	[8] = {
		name             = "Industrial Synthetics",
		threshold        = 5e15,
		valueMultiplier  = 2500.0,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(230, 230, 230),
		grassColor       = Color3.fromRGB(40, 40, 40),
		pathColor        = Color3.fromRGB(20, 20, 20),
		ambientColor     = Color3.fromRGB(60, 60, 60),
		fogColor         = Color3.fromRGB(100, 100, 100),
		auraHolderColor  = Color3.fromRGB(255, 255, 255),
		auraHolderGlow   = Color3.fromRGB(200, 200, 255),
		lightingPreset   = "Area8_Synthetics", 
		auraModels       = { Common = "PVC_Pipe", Uncommon = "KevlarWeave", Rare = "TeflonBlock", Epic = "CarbonFiberRoll", Legendary = "GrapheneSheet" }
	},
	[9] = {
		name             = "Volatile Materials",
		threshold        = 5e19,
		valueMultiplier  = 50000.0,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(100, 255, 100),
		grassColor       = Color3.fromRGB(30, 50, 30),
		pathColor        = Color3.fromRGB(20, 40, 20),
		ambientColor     = Color3.fromRGB(40, 70, 40),
		fogColor         = Color3.fromRGB(80, 200, 80),
		auraHolderColor  = Color3.fromRGB(150, 255, 150),
		auraHolderGlow   = Color3.fromRGB(0, 255, 0),
		lightingPreset   = "Area9_Volatile", 
		auraModels       = { Common = "GlowingSludge", Uncommon = "RadiumDial", Rare = "UraniumRod", Epic = "PlutoniumCore", Legendary = "AntimatterVial" }
	},
	[10] = {
		name             = "Rough Gemstones",
		threshold        = 5e25,
		valueMultiplier  = 1000000.0,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(200, 100, 255),
		grassColor       = Color3.fromRGB(90, 50, 120),
		pathColor        = Color3.fromRGB(60, 30, 80),
		ambientColor     = Color3.fromRGB(100, 60, 130),
		fogColor         = Color3.fromRGB(180, 120, 255),
		auraHolderColor  = Color3.fromRGB(230, 150, 255),
		auraHolderGlow   = Color3.fromRGB(200, 50, 255),
		lightingPreset   = "Area10_RoughGems", 
		auraModels       = { Common = "AmethystCluster", Uncommon = "RawSapphire", Rare = "UncutRuby", Epic = "EmeraldChunk", Legendary = "OpalGeode" }
	},
	[11] = {
		name             = "Polished Gems",
		threshold        = 5e32,
		valueMultiplier  = 5e7,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(150, 255, 255),
		grassColor       = Color3.fromRGB(200, 240, 255),
		pathColor        = Color3.fromRGB(180, 220, 255),
		ambientColor     = Color3.fromRGB(100, 200, 255),
		fogColor         = Color3.fromRGB(180, 255, 255),
		auraHolderColor  = Color3.fromRGB(220, 255, 255),
		auraHolderGlow   = Color3.fromRGB(255, 255, 255),
		lightingPreset   = "Area11_PolishedGems", 
		auraModels       = { Common = "PolishedTopaz", Uncommon = "FacetedSapphire", Rare = "CutRuby", Epic = "PerfectEmerald", Legendary = "FlawlessDiamond" }
	},
	[12] = {
		name             = "High-Tech Computing",
		threshold        = 5e40,
		valueMultiplier  = 2.5e9,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(50, 200, 100),
		grassColor       = Color3.fromRGB(20, 40, 30),
		pathColor        = Color3.fromRGB(15, 30, 20),
		ambientColor     = Color3.fromRGB(30, 60, 40),
		fogColor         = Color3.fromRGB(40, 120, 80),
		auraHolderColor  = Color3.fromRGB(100, 255, 150),
		auraHolderGlow   = Color3.fromRGB(50, 255, 100),
		lightingPreset   = "Area12_HighTech", 
		auraModels       = { Common = "SiliconWafer", Uncommon = "Microchip", Rare = "RAM_Stick", Epic = "QuantumProcessor", Legendary = "AI_Core" }
	},
	[13] = {
		name             = "Neon & Plasma",
		threshold        = 5e50,
		valueMultiplier  = 1.5e11,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(255, 50, 150),
		grassColor       = Color3.fromRGB(40, 10, 30),
		pathColor        = Color3.fromRGB(20, 5, 15),
		ambientColor     = Color3.fromRGB(60, 20, 50),
		fogColor         = Color3.fromRGB(100, 20, 80),
		auraHolderColor  = Color3.fromRGB(255, 100, 200),
		auraHolderGlow   = Color3.fromRGB(255, 0, 150),
		lightingPreset   = "Area13_Neon", 
		auraModels       = { Common = "NeonTube", Uncommon = "PlasmaArc", Rare = "LaserDiode", Epic = "HardLight", Legendary = "PhotonCell" }
	},
	[14] = {
		name             = "Quantum Mechanics",
		threshold        = 5e62,
		valueMultiplier  = 1e14,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(255, 255, 255),
		grassColor       = Color3.fromRGB(200, 200, 255),
		pathColor        = Color3.fromRGB(150, 150, 200),
		ambientColor     = Color3.fromRGB(100, 100, 150),
		fogColor         = Color3.fromRGB(200, 200, 255),
		auraHolderColor  = Color3.fromRGB(255, 255, 255),
		auraHolderGlow   = Color3.fromRGB(100, 200, 255),
		lightingPreset   = "Area14_Quantum", 
		auraModels       = { Common = "Quark", Uncommon = "Tachyon", Rare = "Boson", Epic = "Tesseract", Legendary = "SchrodingerCat" }
	},
	[15] = {
		name             = "Celestial Matter",
		threshold        = 5e75,
		valueMultiplier  = 5e16,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(150, 200, 255),
		grassColor       = Color3.fromRGB(30, 40, 60),
		pathColor        = Color3.fromRGB(20, 25, 40),
		ambientColor     = Color3.fromRGB(40, 50, 80),
		fogColor         = Color3.fromRGB(80, 100, 150),
		auraHolderColor  = Color3.fromRGB(200, 230, 255),
		auraHolderGlow   = Color3.fromRGB(100, 150, 255),
		lightingPreset   = "Area15_Celestial", 
		auraModels       = { Common = "MoonRock", Uncommon = "MarsDust", Rare = "CometIce", Epic = "AsteroidCore", Legendary = "SolarFlare" }
	},
	[16] = {
		name             = "Cosmic Phenomena",
		threshold        = 5e90,
		valueMultiplier  = 2e19,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(200, 50, 255),
		grassColor       = Color3.fromRGB(20, 10, 40),
		pathColor        = Color3.fromRGB(10, 5, 20),
		ambientColor     = Color3.fromRGB(40, 20, 80),
		fogColor         = Color3.fromRGB(80, 30, 150),
		auraHolderColor  = Color3.fromRGB(255, 150, 255),
		auraHolderGlow   = Color3.fromRGB(150, 50, 255),
		lightingPreset   = "Area16_Cosmic", 
		auraModels       = { Common = "Stardust", Uncommon = "PulsarPulse", Rare = "QuasarLight", Epic = "SupernovaRemnant", Legendary = "GalaxySpiral" }
	},
	[17] = {
		name             = "Dark Matter",
		threshold        = 5e108,
		valueMultiplier  = 1e22,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(20, 0, 40),
		grassColor       = Color3.fromRGB(10, 0, 15),
		pathColor        = Color3.fromRGB(5, 0, 10),
		ambientColor     = Color3.fromRGB(15, 5, 30),
		fogColor         = Color3.fromRGB(5, 0, 10),
		auraHolderColor  = Color3.fromRGB(50, 0, 100),
		auraHolderGlow   = Color3.fromRGB(255, 0, 50),
		lightingPreset   = "Area17_DarkMatter", 
		auraModels       = { Common = "ShadowMatter", Uncommon = "VoidResidue", Rare = "EventHorizon", Epic = "Singularity", Legendary = "HawkingRadiation" }
	},
	[18] = {
		name             = "Multiversal Elements",
		threshold        = 5e128,
		valueMultiplier  = 5e25,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(0, 255, 255),
		grassColor       = Color3.fromRGB(30, 30, 30),
		pathColor        = Color3.fromRGB(15, 15, 15),
		ambientColor     = Color3.fromRGB(50, 50, 50),
		fogColor         = Color3.fromRGB(100, 200, 255),
		auraHolderColor  = Color3.fromRGB(255, 0, 255),
		auraHolderGlow   = Color3.fromRGB(0, 255, 255),
		lightingPreset   = "Area18_Multiverse", 
		auraModels       = { Common = "Paradox", Uncommon = "TimelineThread", Rare = "ParallelShard", Epic = "AlternateReality", Legendary = "MultiverseCore" }
	},
	[19] = {
		name             = "Pure Energy",
		threshold        = 5e150,
		valueMultiplier  = 2e29,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(255, 255, 200),
		grassColor       = Color3.fromRGB(200, 200, 150),
		pathColor        = Color3.fromRGB(255, 255, 200),
		ambientColor     = Color3.fromRGB(255, 255, 255),
		fogColor         = Color3.fromRGB(255, 255, 200),
		auraHolderColor  = Color3.fromRGB(255, 255, 255),
		auraHolderGlow   = Color3.fromRGB(255, 255, 150),
		lightingPreset   = "Area19_PureEnergy", 
		auraModels       = { Common = "Static", Uncommon = "Kinetic", Rare = "Thermal", Epic = "Ethereal", Legendary = "InfiniteEnergy" }
	},
	[20] = {
		name             = "The Absolute",
		threshold        = 5e175,
		valueMultiplier  = 1e34,
		yOffset          = -4.5,
		yRotation        = 180,
		auraPreviewColor = Color3.fromRGB(255, 215, 0),
		grassColor       = Color3.fromRGB(255, 255, 255),
		pathColor        = Color3.fromRGB(200, 200, 200),
		ambientColor     = Color3.fromRGB(255, 240, 200),
		fogColor         = Color3.fromRGB(255, 255, 255),
		auraHolderColor  = Color3.fromRGB(255, 215, 0),
		auraHolderGlow   = Color3.fromRGB(255, 255, 255),
		lightingPreset   = "Area20_TheAbsolute", 
		auraModels       = { Common = "Concept", Uncommon = "Truth", Rare = "Existence", Epic = "Reality", Legendary = "Omnipotence" }
	},
}

function AreaRegistry.Get(idx)            return AreaRegistry.Areas[idx] end
function AreaRegistry.GetName(idx)        return (AreaRegistry.Areas[idx] and AreaRegistry.Areas[idx].name) or ("Area "..idx) end
function AreaRegistry.GetThreshold(idx)   return AreaRegistry.Areas[idx] and AreaRegistry.Areas[idx].threshold or nil end
function AreaRegistry.GetMultiplier(idx)  return (AreaRegistry.Areas[idx] and AreaRegistry.Areas[idx].valueMultiplier) or 1.0 end
function AreaRegistry.GetYOffset(idx)     return (AreaRegistry.Areas[idx] and AreaRegistry.Areas[idx].yOffset)    or 0 end
function AreaRegistry.GetYRotation(idx)   return (AreaRegistry.Areas[idx] and AreaRegistry.Areas[idx].yRotation)  or 0 end

function AreaRegistry.GetFlipbook(idx)
	local area = AreaRegistry.Areas[idx]
	if not area or not area.flipbookImage then return nil end
	return {
		image = area.flipbookImage,
		frames = area.flipbookFrames or 1,
		fps = area.flipbookFPS or 12,
		frameW = area.flipbookFrameW or 128,
		frameH = area.flipbookFrameH or 128,
		columns = area.flipbookColumns or area.flipbookFrames or 1,
	}
end

function AreaRegistry.GetLighting(idx)
	local area = AreaRegistry.Areas[idx]
	if not area or not area.lightingPreset then return AreaRegistry.LightingPresets["ClearDay"] end
	return AreaRegistry.LightingPresets[area.lightingPreset] or AreaRegistry.LightingPresets["ClearDay"]
end

function AreaRegistry.GetMaxArea()
	local max = 0
	for k in pairs(AreaRegistry.Areas) do if k > max then max = k end end
	return max
end

function AreaRegistry.GetBestNextArea(currentArea, farmEvaluation)
	local maxArea  = AreaRegistry.GetMaxArea()
	local bestArea = nil
	for i = currentArea + 1, maxArea do
		local area = AreaRegistry.Areas[i]
		if area and farmEvaluation >= (area.threshold or 0) then
			bestArea = i
		end
	end
	return bestArea
end

function AreaRegistry.CanAdvance(currentArea, farmEvaluation)
	local best = AreaRegistry.GetBestNextArea(currentArea, farmEvaluation)
	if best then return true, best end
	return false, nil
end

-- =====================================================================
-- [NEW] 3-STEP FALLBACK HELPER: FETCHES 3D MODEL SAFELY
-- =====================================================================
function AreaRegistry.FetchAuraModel(areaIndex, rarityName)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local AreaAssets = ReplicatedStorage:FindFirstChild("AreaAssets")
	local GlobalAuras = ReplicatedStorage:FindFirstChild("Auras")

	local areaConfig = AreaRegistry.Areas[areaIndex]
	if not areaConfig then return nil end

	-- Step 1: Look up the mapped name (e.g., "CorrodedCore")
	local expectedModelName = areaConfig.auraModels and areaConfig.auraModels[rarityName]

	if expectedModelName and AreaAssets then
		-- Step 2: Look for it in ReplicatedStorage > AreaAssets > Area[X] > Auras
		local areaFolder = AreaAssets:FindFirstChild("Area" .. tostring(areaIndex))
		if areaFolder and areaFolder:FindFirstChild("Auras") then
			local specificModel = areaFolder.Auras:FindFirstChild(expectedModelName)
			if specificModel then
				return specificModel:Clone() -- Found specific!
			end
		end
		warn("[AreaRegistry] Missing physical model: " .. expectedModelName .. " in Area" .. tostring(areaIndex) .. ". Falling back to placeholder.")
	end

	-- Step 3: Fallback to the Global Blueprint Folder
	if GlobalAuras then
		local placeholderModel = GlobalAuras:FindFirstChild(rarityName)
		if placeholderModel then
			return placeholderModel:Clone() -- Found placeholder!
		end
	end

	warn("CRITICAL [AreaRegistry]: No custom model OR placeholder found for rarity: " .. tostring(rarityName))
	return nil
end

return AreaRegistry

-- BoostConfig
-- Location: ReplicatedStorage > Modules > BoostConfig
--
-- ONE place for all boost definitions. Replaces AdminConfig.Boosts.
-- BoostManager and BoostController read from this.
--
-- Each boost:
--   id            = key name (e.g. "AuraRush")
--   displayName   = shown in UI
--   description   = shown in shop card
--   icon          = "rbxassetid://12345" (must include full prefix!)
--   duration      = seconds (0 = instant/one-shot)
--   cost          = golden auras to buy
--   multiplier    = effect value (meaning depends on effectType)
--   effectType    = how the boost works:
--       "spawnSpeed"     — multiplies spawn rate
--       "cubeValue"      — multiplies cube value
--       "soulMult"       — multiplies soul aura gain on prestige
--       "hatcheryRefill" — multiplies hatchery refill rate
--       "instaRefill"    — instantly refills hatchery to max (one-shot)
--       "boostMultiplier"— multiplies ALL active boost effects
--       "cashCheck"      — gives currency = farmEval * multiplier (one-shot)
--   stackable     = can buy and activate multiple at once
--   maxStack      = max active stacks
--   category      = "Production" / "Value" / "Premium" / "Utility"
--   color         = accent Color3 for UI cards

local BoostConfig = {}

BoostConfig.Boosts = {

	-- ══════════ PRODUCTION ══════════

	AuraRush = {
		id          = "AuraRush",
		displayName = "Aura Rush",
		description = "Double spawn speed",
		icon        = "",   -- rbxassetid://YOUR_ID
		duration    = 30,
		cost        = 5,
		multiplier  = 2.0,
		effectType  = "spawnSpeed",
		stackable   = true,
		maxStack    = 3,
		category    = "Production",
		color       = Color3.fromRGB(60, 160, 255),
	},

	HatcheryRefill = {
		id          = "HatcheryRefill",
		displayName = "Fast Refill",
		description = "2x hatchery refill speed",
		icon        = "",
		duration    = 60,
		cost        = 8,
		multiplier  = 2.0,
		effectType  = "hatcheryRefill",
		stackable   = true,
		maxStack    = 3,
		category    = "Production",
		color       = Color3.fromRGB(80, 220, 120),
	},

	InstaHatchery = {
		id          = "InstaHatchery",
		displayName = "Insta Refill",
		description = "Instantly refill hatchery to max",
		icon        = "",
		duration    = 0,   -- one-shot
		cost        = 12,
		multiplier  = 1,
		effectType  = "instaRefill",
		stackable   = false,
		maxStack    = 1,
		category    = "Production",
		color       = Color3.fromRGB(0, 255, 180),
	},

	-- ══════════ VALUE ══════════

	SpawnBoost = {
		id          = "SpawnBoost",
		displayName = "Value Boost",
		description = "Double cube value",
		icon        = "",
		duration    = 45,
		cost        = 8,
		multiplier  = 2.0,
		effectType  = "cubeValue",
		stackable   = true,
		maxStack    = 3,
		category    = "Value",
		color       = Color3.fromRGB(255, 160, 40),
	},

	SoulBoost = {
		id          = "SoulBoost",
		displayName = "Soul Boost",
		description = "2x Soul Auras on prestige",
		icon        = "",
		duration    = 120,
		cost        = 15,
		multiplier  = 2.0,
		effectType  = "soulMult",
		stackable   = false,
		maxStack    = 1,
		category    = "Value",
		color       = Color3.fromRGB(180, 60, 255),
	},

	CashCheck = {
		id          = "CashCheck",
		displayName = "Cash Check",
		description = "Get 5x your farm evaluation as cash!",
		icon        = "",
		duration    = 0,   -- one-shot
		cost        = 20,
		multiplier  = 5,   -- currency = farmEval * 5
		effectType  = "cashCheck",
		stackable   = false,
		maxStack    = 1,
		category    = "Value",
		color       = Color3.fromRGB(80, 255, 80),
	},

	-- ══════════ PREMIUM — BOOST MULTIPLIERS ══════════
	-- Like Egg Inc's Boost Beacon — multiplies ALL active boosts

	BoostBeacon2x = {
		id          = "BoostBeacon2x",
		displayName = "Boost Beacon x2",
		description = "Double all active boost effects!",
		icon        = "",
		duration    = 30,
		cost        = 25,
		multiplier  = 2,
		effectType  = "boostMultiplier",
		stackable   = false,
		maxStack    = 1,
		category    = "Premium",
		color       = Color3.fromRGB(255, 100, 100),
	},

	BoostBeacon10x = {
		id          = "BoostBeacon10x",
		displayName = "Boost Beacon x10",
		description = "10x all active boost effects!",
		icon        = "",
		duration    = 15,
		cost        = 100,
		multiplier  = 10,
		effectType  = "boostMultiplier",
		stackable   = false,
		maxStack    = 1,
		category    = "Premium",
		color       = Color3.fromRGB(255, 60, 60),
	},

	BoostBeacon50x = {
		id          = "BoostBeacon50x",
		displayName = "Boost Beacon x50",
		description = "50x all active boost effects!! Insane!",
		icon        = "",
		duration    = 10,
		cost        = 500,
		multiplier  = 50,
		effectType  = "boostMultiplier",
		stackable   = false,
		maxStack    = 1,
		category    = "Premium",
		color       = Color3.fromRGB(255, 30, 30),
	},
}

---------------------------------------------------------------
-- DISPLAY ORDER — controls which boosts show in the shop
---------------------------------------------------------------
BoostConfig.ShopOrder = {
	"AuraRush", "HatcheryRefill", "InstaHatchery",
	"SpawnBoost", "SoulBoost", "CashCheck",
	"BoostBeacon2x", "BoostBeacon10x", "BoostBeacon50x",
}

---------------------------------------------------------------
-- CATEGORY ORDER — for grouping in shop
---------------------------------------------------------------
BoostConfig.Categories = { "Production", "Value", "Premium" }

BoostConfig.CategoryColors = {
	Production = Color3.fromRGB(60, 180, 255),
	Value      = Color3.fromRGB(255, 200, 60),
	Premium    = Color3.fromRGB(255, 60, 80),
}

---------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------
function BoostConfig.Get(id)
	return BoostConfig.Boosts[id]
end

function BoostConfig.GetByCategory(category)
	local result = {}
	for _, id in ipairs(BoostConfig.ShopOrder) do
		local b = BoostConfig.Boosts[id]
		if b and b.category == category then
			table.insert(result, b)
		end
	end
	return result
end

return BoostConfig

local EpicUpgradeConfig = {}

-- 1. TABS REMOVED: Everything sits in one clean panel now!
EpicUpgradeConfig.Tabs = {"Epic"} 

-- 2. DYNAMIC SCALING MATH
local function scaleCost(base, growth, level)
	return math.floor(base * math.pow(growth, level))
end

-- 3. THE UPGRADES
EpicUpgradeConfig.Tiers = {
	{
		tierName = "Permanent Upgrades",
		unlockRequirement = 0,
		upgrades = {
			["epicAuraValue"] = {
				displayName = "Aura Value Multiplier",
				description = "Permanently increases the base value of all generated Auras by +10% per level.",
				iconId = "rbxassetid://14923131909", 
				maxLevel = 50, category = "Epic", baseCost = 10, costGrowth = 1.3,
				apply = function(d) return 1 + ((d.epicUpgrades and d.epicUpgrades.epicAuraValue) or 0) * 0.1 end
			},
			["epicHoldSpeed"] = {
				displayName = "Turbo Purchasing",
				description = "Increases how fast you buy regular upgrades when holding down the button.",
				iconId = "rbxassetid://14923131909", 
				maxLevel = 10, category = "Epic", baseCost = 25, costGrowth = 1.5,
				apply = function(d) return 1 + ((d.epicUpgrades and d.epicUpgrades.epicHoldSpeed) or 0) * 0.3 end
			},
			["epicMoveSpeed"] = {
				displayName = "Swiftness",
				description = "Permanently increases your character's walking speed.",
				iconId = "rbxassetid://14923131909", 
				maxLevel = 15, category = "Epic", baseCost = 15, costGrowth = 1.4,
				apply = function(d) return ((d.epicUpgrades and d.epicUpgrades.epicMoveSpeed) or 0) * 1 end
			},
			["epicClickMilestone"] = {
				displayName = "Milestone Momentum",
				description = "Reduces the clicks/time required to reach the next clicker milestone.",
				iconId = "rbxassetid://14923131909", 
				maxLevel = 20, category = "Epic", baseCost = 50, costGrowth = 1.6,
				apply = function(d) return ((d.epicUpgrades and d.epicUpgrades.epicClickMilestone) or 0) * 2 end
			},
			["epicPrestigeReward"] = {
				displayName = "Soul Aura Mastery",
				description = "Increases the amount of Soul Auras you receive when prestiging by +5% per level.",
				iconId = "rbxassetid://14923131909", 
				maxLevel = 25, category = "Epic", baseCost = 100, costGrowth = 1.8,
				apply = function(d) return 1 + ((d.epicUpgrades and d.epicUpgrades.epicPrestigeReward) or 0) * 0.05 end
			},
			["epicShipCooldown"] = {
				displayName = "Logistics Overdrive",
				description = "Permanently decreases the cooldown time of shipping auras by 0.5s per level.",
				iconId = "rbxassetid://14923131909", 
				maxLevel = 10, category = "Epic", baseCost = 40, costGrowth = 1.5,
				apply = function(d) 
					-- Returns how many seconds to shave off (Level 1 = 0.5s, Level 10 = 5s)
					return ((d.epicUpgrades and d.epicUpgrades.epicShipCooldown) or 0) * 0.5 
				end
			},

		}

	}
}

function EpicUpgradeConfig.GetUpgradeConfig(upgradeId)
	for _, tierData in ipairs(EpicUpgradeConfig.Tiers) do
		if tierData.upgrades[upgradeId] then return tierData.upgrades[upgradeId] end
	end
	return nil
end

function EpicUpgradeConfig.CalculateCost(upgradeId, currentLevel)
	local cfg = EpicUpgradeConfig.GetUpgradeConfig(upgradeId)
	if not cfg then return math.huge end
	if currentLevel >= cfg.maxLevel then return math.huge end
	return scaleCost(cfg.baseCost, cfg.costGrowth, currentLevel)
end

EpicUpgradeConfig.TabColors = { Epic = Color3.fromRGB(150, 80, 255) }
return EpicUpgradeConfig

-- MailConfig
-- Location: ReplicatedStorage > Modules > MailConfig
--
-- ONE place for every mail message in the game.
-- Same pattern as TutorialConfig — edit the table below.
--
-- Each mail entry:
--   id           = unique name (never change after release)
--   trigger      = when this mail becomes available (see TRIGGER TYPES)
--   triggerValue = optional threshold for the trigger
--   title        = mail subject line
--   body         = message body text
--   icon         = image asset ID ("" = no icon)
--   sender       = who it's from (displayed as "From: sender")
--   rewards      = table of rewards given on claim:
--                    goldenAuras = number
--                    currency    = number
--                    boosts      = { AuraRush = count, SpawnBoost = count, ... }
--   color        = accent Color3 (nil = default gold)
--   area         = optional area requirement (nil = any area)
--   oneTime      = true (default) — mail can only be claimed once ever
--
-- TRIGGER TYPES (same as TutorialConfig + extras):
--   "areaEnter"       — entering a specific area
--   "firstCube"       — first cube spawned (any run)
--   "firstShip"       — first platform shipped
--   "firstUpgrade"    — first upgrade purchased
--   "firstPrestige"   — first prestige completed
--   "currencyReached" — currency >= triggerValue
--   "farmEvalReached" — farmEval >= triggerValue
--   "portalReady"     — portal opens
--   "prestigeCount"   — prestige count >= triggerValue
--   "soulAurasReached" — soul auras >= triggerValue
--   "goldenAurasReached" — golden auras >= triggerValue
--   "timerElapsed"    — seconds since area enter >= triggerValue
--   "giftCollected"   — collected first gift
--   "always"          — available immediately on join
--   "manual"          — call shared.SendMail("mailId") from any script

local MailConfig = {}

---------------------------------------------------------------
-- DEFAULTS
---------------------------------------------------------------
MailConfig.DefaultColor  = Color3.fromRGB(255, 255, 255)
MailConfig.DefaultIcon   = ""
MailConfig.DefaultSender = "Aura Inc"

---------------------------------------------------------------
-- MAIL ENTRIES — edit freely
---------------------------------------------------------------
MailConfig.Entries = {

	-- ══════════ WELCOME / ONBOARDING ══════════

	{
		id       = "mail_welcome",
		trigger  = "always",
		title    = "Welcome to Aura Inc!",
		body     = "Thank You For Even Trying out Aura Inc my first Incremental I've made. Also here's some Golden Auras for a small boost!",
		icon     = "rbxassetid://6031075938",
		sender   = "Aura Inc",
		rewards  = { goldenAuras = 10 },
		color    = Color3.fromRGB(80, 220, 160),
	},

	-- ══════════ PROGRESSION REWARDS ══════════

	{
		id           = "mail_first_prestige",
		trigger      = "firstPrestige",
		title        = "First Prestige Reward",
		body         = "You prestiged for the first time! Here's a bonus to celebrate.",
		icon         = "rbxassetid://14914101465",
		sender       = "Soul Department",
		rewards      = { goldenAuras = 25 },
		color        = Color3.fromRGB(176, 17, 220),
	},
	{
		id           = "mail_area2",
		trigger      = "areaEnter",
		triggerValue = nil,
		area         = 2,
		title        = "Unlocking Uncommon Area",
		body         = "More Rewards! For Reaching the 2nd Area of 5 in this tutorial.",
		icon         = "rbxassetid://14914000799",
		sender       = "Area Management",
		rewards      = { goldenAuras = 30 },
		color        = Color3.fromRGB(100, 200, 100),
	},
	{
		id           = "mail_area3",
		trigger      = "areaEnter",
		area         = 3,
		title        = "Unlocking Rare Area",
		body         = "Even More Rewards, Hopefully your getting used to the loop by now but don't worry I try to keep things interesting as you go on.",
		icon         = "rbxassetid://14914000799",
		sender       = "Area Management",
		rewards      = { goldenAuras = 40 },
		color        = Color3.fromRGB(80, 120, 255),
	},
	{
		id           = "mail_area4",
		trigger      = "areaEnter",
		area         = 4,
		title        = "Unlocking Epic Area",
		body         = "Even Bigger Rewards, Now and later stages rewards Golden Auras AND Boosts now So Keep Going!",
		icon         = "rbxassetid://14914000799",
		sender       = "Area Management",
		rewards      = { goldenAuras = 50, boosts = { AuraRush = 3 } },
		color        = Color3.fromRGB(187, 24, 220),
	},
	{
		id           = "mail_area5",
		trigger      = "areaEnter",
		area         = 5,
		title        = "Finishing the Tutorial",
		body         = "Huge Rewards and the final area before your ready to actually start grinding or progressing. Enjoy the boosts and use them wisely, Props to making it here!",
		icon         = "rbxassetid://14914000799",
		sender       = "Area Management",
		rewards      = { goldenAuras = 100, boosts = { AuraRush = 6, SpawnBoost = 6, SoulBoost = 2 } },
		color        = Color3.fromRGB(255, 200, 50),
	},

	-- ══════════ MILESTONE REWARDS ══════════

	{
		id           = "mail_prestige50",
		trigger      = "prestigeCount",
		triggerValue = 50,
		title        = "Getting A Bit of Soul Auras",
		body         = "Soul Auras Are Extremely Important to keep progressing so make sure to use boosts and time your Prestiges correctly.",
		icon         = "rbxassetid://14915578013",
		sender       = "Prestige Office",
		rewards      = { goldenAuras = 50 },
		color        = Color3.fromRGB(202, 12, 255),
	},
	{
		id           = "mail_prestige250",
		trigger      = "prestigeCount",
		triggerValue = 250,
		title        = "Getting A Few Soul Auras",
		body         = "Remember you can only prestige once per area and going to the next area also counts as one so Keep Prestiging!",
		icon         = "rbxassetid://14914245158",
		sender       = "Prestige Office",
		rewards      = { goldenAuras = 100 },
		color        = Color3.fromRGB(200, 120, 255),
	},
	{
		id           = "mail_souls1000",
		trigger      = "soulAurasReached",
		triggerValue = 1000,
		title        = "Quite A Bit Of Soul Auras",
		body         = "Im sure you have prestiges down by now, Its recommended to min max and see how much Soul Auras you can squeeze out each prestige.",
		icon         = "rbxassetid://14914245158",
		sender       = "Soul Aura Research",
		rewards      = { goldenAuras = 250 },
		color        = Color3.fromRGB(160, 100, 255),
	},
	{
		id           = "mail_souls10000",
		trigger      = "soulAurasReached",
		triggerValue = 10000,
		title        = "Decent Amount of Soul Auras",
		body         = "Crazy Work, Prestiges scale on your rate and how much your making so letting auras sit for prestiges is usually a great play",
		icon         = "rbxassetid://14914245158",
		sender       = "Soul Aura Research",
		rewards      = { goldenAuras = 500 },
		color        = Color3.fromRGB(160, 100, 255),
	},
	{
		id           = "mail_souls100000",
		trigger      = "soulAurasReached",
		triggerValue = 100000,
		title        = "Crazy Amount of Soul Auras",
		body         = "Yea, I Don't have anymore tips but check out other boosts and earning increasing options as you unlock new areas.",
		icon         = "rbxassetid://14914245158",
		sender       = "Soul Aura Research",
		rewards      = { goldenAuras = 1000 },
		color        = Color3.fromRGB(160, 100, 255),
	},
	{
		id           = "mail_souls1000000",
		trigger      = "soulAurasReached",
		triggerValue = 1000000,
		title        = "Absolute Amount of Soul Auras",
		body         = "Check out some challenges you can do for more Soul Auras, Golden Auras, Or Progression there. Hopefully your not stuck in an area.",
		icon         = "rbxassetid://14914245158",
		sender       = "Soul Aura Research",
		rewards      = { goldenAuras = 5000 },
		color        = Color3.fromRGB(160, 100, 255),
	},

	-- ══════════ ADD YOUR OWN BELOW ══════════
}

---------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------
function MailConfig.GetEntry(id)
	for _, entry in ipairs(MailConfig.Entries) do
		if entry.id == id then return entry end
	end
	return nil
end

function MailConfig.GetAllIds()
	local ids = {}
	for _, entry in ipairs(MailConfig.Entries) do
		table.insert(ids, entry.id)
	end
	return ids
end

return MailConfig

-- ============================================================
-- MutationConfig
-- Location: ReplicatedStorage > Modules > MutationConfig
-- CHANGES FROM PHASE 2:
--   ValueBonuses first entry time: 15s (was 30s)
--   First +50% value bonus now hits at 15 seconds instead of 30.
--   Kills the dead zone immediately after spawn/prestige.
--   The bonus amount (+50%) is unchanged — cubes just get there faster.
-- ============================================================
local MutationConfig = {}

---------------------------------------------------------------
-- Value bonus: one quick +50% at 15 seconds, then done.
-- Phase 3 change: was 30s, now 15s to kill the post-prestige
-- dead zone. Cubes feel alive much sooner after spawning.
---------------------------------------------------------------
MutationConfig.ValueBonuses = {
	{ time = 0,   bonus = 0.00 },  -- spawned value (no bonus)
	{ time = 15,  bonus = 0.50 },  -- +50% value at 15 seconds (was 30s)
}

---------------------------------------------------------------
-- Tier upgrade rolls — unchanged from Phase 2.
---------------------------------------------------------------
MutationConfig.TierUpgrades = {
	{ time = 300,  chance = 0.15 },  -- 5 min:  15% to upgrade one tier
	{ time = 600,  chance = 0.40 },  -- 10 min: 40% to upgrade one tier
	{ time = 1800, chance = 1.00 },  -- 30 min: guaranteed upgrade
}

---------------------------------------------------------------
-- AFK diminishing returns on mutation speed — unchanged.
---------------------------------------------------------------
MutationConfig.AFKDecay = {
	{ time = 0,    speed = 1.0 },
	{ time = 1800, speed = 0.5 },
	{ time = 7200, speed = 0.1 },
}

---------------------------------------------------------------
-- Server mutation check interval (seconds).
---------------------------------------------------------------
MutationConfig.CheckInterval = 1.0

function MutationConfig.GetMutatedValue(cube)
	if not cube then return 0 end -- ADDED: The safety net!

	local bonus = 0
	for _, entry in ipairs(MutationConfig.ValueBonuses) do
		if cube.effectiveElapsed >= entry.time then bonus = entry.bonus end
	end
	return math.floor(cube.baseValue * (1 + bonus))
end

---------------------------------------------------------------
-- Utility: get current value bonus level for visual feedback.
---------------------------------------------------------------
function MutationConfig.GetValueBonusLevel(effectiveElapsed)
	local level = 0
	for i, entry in ipairs(MutationConfig.ValueBonuses) do
		if effectiveElapsed >= entry.time then level = i end
	end
	return level
end

return MutationConfig

local NumberFormatter = {}

-- Standard suffixes: k, M, B, T, Qa, Qi, Sx, Sp, Oc, No, Dc
local standardSuffixes = {"", "k", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

-- Roman Numerals for the Rank Style (Past Decillion)
local romanNumerals = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"}

function NumberFormatter.Format(n)
	-- 1. Safety check for nil or small numbers
	if not n then return "0" end

	-- 2. Handle numbers under 1000 with proper Cents (2 decimals)
	if n < 1000 then
		-- If it's a whole number (e.g. 5.0), keep it clean as "5"
		if n == math.floor(n) then
			return tostring(math.floor(n))
		else
			-- If it's a decimal, format to 2 places (cents)
			local str = string.format("%.2f", n)
			-- Strip unnecessary trailing zeros so it looks clean (0.50 -> 0.5)
			str = str:gsub("0+$", ""):gsub("%.$", "")
			return str
		end
	end

	-- 3. Calculate the thousand-step (exponent)
	local exp = math.floor(math.log10(n) / 3)
	local shortVal = n / (10 ^ (exp * 3))

	-- 4. Suffix Logic
	if exp < #standardSuffixes then
		-- Use standard suffixes (k through Dc)
		local suffix = standardSuffixes[exp + 1]
		return string.format("%.2f%s", shortVal, suffix)
	else
		-- THE RANK ASCENSION (ΩI, ΩII, etc.)
		local romanIndex = (exp - #standardSuffixes) + 1
		local numeral = romanNumerals[romanIndex] or "∞"
		return string.format("%.2f Ω%s", shortVal, numeral)
	end
end

return NumberFormatter

-- PrestigeModule
-- Location: ReplicatedStorage > Modules > PrestigeModule
--
-- Formula: floor(totalEarned ^ 0.21 * 5)
--
-- SOUL AURA PAYOUT:
--   $1K        →  21 SA
--   $10K       →  34 SA
--   $50K       →  48 SA    ← typical early prestige
--   $100K      →  56 SA
--   $500K      →  78 SA    ← Area 1 portal threshold
--   $1M        →  90 SA
--   $1B        →  388 SA
--
-- EARNINGS BONUS: +15% per Soul Aura
--   21 SA  =  4.2x
--   56 SA  =  9.4x
--   78 SA  = 12.7x
--   100 SA = 16x

local PrestigeModule = {}

local EXPONENT     = 0.21
local COEFFICIENT  = 5      -- was 0.5, bumped to 5 for Egg Inc parity
local BONUS_PER_SA = 0.10

function PrestigeModule.CalcSoulAuras(totalEarned)
	if totalEarned <= 0 then return 0 end
	return math.floor((totalEarned ^ EXPONENT) * COEFFICIENT)
end

function PrestigeModule.GetMultiplier(soulAuras)
	return 1 + ((soulAuras or 0) * BONUS_PER_SA)
end

-- Exported so PrestigeController stays in sync
PrestigeModule.EXPONENT     = EXPONENT
PrestigeModule.COEFFICIENT  = COEFFICIENT
PrestigeModule.BONUS_PER_SA = BONUS_PER_SA

return PrestigeModule

-- SoundConfig
-- Location: ReplicatedStorage > Modules > SoundConfig
--
-- ONE place for every sound ID in the game.
-- Fill in the number only — e.g. "9120386358"
-- Leave "" to silence that sound, nothing will error.
-- SoundManager prepends "rbxassetid://" automatically.

local SoundConfig = {}

---------------------------------------------------------------
-- UI
---------------------------------------------------------------
SoundConfig.UIOpen    = "3785105076"   -- any panel opening
SoundConfig.UIClose   = "3785105076"   -- any panel closing / X button
SoundConfig.UIClick   = "6895079853"   -- generic button press
SoundConfig.UIArrow   = "6895079853"             -- ← / → navigation arrows in Area Travel panel

---------------------------------------------------------------
-- PRESTIGE
---------------------------------------------------------------
SoundConfig.PrestigeReady    = "3314301672"             -- prestige button fades from grey → purple (ready to prestige)
SoundConfig.PrestigeConfirm  = "3601621507"   -- prestige confirm button pressed
SoundConfig.PrestigeComplete = "3601621507"   -- prestige flash fires

---------------------------------------------------------------
-- INTERACTION
---------------------------------------------------------------
SoundConfig.Click         = "6895079853"  -- cube spawned
SoundConfig.HoldStart     = ""
SoundConfig.HoldLoop      = ""
SoundConfig.HatcheryEmpty = "2390695935"
SoundConfig.HabitatFull   = "2390695935"
---------------------------------------------------------------
-- SHIPPING / PAYOUT
---------------------------------------------------------------
SoundConfig.PlatformArrive = "588738949"
SoundConfig.PlatformLeave  = "2609873966"

---------------------------------------------------------------
-- MUTATION / UPGRADE
---------------------------------------------------------------
SoundConfig.TierUpgrade    = "3314301672"
SoundConfig.LegendarySpawn = "3932668730"
SoundConfig.MutationBonus  = ""
SoundConfig.Purchase       = ""

---------------------------------------------------------------
-- PORTAL / AREA
---------------------------------------------------------------
SoundConfig.PortalOpen  = "4459057403"
SoundConfig.PortalEnter = ""

--Tutorial Hints
SoundConfig.TutorialHint = "123882484934579"      -- plays when tutorial popup appears
SoundConfig.GiftCollect  = ""      -- plays when collecting a gift drop
---------------------------------------------------------------
-- AREA MUSIC
---------------------------------------------------------------
SoundConfig.AreaMusic = {
	[1] = "1846271108",
	[2] = "1848354536",
	[3] = "105440555341398",
	[4] = "75517802356532",
	[5] = "127559941651252",
	[6] = "1848354536",
}

---------------------------------------------------------------
-- VOLUME PER CATEGORY
---------------------------------------------------------------
SoundConfig.Volume = {
	ui          = 0.3,
	interaction = 0.6,
	mutation    = 0.3,
	prestige    = 0.9,
	portal      = 1.0,
	music       = 0.1,
	shipping    = 0.5,
}

return SoundConfig

-- =====================================================================
-- 2. MODULE: TierConfig
-- Location: ReplicatedStorage > Modules > TierConfig
-- =====================================================================
local AdminConfig = require(game:GetService("ReplicatedStorage").Modules.AdminConfig)
local TierConfig = {}

-- Chances must add up to exactly 1.0 (100%) for the math.random() to be perfectly accurate
TierConfig.Tiers = {
	{ name = "Common",    chance = 0.74,     multiplier = 1,     color = Color3.fromRGB(220, 220, 220), glow = false },
	{ name = "Uncommon",  chance = 0.17,     multiplier = 1.5,   color = Color3.fromRGB(80, 200, 80),   glow = true  },
	{ name = "Rare",      chance = 0.06,     multiplier = 3,     color = Color3.fromRGB(60, 120, 255),  glow = true  },
	{ name = "Epic",      chance = 0.02,     multiplier = 8,     color = Color3.fromRGB(180, 60, 255),  glow = true  },
	{ name = "Legendary", chance = 0.008,    multiplier = 25,    color = Color3.fromRGB(255, 200, 0),   glow = true  },

	-- --- THE ELITE TIERS (6 through 10) ---
	{ name = "Mythic",    chance = 0.0015,   multiplier = 75,    color = Color3.fromRGB(255, 60, 120),  glow = true  }, -- 0.15%
	{ name = "Divine",    chance = 0.00035,  multiplier = 200,   color = Color3.fromRGB(0, 255, 255),   glow = true  }, -- 0.035%
	{ name = "Celestial", chance = 0.0001,   multiplier = 750,   color = Color3.fromRGB(255, 250, 150), glow = true  }, -- 0.01%
	{ name = "Cosmic",    chance = 0.00004,  multiplier = 2500,  color = Color3.fromRGB(100, 0, 255),   glow = true  }, -- 0.004%
	{ name = "Omni",      chance = 0.00001,  multiplier = 10000, color = Color3.fromRGB(255, 20, 60),   glow = true  }, -- 0.001%
}

if AdminConfig.TierOverride then
	TierConfig.Tiers = AdminConfig.TierOverride
end

function TierConfig.Roll()
	local r = math.random()
	local cumulative = 0
	for _, tier in ipairs(TierConfig.Tiers) do
		cumulative += tier.chance
		if r <= cumulative then return tier end
	end
	return TierConfig.Tiers[1] -- Failsafe
end

return TierConfig

-- TutorialConfig
-- Location: ReplicatedStorage > Modules > TutorialConfig

local TutorialConfig = {}

TutorialConfig.TutorialEndArea = 5

TutorialConfig.DefaultDuration = 4
TutorialConfig.DefaultDelay    = 0
TutorialConfig.DefaultColor    = Color3.fromRGB(255, 255, 255)
TutorialConfig.DefaultIcon     = "rbxassetid://14914018910"

TutorialConfig.Steps = {

	-- ══════════ AREA 1: COMMON ══════════
	-- CHAIN 1: The Spawning Loop
	{
		id           = "a1_hello",
		area         = 1,
		trigger      = "areaEnter",
		title        = "Welcome to Aura Inc!",
		body         = "Spam Click the Red Button to Produce Auras!",
		target       = "ClickButton", 
		isMandatory  = true, 
		bannerPos    = "Center",
		unlockUI     = {"ClickButton", "HatcheryBar", "CurrencyLabel", "RateLabel"},
		nextStep     = "a1_hold", -- 💥 CHANGED: Skipped the cube hint. Straight to action.
		icon         = "rbxassetid://14922082255",
	},
	{
		id           = "a1_hold",
		area         = 1,
		trigger      = "chain",
		title        = "Hold For Multipliers",
		body         = "Hold the Red Button! Higher multipliers = More Cash!",
		target       = "ClickButton", 
		isMandatory  = true, 
		holdDuration = 1.5, 
		bannerPos    = "Center",
		nextStep     = "a1_mailbox", -- 💥 CHANGED: Skipped the 10-second wait hint.
		icon         = "rbxassetid://14924185885",
	},
	{
		id           = "a1_mailbox",
		area         = 1,
		trigger      = "chain",
		title        = "Check The Mail!",
		body         = "Click the MailBox to claim FREE Rewards!",
		unlockUI     = "Mailbox",
		isMandatory  = true, 
		bannerPos    = "Center",
		icon         = "rbxassetid://14921813212",
		duration = 10
	},

	-- CHAIN 2: The Economy Loop
	{
		id           = "a1_habitat_full",
		area         = 1,
		trigger      = "habitatFull",
		title        = "Your Habitat is Full!",
		body         = "Your storage is full! Click the Blue Button to send a ship and FREE up SPACE!",
		target       = "SendShipBtn", 
		isMandatory  = true, 
		bannerPos    = "Center",
		unlockUI     = "SendShipBtn",  
		nextStep     = "a1_ship_toggle", 
		icon         = "rbxassetid://14914018910",
	},
	{
		id           = "a1_ship_toggle",
		area         = 1,
		trigger      = "chain",
		title        = "Automation",
		body         = "Click here to toggle Auto-Shipping so you don't have to do it manually!",
		target       = "ToggleShipBtn",
		isMandatory  = true,
		bannerPos    = "Center",
		unlockUI     = "ModeToggle", 
		nextStep     = "a1_buy_upgrade", 
		icon         = "rbxassetid://14914018910",
	},
	{
		id           = "a1_buy_upgrade",
		area         = 1,
		trigger      = "chain",
		title        = "Research Shop",
		body         = "Time to upgrade! Click the Shop Button.",
		target       = "ShopButton",
		unlockUI     = "ShopButton",
		isMandatory  = true,
		bannerPos    = "Center",
		nextStep     = "a1_buy_first_upgrade", 
		icon         = "rbxassetid://14917128076",
	},
	{
		id           = "a1_buy_first_upgrade",
		area         = 1,
		trigger      = "chain",
		title        = "Buy Your First Upgrade",
		body         = "Click the green $50 button to increase your Aura Value!",
		target       = "Buy_blockValue", 
		bannerPos    = "Top",
		isMandatory  = true, 
		nextStep     = "a1_close_shop",
		icon         = "rbxassetid://14914018910",
	},
	{
		id           = "a1_close_shop",
		area         = 1,
		trigger      = "chain",
		title        = "Close The Shop",
		body         = "Click the Red X to close the shop.",
		unlockUI     = "ShopCloseBtn",
		isMandatory  = true, 
		target       = "ShopCloseBtn", 
		bannerPos    = "Top",
		icon         = "rbxassetid://14915225073",
		-- Stops here and waits for them to hit 20,000 Eval
	},
	
	

	-- CHAIN 3: Prestige and Progress
	{
		id           = "a1_try_prestige",
		area         = 1,
		trigger      = "farmEvalReached",
		triggerValue = 20000,
		title        = "Try Prestiging!",
		body         = "Click the Prestige button to permanently multiply your earnings!",
		target       = "PrestigeButton", 
		isMandatory  = true, 
		bannerPos    = "Center",
		unlockUI     = {"MainPrestigeBtn", "SoulAuraDisplay"},
		nextStep     = "a1_prestige_button",
		icon         = "rbxassetid://14916846070",
	},
	{
		id           = "a1_prestige_button",
		area         = 1,
		trigger      = "chain",
		title        = "Prestige Now",
		body         = "Prestige now to get your first permanent earnings increase!",
		unlockUI     = {"PrestigeBtns", "PrestigeCloseBtn"},
		isMandatory  = true, 
		target       = "PrestigeBtns", 
		bannerPos    = "Top",
		icon         = "rbxassetid://14923411730",
		nextStep     = "a1_close_prestige",
	},
	{
		id           = "a1_progress",
		area         = 1,
		trigger      = "farmEvalReached",        
		triggerValue = 50000,                    
		title        = "Next Area Unlocked",
		body         = "Click the Travel button to move to the next area!",
		unlockUI     = {"AreaTravelButton", "PortalCloseBtn"},
		target       = "AreaTravelButton", 
		isMandatory  = true, 
		requirePrestige = true,                  
		requireStep  = "a1_prestige_button",    
		bannerPos    = "Center",
		nextStep     = "a1_arrow_button",        
		icon         = "rbxassetid://14914000799",
	},
	{
		id           = "a1_arrow_button",
		area         = 1,
		trigger      = "chain",
		title        = "Select The Area",
		body         = "Click the arrow to view the Uncommon Area!",
		target       = "ArrowBtn",
		isMandatory  = true, 
		bannerPos    = "Top",
		unlockUI     = "ArrowBtn",
		nextStep     = "a1_next_area",
		icon         = "rbxassetid://14914018910",
	},
	{
		id           = "a1_next_area",
		area         = 1,
		trigger      = "chain",
		title        = "Uncommon Area",
		body         = "Click Travel to progress to the Uncommon Area!",
		target       = "TravelBtn",
		unlockUI     = {"TravelBtn", "PortalCloseBtn"},
		isMandatory  = true, 
		icon         = "rbxassetid://14914018910",
	},
	{
		id           = "a1_stuck_prestige",
		area         = 1,
		trigger      = "timerElapsed",
		triggerValue = 600,
		title        = "Keep Going!",
		body         = "If you feel stuck make sure to prestige and Upgrade more. Also Use Boosts To Help escpecially the Value Booster!",
	},
	


	---- ══════════ AREA 2: UNCOMMON ══════════
	--{
	--	id           = "a2_welcome",
	--	area         = 2,
	--	trigger      = "areaEnter",
	--	title        = "How To Boost",
	--	body         = "Click On The Boost Button",
	--	target       = "BoostsButton", 
	--	isMandatory  = true, 
	--	bannerPos    = "Center",
	--	unlockUI = 		"BoostsButton",
	--	nextStep     = "a2_click_boost",
	--	icon = "rbxassetid://14914018910",
	--},

	--{
	--	id           = "a2_click_boost",
	--	area         = 2,
	--	trigger      = "chain",
	--	delay        = 10,
	--	title        = "Buy A Spawn Speed Boost",
	--	body         = "Use your GOLDEN AURAS to BUY this BOOST",
	--	isMandatory  = true, 
	--	target       = "BoostsButton", 
	--	unlockUI = 		"BoostsButton",
	--	icon = "rbxassetid://14914018910",

	--},


	-- ══════════ AREA 3: RARE ══════════
	-- CHAIN 4: Golden Bank 
	--{
	--	id           = "a3_golden_auras",
	--	area         = 3,
	--	trigger      = "areaEnter",
	--	title        = "Placeholder Title 21",
	--	body         = "Placeholder text for step 21.",
	--	nextStep     = "a3_golden_aura_bank",
	--},
	--{
	--	id           = "a3_golden_aura_bank",
	--	area         = 3,
	--	trigger      = "chain",
	--	title        = "Placeholder Title 22",
	--	body         = "Placeholder text for step 22.",
	--	cameraTarget = "GoldenBankModel", -- Replace with actual model name
	--	nextStep     = "a3_golden_aura_break",
	--},
	--{
	--	id           = "a3_golden_aura_break",
	--	area         = 3,
	--	trigger      = "chain",
	--	title        = "Placeholder Title 23",
	--	body         = "Placeholder text for step 23.",
	--	cameraTarget = "GoldenBankModel",
	--	nextStep     = "a3_epic_research",
	--},


	-- ══════════ AREA 4: EPIC ══════════
	-- AREA 4 EVENTS EPIC RESEARCH HERE
	--{
	--	id           = "a4_welcome",
	--	area         = 4,
	--	trigger      = "areaEnter",
	--	title        = "Placeholder Title 25",
	--	body         = "Placeholder text for step 25.",
	--},
	--{
	--	id           = "a4_boost_hint",
	--	area         = 4,
	--	trigger      = "currencyReached",
	--	triggerValue = 5000,
	--	title        = "Placeholder Title 26",
	--	body         = "Placeholder text for step 26.",
	--},
	--{
	--	id           = "a4_combo_boost",
	--	area         = 4,
	--	trigger      = "boostActivated",
	--	title        = "Placeholder Title 27",
	--	body         = "Placeholder text for step 27.",
	--},


	-- ══════════ AREA 5: LEGENDARY ══════════
--	-- AREA 5 EVENTS
--	{
--		id           = "a5_welcome",
--		area         = 5,
--		trigger      = "areaEnter",
--		title        = "Placeholder Title 28",
--		body         = "Placeholder text for step 28.",
--	},
--	{
--		id           = "a5_graduation",
--		area         = 5,
--		trigger      = "portalReady",
--		title        = "Placeholder Title 29",
--		body         = "Placeholder text for step 29.",
--	},
}

---------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------
function TutorialConfig.GetStepsForArea(area)
	local result = {}
	for _, step in ipairs(TutorialConfig.Steps) do
		if step.area == area then table.insert(result, step) end
	end
	return result
end

function TutorialConfig.GetStep(id)
	for _, step in ipairs(TutorialConfig.Steps) do
		if step.id == id then return step end
	end
	return nil
end

return TutorialConfig



-- UIConfig
-- Location: ReplicatedStorage > Modules > UIConfig
--
-- ONE place to change every size in the game's UI.
-- All UI scripts read from UIConfig at startup.

local UIConfig = {}

---------------------------------------------------------------
-- HUD — bottom bar buttons and displays
---------------------------------------------------------------
UIConfig.HUD = {
	PrestigeButtonW  = 90,
	PrestigeButtonH  = 40,
	NextAreaButtonW  = 100,
	NextAreaButtonH  = 40,
	SettingsButtonW  = 36,
	SettingsButtonH  = 36,
	BottomButtonY    = -55,

	SADisplayW       = 160,
	SADisplayH       = 70,
	SADisplayY       = -135,

	BoostSlotW       = 160,
	BoostSlotH       = 36,
	BoostStripYBase  = 145,

	ShopButtonW      = 80,
	ShopButtonH      = 40,
	BoostsButtonW    = 80,
	BoostsButtonH    = 40,
}

---------------------------------------------------------------
-- PANELS — popup panel dimensions
---------------------------------------------------------------
UIConfig.Panels = {
	AreaTravelW      = 340,
	AreaTravelH      = 440,
	SettingsPanelW   = 240,
	SettingsPanelH   = 320,
	BoostShopW       = 320,
	BoostShopH       = 420,
	UpgradeShopW     = 400,
	UpgradeShopH     = 460,
	CornerRadius     = 14,
}

---------------------------------------------------------------
-- DIALOG — Prestige confirmation dialog
--
-- HOW TO MAKE TEXT BIGGER:
--   1. Increase the label height values below (e.g. EarnedH = 42)
--   2. Increase H to match — H should be roughly:
--      HeaderH + EarnedH + BoostH + MultH + TotalH + HintH
--      + BonusH + WarningH + ConfirmBtnH + ~50 padding
--   The text inside each label scales to fill its height,
--   so bigger height = bigger text automatically.
---------------------------------------------------------------
UIConfig.Dialog = {
	W            = 360,   -- dialog width
	H            = 420,   -- dialog total height — increase if labels overflow
	HeaderH      = 40,    -- header bar height
	CornerRadius = 12,
	CloseBtnSize = 28,

	-- Label heights — increase these to make text bigger
	EarnedH      = 36,    -- "You will earn: +N Soul Auras"
	BoostH       = 22,    -- "⚡ Soul Boost active" (hidden when no boost)
	MultH        = 26,    -- "Earnings Bonus: +X% → +Y%"
	TotalH       = 26,    -- "Total Soul Auras: N (was N)"
	HintH        = 24,    -- "Each Soul Aura gives +15% earnings!"
	BonusH       = 26,    -- "Kickstart Bonus: $X"
	WarningH     = 44,    -- reset warning (wraps to 2 lines)
	ConfirmBtnH  = 48,    -- PRESTIGE button height

	-- Gap between labels (pixels)
	LabelGap     = 6,
}

---------------------------------------------------------------
-- BANNERS
---------------------------------------------------------------
UIConfig.Banners = {
	AreaBannerW      = 260,
	AreaBannerY      = 80,
	PortalBannerW    = 420,
	PortalBannerH    = 56,
	CornerRadius     = 10,
}

---------------------------------------------------------------
-- CARDS
---------------------------------------------------------------
UIConfig.Cards = {
	PrestigeCardW    = 380,
	PrestigeCardH    = 210,
	CornerRadius     = 14,
}

---------------------------------------------------------------
-- MAIN MENU
---------------------------------------------------------------
UIConfig.MainMenu = {
	VignetteDim      = 0.9,   -- higher = more transparent (less dim)
	TitleY           = 0.28,
	SubtitleY        = 0.35,
	PlayButtonY      = 0.48,
	PlayButtonW      = 220,
	PlayButtonH      = 60,
	CreditsY         = 0.92,
	LeftMargin       = 0.05,
	TitleHeight      = 80,
	SubtitleHeight   = 24,
	CreditsHeight    = 18,
	IdleSpeed        = 2,
	FadeInTime       = 0.6,
	FadeHoldTime     = 0.4,
	FadeOutTime      = 0.8,
}

return UIConfig	

-- UITheme
-- Location: ReplicatedStorage > Modules > UITheme

local RunService = game:GetService("RunService")

local UITheme = {}
local Lighting = game:GetService("Lighting")

local MenuBlur = Lighting:FindFirstChild("MenuBlur") or Instance.new("BlurEffect", Lighting)
MenuBlur.Name = "MenuBlur"
MenuBlur.Size = 0 
MenuBlur.Enabled = false

UITheme.Themes = {
	Custom = {
		-- 1. BASE COLORS (Obsidian & Holographic Glass)
		panelBG         = Color3.fromRGB(10,  12,  20),  -- Deep Obsidian Navy
		panelStroke     = Color3.fromRGB(0,   255, 255), -- Glowing Neon Cyan
		headerBG        = Color3.fromRGB(15,  18,  30),  -- Slightly lighter tech-grey
		headerText      = Color3.fromRGB(240, 250, 255), -- Ice White
		bodyText        = Color3.fromRGB(220, 230, 240),
		subText         = Color3.fromRGB(100, 180, 220), -- Muted Cyan

		-- 2. BUTTONS & ACTIONS (Neon Cyberpunk Accents)
		buttonPrimary   = Color3.fromRGB(138, 43,  226), -- Electric Purple
		buttonSecondary = Color3.fromRGB(25,  28,  38),  -- Carbon fiber dark
		buttonGreen     = Color3.fromRGB(0,   255, 128), -- Neon Lime/Mint
		buttonRed       = Color3.fromRGB(255, 30,  60),  -- Laser Red
		buttonDisabled  = Color3.fromRGB(40,  45,  55),

		-- 3. ACCENTS & DATA
		accentGold      = Color3.fromRGB(255, 215, 0),   -- Solid Gold
		accentGreen     = Color3.fromRGB(0,   255, 128),
		accentPurple    = Color3.fromRGB(180, 100, 255),
		accentBlue      = Color3.fromRGB(0,   200, 255),
		accentTeal      = Color3.fromRGB(0,   255, 255),
		currencyColor   = Color3.fromRGB(0,   255, 128), -- Neon Money
		rateColor       = Color3.fromRGB(0,   200, 255),
		warningColor    = Color3.fromRGB(255, 50,  50),

		-- 4. GLASS SETTINGS (Holographic feel)
		cardBG             = Color3.fromRGB(15,  18,  28),
		GlassTransparency  = 0.35, -- More transparent for glassmorphism
		CardTransparency   = 0.5,
		BlurIntensity      = 20,   -- Deep background blur
		StrokeThickness    = 1.5,  -- Slightly thicker glowing borders

		-- 5. FONTS (Sleek & Technical)
		font            = Enum.Font.Jura, 
		fontBody        = Enum.Font.Jura,

		-- 6. FLAIR DEFAULTS
		flair = {
			ShineSpeed     = 1.5,    
			ShineRotation  = 30,     
			ShinePeak      = 0.2,    
			ShineWidth     = 0.6,   
			ShinePause     = 1.0,    
			TextFlairSpeed = 0.3,
			TextFlairSize  = 2,
		},
	}
}

function UITheme.Get(themeName)
	return UITheme.Themes[themeName or "Custom"]
end

function UITheme.SetMenuVisible(isVisible)
	local T = UITheme.Get("Custom")
	MenuBlur.Enabled = isVisible
	local goalSize = isVisible and T.BlurIntensity or 0
	game:GetService("TweenService"):Create(MenuBlur, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Size = goalSize}):Play()
end

---------------------------------------------------------------
-- EASYVISUALS LAZY LOADER
---------------------------------------------------------------
local _EasyVisuals = nil
local _checkedEV = false

local function FindEasyVisuals()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local candidates = {
		ReplicatedStorage:FindFirstChild("EasyVisuals"),
		ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("EasyVisuals"),
		game:GetService("ReplicatedFirst"):FindFirstChild("EasyVisuals"),
	}
	for _, ev in ipairs(candidates) do
		if ev and ev:IsA("ModuleScript") then return ev end
	end
	for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
		if descendant.Name == "EasyVisuals" and descendant:IsA("ModuleScript") then
			return descendant
		end
	end
	return nil
end

local function GetEasyVisuals()
	if _checkedEV then return _EasyVisuals end
	_checkedEV = true
	local ev = FindEasyVisuals()
	if ev then
		local ok, result = pcall(require, ev)
		if ok then _EasyVisuals = result
		else warn("[UITheme] EasyVisuals failed to require: " .. tostring(result)) end
	end
	return _EasyVisuals
end

---------------------------------------------------------------
-- APPLY STYLE
---------------------------------------------------------------
function UITheme.Apply(element, styleType, flairType)
	local T = UITheme.Get("Custom")

	if styleType == "Panel" then
		element.BackgroundColor3 = T.panelBG
		element.BackgroundTransparency = T.GlassTransparency
		element.BorderSizePixel = 0

		-- Glowing Edge
		local stroke = element:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", element)
		stroke.Color = T.panelStroke
		stroke.Thickness = T.StrokeThickness
		stroke.Transparency = 0.2 -- Less transparent so it glows brighter!

		-- Sharper, more technical corners
		local corner = element:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", element)
		corner.CornerRadius = UDim.new(0, 6) 

	elseif styleType == "Card" then
		element.BackgroundColor3 = T.cardBG
		element.BackgroundTransparency = T.CardTransparency

		-- Give cards a subtle technical corner too
		local corner = element:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", element)
		corner.CornerRadius = UDim.new(0, 6) 
	end

	-- Enforce the new Sci-Fi Font across all TextLabels/TextButtons inside this element
	if element:IsA("TextLabel") or element:IsA("TextButton") then
		element.FontFace = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	end
	for _, child in ipairs(element:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			child.FontFace = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		end
	end

	if flairType then
		UITheme.ApplyFlair(element, flairType)
	end
end

---------------------------------------------------------------
-- APPLY SHINE 
---------------------------------------------------------------
function UITheme.ApplyShine(element, speedOverride)
	local T = UITheme.Get("Custom")
	local speed = speedOverride or T.flair.ShineSpeed
	local peak  = T.flair.ShinePeak
	local halfW = T.flair.ShineWidth
	local pause = T.flair.ShinePause

	local existing = element:FindFirstChild("UIThemeShine")
	if existing then existing:Destroy() end

	local gradient = Instance.new("UIGradient")
	gradient.Name = "UIThemeShine"
	gradient.Rotation = T.flair.ShineRotation
	gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 1),
		NumberSequenceKeypoint.new(math.max(0.5 - halfW, 0.01), 1),
		NumberSequenceKeypoint.new(0.5, peak),
		NumberSequenceKeypoint.new(math.min(0.5 + halfW, 0.99), 1),
		NumberSequenceKeypoint.new(1.0, 1),
	})
	gradient.Offset = Vector2.new(-1, 0)
	gradient.Parent = element

	local elapsed = 0
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if not gradient.Parent then
			if conn then conn:Disconnect() end
			return
		end
		elapsed += dt
		local cycle = 2 / speed + pause 
		local t = elapsed % cycle
		if t < 2 / speed then
			gradient.Offset = Vector2.new(-1 + (t * speed), 0)
		else
			gradient.Offset = Vector2.new(1, 0) 
		end
	end)

	return gradient
end

---------------------------------------------------------------
-- APPLY FLAIR
---------------------------------------------------------------
function UITheme.ApplyFlair(element, presetName, speedOverride, sizeOverride)
	local EV = GetEasyVisuals()
	if not EV then
		warn("[UITheme] ApplyFlair requires EasyVisuals module.")
		return nil
	end
	local T = UITheme.Get("Custom")
	local ok, effect = pcall(function()
		return EV.new(
			element,
			presetName,
			speedOverride or T.flair.TextFlairSpeed,
			sizeOverride  or T.flair.TextFlairSize,
			true
		)
	end)
	if not ok then
		warn("[UITheme] ApplyFlair failed: " .. tostring(effect))
		return nil
	end
	return effect
end

return UITheme

-- UpgradeConfig --
-- Location: ReplicatedStorage > Modules > UpgradeConfig
local AdminConfig = require(script.Parent.AdminConfig)
local UpgradeConfig = {}

UpgradeConfig.Tiers = {
	[1] = {
		tierName = "Tier 1",
		unlockRequirement = 0,
		upgrades = {
			blockValue = {
				baseCost = 50, 
				costScale = 1.05, 
				maxLevel = 100,
				apply = function(data) 
					local lv = (data.upgrades and data.upgrades.blockValue) or 0
					return (lv * 0.2) 
				end,
				displayName = "Glow Enhancement", -- (Fixed typo here too!)
				description = "Increases base aura value by +20%", 
				iconId = "rbxassetid://14917130166",
			},
			hatcheryCapacity = {
				baseCost = 100, costScale = 1.1, maxLevel = 50,
				apply = function(data) return (AdminConfig.HatcheryMax or 100) + (((data.upgrades and data.upgrades.hatcheryCapacity) or 0) * 1) end,
				displayName = "Hatchery Expansion", description = "Increases the max capacity of your Hatchery by 1", iconId = "rbxassetid://14923548733",
			},
			habitatCapacity = {
				baseCost = 1500, costScale = 1.2, maxLevel = 20,
				apply = function(data) return (AdminConfig.BaseHabitatCapacity or 50) + (((data.upgrades and data.upgrades.habitatCapacity) or 0) * 10) end,
				displayName = "Habitat Reservoir", description = "Increase habitat capacity by 10", iconId = "rbxassetid://14915711292",
			},
			unlockMythicMult = { 
				baseCost = 25000, costScale = 1, maxLevel = 1, 
				apply = function(data) return ((data.upgrades and data.upgrades.unlockMythicMult) or 0) == 1 end,
				displayName = "Mythic Multi",
				description = "Allows you to hold past the legendary multiplier! Unlocks the " .. (AdminConfig.MilestoneData[6] and AdminConfig.MilestoneData[6].name or "MYTHIC") .. " tier!",
				iconId = "rbxassetid://14921959974",
			},
		}
	},
	[2] = {
		tierName = "Tier 2",
		unlockRequirement = 150,
		upgrades = {
			blockValueT2 = {
				baseCost = 1000, costScale = 1.2, maxLevel = 125,
				apply = function(data) return (((data.upgrades and data.upgrades.blockValueT2) or 0) * 0.15) end,
				displayName = "Increased Aura Pulse", description = "Increased aura value by +15%", iconId = "rbxassetid://14923455396",
			},
			passiveTickSpeedT2 = {
				baseCost = 20000, costScale = 1.45, maxLevel = 20,
				apply = function(data) return (((data.upgrades and data.upgrades.passiveTickSpeedT2) or 0) * 0.15) end,
				displayName = "Advanced Aura Generation", description = "Reduces passive tick speed by 15%", iconId = "rbxassetid://14921959974",
			},
			multiplierSpeed = {
				baseCost = 5000, costScale = 1.5, maxLevel = 5,
				apply = function(data) return 1 + (((data.upgrades and data.upgrades.multiplierSpeed) or 0) * 0.05) end,
				displayName = "Multiplier Speed", description = "Increases how fast your multiplier builds up by 5%.", iconId = "rbxassetid://14921959974",
			},			
			shipCooldown = {
				baseCost = 1500, costScale = 1.4, maxLevel = 10,
				apply = function(data) return 15 - (((data.upgrades and data.upgrades.shipCooldown) or 0) * 1) end,
				displayName = "Hyper-Drive Engines", description = "Reduces the manual ship cooldown by 1 second.",
			},
			-- ✨ NEW: Ship Capacity
			shipCapacityT1 = {
				baseCost = 8000, costScale = 1.25, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.shipCapacityT1) or 0) * 50 end,
				displayName = "Cargo Expansion", description = "Increases the max auras a ship can carry by 50.",
			},
			-- ✨ NEW: Golden Aura Drop Chance
			goldenChanceT1 = {
				baseCost = 15000, costScale = 1.5, maxLevel = 10,
				apply = function(data) return ((data.upgrades and data.upgrades.goldenChanceT1) or 0) * 0.5 end,
				displayName = "Golden Luck", description = "Increases base chance to find Golden Auras by 0.5%.",
			},
		}
	},
	[3] = {
		tierName = "Tier 3",
		unlockRequirement = 150, 
		upgrades = {
			auraValueT3 = {
				baseCost = 250000, costScale = 1.15, maxLevel = 150,
				apply = function(data) return (((data.upgrades and data.upgrades.auraValueT3) or 0) * 0.25) end,
				displayName = "Aura Purifier", description = "Purifies Your Auras for more value +25%",
			},
			hatcheryT3 = {
				baseCost = 750000, costScale = 1.3, maxLevel = 25,
				apply = function(data) return (((data.upgrades and data.upgrades.hatcheryT3) or 0) * 50) end,
				displayName = "Sub-Atomic Breeding", description = "Uses quantum physics to pack 50 more auras into the hatchery.",
			},
			habitatT3 = {
				baseCost = 2000000, costScale = 1.4, maxLevel = 15,
				apply = function(data) return (((data.upgrades and data.upgrades.habitatT3) or 0) * 500) end,
				displayName = "Dimensional Pocketing", description = "Folds space-time within your habitats to add 500 capacity.",
			},
			passiveSpeedT3 = {
				baseCost = 5000000, costScale = 1.5, maxLevel = 10,
				apply = function(data) return (((data.upgrades and data.upgrades.passiveSpeedT3) or 0) * 0.2) end,
				displayName = "Temporal Overclock", description = "Spawners now operate in a fast-forward time stream (-20% delay).",
			},
			-- ✨ NEW: Offline Earnings
			offlineEarningsT1 = {
				baseCost = 1000000, costScale = 1.3, maxLevel = 20,
				apply = function(data) return 1 + (((data.upgrades and data.upgrades.offlineEarningsT1) or 0) * 0.1) end,
				displayName = "Idle Automation", description = "Increases offline/away earnings by 10%.",
			},
		}
	},
	[4] = {
		tierName = "Tier 4",
		unlockRequirement = 225, 
		upgrades = {
			auraValueT4 = {
				baseCost = 15000000, costScale = 1.25, maxLevel = 100,
				apply = function(data) return ((data.upgrades and data.upgrades.auraValueT4) or 0) * 1.5 end,
				displayName = "Quantum State Auras", description = "Auras exist in multiple states, increasing value by +150% per level.",
			},
			hatcheryT4 = {
				baseCost = 40000000, costScale = 1.35, maxLevel = 50,
				apply = function(data) return ((data.upgrades and data.upgrades.hatcheryT4) or 0) * 250 end,
				displayName = "Schrodinger's Hatchery", description = "Hatchery holds both auras and no auras (+250 capacity).",
			},
			-- ✨ NEW: Elite Aura Chance
			eliteSpawnChance = {
				baseCost = 25000000, costScale = 1.4, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.eliteSpawnChance) or 0) * 1.0 end,
				displayName = "Mutated Genetics", description = "Increases the chance of an Elite Aura spawning by 1%.",
			},
			-- ✨ NEW: Drone/Drop frequency
			droneFrequency = {
				baseCost = 50000000, costScale = 1.4, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.droneFrequency) or 0) * 2 end,
				displayName = "Care Package Routing", description = "Random sky drops appear 2% more frequently.",
			},
		}
	},
	[5] = {
		tierName = "Tier 5",
		unlockRequirement = 200,
		upgrades = {
			habitatT5 = {
				baseCost = 5e8, costScale = 1.4, maxLevel = 50,
				apply = function(data) return ((data.upgrades and data.upgrades.habitatT5) or 0) * 2000 end,
				displayName = "Stellar Habitats", description = "House your auras inside miniature stars (+2,000 capacity).",
			},
			-- ✨ NEW: Habitat Cost Reduction
			habitatDiscount = {
				baseCost = 1e8, costScale = 1.5, maxLevel = 10,
				apply = function(data) return ((data.upgrades and data.upgrades.habitatDiscount) or 0) * 0.05 end,
				displayName = "Material Synthesis", description = "Reduces the cost of upgrading habitats by 5%.",
			},
			-- ✨ NEW: Automated Dispatch
			autoDispatchSpeed = {
				baseCost = 7.5e8, costScale = 1.3, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.autoDispatchSpeed) or 0) * 0.2 end,
				displayName = "Logistics AI", description = "Auto-shipping speed increased by 20%.",
			},
			unlockCosmicMult = { 
				baseCost = 2.5e9, costScale = 1, maxLevel = 1, 
				apply = function(data) return ((data.upgrades and data.upgrades.unlockCosmicMult) or 0) == 1 end,
				displayName = "Cosmic Multiplier", 
				description = "Shatters the Mythic limit, unlocking the " .. (AdminConfig.MilestoneData[7] and AdminConfig.MilestoneData[7].name or "COSMIC") .. " tier!",
			},
		}
	},
	[6] = {
		tierName = "Tier 6",
		unlockRequirement = 300,
		upgrades = {
			passiveSpeedT6 = {
				baseCost = 5e10, costScale = 1.5, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.passiveSpeedT6) or 0) * 0.5 end,
				displayName = "Faster Than Light", description = "Auras spawn before you even need them (-50% delay).",
			},
			auraValueT6 = {
				baseCost = 1.5e11, costScale = 1.3, maxLevel = 200,
				apply = function(data) return ((data.upgrades and data.upgrades.auraValueT6) or 0) * 5.0 end,
				displayName = "Tachyon Infusion", description = "Infuse auras with speed particles for +500% value per level.",
			},
			-- ✨ NEW TIER 6 PADDING (All Max Level 25 for easy tweaking)
			doubleSpawnChance = {
				baseCost = 2e10, costScale = 1.35, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.doubleSpawnChance) or 0) * 1 end,
				displayName = "Mitosis Splitting", description = "1% chance for a spawner to generate two auras at once.",
			},
			offlineTimeCap = {
				baseCost = 3.5e10, costScale = 1.4, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.offlineTimeCap) or 0) * 1 end,
				displayName = "Stasis Batteries", description = "Increases max offline earnings time by 1 hour.",
			},
			goldenAuraValue = {
				baseCost = 8e10, costScale = 1.5, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.goldenAuraValue) or 0) * 0.1 end,
				displayName = "Refined Gold", description = "Golden Auras collected grant +10% more premium currency.",
			},
			shippingCapacityT6 = {
				baseCost = 1e11, costScale = 1.45, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.shippingCapacityT6) or 0) * 5000 end,
				displayName = "Wormhole Freight", description = "Ships carry +5,000 more auras through hyperspace.",
			},
		}
	},
	[7] = {
		tierName = "Tier 7",
		unlockRequirement = 500,
		upgrades = {
			hatcheryT7 = {
				baseCost = 1e13, costScale = 1.4, maxLevel = 100,
				apply = function(data) return ((data.upgrades and data.upgrades.hatcheryT7) or 0) * 10000 end,
				displayName = "Void Reservoirs", description = "Store energy in the endless void (+10,000 capacity).",
			},
			habitatT7 = {
				baseCost = 5e13, costScale = 1.45, maxLevel = 100,
				apply = function(data) return ((data.upgrades and data.upgrades.habitatT7) or 0) * 50000 end,
				displayName = "Antimatter Containment", description = "Safely store massive amounts of auras (+50,000 capacity).",
			},
			-- ✨ NEW
			prestigeMultiplierBonus = {
				baseCost = 2e13, costScale = 1.6, maxLevel = 10,
				apply = function(data) return ((data.upgrades and data.upgrades.prestigeMultiplierBonus) or 0) * 0.05 end,
				displayName = "Soul Memory", description = "Increases the multiplier gained from Prestiging by 5%.",
			},
			droneRewardMulti = {
				baseCost = 8e13, costScale = 1.5, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.droneRewardMulti) or 0) * 0.5 end,
				displayName = "Heavier Payloads", description = "Random drops contain 50% more resources.",
			},
		}
	},
	[8] = {
		tierName = "Tier 8",
		unlockRequirement = 1000,
		upgrades = {
			auraValueT8 = {
				baseCost = 5e15, costScale = 1.35, maxLevel = 250,
				apply = function(data) return ((data.upgrades and data.upgrades.auraValueT8) or 0) * 25.0 end,
				displayName = "Reality Bending", description = "Auras pull value from alternate dimensions (+2,500% value).",
			},
			-- ✨ NEW
			godlyCritChance = {
				baseCost = 1e16, costScale = 1.4, maxLevel = 25,
				apply = function(data) return ((data.upgrades and data.upgrades.godlyCritChance) or 0) * 0.2 end,
				displayName = "Divine Intervention", description = "0.2% chance for an aura to instantly max out its value.",
			},
			habitatT8 = {
				baseCost = 8e16, costScale = 1.5, maxLevel = 100,
				apply = function(data) return ((data.upgrades and data.upgrades.habitatT8) or 0) * 250000 end,
				displayName = "Pocket Universes", description = "Creates entire universes to hold your auras (+250,000 capacity).",
			},
			unlockGodlyMult = { 
				baseCost = 1e17, costScale = 1, maxLevel = 1,
				apply = function(data) return ((data.upgrades and data.upgrades.unlockGodlyMult) or 0) == 1 end,
				displayName = "Godly Multiplier", 
				description = "Reach ascension. Unlocks the " .. (AdminConfig.MilestoneData[8] and AdminConfig.MilestoneData[8].name or "GODLY") .. " tier!",
			},
		}
	},
	[9] = {
		tierName = "Tier 9",
		unlockRequirement = 1500,
		upgrades = {
			habitatT9 = {
				baseCost = 1e19, costScale = 1.5, maxLevel = 150,
				apply = function(data) return ((data.upgrades and data.upgrades.habitatT9) or 0) * 1000000 end,
				displayName = "Galaxy Clusters", description = "Your habitats are now comprised of entire galaxies (+1M capacity).",
			},
			hatcheryT9 = {
				baseCost = 5e19, costScale = 1.5, maxLevel = 150,
				apply = function(data) return ((data.upgrades and data.upgrades.hatcheryT9) or 0) * 500000 end,
				displayName = "Big Bang Forges", description = "Hatch energy from the birth of new universes (+500k capacity).",
			},
			-- ✨ NEW
			universalShipping = {
				baseCost = 8e19, costScale = 1.45, maxLevel = 50,
				apply = function(data) return ((data.upgrades and data.upgrades.universalShipping) or 0) * 1000000 end,
				displayName = "Teleportation Networks", description = "Instantly beam auras to buyers (+1M shipping capacity).",
			},
			unlockUniversalMult = { 
				baseCost = 1e20, costScale = 1, maxLevel = 1, 
				apply = function(data) return ((data.upgrades and data.upgrades.unlockUniversalMult) or 0) == 1 end,
				displayName = "Universal Multiplier", 
				description = "Shatter reality. Unlocks the " .. (AdminConfig.MilestoneData[9] and AdminConfig.MilestoneData[9].name or "UNIVERSAL") .. " tier!",
			},
		}
	},
	[10] = {
		tierName = "Tier 10",
		unlockRequirement = 2500,
		upgrades = {
			auraValueT10 = {
				baseCost = 1e22, costScale = 1.4, maxLevel = 500,
				apply = function(data) return ((data.upgrades and data.upgrades.auraValueT10) or 0) * 150.0 end,
				displayName = "Limitless Potential", description = "The ultimate value upgrade. +15,000% value per level.",
			},
			-- ✨ NEW
			omniCapacity = {
				baseCost = 5e22, costScale = 1.5, maxLevel = 500,
				apply = function(data) return ((data.upgrades and data.upgrades.omniCapacity) or 0) * 10000000 end,
				displayName = "The Final Frontier", description = "Unfathomable space (+10M habitat capacity).",
			},
			omniSpeed = {
				baseCost = 8e22, costScale = 1.6, maxLevel = 100,
				apply = function(data) return ((data.upgrades and data.upgrades.omniSpeed) or 0) * 2.0 end,
				displayName = "Time Collapse", description = "Auras generate infinitely fast (-200% delay multiplier).",
			},
			unlockOmniMult = { 
				baseCost = 5e23, costScale = 1, maxLevel = 1,
				apply = function(data) return ((data.upgrades and data.upgrades.unlockOmniMult) or 0) == 1 end,
				displayName = "Omni Multiplier", 
				description = "The absolute limit. Unlocks the " .. (AdminConfig.MilestoneData[10] and AdminConfig.MilestoneData[10].name or "OMNI") .. " tier!",
			},
		}
	},
}

-- HELPER: Used by Spawner, Manager, and HUD to find math without knowing the Tier
function UpgradeConfig.GetUpgradeConfig(upgradeId)
	for _, tierData in ipairs(UpgradeConfig.Tiers) do
		if tierData.upgrades[upgradeId] then
			return tierData.upgrades[upgradeId]
		end
	end
	return nil
end

-- HELPER: Used by Shop and Manager to calculate cost
function UpgradeConfig.CalculateCost(upgradeId, currentLevel)
	local cfg = UpgradeConfig.GetUpgradeConfig(upgradeId)
	if not cfg then return math.huge end
	if currentLevel >= cfg.maxLevel then return math.huge end

	-- Exponential Cost Formula: Base * (Scale ^ Level)
	return math.floor(cfg.baseCost * (cfg.costScale ^ currentLevel))
end

return UpgradeConfig

local WeatherConfig = {
	CycleTime = 60, -- 5 minutes per weather cycle
	EventChance = 0.35, -- 35% chance to roll a storm

	Types = {
		Clear = {
			name = "Clear Skies", minArea = 1,
			ambient = Color3.fromRGB(130, 130, 130), fogEnd = 2000,
			particle = nil, rate = 0,
			spawnMult = 1.0, valueMult = 1.0,
			color = Color3.fromRGB(200, 200, 200),
			bannerText = "The skies have cleared."
		},
		Windy = {
			name = "Windy", minArea = 1, -- Unlocked immediately
			ambient = Color3.fromRGB(160, 170, 160), fogEnd = 1200,
			particle = "rbxassetid://14922084401", rate = 15, 
			spawnMult = 1.2, valueMult = 1.0,
			color = Color3.fromRGB(150, 200, 150),
			bannerText = "Windy! 1.2x Spawn Speed!"
		},
		Nightfall = {
			name = "Nightfall", minArea = 2, -- Unlocked in Area 2
			ambient = Color3.fromRGB(30, 30, 50), fogEnd = 800,
			particle = "rbxassetid://14914000799", rate = 20, 
			spawnMult = 1.0, valueMult = 1.5,
			color = Color3.fromRGB(100, 100, 255),
			bannerText = "Nightfall! 1.5x Aura Value!"
		},
		Starfall = {
			name = "Starfall", minArea = 3,
			ambient = Color3.fromRGB(100, 100, 150), fogEnd = 800,
			particle = "rbxassetid://14914000799", rate = 40,
			spawnMult = 1.0, valueMult = 1.5,
			color = Color3.fromRGB(255, 255, 100),
			bannerText = "Starfall! 1.5x Aura Value!"
		},
		Corruption = {
			name = "Corruption", minArea = 4,
			ambient = Color3.fromRGB(80, 40, 120), fogEnd = 400,
			particle = "rbxassetid://14922084401", rate = 100,
			spawnMult = 2.0, valueMult = 0.8,
			color = Color3.fromRGB(150, 50, 255),
			bannerText = "Corruption! 2x Spawn Speed!"
		},
		Eclipse = {
			name = "Eclipse", minArea = 5,
			ambient = Color3.fromRGB(10, 10, 10), fogEnd = 200,
			particle = "rbxassetid://14922084401", rate = 15,
			spawnMult = 0.5, valueMult = 3.0,
			color = Color3.fromRGB(100, 100, 100),
			bannerText = "Eclipse... 3.0x Aura Value!"
		},
		Hell = {
			name = "Hell", minArea = 6,
			ambient = Color3.fromRGB(150, 40, 20), fogEnd = 300,
			particle = "rbxassetid://14922084401", rate = 200,
			spawnMult = 3.0, valueMult = 2.0,
			color = Color3.fromRGB(255, 80, 20),
			bannerText = "HELL STORM! Massive Boosts!"
		},
	}
}

return WeatherConfig
