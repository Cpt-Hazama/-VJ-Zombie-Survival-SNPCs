AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

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
	},
	[5] = {
		"npc_vj_zs_wraithcrab",
		"npc_vj_zs_stalker",
	},
	[6] = {
		"npc_vj_zs_poisonheadcrab",
	},
	[7] = {
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
	},
	[3] = {
		"weapon_vj_zs_fastzombie",
	},
	[4] = {
		nil
	},
	[5] = {
		nil
	},
	[6] = {
		nil
	},
	[7] = {
		"weapon_vj_zs_poisonzombie",
		"weapon_vj_zs_zombine",
	},
	[8] = {
		nil
	}
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetupZombies() -- Called when wave starts
	local oldCount = #self.ZombieClasses
	table.Empty(self.ZombieClasses)
	table.Empty(self.PlayerClasses)
	for i = 1,self.Wave do
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
	self.StartedOnslaught = false
	self.NextWaveT = 0
	self.InIntermission = false
	self.ZombieAdditions = 0
	self.NextSpawnZTime = 0
	self.StarterTimer = CurTime() +self.IntermissionTime
	self.Zombies = {}
	self.ZombieClasses = {}
	self.PlayerZombies = {}
	self.PlayerClasses = {}
	self.tbl_ScoreBoard = {
		["mostkills"] = {ply="N/A",value=0},
		["mostdeaths"] = {ply="N/A",value=0},
		["longestsurvival"] = {ply="N/A",value=0},
	}
	self:SetNWInt("VJ_ZSWaveMax",self.TotalWaves)
end
---------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PlayerDeath","VJ_ZS_ZombieAddition",function(ply)
	local canRun = false
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		-- v.ZombieAdditions = v.ZombieAdditions +1
		canRun = true
	end
	if !canRun then
		if ply.VJ_ZS_IsZombie then
			ply.VJ_ZS_IsZombie = false
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
		end
		return
	end
	ply.ZS_Deaths = ply.ZS_Deaths +1
	if GetConVarNumber("vj_zs_allowplayerzombies") == 1 && GetConVarNumber("vj_zs_becomezombies") == 1 then
		ply.VJ_ZS_IsZombie = true
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
	if GetConVarNumber("vj_zs_allowplayerzombies") == 0 then ply.VJ_ZS_IsZombie = false return end
	local canRun = false
	local ent = NULL
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		canRun = true
		ent = v
	end
	if !canRun then return end
	if ply.VJ_ZS_IsZombie then
		timer.Simple(0.01,function()
			ply:StripWeapons()
			local wep = ent:PickPlayerClass()
			ply.VJ_ZS_ZombieClass = wep
			ply.VJ_CanBePickedUpWithOutUse = true
			ply.VJ_CanBePickedUpWithOutUse_Class = wep
			ply:Give(wep)
			ply.VJ_NPC_Class = {}
			table.insert(ply.VJ_NPC_Class,"CLASS_ZOMBIE")
			ply:SelectWeapon(wep)
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
		end)
	end
end)
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
	local tbl = {
		"music/stingers/industrial_suspense1.wav",
		"music/stingers/hl1_stinger_song16.mp3",
		"music/stingers/hl1_stinger_song7.mp3",
		"music/stingers/hl1_stinger_song8.mp3",
	}
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
function ENT:PickPlayerClass()
	return VJ_PICKRANDOMTABLE(self.PlayerClasses)
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
function ENT:SetIntermission(nextWave)
	if self.InIntermission then return end
	self.BossRound = false
	if nextWave == self.TotalWaves +1 then
		if self.ZombieAdditions < game.MaxPlayers() then
			self:PlayerSound("cpt_zs/music/humanwin.mp3")
			self:PlayerMsg("The living have prevailed!")
		else
			self:PlayerSound("cpt_zs/music/zombie_win.wav")
			self:PlayerMsg("The undead have prevailed!")
		end
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
		self:Remove()
	end
	self.InIntermission = true
	if nextWave == 1 then
		self:PlayerMsg("Prepare your defenses! (".. self.IntermissionTime .. " seconds until the undead arrive.)")
		self:PlayerSound(self:GetStartSong())
	else
		self:PlayerMsg("The undead have stop rising! (".. self.IntermissionTime .. " second intermission.)")
		self:PlayerSound("ambient/atmosphere/cave_hit5.wav")
	end
	timer.Simple(self.IntermissionTime,function()
		if IsValid(self) then
			self.InIntermission = false
			if nextWave == 1 then
				self.StartedOnslaught = true
				if GetConVarNumber("vj_zs_allowplayerzombies") == 1 then
					if SERVER then
						for _,v in pairs(player.GetAll()) do
							for i = 1,#self.DefaultSpawnPositions do
								if v:GetPos():Distance(self.DefaultSpawnPositions[i]) <= 150 then
									v:Kill()
									v.VJ_ZS_IsZombie = true
								end
							end
						end
					end
				end
			end
			self:SetWave(nextWave)
		end
	end)
	for i = 1,5 do
		timer.Simple(self.IntermissionTime -i,function()
			if IsValid(self) then
				self:PlayerSound("ambient/creatures/teddy.wav")
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
		self:PlayerSound("ambient/creatures/town_zombie_call1.wav")
	else
		self:PlayerSound("ambient/atmosphere/cave_hit1.wav")
	end
	self.Wave = num
	if math.random(1,self.BossChance) == 1 then
		self.BossRound = true
	end
	self:SetupZombies()
	self.NextWaveT = CurTime() +self.WaveTime
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
	local plTbl = {}
	for _,v in pairs(player.GetAll()) do
		-- if v.VJ_ZS_IsZombie then 
			-- if !IsValid(v:GetActiveWeapon()) || IsValid(v:GetActiveWeapon()) && v:GetActiveWeapon():GetClass() != v.VJ_ZS_ZombieClass then
				-- v:Give(v.VJ_ZS_ZombieClass)
			-- end
		-- end
		table.insert(plTbl,v)
	end
	local numZ = (#plTbl *wave +self.ZombieAdditions +3) *GetConVarNumber("vj_zs_difficulty")
	maxZombies = math.Clamp(numZ,1,GetConVarNumber("vj_zs_maxzombies"))
	self:SpawnThink(wave,maxZombies)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	local wave = self.Wave
	self:SetNWInt("VJ_ZSWave",wave)
	-- self:SetNWBool("VJ_ZSIntermission",self.InIntermission)
	self:SetNWBool("VJ_ZSBoss",IsValid(self.Boss))
	if IsValid(self.Boss) then
		self:SetNWString("VJ_ZSBossIcon",self.Boss:GetClass())
		self:SetNWInt("VJ_ZSBossHP",math.Round(self.Boss:Health()))
	end
	self:SetNWInt("VJ_ZSZombieCount",#self.Zombies) // WaveTime
	if self.StartedOnslaught then
		if self.NextWaveT > 0 then
			self:SetNWInt("VJ_ZSCountdown",math.Round(self.NextWaveT -CurTime()))
		else
			self:SetNWInt("VJ_ZSCountdown",0)
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
	for _,v in pairs(self.Zombies) do
		v:TakeDamage(999999999,v,v)
	end
	for _,v in pairs(player.GetAll()) do
		v:SetNWBool("ZS_HUD",false)
	end
end