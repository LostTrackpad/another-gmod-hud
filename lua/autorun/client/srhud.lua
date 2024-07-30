local disabled = CreateClientConVar("srhud_disable", "", true, false, "", 0, 1)
local playername = ""
local ply = nil
local scale = ScrH() / 1080
local scrw = ScrW()
local scrh = ScrH()

local Weapon = nil
local WeaponClass = ""
local WepClip1 = -1 
local WepClip2 = -1 
local WepMag1 = -1 
local WepMag2 = -1
local WepReserve1 = -1
local WepReserve2 = -1

local vercolor = Color(183,183,183,183)
local white = Color(255,255,255,255)
local hpbarblue = Color(0,242,255)
local hpbarred = Color(255,60,60)
local hpdmg = Color(255,121,121,210)

local blur = Material("pp/blurscreen")
local gradient = Material("gui/gradient")
local armorhud = Material("srhud/armorbar.png")

local backhealth = 0
local backarmor = 0

local hide = {
    CHudBattery = disabled:GetBool(),
    CHudAmmo = true,
    CHudWepClip2 = true
}

-- Functions.
local function DrawBlurRect2(x, y, w, h, a, f) -- NEW: i is intensity. Adjust by multiples of 5.
	if render.GetDXLevel() < 90 then
		surface.SetDrawColor(80,80,80,50)
		surface.DrawRect(x,y,w,h)
	else
		local X = 0
		local Y = 0
		local intensity = 20
		if f != nil then intensity = f end
		
		surface.SetDrawColor(255, 255, 255, a)
		surface.SetMaterial(blur)
		
		for i = 1, 2 do
			--blur:SetFloat("$blur", i / 3 * 5)
			blur:SetFloat("$blur", i / 12 * intensity)
			blur:Recompute()
			
			render.UpdateScreenEffectTexture()
			render.SetScissorRect(x, y, x + w, y + h, true)
			
			surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
			
			render.SetScissorRect(0, 0, 0, 0, false)
		end
	end
end

surface.CreateFont("srhud_debug", {
    shadow = false,
    blursize = 0,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Alte DIN 1451 Mittelschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 24 * scale
}
)

surface.CreateFont("srhud_smalltext", {
    shadow = false,
    blursize = 0,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Alte DIN 1451 Mittelschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 27 * scale
}
)

surface.CreateFont("srhud_largetext", {
    shadow = false,
    blursize = 0,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Alte DIN 1451 Mittelschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 33 * scale
}
)

local function srhud_draw()
    if disabled:GetBool() then return end
    local ply = LocalPlayer()
    verstring = "Garry's Mod (" .. BRANCH .. " ".. VERSIONSTR .. ", " .. _VERSION .. ")"
    surface.SetFont("srhud_debug") -- stfu this is needed
    verw, verh = surface.GetTextSize(verstring)
    draw.DrawText(verstring, "srhud_debug", scrw - 8 * scale, scrh - verh - 8 * scale, vercolor, TEXT_ALIGN_RIGHT)

    if !ply:Alive() then return end
    
    local gradientoffset = -math.Clamp(math.Remap(ply:Health(), 0, ply:GetMaxHealth() * 0.6739130435, 0, 1), 0, 1)+1

    DrawBlurRect2(60 * scale,scrh - 80 * scale,230 * scale,10 * scale,255)
    surface.SetDrawColor(128,128,128,130)
    surface.DrawRect(60 * scale,scrh - 80 * scale,230 * scale,10 * scale)

    backhealth = math.Approach(backhealth, ply:Health(), RealFrameTime()*8)

    print(backhealth/ply:GetMaxHealth())

    surface.SetDrawColor(hpdmg)
    surface.DrawRect(60 * scale,scrh - 80 * scale,230*(backhealth/ply:GetMaxHealth()), 10 * scale)

    if ply:Health() > ply:GetMaxHealth() * 0.3 then
        surface.SetDrawColor(hpbarblue)
        surface.DrawRect(60 * scale,scrh - 80 * scale,230*(ply:Health()/ply:GetMaxHealth()), 10 * scale)
        surface.SetDrawColor(white)
        surface.SetMaterial(gradient)
        render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 70 * scale,true)
        surface.DrawTexturedRect(60 * scale - 155 * scale * gradientoffset,scrh - 80 * scale,155 * scale,10 * scale)
        render.SetScissorRect(0,0,0,0,false)
    else
        surface.SetDrawColor(hpbarred)
        surface.DrawRect(60 * scale,scrh - 80 * scale,230*(ply:Health()/ply:GetMaxHealth()) * scale, 10 * scale)
        surface.SetDrawColor(white)
        surface.SetMaterial(gradient)
        render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 70 * scale,true)
        surface.DrawTexturedRect(60 * scale - 155 * scale * gradientoffset,scrh - 80 * scale,155 * scale,10 * scale)
        render.SetScissorRect(0,0,0,0,false)
    end

    draw.DrawText(ply:Health(), "srhud_smalltext", 290 * scale, scrh - 108 * scale, white, TEXT_ALIGN_RIGHT)

    backarmor = math.Approach(backarmor, ply:Armor(), RealFrameTime() * 8)

    render.SetScissorRect(55 * scale, scrh - 84 * scale,56 * scale + 239 * (backarmor/ply:GetMaxArmor())* scale , scrh - 66 * scale,true)
    surface.SetDrawColor(hpdmg)
    surface.SetMaterial(armorhud)
    surface.DrawTexturedRect(55 * scale,scrh - 84 * scale,239 * scale,18 * scale)

    surface.SetDrawColor(white)
    surface.SetMaterial(armorhud)
    render.SetScissorRect(55 * scale, scrh - 84 * scale,56 * scale + 239 * scale * ply:Armor()/ply:GetMaxArmor(), scrh - 66 * scale,true)
    surface.DrawTexturedRect(55 * scale,scrh - 84 * scale,239 * scale,18 * scale)
    render.SetScissorRect(0,0,0,0,false)
end

hook.Add("HUDPaint", "srhud.draw", srhud_draw)