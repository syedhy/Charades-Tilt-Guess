import json
import uuid
import datetime

# Load the existing decks
with open("CharadesTiltGuess/Resources/DefaultDecks.json", "r") as f:
    decks = json.load(f)

# Remove existing kids decks
decks = [d for d in decks if not d.get("id", "").startswith("kids-")]

animals = ["Dog", "Cat", "Elephant", "Lion", "Tiger", "Bear", "Monkey", "Giraffe", "Zebra", "Penguin", "Dolphin", "Whale", "Shark", "Octopus", "Turtle", "Frog", "Snake", "Crocodile", "Alligator", "Kangaroo", "Koala", "Panda", "Rabbit", "Mouse", "Rat", "Squirrel", "Bat", "Owl", "Eagle", "Hawk", "Parrot", "Peacock", "Flamingo", "Ostrich", "Chicken", "Rooster", "Duck", "Goose", "Swan", "Pig", "Cow", "Horse", "Sheep", "Goat", "Deer", "Moose", "Camel", "Rhino", "Hippo", "Gorilla"]

tools = ["Hammer", "Screwdriver", "Wrench", "Pliers", "Saw", "Drill", "Tape Measure", "Level", "Utility Knife", "Chisel", "Files", "Mallet", "Axe", "Shovel", "Rake", "Hoe", "Trowel", "Pitchfork", "Wheelbarrow", "Ladder", "Flashlight", "Extension Cord", "Toolbox", "Nails", "Screws", "Bolts", "Nuts", "Washers", "Sandpaper", "Paintbrush", "Paint Roller", "Paint Tray", "Drop Cloth", "Ladder", "Bucket", "Sponge", "Broom", "Dustpan", "Mop", "Vacuum", "Iron", "Ironing Board", "Scissors", "Needle", "Thread", "Thimble", "Pins", "Measuring Tape", "Sewing Machine", "Plunger"]

food = ["Apple", "Banana", "Orange", "Grape", "Strawberry", "Watermelon", "Pineapple", "Mango", "Peach", "Cherry", "Pear", "Plum", "Kiwi", "Lemon", "Lime", "Coconut", "Tomato", "Carrot", "Potato", "Onion", "Garlic", "Broccoli", "Cauliflower", "Corn", "Peas", "Green Beans", "Spinach", "Lettuce", "Cucumber", "Bell Pepper", "Mushroom", "Pizza", "Burger", "Hot Dog", "Sandwich", "Taco", "Burrito", "Sushi", "Pasta", "Noodles", "Rice", "Bread", "Cheese", "Egg", "Bacon", "Sausage", "Chicken", "Steak", "Fish", "Shrimp"]

def make_deck(id_suffix, name, color, symbol, words_list):
    cards = []
    for word in words_list:
        word_id = word.lower().replace(" ", "_")
        image_name = f"kids_{id_suffix.split('-')[-1]}_{word_id}"
        cards.append({
            "id": word_id,
            "text": word,
            "imageName": image_name
        })

    return {
        "id": id_suffix,
        "name": name,
        "description": f"A fun deck about {name.lower()} for kids!",
        "cards": cards,
        "type": "default",
        "color": color,
        "symbolName": symbol,
        "createdDate": 1718841600,
        "updatedDate": 1718841600
    }

decks.append(make_deck("kids-animals", "Animals", "mint", "pawprint.fill", animals))
decks.append(make_deck("kids-tools", "Tools", "slate", "hammer.fill", tools))
decks.append(make_deck("kids-food", "Food", "orange", "fork.knife", food))

with open("CharadesTiltGuess/Resources/DefaultDecks.json", "w") as f:
    json.dump(decks, f, indent=2)

print("Created 3 kids decks with 50 words each.")
