ENT.Base 			= "npc_vj_creature_base"
ENT.Type 			= "ai"
ENT.PrintName 		= ""
ENT.Author 			= "Cpt. Hazama"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Purpose 		= "Spawn it and fight with it!"
ENT.Instructions 	= "Click on the spawnicon to spawn it."
ENT.Category		= "Combine"

if (CLIENT) then
	local LaserMaterial = Material("sprites/rollermine_shock")
	local SpriteMaterial = Material("particle/particle_glow_02")
	function ENT:CustomOnDraw()
		local attach = self:GetAttachment(self:LookupAttachment("light"))
		local blue = Color(0,161,255,255)
		local red = Color(235,0,0,255)
		local useColor = blue
		local ud,lr = 0, 0
		local endPos = attach.Pos +attach.Ang:Forward() *10000 +attach.Ang:Up() *ud +attach.Ang:Right() *lr
		local tr = util.TraceLine({
			start = attach.Pos,
			endpos = endPos,
			filter = self,
		})
		if self:GetSequenceName(self:GetSequence()) == "idlealert" or self:GetSequenceName(self:GetSequence()) == "fire" then
			useColor = red
		end
		render.SetMaterial(LaserMaterial)
		render.DrawBeam(attach.Pos,tr.HitPos, 5, 0, 5, useColor)
		render.SetMaterial(SpriteMaterial)
		render.DrawSprite(attach.Pos,3,3,useColor)
		if tr.Hit == true then
			render.SetMaterial(SpriteMaterial)
			render.DrawSprite(tr.HitPos,5,5,useColor)
		end
	end
end