#!/bin/sh
# Purpose: geoid of Ecuador
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

gmt grdconvert s45w90/w001001.adf geoid_01.grd
gmt grdconvert n00w90/w001001.adf geoid_02.grd
gdalinfo geoid_01.grd -stats
# Minimum=-28.476, Maximum=50.095, Mean=7.756, StdDev=14.446


# Generate a color palette table from grid
# gmt makecpt --help
gmt makecpt -Cwysiwyg -T-20/30 > colors.cpt

# Generate a file
ps=Geoid_EC.ps
gmt grdimage geoid_01.grd -Ccolors.cpt -R277/285/-5/1.5 -JM6.5i -P -Xc -I+a15+ne0.75 -K > $ps
gmt grdimage geoid_02.grd -Ccolors.cpt -R277/285/-5/1.5 -JM6.5i -P -Xc -I+a15+ne0.75 -O -K >> $ps

# Add shorelines
gmt grdcontour geoid_01.grd -R -J -C0.5 -A0.5+f9p,25,black -Wthinner,dimgray -O -K >> $ps
gmt grdcontour geoid_02.grd -R -J -C0.5 -A0.5+f9p,25,black -Wthinner,dimgray -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Geoid gravitational model of Ecuador" -O -K >> $ps
    
# Add legend
gmt psscale -Dg277/-5.5+w16.5c/0.4c+h+o0.0/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=8p,25,black \
    -Bg4f0.5a2+l"Color scale 'wysiwyg': 20 well-separated RGB colors [C=RGB] [C=RGB -T-18/-5]" \
    -I0.2 -By+lm -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thickest,white -Wthinner -Df -O -K >> $ps

# Add GMT logo
gmt logo -Dx7.2/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y8.2c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
3.0 9.0 World geoid image EGM2008 vertical datum 2.5 min resolution
EOF

# Convert to image file using GhostScript
gmt psconvert Geoid_EC.ps -A0.5c -E720 -Tj -Z
