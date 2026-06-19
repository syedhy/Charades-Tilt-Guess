import json

with open("CharadesTiltGuess/Resources/DefaultDecks.json", "r") as f:
    decks = json.load(f)

for deck in decks:
    if deck.get("color") == "slate":
        deck["color"] = "gray"

with open("CharadesTiltGuess/Resources/DefaultDecks.json", "w") as f:
    json.dump(decks, f, indent=2)

print("Fixed colors in JSON.")
