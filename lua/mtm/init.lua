local addonName = 'Map Thumbnails Maker'

-- ConVars
local thumbSize = CreateClientConVar( 'mtm_size', '512', true, false, 'Map thumbnail size (in pixels)', 64, 2048 )
local thumbFormat = CreateClientConVar( 'mtm_format', 'png', true, false, 'Map thumbnail image format (png, jp, jpeg)' )

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

    local filePath = 'map_thumbs/' .. game.GetMap() .. '.' .. ( format or 'png' )
    file.Write( filePath, render.Capture( {
        ['format'] = format or 'png',
        ['x'] = x,
        ['y'] = y,
        ['w'] = w,
        ['h'] = h
    } ) )

    notification.AddLegacy( 'Result saved in \'' .. filePath .. '\'.', NOTIFY_GENERIC, 3 )
end

cvars.AddChangeCallback( 'mtm_size', function()
    if not IsValid( Panel ) then return end
    local frame = Panel.Frame
    if IsValid( frame ) then
        frame:InvalidateLayout()
    end
end, addonName )

cvars.AddChangeCallback( 'mtm_format', function()
    if not IsValid( Panel ) then return end
    local options = Panel.Options
    if IsValid( options ) then
        options:InvalidateLayout()
    end
end, addonName )

function Stop()
    if IsValid( Panel ) then
        notification.AddLegacy( 'Creating a thumbnail has been cancelled.', NOTIFY_UNDO, 3 )
        Panel:Remove()
    end
end

function Start()
    Stop()

    Panel = vgui.Create( 'mtm.main' )
end

concommand.Add( 'mtm_start', Start )
concommand.Add( 'mtm_stop', Stop )