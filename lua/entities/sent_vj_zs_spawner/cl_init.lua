include('shared.lua')

function ENT:Draw()
	return false
end

net.Receive("vj_zs_sound",function(len,pl)
	local ply = net.ReadEntity()
	local snd = net.ReadString()
	
	ply:EmitSound(snd)
end)