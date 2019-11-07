AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_junk/popcan01a.mdl")
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetNotSolid(true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	self.CanDamage = IsValid(self.MasterEntity)
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos() +Vector(0,0,40))
	effectdata:SetEntity(self)
	util.Effect("zs_spawner",effectdata)
	if self.CanDamage then
		for _,v in pairs(player.GetAll()) do
			v.NextZSDMGT = v.NextZSDMGT or CurTime()
			if v:GetPos():Distance(self:GetPos() +Vector(0,0,40)) <= 200 && GetConVarNumber("ai_ignoreplayers") == 0 && CurTime() > v.NextZSDMGT then
				v:TakeDamage(10,self,self)
				v:EmitSound("ambient/voices/cough" .. math.random(1,2) .. ".wav",65,100)
				v.NextZSDMGT = CurTime() +2
			end
		end
	end
	self:NextThink(CurTime() +0.01)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRemove()

end