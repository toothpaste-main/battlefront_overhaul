--
-- Copyright (c) 2005 Pandemic Studios, LLC. All rights reserved.
--

-- load the gametype script
ScriptCB_DoFile("ObjectiveOneFlagCTF")
ScriptCB_DoFile("setup_teams")

-- load mission helper
ScriptCB_DoFile("import")
local memorypool = import("memorypool")
local missionProperties = import("mission_properties")
local TeamConfig = import("TeamConfig")
local objCTF = import("objective_ctf_helper")

-- load BOM assets
ScriptCB_DoFile("bom_cmn")

-- these variables do not change
local ATT = 1
local DEF = 2
-- republic attacking (attacker is always #1)
local REP = ATT
local CIS = DEF


---------------------------------------------------------------------------
-- FUNCTION:    ScriptInit
-- PURPOSE:     This function is only run once
-- INPUT:
-- OUTPUT:
-- NOTES:       The name, 'ScriptInit' is a chosen convention, and each
--              mission script must contain a version of this function, as
--              it is called from C to start the mission.
---------------------------------------------------------------------------
function ScriptInit()
    
	------------------------------------------------
	-- Designers, these two lines *MUST* be first.--
	------------------------------------------------

	-- allocate PS2 memory
	if(ScriptCB_GetPlatform() == "PS2") then
        StealArtistHeap(1024*1024)	-- steal 1MB from art heap
    end
	SetPS2ModelMemory(PS2_MEMORY)

    ReadDataFile("ingame.lvl")
	
	
	------------------------------------------------
	------------   MEMORY POOL   -------------------
	------------------------------------------------
	--
	-- This happens first and foremost to avoid
	-- crashes when loading.
	--
	
	memorypool:init{	
		-- map
		hints = 768,
		redOmniLights = 96,
		
		-- sounds
		soundStatic = 17, 
		soundStream = 14,
		soundSpace = 14,
		
		-- units
		cloths = MAX_UNITS,
		
		-- vehicles
		turrets = 1,
		droidekas = MAX_SPECIAL,
		
		-- weapons
		mines = 2 * ASSAULT_MINES * MAX_ASSAULT,
		portableTurrets = 2 * SNIPER_TURRETS * MAX_SNIPER,
	}
	
	
	------------------------------------------------
	------------   DLC SOUNDS   --------------------
	------------------------------------------------
	--
	-- This happens first to avoid conflicts with 
	-- vanilla sounds.
	--
	
	-- global
	ReadDataFile("dc:sound\\bom.lvl;bom_cmn")

	-- era
	ReadDataFile("dc:sound\\bom.lvl;bomcw")
    
	
	------------------------------------------------
	------------   VANILLA SOUNDS   ----------------
	------------------------------------------------
    
    ReadDataFile("sound\\tan.lvl;tan1cw")

    
	------------------------------------------------
	------------   UNIT TYPES   --------------------
	------------------------------------------------	
	
	-- republic
	local REP_HERO = "rep_hero_yoda"
	
	-- cis
	local CIS_HERO = "cis_hero_grievous"
	
	
	------------------------------------------------
	------------   LOAD VANILLA ASSETS   -----------
	------------------------------------------------

	-- republic
    ReadDataFile("SIDE\\rep.lvl",
				 REP_HERO)
	
	-- cis
    ReadDataFile("SIDE\\cis.lvl",
				 CIS_HERO)
 
 
	------------------------------------------------
	------------   SETUP TEAMS   -------------------
	------------------------------------------------
    
	-- setup teams
	TeamConfig:init{
		teamNameATT = "rep", teamNameDEF = "cis",
		teamATTConfigID = "marine", teamDEFConfigID = "basic",
	}
	
	-- heroes
    SetHeroClass(REP, REP_HERO)
	SetHeroClass(CIS, CIS_HERO)
	
	
	------------------------------------------------
	------------   MISSION PROPERTIES   ------------
	------------------------------------------------
	
	-- load game type map layer
	ReadDataFile("tan\\tan1.lvl", "tan1_1flag")
	
	-- set mission properties
	missionProperties:init{
	-- map properties
		-- ceiling and floor limit
		mapCeiling = 32,
		
		-- misc
		mapNorthAngle = 180,
		worldExtents = 1064.5,
		
	-- ai properties
		-- view distance
		urbanEnvironment = true,	
	}
	
	
	------------------------------------------------
	------------   LEVEL SOUNDS   ------------------
	------------------------------------------------

	-- open ambient streams
    OpenAudioStream("sound\\global.lvl", "cw_music")
    OpenAudioStream("sound\\tan.lvl", "tan1")
    OpenAudioStream("sound\\tan.lvl", "tan1")

	-- music
    SetAmbientMusic(REP, 1.0, "rep_tan_amb_start", 0,1)
    SetAmbientMusic(REP, 0.8, "rep_tan_amb_middle", 1,1)
    SetAmbientMusic(REP, 0.2,"rep_tan_amb_end", 2,1)
    SetAmbientMusic(CIS, 1.0, "cis_tan_amb_start", 0,1)
    SetAmbientMusic(CIS, 0.8, "cis_tan_amb_middle", 1,1)
    SetAmbientMusic(CIS, 0.2,"cis_tan_amb_end", 2,1)

	-- game over song
    SetVictoryMusic(REP, "rep_tan_amb_victory")
    SetDefeatMusic (REP, "rep_tan_amb_defeat")
    SetVictoryMusic(CIS, "cis_tan_amb_victory")
    SetDefeatMusic (CIS, "cis_tan_amb_defeat")


	------------------------------------------------
	------------   CAMERA STATS   ------------------
	------------------------------------------------

    AddCameraShot(0.233199, -0.019441, -0.968874, -0.080771, -240.755920, 11.457644, 105.944176)
    AddCameraShot(-0.395561, 0.079428, -0.897092, -0.180135, -264.022278, 6.745873, 122.715752)
    AddCameraShot(0.546703, -0.041547, -0.833891, -0.063371, -309.709900, 5.168304, 145.334381)
end


 --PostLoad, this is all done after all loading, etc.
function ScriptPostLoad()

   ------------------------------------------------
	------------   OUT OF BOUNDS   -----------------
	------------------------------------------------
	
	-- death regions
    AddDeathRegion("turbinedeath")
    
    
	-- remove AI barriers	
    DisableBarriers("barracks")
    DisableBarriers("liea")
    
	
	------------------------------------------------
	------------   MAP SETUP   ---------------------
	------------------------------------------------
	
	-- blow out blast door
    KillObject("blastdoor")
	
	
	------------------------------------------------
	------------   MAP INTERACTION   ---------------
	------------------------------------------------
	
	-- turbine
    BlockPlanningGraphArcs("turbine")
    OnObjectKillName(destturbine, "turbineconsole")
    OnObjectRespawnName(returbine, "turbineconsole")    
	healturbine()
	
	
	------------------------------------------------
	------------   INITIALIZE OBJECTIVE   ----------
	------------------------------------------------
	
	-- hide cp numbers on map
	SetProperty("1flag_cp1", "HUDIndexDisplay", 0)
	SetProperty("1flag_cp2", "HUDIndexDisplay", 0)
    
	-- create objective		   
	objCTF:initOneFlag{
		teamNameATT = "rep", teamNameDEF = "cis",
		flagName = "flag", homeRegion = "1flag_team1_capture",
		captureRegionATT = "1flag_team1_capture", captureRegionDEF = "1flag_team2_capture"
	}

	
	------------------------------------------------
	------------   MISC   --------------------------
	------------------------------------------------
	
    EnableSPHeroRules()
end

function healturbine()
	--Setup Timer-- 
	timeConsole = CreateTimer("timeConsole")
	SetTimerValue(timeConsole, 0.3)
	StartTimer(timeConsole)
	OnTimerElapse(
		function(timer)
			-- I think this replenishes the health over time
			SetProperty("turbineconsole", "CurHealth", GetObjectHealth("turbineconsole") + 1)
			DestroyTimer(timer)
		end,
	timeConsole
	)
end

function destturbine()
    UnblockPlanningGraphArcs("turbine")
    PauseAnimation("Turbine Animation")
    RemoveRegion("turbinedeath")
--    SetProperty("woodr", "CurHealth", 15)
end

function returbine()
    BlockPlanningGraphArcs("turbine")
    PlayAnimation("Turbine Animation")
    AddDeathRegion("turbinedeath")
--    SetProperty("woodr", "CurHealth", 15)
end
