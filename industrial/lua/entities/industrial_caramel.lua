AddCSLuaFile()

ENT.Base = "industrial_base"
ENT.PrintName = "Caramel"
ENT.Spawnable = true
ENT.Model = "models/Items/item_item_crate_chunk02.mdl"
function ENT:IndustrialType()
	return "base"
	// valid types and their uses
	// base - does nothing
	// gen - generates power
	// bat - stores power
	// mach - uses power
end
function ENT:HelpText()
	return "It's caramel. I was running out of ideas."
end
function ENT:CanReceivePower()
	return false
end
function ENT:CanTransmitPower()
	return false
end
function ENT:PermaMaterial()
	return "models/props_pipes/GutterMetal01a"
end
