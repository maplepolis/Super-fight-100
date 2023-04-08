# cscb58-final-project

### Title: Super Fight 1000

## Milestone 1: basic graphics [3 marks]
### A. Draw the level

- 8 platforms
- Yellow door
- Red lava

### B. Draw the player character

- White player

### C. Draw at least 2 additional objects that are not platforms other than the player and the level itself (more is allowed!)

- Blue enemy
- Pink health pickups

## Milestone 2: basic controls [5 marks]
### A. Player can move the player character left/right around the platform using the movement keys. Make sure the player cannot move past the edges of the screen!

- AD to move left and right
- Player can not move past edges of the screen

### B. Platform collision and gravity

- the player can stand on a platform but will fall down if moving off a platform. If the player falls down on another platform, they will not go through

### C. Vertical movement: the player can navigate to (then move around on) at least 3 different platforms (including the one they are standing on initially). This can be done by jumping up to platforms and dropping down from them

- W to jump

### D. Collision with objects
- Lose 1 health and sends player back to initial position when player touches enemy or falls to lava
- Win when player touches door
- gain 1 health when player touches health pickup and removes the pickup

### E. Allow restarting the game at any point by pressing the p key on the keyboard


## Milestone 3: additional features and polish

- Health/score [2 marks]: Health points tracked on top right
- Fail condition [1 mark]: When player loses all hearts
- Win condition [1 mark]: When player reaches door
- Moving objects [2 mark]: Moving blue enemy
- Pick-up effects [2 marks]: 
    - health pickup: increases player's health by 1
    - key: necessary to complete the level
    - green pickup: removes obstacle 
- Double jump [1 mark]: the player can double jump