__includes [ "midden.nls" "nest-patrollers.nls" "trail-patrollers.nls" "inactives.nls" "foragers.nls"]


patches-own [
  nest-config  ;;able to find antill by gradient
  in-dish?     ;; model of petri dish for radius around ant hill
  midden-amount ;;a pile of midden can have more than one object in it
  food-source-number ;;designates the food pile
  foodp               ;;power of the food
  ]  ;;Property to setup the gradient of patches to get home


globals
[ dish-radius    ;;size of the radius around the ant hill
  nest-return    ;; count of how many trail partollers returned - if at 85% of those that go out then trail patrollers go out
  coeff
]


to setup 
  clear-all
  set-default-shape turtles "bug"  ;;make the shape look like an ant ;;1D "ant"
  
  create-nest-patrollers ceiling (population * 0.015)  [
    set color red
    set patrol-completion 0         ;;set default values
    ;;set up internal variables
  ]
  
  create-trail-patrollers 20 [   ;;make trail patrollers 
    set color yellow
    set hidden? true             ;;hide them till when they are needed
    set found-food? false        ;;set default values
    set active? false
    set direction 0
    set scent 0
    
  ]
  
  create-inactives 0.1 * (population - ceiling (population * 0.015) - 20 )[
    set color blue
    set hidden? true
    set food-direction []
  ]
  
  set nest-return 0                ;;0 nets partollers have returned --> initialize to 0
  set coeff 5
  
  setup-antifood                   ;;make objects for midden ants
  
  setup-food                       ;;make piles of food
  
  setup-ant-hill                   ;;make the anthill and sent the patches
  
end

to setup-ant-hill
  ask patch 0 0 [set pcolor magenta]                                ;;the anthill is magenta
  ask patches [set nest-config 200 - distancexy 0 0]             ;;scent the ground to find way home
  
  set dish-radius floor ( max-pxcor * 0.66)                    ;;66% of the x-direction makes th radius of the dish 
  ask patches [ set in-dish? false ]
  ask turtle 0 [ask patches in-radius dish-radius [ set in-dish? true ]]  ;;designate inside and outside of dish

end

to setup-antifood
  repeat ceiling (max-pxcor * max-pycor * (amount-midden / 100))  ;;set up amount-midden% of total squares
  [
    ask one-of patches
     [
       if pxcor != 0 and pycor != 0
       [
         set pcolor white                                           ;;to be midden
         set midden-amount ((random 3) + 1)                         ;;and a certain amount of midden per designated patch
       ]
     ]
  ]
    
end


to setup-food
  
    ;;repeat 5[
    ;;ask patch (random-pxcor) (abs (random-pycor)) [set pcolor green]    ;;for 5 POSITIVE patches color green to represent food
  ;;]
  ask patches [if (distancexy (0.85 * max-pxcor) 12) < 2
    [ set food-source-number 1 ]
    ;; setup food source two on the lower-left
  if (distancexy (-0.8 * max-pxcor) (-0.6 * max-pycor)) < 2 ;;last number is radius !make scale to world size
    [ set food-source-number 2 ]
    ;; setup food source three on the upper-left
  if (distancexy (-0.6 * max-pxcor) (0.7 * max-pycor)) < 2
    [ set food-source-number 3 ]
    ;; set "food" at sources to either 1 or 2, randomly
  if food-source-number > 0
   [ set foodp random 9 + 1 ] ;;change to random for amount of food per block
   
   if foodp > 0       ;; Color food
    [ if food-source-number = 1 [ set pcolor cyan ]
      if food-source-number = 2 [ set pcolor sky  ]
      if food-source-number = 3 [ set pcolor blue ] 
      ;;if food-source-number = 4 [ set pcolor red  ]
    ]
  ]
  
  
end


to go
  ask turtles[
    run word breed "-task"   ;;run the state machine based on the breed of ant
  ]
  tick
  
  do-plots
  
  random-midden
  
  if ticks > 3000
  [
    setup
  ]
  
end


to do-plots
  set-current-plot "Counts"
  set-current-plot-pen "Foragers"
  plot count foragers
  set-current-plot-pen "Inactive Ants"
  plot count inactives
  set-current-plot-pen "NestPatrollers"
  plot count nest-patrollers
  set-current-plot-pen "Trail Patrollers"
  plot count trail-patrollers with [not hidden?]
  set-current-plot-pen "Midden Workers"
  plot count middens
  
end

to random-midden
  if (random ticks) mod 311 = 0
  [
   setup-antifood 
  ]
  
end



to flip
  ask turtles [
  ifelse hidden?
  [
    set hidden? false
  ]
  
  [
    set hidden? true 
  ]
  ]
  
end
  


@#$#@#$#@
GRAPHICS-WINDOW
210
10
649
470
16
16
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks

BUTTON
16
25
89
58
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
98
24
161
57
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

INPUTBOX
13
69
174
129
population
1000
1
0
Number

INPUTBOX
14
142
175
202
amount-midden
3
1
0
Number

MONITOR
20
207
93
252
Nest Patrollers
count nest-patrollers
17
1
11

MONITOR
21
259
93
304
Foragers
count foragers
17
1
11

MONITOR
100
207
171
252
Trail Patrollers
count trail-patrollers with [not hidden?]
17
1
11

MONITOR
101
260
173
305
Midden
count middens
17
1
11

SLIDER
12
312
184
345
thold
thold
20
40
34
1
1
NIL
HORIZONTAL

PLOT
4
351
204
501
Counts
Time 
Number of Ants
0.0
10.0
0.0
10.0
true
false
PENS
"Foragers" 1.0 0 -14835848 true
"NestPatrollers" 1.0 0 -2674135 true
"Inactive Ants" 1.0 0 -13345367 true
"Trail Patrollers" 1.0 0 -1184463 true
"Midden Workers" 1.0 0 -10899396 true

@#$#@#$#@
WHAT IS IT?
-----------

An agent based model of the Harvester Ant. Roles include nest partoller, trail patroller, midden worker, forager, inactive ants. Ants accomplish goas and interact in an antychamber.


HOW IT WORKS
------------

Nest patrollers are present first to make sure the environment is safe. Then interact with the ants in the antychamber where the trail patrollers and midden workers then start their task. Midden workers remove items to a given radius around the nest. trail patrollers report the direction of the food. The trail patrollers interact and notify the foragers of where the food is.


HOW TO USE IT
-------------

Simple setup and run with monitors keeping trak of the number of each breed.


THINGS TO NOTICE
----------------

Given different threasholds on the interaction rate significantly alters the number of foragers.


THINGS TO TRY
-------------

Change the amount of midden or the size of the population.


EXTENDING THE MODEL
-------------------

To exetend this model incorperate the concept of foraging over multiple days. 


NETLOGO FEATURES
----------------

Use of nearest neighbor to find the ant to interact with. Using links to communicate information. Using the hidden? attribute to simulate the inside and outside of the nest.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
Fall and Spring CU Boulder APPM 4950 class. Author: Max Bohning.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

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

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
