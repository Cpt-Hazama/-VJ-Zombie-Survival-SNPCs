
function EFFECT:Init(data)
	self.DeathTime = CurTime() +10
	self.Alpha = 235
	self.Speed = Vector(0,0,math.Rand(30,60))
	self.SpawnTime = CurTime() +math.Rand(0,5)
	self.Scale = 2
end

function EFFECT:Think()
	self.Alpha = self.Alpha -1
	self:SetPos(self:GetPos() +self.Speed *FrameTime())
	if CurTime() > self.DeathTime then
		return false
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial(Material("effects/redflare"))
	local Pos = self:GetPos()
	local EyeNormal = (EyePos() -Pos):GetNormal()
	EyeNormal:Mul(self.Scale)	
	EyeNormal.z = 0
	local Rot = 180 +math.sin((self.SpawnTime +CurTime()) *2) *10
	Pos = Pos +EyeAngles():Right() *math.cos((self.SpawnTime +CurTime()) *2) *4 *self.Scale
	render.DrawQuadEasy(Pos,EyeNormal,30,30,Color(255,0,150,self.Alpha),Rot)
end