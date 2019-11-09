include('shared.lua')

surface.CreateFont("VJ_ZS",{
	font = "anthem",
	size = 17,
})

hook.Add("HUDPaint","VJ_ZombieSurvival_HUD",function()
	local CANDRAW = false
	local ply = LocalPlayer()
	local hasHUD = ply:GetNWBool("ZS_HUD")
	local sp = NULL
	for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
		sp = v; break
	end
	CANDRAW = (IsValid(sp) && hasHUD)
	if CANDRAW == false then return end
	local zbText = sp:GetNWBool("VJ_ZSBoss")
	
	local k = ply:GetNWInt("VJ_ZSKills")
	local d = ply:GetNWInt("VJ_ZSDeaths")

	local smooth = 8
	local bposX = 10
	local bposY = 10
	local bX = 205
	local bY = 80
	draw.RoundedBox(smooth,bposX,bposY,bX,bY,Color(0,0,0,200))

	if !zbText then
		local zombo = surface.GetTextureID("HUD/killicons/npc_vj_zs_zombie")
		local zposX = 45
		local zposY = 50
		local zX = 78
		local zY = 74
		surface.SetTexture(zombo)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRectRotated(zposX,zposY,zX,zY,0)
	end
		
	local wText = sp:GetNWInt("VJ_ZSWave")
	local wposX = 84
	local wposY = 13
	local wFText = "Wave " .. wText
	draw.SimpleText(wFText,"VJ_ZS",wposX,wposY,Color(0,255,0,255))

	local zText = sp:GetNWInt("VJ_ZSZombieCount")
	local zposX = 84
	local zposY = 28
	local zFText = "Z-Count: " .. zText
	draw.SimpleText(zFText,"VJ_ZS",zposX,zposY,Color(0,255,0,255))
	
	local tText = sp:GetNWInt("VJ_ZSCountdown")
	local tposX = 84
	local tposY = 42
	if tText < 0 then
		tText = 0
	end
	local tFText = "Round End: " .. tText
	draw.SimpleText(tFText,"VJ_ZS",tposX,tposY,Color(0,255,0,255))
	
	local kposX = 84
	local kposY = 57
	if tText < 0 then
		tText = 0
	end
	local tFText = "Kills: " .. k .. " | Deaths: " .. d
	draw.SimpleText(tFText,"VJ_ZS",kposX,kposY,Color(0,255,0,255))

	if zbText then
		local zbiText = sp:GetNWBool("VJ_ZSBossIcon")
		if zbiText then
			local bosszombo = surface.GetTextureID("HUD/killicons/" .. zbiText)
			local zbiposX = 45
			local zbiposY = 50
			local zbiX = 78
			local zbiY = 74
			surface.SetTexture(bosszombo)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawTexturedRectRotated(zbiposX,zbiposY,zbiX,zbiY,0)
		end

		local zbposX = 15
		local zbposY = 60
		draw.SimpleText("BOSS!","CloseCaption_Bold",zbposX,zbposY,Color(255,0,0,255))
		
		local zbHposX = 84
		local zbHposY = 72
		draw.SimpleText(tostring(sp:GetNWInt("VJ_ZSBossHP")) .. " HP","VJ_ZS",zbHposX,zbHposY,Color(255,0,0,255))
	end
end)

function ENT:Initialize()
	self.CanStartThisShit = CurTime() +1
	for _,v in pairs(player.GetAll()) do
		v.ZS_CurrentBeat = 1
		v.ZS_OldBeat = 0
		v.ZS_TotalZombies = 0
		v.ZS_NextBeatT = 0
		v.ZS_NextCheckT = 0
		v.ZS_TotalBeats = 0
		v.ZS_BeatDir = nil
		v.tbl_Beats = {}
		self:SetUpBeats(v)
	end
end

function ENT:SetUpBeats(v)
	local vol = GetConVarNumber("vj_zs_music_volume")
	local set = GetConVarNumber("vj_zs_musicset")
	local max = 1
	local dir = "common/"
	if set == 1 then
		max = 8
		dir = "cpt_zs/music/zbeat"
	elseif set == 2 then
		max = 10
		dir = "cpt_zs/music/gmod13/beat"
	end
	for i = 1,max do
		local ZS_Beat = CreateSound(v,dir .. i .. ".wav")
		ZS_Beat:SetSoundLevel(vol)
		v.tbl_Beats[i] = ZS_Beat
	end
	v.ZS_TotalBeats = max
	v.ZS_BeatDir = dir
	local ZS_Beat = CreateSound(v,"cpt_zs/music/lasthuman.wav")
	ZS_Beat:SetSoundLevel(vol)
	v.tbl_Beats[max +1] = ZS_Beat
end

function ENT:PlayBeat(v,i)
	v.tbl_Beats[i]:Play()
end

function ENT:StopBeats(v)
	for i = 1,v.ZS_TotalBeats +1 do
		if v.tbl_Beats[i] then v.tbl_Beats[i]:Stop() end
	end
end

function ENT:Draw()
	return false
end

function ENT:Think()
	for _,v in pairs(player.GetAll()) do
		if v.tbl_Beats == nil then
			self:SetUpBeats(v)
		end
		self:ZS_Music(v)
	end
end

function ENT:ZS_Music(ent)
	local wave = self:GetNWInt("VJ_ZSWave")
	local finalwave = self:GetNWInt("VJ_ZSWaveMax")
	local isZombie = ent:GetNWBool("VJ_ZS_IsZombie")
	if CurTime() > ent.ZS_NextCheckT then
		local tbl = {}
		if isZombie then
			for _,v in pairs(ents.FindInSphere(ent:GetPos(),400)) do
				if (v:IsNPC() && !string.find(v:GetClass(),"npc_vj_zs_")) or (v:IsPlayer() && v != ent && !v:GetNWBool("VJ_ZS_IsZombie")) then
					table.insert(tbl,v)
				end
			end
		else
			for _,v in pairs(ents.FindByClass("npc_vj_zs_*")) do
				if v:GetPos():Distance(ent:GetPos()) <= 400 then
					table.insert(tbl,v)
				end
			end
		end
		ent.ZS_TotalZombies = #tbl
		local count = math.Round((#tbl *0.65))
		ent.ZS_CurrentBeat = math.Clamp(count,1,ent.ZS_TotalBeats)
		ent.ZS_NextCheckT = CurTime() +2
	end
	-- print(ent.ZS_TotalZombies,ent.ZS_CurrentBeat,ent.ZS_OldBeat,ent.ZS_NextBeatT)
	-- print(wave,finalwave)
	if wave == finalwave then
		if CurTime() > self.CanStartThisShit then
			if CurTime() > ent.ZS_NextBeatT then
				self:StopBeats(ent)
				self:PlayBeat(ent,ent.ZS_TotalBeats +1)
				ent.ZS_NextBeatT = CurTime() +SoundDuration("cpt_zs/music/lasthuman.wav")
			end
		end
	else
		if CurTime() > ent.ZS_NextBeatT then
			local beat = ent.ZS_BeatDir .. ent.ZS_CurrentBeat .. ".wav"
			if ent.ZS_CurrentBeat != ent.ZS_OldBeat then
				self:StopBeats(ent)
				ent.ZS_OldBeat = ent.ZS_CurrentBeat
			end
			self:StopBeats(ent)
			self:PlayBeat(ent,ent.ZS_CurrentBeat)
			ent.ZS_NextBeatT = CurTime() +SoundDuration(beat)
		end
	end
end

function ENT:OnRemove()
	for _,v in pairs(player.GetAll()) do
		self:StopBeats(v)
		-- v:SetNWBool("ZS_HUD",false)
	end
end