local addonName = 'Map Thumbs Maker'

-- ConVars
local thumbSize = CreateClientConVar( 'mtm_thumb_size', '512', true, false, 'Map thumb size (in pixels)', 64, 2048 )
local thumbFormat = CreateClientConVar( 'mtm_thumb_format', 'png', true, false, 'Map thumb image format (png, jp, jpeg)' )

module( 'mtm', package.seeall )

-- Screen Size
ScreenWidth, ScreenHeight = ScrW(), ScrH()
hook.Add( 'OnScreenSizeChanged', addonName, function()
    ScreenWidth, ScreenHeight = ScrW(), ScrH()
end )

AllowedFormats = {
    ['png'] = true,
    ['jpg'] = true,
    ['jpeg'] = true
}

function GetImageFormat()
    local str = thumbFormat:GetString()
    if not str then return 'png' end
    local format = string.Trim( str )
    if not AllowedFormats[ format ] then return 'png' end
    return format
end

function GetMaxImageSize()
    return math.min( thumbSize:GetMax(), math.min( ScreenWidth, ScreenHeight ) )
end

function GetImageSize()
    return math.min( thumbSize:GetInt(), math.min( ScreenWidth, ScreenHeight ) )
end

View = {
    ['drawviewmodel'] = false,
    ['dopostprocess'] = false,
    ['drawmonitors'] = true,
    ['drawhud'] = false
}

function Make( x, y, w, h, format )
    render.RenderView( View )

    file.Write( 'map_thumbs/' .. game.GetMap() .. '.' .. ( format or 'png' ), render.Capture( {
        ['format'] = format or 'png',
        ['x'] = x,
        ['y'] = y,
        ['w'] = w,
        ['h'] = h
    } ) )
end

cvars.AddChangeCallback( 'mtm_thumb_size', function()
    if not IsValid( Panel ) then return end
    local frame = Panel.Frame
    if IsValid( frame ) then
        frame:InvalidateLayout()
    end
end, addonName )

cvars.AddChangeCallback( 'mtm_thumb_format', function()
    if not IsValid( Panel ) then return end
    local options = Panel.Options
    if IsValid( options ) then
        options:InvalidateLayout()
    end
end, addonName )

concommand.Add( 'mtm_start', function()
    if IsValid( Panel ) then
        Panel:Remove()
    end

    Panel = vgui.Create( 'mtm.main' )
end )