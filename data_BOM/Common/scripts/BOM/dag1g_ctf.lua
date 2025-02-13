--
-- Copyright (c) 2005 Pandemic Studios, LLC. All rights reserved.
--

-- load the gametype script
ScriptCB_DoFile("ObjectiveCTF")
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
-- alliance attacking (attacker is always #1)
local ALL = ATT
local IMP = DEF


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
		hints = 1280,
		obstacles = 1024,
		redOmniLights = 64,
	
		-- sounds
		soundStatic = 2, 
		soundStream = 4,
		soundSpace = 2,
		
		-- units
		cloths = MAX_UNITS,
		wookiees = MAX_SPECIAL,
		
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
	ReadDataFile("dc:sound\\bom.lvl;bomgcw")
    
	
	------------------------------------------------
	------------   VANILLA SOUNDS   ----------------
	------------------------------------------------
	
    ReadDataFile("sound\\dag.lvl;dag1gcw")

	
    ------------------------------------------------
	------------   UNIT TYPES   --------------------
	------------------------------------------------
	
	-- alliance
	local ALL_HERO = "rep_hero_yoda"
	
	-- empire
	local IMP_HERO = "imp_hero_darthvader"
	
	
	------------------------------------------------
	------------   LOAD VANILLA ASSETS   -----------
	------------------------------------------------
	
    -- alliance
    ReadDataFile("SIDE\\all.lvl",
				 ALL_HERO)
				 
	-- empire
	ReadDataFile("SIDE\\imp.lvl",
				 IMP_HERO)

	-- republic
	ReadDataFile("SIDE\\rep.lvl",
                 "rep_hero_yoda")
				 
	
	------------------------------------------------
	------------   SETUP TEAMS   -------------------
	------------------------------------------------

    -- setup teams
	TeamConfig:init{
		teamNameATT = "all", teamNameDEF = "imp",
		teamATTConfigID = "basic_jungle", teamDEFConfigID = "army",
	}
	
	-- heroes
    SetHeroClass(ALL, ALL_HERO)    
    SetHeroClass(IMP, IMP_HERO)
	
	
	------------------------------------------------
	------------   MISSION PROPERTIES   ------------
	------------------------------------------------
	
	-- load game type map layer
	ReadDataFile("dag\\dag1.lvl", "dag1_ctf")
	ReadDataFile("dag\\dag1.lvl", "dag1_gcw") -- for x-wing
	
	-- set mission properties
	missionProperties:init{
	-- map properties
		-- ceiling and floor limit
		mapCeiling = 20,
		
		-- birdies and fishies
		numBirdTypes = 2,
		numFishTypes = 1,
		
	-- ai properties
		-- view distance
		denseEnvironment = true,	
	}
	
	
	------------------------------------------------
	------------   LEVEL SOUNDS   ------------------
	------------------------------------------------

	-- open ambient streams
	OpenAudioStream("sound\\global.lvl", "gcw_music")
	OpenAudioStream("sound\\dag.lvl", "dag1")
	OpenAudioStream("sound\\dag.lvl", "dag1")

	-- music
	SetAmbientMusic(ALL, 1.0, "all_dag_amb_start", 0,1)
	SetAmbientMusic(ALL, 0.8, "all_dag_amb_middle", 1,1)
	SetAmbientMusic(ALL, 0.2,"all_dag_amb_end", 2,1)
	SetAmbientMusic(IMP, 1.0, "imp_dag_amb_start", 0,1)
	SetAmbientMusic(IMP, 0.8, "imp_dag_amb_middle", 1,1)
	SetAmbientMusic(IMP, 0.2,"imp_dag_amb_end",  2,1)

	-- game over song
	SetVictoryMusic(ALL, "all_dag_amb_victory")
	SetDefeatMusic (ALL, "all_dag_amb_defeat")
	SetVictoryMusic(IMP, "imp_dag_amb_victory")
	SetDefeatMusic (IMP, "imp_dag_amb_defeat")


    ------------------------------------------------
	------------   CAMERA STATS   ------------------
	------------------------------------------------

    AddCameraShot(0.953415, -0.062787, 0.294418, 0.019389, 20.468771, 3.780040, -110.412453)
    AddCameraShot(0.646125, -0.080365, 0.753185, 0.093682, 41.348438, 5.688061, -52.695042)
    AddCameraShot(-0.442911, 0.055229, -0.887986, -0.110728, 39.894440, 9.234127, -59.177147)
    AddCameraShot(-0.038618, 0.006041, -0.987228, -0.154444, 28.671711, 10.001163, 128.892181) 
end


-- PostLoad, this is all done after all loading, etc.
function ScriptPostLoad()
    
	------------------------------------------------
	------------   INITIALIZE OBJECTIVE   ----------
	------------------------------------------------

	-- create and start objective	
	objCTF:initCTF{
		teamNameATT = "all", teamNameDEF = "imp",
		flagNameATT = "ctf_flag1", flagNameDEF = "ctf_flag2",
		homeRegionATT = "flag1_home", homeRegionDEF = "flag2_home", 
		captureRegionATT = "flag2_home", captureRegionDEF = "flag1_home",
	}
	
	
	------------------------------------------------
	------------   MISC   --------------------------
	------------------------------------------------

    EnableSPHeroRules()    
end
