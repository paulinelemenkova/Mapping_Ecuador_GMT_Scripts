#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Ecuador)
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

chsh -s /bin/bash
chsh -s /bin/zsh

gmt grdcut GEBCO_2019.nc -R277/285/-5/1.5 -Gec_relief.nc
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R277/285/-5/1.5 -Gec_relief1.nc

gdalinfo ec_relief.nc -stats
# Minimum=-5319.000, Maximum=6560.000, Mean=-649.924, StdDev=2059.874
#####################################################################
# create mask of vector layer from the DCW of country's polygon
gmt pscoast -R277/285/-5/1.5 -Dh -M -EEC > ec.txt
#####################################################################
# Make color palette
# makecpt --help
gmt makecpt -Cgeo.cpt -V -T-5319/6560 > pauline.cpt
# Generate a file
ps=Topography_EC.ps
# Make background transparent image
gmt grdimage ec_relief.nc -Cpauline.cpt -R277/285/-5/1.5 -JM6i -P -I+a15+ne0.75 -t50 -Xc -K > $ps
# Add isolines
gmt grdcontour ec_relief1.nc -R -J -C500 -W0.1p -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,darkred -W0.1p -Df -O -K >> $ps
#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country
gmt psclip -R277/285/-5/1.5 -JM6.0i ec.txt -O -K >> $ps
# 2. create map within mask
# Add raster image
gmt grdimage ec_relief.nc -Cpauline.cpt -R277/285/-5/1.5 -JM6.0i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour ec_relief1.nc -R -J -C500 -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,tomato -W0.1p -Df -O -K >> $ps
# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################
# Add color barlegend
gmt psscale -Dg277/-5.5+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba1000g500f100+l"Color scale 'geo': global bathymetry/topography relief [R=-6857/3206, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Topographic map of Ecuador" -O -K >> $ps
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=10p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.2c+c50+w150k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-65p -O -K >> $ps
# Texts -R277/285/-5/1.5
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB+a-0 -Gwhite@40 >> $ps << EOF
281.59 -0.40 Quito
EOF
gmt psxy -R -J -Sc -W0.5p -Gred -O -K << EOF >> $ps
281.49 -0.22 0.25c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB+a-0 >> $ps << EOF
280.22 -2.18 Guayaquil
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.12 -2.18 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@50 >> $ps << EOF
281.10 -2.89 Cuenca
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
281.00 -2.89 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
280.70 -0.15 Santo Domingo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.83 -0.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@50 >> $ps << EOF
281.48 -1.24 Ambato
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
281.38 -1.24 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB+a-0 >> $ps << EOF
279.65 -1.2 Portoviejo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
279.55 -1.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,white+jLB+a-0 >> $ps << EOF
280.27 -2.4 Durán
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.17 -2.17 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@50 >> $ps << EOF
280.14 -3.27 Machala
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.04 -3.27 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@40 >> $ps << EOF
280.90 -3.98 Loja
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
280.80 -3.98 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB+a-0 -Gwhite@60 >> $ps << EOF
279.38 -0.95 Manta
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
279.28 -0.95 0.20c
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB >> $ps << EOF
283.2 0.6 C O L O M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,25,black+jLB >> $ps << EOF
282.5 -3.5 P  E  R  U
EOF
# water
gmt pstext -R -J -N -O -K \
-F+jTL+f13p,26,blue1+jLB >> $ps << EOF
277.5 -0.5 Pacific
277.5 -1.0 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB >> $ps << EOF
279.0 -3.1 Gulf of
279.0 -3.3 Guayaquil
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue1+jLB -Gwhite@60 >> $ps << EOF
279.4 1.3 Ancón de Sardinas
280.3 1.1 Bay
EOF
# rivers -R285/328/-35/6
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,white+jLB >> $ps << EOF
283.2 -0.4 Aguarico
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,white+jLB+a-333 >> $ps << EOF
282.5 -0.9 Napo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,white+jLB+a-62 >> $ps << EOF
282.9 -0.1 Coca
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,23,honeydew+jLB >> $ps << EOF
281.0 -0.8 A N D E S
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,23,honeydew+jLB >> $ps << EOF
282.60 -1.2 A M A Z O N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,23,honeydew+jLB >> $ps << EOF
279.7 -1.5 C O S T A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,23,honeydew+jLB+a-38 >> $ps << EOF
279.3 -2.0 Santa Elena
279.3 -2.2 Peninsula
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,23,midnightblue+jLB -Gwhite@70 >> $ps << EOF
278.6 -2.1 Point
278.2 -2.3 Santa Elena
EOF
# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjBR+w3.0c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,white -Rg -JG281/2S/$w -Da -Gbrown -A5000 -Bg -Wfaint -ESA+gpeachpuff -EEC+gyellow -Scornflowerblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps
# Add GMT logo
gmt logo -Dx6.2/-2.8+o0.1i/0.1i+w2c -O -K >> $ps
# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.2c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
1.5 13.5 SRTM/GEBCO 15 arc sec resolution global terrain model grid
EOF
# Convert to image file using GhostScript
gmt psconvert Topography_EC.ps -A0.5c -E720 -Tj -Z
