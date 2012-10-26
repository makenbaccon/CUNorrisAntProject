Globals [
  power       ;; amount of resources the colony is using
  energy      ;; total amount of power the colony has spent throughout time
  inital-food ;; amount of food at time = o
  food-per-energy ;; ratio of amount food collected compared to energy spent
  Leave       ;; amount of chemical near nest
  window      ;; tells us whether the nest chemical amount is going up or down
]  

patches-own [
  chemical             ;; amount of chemical on this patch
  ground               ;; color of ground
  food                 ;; amount of food on this patch (1 or 2)
  nest?                ;; true on nest patches, false elsewhere
  nest-scent           ;; number that is higher closer to the nest
  food-source-number   ;; number (1, 2, 3, or 4) to identify the food sources

]

Turtles-own [ 
  hungry               ;; counts how long it has been since last food encounter
]
  
;; Create different types of ants
Breed [ patroller ] 
Breed [ forager ]
Breed [ midden ]
Breed [ warrior ]


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  set-default-shape turtles "ant"  ;; makes them look like ants
  resize-world -60 60 -60 60
  ;;resize-world -30 30 -30 30
  create-patroller population
  [ set size 3         ;; easier to see
    set color red      ;; red = not carrying food
    fd 5 ]
  setup-patches
  do-plotting
end

to setup-patches
  ask patches
  [ setup-nest
    create-food
    recolor-patch
    set pcolor 65 ]
end

to setup-nest  ;; patch procedure
  ;; set nest? variable to true inside the nest, false elsewhere
  set nest? (distancexy 0 0) < 4
  ;; spread a nest-scent over the whole world -- stronger near the nest
  set nest-scent 200 - distancexy 0 0
end

to create-food
  if (distancexy (0.85 * max-pxcor) 12) < 6
    [ set food-source-number 1 ]
    ;; setup food source two on the lower-left
    if (distancexy (-0.8 * max-pxcor) (-0.6 * max-pycor)) < 6
    [ set food-source-number 2 ]
    ;; setup food source three on the upper-left
    if (distancexy (-0.6 * max-pxcor) (0.7 * max-pycor)) < 6
    [ set food-source-number 3 ]
    ;; set "food" at sources to either 1 or 2, randomly
    if food-source-number > 0
   [ set food 2 ]
end

to recolor-patch  ;; patch procedure
  ;; give color to nest and food sources
  ifelse nest?
  [ set pcolor brown ]    ;; Color the nest Brown
  [ ifelse food > 0       ;; Color food
    [ if food-source-number = 1 [ set pcolor cyan ]
      if food-source-number = 2 [ set pcolor sky  ]
      if food-source-number = 3 [ set pcolor blue ] 
      if food-source-number = 4 [ set pcolor red  ] ]
    ;; scale color to show chemical concentration
    [ ifelse chemical <= 1             
       [ set pcolor green ]
       [ ifelse chemical >= 10.5
         [ set pcolor white ]
          ;; if chemical >= 1 and chemical <= 10.5
         [ set pcolor scale-color magenta chemical 1 10.5 ]
  ] ] ]
end


;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;
;;;;;;;;;;;;;;;;;;;;;

to go  ;; forever button
  ask turtles
  [ ifelse color = red
    [ look-for-food  ]       ;; not carrying food? look for it
    [ return-to-nest ]       ;; carrying food? take it back to nest
    fd 1 
    add-ants
    kill-ants ]
  diffuse chemical (diffusion-rate / 100)
  ask patches
  [ set chemical chemical  * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    recolor-patch 
    if add-food-with-click? = true [add-food]
  ]
  
  measure-system
  tick
  do-plotting
  if sum [food] of patches = 0 [Stop]
end

to return-to-nest  ;; turtle procedure
  if return-wiggle 
  [ wiggle ]
  if not can-move? 1 [ rt 180 ]
  ifelse nest?
  [ ;; drop food and head out again
    set color red
    rt 180 ]
  [ If breed = patroller 
    [set chemical chemical + patchem]  ;; drop some chemical
    If breed = forager
    [set chemical chemical + forgchem]  ;; drop some chemical
    uphill-nest-scent ]         ;; head toward the greatest value of nest-scent
end

to look-for-food  ;; turtle procedure
  wiggle
  if not can-move? 1 [ rt 180 ]
  if food > 0
  [ set color black          ;; pick up food
    set food food - 1        ;; and reduce the food source
    rt 180                   ;; and turn around
    stop ]
  ;; go in the direction where the chemical smell is strongest
  if (chemical >= 1) and (chemical < 10.5)
  [ uphill-chemical ]
end

;; sniff forward, left, and right, and go where the strongest smell is
to uphill-chemical  ;; turtle procedure
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle  -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

;; sniff left and right, and go where the strongest smell is
to uphill-nest-scent  ;; turtle procedure
  let scent-ahead nest-scent-at-angle   0
  let scent-right nest-scent-at-angle  45
  let scent-left  nest-scent-at-angle  (45 * -1)
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to wiggle  ;; turtle procedure
  if (count turtles < 500)
  [ifelse count turtles > 500
  [rt random-normal 1 amount-of-wiggle]
  [rt random-normal 1 amount-of-wiggle * 2]]
end

to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent] of p
end

to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical] of p
end

to Add-food  ;; patch procedure
  ;; setup food source one on the right
  
  if mouse-down?
  [ ask patch mouse-xcor mouse-ycor 
    [ if (distancexy mouse-xcor mouse-ycor) < 5
      [ set food-source-number 4
        set food 2 
        set pcolor red ] ] ]
end

to Add-ants
  if (distancexy 0 0) < 6
      [   set Leave (Leave + chemical) / 2 ]
  if leave < Leave-low-Threshold [ set window 0 ] 
  if leave > Leave-high-Threshold [ set window 1 ] 
  
  if ;Ticks Mod 10 = 0 and 
     count turtles < 1000 and 
     window = 0 and
     Who < forager-flow   ;;amount of ants that come out when leave-nest is satisfied
     [ if Leave > Leave-low-Threshold and Leave < Leave-high-Threshold
       [ hatch-forager 1 
         [ set color red 
           set hungry 0
           setxy 0 0 ] ]]
end 

to kill-ants
  ask turtle who [ 
    if Breed = forager
      [ set hungry (hungry + 1) 
        if hungry > Death-From-Hunger [die] ] ]
      if color = black [ set hungry 0 ] 
end 

to Measure-System
  if ticks < 2
    [ set inital-food (sum [food] of patches) ]
  set power (count turtles * ant-cost + count turtles with [color = black] * chem-cost )
  set energy (energy + power)
  set food-per-energy ((inital-food - (sum [food] of patches)) / energy)
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Plotting procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-plotting
  if not plot? [ stop ]
  set-current-plot "Food in each pile"
  ;; since the plot? switch can be turned on and off at
  ;; any time, we must use PLOTXY to make sure points are
  ;; plotted with the proper x coordinates
  set-current-plot-pen "food-in-pile1"
  plotxy ticks sum [food] of patches with [pcolor = cyan]
  set-current-plot-pen "food-in-pile2"
  plotxy ticks sum [food] of patches with [pcolor = sky]
  set-current-plot-pen "food-in-pile3"
  plotxy ticks sum [food] of patches with [pcolor = blue]
  set-current-plot-pen "food-in-pile4"
  plotxy ticks sum [food] of patches with [pcolor = red]

  set-current-plot "Number of Foragers"
  set-current-plot-pen "forage"
  plotxy ticks count forager ;;of turtles with [pcolor = red]

  set-current-plot "Power" ;; plot energy vs time
  plotxy ticks power
  
  set-current-plot "Signal-to-Leave"
  plotxy ticks Leave  ;; plot the amount of chemical near nest vs time

  set-current-plot "Food-per-Energy"
  plotxy ticks Food-per-energy  



end


;; Credit to 1997 Uri Wilensky for frame of program
@#$#@#$#@
GRAPHICS-WINDOW
226
44
1083
922
60
60
7.0
1
10
1
1
1
0
1
1
1
-60
60
-60
60
0
0
1
ticks

BUTTON
32
10
112
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
18
94
208
127
diffusion-rate
diffusion-rate
0.0
99.0
3
3
1
NIL
HORIZONTAL

SLIDER
19
136
209
169
evaporation-rate
evaporation-rate
0.0
5
0
.2
1
NIL
HORIZONTAL

BUTTON
122
10
197
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SWITCH
968
10
1058
43
plot?
plot?
0
1
-1000

SLIDER
18
54
208
87
population
population
0.0
200.0
79
1.0
1
NIL
HORIZONTAL

PLOT
1093
10
1387
147
Food in each pile
time
food
0.0
100.0
0.0
120.0
true
false
PENS
"food-in-pile1" 1.0 0 -11221820 true
"food-in-pile2" 1.0 0 -13791810 true
"food-in-pile3" 1.0 0 -13345367 true
"food-in-pile4" 1.0 0 -2674135 true

SLIDER
19
177
209
210
amount-of-wiggle
amount-of-wiggle
0
180
10.5
.5
1
NIL
HORIZONTAL

SWITCH
46
511
162
544
return-wiggle
return-wiggle
0
1
-1000

SLIDER
19
218
208
251
Chem-Low-Threshold
Chem-Low-Threshold
0
1
0
.1
1
NIL
HORIZONTAL

SLIDER
20
260
206
293
Chem-Upper-Threshold
Chem-Upper-Threshold
0
50
33.5
.5
1
NIL
HORIZONTAL

PLOT
1092
155
1387
282
Number of Foragers
Time
# of Ants
0.0
100.0
0.0
100.0
true
false
PENS
"Forage" 1.0 0 -16777216 true
"Midden" 1.0 0 -8630108 true

PLOT
1094
448
1388
598
Power
NIL
NIL
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true

PLOT
1092
289
1309
439
Signal-to-Leave
time
Chem Near Nest
0.0
10.0
0.0
30.0
true
false
PENS
"default" 1.0 0 -16777216 true

MONITOR
1319
396
1386
441
Energy
Energy
1
1
11

MONITOR
1298
598
1389
643
food-per-energy
food-per-energy
5
1
11

PLOT
1094
644
1391
794
Food-per-Energy
NIL
NIL
0.0
10.0
0.0
0.0010
true
false
PENS
"default" 1.0 0 -16777216 true

SLIDER
19
301
208
334
Leave-low-Threshold
Leave-low-Threshold
0
100
60
5
1
NIL
HORIZONTAL

SLIDER
19
343
205
376
Leave-high-Threshold
Leave-high-Threshold
20
200
120
10
1
NIL
HORIZONTAL

SLIDER
18
386
206
419
forager-flow
forager-flow
0
20
20
1
1
NIL
HORIZONTAL

SLIDER
18
429
206
462
Death-from-Hunger
Death-from-Hunger
10
1000
10
10
1
NIL
HORIZONTAL

SWITCH
24
553
194
586
Add-Food-with-click?
Add-Food-with-click?
1
1
-1000

TEXTBOX
11
615
205
687
If on, you can add food with a mouse click, but the program will become very slow. 'Food-per-Energy' won't work if you add food
11
0.0
1

SLIDER
1101
606
1193
639
Ant-Cost
Ant-Cost
0
2
1
.1
1
NIL
HORIZONTAL

SLIDER
1205
607
1297
640
Chem-Cost
Chem-Cost
0
10
2
.2
1
NIL
HORIZONTAL

SLIDER
17
468
109
501
Patchem
Patchem
0
200
100
10
1
NIL
HORIZONTAL

SLIDER
114
467
206
500
Forgchem
Forgchem
0
60
20
2
1
NIL
HORIZONTAL

@#$#@#$#@
WHAT IS IT?
-----------
This is an extension of "Ants", a model included in the default model library of NetLogo. In this project, a colony of ants forages for food. Though each ant follows a set of simple rules, the colony as a whole acts in a sophisticated way.

AUTHORSHIP
-----------
The original framework was designed by Uri Wilensky (see copyright notice below) with extensions made by Andrew Erickson and David Kozak. Extensions were made in collaboration with the Prof. Adam Norris Ant Seminar Class at University of Colorado at Boulder (APPM 4950, Fall '10). 

HOW IT WORKS
------------
When an ant finds a piece of food, it carries the food back to the nest, dropping a chemical as it moves. When other ants "sniff" the chemical, they follow the chemical toward the food. As more ants carry food to the nest, they reinforce the chemical trail.

HOW TO USE IT
-------------
Click the SETUP button to set up the ant nest (in brown, at center) and three piles of food. Click the GO button to start the simulation. The chemical is shown in a black-to-green-to-white gradient. Play with the user defined variables to find the best colony characteristics.

USER VARIABLES
-------------
If you want to change the number of patroller ants (ants that don't go away), move the POPULATION slider before pressing SETUP. More patrollers means you find food faster but the base level of energy usage costs more. 

The EVAPORATION-RATE slider controls the evaporation rate of the chemical. The DIFFUSION-RATE slider controls the diffusion rate of the chemical. 

AMOUNT-OF-WIGGLE is a parameter that controls how much the ants divate from a straight path. It randomly chooses a number from a normal distribution and tells the ant to step slightly in that direction. The slider adjusts the standard deviation. If this slider is set to 0, the ants will walk in straight lines. If it is set higher than 100, the ants pretty much act with Brownian motion. Optimal wiggle is about 20.

LoS is an abbreviation for Line of Sight. This parameter tells the ant how far to the left and right it should ‘sniff’. Optimal value is about 40. Anything under 15 and over 150 seems to be dysfunctional.

CHEM-LOW-THRESHOLD tells the ant to ignore scents that are below this threshold. Setting this number to 0 lets the ants smell infinitely small amounts of pheromone. The optimal value for this seems to be dependent on the food source, amount of ants, evaporation-rate and diffusion-rate.

CHEM-UPPER-THRESHOLD tells the ants to ignore the difference in scent for pheromone over this threshold. The optimal value for this seems to be dependent on the food source and the amount of ants.

The two reporter windows below these sliders tell us what area is covered by chemicals. LOW CHEM AREA tells us the amount of area that has more than the lower threshold of chemicals ants can 'smell'. UPPER CHEM AREA tells us the area ants will cover when on a hot trail (what area).  

There is a window that ants foragers use to decide to leave the nest. If the total chemical within a circle of 6 patches from the nest center satisfies the window conditions, ant foragers will leave the nest. LEAVE-(LOW/HIGH)-CHEMICAL adjusts the window. 

FORAGER-FLOW is the amount of ant foragers that come out of the nest when the window conditions are met. If there are over 1000 ants, no more will come out. This is to protect the program from having an ant explosion. If you want to change this you can modify the code: 
  if ;Ticks Mod 10 = 0 and 
     count turtles < 1000 and 
     window = 0 and

If an ant does not find food within DEATH-FROM-HUNGER ticks it will die. Another way of thinking of this parameter is that the ants just goes back into the nest and waits for the window conditions to be met again. 

RETURN-WIGGLE is a switch that when on lets ants with food wiggle as much as ants without food. When this is switched off, ants returning with food walk in a straight line towards the nest.     

If ADD FOOD WITH CLICK? is on, you can add food with a mouse click, but the program will become very slow. 'Food-per-Energy' won't work if you add food. 

PLOTS
-------------
There is a PLOT? switch. If off plotting will be disabled and the model runs faster. 

FOOD IN EACH PILE graphs the amount of food in each of the four food piles. The red line is the user added food. 

NUMBER OF FORAGERS graphs the amount ant foragers at any one time. 

SIGNAL TO LEAVE graphs the amount of chemical within a 6 patch radius of the nest. 

ENERGY is the total power throughout time used. See Power below for more details

POWER sums the amount of ants outside the nest adds and the amount of chemical being used. Each of these sums is weighted with the sliders below: ANT-COST and CHEM-COST.  

FOOD-PER-ENERGY is the ratio of food gathered to energy spent. The best ant colonies will maximize this. The reporter window tells us at that particular tick what the food/energy is and the graph below measures it throughout time. 

THINGS TO NOTICE
----------------
The ant colony generally exploits the food source in order, starting with the food closest to the nest, and finishing with the food most distant from the nest. It is more difficult for the ants to form a stable trail to the more distant food, since the chemical trail has more time to evaporate and diffuse before being reinforced.

Once the colony finishes collecting the closest food, the chemical trail to that food naturally disappears, freeing up ants to help collect the other food sources. The more distant food sources require a larger "critical number" of ants to form a stable trail.

The consumption of the food is shown in a plot.  The line colors in the plot match the colors of the food piles.


EXTENDING THE MODEL
-------------------
Try different placements for the food sources. What happens if two food sources are equidistant from the nest? When that happens in the real world, ant colonies typically exploit one source then the other (not at the same time).

In this project, the ants use a "trick" to find their way back to the nest: they follow the "nest scent." Real ants use a variety of different approaches to find their way back to the nest. Try to implement some alternative strategies.


ORIGINAL COPYRIGHT NOTICE
----------------
Copyright 1997 Uri Wilensky. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission from Uri Wilensky. Contact Uri Wilensky for appropriate licenses for redistribution for profit.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was developed at the MIT Media Lab using CM StarLogo.  See Resnick, M. (1994) "Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds."  Cambridge, MA: MIT Press.  Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 1998.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

ant 2
true
0
Polygon -7500403 true true 150 19 120 30 120 45 130 66 144 81 127 96 129 113 144 134 136 185 121 195 114 217 120 255 135 270 165 270 180 255 188 218 181 195 165 184 157 134 170 115 173 95 156 81 171 66 181 42 180 30
Polygon -7500403 true true 150 167 159 185 190 182 225 212 255 257 240 212 200 170 154 172
Polygon -7500403 true true 161 167 201 150 237 149 281 182 245 140 202 137 158 154
Polygon -7500403 true true 155 135 185 120 230 105 275 75 233 115 201 124 155 150
Line -7500403 true 120 36 75 45
Line -7500403 true 75 45 90 15
Line -7500403 true 180 35 225 45
Line -7500403 true 225 45 210 15
Polygon -7500403 true true 145 135 115 120 70 105 25 75 67 115 99 124 145 150
Polygon -7500403 true true 139 167 99 150 63 149 19 182 55 140 98 137 142 154
Polygon -7500403 true true 150 167 141 185 110 182 75 212 45 257 60 212 100 170 146 172

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Wiggle" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <enumeratedValueSet variable="Chem-Upper-Threshold">
      <value value="10.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Patchem">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-low-Threshold">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forager-flow">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="amount-of-wiggle" first="6" step="1" last="14"/>
    <enumeratedValueSet variable="population">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Low-Threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusion-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-high-Threshold">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Forage_Flow1" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <enumeratedValueSet variable="Chem-Upper-Threshold">
      <value value="10.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Patchem">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-low-Threshold">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forager-flow">
      <value value="1"/>
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="amount-of-wiggle">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Low-Threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusion-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-high-Threshold">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Flow" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <enumeratedValueSet variable="Chem-Upper-Threshold">
      <value value="10.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="50"/>
      <value value="80"/>
      <value value="100"/>
      <value value="200"/>
      <value value="400"/>
      <value value="800"/>
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Patchem">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-low-Threshold">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forager-flow">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="amount-of-wiggle">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Low-Threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusion-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-high-Threshold">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Leave" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <enumeratedValueSet variable="Chem-Upper-Threshold">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Patchem">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Leave-low-Threshold" first="20" step="20" last="140"/>
    <enumeratedValueSet variable="forager-flow">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="amount-of-wiggle">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Low-Threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusion-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Leave-high-Threshold" first="50" step="25" last="200"/>
  </experiment>
  <experiment name="Trail" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <steppedValueSet variable="Chem-Upper-Threshold" first="5" step="3" last="26"/>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Patchem">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-low-Threshold">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forager-flow">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="amount-of-wiggle">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="49"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Chem-Low-Threshold" first="0.2" step="0.2" last="1.6"/>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusion-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-high-Threshold">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Chem" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <enumeratedValueSet variable="Chem-Upper-Threshold">
      <value value="10.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="evaporation-rate" first="0.4" step="0.4" last="3.2"/>
    <enumeratedValueSet variable="Patchem">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-low-Threshold">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forager-flow">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="amount-of-wiggle">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Low-Threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="diffusion-rate" first="5" step="3" last="30"/>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-high-Threshold">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Patroll" repetitions="4" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3200"/>
    <exitCondition>sum [food] of patches &lt; 2</exitCondition>
    <metric>food-per-energy</metric>
    <enumeratedValueSet variable="Chem-Upper-Threshold">
      <value value="10.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Death-from-Hunger">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ant-Cost">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evaporation-rate">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Patchem">
      <value value="20"/>
      <value value="40"/>
      <value value="60"/>
      <value value="80"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Add-Food-with-click?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-low-Threshold">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forager-flow">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Forgchem">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="amount-of-wiggle">
      <value value="8"/>
    </enumeratedValueSet>
    <steppedValueSet variable="population" first="10" step="10" last="150"/>
    <enumeratedValueSet variable="Chem-Low-Threshold">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Chem-Cost">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="diffusion-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="return-wiggle">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leave-high-Threshold">
      <value value="150"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
