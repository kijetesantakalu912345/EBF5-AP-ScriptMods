package archipelago
{
    public class ItemHandler
    {
        public var apItem:Item;
        public var receivedItemsIndex:Array = [];
        public var otherWorldItems:Array = []; // Keep definitions for new items in here (eg. Ultima Weapon)

        public function ItemHandler()
        {
            this.apItem = Items.APiconEbf5SVG;
        }

        // Create Objects with details of items from other worlds so the player can view what they're sending.
        public function PopulateOtherWorldItemList()
        {
            // Example new item creation
            otherWorldItems.push(new Item({
                "name": 'Ultima Weapon',
                "description": 'an Item from Another world...',
                "SID":"ApId1232",
                "type":Item.MISC,
                "target":Target.AUTO,
                "icon": apItem.icon
            }))
        }

        public function ReceiveArchipelagoItem()
        {
            // Requirements:
            // - Incoming items do NOT require sending player or location data
            // - An index of received items must be stored, so that it keeps in sync

            // Check if item in ReceivedItemIndex, if true skip, otherwise...
            //      Add Item to Inventory
            //      Add Item to ReceivedItemIndex

            return;
        }

        public function SendArchipelagoItem()
        {
            return;
        }
    }
}