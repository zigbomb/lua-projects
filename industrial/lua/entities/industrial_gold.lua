AddCSLuaFile()

ENT.Base = "industrial_base"
ENT.PrintName = "Gold"
ENT.Spawnable = true
ENT.Model = "models/props_c17/oildrum001.mdl"
function ENT:IndustrialType()
	return "base"
	// valid types and their uses
	// base - does nothing
	// gen - generates power
	// bat - stores power
	// mach - uses power
end
function ENT:HelpText()
	return "Gold is an extremely rare metal used in high-tier crafting."
end
function ENT:CanReceivePower()
	return false
end
function ENT:CanTransmitPower()
	return false
end
