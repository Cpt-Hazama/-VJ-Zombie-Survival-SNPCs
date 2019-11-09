/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2019 by Cpt. Hazama, All rights reserved. ***
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

	local vCat = "Zombie Survival - Tools"
	VJ.AddNPC("Gamemode","sent_vj_zs_gamemode",vCat)
	VJ.AddNPC("Zombie Gas","sent_vj_zs_spawner",vCat)

	VJ.AddNPC("SMG Turret","npc_vj_hzs_turret",vCat)
	VJ.AddNPC("Shotgun Turret","npc_vj_hzs_turret_shotguns",vCat)
	VJ.AddNPC("Sniper Turret","npc_vj_hzs_turret_sniper",vCat)

	local vCat = "Zombie Survival"
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
	
	hook.Add("EntityTakeDamage","VJ_ZS_PlayerSounds",function(ent,dmginfo)
		if ent:IsPlayer() && IsValid(ent:GetActiveWeapon()) && ent:GetActiveWeapon().ZHealth then
			ent.NextZPainSoundT = ent.NextZPainSoundT or CurTime()
			if CurTime() > ent.NextZPainSoundT then
				ent:GetActiveWeapon():PainSound()
				ent.NextZPainSoundT = CurTime() +math.Rand(1,3)
			end
		end
	end)

	local ENT = FindMetaTable("NPC")
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
	VJ.AddConVar("vj_zs_difficulty",1) -- Increases the multiplier for the amount of zombies that can spawn
	VJ.AddConVar("vj_zs_allowplayerzombies",0) -- Allow players to play as zombies
	VJ.AddConVar("vj_zs_becomezombies",0) -- If the above is true, then players will become zombies on death
	VJ.AddConVar("vj_zs_wavetime",180)
	VJ.AddConVar("vj_zs_intermissiontime",45)
	VJ.AddConVar("vj_zs_maxzombies",144) -- Max zombies that can be on screen at any time if they can even get this high

	if CLIENT then
		hook.Add("PopulateToolMenu", "VJ_ADDTOMENU_ZS", function()
			spawnmenu.AddToolMenuOption("DrVrej", "SNPC Configures", "Zombie Survival", "Zombie Survival", "", "", function(Panel)
				if !game.SinglePlayer() then
				if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then
					Panel:AddControl( "Label", {Text = "You are not an admin!"})
					Panel:AddControl("Slider", {Label = "Music Volume", Command = "vj_zs_music_volume", Type = "Float", Min = 0, Max = 100})
					Panel:AddControl("Slider", { Label 	= "Music Set", Command = "vj_zs_musicset", Type = "Float", Min = 1, Max = 2})
					Panel:ControlHelp("Music Set - (1 = GMod 11 OST | 2 = GMod 13 OST)")
					Panel:ControlHelp("Notice: Only admins can change the main settings")
					return
					end
				end

				Panel:AddControl("Slider", {Label = "Music Volume", Command = "vj_zs_music_volume", Type = "Float", Min = 0, Max = 100})
				Panel:AddControl("Slider", { Label 	= "Music Set", Command = "vj_zs_musicset", Type = "Float", Min = 1, Max = 2})
				Panel:ControlHelp("Music Set - (1 = GMod 11 OST | 2 = GMod 13 OST)")
				Panel:AddControl("Label", {Text = "Notice: The below settings are server/admin only"})
				Panel:AddControl("Checkbox", {Label = "Allow Player Zombies?", Command = "vj_zs_allowplayerzombies"})
				Panel:AddControl("Checkbox", {Label = "Become Zombies on Death?", Command = "vj_zs_becomezombies"})
				Panel:AddControl("Slider", { Label 	= "Wave Time", Command = "vj_zs_wavetime", Type = "Float", Min = 5, Max = 720})
				Panel:AddControl("Slider", { Label 	= "Intermission Time", Command = "vj_zs_intermissiontime", Type = "Float", Min = 5, Max = 120})
				Panel:AddControl("Slider", { Label 	= "Difficulty (Influcenes Max Zombies)", Command = "vj_zs_difficulty", Type = "Float", Min = 1, Max = 100})
				Panel:AddControl("Slider", { Label 	= "Max Zombies", Command = "vj_zs_maxzombies", Type = "Float", Min = 10, Max = 600})
			end, {})
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