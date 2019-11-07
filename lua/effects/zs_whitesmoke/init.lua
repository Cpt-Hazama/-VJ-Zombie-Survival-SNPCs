local material = Material("particle/smokesprites_0001")
local material_color = Color(255,255,255,255)

function EFFECT:Init(data)

	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40,-40,-18),Vector(40,40,90))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32,48)

	local pos = data:GetOrigin()
	local emitter = ParticleEmitter(pos)

	-- emitter:SetNearClip(40,45)
	
	render.SetMaterial(material)
	render.DrawSprite(pos,math.Rand(64,72),math.Rand(64,72),material_color)

	if (self.Timer or 0) < CurTime() then
		self.Timer = CurTime() + 0.15
		local particle = emitter:Add("particle/smokestack",pos)
		particle:SetVelocity(Vector(0,0,0))
		particle:SetDieTime(math.Rand(0.3,0.5))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(10)
		particle:SetStartSize(math.Rand(3,6))
		particle:SetEndSize(13)
		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(math.Rand(-3,3))
		particle:SetGravity(Vector(0,0,0))
		particle:SetCollide(false)
		particle:SetBounce(0.45)
		particle:SetAirResistance(12)
		particle:SetColor(255,255,255,255)
	end
		
	emitter:Finish()

end

function EFFECT:Think() return false end
function EFFECT:Render() end