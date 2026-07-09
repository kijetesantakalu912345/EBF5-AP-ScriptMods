package archipelago
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;
    import flash.events.*;

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
            addressField = new TextField();
            addressField.autoSize = TextFieldAutoSize.LEFT;
            addressField.type = TextFieldType.INPUT;
            addressField.setTextFormat(textFormat);
            addressField.defaultTextFormat = textFormat;
            addressField.appendText("localhost:4999");
            
            var width:int = titleText.textWidth + 6; // +x pixels of padding
            var height:int = 200;
            this.graphics.beginFill(0x000000, 0.7);
            this.graphics.drawRect(0, 0, width, height);
            this.graphics.endFill();
            connectionButton = new APTextButton(0, 0, width, -1, CONNECT_TEXT, 16, 40);
            connectionButton.y = height - connectionButton.height;
            connectionButton.btn.addEventListener(MouseEvent.CLICK, onConnectionButtonPressed);
            this.addChild(titleText);
            this.addChild(connectionButton);
            //this.width = width;
            //this.height = height;
            // I tried to put this in the top right corner of the screen but for some reason all of the ways to get the sprite's this.width are actually liars.
            // So instead of wasting more time trying to do that I'm just putting it under the APDebugLogger.
            this.x = 0;
            this.y = 310;
            Main.debugLogAP.print("width shenanigans. text: " + titleText.textWidth.toString() + " this.width: " + this.width.toString() + " calc: " + (Game.root.stage.width - this.width).toString() + "calc2: " + (Game.root.stage.width - titleText.textWidth).toString())
            Main.debugLogAP.print(this.x.toString() + " " + this.y.toString());
            Main.debugLogAP.print("APConnectUI should exist.");
        }

        public function onConnectionButtonPressed(e:MouseEvent):void
        {
            Main.debugLogAP.print("(dis)connect button pressed");
            if (!linkedApSocket.connected)
            {
                connectionButton.disableClick(); // prevent the user from pressing connect again before the timeout expires.
                connectionButton.setText(TRYING_TO_CONNECT_TEXT);
                Main.debugLogAP.print("trying to connect.");
                // 4999 is just some random port number that according to wikipedia's list of TCP and UDP port numbers doesn't seem to have much usage.
                Main.apSocket.connect("localhost", 4999);
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