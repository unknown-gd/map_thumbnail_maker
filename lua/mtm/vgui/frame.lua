local surface = surface
local render = render
local mtm = mtm

local STENCILCOMPARISONFUNCTION_EQUAL = STENCILCOMPARISONFUNCTION_EQUAL
local STENCILCOMPARISONFUNCTION_NEVER = STENCILCOMPARISONFUNCTION_NEVER
local STENCILOPERATION_REPLACE = STENCILOPERATION_REPLACE
local STENCILOPERATION_ZERO = STENCILOPERATION_ZERO

local PANEL = {}

function PANEL:Init()
    self:SetPaintedManually( true )
    self:NoClipping( true )
    self:SetAlpha( 0 )
    self.Thickness = 3

    hook.Add( 'HUDPaint', self, function()
        surface.SetDrawColor( 255, 255, 255 )

        render.ClearStencil()
        render.SetStencilEnable( true )

        render.SetStencilWriteMask( 1 )
        render.SetStencilTestMask( 1 )

        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
        render.SetStencilPassOperation( STENCILOPERATION_ZERO )
        render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
        render.SetStencilReferenceValue( 1 )

        surface.DrawRect( self:GetBounds() )

        render.SetStencilFailOperation( STENCILOPERATION_ZERO )
        render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
        render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
        render.SetStencilReferenceValue( 0 )

        surface.SetDrawColor( 0, 0, 0, 200 )
        surface.DrawRect( 0, 0, mtm.ScreenWidth, mtm.ScreenHeight )

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

local IsValid = IsValid

function PANEL:UpdatePos()
    local parent = self:GetParent()
    if IsValid( parent ) then
        local x, y = self:GetPos()
        local w, h = self:GetSize()
        self:SetPos( math.Clamp( x, 0, parent:GetWide() - w ), math.Clamp( y, 0, parent:GetTall() - h ) )
    end
end

local input = input

function PANEL:MousePos()
    local x, y = input.GetCursorPos()
    local w, h = self:GetSize()

    if self.ClickPos then
        x, y = x - self.ClickPos[ 1 ], y - self.ClickPos[ 2 ]
    else
        x, y = x - w / 2, y - h / 2
    end

    self:SetPos( x, y )
    self:UpdatePos()
end

local MOUSE_LEFT = MOUSE_LEFT

function PANEL:OnMousePressed( keyCode )
    if (keyCode == MOUSE_LEFT) then
        self.ClickPos = { self:ScreenToLocal( input.GetCursorPos() ) }
        self.Pressed = true
    end
end

function PANEL:OnMouseReleased( keyCode )
    if (keyCode == MOUSE_LEFT) then
        self.Pressed = false
    end
end

-- local KEY_ENTER = KEY_ENTER

function PANEL:Think()
    -- if self:IsHovered() and input.IsButtonDown( KEY_ENTER ) then
    --     local parent = self:GetParent()
    --     if IsValid( parent ) then
    --         parent:Make()
    --         return
    --     end
    -- end

    if self.Pressed then
        if input.IsMouseDown( MOUSE_LEFT ) then
            self:MousePos()
            return
        end

        self.Pressed = false
    end
end

function PANEL:PerformLayout( w, h )
    local size = mtm.GetImageSize()
    self:SetSize( size, size )

    if not self.Initialized then
        self.Initialized = true
        self:SetAlpha( 255 )
        self:MousePos()
        return
    end

    self:UpdatePos()
end

vgui.Register( 'mtm.frame', PANEL, 'Panel' )