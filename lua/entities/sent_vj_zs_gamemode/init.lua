AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString("vj_zs_sound")

ENT.BossRound = false
ENT.Wave = 0
ENT.TotalWaves = 8 -- 8
ENT.WaveTime = GetConVarNumber("vj_zs_wavetime") -- 180
ENT.IntermissionTime = GetConVarNumber("vj_zs_intermissiontime") -- 45
ENT.BossChance = 3
ENT.ZombieBosses = {
	"npc_vj_zs_nightmare",
	"npc_vj_zs_gorechild_boss",
	"npc_vj_zs_pukepuss",
	"npc_vj_zs_ticklemonster",
}
ENT.ZombieRespawnTime = 4
ENT.ZombieThresholds = {
	[0] = nil,
	[1] = {
		"npc_vj_zs_zombie"
	},
	[2] = {
		"npc_vj_zs_zombietorso",
		"npc_vj_zs_headcrab",
		"npc_vj_zs_ghoul",
	},
	[3] = {
		"npc_vj_zs_fastzombie",
		"npc_vj_zs_fastheadcrab",
		"npc_vj_zs_wraith",
	},
	[4] = {
		"npc_vj_zs_bloatedzombie",
		"npc_vj_zs_mailedzombie",
		"npc_vj_zs_howler",
	},
	[5] = {
		"npc_vj_zs_wraithcrab",
		"npc_vj_zs_stalker",
	},
	[6] = {
		"npc_vj_zs_poisonheadcrab",
		"npc_vj_zs_draggy",
	},
	[7] = {
		"npc_vj_zs_burnzie",
		"npc_vj_zs_poisonzombie",
		"npc_vj_zs_zombine",
	},
	[8] = {
		"npc_vj_zs_chemzombie"
	}
}
ENT.PlayerZombieThresholds = {
	[0] = nil,
	[1] = {
		"weapon_vj_zs_zombie"
	},
	[2] = {
		"weapon_vj_zs_ghoul",
		"weapon_vj_zs_zombietorso",
		"weapon_vj_zs_headcrab",
	},
	[3] = {
		"weapon_vj_zs_fastzombie",
		"weapon_vj_zs_fastheadcrab",
		"weapon_vj_zs_wraith_old",
	},
	[4] = {
		"weapon_vj_zs_mailedzombie",
		"weapon_vj_zs_howler",
	},
	[5] = {
		"weapon_vj_zs_wraith",
		"weapon_vj_zs_wraithcrab",
	},
	[6] = {
		"weapon_vj_zs_poisonheadcrab",
		"weapon_vj_zs_draggy",
	},
	[7] = {
		"weapon_vj_zs_burnzie",
		"weapon_vj_zs_poisonzombie",
		"weapon_vj_zs_zombine",
	},
	[8] = {
		"weapon_vj_zs_chemzombie",
	}
}
ENT.PlayerWeapons = { -- Replace these with whatever you want, too lazy to make a bunch of ZS weapons on VJ Base
	[0] = {"weapon_crowbar"},
	[1] = {
		"weapon_vj_9mmpistol",
		"weapon_vj_zsh_glock",
		"weapon_vj_zsh_p228",
	},
	[2] = {
		"weapon_vj_357",
		"weapon_vj_zsh_usp",
	},
	[3] = {
		"weapon_vj_smg1",
		"weapon_vj_zs_tmp",
	},
	[4] = {
		"weapon_vj_ak47",
		"weapon_vj_mp40",
	},
	[5] = {
		"weapon_vj_glock17",
		"weapon_vj_zsh_mp5",
	},
	[6] = {
		"weapon_vj_zsh_deagle",
		"weapon_vj_m16a1",
	},
	[7] = {
		"weapon_vj_spas12",
	},
	[8] = {
		"weapon_vj_blaster",
	}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupZombies() -- Called when wave starts
	local oldCount = #self.ZombieClasses
	table.Empty(self.ZombieClasses)
	table.Empty(self.PlayerClasses)
	local free = tobool(GetConVarNumber("vj_zs_freezombies"))
	local counter = self.Wave
	if free then counter = self.TotalWaves end
	for i = 1,counter do
		for _,z in pairs(self.ZombieThresholds[i]) do
			table.insert(self.ZombieClasses,z)
		end
		for _,z in pairs(self.PlayerZombieThresholds[i]) do
			table.insert(self.PlayerClasses,z)
		end
	end
	if self.BossRound then
		self:SpawnBoss()
	end
	local newCount = #self.ZombieClasses
	local newClasses = newCount -oldCount
	if newClasses > 0 then
		for _,v in pairs(player.GetAll()) do
			if newClasses == 1 then
				self:PlayerMsg(newClasses .. " zombie class unlocked!")
			else
				self:PlayerMsg(newClasses .. " zombie classes unlocked!")
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_junk/popcan01a.mdl")
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetNotSolid(true)
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		if IsValid(v) && v != self then
			self:Remove()
		end
	end
	self.tbl_Spawners = {}
	self.DefaultSpawnPositions = {}
	for _,v in pairs(ents.FindByClass("sent_vj_zs_spawner")) do
		table.insert(self.tbl_Spawners,v)
		table.insert(self.DefaultSpawnPositions,v:GetPos())
		v.MasterEntity = self
	end
	if #self.DefaultSpawnPositions < 1 then self:Remove() end
	for _,v in pairs(player.GetAll()) do
		v:SetNWBool("ZS_HUD",true)
		v.ZS_Kills = 0
		v.ZS_Deaths = 0
		v.ZS_SurviveTime = CurTime()
		v.ZS_SurviveTimeOriginal = CurTime()
	end
	self.WaveTime = GetConVarNumber("vj_zs_wavetime")
	self.IntermissionTime = GetConVarNumber("vj_zs_intermissiontime")
	self.StartedOnslaught = false
	self.NextWaveT = 0
	self.InIntermission = false
	self.ZombieAdditions = 0
	self.TotalDeaths = 0
	self.NextSpawnZTime = 0
	self.StarterTimer = CurTime() +self.IntermissionTime
	self.EnforceWeapons = tobool(GetConVarNumber("vj_zs_weapons"))
	self.tbl_TotalPlayers = {}
	self.Zombies = {}
	self.ZombieClasses = {}
	self.PlayerZombies = {}
	self.PlayerClasses = {}
	self.tbl_ScoreBoard = {
		["mostkills"] = {ply="N/A",value=0},
		["mostdeaths"] = {ply="N/A",value=0},
		["longestsurvival"] = {ply="N/A",value=0},
	}
	if self.EnforceWeapons then
		self:EnforceStarterWeapons()
	end
	self.NextNumberCheckT = CurTime() +1
	self:SetNWInt("VJ_ZSWaveMax",self.TotalWaves)
	-- self:SetNWInt("VJ_ZSTotalHumans",0)
	self:SetNWInt("VJ_ZSTotalZombies",0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- function ENT:UpdateNumbers()
	-- if CurTime() > self.NextNumberCheckT then
		-- local tbl = {}
		-- local tblZ = {}
		-- if GetConVarNumber("ai_ignoreplayers") == 0 then
			-- for _,v in pairs(player.GetAll()) do
				-- if v.VJ_ZS_IsZombie then
					-- table.insert(tblZ,v)
				-- else
					-- table.insert(tbl,v)
				-- end
			-- end
		-- end
		-- for _,v in pairs(ents.FindByClass("npc_vj_hzs_bot")) do
			-- table.insert(tbl,v)
		-- end
		-- self:SetNWInt("VJ_ZSTotalHumans",#tbl)
		-- self:SetNWInt("VJ_ZSTotalZombies",#tblZ +#self.Zombies)
		-- self.NextNumberCheckT = CurTime() +math.Rand(4,8)
	-- end
-- end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ObtainWaveWeapon(ent,wave)
	if !self.EnforceWeapons then return end
	local wep = VJ_PICK(self.PlayerWeapons[wave])
	ent.VJ_CanBePickedUpWithOutUse = true
	ent.VJ_CanBePickedUpWithOutUse_Class = wep
	ent:Give(wep)
	-- ent:EmitSound("weapons/physcannon/physcannon_charge.wav",45,100)
	ent:ChatPrint("Unlocked new weapon!")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ObtainWaveWeapon_Bot(ent,wave)
	if !self.EnforceWeapons then return end
	local wep = VJ_PICK(self.PlayerWeapons[wave])
	if wave == 0 then wep = "weapon_vj_9mmpistol" end
	if IsValid(ent:GetActiveWeapon()) then ent:GetActiveWeapon():Remove() end
	ent:Give(wep)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:EnforceStarterWeapons()
	local wave = self.Wave
	local tbl = player.GetAll()
	for _,v in pairs(tbl) do
		if v:Alive() && !v.VJ_ZS_IsZombie then
			v:StripWeapons()
			v:StripAmmo()
			for i = 0,wave do
				self:ObtainWaveWeapon(v,wave)
			end
			if #tbl <= 1 then
				v.VJ_CanBePickedUpWithOutUse = true
				v.VJ_CanBePickedUpWithOutUse_Class = "weapon_vj_zsh_barricade"
				v:Give("weapon_vj_zsh_barricade")
			else
				if math.random(1,2) == 1 then
					v.VJ_CanBePickedUpWithOutUse = true
					v.VJ_CanBePickedUpWithOutUse_Class = "weapon_vj_zsh_barricade"
					v:Give("weapon_vj_zsh_barricade")
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PlayerDeath","VJ_ZS_ZombieAddition",function(ply)
	local canRun = false
	local ent = NULL
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		-- v.ZombieAdditions = v.ZombieAdditions +1
		ent = v
		canRun = true
	end
	if !canRun then
		if ply.VJ_ZS_IsZombie then
			ply.VJ_ZS_IsZombie = false
			ply:SetNWBool("VJ_ZS_IsZombie",false)
			ply.VJ_NPC_Class = nil
			for _,v in pairs(ents.FindByClass("npc_vj_*")) do
				if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") then
					v:AddEntityRelationship(ply,D_HT,99)
					v:SetEnemy(ply)
					table.insert(v.VJ_AddCertainEntityAsEnemy,ply)
				elseif VJ_HasValue(v.VJ_NPC_Class,"CLASS_PLAYER_ALLY") or v.PlayerFriendly then
					v:AddEntityRelationship(ply,D_LI,99)
					table.insert(v.VJ_AddCertainEntityAsFriendly,ply)
				end
			end
		else
			if ent.TotalDeaths then ent.TotalDeaths = ent.TotalDeaths +1 end
		end
		return
	end
	ply.ZS_Deaths = ply.ZS_Deaths +1
	if GetConVarNumber("vj_zs_allowplayerzombies") == 1 && GetConVarNumber("vj_zs_becomezombies") == 1 then
		ply.VJ_ZS_IsZombie = true
		ply:SetNWBool("VJ_ZS_IsZombie",true)
	end
end)
---------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PlayerDeathThink","VJ_ZS_DisableZPlayerSpawning",function(ply)
	local function Respawn(ply)
		if (ply.NextSpawnTime && ply.NextSpawnTime > CurTime()) then return end
		if (ply:IsBot() || ply:KeyPressed(IN_ATTACK) || ply:KeyPressed(IN_ATTACK2) || ply:KeyPressed(IN_JUMP)) then
			ply:Spawn()
		end
	end
	local canRun = false
	local ent = NULL
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		canRun = true
		ent = v
	end
	if !canRun then Respawn(ply) return end
	if !ply.VJ_ZS_IsZombie then Respawn(ply) return end
	if ply.VJ_ZS_IsZombie then
		local wave = ent.Wave
		local int = ent.InIntermission
		if wave == 0 then
			ply.NextSpawnTime = CurTime() +2
			return
		end
		if int then
			ply.NextSpawnTime = CurTime() +2
			return
		end
		Respawn(ply)
	end
end)
---------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PlayerSpawn","VJ_ZS_ZombiePlayers",function(ply)
	if SERVER then
		local canRun = false
		local ent = NULL
		for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
			canRun = true
			ent = v
		end
		if !canRun then return end
		local function RestorePlayerWeapons(ply,ent)
			local wave = ent.Wave
			timer.Simple(0.1,function()
				if IsValid(ply) && IsValid(ent) then
					ply:StripWeapons()
					ply:StripAmmo()
					for i = 0,wave do
						ent:ObtainWaveWeapon(ply,i)
					end
				end
			end)
			-- timer.Simple(0.1,function()
				-- if IsValid(ply) && IsValid(ent) then
					-- ply:StripWeapons()
					-- ply:StripAmmo()
				-- end
			-- end)
			-- timer.Simple(0.11,function()
				-- if IsValid(ply) && IsValid(ent) then
					-- for i = 0,wave do
						-- timer.Simple(0.1 *wave,function()
							-- if IsValid(ply) && IsValid(ent) then
								-- ent:ObtainWaveWeapon(ply,wave)
							-- end
						-- end)
					-- end
				-- end
			-- end)
		end
		if !ply.VJ_ZS_IsZombie then
			RestorePlayerWeapons(ply,ent)
		end
		if GetConVarNumber("vj_zs_allowplayerzombies") == 0 then ply.VJ_ZS_IsZombie = false; ply:SetNWBool("VJ_ZS_IsZombie",false) return end
		if ply.VJ_ZS_IsZombie then
			ply.VJ_NPC_Class = {}
			table.insert(ply.VJ_NPC_Class,"CLASS_ZOMBIE")
			ply.VJ_NPC_Class = {"CLASS_ZOMBIE"}
			ply:SetPos(ent:GetRandomSpawn(80))
			for _,v in pairs(ents.FindByClass("npc_vj_*")) do
				if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") then
					v:AddEntityRelationship(ply,D_LI,99)
					table.insert(v.VJ_AddCertainEntityAsFriendly,ply)
				else
					v:AddEntityRelationship(ply,D_HT,99)
					table.insert(v.VJ_AddCertainEntityAsEnemy,ply)
				end
			end
			timer.Simple(0.01,function()
				ply:StripWeapons()
				local wep = ent:PickPlayerClass(ply)
				ply.VJ_ZS_ZombieClass = wep
				ply.VJ_CanBePickedUpWithOutUse = true
				ply.VJ_CanBePickedUpWithOutUse_Class = wep
				ply:Give(wep)
				ply:SelectWeapon(wep)
				ply.VJ_NPC_Class = {nil}
				table.insert(ply.VJ_NPC_Class,"CLASS_ZOMBIE")
				ply.VJ_NPC_Class = {"CLASS_ZOMBIE"}
				ply:SetPos(ent:GetRandomSpawn(80))
				for _,v in pairs(ents.FindByClass("npc_vj_*")) do
					if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") then
						v:AddEntityRelationship(ply,D_LI,99)
						table.insert(v.VJ_AddCertainEntityAsFriendly,ply)
					else
						v:AddEntityRelationship(ply,D_HT,99)
						table.insert(v.VJ_AddCertainEntityAsEnemy,ply)
					end
				end
				if ent:GetNWInt("VJ_ZSWave") < 8 && math.random(1,5) == 1 then
					ent:PlayerNWSound(ply,VJ_PICK({
						"music/stingers/industrial_suspense1.wav",
						"music/stingers/industrial_suspense2.wav",
						"music/stingers/hl1_stinger_song16.mp3",
						"music/stingers/hl1_stinger_song27.mp3",
						"music/stingers/hl1_stinger_song7.mp3",
						"music/stingers/hl1_stinger_song8.mp3",
					}))
				end
			end)
		end
	end
end)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayerNWSound(ply,snd,vo)
	if vo && GetConVarNumber("vj_zs_vo") == 0 then return end
    net.Start("vj_zs_sound")
		net.WriteEntity(ply)
		net.WriteString(snd)
    net.Send(ply)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayerSound(snd)
	local tb = {}
	for _,v in pairs(player.GetAll()) do
		table.insert(tb,v)
	end
	for i = 1,#tb do
		tb[i]:EmitSound(snd,0.2,100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PlayerMsg(msg)
	PrintMessage(HUD_PRINTTALK,msg)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetSpawners()
	return self.tbl_Spawners
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetRandomSpawn(offset)
	return VJ_PICKRANDOMTABLE(self.DefaultSpawnPositions) +Vector(math.Rand(-offset,offset),math.Rand(-offset,offset),5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetStartSong()
	local tbl = {"common/null.wav"}
	if os.date("%m") == "12" then
		return "cpt_zs/mrgreen/gamestart_xmas.mp3"
	end
	if self.IntermissionTime < 120 then
		tbl = {
			"music/stingers/industrial_suspense1.wav",
			"music/stingers/hl1_stinger_song16.mp3",
			"music/stingers/hl1_stinger_song7.mp3",
			"music/stingers/hl1_stinger_song8.mp3",
		}
	else
		tbl = {
			"cpt_zs/mrgreen/gamestart1.mp3",
			"cpt_zs/mrgreen/gamestart2.mp3",
			"cpt_zs/mrgreen/gamestart3.mp3",
			"cpt_zs/mrgreen/gamestart4.mp3"
		}
	end
	return VJ_PICKRANDOMTABLE(tbl)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetWaveTime()
	return self.WaveTime
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PickBoss()
	return VJ_PICKRANDOMTABLE(self.ZombieBosses)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PickClass()
	return VJ_PICKRANDOMTABLE(self.ZombieClasses)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PickPlayerClass(ply)
	local tbl = self.PlayerClasses
	if GetConVarNumber("vj_zs_zombieclass") == 0 then
		return VJ_PICKRANDOMTABLE(tbl)
	end
	local requestedClass = self.PlayerClasses[GetConVarNumber("vj_zs_zombieclass")]
	if requestedClass == nil then
		return VJ_PICKRANDOMTABLE(tbl)
	end
	return requestedClass
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetHighestScore(tb)
	return math.max(unpack(tb))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DecideScores()
	local tbK = {}
	local tbD = {}
	local tbT = {}
	for _,v in pairs(player.GetAll()) do
		table.insert(tbK,v.ZS_Kills)
		table.insert(tbD,v.ZS_Deaths)
		v.ZS_SurviveTimeOriginal = v.ZS_SurviveTime
		table.insert(tbT,math.Round(CurTime() -v.ZS_SurviveTime))
	end
	local hK = self:GetHighestScore(tbK)
	local kP = nil
	local hD = self:GetHighestScore(tbD)
	local dP = nil
	local hT = self:GetHighestScore(tbT)
	local tP = nil
	for _,v in pairs(player.GetAll()) do
		if v.ZS_Kills == hK then
			kP = v
		end
		if v.ZS_Deaths == hD then
			dP = v
		end
		if math.Round(v.ZS_SurviveTimeOriginal) == math.Round(hT) then
			tP = v
		end
	end
	self.tbl_ScoreBoard["mostkills"] = {ply=kP:Nick(),value=hK}
	self.tbl_ScoreBoard["mostdeaths"] = {ply=dP:Nick(),value=hD}
	if tP then self.tbl_ScoreBoard["longestsurvival"] = {ply=tP:Nick(),value=hT} end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoEndingVoices()
	if self.TotalDeaths < game.MaxPlayers() then
		for _,v in pairs(player.GetAll()) do
			self:PlayerNWSound(v,(math.random(1,300) == 1 && "cpt_zs/mrgreen/ravebreak_fix.mp3") or "cpt_zs/music/humanwin.mp3")
			if v.VJ_ZS_IsZombie then
				self:PlayerNWSound(v,"cpt_zs/vo/zombie_wave_outro_lose.wav",true)
			else
				self:PlayerNWSound(v,"cpt_zs/vo/human_wave_outro.wav",true)
			end
		end
		self:PlayerMsg("The living have prevailed!")
	else
		for _,v in pairs(player.GetAll()) do
			self:PlayerNWSound(v,"cpt_zs/music/zombie_win.wav")
			if v.VJ_ZS_IsZombie then
				self:PlayerNWSound(v,"cpt_zs/vo/zombie_wave_outro.wav",true)
			end
		end
		self:PlayerMsg("The undead have prevailed!")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ResetPlayerData()
	for _,v in pairs(player.GetAll()) do
		if v.VJ_ZS_IsZombie then
			v.VJ_ZS_IsZombie = false
			v:SetNWBool("VJ_ZS_IsZombie",false)
			for _,v in pairs(ents.FindByClass("npc_vj_*")) do
				if VJ_HasValue(v.VJ_NPC_Class,"CLASS_ZOMBIE") then
					v:AddEntityRelationship(v,D_HT,99)
					table.insert(v.VJ_AddCertainEntityAsEnemy,v)
				elseif v.PlayerFriendly then
					v:AddEntityRelationship(v,D_LI,99)
					table.insert(v.VJ_AddCertainEntityAsFriendly,v)
				end
			end
			v.VJ_NPC_Class = {nil}
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetIntermission(nextWave)
	if self.InIntermission then return end
	self.BossRound = false
	if nextWave == self.TotalWaves +1 then
		for _,v in pairs(player.GetAll()) do
			self:PlayerNWSound(v,"weapons/physcannon/energy_disintegrate4.wav")
		end
		-- self:PlayerSound("weapons/physcannon/energy_disintegrate4.wav")
		self:DoEndingVoices()
		self:DecideScores()
		local kills = self.tbl_ScoreBoard["mostkills"]
		local deaths = self.tbl_ScoreBoard["mostdeaths"]
		local time = self.tbl_ScoreBoard["longestsurvival"]
		self:PlayerMsg("--== Achievements ==--")
		self:PlayerMsg("Most Kills:")
		self:PlayerMsg(kills.ply .. " - " ..kills.value)
		self:PlayerMsg("Most Deaths:")
		self:PlayerMsg(deaths.ply .. " - " ..deaths.value)
		if time.ply != "N/A" then self:PlayerMsg("Longest Survival Time:") end
		if time.ply != "N/A" then self:PlayerMsg(time.ply .. " - " ..time.value) end
		for _,v in pairs(ents.FindByClass("npc_vj_zs_*")) do
			v:TakeDamage(999999999,v,v)
		end
		self.StartedOnslaught = false
		self:ResetPlayerData()
		self:Remove()
	end
	self.InIntermission = true
	if nextWave == 1 then
		for _,v in pairs(player.GetAll()) do
			self:PlayerNWSound(v,self:GetStartSong())
			self:PlayerNWSound(v,"cpt_zs/vo/human_prepare.wav",true)
		end
		self:PlayerMsg("Prepare your defenses! (".. self.IntermissionTime .. " seconds until the undead arrive.)")
	else
		if self.Wave != 8 then
			self:PlayerMsg("The undead have stopped rising! (".. self.IntermissionTime .. " second intermission.)")
			for _,v in pairs(player.GetAll()) do
				self:PlayerNWSound(v,"ambient/atmosphere/cave_hit5.wav")
				if v.VJ_ZS_IsZombie then
					self:PlayerNWSound(v,"cpt_zs/vo/zombie_wave_over.wav",true)
				else
					self:PlayerNWSound(v,"cpt_zs/vo/human_wave_over.wav",true)
				end
			end
		end
	end
	self.NextWaveT = CurTime() +self.IntermissionTime
	timer.Simple(self.IntermissionTime,function()
		if IsValid(self) then
			self.InIntermission = false
			if nextWave == 1 then
				self.StartedOnslaught = true
				for _,v in pairs(player.GetAll()) do
					if v:Alive() && !v.VJ_ZS_IsZombie then
						self:ObtainWaveWeapon(v,1)
					end
				end
				if GetConVarNumber("vj_zs_allowplayerzombies") == 1 then
					if SERVER then
						for _,v in pairs(player.GetAll()) do
							for i = 1,#self.DefaultSpawnPositions do
								if v:GetPos():Distance(self.DefaultSpawnPositions[i]) <= 150 then
									v:Kill()
									v.VJ_ZS_IsZombie = true
									v:SetNWBool("VJ_ZS_IsZombie",true)
								end
							end
						end
					end
				end
			end
			self:SetWave(nextWave)
		end
	end)
	if nextWave == 1 then
		timer.Simple(self.IntermissionTime -11,function()
			if IsValid(self) then
				for _,v in pairs(player.GetAll()) do
					self:PlayerNWSound(v,"cpt_zs/vo/human_10seconds.wav",true)
				end
			end
		end)
	end
	for i = 1,5 do
		timer.Simple(self.IntermissionTime -i,function()
				if IsValid(self) then
				for _,v in pairs(player.GetAll()) do
					self:PlayerNWSound(v,"cpt_zs/vo/human_" .. tostring(i) .. ".wav",true)
					self:PlayerNWSound(v,"buttons/lightswitch2.wav")
				end
				self:PlayerMsg(i .. "..")
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetWave(num)
	if num > self.TotalWaves then
		return
	end
	if num == 1 then
		for _,v in pairs(player.GetAll()) do
			self:PlayerNWSound(v,"ambient/creatures/town_zombie_call1.wav")
		end
		-- self:PlayerSound("ambient/creatures/town_zombie_call1.wav")
	else
		for _,v in pairs(player.GetAll()) do
			self:PlayerNWSound(v,"ambient/atmosphere/cave_hit1.wav")
		end
		-- self:PlayerSound("ambient/atmosphere/cave_hit1.wav")
	end
	if num > 0 then
		timer.Simple(self.WaveTime *math.Rand(0.05,0.95),function()
			if IsValid(self) then
				self:RandomResources()
			end
		end)
	end
	self.Wave = num
	for _,v in pairs(player.GetAll()) do
		if v:Alive() && !v.VJ_ZS_IsZombie then
			self:ObtainWaveWeapon(v,num)
		end
	end
	for _,v in pairs(ents.FindByClass("npc_vj_hzs_bot")) do
		self:ObtainWaveWeapon_Bot(v,num)
	end
	if math.random(1,self.BossChance) == 1 then
		self.BossRound = true
	end
	table.Empty(self.tbl_TotalPlayers)
	for _,v in pairs(player.GetAll()) do
		table.insert(self.tbl_TotalPlayers,v)
	end
	self:SetupZombies()
	self.NextWaveT = CurTime() +self.WaveTime
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RandomResources()
	for _,v in pairs(player.GetAll()) do
		if v:Alive() && !v.VJ_ZS_IsZombie then
			v:ChatPrint("Ammo Restored!")
			v:VJ_RestoreAmmo(false,50,250)
			self:PlayerNWSound(v,"weapons/physcannon/physcannon_charge.wav")
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnThink(wave,max)
	local count = #self.Zombies
	if count == max then return end
	if CurTime() > self.NextSpawnZTime then
		local z = ents.Create(self:PickClass())
		z:SetPos(self:GetRandomSpawn(80))
		z:SetAngles(self:GetAngles())
		z:Spawn()
		z.FindEnemy_UseSphere = true
		z.FindEnemy_CanSeeThroughWalls = true
		for _,v in pairs(self.ZombieClasses) do
			table.insert(z.EntitiesToNoCollide,v)
		end
		table.insert(self.Zombies,z)
		self.NextSpawnZTime = CurTime() +math.Rand(0.2,1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnBoss()
	local z = ents.Create(self:PickBoss())
	z:SetPos(self:GetRandomSpawn(80))
	z:SetAngles(self:GetAngles())
	z:Spawn()
	self.Boss = z
	z.FindEnemy_UseSphere = true
	z.FindEnemy_CanSeeThroughWalls = true
	for _,v in pairs(self.ZombieClasses) do
		table.insert(z.EntitiesToNoCollide,v)
	end
	for _,v in pairs(player.GetAll()) do
		self:PlayerNWSound(v,"cpt_zs/mrgreen/beep22.wav")
	end
	self:PlayerMsg("A new Boss zombie has been spotted!")
end
---------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("OnNPCKilled","VJ_ZS_Kills",function(npc,ply,weapon)
	local doRun = false
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		doRun = true
	end
	if !doRun then return end
	if string.find(npc:GetClass(),"npc_vj_zs_") && ply:IsPlayer() then
		ply.ZS_Kills = ply.ZS_Kills +1
	end
end)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZS_Think(wave)
	if CurTime() > self.NextWaveT then
		self:SetIntermission(wave +1)
	end
	local int = self.InIntermission
	for i,v in pairs(self.Zombies) do
		if !IsValid(v) then
			table.remove(self.Zombies,i)
		end
	end
	if int then return end
	local maxZombies = 1
	local numZ = (#self.tbl_TotalPlayers *wave /*+self.ZombieAdditions*/ +3) *GetConVarNumber("vj_zs_difficulty")
	maxZombies = math.Clamp(numZ,1,GetConVarNumber("vj_zs_maxzombies"))
	self:SpawnThink(wave,maxZombies)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	local wave = self.Wave
	self:SetNWInt("VJ_ZSWave",wave)
	self:SetNWBool("VJ_ZSIntermission",self.InIntermission)
	self:SetNWBool("VJ_ZSBoss",IsValid(self.Boss))
	-- if IsValid(self.Boss) then
		-- self:SetNWString("VJ_ZSBossIcon",self.Boss:GetClass())
		-- self:SetNWInt("VJ_ZSBossHP",math.Round(self.Boss:Health()))
	-- end
	-- self:UpdateNumbers()
	self:SetNWInt("VJ_ZSTotalZombies",#self.Zombies)
	-- self:SetNWInt("VJ_ZSZombieCount",#self.Zombies) // WaveTime
	if self.StartedOnslaught then
		if self.NextWaveT > 0 then
			self:SetNWInt("VJ_ZSCountdown",math.Round(self.NextWaveT -CurTime()))
		-- else
			-- self:SetNWInt("VJ_ZSCountdown",0)
		end
	else
		self:SetNWInt("VJ_ZSCountdown",math.Round(self.StarterTimer -CurTime()))
	end
	for _,v in pairs(player.GetAll()) do
		v:SetNWInt("VJ_ZSKills",v.ZS_Kills)
		v:SetNWInt("VJ_ZSDeath",v.ZS_Deaths)
	end
	if wave == 0 && !self.StartedOnslaught then
		self:SetIntermission(1)
	end
	if self.StartedOnslaught then
		self:ZS_Think(wave)
	end
	self:NextThink(CurTime() +0.01)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
	if #self.Zombies > 0 then
		for _,v in pairs(self.Zombies) do
			v:TakeDamage(999999999,v,v)
		end
	end
	for _,v in pairs(player.GetAll()) do
		v:SetNWBool("ZS_HUD",false)
		if v.VJ_ZS_IsZombie then
			v:Kill()
		end
	end
	self:ResetPlayerData()
end