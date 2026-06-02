Chunk generation stutter fix for new worlds:

1) Create the world and enter it once.
2) Turn shaders OFF while pre-generating.
3) Run these commands in chat as cheats/LAN operator:
   /chunky radius 1000
   /chunky start

For long playthroughs, use radius 2000 after confirming the world works:
   /chunky radius 2000
   /chunky start

Useful commands:
   /chunky progress
   /chunky pause
   /chunky continue
   /chunky cancel

This does not increase FPS by itself; it moves the heavy first-time terrain/structure generation work to a one-time pre-generation task.
