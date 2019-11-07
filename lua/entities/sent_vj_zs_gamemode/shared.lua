ENT.Base 			= "base_anim"
ENT.Type 			= "anim"
ENT.PrintName 		= "ZS Gamemode - Mini Edition"
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""
ENT.Category		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

-- function ENT:Initialize()
	-- for _,v in pairs(player.GetAll()) do
		-- v.ZS_CurrentBeat = 1
		-- v.ZS_OldBeat = 0
		-- v.ZS_TotalZombies = 0
		-- v.ZS_NextBeatT = 0
		-- v.ZS_NextCheckT = 0
		-- v.tbl_Beats = {}
		-- self:SetUpBeats(v)
		-- print(v)
	-- end
-- end

-- function ENT:SetUpBeats(v)
	-- for i = 1,8 do
		-- local ZS_Beat = CreateSound(v,"cpt_zs/music/zbeat" .. i .. ".wav")
		-- ZS_Beat:SetSoundLevel(45)
		-- v.tbl_Beats[i] = ZS_Beat
	-- end
-- end

-- function ENT:PlayBeat(v,i)
	-- v.tbl_Beats[i]:Play()
-- end

-- function ENT:StopBeats(v)
	-- for i = 1,8 do
		-- v.tbl_Beats[i]:Stop()
	-- end
-- end

-- function ENT:Draw()
	-- return false
-- end

-- function ENT:Think()
	-- for _,v in pairs(player.GetAll()) do
		-- self:ZS_Music(v)
	-- end
-- end

-- function ENT:ZS_Music(ent)
	-- if CurTime() > ent.ZS_NextCheckT then
		-- local tbl = {}
		-- for _,v in pairs(ents.FindByClass("npc_vj_zs_*")) do
			-- if v:GetPos():Distance(ent:GetPos()) <= 400 then
				-- table.insert(tbl,v)
			-- end
		-- end
		-- ent.ZS_TotalZombies = #tbl
		-- local count = math.Round((#tbl *0.65))
		-- ent.ZS_CurrentBeat = math.Clamp(count,1,8)
		-- ent.ZS_NextCheckT = CurTime() +2
	-- end
	-- print(ent.ZS_TotalZombies,ent.ZS_CurrentBeat,ent.ZS_OldBeat,ent.ZS_NextBeatT)
	-- if CurTime() > ent.ZS_NextBeatT then
		-- local beat = "cpt_zs/music/zbeat" .. ent.ZS_CurrentBeat .. ".wav"
		-- if ent.ZS_CurrentBeat != ent.ZS_OldBeat then
			-- self:StopBeats(ent)
			-- ent.ZS_OldBeat = ent.ZS_CurrentBeat
		-- end
		-- self:StopBeats(ent)
		-- self:PlayBeat(ent,ent.ZS_CurrentBeat)
		-- ent.ZS_NextBeatT = CurTime() +SoundDuration(beat)
	-- end
-- end