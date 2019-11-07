local material = Material("effects/fire_cloud1")
local material_color = Color(0,255,0,255)

function EFFECT:Init(data)
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40,-40,-18),Vector(40,40,90))

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32,48)

	local pos = data:GetOrigin()
	local emitter = ParticleEmitter(pos)

	emitter:SetNearClip(40,45)
	
	render.SetMaterial(material)
	render.DrawSprite(pos,math.Rand(150,200),math.Rand(150,200),material_color)
	for i = 1,3 do
		if (self.Timer or 0) < CurTime() then
			self.Timer = CurTime() + 0.5
			local particle = emitter:Add("particle/smokestack",pos)
			particle:SetVelocity(Vector(math.Rand(-150,200),math.Rand(-150,200),math.Rand(-150,200)))
			particle:SetDieTime(math.Rand(0.3,0.7))
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(90,180))
			particle:SetEndSize(300)
			particle:SetRoll(math.Rand(0,360))
			particle:SetRollDelta(math.Rand(-3,3))
			particle:SetGravity(Vector(0,0,125))
			particle:SetCollide(false)
			particle:SetBounce(0.45)
			particle:SetAirResistance(12)
			particle:SetColor(0,255,0,255) // Green
		end
	end
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end