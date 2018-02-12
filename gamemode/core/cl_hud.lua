local gap = 5
local length = gap + 5
local crosshair_acc = 25

function GFL:HUDPaint()
	local p = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
	local x,y = p.x, p.y
	surface.SetDrawColor( 255, 255,255, 155 )

	surface.DrawCircle(x,y,crosshair_acc,Color(255,255,255,255))
end

local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true
hidden["CHudDeathNotice"] = true

function GFL:HUDShouldDraw(name)
	if hidden[name] then
		return false
	end
	return true
end

