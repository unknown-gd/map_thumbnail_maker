if CLIENT then
    if !file.IsDir( 'map_thumbs', 'DATA' ) then
        file.CreateDir( 'map_thumbs' )
    end

    include( 'mtm/vgui/options.lua' )
    include( 'mtm/vgui/frame.lua' )
    include( 'mtm/vgui/main.lua' )
    include( 'mtm/init.lua' )
    return
end

AddCSLuaFile( 'mtm/vgui/options.lua' )
AddCSLuaFile( 'mtm/vgui/frame.lua' )
AddCSLuaFile( 'mtm/vgui/main.lua' )
AddCSLuaFile( 'mtm/init.lua' )