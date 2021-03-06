local fuck = GESTURE_SLOT_ATTACK_AND_RELOAD

SWEP.PrintName = "Boomstick"
SWEP.Author = "Sir Francis Billard"
SWEP.Instructions = "Left click to blow down doors or people.\nRight click to launch a rocket."
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.UseHands = true
SWEP.ViewModelFOV = 60
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

SWEP.SwayScale = 1
SWEP.DrawAmmo = true
SWEP.Slot = 3

SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "SMG1_Grenade"
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 8
SWEP.Secondary.Automatic = false

local IsDoor = {
	["prop_door_rotating"] = true,
	["func_movelinear"] = true,
	["func_door"] = true,
	["func_door_rotating"] = true
}

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Reloading")
end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
	local bullet = {}
	bullet.Num 	= num_bullets
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(aimcone, aimcone, 0)
	bullet.Tracer = 1
	bullet.Force = 200
	bullet.Damage = damage
	bullet.AmmoType = "Pistol"
	self.Owner:FireBullets(bullet)
	self:ShootEffects()
end

function SWEP:Deploy()
	if SERVER then
		self:SetReloading(false)
	end
	self:EmitSound(Sound("weapons/shotgun/shotgun_cock.wav"))
	self:SetHoldType("shotgun")
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Owner:AnimRestartGesture(fuck, ACT_SHOTGUN_RELOAD_FINISH, true)
	return true
end

function SWEP:Holster()
	self:SetReloading(false)
	return true
end

function SWEP:Reload()
	if self:GetReloading() then return end
	if (self.Weapon:Clip1() < self.Primary.ClipSize and self.Weapon:Ammo1() > 0) or (self.Weapon:Clip2() < self.Secondary.ClipSize and self.Weapon:Ammo2() > 0) then
		if SERVER then
			self:SetReloading(true)
		end
		self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
		timer.Simple(self:SequenceDuration() + 1, function()
			if (not IsValid(self)) or (not IsValid(self.Owner)) then return end
			if IsValid(self.Owner:GetActiveWeapon()) then
				if (self.Owner:GetActiveWeapon():GetClass() != self.ClassName) then
					return
				end
			end
			self:DefaultReload(ACT_VM_DRAW)
			self:SetNextPrimaryFire(CurTime() + 1)
			self:SetNextSecondaryFire(CurTime() + 1)
			self:SetReloading(false)
			if SERVER then
				self:EmitSound(Sound("weapons/shotgun/shotgun_cock.wav"))
			end
		end)
		self.Owner:AnimRestartGesture(fuck, ACT_SHOTGUN_RELOAD_FINISH, true)
		
	end
end

function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack()) or self:GetReloading() then return end
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(true)
	end
	local trent = util.TraceLine(util.GetPlayerTrace(self.Owner)).Entity
	local trpos = util.TraceLine(util.GetPlayerTrace(self.Owner)).HitPos
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(false)
	end
	self:ShootBullet(20, 24, 0.08)
	self:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:EmitSound(Sound("weapons/shotgun/shotgun_fire"..math.random(6, 7)..".wav"))
	self.Owner:ViewPunch(Angle(-2, 0, 0))
	if trent:GetPos():Distance(self.Owner:GetPos()) < 256 then
		if IsDoor[trent:GetClass()] and SERVER then
			trent:Fire("Unlock", "", 0)
			trent:Fire("Open", "", 0)
			local sparks = EffectData()
			sparks:SetOrigin(trpos)
			util.Effect("cball_explode", sparks)
		end
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.4)
end

function SWEP:SecondaryAttack()
	if (not self:CanSecondaryAttack()) or self:GetReloading() then return end
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(true)
	end
	local trent = util.TraceLine(util.GetPlayerTrace(self.Owner)).Entity
	local trpos = util.TraceLine(util.GetPlayerTrace(self.Owner)).HitPos
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(false)
	end
	self:ShootEffects()
	self:TakeSecondaryAmmo(1)
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:EmitSound(Sound("weapons/grenade_launcher1.wav"))
	self.Owner:ViewPunch(Angle(-8, 0, 0))
	timer.Simple(self.Owner:GetPos():Distance(trpos) / 2048, function()
		if (not IsValid(self)) then return end
		local boom = EffectData()
		boom:SetOrigin(trpos)
		util.Effect("HelicopterMegaBomb", boom)
		util.BlastDamage(self, self.Owner, trpos, 256, 150)
		local snd = "weapons/explode"..math.random(3, 5)..".wav"
		sound.Play(Sound(snd), trpos)
		self:EmitSound(Sound(snd))
	end)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end
