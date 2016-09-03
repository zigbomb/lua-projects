AddCSLuaFile()

hook.Add("HUDPaint", "IndustrialMod_DrawHints", function()
	local tr = LocalPlayer():GetEyeTrace()
	local clrWhite = Color(0, 0, 0, 255)
	local clrBlack = Color(255, 255, 255, 255)
	local halfScrH = (ScrH() / 2)
	local halfScrW = ScrW() / 2
	local trent = tr.Entity
	if IsValid(trent) and (trent.GetStoredPower != nil) and (trent:IndustrialType() != "base") and (trent:GetPos():Distance(LocalPlayer():EyePos()) < 256) then
		draw.SimpleTextOutlined("Power: "..trent:GetStoredPower().."/"..trent:GetMaxStoredPower(), "Default", halfScrW, halfScrH + 25, clrWhite, 1, 1, 1, clrBlack)
	end
	if IsValid(trent) and (trent.IndustrialType != nil) then
		draw.SimpleTextOutlined(scripted_ents.Get(trent:GetClass()).PrintName, "Default", halfScrW, halfScrH - 25, clrWhite, 1, 1, 1, clrBlack)
	end
end)
