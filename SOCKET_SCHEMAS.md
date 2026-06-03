# Message Formats
Using JSON as the structure for the messages between the game and AP client.
Each JSON message will have a "type" field which will be used to determine how the message should be handled, and extra fields if needed for that specific message type.
Example message:
```json
{
   "type": "received_items_add",
   "items": [
      {
         "sid": "coffee",
         "count": 5
      }
   ]
}
```

## AP Client to Game Messages

### received_items_reset
Sent by the server to the game to reset the list of received items.
TODO: May need to be expanded to a general reset message for seed data in general.
```json
{
   "type": "received_items_reset"
}
```

### received_items_add
Sent by the server to the game to add one or more items to the list of received items in the game.
Currently supports SIDs for items, equips, spells, summons, and cards.
Count is optional for non-item types and defaults to 1 if not provided.
```json
{
   "type": "received_items_add",
   "items": [
      {
         "sid": "coffee",
         "count": 5
      },
      {
         "sid": "emeraldsmasher"
      },
      {
         "sid": "protect"
      },
      {
         "sid": "BossDevourer"
      }
   ]
}
```

### seed_data
Sent by the server to the game to send the initial seed data for the game.
Currently includes the starting player and starting equipment for each player.
```json
{
   "type": "seed_data",
   "start_player": "natalie",
   "start_equips": {
      "matt": ["poisonfang", "wizardrobe", "knightshelmet"],
      "natalie": ["arctictrident", "rangerskirt", "darkbobble"],
      ...
   }
}
```

### chest_data
Sent by the server to the game to send chest replacement data by chest id as defined in the AP World Locations.py.<br>
For local items, use the `sid` and `count` fields to specify the item.<br>
For remote items, use the `name` and `player` fields to specify the item by the player and item name.<br>
```json
{
   "type": "chest_data",
   "chest_replacements": {
      "152-0-0": {
         "sid": "coffee",
         "count": 5
      },
      "26-1-1": {
         "name": "Double Jump",
         "player": "Mario"
      },
      ...
   }
}
```

Sends a validation message of type "received_item_count_update" with the new count of all received items in game memory if successful.

## Game to AP Client Messages

### received_item_count_update
Sent by the game to the server whenever the count of received items changes.
Used for the server to validate that items were successfully received in the game and to keep an accurate count of how many of each item the player has.
```json
{
   "type": "received_item_count_update",
   "count": 5,
}
```

### collected_items
Sent by the game to the server whenever the player collects items to let the AP client know which locations have been checked.
```json
{
   "type": "collected_items",
   "items": [
      "152-0-0",
      "26-1-1",
      ...
   ]
}
```