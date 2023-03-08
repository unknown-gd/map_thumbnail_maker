local IsValid = IsValid
local vgui = vgui
local mtm = mtm

local FILL = FILL
local LEFT = LEFT
local TOP = TOP

local PANEL = {}

function PANEL:Init()
    self:SetTitle( '#options' )
    self:SetSize( 256, 130 )

    do

        local label = vgui.Create( 'DLabel', self )
        self.Label = label
        label:Dock( TOP )

    end

    do

        local panel = vgui.Create( 'Panel', self )
        panel:Dock( TOP )

        local label = vgui.Create( 'DLabel', panel )
        panel.Label = label
        label:Dock( LEFT )
        label:SetText( 'Image Format:' )
        label:SizeToContentsX()

        local formats = vgui.Create( 'DComboBox', panel )
        panel.Formats = formats
        self.Formats = formats
        formats:Dock( FILL )

        function formats:OnSelect( _, value )
            RunConsoleCommand( 'mtm_format', value )
        end

        for name in pairs( mtm.AllowedFormats ) do
            formats:AddChoice( name )
        end

    end

    do

        local slider = vgui.Create( 'DNumSlider', self )
        self.Slider = slider
        slider:Dock( TOP )

        local thumbSize = GetConVar( 'mtm_size' )
        slider:SetText( 'Image Size:' )
        slider:SetMin( thumbSize:GetMin() )
        slider:SetDecimals( 0 )

        slider:SetConVar( thumbSize:GetName() )

    end

    do

        local button = vgui.Create( 'DButton', self )
        self.Button = button
        button:SetText( 'OK' )
        button:Dock( TOP )

        function button:DoClick()
            local parent = self:GetParent()
            if IsValid( parent ) then
                local parent = parent:GetParent()
                if IsValid( parent ) then
                    parent:Make()
                end
            end
        end

    end

end

function PANEL:PerformLayoutInternal( w, h )
    local titlePush = 0
    if IsValid( self.imgIcon ) then
        self.imgIcon:SetPos( 5, 5 )
        self.imgIcon:SetSize( 16, 16 )
        titlePush = 16
    end

    self.btnClose:SetPos( w - 31 - 4, 0 )
    self.btnClose:SetSize( 31, 24 )

    self.btnMaxim:SetPos( w - 31 * 2 - 4, 0 )
    self.btnMaxim:SetSize( 31, 24 )

    self.btnMinim:SetPos( w - 31 * 3 - 4, 0 )
    self.btnMinim:SetSize( 31, 24 )

    self.lblTitle:SetPos( 8 + titlePush, 2 )
    self.lblTitle:SetSize( w - 25 - titlePush, 20 )
end

function PANEL:PerformLayout( w, h )
    self:PerformLayoutInternal( w, h )

    local slider = self.Slider
    if IsValid( slider ) then
        slider:SetMax( mtm.GetMaxImageSize() )
        slider:SetValue( mtm.GetImageSize() )
        slider:SizeToContentsX()
    end

    local label = self.Label
    if IsValid( label ) then
        label:SetText( 'File: data/map_thumbs/' .. game.GetMap() .. '.' .. mtm.GetImageFormat() )
    end

    local formats = self.Formats
    if IsValid( formats ) then
        formats:SetValue( mtm.GetImageFormat() )
    end

    if self.Initialized then return end
    self.Initialized = true

    local parent = self:GetParent()
    if IsValid( parent ) then
        self:SetPos( ( parent:GetWide() - self:GetWide() ) / 2, self:GetTall() / 2 )
    end
end

function PANEL:OnRemove()
    local parent = self:GetParent()
    if IsValid( parent ) then
        parent:Remove()
    end
end

vgui.Register( 'mtm.options', PANEL, 'DFrame' )