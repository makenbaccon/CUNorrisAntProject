;; This will be a version of the ants code which is meant to include multiple 
;; colonies

;; The following are the required included files
__includes [ 
   "inactives.nls" 
                   ;; These are the ants which dont do anything in the nest
   "nestpatrolers.nls"
                   ;; These are the ants which see how much stuff is on the nest
   "trailpatrolers.nls" 
                   ;; These are the ants which initially patrol the area controlled
                   ;; by the nest and set the initial foraging paths
   "foragers.nls"  
                   ;; These are the ants which go out and gather food
   "middens.nls"
                   ;; these are the ants which clean up garbage around the nest
]


;; Here I will define what each individual patch owns. This is a way of saying 
;; that these are the properties of each patch
patches-own [ 
  nest-config
  ;; This will be the gradiant moving up towards the ant hill. This will be usefull
  ;; in allowing the ants to find their way back to the nest.
  
  onhill? 
  ;; This will be a variable which states whether the given patch is on the hill
  
  amountfood
  ;; This is the amount of food on a given patch
  
  midden?
  ;; this is whether or not the patch has midden on it
  
  midden-amount
  ;; This is how much midden is on a patch 
]


;; Here I will define some Global variables. These are variables usable by the 
;; entire program which do not depend on the agent excicuting the code. It will  
;; also be where I can possibly change basic variables about the program.
globals[
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;First I will list all of the preset varaibles I will need
  
  numberofcolonies
  ;; This will be the number of distinct colonies we have
  
  scaling-factor
  ;; This is a scaling factor for the size of the world
  
  nestradius
  ;; This is the radius of the ant hill
  
  foodradius
  ;; This is the radius of the pile of food
  
  foodquantity
  ;; This is the quantity of food on each food patch
  
  population
  ;; this is the total population of each
  
  total-food
  ;; this is an array of how much food each colony has gathered
  
  thold
  ;; The threshold over which 
  
  coeff
  ;; This is a coeficent of decay for the scents 
  
  nestcenterx
  nestcentery
  ;; these are the arrays of the x and y coordinates for the different nest centers
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Next these will be the temporary variables I will need
  temp
  xtemp
  ytemp
  vtemp
  rtemp
  ttemp
  
  ;; this will help me keep track of array positions
  iter 
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initial setup functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The setup function is run to initialize the program, it creates the world 
;; and agents
to setup
  
  ;; First if we want to plot things we need to call a default function which
  ;; clears all current plots and resets the tick counter
  __clear-all-and-reset-ticks
  
  ;; Now I need to set my globals
  set-globals
  
  ;; Now we need to call a function we make to setup the window for the world
  ;; and create the appropriate patches
  setup-world
  
  ;; Now we call a function which we made to create all of the agents in the model
  create-agents
  
end


;; Now this function will set all of the globals in the program. Later this can be
;; replaced with buttons but for now I like code
to set-globals
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; first the non arrayed globals;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set scaling-factor 1
  set foodradius 2 
  set foodquantity 3
  set thold 3
  set coeff 5
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; now the arrayed globals;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;; Here I will simply set all of the populations to 1000 and nest radii to 3
  ;; future runns will want to change this to test for impact by colony size
  set population []
  set nestradius []
  set total-food []
  repeat numberofcolonies
  [
    set population lput 10000 population
    set nestradius lput 3 nestradius
    set total-food lput 0 total-food
  ]
  
end


;; Now we will create the function we called earlier in setup which will set the 
;; world size, and create a window large enough to hold it. Keep in mind that the
;; windown created may not fit on your screen so if you want to see all of the 
;; action you will need to to some other resizing.
to setup-world
  
  ;; The default size for a netlogo world is 33X33 (remembering that the center is
  ;; considered the origin (0,0) so the top right corner would be (16,16). The 
  ;; function we are going to use allows us to create asymetrical coordinate 
  ;; systems however we want to keep things simple so we will simply do 16 times
  ;; the scaling factor for each area
  resize-world  (-16 * scaling-factor) (16 * scaling-factor)
   (-16 * scaling-factor) (16 * scaling-factor)
   
  ;; now we will create three patches of food for our ants to find
  setup-food
   
  ;; Now we need to place the nest centers, for now they will be in random locations
  ;; on the map. Change this later if you want to experiment more
  set iter 0
  repeat numberofcolonies
  [
    ;; first pick the coordinates
    set nestcenterx lput random-xcor nestcenterx
    set nestcentery lput random-ycor nestcentery
    
    ;; Now set each nest center to the right color
    ask patch (item iter nestcenterx) (item iter nestcentery)
    [
      set pcolor magenta
    ]
    
    ;; Now I will set the onhill variable to 1 when a patch is on a given hill
    ;; And I will construct the nest-config gradiant
    ;; first I need to initialize the variables
    ask patches
    [
      set onhill? []
      set nest-config []
    ]
    ;; Now I set them to the values I want
    ask patches
    [
      ;; here is the setup of the onhill 
      ifelse (distancexy (item iter nestcenterx) (item iter nestcentery) < nestradius)
        [
          set onhill? lput true onhill?
        ]
        [
          set onhill? lput false onhill?
        ]
      
      ;; Now We will greate a gradiant for the ants to follow to get back to the nest
      ;; note that we are using 200 as a base value so if we make the world really big
      ;; we will need to change this, for our purposes however this will work.
      set nest-config 200 - distancexy (item iter nestcenterx) (item iter nestcentery)
      
      ;; I need to increment iter
      set iter (iter + 1)
    ]
  ]
    
  ;; Now we will set up the midden on the map. The initial generation will simply 
  ;; be whether or not a random number is less than 5 for now I am doing the random
  ;; generation between 0 and 100
  ask patches [ ifelse ( random 100 ) < 5
    [ set midden? 1
      set pcolor white ]
    [ set midden? 0 ]
  ]
   
end


;; Now we need to create the 3 patches of food I am chosing that these not be
;; bordering on the nest however they can be outside the window (so the ants 
;; will not be able to get at it, if this happens boo hoo ants)
to setup-food
  
    ;; Note here that the randoms generated are the distance of the center of the 
  ;; food to the nest mound and the degree value
;  set rtemp ( nestradius + foodradius + 
;    ( random ( 16 * scaling-factor - nestradius - foodradius ) ) )
  set rtemp ( random ( 16 * scaling-factor ) )
  set ttemp 360
  set xtemp ( rtemp * cos ttemp )
  set ytemp ( rtemp * sin ttemp )
  ;; Now we will put food on those patches
  ask patches [ 
    ifelse ( distancexy xtemp ytemp < foodradius ) 
    [ set amountfood 3
      set pcolor cyan ]
    [ set amountfood 0 ]
  ]
  
  ;; repeat with a different color
  set rtemp ( random ( 16 * scaling-factor ) )
  set ttemp 360
  set xtemp ( rtemp * cos ttemp )
  set ytemp ( rtemp * sin ttemp )
  ;; Now we will put food on those patches
  ask patches [ 
    ifelse ( distancexy xtemp ytemp < foodradius ) 
    [ set amountfood 3
      set pcolor sky ]
    [ set amountfood 0 ]
  ]
  
  ;; repeat with a different color
  set rtemp ( random ( 16 * scaling-factor ) )
  set ttemp 360
  set xtemp ( rtemp * cos ttemp )
  set ytemp ( rtemp * sin ttemp )
  ;; Now we will put food on those patches
  ask patches [ 
    ifelse ( distancexy xtemp ytemp < foodradius ) 
    [ set amountfood 3
      set pcolor blue ]
    [ set amountfood 0 ]
  ]
  
end


;; Now we need a function to create all of the ants in our world. we will do this 
;; I will make a function with several helper functions and call them recursively 
;; to create the desired number of each agent
to create-agents
  
  ;; first we want to set the default shape of all agents to the bug setting
  ;; which most closely resembles an ant.
  set-default-shape turtles "bug"
  
  ;; Now I will create the initial agents for each nest
  set iter 0
  repeat numberofcolonies
  [
    ;; This will create the nest patrollers
    create-nest-patrollers ceiling ((item iter population) * 0.015)
    [
      set color red
      set colonynumber iter
    ]
    
    ;; This will create the inactives
    create-inactives ((item iter population) * .1)
    [
      set color blue
      set hidden? true
      set food-direction []
      set colonynumber iter
    ]
    
    set iter iter + 1
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; general run operations ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; First we need to create the general go function. This function tells the program
;; what to do on each tick
to go
  ask turtles [
    run word breed "-task" ;; this causes each agent to run its current breed's
                           ;; task
  ]
  tick
  
  ;; Now we will plot the populations of each breed so we can study how these 
  ;; patterns correspond to research data
  do-plots 
  
  ;; We want to steadily generate more midden in the world to simulate stuff 
  ;; falling around so we create a function to do this
  random-midden
  
  ;; We dont want the program to run indefinently so if we are past 3000 ticks we
  ;; will tell it to stop and reset itself
  if ticks > 3000
  [
    setup
  ]
  
;  ;; We will simulate natural death. To do this we pick a random number between
;  ;; 0 and 50. If this number is 9 then we ask a random turtle if it is outside the
;  ;; nest. If it is, then it dies. We then proceed to report that the patch has a 
;  ;; piece of midden on it for one of the other ants to take it away however we 
;  ;; will color the midden the color of the ant that died
;  if random 50 = 9
;  [
;    ask one-of turtles
;    [
;      if not hidden?
;      [
;        set pcolor color
;        set midden? true
;        set midden-amount 1
;        die
;      ]
;    ]
;  ]
  
end



;; Now we will write a function to plot all of the current populations of each 
;; breed in order to compare our results with those of research liturature.
to do-plots
  
  ;; First we make sure we are plotting in the window called counts (there are no
  ;; others at the moment but this is good practice) 
  set-current-plot "Counts"
  
  ;; Now we will plot the foragers, to do this we first select the pen color for 
  ;; foragers (edited in the settings section of the plot window) then plot the
  ;; count
  set-current-plot-pen "foragers"
  plot count foragers
  
  ;; Now we do the same for nest patrollers
  set-current-plot-pen "NestPatrollers"
  plot count nest-patrollers
  
  ;; Now we do the same for trail patrollers who are not hidden
  set-current-plot-pen "Trail Patrollers"
  plot count trail-patrollers with [not hidden?]
  
  ;; Now we do the same for the midden workers
  set-current-plot-pen "Midden Workers"
  plot count middens
  
end


;; Now we will write the program to generate midden randomly on the screen
to random-midden
  if (random ticks) mod 311 = 0
  [
    set xtemp random-xcor
    set ytemp random-ycor
    ask patches [
      if distancexy xtemp ytemp < 1 [
        set midden? true
        set pcolor white
      ]
    ]
  ]
end


;; Now we will write a function which will allow us to see the inside of the nest
;; this function must my excicuted by the observer and has several known bugs
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; helper functions for the ants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This is a function to help an ant find its nearest neighbor
to find-nearest-neighbor                                      
  set antmates other turtles in-radius 2                     
  set nearest-neighbor min-one-of antmates [distance myself]  
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
30.0

BUTTON
34
49
97
82
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
1

BUTTON
47
129
110
162
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
1

PLOT
53
337
253
487
Counts
Time
Number of ants
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Foragers" 1.0 0 -15575016 true "" "plot count turtles"
"NestPatrollers" 1.0 0 -2674135 true "" ""
"Inactive Ants" 1.0 0 -14070903 true "" ""
"Trail Patrollers" 1.0 0 -1184463 true "" ""
"Midden Workers" 1.0 0 -11085214 true "" ""

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

wolf
false
0
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.1
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
