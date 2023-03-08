local vgui_Create = vgui.Create
local IsValid = IsValid
local mtm = mtm

local PANEL = {}

function PANEL:Init()
    self:MakePopup()
    self.Frame = vgui_Create( 'mtm.frame', self )
    self.Options = vgui_Create( 'mtm.options', self )
end

function PANEL:Make()
    local frame = self.Frame
    if IsValid( frame ) then
        mtm.Make( frame:GetX(), frame:GetY(), frame:GetWide(), frame:GetTall(), mtm.GetImageFormat() )
        self:Remove()
    end
end

do

    local input_IsButtonDown = input.IsButtonDown
    local gui_HideGameUI = gui.HideGameUI
    local KEY_ESCAPE = KEY_ESCAPE

    function PANEL:Think()
        if input_IsButtonDown( KEY_ESCAPE ) then
            gui_HideGameUI()
            mtm.Stop()
            return
        end
    end

end

function PANEL:PerformLayout( w, h )
    self:SetSize( ScrW(), ScrH() )
    self:SetPos( 0, 0 )
end

vgui.Register( 'mtm.main', PANEL, 'Panel' )