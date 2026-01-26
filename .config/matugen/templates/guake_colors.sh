#!/bin/bash
# Matugen template for Guake 18-color palette (16 ANSI + Foreground + Background)
SCHEMA="guake.style.font"

# Construct the palette: color0 through color15, then color7 (FG), then color0 (BG)
gsettings set $SCHEMA palette '{{dank16.color0.default.hex}}:{{dank16.color1.default.hex}}:{{dank16.color2.default.hex}}:{{dank16.color3.default.hex}}:{{dank16.color4.default.hex}}:{{dank16.color5.default.hex}}:{{dank16.color6.default.hex}}:{{dank16.color7.default.hex}}:{{dank16.color8.default.hex}}:{{dank16.color9.default.hex}}:{{dank16.color10.default.hex}}:{{dank16.color11.default.hex}}:{{dank16.color12.default.hex}}:{{dank16.color13.default.hex}}:{{dank16.color14.default.hex}}:{{dank16.color15.default.hex}}:{{dank16.color7.default.hex}}:{{dank16.color0.default.hex}}'

# Ensure the palette-name is set to Custom so Guake uses our values
gsettings set $SCHEMA palette-name 'Custom'
