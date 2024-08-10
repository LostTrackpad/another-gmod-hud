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
local textshadow = Color(82,82,82,207)
local black = Color(0,0,0)
local gradientcol = Color(255,255,255,128)
local bggradientcol = Color(255,255,255,97)
local lightgray = Color(179,179,179,199)
local hpbarblue = Color(0,242,255)
local hpbarred = Color(255,60,60)
local hpdmg = Color(255,149,149)

local blur = Material("pp/blurscreen")
local gradient = Material("gui/gradient")
local armorhud = Material("srhud/armorbar.png", "alphatest")

local platform = ""

if system.IsWindows() then
    platform = "Windows"
elseif system.IsOSX() then
    platform = "macOS"
else
    platform = "Linux"
end

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
    font = "Bahnschrift",
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
    font = "Bahnschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 0,
    size = 29 * scale
}
)

surface.CreateFont("srhud_smallblur", {
    shadow = false,
    blursize = 4,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Bahnschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 0,
    size = 29 * scale
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
    font = "Bahnschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 40 * scale
}
)

surface.CreateFont("srhud_hugetext", {
    shadow = false,
    blursize = 0,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Bahnschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 63 * scale
}
)

surface.CreateFont("srhud_largeblur", {
    shadow = false,
    blursize = 5,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Bahnschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 40 * scale
}
)

surface.CreateFont("srhud_hugeblur", {
    shadow = false,
    blursize = 5,
    underline = false,
    rotary = false,
    strikeout = false,
    additive = false,
    antialias = true,
    extended = false,
    scanlines = 0,
    font = "Bahnschrift",
    italic = false,
    outline = false,
    symbol = false,
    weight = 250,
    size = 63 * scale
}
)

local function srhud_draw()
    if disabled:GetBool() then return end
    local ply = LocalPlayer()

    verstring = "Garry's Mod ("  .. platform .. " " .. BRANCH .. ", " .. string.Replace(VERSIONSTR, ".", "/") .. ", " .. _VERSION .. ")"
    surface.SetFont("srhud_debug") -- stfu this is needed
    verw, verh = surface.GetTextSize(verstring)

    draw.DrawText(verstring, "srhud_debug", scrw - 8 * scale, scrh - verh - 8 * scale, vercolor, TEXT_ALIGN_RIGHT)

    --if !ply:Alive() then return end
    
    local gradientoffset = -math.Clamp(math.Remap(ply:Health(), 0, ply:GetMaxHealth() * 0.6739130435, 0, 1), 0, 1)+1

    if ply:Armor() > 0 then
        DrawBlurRect2(55 * scale,scrh - 85 * scale,225 * scale,22 * scale,255)
        surface.SetDrawColor(64,64,64,224)
        surface.DrawRect(55 * scale,scrh - 85 * scale,225 * scale,22 * scale)
    else
        DrawBlurRect2(57 * scale,scrh - 83 * scale,221 * scale,18 * scale,255)
        surface.SetDrawColor(64,64,64,224)
        surface.DrawRect(57 * scale,scrh - 83 * scale,221 * scale,18 * scale)
    end

    backhealth = math.Approach(backhealth, ply:Health(), RealFrameTime()*24)

    surface.SetDrawColor(hpdmg)
    surface.DrawRect(60 * scale,scrh - 80 * scale,215*(backhealth/ply:GetMaxHealth()), 12 * scale)

    if ply:Health() > ply:GetMaxHealth() * 0.3 then
        surface.SetDrawColor(hpbarblue)
        surface.DrawRect(60 * scale,scrh - 80 * scale,215*(ply:Health()/ply:GetMaxHealth()), 12 * scale)
        surface.SetDrawColor(gradientcol)
        surface.SetMaterial(gradient)
        render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 68 * scale,true)
        surface.DrawTexturedRect(60 * scale - 125 * scale * gradientoffset,scrh - 80 * scale,155 * scale,12 * scale)
        render.SetScissorRect(0,0,0,0,false)
    else
        surface.SetDrawColor(hpbarred)
        surface.DrawRect(60 * scale,scrh - 80 * scale,215*(ply:Health()/ply:GetMaxHealth()) * scale, 12 * scale)
        surface.SetDrawColor(gradientcol)
        surface.SetMaterial(gradient)
        render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 68 * scale,true)
        surface.DrawTexturedRect(60 * scale - 125 * scale * gradientoffset,scrh - 80 * scale,155 * scale,12 * scale)
        render.SetScissorRect(0,0,0,0,false)
    end

    draw.DrawText(ply:Health(), "srhud_smallblur", 277 * scale, scrh - 113 * scale, black, TEXT_ALIGN_RIGHT)
    draw.DrawText(ply:Health(), "srhud_smallblur", 277 * scale, scrh - 113 * scale, textshadow, TEXT_ALIGN_RIGHT)
    draw.DrawText(ply:Health(), "srhud_smalltext", 279 * scale, scrh - 111 * scale, textshadow, TEXT_ALIGN_RIGHT)
    draw.DrawText(ply:Health(), "srhud_smalltext", 277 * scale, scrh - 113 * scale, white, TEXT_ALIGN_RIGHT)

    backarmor = math.Approach(backarmor, ply:Armor(), RealFrameTime() * 24)

    if ply:Armor() > 0 then
        render.SetScissorRect(55 * scale, scrh - 256 * scale,57 * scale + 223 * (backarmor/ply:GetMaxHealth())* scale , scrh - 0 * scale,true)
        surface.SetDrawColor(hpdmg)
        surface.SetMaterial(armorhud)
        surface.DrawTexturedRect(55 * scale,scrh - 85 * scale,225 * scale,22 * scale)

        surface.SetDrawColor(white)
        surface.SetMaterial(armorhud)
        render.SetScissorRect(55 * scale, scrh - 256 * scale,57 * scale + 223 * scale * ply:Armor()/ply:GetMaxHealth(), scrh - 0 * scale,true)
        surface.DrawTexturedRect(55 * scale,scrh - 85 * scale,225 * scale,22 * scale)
        surface.DrawTexturedRect(540 * scale,scrh - 540 * scale,225 * scale * 2,22 * scale * 2)
        render.SetScissorRect(0,0,0,0,false)

        draw.DrawText("[" .. ply:Armor() .. "]", "srhud_smallblur", 58 * scale, scrh - 113 * scale, black, TEXT_ALIGN_LEFT)
        draw.DrawText("[" .. ply:Armor() .. "]", "srhud_smallblur", 58 * scale, scrh - 113 * scale, black, TEXT_ALIGN_LEFT)
        draw.DrawText("[" .. ply:Armor() .. "]", "srhud_smalltext", 60 * scale, scrh - 112 * scale, textshadow, TEXT_ALIGN_LEFT)
        draw.DrawText("[" .. ply:Armor() .. "]", "srhud_smalltext", 58 * scale, scrh - 113 * scale, white, TEXT_ALIGN_LEFT)
    end

    Weapon = ply:GetActiveWeapon()
    if !IsValid(Weapon) then return end

    local ammo1gradientoffset = -math.Clamp(math.Remap(Weapon:Clip1(), 0, Weapon:GetMaxClip1(), 0, 1), 0, 1)+1
    local ammo2gradientoffset = -math.Clamp(math.Remap(Weapon:Clip2(), 0, Weapon:GetMaxClip2(), 0, 1), 0, 1)+1

    if Weapon:GetPrimaryAmmoType() != -1 then
        draw.DrawText(Weapon:Clip1(), "srhud_hugeblur", scrw - 225 * scale, scrh - 126 * scale, black, TEXT_ALIGN_RIGHT)
        draw.DrawText(" / "..math.Clamp(ply:GetAmmoCount(Weapon:GetPrimaryAmmoType()), 0, 2147483647), "srhud_largeblur",scrw - 215 * scale, scrh - 120 * scale, black, TEXT_ALIGN_LEFT)
        draw.DrawText(Weapon:Clip1(), "srhud_hugetext", scrw - 225 * scale, scrh - 126 * scale, white, TEXT_ALIGN_RIGHT)
        draw.DrawText(" / "..math.Clamp(ply:GetAmmoCount(Weapon:GetPrimaryAmmoType()), 0, 2147483647), "srhud_largetext",scrw - 215 * scale, scrh - 120 * scale, lightgray, TEXT_ALIGN_LEFT)

        surface.SetDrawColor(bggradientcol)
        surface.SetMaterial(gradient)
        --render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 68 * scale,true)
        surface.DrawTexturedRect(scrw - 208 * scale,scrh - 80 * scale,100 * scale,6 * scale)

        DrawBlurRect2(scrw - 209 * scale,scrh - 81 * scale,102 * scale,8 * scale,255,25)
        surface.SetDrawColor(97,97,97,105)
        surface.DrawRect(scrw - 209 * scale,scrh - 81 * scale,102 * scale,8 * scale)

        if Weapon:Clip1() > (Weapon:GetMaxClip1() / 3) then
            surface.SetDrawColor(hpbarblue)
        else
            surface.SetDrawColor(hpbarred)
        end
        surface.DrawRect(scrw - 208 * scale, scrh - 80 * scale, 100 * (ply:GetActiveWeapon():Clip1() / ply:GetActiveWeapon():GetMaxClip1    ()), 6 * scale)

        surface.SetDrawColor(gradientcol)
        surface.SetMaterial(gradient)
        render.SetScissorRect(scrw - 208 * scale, scrh - 80 * scale,scrw - 108 * scale, scrh - 50 * scale,true)
        surface.DrawTexturedRect(scrw - 208 * scale - 100 * scale * ammo1gradientoffset,scrh - 80 * scale,100 * scale,6 * scale)
        render.SetScissorRect(0,0,scrw,scrh,false)
    end

    if Weapon:GetSecondaryAmmoType() != -1 then
        if Weapon:GetMaxClip2() != -1 then
            draw.DrawText(Weapon:Clip2(), "srhud_hugeblur", scrw - 420 * scale, scrh - 126 * scale, black, TEXT_ALIGN_RIGHT)
            draw.DrawText(" / "..math.Clamp(ply:GetAmmoCount(Weapon:GetSecondaryAmmoType()), 0, 2147483647), "srhud_largeblur",scrw - 410 *     scale, scrh - 120 * scale, black, TEXT_ALIGN_LEFT)
            draw.DrawText(Weapon:Clip2(), "srhud_hugetext", scrw - 420 * scale, scrh - 126 * scale, white, TEXT_ALIGN_RIGHT)
            draw.DrawText(" / "..math.Clamp(ply:GetAmmoCount(Weapon:GetSecondaryAmmoType()), 0, 2147483647), "srhud_largetext",scrw - 410 *     scale, scrh - 120 * scale, lightgray, TEXT_ALIGN_LEFT)

            surface.SetDrawColor(bggradientcol)
            surface.SetMaterial(gradient)
            --render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 68 * scale,true)
            surface.DrawTexturedRect(scrw - 403 * scale,scrh - 80 * scale,69 * scale,6 * scale)

            --DrawBlurRect2(scrw - 369 * scale,scrh - 81 * scale,102 * scale,8 * scale,255,25)
            surface.SetDrawColor(97,97,97,105)
            surface.DrawRect(scrw - 404 * scale,scrh - 81 * scale,69 * scale,8 * scale)

            if Weapon:Clip2() > (Weapon:GetMaxClip2() / 3) then
                surface.SetDrawColor(hpbarblue)
            else
                surface.SetDrawColor(hpbarred)
            end
            surface.DrawRect(scrw - 403 * scale, scrh - 80 * scale, 69 * (ply:GetActiveWeapon():Clip2() / ply:GetActiveWeapon():GetMaxClip2 ()) * scale, 6 * scale)

            surface.SetDrawColor(gradientcol)
            surface.SetMaterial(gradient)
            render.SetScissorRect(scrw - 403 * scale, scrh - 80 * scale,scrw - 268 * scale, scrh - 50 * scale,true)
            surface.DrawTexturedRect(scrw - 403 * scale - 60 * scale * ammo2gradientoffset,scrh - 80 * scale,69 * scale,6 * scale)
            render.SetScissorRect(0,0,scrw,scrh,false)
        else
            draw.DrawText(math.Clamp(Weapon:Clip2(), 0, 2147483647) + math.Clamp(ply:GetAmmoCount(Weapon:GetSecondaryAmmoType()), 0, 2147483647), "srhud_largeblur",scrw - 406 * scale, scrh - 120 * scale, black, TEXT_ALIGN_LEFT)
            draw.DrawText(math.Clamp(Weapon:Clip2(), 0, 2147483647) + math.Clamp(ply:GetAmmoCount(Weapon:GetSecondaryAmmoType()), 0, 2147483647), "srhud_largetext",scrw - 406 * scale, scrh - 120 * scale, lightgray, TEXT_ALIGN_LEFT)

            surface.SetDrawColor(bggradientcol)
            surface.SetMaterial(gradient)
            --render.SetScissorRect(60 * scale, scrh - 80 * scale,60 * scale + 155 * scale, scrh - 68 * scale,true)
            surface.DrawTexturedRect(scrw - 403 * scale,scrh - 80 * scale,69 * scale,6 * scale)

            --DrawBlurRect2(scrw - 369 * scale,scrh - 81 * scale,102 * scale,8 * scale,255,25)
            surface.SetDrawColor(97,97,97,105)
            surface.DrawRect(scrw - 404 * scale,scrh - 81 * scale,69 * scale,8 * scale)

            if Weapon:Clip2() > (Weapon:GetMaxClip2() / 3) then
                surface.SetDrawColor(hpbarblue)
            else
                surface.SetDrawColor(hpbarred)
            end
            surface.DrawRect(scrw - 403 * scale, scrh - 80 * scale, 69 * (ply:GetActiveWeapon():Clip2() / ply:GetActiveWeapon():GetMaxClip2 ()) * scale, 6 * scale)

            surface.SetDrawColor(gradientcol)
            surface.SetMaterial(gradient)
            render.SetScissorRect(scrw - 403 * scale, scrh - 80 * scale,scrw - 268 * scale, scrh - 50 * scale,true)
            surface.DrawTexturedRect(scrw - 403 * scale - 60 * scale * ammo2gradientoffset,scrh - 80 * scale,69 * scale,6 * scale)
            render.SetScissorRect(0,0,scrw,scrh,false)
        end
    end
end

hook.Add("HUDPaint", "srhud.draw", srhud_draw)