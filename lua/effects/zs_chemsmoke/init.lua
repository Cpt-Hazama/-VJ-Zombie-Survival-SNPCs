local material = Material("effects/fire_cloud1")
local material_color = Color(255, 95, 95, 255)

function EFFECT:Init(data)

	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40,-40,-18),Vector(40,40,90))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32,48)

	local pos = data:GetOrigin()
	local emitter = ParticleEmitter(pos)

	emitter:SetNearClip(40,45)
	
	render.SetMaterial(material)
	render.DrawSprite(pos,math.Rand(64,72),math.Rand(64,72),material_color)

	if (self.Timer or 0) < CurTime() then
		self.Timer = CurTime() + 0.15
		local particle = emitter:Add("particle/smokestack",pos)
		particle:SetVelocity(Vector(0,0,0))
		particle:SetDieTime(math.Rand(0.3,0.7))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(15,20))
		particle:SetEndSize(50)
		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(math.Rand(-3,3))
		particle:SetGravity(Vector(0,0,125))
		particle:SetCollide(false)
		particle:SetBounce(0.45)
		particle:SetAirResistance(12)
		particle:SetColor(0,255,0,255) // Green
	end
		
	emitter:Finish()

end

function EFFECT:Think() return false end
function EFFECT:Render() end