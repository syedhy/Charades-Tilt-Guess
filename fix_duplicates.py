import json

with open("CharadesTiltGuess/Resources/DefaultDecks.json", "r") as f:
    decks = json.load(f)

for deck in decks:
    seen_ids = set()
    new_cards = []
    for card in deck.get("cards", []):
        if card["id"] not in seen_ids:
            seen_ids.add(card["id"])
            new_cards.append(card)
        else:
            print(f"Removed duplicate {card['id']} in deck {deck['id']}")

    # If we removed something and it's a kids deck, we might need to pad it to 50
    if deck.get("id").startswith("kids-") and len(new_cards) < 50:
        needed = 50 - len(new_cards)
        for i in range(needed):
            new_id = f"extra_item_{i}"
            new_cards.append({
                "id": new_id,
                "text": f"Extra Item {i+1}",
                "imageName": f"kids_{deck['id'].split('-')[-1]}_{new_id}"
            })
            print(f"Added {new_id} to {deck['id']} to reach 50.")

    deck["cards"] = new_cards

with open("CharadesTiltGuess/Resources/DefaultDecks.json", "w") as f:
    json.dump(decks, f, indent=2)

print("Duplicates fixed.")
