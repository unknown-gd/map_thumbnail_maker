local PANEL = {}

function PANEL:Init()
    self:MakePopup()

    self.Frame = vgui.Create( 'mtm.frame', self )
    self.Options = vgui.Create( 'mtm.options', self )
end

function PANEL:Make()
    local frame = self.Frame
    if IsValid( frame ) then
        mtm.Make( frame:GetX(), frame:GetY(), frame:GetWide(), frame:GetTall(), mtm.GetImageFormat() )
        self:Remove()
    end
end

local input_IsButtonDown = input.IsButtonDown
local KEY_ESCAPE = KEY_ESCAPE

function PANEL:Think()
    if input_IsButtonDown( KEY_ESCAPE ) then
        gui.HideGameUI()
        self:Remove()
        return
    end
end

function PANEL:PerformLayout( w, h )
    self:SetSize( ScrW(), ScrH() )
    self:SetPos( 0, 0 )
end

vgui.Register( 'mtm.main', PANEL, 'Panel' )