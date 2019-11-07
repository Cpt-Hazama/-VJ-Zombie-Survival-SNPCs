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
	
	VJ.AddClientConVar("vj_zs_music_volume",50)
	VJ.AddConVar("vj_zs_difficulty",1)
	VJ.AddConVar("vj_zs_maxzombies",144) -- Doesn't mean this is the amount you will have on-screen

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