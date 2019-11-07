function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local up = Vector(0,0,20)
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24,32)
	for i = 1,2 do
		local vecRan = VectorRand():GetNormalized()
		vecRan = vecRan *math.Rand(8,16)
		vecRan.z = math.Rand(-22,-2)
	
		local particle = emitter:Add("effects/blood_puff",pos +up +vecRan)
		particle:SetColor(50,0,0)
		particle:SetGravity(Vector(0,0,100))
		particle:SetAirResistance(160)
		particle:SetCollide(true)
		particle:SetVelocity(Vector(math.Rand(-60,60),math.Rand(-60,60),math.Rand(12,20)))
        particle:SetDieTime(math.Rand(0.27,0.35))
		particle:SetStartAlpha(255) 
		particle:SetEndAlpha(0)
        particle:SetStartSize(4)
        particle:SetEndSize(9)
	end
	emitter:Finish()
end

function EFFECT:Think() return false end

function EFFECT:Render() end