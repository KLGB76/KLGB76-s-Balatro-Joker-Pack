# KLGB76's Balatro Joker Pack
A Balatro mod adding 14 new Jokers to the game

Those jokers are:

- Truck-kun
- The Keeper
- Infinity Eight
- Jackpot
- Cheval de 3
- Medusa's Glare
- Metronome
- Four-Leaf Clover
- Black Jack
- Anti-Joker
- Clown Car
- Forbidden Summoning
- Restaurant Menu
- Chicken

Known Bug(s):
- All cards randomized by Metronome get debuffed by The Pillar
- The sound of cards being destroyed by Clown Car plays twice

Changelog(s):
- v1.0.1: Added getting_sliced check for Forbidden Summoning and Chicken
- v1.5.0:
  * Added check to Black Jack so it doesn't transform negative cards again
  * Fixed bug where Clown Car would not fully destroy cards, resulting in the game drawing ghost cards
- v1.6.9:
  * Fixed problem where debuffed Jokers would still work
  * Made it so Anti-Joker, Clown Car, Forbidden Summoning and Restaurant Menu don't take debuffed cards into account when checking for their respective associated jokers/editions
  * Made it so Chicken won't add Mult for debuffed Eggs
  * Nerfed Cheval de 3 to only gain X0.25 Mult
- v1.7.0: Fixed bug where cards created by Infinity Eight would never be drawn or counted as added to deck
- v1.7.1: Fixed interaction between Medusa's Glare and Clown Car (without Driver License)
