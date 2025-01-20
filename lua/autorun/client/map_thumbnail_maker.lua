local file, vgui, math = file, vgui, math
local vgui_Create = vgui.Create

if not file.IsDir( "maps", "DATA" ) then
    if file.Exists( "maps", "DATA" ) then
        file.Delete( "maps" )
    end

    file.CreateDir( "maps" )
end

if not file.IsDir( "maps/thumb", "DATA" ) then
    if file.Exists( "maps/thumb", "DATA" ) then
        file.Delete( "maps/thumb" )
    end

    file.CreateDir( "maps/thumb" )
end

---@class mtm
---@field View ViewData
local mtm = {}
_G.mtm = mtm

local screen_width, screen_height = ScrW(), ScrH()
local vmin = math.min( screen_width, screen_height ) * 0.01

hook.Add( "OnScreenSizeChanged", "mtm", function( _, __, width, height )
    screen_width, screen_height = width or ScrW(), height or ScrH()
    vmin = math.min( screen_width, screen_height ) * 0.01
    ---@diagnostic disable-next-line: undefined-field, redundant-parameter
end, _G.PRE_HOOK )

local size_cvar = CreateClientConVar( "map_thumb_size", "512", true, false, "Map thumbnail size (in pixels)", 64, 2048 )

function mtm.GetMaxImageSize()
    return math.min( size_cvar:GetMax(), math.min( screen_width, screen_height ) )
end

function mtm.GetImageSize()
    return math.min( size_cvar:GetInt(), math.min( screen_width, screen_height ) )
end

local view = {
    drawviewmodel = false,
    dopostprocess = false,
    drawmonitors = true,
    drawhud = false
}

---@cast view ViewData

mtm.View = view

function mtm.Capture( x, y, w, h )
    render.RenderView( view )

    local filePath = "maps/thumb/" .. game.GetMap() .. ".jpg"
    file.Write( filePath, render.Capture( {
        x = x, y = y, w = w, h = h, format = "jpg"
    } ) )

    notification.AddLegacy( "Result saved in \"" .. filePath .. "\".", NOTIFY_GENERIC, 3 )
end

do

    local capture_panel

    cvars.AddChangeCallback( size_cvar:GetName(), function()
        if not ( capture_panel and capture_panel:IsValid() ) then return end

        local frame = capture_panel.Frame
        if frame and frame:IsValid() then
            ---@cast frame Panel
            frame:InvalidateLayout()
        end
    end, "Map Thumbnail Maker" )

    function mtm.Stop( silent )
        if not ( capture_panel and capture_panel:IsValid() ) then return end

        if not silent then
            notification.AddLegacy( "Creating a thumbnail has been cancelled.", NOTIFY_UNDO, 3 )
            surface.PlaySound( "garrysmod/balloon_pop_cute.wav" )
        end

        capture_panel:Remove()
    end

    function mtm.Start()
        if capture_panel and capture_panel:IsValid() then
            capture_panel:Remove()
        end

        capture_panel = vgui_Create( "Map Thumbnail Maker - Capture" )
    end

end

concommand.Add( "map_thumb_create", mtm.Start )
concommand.Add( "map_thumb_cancel", mtm.Stop )

do

    local surface = surface
    local render = render

    ---@class MapThumbnailMakerFrame : Panel
    local PANEL = {}

    local function think( self )
        if self:IsHovered() and input.IsButtonDown( 64 ) then
            local parent = self:GetParent()
            if parent and parent:IsValid() then
                parent:Capture()
                return
            end
        end

        if self.Pressed then
            if input.IsMouseDown( 107 ) then
                self:MousePos()
            else
                self.Pressed = false
            end
        end
    end

    function PANEL:Init()
        self:SetPaintedManually( true )
        self:NoClipping( true )
        self:SetAlpha( 0 )
        self.Thickness = 0

        timer.Simple( 1, function()
            if self:IsValid() then
                self.Think = think
            end
        end )

        hook.Add( "HUDPaint", self, function()
            surface.SetDrawColor( 255, 255, 255 )

            render.ClearStencil()
            render.SetStencilEnable( true )

            render.SetStencilWriteMask( 1 )
            render.SetStencilTestMask( 1 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilFailOperation( 3 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilPassOperation( 2 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilZFailOperation( 2 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilCompareFunction( 1 )
            render.SetStencilReferenceValue( 1 )

            surface.DrawRect( self:GetBounds() )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilFailOperation( 2 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilPassOperation( 3 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilZFailOperation( 2 )

            ---@diagnostic disable-next-line: param-type-mismatch
            render.SetStencilCompareFunction( 3 )
            render.SetStencilReferenceValue( 0 )

            surface.SetDrawColor( 0, 0, 0, 200 )
            surface.DrawRect( 0, 0, screen_width, screen_height )

            render.SetStencilEnable( false )
            render.ClearStencil()

            self:PaintManual()
        end )
    end

    function PANEL:Paint( w, h )
        surface.SetDrawColor( 255, 255, 255, 200 )
        surface.DrawRect( 0, 0, w - self.Thickness, self.Thickness )
        surface.DrawRect( 0, self.Thickness, self.Thickness, h - self.Thickness )
        surface.DrawRect( self.Thickness, h - self.Thickness, w - self.Thickness, self.Thickness )
        surface.DrawRect( w - self.Thickness, 0, self.Thickness, h - self.Thickness )
    end

    function PANEL:UpdatePos()
        local parent = self:GetParent()
        if parent and parent:IsValid() then
            local x, y, width, height = self:GetBounds()
            local parent_width, parent_height = parent:GetSize()
            self:SetPos( math.Clamp( x, 0, parent_width - width ), math.Clamp( y, 0, parent_height - height ) )
        end
    end

    local input = input

    function PANEL:MousePos()
        local x, y = input.GetCursorPos()

        local data = self.StartPosition
        if data then
            x, y = x - data[ 1 ], y - data[ 2 ]
        else
            local width, height = self:GetSize()
            x, y = x - ( width * 0.5 ), y - ( height * 0.5 )
        end

        self:SetPos( x, y )
        self:UpdatePos()
    end

    function PANEL:OnMousePressed( keyCode )
        if keyCode == 107 then
            self.StartPosition = { self:ScreenToLocal( input.GetCursorPos() ) }
            self.Pressed = true
        end
    end

    function PANEL:OnMouseReleased( keyCode )
        if keyCode == 107 then
            self.Pressed = false
        end
    end

    function PANEL:PerformLayout()
        local size = mtm.GetImageSize()
        self:SetSize( size, size )

        if self.Initialized then
            self:UpdatePos()
        else
            self.Thickness = math.ceil( vmin * 0.25 )
            self.Initialized = true
            self:SetAlpha( 255 )
            self:MousePos()
        end
    end

    vgui.Register( "Map Thumbnail Maker - Frame", PANEL, "Panel" )

end

do

    ---@class MapThumbnailMakerOptions : DFrame
    local PANEL = {}

    function PANEL:Init()
        self:SetTitle( "#options" )
        self:SetSize( 256, 110 )

        do

            local label = vgui_Create( "DLabel", self )
            self.Label = label

            label:Dock( 4 )

        end

        do

            local slider = vgui_Create( "DNumSlider", self )
            self.Slider = slider

            slider:Dock( 4 )
            slider:SetDecimals( 0 )
            slider:SetText( "Image Size:" )
            slider:SetMin( size_cvar:GetMin() )
            slider:SetConVar( size_cvar:GetName() )

        end

        do

            local button = vgui_Create( "DButton", self )
            self.Button = button

            button:SetText( "OK" )
            button:Dock( 4 )

            ---@diagnostic disable-next-line: inject-field
            function button:DoClick()
                local options_panel = self:GetParent()
                if not ( options_panel and options_panel:IsValid() ) then return end

                local capture_panel = options_panel:GetParent()
                ---@cast capture_panel MapThumbnailMakerCapture
                if capture_panel and capture_panel:IsValid() then
                    capture_panel:Capture()
                end
            end

        end

    end

    function PANEL:PerformLayoutInternal( w, h )
        local titlePush = 0

        ---@diagnostic disable-next-line: undefined-field
        local icon = self.imgIcon
        if icon and icon:IsValid() then
            icon:SetPos( 5, 5 )
            icon:SetSize( 16, 16 )
            titlePush = 16
        end

        ---@diagnostic disable-next-line: undefined-field
        local close_button = self.btnClose
        if close_button and close_button:IsValid() then
            close_button:SetPos( w - 31 - 4, 0 )
            close_button:SetSize( 31, 24 )
        end

        ---@diagnostic disable-next-line: undefined-field
        local maxim_button = self.btnMaxim
        if maxim_button and maxim_button:IsValid() then
            maxim_button:SetPos( w - 31 * 2 - 4, 0 )
            maxim_button:SetSize( 31, 24 )
        end

        ---@diagnostic disable-next-line: undefined-field
        local minim_button = self.btnMinim
        if minim_button and minim_button:IsValid() then
            minim_button:SetPos( w - 31 * 3 - 4, 0 )
            minim_button:SetSize( 31, 24 )
        end

        ---@diagnostic disable-next-line: undefined-field
        local title = self.lblTitle
        if title and title:IsValid() then
            title:SetPos( 8 + titlePush, 2 )
            title:SetSize( w - 25 - titlePush, 20 )
        end
    end

    function PANEL:PerformLayout( w, h )
        self:PerformLayoutInternal( w, h )

        local slider = self.Slider
        if slider and slider:IsValid() then
            slider:SetMax( mtm.GetMaxImageSize() )
            slider:SetValue( mtm.GetImageSize() )
            slider:SizeToContentsX()
        end

        local label = self.Label
        if label and label:IsValid() then
            label:SetText( "File: data/maps/thumb/" .. game.GetMap() .. ".jpg" )
        end

        if self.Initialized then return end
        self.Initialized = true

        local parent = self:GetParent()
        if parent and parent:IsValid() then
            self:SetPos( ( parent:GetWide() - self:GetWide() ) * 0.5, self:GetTall() * 0.5 )
        end
    end

    function PANEL:OnRemove()
        local parent = self:GetParent()
        if parent and parent:IsValid() then
            parent:Remove()
        end
    end

    vgui.Register( "Map Thumbnail Maker - Options", PANEL, "DFrame" )

end

do

    ---@class MapThumbnailMakerCapture : Panel
    local PANEL = {}

    function PANEL:Init()
        self:MakePopup()
        self.Frame = vgui_Create( "Map Thumbnail Maker - Frame", self )
        self.Options = vgui_Create( "Map Thumbnail Maker - Options", self )

        hook.Add( "OnPauseMenuShow", self, function()
            mtm.Stop( false )
            return false
        end )
    end

    function PANEL:Capture()
        local frame = self.Frame
        ---@diagnostic disable-next-line: cast-type-mismatch
        ---@cast frame Panel
        if frame and frame:IsValid() then
            mtm.Capture( frame:GetBounds() )
            self:Remove()
        end
    end

    function PANEL:PerformLayout()
        self:SetPos( 0, 0 )
        self:SetSize( screen_width, screen_height )
    end

    vgui.Register( "Map Thumbnail Maker - Capture", PANEL, "Panel" )

end
