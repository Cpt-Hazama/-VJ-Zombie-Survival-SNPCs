/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2020 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Zombie Survival SNPCs"
local AddonName = "Zombie Survival"
local AddonType = "SNPC"
local AutorunFile = "autorun/vj_zs_spawn.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	VJ_ZS_MaxZoom = 70
	VJ_ZS_MinZoom = 15

	local vCat = "Zombie Survival - Tools"
	VJ.AddCategoryInfo(vCat,{Icon = "vj_icons/zs_tools.png"})
	VJ.AddNPC("Gamemode","sent_vj_zs_gamemode",vCat)
	VJ.AddNPC("Zombie Gas","sent_vj_zs_spawner",vCat)
	VJ.AddNPC("Ammo Crate","sent_vj_zs_ammocrate",vCat)
	-- VJ.AddNPC("Objective Point","sent_vj_zs_point",vCat)

	VJ.AddNPC_HUMAN("Player Bot","npc_vj_hzs_bot",{"weapon_vj_zsh_tmp","weapon_vj_zsh_deagle","weapon_vj_zsh_glock","weapon_vj_zsh_mp5","weapon_vj_zsh_p228","weapon_vj_zsh_usp","weapon_vj_357","weapon_vj_9mmpistol","weapon_vj_glock17","weapon_vj_smg1","weapon_vj_smg1","weapon_vj_smg1","weapon_vj_k3","weapon_vj_k3","weapon_vj_ar2","weapon_vj_ar2","weapon_vj_ak47","weapon_vj_m16a1","weapon_vj_mp40","weapon_vj_spas12","weapon_vj_blaster"},vCat)
	VJ.AddNPC("SMG Turret","npc_vj_hzs_turret",vCat)
	VJ.AddNPC("Shotgun Turret","npc_vj_hzs_turret_shotguns",vCat)
	VJ.AddNPC("Sniper Turret","npc_vj_hzs_turret_sniper",vCat)

	local vCat = "Zombie Survival - Events"
	VJ.AddCategoryInfo(vCat,{Icon = "vj_icons/zs_event.png"})
	VJ.AddNPC("Zombie (Halloween)","npc_vj_zs_zombie_hw",vCat)

	local vCat = "Zombie Survival"
	VJ.AddCategoryInfo(vCat,{Icon = "vj_icons/zs.png"})
	VJ.AddNPC("Zombie","npc_vj_zs_zombie",vCat)
	VJ.AddNPC("Zombie Torso","npc_vj_zs_zombietorso",vCat)
	VJ.AddNPC("Fast Zombie","npc_vj_zs_fastzombie",vCat)
	VJ.AddNPC("Poison Zombie","npc_vj_zs_poisonzombie",vCat)
	VJ.AddNPC("Wraith","npc_vj_zs_wraith",vCat)
	VJ.AddNPC("Wraith (Stalker)","npc_vj_zs_stalker",vCat)
	VJ.AddNPC("Zombine","npc_vj_zs_zombine",vCat)
	VJ.AddNPC("Headcrab","npc_vj_zs_headcrab",vCat)
	VJ.AddNPC("Fast Headcrab","npc_vj_zs_fastheadcrab",vCat)
	VJ.AddNPC("Poison Headcrab","npc_vj_zs_poisonheadcrab",vCat)
	VJ.AddNPC("Wraithcrab","npc_vj_zs_wraithcrab",vCat)
	VJ.AddNPC("Chem Zombie","npc_vj_zs_chemzombie",vCat)
	VJ.AddNPC("Howler","npc_vj_zs_howler",vCat)
	
		-- Custom Classes --
	VJ.AddNPC("Burnzie","npc_vj_zs_burnzie",vCat) -- Burns targets
	VJ.AddNPC("Drifter","npc_vj_zs_draggy",vCat) -- Heals zombies, can bite

		-- Garry's Mod 13 ZS Classes (yk, the really shitty version of zs -_- thanks jetboom or whoever the fuck owns zs now, this gamemode is utter shit now --
	VJ.AddNPC("Fresh Dead","npc_vj_zs_freshdead",vCat)
	VJ.AddNPC("Ghoul","npc_vj_zs_ghoul",vCat)
	VJ.AddNPC("Bloated Zombie","npc_vj_zs_bloatedzombie",vCat)
	VJ.AddNPC("Gore Child","npc_vj_zs_gorechild",vCat)
	VJ.AddNPC("Mailed Zombie","npc_vj_zs_mailedzombie",vCat)
	VJ.AddNPC("(BOSS) Nightmare","npc_vj_zs_nightmare",vCat)
	VJ.AddNPC("(BOSS) Giga Gore Child","npc_vj_zs_gorechild_boss",vCat)
	VJ.AddNPC("(BOSS) Puke Puss","npc_vj_zs_pukepuss",vCat)
	VJ.AddNPC("(BOSS) Tickle Monster","npc_vj_zs_ticklemonster",vCat)

	VJ.AddNPCWeapon("VJ_ZS_Deagle","weapon_vj_zsh_deagle",false,vCat)
	VJ.AddNPCWeapon("VJ_ZS_Glock","weapon_vj_zsh_glock",false,vCat)
	VJ.AddNPCWeapon("VJ_ZS_MP5","weapon_vj_zsh_mp5",false,vCat)
	VJ.AddNPCWeapon("VJ_ZS_p228","weapon_vj_zsh_p228",false,vCat)
	VJ.AddNPCWeapon("VJ_ZS_USP","weapon_vj_zsh_usp",false,vCat)
	VJ.AddNPCWeapon("VJ_ZS_TMP","weapon_vj_zsh_tmp",false,vCat)

	if CLIENT then
		local ScrollSpeed = 0.01
		hook.Add("PlayerBindPress","VJ_ZS_ThirdpersonScrolling",function(ply,bind,pressed)
			if bind != "invnext" && bind != "invprev" then return end
			if !ply:GetNWBool("VJ_ZS_IsZombie") then return end
			if ScrollSpeed > CurTime() then
				return true
			end
			ply.VJ_ZS_Scroll = ply.VJ_ZS_Scroll or 0
			if bind == "invprev" then -- Scrolled up
				ply.VJ_ZS_Scroll = math.Clamp(ply.VJ_ZS_Scroll -5,0,VJ_ZS_MaxZoom)
			elseif bind == "invnext" then -- Scrolled down
				ply.VJ_ZS_Scroll = math.Clamp(ply.VJ_ZS_Scroll +5,0,VJ_ZS_MaxZoom)
			end
			local int = ply.VJ_ZS_Scroll
			net.Start("vj_zs_cameradist")
				net.WriteEntity(ply)
				net.WriteInt(int,10)
			net.SendToServer(ply)
			ScrollSpeed = CurTime() +0.01
			return true
		end)
	end

	-- if SERVER then
		hook.Add("UpdateAnimation","VJ_ZS_Animations",function(ply,vel,maxSeqGroundSpeed)
			if !ply:GetNWBool("VJ_ZS_IsZombie") then return end
			if !ply:Alive() then return end
			if !IsValid(ply:GetActiveWeapon()) then return end
			local wep = ply:GetActiveWeapon()
			
			ply:SetPoseParameter("move_yaw", math.NormalizeAngle(vel:Angle().yaw -ply:EyeAngles().y))
			
			local data = {}
			if wep.ZS_Animations then
				data = wep:ZS_Animations(vel,maxSeqGroundSpeed)
			end

			local len = vel:LengthSqr()
			local rate = 1
			if len > 1 then
				rate = math.min(len /maxSeqGroundSpeed ^2,2)
			end

			if data.sequence then
				local seq = ply:SelectWeightedSequence(data.sequence)
				if ply:GetSequence() ~= seq then
					ply:SetSequence(seq)
				end
			end

			if data.movex then
				ply:SetPoseParameter("move_x",data.movex)
			end
			if data.movey then
				ply:SetPoseParameter("move_y",data.movey)
			end
			ply:SetPlaybackRate(rate)
		end)
	-- end
	
	-- if SERVER then
		hook.Add("PlayerSpawn","VJ_ZS_PlayerHull",function(ply)
			local resetHull = true
			ply.VJ_ZS_SetHull = false
			ply.VJ_ZS_IsGhosting = false
			ply:ResetHull()
			ply:SetNWInt("VJ_ZS_Scroll",0)
			ply.VJ_ZS_Scroll = 0
			-- timer.Simple(0.5,function()
				-- if IsValid(ply) then
					-- if IsValid(ply:GetActiveWeapon()) then
						-- local wep = ply:GetActiveWeapon()
							-- print("Set HULL")
						-- if wep.ZHull then
							-- local hull = wep.ZHull
							-- ply:SetHull(Vector(-hull.x,-hull.y,0),Vector(hull.x,hull.y,hull.z))
							-- ply:SetHullDuck(Vector(-hull.x,-hull.y,0),Vector(hull.x,hull.y,hull.d))
							-- ply.VJ_ZS_SetHull = true
							-- resetHull = false
						-- end
					-- end
					-- if resetHull then
						-- ply:SetHull(Vector(-16,-16,0),Vector(16,16,72))
						-- ply:SetHullDuck(Vector(-16,-16,0),Vector(16,16,36))
					-- end
				-- end
			-- end)
		end)
		
		if SERVER then
			util.AddNetworkString("vj_zs_cameradist")
			net.Receive("vj_zs_cameradist",function(len,pl)
				local ply = net.ReadEntity()
				local amount = net.ReadInt(10)
				ply.VJ_ZS_Scroll = amount
			end)
		end
		
		if CLIENT then
			hook.Add("Tick","VJ_ZS_TickHull",function()
				-- local plys = player.GetAll()
				-- for _,ply in pairs(plys) do
					-- if IsValid(ply:GetActiveWeapon()) && ply:GetActiveWeapon().ZHull then
						-- local wep = ply:GetActiveWeapon()
						-- local hull = wep.ZHull
						-- ply:SetHull(Vector(-hull.x,-hull.y,0),Vector(hull.x,hull.y,hull.z))
						-- ply:SetHullDuck(Vector(-hull.x,-hull.y,0),Vector(hull.x,hull.y,hull.d))
					-- end
				-- end
			end)

			local matGlow = Material("Sprites/light_glow02_add_noz")
			local colHealthEmpty = Color(255,0,0,255)
			local colHealthFull = Color(20,255,20,255)
			local colHealth = Color(255,255,255)
			local HeartBeatTime = 0
			hook.Add("PostDrawTranslucentRenderables","VJ_ZS_HeartBeats",function() -- Credits to JetBoom
				if !LocalPlayer():GetNWBool("VJ_ZS_IsZombie") then return end

				HeartBeatTime = HeartBeatTime +(4 +(0.1) *5) *FrameTime()

				local eyepos = EyePos()
				local range = 2048 *2048
				local dist, healthfrac, pos, size
				local entities = ents.FindInSphere(LocalPlayer():GetPos(),range)
				for _,ent in pairs(entities) do
					if ent:IsPlayer() or ent:IsNPC() then
						local isZombieNPC = ent:IsNPC() && string.find(ent:GetClass(),"npc_vj_zs_")
						local isZombie = ent:IsPlayer() && ent:GetNWBool("VJ_ZS_IsZombie")
						dist = ent:GetPos():DistToSqr(eyepos)
						if ent != LocalPlayer() && ent:Health() > 0 && dist <= range && !isZombie && !isZombieNPC then
							healthfrac = math.Max(ent:Health(),0) /ent:GetMaxHealth()
							colHealth.r = math.Approach(colHealthEmpty.r,colHealthFull.r,math.abs(colHealthEmpty.r -colHealthFull.r) *healthfrac)
							colHealth.g = math.Approach(colHealthEmpty.g,colHealthFull.g,math.abs(colHealthEmpty.g -colHealthFull.g) *healthfrac)
							colHealth.b = math.Approach(colHealthEmpty.b,colHealthFull.b,math.abs(colHealthEmpty.b -colHealthFull.b) *healthfrac)
							pos = ent:WorldSpaceCenter()

							render.SetMaterial(matGlow)
							render.DrawSprite(pos,13,13,colHealth)
							size = math.sin(HeartBeatTime +ent:EntIndex()) *50 -21
							if size > 0 then
								render.DrawSprite(pos,size *1.5,size,colHealth)
								render.DrawSprite(pos,size,size *1.5,colHealth)
							end
						end
					end
				end
			end)
		end

	hook.Add("ShouldDrawLocalPlayer","VJ_ZS_DrawZombie",function(ply)
		if ply.VJ_ZS_Scroll && ply.VJ_ZS_Scroll > VJ_ZS_MinZoom && ply:GetNWBool("VJ_ZS_IsZombie") then return true end
	end)
	
	hook.Add("CalcView","VJ_ZS_ThirdPersonView",function(ply,pos,angles,fov)
		local int = ply.VJ_ZS_Scroll
		local enabled = ply.VJ_ZS_Scroll && ply.VJ_ZS_Scroll > VJ_ZS_MinZoom && ply:GetNWBool("VJ_ZS_IsZombie")
		if enabled then
			local view = {}
			view.origin = ply:VJ_ZSThirdPersonPos(pos,angles)
			view.angles = ply:EyeAngles()
			view.fov = fov
			return view
		end
	end)
	
	if SERVER then
		hook.Add("Tick","VJ_ZS_TickHull",function()
			local plys = player.GetAll()
			for _,ply in pairs(plys) do
				ply:VJ_ZS_SetGhosting(ply:KeyDown(IN_WALK))
				-- if IsValid(ply:GetActiveWeapon()) && ply:GetActiveWeapon().ZHull then
					-- local wep = ply:GetActiveWeapon()
					-- local hull = wep.ZHull
					-- ply:SetHull(Vector(-hull.x,-hull.y,0),Vector(hull.x,hull.y,hull.z))
					-- ply:SetHullDuck(Vector(-hull.x,-hull.y,0),Vector(hull.x,hull.y,hull.d))
				-- end
			end
		end)
		
		hook.Add("ShouldCollide","VJ_ZS_Collide",function(ent1,ent2)
			if ent1:IsPlayer() && !ent1.VJ_ZS_IsZombie then
				if ent1.VJ_ZS_IsGhosting && (ent2:GetClass() == "prop_physics" or ent2:GetClass() == "sent_vj_board" or ent2:GetClass() == "prop_physics_multiplayer") then
					return false
				end
			end
			return true
		end)
	end
	-- end
	
	hook.Add("EntityTakeDamage","VJ_ZS_PlayerSounds",function(ent,dmginfo)
		if ent:IsPlayer() && IsValid(ent:GetActiveWeapon()) && ent:GetActiveWeapon().ZHealth then
			ent.NextZPainSoundT = ent.NextZPainSoundT or CurTime()
			if CurTime() > ent.NextZPainSoundT then
				ent:GetActiveWeapon():PainSound()
				ent.NextZPainSoundT = CurTime() +math.Rand(1,3)
			end
		end
	end)
	
	if SERVER then
		hook.Add("PlayerFootstep","VJ_ZS_PlayerStepSounds",function(ent,pos,foot/*0=left,1=right*/,snd,vol,tblCanHear)
			if ent:IsPlayer() && IsValid(ent:GetActiveWeapon()) && ent:GetActiveWeapon().ZSteps then
				local tbl = ent:GetActiveWeapon().ZSteps
				if tbl == false then return true end
				ent:EmitSound(VJ_PICK(tbl),ent:GetActiveWeapon().ZStepVolume or math.random(50,65),ent:GetActiveWeapon().ZStepPitch or 100)
				return true
			end
		end)
		
		hook.Add("PlayerStepSoundTime","VJ_ZS_PlayerStepSoundTime",function(ent,enum,isWalking)
			if ent:IsPlayer() && IsValid(ent:GetActiveWeapon()) && ent:GetActiveWeapon().ZStepTime then
				if ent:GetActiveWeapon().ZStepTime == false then return end
				return ent:GetActiveWeapon().ZStepTime
			end
		end)
	end
	
	hook.Add("PlayerSay","VJ_ZS_PlayerStepSoundTime",function(sender,text,teamChat)
		if text == "gg" then
			for _,v in pairs(ents.FindByClass("npc_vj_hzs_bot")) do
				if math.random(1,3) == 1 then
					timer.Simple(math.Rand(1,2),function()
						if IsValid(v) then
							if math.random(1,30) == 1 then
								v:BotChat(sender:Nick() .. " shut the fuck up with the gg shit! we're not all gonna copy you..")
							else
								v:BotChat(text)
							end
						end
					end)
				end
			end
		end
	end)
	
	game.AddAmmoType({name="vj_zs_boards",dmgtype=DMG_GENERIC})
	
	if CLIENT then -- Credits to Infected Wars
		local VJ_ZS_HowlerTime = 0
		local VJ_ZS_HowlerLength = 0
		local VJ_ZS_HowlerTab = {
			["$pp_colour_addr"] 		= 0,
			["$pp_colour_addg"] 		= 0,
			["$pp_colour_addb"] 		= 0,
			["$pp_colour_brightness"] 	= 0,
			["$pp_colour_contrast"] 	= 1,
			["$pp_colour_colour"] 		= 0,
			["$pp_colour_mulr"] 		= 0,
			["$pp_colour_mulg"] 		= 0,
			["$pp_colour_mulb"] 		= 0
		}

		local function VJ_ZS_DrawHowlerEffects()
			DrawColorModify(VJ_ZS_HowlerTab)
			DrawMotionBlur(0.2,math.Clamp(VJ_ZS_HowlerTime -CurTime(),0,1),0)
			VJ_ZS_HowlerTab["$pp_colour_colour"] = math.Approach(VJ_ZS_HowlerTab["$pp_colour_colour"],1,VJ_ZS_HowlerLength *FrameTime())
			local sev = math.Clamp(VJ_ZS_HowlerTime -CurTime(),0,5) /35
			VJ_ZS_HowlerTab["$pp_colour_brightness"] = math.Rand(-sev *2,sev *2)
			local ply = LocalPlayer()
			if !ply:GetNWBool("VJ_ZS_IsZombie") then
				local ang = (ply:GetAimVector() +Vector(math.Rand(-sev,sev),math.Rand(-sev,sev),math.Rand(-sev,sev))):Angle()
				ply:SetEyeAngles(ang)
			end
			if VJ_ZS_HowlerTime < CurTime() then
				VJ_ZS_HowlerTab["$pp_colour_brightness"] = 0
				hook.Remove("RenderScreenspaceEffects","VJ_ZS_DrawHowlerEffects")
			end
		end	

		function StalkerFuck(length)
			local len = length or 3
			hook.Remove("RenderScreenspaceEffects","VJ_ZS_DrawHowlerEffects")
			VJ_ZS_HowlerTab["$pp_colour_colour"] = 0
			VJ_ZS_HowlerTime = CurTime() +len
			VJ_ZS_HowlerLength = len
			hook.Add("RenderScreenspaceEffects","VJ_ZS_DrawHowlerEffects",VJ_ZS_DrawHowlerEffects)
		end
	end

	local PLY = FindMetaTable("Player")
	function PLY:VJ_GiveWeapon(wep)
		self.VJ_CanBePickedUpWithOutUse = true
		self.VJ_CanBePickedUpWithOutUse_Class = wep
		self:Give(wep)
	end

	function PLY:VJ_ZS_SetGhosting(bool)
		if self.VJ_ZS_IsZombie then self.VJ_ZS_IsGhosting = false return end
		
		local function CanRun()
			local run = false
			for _,v in pairs(ents.FindByClass("sent_vj_zs_gamemode")) do
				if v then run = true break end
			end
			return run
		end

		if !CanRun() then return end
		
		local noCollide = COLLISION_GROUP_WORLD
		if self:GetCollisionGroup() != noCollide then
			self.VJ_ZS_OldCollisionGroup = self:GetCollisionGroup()
		end
		self.VJ_ZS_IsGhosting = bool
		self:SetCustomCollisionCheck(bool)
		if bool then
			self:SetCollisionGroup(noCollide)
		else
			self:SetCollisionGroup(self.VJ_ZS_OldCollisionGroup)
		end
	end

	function PLY:VJ_ZS_Howled(iIntensity)
		if iIntensity == nil then
			return
		end
		if SERVER then self:SendLua( "StalkerFuck("..( iIntensity )..")" ) end
	end
	
	local ViewHullMins = Vector(-8,-8,-8)
	local ViewHullMaxs = Vector(8,8,8)
	function PLY:VJ_ZSThirdPersonPos(origin,angles)
		local allplayers = player.GetAll()
		local tr = util.TraceHull({
			start = origin,
			endpos = origin +angles:Forward() *-math.max(ply.VJ_ZS_Scroll,self:BoundingRadius()),
			mask = MASK_SHOT,
			filter = allplayers,
			mins = ViewHullMins,
			maxs = ViewHullMaxs
		})
		return tr.HitPos +tr.HitNormal *5
	end

	function PLY:VJ_GetAmmoTypes()
		local tbl = {}
		for ammotype,amount in pairs(self:GetAmmo()) do
			table.insert(tbl,ammotype)
		end
		return tbl
	end

	function PLY:VJ_RestoreAmmo(amount,a,b)
		for ammotype,ammocount in pairs(self:GetAmmo()) do
			if amount == false then
				self:SetAmmo(ammocount +math.random(a,b),ammotype)
			else
				self:SetAmmo(ammocount +amount,ammotype)
			end
		end
	end
	
	local ENT = FindMetaTable("Weapon")
	function ENT:VJ_ZSSkin(mat)
		local c = GetConVarNumber("vj_zs_glow")
		if c == 0 then
			local ply = self.Owner
			if IsValid(ply:GetViewModel()) then
				ply:GetViewModel():SetMaterial(mat)
			end
			ply:SetMaterial(mat)
		end
	end
	
	local ENT = FindMetaTable("NPC")
	function ENT:VJ_ZSSkin(mat)
		local c = GetConVarNumber("vj_zs_glow")
		if c == 0 then
			self:SetMaterial(mat)
		end
	end

	function ENT:CreateZSBlood(count,dmginfo)
		for i = 1,count do
			local dmg_pos = dmginfo:GetDamagePosition()
			if dmg_pos == Vector(0,0,0) then dmg_pos = self:GetPos() + self:OBBCenter() end
			local effectdata = EffectData()
			effectdata:SetOrigin(dmg_pos)
			effectdata:SetScale(dmginfo:GetDamageForce().z /3)
			effectdata:SetEntity(self)
			effectdata:SetMagnitude(3)
			util.Effect("zs_blood",effectdata)
		end
	end

	function ENT:AdjustBones(tbl,alter)
		local ang = false
		if type(alter) == "Angle" then
			ang = true
		end
		for _,v in pairs(tbl) do
			local boneid = self:LookupBone(v)
			if boneid && boneid > 0 then
				if ang == false then
					self:ManipulateBonePosition(boneid,alter)
				else
					self:ManipulateBoneAngles(boneid,alter)
				end
			end
		end
	end
	
	if CLIENT then
		hook.Add("RenderScreenspaceEffects","VJ_ZS_ZombieFlashlight",function()
			local ply = LocalPlayer()
			if !ply:GetNWBool("VJ_ZS_IsZombie") then return end
			local tab_infected = {
				["$pp_colour_addr"] = 0.5,
				["$pp_colour_addg"] = 0.4,
				["$pp_colour_addb"] = 0.2,
				["$pp_colour_brightness"] = -0.4,
				["$pp_colour_contrast"] = 0.8,
				["$pp_colour_colour"] = 1,
				["$pp_colour_mulr"] = 1,
				["$pp_colour_mulg"] = 0.2,
				["$pp_colour_mulb"] = 0
			}
			DrawColorModify(tab_infected)
			local light = DynamicLight(LocalPlayer():EntIndex())
			if (light) then
				light.Pos = LocalPlayer():GetPos() +Vector(0,0,20)
				light.r = 255
				light.g = 100
				light.b = 100
				light.Brightness = 0
				light.Size = 450
				light.Decay = 0
				light.DieTime = CurTime() +0.2
				light.Style = 0
			end
		end)

		hook.Add("PreDrawHalos","VJ_ZS_ZombieVision",function()
			local ply = LocalPlayer()
			if !ply:GetNWBool("VJ_ZS_IsZombie") then return end
			local tb = {}
			local tbFri = {}
			local tbFriPly = {}
			for _,v in pairs(ents.GetAll()) do
				if v:IsNPC() or v:IsPlayer() then
					if v:IsNPC() && string.find(v:GetClass(),"npc_vj_zs") then
						table.insert(tbFri,v)
					elseif v:IsPlayer() && v:GetNWBool("VJ_ZS_IsZombie") then
						table.insert(tbFriPly,v)
					else
						table.insert(tb,v)
					end
				end
			end
			halo.Add(tb,Color(0,150,255),4,4,3,true,true)
			halo.Add(tbFri,Color(0,200,0),4,4,3,true,true)
			halo.Add(tbFriPly,Color(200,0,200),4,4,3,true,true)
		end)
	end

	VJ.AddClientConVar("vj_zs_music_volume",50)
	VJ.AddClientConVar("vj_zs_musicset",1)
	VJ.AddClientConVar("vj_zs_beat_multi",1)
	VJ.AddClientConVar("vj_zs_forcesong",0)
	VJ.AddClientConVar("vj_zs_forcesong_a",1)
	VJ.AddClientConVar("vj_zs_forcesong_b",1)
	VJ.AddClientConVar("vj_zs_forcesong_c",1)
	VJ.AddClientConVar("vj_zs_vo",1)
	VJ.AddClientConVar("vj_zs_zombieclass",0) -- 0 = Default/Random
	VJ.AddConVar("vj_zs_difficulty",1) -- Increases the multiplier for the amount of zombies that can spawn
	VJ.AddConVar("vj_zs_weapons",0) -- Enforces set weapons to players
	VJ.AddConVar("vj_zs_botanger",0) -- Allow player bots to become angry after friendly damage
	VJ.AddConVar("vj_zs_botchat",1)
	VJ.AddConVar("vj_zs_glow",1) -- Use the original Zombie Survival zombie skins
	VJ.AddConVar("vj_zs_freezombies",0)
	VJ.AddConVar("vj_zs_allowplayerzombies",0) -- Allow players to play as zombies
	VJ.AddConVar("vj_zs_becomezombies",0) -- If the above is true, then players will become zombies on death
	VJ.AddConVar("vj_zs_wavetime",180)
	VJ.AddConVar("vj_zs_intermissiontime",45)
	VJ.AddConVar("vj_zs_maxzombies",144) -- Max zombies that can be on screen at any time if they can even get this high

	local function RemoveNPCs(ply)
		if !ply:IsAdmin() then return end
		if !ply:IsSuperAdmin() then return end
		local tbl = {"npc_maker","npc_zombie","npc_zombie_torso","npc_fastzombie","npc_fastzombie_torso","npc_poisonzombie","npc_headcrab","npc_headcrab_fast","npc_headcrab_poison","npc_headcrab_black","npc_zombine"}
		for _,v in pairs(ents.GetAll()) do
			if table.HasValue(tbl,v:GetClass()) then
				v:Remove()
			end
		end
	end
	concommand.Add("vj_zs_removenpcs",RemoveNPCs)

	if CLIENT then
		language.Add("vjbase.zs_class.random","Random Class")
		language.Add("vjbase.zs_class.zombie","[1] Zombie")
		language.Add("vjbase.zs_class.ghoul","[2] Ghoul")
		language.Add("vjbase.zs_class.zombie_torso","[2] Zombie Torso")
		language.Add("vjbase.zs_class.headcrab","[2] Headcrab")
		language.Add("vjbase.zs_class.fast_zombie","[3] Fast Zombie")
		language.Add("vjbase.zs_class.fast_headcrab","[3] Fast Headcrab")
		language.Add("vjbase.zs_class.wraith_old","[3] Wraith")
		language.Add("vjbase.zs_class.mailed_zombie","[4] Mailed Zombie")
		language.Add("vjbase.zs_class.howler","[4] Howler")
		language.Add("vjbase.zs_class.wraith","[5] Wraith (Stalker)")
		language.Add("vjbase.zs_class.wraithcrab","[5] Wraithcrab")
		language.Add("vjbase.zs_class.poison_headcrab","[6] Poison Headcrab")
		language.Add("vjbase.zs_class.draggy","[6] Drifter")
		language.Add("vjbase.zs_class.burnzie","[7] Burnzie")
		language.Add("vjbase.zs_class.poison_zombie","[7] Poison Zombie")
		language.Add("vjbase.zs_class.zombine","[7] Zombine")
		language.Add("vjbase.zs_class.chem_zombie","[8] Chem Zombie")

		language.Add("vjbase.zs_track.gmod11","[1] Garry's Mod 11")
		language.Add("vjbase.zs_track.gmod13","[2] Garry's Mod 13")
		language.Add("vjbase.zs_track.mrgreen","[3] Mr. Green")

		hook.Add("PopulateToolMenu", "VJ_ADDTOMENU_ZS_CLIENT", function()
			spawnmenu.AddToolMenuOption("DrVrej", "SNPC Configures", "Zombie Survival - Client", "Zombie Survival - Client", "", "", function(Panel)
				Panel:AddControl( "Label", {Text = "You are not an admin!"})
				Panel:AddControl("Slider", {Label = "Music Volume", Command = "vj_zs_music_volume", Min = 0, Max = 100})
				
				local vj_zs_musicset = {Options = {}, CVars = {}, Label = "Select Music Set", MenuButton = "0"}
				vj_zs_musicset.Options["#vjbase.zs_track.gmod11"] = {vj_zs_musicset = "1"}
				vj_zs_musicset.Options["#vjbase.zs_track.gmod13"] = {vj_zs_musicset = "2"}
				vj_zs_musicset.Options["#vjbase.zs_track.mrgreen"] = {vj_zs_musicset = "3"}
				Panel:AddControl("ComboBox",vj_zs_musicset)
				
				-- Panel:AddControl("Slider", { Label 	= "Music Set", Command = "vj_zs_musicset", Min = 1, Max = 3})
				-- Panel:ControlHelp("Music Set - (1 = GMod 11 OST | 2 = GMod 13 OST | 3 = Mr. Green OST)")
				
				Panel:AddControl("Slider", { Label 	= "Beat Req. Multiplier", Command = "vj_zs_beat_multi", Min = 1, Max = 5})
				Panel:AddControl("Checkbox", { Label = "Force Specific Track?", Command = "vj_zs_forcesong"})
				Panel:AddControl("Slider", { Label 	= "Force Track (Set 1)", Command = "vj_zs_forcesong_a", Min = 1, Max = 8})
				Panel:AddControl("Slider", { Label 	= "Force Track (Set 2)", Command = "vj_zs_forcesong_b", Min = 1, Max = 10})
				Panel:AddControl("Slider", { Label 	= "Force Track (Set 3)", Command = "vj_zs_forcesong_c", Min = 1, Max = 9})
				Panel:AddControl("Checkbox", { Label = "Enable VO", Command = "vj_zs_vo"})

				Panel:ControlHelp("Notice: If chosen class isn't unlocked, a random one will be assigned!")
				Panel:ControlHelp("Key: [Wave Requirement] Class Name")
				local vj_zs_class = {Options = {}, CVars = {}, Label = "Select Zombie Class", MenuButton = "0"}
				vj_zs_class.Options["#vjbase.zs_class.random"] = {vj_zs_zombieclass = "0"}
				vj_zs_class.Options["#vjbase.zs_class.zombie"] = {vj_zs_zombieclass = "1"}
				vj_zs_class.Options["#vjbase.zs_class.ghoul"] = {vj_zs_zombieclass = "2"}
				vj_zs_class.Options["#vjbase.zs_class.zombie_torso"] = {vj_zs_zombieclass = "3"}
				vj_zs_class.Options["#vjbase.zs_class.headcrab"] = {vj_zs_zombieclass = "4"}
				vj_zs_class.Options["#vjbase.zs_class.fast_zombie"] = {vj_zs_zombieclass = "5"}
				vj_zs_class.Options["#vjbase.zs_class.fast_headcrab"] = {vj_zs_zombieclass = "6"}
				vj_zs_class.Options["#vjbase.zs_class.wraith_old"] = {vj_zs_zombieclass = "7"}
				vj_zs_class.Options["#vjbase.zs_class.mailed_zombie"] = {vj_zs_zombieclass = "8"}
				vj_zs_class.Options["#vjbase.zs_class.howler"] = {vj_zs_zombieclass = "9"}
				vj_zs_class.Options["#vjbase.zs_class.wraith"] = {vj_zs_zombieclass = "10"}
				vj_zs_class.Options["#vjbase.zs_class.wraithcrab"] = {vj_zs_zombieclass = "11"}
				vj_zs_class.Options["#vjbase.zs_class.poison_headcrab"] = {vj_zs_zombieclass = "12"}
				vj_zs_class.Options["#vjbase.zs_class.draggy"] = {vj_zs_zombieclass = "13"}
				vj_zs_class.Options["#vjbase.zs_class.burnzie"] = {vj_zs_zombieclass = "14"}
				vj_zs_class.Options["#vjbase.zs_class.poison_zombie"] = {vj_zs_zombieclass = "15"}
				vj_zs_class.Options["#vjbase.zs_class.zombine"] = {vj_zs_zombieclass = "16"}
				vj_zs_class.Options["#vjbase.zs_class.chem_zombie"] = {vj_zs_zombieclass = "17"}
				Panel:AddControl("ComboBox",vj_zs_class)
			end, {})
		end)

		hook.Add("PopulateToolMenu", "VJ_ADDTOMENU_ZS", function()
			spawnmenu.AddToolMenuOption("DrVrej", "SNPC Configures", "Zombie Survival", "Zombie Survival", "", "", function(Panel)
					if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then return end
					Panel:AddControl("Label", {Text = "Notice: The below settings are server/admin only"})
					Panel:AddControl("Button", {Label = "Remove Vanilla NPCs/Spawners", Command = "vj_zs_removenpcs"})
					Panel:AddControl("Checkbox", {Label = "Enforce Human Weapons?", Command = "vj_zs_weapons"})
					Panel:AddControl("Label", {Text = "Currently no way to set your own weapons via menu"})
					Panel:AddControl("Label", {Text = "Decompile the mod and change the weapons yourself (if you want)"})
					Panel:AddControl("Checkbox", {Label = "Player Bot NPCs can type in the chat?", Command = "vj_zs_botchat"})
					Panel:AddControl("Checkbox", {Label = "Player Bot NPCs can be angry from TD?", Command = "vj_zs_botanger"})
					Panel:AddControl("Checkbox", {Label = "Use Classic ZS skins?", Command = "vj_zs_glow"})
					Panel:AddControl("Checkbox", {Label = "Free Classes", Command = "vj_zs_freezombies"})
					Panel:AddControl("Checkbox", {Label = "Allow Player Zombies?", Command = "vj_zs_allowplayerzombies"})
					Panel:AddControl("Checkbox", {Label = "Become Zombies on Death?", Command = "vj_zs_becomezombies"})
					Panel:AddControl("Slider", { Label 	= "Wave Time", Command = "vj_zs_wavetime", Min = 10, Max = 720})
					Panel:AddControl("Slider", { Label 	= "Intermission Time", Command = "vj_zs_intermissiontime", Min = 15, Max = 180})
					Panel:AddControl("Slider", { Label 	= "Difficulty (Influcenes Max Zombies)", Command = "vj_zs_difficulty", Min = 1, Max = 75})
					Panel:AddControl("Slider", { Label 	= "Max Zombies", Command = "vj_zs_maxzombies", Min = 10, Max = 600})
			end,{})
		end)
	end

-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("ERROR!")
				VJF:SetSize(790,560)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				
				local VJURL = vgui.Create("DHTML",VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				VJURL:Dock(FILL)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end