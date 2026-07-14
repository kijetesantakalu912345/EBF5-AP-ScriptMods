package archipelago
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
    import flash.events.*;

    // THIS UI NEEDS MORE POLISH BEFORE IT SHOULD SHIP!

    // KNOWN BUG: you can enter a ton of characters into the address field and the text will just spill out onto the rest of the screen.
    public class APConnectUI extends flash.display.Sprite implements IOnConnectHandler, IOnNotConnectedHandler
    {
        public static var CONNECT_TEXT:String = "Connect";
        public static var TRYING_TO_CONNECT_TEXT:String = "Trying to connect..."
        public static var DISCONNECT_TEXT:String = "Disconnect";

        public var linkedApSocket:APSocket;
        private var titleText:TextField;
        private var addressField:TextField;
        private var connectionButton:APTextButton; // contextually "Connect"/"Disconnect"/'waiting to connect'
        //private var hasInitializedPosition:Boolean = false;

        public function APConnectUI(apSocket:APSocket)
        {
            Main.debugLogAP.print("creating APConnectUI.");
            super();
            //addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            linkedApSocket = apSocket;
            linkedApSocket.onConnectCallbackHandlers.push(this);
            linkedApSocket.onNotconnectedCallbackHandlers.push(this);
            var textFormat:TextFormat = new TextFormat();
            textFormat.font = "Verdana";
            textFormat.size = 24;
            textFormat.color = 0xFFFFFF;
            titleText = new TextField();
            titleText.autoSize = TextFieldAutoSize.LEFT;
            titleText.setTextFormat(textFormat);
            titleText.defaultTextFormat = textFormat;
            titleText.selectable = false;
            titleText.appendText("AP Client Connection");

            textFormat.size = 18;
            addressField = new TextField();
            addressField.autoSize = TextFieldAutoSize.LEFT;
            addressField.type = TextFieldType.INPUT;
            addressField.setTextFormat(textFormat);
            addressField.defaultTextFormat = textFormat;
            addressField.appendText("localhost:4999"); // 4999 is just some random port number that according to wikipedia's list of TCP and UDP port numbers doesn't seem to have much usage.
            addressField.y += titleText.textHeight + 4; // +x pixels of padding
            
            var width:int = titleText.textWidth + 6; // +x pixels of padding

            this.addChild(titleText);
            this.addChild(addressField);
            connectionButton = new APTextButton(0, 0, width, -1, CONNECT_TEXT, 16, 4);
            connectionButton.y = this.height;
            connectionButton.btn.addEventListener(MouseEvent.CLICK, onConnectionButtonPressed);
            this.addChild(connectionButton);

            this.graphics.beginFill(0x000000, 0.7);
            this.graphics.drawRect(0, 0, width, this.height);
            this.graphics.endFill();
            this.x = 0;
            this.y = 310;
            Main.debugLogAP.print("APConnectUI should exist.");
        }

        public function onConnectionButtonPressed(e:MouseEvent):void
        {
            Main.debugLogAP.print("(dis)connect button pressed");
            if (!linkedApSocket.connected)
            {
                Main.debugLogAP.print("trying to connect.");
                // removing trailing or beginning whitespace would also be a good idea. though again that's polish.
                var splitString:Array = addressField.text.split(":");
                if (splitString.length != 2 || (splitString.length == 2 && (splitString[0] == "" || splitString[1] == "")))
                {
                    // we probably need to add a "status" textfield to this UI, or at least a place to specify messages like this other than the debug log.
                    // that's polish though, right now I just want to get it working.
                    Main.debugLogAP.print("Enter an address in the format of `address:port`.");
                    return;
                }
                var host:String = splitString[0];
                var port:int = parseInt(splitString[1]);
                Main.debugLogAP.print("host: " + host + " | port: " + port.toString())
                if (port < 1 || port > 65535)
                {
                    Main.debugLogAP.print("Invalid port! Must be a positive integer between 1 and 65535.")
                    return;
                }
                if (port < 1024)
                {
                    Main.debugLogAP.print("Warning: flash player doesn't like using port numbers below 1024. This port might not work.");
                }
                // only do this if the user actually entered a (probably) valid address.
                connectionButton.disableClick(); // prevent the user from pressing connect again before the timeout expires.
                connectionButton.setText(TRYING_TO_CONNECT_TEXT);
                Main.apSocket.connect(host, port);
                Main.apSocket.sendUTF8("test message sent by the game to the client. here's some unicode characters: π😀🏴‍☠️—");
            }
            else
            {
                Main.debugLogAP.print("trying to disconnect.");
                linkedApSocket.close();
            }
        }

        public function onConnect():void
        {
            connectionButton.setText(DISCONNECT_TEXT);
            connectionButton.enableClick();
        }

        public function onNotConnected():void
        {
            connectionButton.setText(CONNECT_TEXT);
            connectionButton.enableClick();
        }
    }
}