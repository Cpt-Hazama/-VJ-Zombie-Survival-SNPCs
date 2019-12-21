if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
MAXBOARDS = 6
SWEP.Base 						= "weapon_vj_base"
SWEP.PrintName					= "Barricade Kit"
SWEP.Author 					= "Cpt. Hazama"
SWEP.Contact					= "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose					= "This weapon is made for Players and NPCs"
SWEP.Instructions				= "Controls are like a regular weapon."
SWEP.Category					= "VJ Base - Zombie Survival"
	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
SWEP.Slot						= 1 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
SWEP.SlotPos					= 4 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.UseHands					= true
end
SWEP.UseHands					= true
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel					= "models/cpthazama/zombiesurvival/weapons/v_hammer.mdl"
SWEP.WorldModel					= "models/cpthazama/zombiesurvival/weapons/w_hammer.mdl"
SWEP.HoldType 					= "melee2"
SWEP.ViewModelFOV				= 40 -- Player FOV for the view model
SWEP.Spawnable					= true
SWEP.AdminSpawnable				= false
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.ClipSize			= MAXBOARDS -- Max amount of bullets per clip
SWEP.Primary.Recoil				= 0 -- How much recoil does the player get?
SWEP.Primary.Delay				= 1.25 -- Time until it can shoot again
SWEP.Primary.Automatic			= false -- Is it automatic?
SWEP.Primary.Ammo				= "vj_zs_boards" -- Ammo type
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.AllowFireInWater = true
SWEP.Primary.DisableBulletCode	= true -- The bullet won't spawn, this can be used when creating a projectile-based weapon
SWEP.PrimaryEffects_MuzzleFlash = false
SWEP.PrimaryEffects_SpawnShells = false
SWEP.PrimaryEffects_SpawnDynamicLight = false
	-- Deployment Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.DelayOnDeploy 				= 1 -- Time until it can shoot again after deploying the weapon
	-- Reload Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasReloadSound				= false -- Does it have a reload sound? Remember even if this is set to false, the animation sound will still play!
	-- Idle Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasIdleAnimation			= true -- Does it have a idle animation?
SWEP.AnimTbl_Idle				= {ACT_VM_IDLE}
SWEP.AnimTbl_PrimaryFire = {ACT_VM_HITCENTER}
SWEP.NextIdle_Deploy			= 0.5 -- How much time until it plays the idle animation after the weapon gets deployed
SWEP.NextIdle_PrimaryAttack		= 1.2 -- How much time until it plays the idle animation after attacking(Primary)
---------------------------------------------------------------------------------------------------------------------------------------------
if SERVER then
SWEP.Yaw = 90
SWEP.TurnAmount = 90
function SWEP:CustomOnInitialize()
	timer.Simple(0.1,function()
		if IsValid(self) then
			self:CreateGhost()
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CreateGhost()
	self.Ghost = ents.Create("prop_dynamic")
	self.Ghost:SetModel("models/props_debris/wood_board05a.mdl")
	self.Ghost:SetPos(self:GetPos())
	self.Ghost:SetAngles(self:GetAngles())
	self.Ghost:Spawn()
	self.Ghost:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.Ghost:DrawShadow(false)
	self.Ghost:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self.Ghost:SetColor(Color(0,255,0,180))
	self:UpdateGhost(self:GetOwner():GetEyeTrace())
	self:DisplayGhost(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local nextClick = 0
function SWEP:RotateGhost(amount)
	if IsValid(self.Ghost) then
		if self.Ghost:GetNoDraw() then return end
		if RealTime() > nextClick then
			self:EmitSound("npc/headcrab_poison/ph_step4.wav")
			nextClick = RealTime() +0.3
		end
		self.Yaw = math.Round(math.NormalizeAngle(self.Yaw +amount))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DoHammerAnimation()
	if CurTime() > self.Primary.Delay then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SendWeaponAnim(VJ_PICK(self.AnimTbl_PrimaryFire))
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		-- timer.Simple(self.NextIdle_PrimaryAttack,function() if self:IsValid() then self:DoIdleAnimation() end end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local nextFix = CurTime()
function SWEP:CustomOnThink()
	if !IsValid(self.Ghost) then
		self:CreateGhost()
	end
	local owner = self:GetOwner()
	local trace = owner:GetEyeTrace()
	local dist = trace.HitPos:Distance(owner:GetPos())

	if owner:GetAmmoCount(self:GetPrimaryAmmoType()) > MAXBOARDS then
		owner:SetAmmo(MAXBOARDS,self:GetPrimaryAmmoType())
	end

	if trace.Hit && IsValid(trace.Entity) && trace.Entity:GetClass() == "sent_vj_board" && dist <= 150 then
		self:DisplayGhost(false)
		if trace.Entity.VJ_ZS_Owner == owner then
			if owner:KeyDown(IN_ATTACK2) then
				if CurTime() > self.Primary.Delay then
					self:DoHammerAnimation()
					trace.Entity:EmitSound("physics/wood/wood_plank_break"..math.random(1,4)..".wav",70,100)
					self:SetClip1(self:Clip1() +1)
					self:BoardSounds(5,trace.HitPos)
					local effectdata = EffectData()
					effectdata:SetOrigin(trace.Entity:GetPos())
					util.Effect("VJ_Small_Dust1",effectdata)
					trace.Entity:Remove()
				end
			end
			if owner:KeyDown(IN_RELOAD) && CurTime() > nextFix && trace.Entity:Health() < 100 then
				if CurTime() > self.Primary.Delay then
					self:DoHammerAnimation()
					trace.Entity:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(1,5)..".wav",70,100)
					local fixHP = trace.Entity:Health() +5
					trace.Entity:SetHealth(math.Clamp(fixHP,0,100))
					local effectdata = EffectData()
					effectdata:SetOrigin(trace.HitPos)
					util.Effect("GlassImpact",effectdata)
					nextFix = CurTime() +1
				end
			end
		end
	else
		if dist <= 150 then
			self:UpdateGhost(trace)
			self:DisplayGhost(true)
		else
			self:DisplayGhost(false)
		end
		if owner:KeyDown(IN_ATTACK2) then
			self:RotateGhost(FrameTime() *self.TurnAmount)
		end
		if owner:KeyDown(IN_RELOAD) then
			self:RotateGhost(FrameTime() *-self.TurnAmount)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:DisplayGhost(bDraw)
	if IsValid(self.Ghost) then
		self.Ghost:SetNoDraw(!bDraw)
		if self:Clip1() <= 0 then
			self.Ghost:SetColor(Color(255,0,0,180))
		else
			self.Ghost:SetColor(Color(0,255,0,180))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:UpdateGhost(trace)
	-- print(type(trace.HitPos +trace.HitNormal))
	if IsValid(self.Ghost) then
		local pos = trace.HitPos
		local norm = trace.HitNormal
		local ang = Angle(norm.x,norm:Angle().y,self.Yaw)
		self.Ghost:SetPos(pos)
		self.Ghost:SetAngles(ang)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnEquip()
	self:DisplayGhost(true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnHolster()
	self:DisplayGhost(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnRemove()
	self.Ghost:Remove()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:BoardSounds(count,ent)
	if type(ent) == "Vector" then
		for i = 1,count do
			timer.Simple(0.1 *i,function()
				if math.random(1,3) == 1 then
					sound.Play("weapons/crowbar/crowbar_impact"..math.random(1,2)..".wav",ent,math.random(70,75),math.random(92,105))
				end
				sound.Play("physics/wood/wood_plank_break"..math.random(1,4)..".wav",ent,math.random(70,75),math.random(92,105))
			end)
		end
	else
		for i = 1,count do
			timer.Simple(0.1 *i,function()
				if IsValid(ent) then
					if math.random(1,3) == 1 then ent:EmitSound("weapons/crowbar/crowbar_impact"..math.random(1,2)..".wav",math.random(70,75),math.random(92,105)) end
					ent:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(1,5)..".wav",math.random(70,75),math.random(92,105))
				end
			end)
		end
	end
end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_BeforeShoot()
	if (CLIENT) then return end
	if self.Ghost:GetNoDraw() then self:SetNextPrimaryFire(CurTime() + 1.2); self:SetClip1(self:Clip1() +1); self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav") return end
	local trace = self.Owner:GetEyeTrace()
	if trace.Hit && IsValid(trace.Entity) && (trace.Entity:IsNPC() or trace.Entity:IsPlayer() or trace.Entity:IsNextBot()) then return end
	local ent = ents.Create("sent_vj_board")
	local pos = self.Ghost:GetPos()
	local ang = self.Ghost:GetAngles()
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:EmitSound("npc/dog/dog_servo12.wav")
	ent.VJ_ZS_Owner = self.Owner
	-- ent:SetOwner(self:GetOwner())
	ent:SetHealth(100)
	ent:SetMoveType(MOVETYPE_NONE)
	self:BoardSounds(7,ent)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Reload()
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttackEffects()
	return true
end