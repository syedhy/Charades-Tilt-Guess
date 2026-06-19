import json

with open('CharadesTiltGuess/Resources/DefaultDecks.json', 'r') as f:
    decks = json.load(f)

# find and remove the existing kids deck
decks = [d for d in decks if d['id'] != 'default-kids']

new_decks = [
  {
    "id": "kids-animals",
    "name": "Animals (Pictures)",
    "description": "Friendly animal pictures for kids.",
    "cards": [
      { "id": "ka-01", "text": "Whale", "imageName": "kids_whale" },
      { "id": "ka-02", "text": "Gorilla", "imageName": "kids_gorilla" },
      { "id": "ka-03", "text": "Rooster", "imageName": "kids_rooster" },
      { "id": "ka-04", "text": "Dinosaur" },
      { "id": "ka-05", "text": "Elephant" }
    ],
    "type": "default",
    "color": "mint",
    "symbolName": "pawprint.fill"
  },
  {
    "id": "kids-cartoons",
    "name": "Cartoons (Pictures)",
    "description": "Famous cartoon characters.",
    "cards": [
      { "id": "kc-01", "text": "SpongeBob", "imageName": "kids_spongebob" },
      { "id": "kc-02", "text": "Mickey Mouse" },
      { "id": "kc-03", "text": "Peppa Pig" }
    ],
    "type": "default",
    "color": "yellow",
    "symbolName": "tv.fill"
  }
]

decks.extend(new_decks)

with open('CharadesTiltGuess/Resources/DefaultDecks.json', 'w') as f:
    json.dump(decks, f, indent=2)

