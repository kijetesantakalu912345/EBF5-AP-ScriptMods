package archipelago
{
   import flash.net.Socket;
   import flash.errors.*;
   import flash.events.*;
   import archipelago.APDebugLogger;
   import flash.utils.ByteArray;

   public class APSocket extends Socket implements IUTF8MessageRecivedHandler
   {
      /**
       * Called when we finish receiving a message, like after fully reconstructing an archipelago protocol packet that may have been cut into many TCP packets.
       */
      public var onUTF8MessageReceivedCallbackHandler:IUTF8MessageRecivedHandler;

      public var isWaitingForNewMessage:Boolean = true;
      public var currentMessageFinalLength:uint = 0;
      // i want to just use a string but then i'd need to copy it to a byte array and waste a ton of memory every time which would be slow
      public var currentReceivedMessageFragments:ByteArray = new ByteArray();

      // 4999 is just some random port number that according to wikipedia's list of TCP and UDP port numbers doesn't seem to have much usage.
      public function APSocket(host:String = null, port:uint = 4999)
      {
         super();
         // this is just for testing and should probably be removed later. maybe i'll call a function that calls the callback and logs the text to the debug log.
         onUTF8MessageReceivedCallbackHandler = this;
         addEventListener(Event.CLOSE, closeHandler);
         addEventListener(Event.CONNECT, connectHandler);
         // addEventListener(IOErrorEvent.IO_ERROR, );
         addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
         addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
      }

      public function onUTF8MessageReceived(receivedText:String):void
      {
         Main.debugLogAP.print("received text: \"" + receivedText + "\"");
      }

      private function closeHandler(event:Event):void
      {
         Main.debugLogAP.print("socket disconnected.");
      }

      private function connectHandler(event:Event):void
      {
         Main.debugLogAP.print("socket connected!");
      }

      // in order to be allowed to use sockets in local flash player the SWF's file path must be trusted in the global settings, so yeah we'll want to tell the user
      // how to possibly work around this error if they encounter it. (in AIR it's way less restrictive and seems to just work).
      // though honestly this is probably more helpful for us so that we get in game error message popups with debug flash player while actually being allowed to use sockets.
      // https://airsdk.dev/reference/actionscript/3.0/flash/net/Socket.html
      // also for some reason it takes like a good 10 seconds for this to show up in the log after the error happens which is annoying.
      private function securityErrorHandler(event:SecurityErrorEvent):void
      {
         Main.debugLogAP.print("Can't connect to Archipelago client. Flash Player refused to allow us to connect and threw a security error.");
         Main.debugLogAP.print("How to fix it:");

         Main.debugLogAP.print("If you're running EBF5 locally via Flash Player, go into Global Settings > Advanced and add this SWF file as a trusted location.");
         // ^ we might actually just want to use a JPEXS patch for this, i'll look into it later.

         Main.debugLogAP.print("If you're running EBF5 via Ruffle, then allow it to connect next time when you get the pop up from Ruffle.");
         Main.debugLogAP.print("If you're running EBF5 via Steam with Epic Battle Fantasy 5.exe, then this is a bug on the mod's end.");
         // this would probably be easy to implement but testing it would probably be a lot of set up work and this is an extremely unlikely case because this is the
         // paid version of the game.
         // also just allowing it access to any localhost port could legitimately be a security issue if the swf was served from a website
         // and currently idk what port we'll use for game to client communication.
         Main.debugLogAP.print("If you're running EBF5 in a browser, then unfortunately playing the mod this way is unimplemented. You'll have to run it in one of the " +
               "ways listed above.");
         Main.debugLogAP.print("Error message: " + event.text);
      }

      public function sendUTF8(text:String):void
      {
         // we need to get the length in bytes, because unicode.
         // also because archipelago uses websockets which can transfer a ton of data per websocket frame, 2 bytes feels too small (65k = 0.65 MB)
         // and while a 3 byte length would be good (up to ~16.7 MB frames) there's no easy datatype for it, so we're using 4 byte lengths.
         // part of me says that using a 4 byte length is gonna be super overkill because we're going over TCP, but the game and client are almost certainly gonna be
         // connected via localhost on the same machine, so massive packets are probably actually faster in this context.

         // after looking into it, it looks like the python commonclient (no specific reason for that example, it just has an easy to see max packet length) throws errors
         // about incoming packet size at 16 MB (probably 16 MB compressed but still), so a max of ~4 gigs (= 2^32-1 bytes) uncompressed on our end will be fine.

         // 4 byte length, and then raw UTF-8.
         var byteArr:ByteArray = new ByteArray();
         byteArr.writeUTFBytes(text);
         var length:uint = byteArr.length;
         writeUnsignedInt(length);
         writeUTFBytes(text);
         flush();
      }

      private function handleSocketData(event:ProgressEvent):void
      {
         while (bytesAvailable > 0)
         {
            if (isWaitingForNewMessage)
            {
               if (bytesAvailable < 4)
               {
                  return;
               }
               else
               {
                  currentMessageFinalLength = readUnsignedInt();

               }
            }
            var bytesToRead:uint = 0;
            if (bytesAvailable + currentReceivedMessageFragments.length >= currentMessageFinalLength)
            {
               bytesToRead = currentMessageFinalLength - currentReceivedMessageFragments.length;
               isWaitingForNewMessage = true;
            }
            else
            {
               bytesToRead = bytesAvailable;
            }
            currentReceivedMessageFragments.writeUTFBytes(readUTFBytes(bytesToRead)); // this feels really dumb but i need ByteArray so i get the byte length, because unicode
            if (isWaitingForNewMessage)
            {
               if (onUTF8MessageReceivedCallbackHandler != null && onUTF8MessageReceivedCallbackHandler.onUTF8MessageReceived != null)
               {
                  currentReceivedMessageFragments.position = 0;
                  onUTF8MessageReceivedCallbackHandler.onUTF8MessageReceived(currentReceivedMessageFragments.readUTFBytes(currentReceivedMessageFragments.length));
               }
            }
         }
      }
   }
}