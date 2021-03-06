AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Salesman"
ENT.Spawnable = false
ENT.IsSalesman = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ItemID")
end

if SERVER then
	function ENT:Initialize()
		self:DrawShadow(true)
		self:SetSolid(SOLID_BBOX)
		self:PhysicsInit(SOLID_BBOX)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
	end

	function ENT:Think()
		if type(self:GetItemID()) == "string" then
			self:SetModel(g_SalesmanTable[self:GetItemID()]["model"])
			self:SetSequence(self:LookupSequence("idle_all_01"))
		end
	end

	function ENT:Use(activator, caller)
		if IsValid(caller) and IsValid(self) and type(self:GetItemID()) == "string" then
			net.Start("SimpleInventory_PlayerBuyMenu")
				net.WriteEntity(self)
			net.Send(caller)
		end
	end

	net.Receive("SimpleInventory_PlayerBuyItem", function(len, ply)
		local man = net.ReadEntity()
		local id = g_ItemTranslateFromID[net.ReadString()]
		if man:GetClass() != "inv_salesman" then return end
		if man:GetPos():DistToSqr(ply:GetPos()) > 262144 then return end
		if g_ItemTable[id] == nil then return end
		if not ply:canAfford(g_SalesmanTable[man:GetItemID()]["soldItems"][id]) then
			ply:Notify("You cannot afford this item!")
			return
		end
		if not ply:CanGiveItem(id, 1) then
			ply:Notify("Your inventory is full!")
			return
		end
		ply:addMoney(-g_SalesmanTable[man:GetItemID()]["soldItems"][id])
		ply:GiveItem(id, 1)
		ply:Notify("You have bought " .. g_ItemTable[id]["name"] .. ".")
	end)
elseif CLIENT then
	function ENT:Initialize()
		self.AutomaticFrameAdvance = true
	end

	function ENT:Think()
		self:FrameAdvance(FrameTime())
		self:NextThink(CurTime())
	end

	function ENT:Draw()
		self:DrawModel()

		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(), 90)
		Ang:RotateAroundAxis(Ang:Right(), -90)

		local Ang2 = self:GetAngles()
		Ang2:RotateAroundAxis(Ang2:Forward(), 90)
		Ang2:RotateAroundAxis(Ang2:Right(), -90)
		Ang2:RotateAroundAxis(Ang2:Right(), 180)

		cam.Start3D2D(self:GetPos() + (self:GetUp() * 85), Ang2, 0.35)
			draw.SimpleTextOutlined(g_SalesmanTable[self:GetItemID()]["name"], "Trebuchet24", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		cam.End3D2D()
		cam.Start3D2D(self:GetPos() + (self:GetUp() * 85), Ang, 0.35)
			draw.SimpleTextOutlined(g_SalesmanTable[self:GetItemID()]["name"], "Trebuchet24", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		cam.End3D2D()
	end

	net.Receive("SimpleInventory_PlayerBuyMenu", function(len)
		local man = net.ReadEntity()
		if not IsValid(man) then return end
		local salesMenu = vgui.Create("DFrame")
		salesMenu:SetSize(300, 300)
		salesMenu:Center()
		salesMenu:SetDraggable(true)
		salesMenu:ShowCloseButton(true)
		salesMenu:MakePopup()
		salesMenu:SetTitle(g_SalesmanTable[man:GetItemID()]["name"])
		function salesMenu:Paint(w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
		end

		local invScroll = vgui.Create("DScrollPanel", salesMenu)
		invScroll:SetSize(69, 69)
		invScroll:Dock(FILL)

		local invPanels = {}
		local invModels = {}
		local invButtons = {}

		for k, v in pairs(g_SalesmanTable[man:GetItemID()]["soldItems"]) do
			invPanels[#invPanels + 1] = vgui.Create("DPanel", invScroll)
			invPanels[#invPanels]:SetSize(0, 40)
			invPanels[#invPanels]:Dock(TOP)

			invButtons[#invButtons + 1] = vgui.Create("DButton", invPanels[#invPanels])
			invButtons[#invButtons]:SetSize(240, 40)
			invButtons[#invButtons]:Dock(FILL)
			invButtons[#invButtons]:SetText(g_ItemTable[k]["name"] .. " ($" .. string.Comma(v) .. ")")
			if g_ItemTable[k]["desc"] != nil then
				invButtons[#invButtons]:SetTooltip(g_ItemTable[k]["desc"])
			end
			invButtons[#invButtons].DoClick = function()
				net.Start("SimpleInventory_PlayerBuyItem")
					net.WriteEntity(man)
					net.WriteString(k)
				net.SendToServer()
			end
			invModels[#invModels + 1] = vgui.Create("ModelImage", invButtons[#invButtons])
			invModels[#invModels]:SetSize(40, 40)
			invModels[#invModels]:Dock(LEFT)
			invModels[#invModels]:DockMargin(5, 0, 0, 0)
			invModels[#invModels]:SetModel(g_ItemTable[k]["model"])
		end
	end)
end
