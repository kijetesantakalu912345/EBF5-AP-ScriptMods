package archipelago
{
   public class APDataModHandler implements IJSONMessageRecivedHandler
   {
      // Currently controlled by a JSON message but can be changed to update based on other data being tracked
      private var isReady:Boolean = false;

      // Receive JSON types
      private static var READY:String = "ready";

      public function APDataModHandler(apSocket:APSocket)
      {
         apSocket.onJSONMessageReceivedCallbackHandlers.push(this);
      }

      public function onJSONMessageReceived(jsonData:Object):void
      {
         if (!jsonData || !jsonData.type)
         {
            return;
         }

         if (jsonData.type == READY)
         {
            isReady = true;
            return;
         }
      }

      public function supportsJSONType(jsonType:String):Boolean
      {
         return jsonType == READY;
      }

      public function get isReadyToStart():Boolean
      {
         return isReady;
      }
   }
}
