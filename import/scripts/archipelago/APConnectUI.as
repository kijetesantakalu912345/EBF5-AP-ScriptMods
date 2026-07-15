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
    public class APConnectUI extends flash.display.Sprite implements IOnConnectHandler, IOnNotConnectedHandler
    {
        public static var CONNECT_TEXT:String = "Connect";
        public static var TRYING_TO_CONNECT_TEXT:String = "Trying to connect...";
        public static var DISCONNECT_TEXT:String = "Disconnect";
        public var linkedApSocket:APSocket;
        public var maxInputFieldTextPosition:int;
        private var titleText:TextField;
        private var addressField:TextField;
        private var addressFieldLabel:TextField;
        private var connectionButton:APTextButton; // contextually "Connect"/"Disconnect"/'waiting to connect'
        
        //private var hasInitializedPosition:Boolean = false;

        public function APConnectUI(apSocket:APSocket)
        {
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

            var width:int = 300; //titleText.textWidth + 6; // +x pixels of padding

            textFormat.size = 16;
            var uiLine2Position:int = titleText.textHeight + 4; // +x pixels of padding

            addressFieldLabel = new TextField();
            addressFieldLabel.autoSize = TextFieldAutoSize.LEFT;
            addressFieldLabel.setTextFormat(textFormat);
            addressFieldLabel.defaultTextFormat = textFormat;
            addressFieldLabel.selectable = false;
            addressFieldLabel.appendText("Address:")
            addressFieldLabel.y = uiLine2Position;
            this.addChild(addressFieldLabel);

            addressField = new TextField();
            addressField.autoSize = TextFieldAutoSize.LEFT;
            addressField.type = TextFieldType.INPUT;
            addressField.setTextFormat(textFormat);
            addressField.defaultTextFormat = textFormat;
            addressField.appendText("localhost:4999"); // 4999 is just some random port number that according to wikipedia's list of TCP and UDP port numbers doesn't seem to have much usage.
            addressField.x = addressFieldLabel.width + 8; // +x pixels of padding
            addressField.y = uiLine2Position; // +x pixels of padding
            addressField.border = true;
            addressField.borderColor = 0xFFFFFF;
            addressField.addEventListener(Event.CHANGE, onAddressFieldChangedHandler);
            
            this.addChild(titleText);
            this.addChild(addressField);
            connectionButton = new APTextButton(0, 0, width, -1, CONNECT_TEXT, 16, 4);
            connectionButton.y = this.height + 4; // +x pixels of padding
            connectionButton.btn.addEventListener(MouseEvent.CLICK, onConnectionButtonPressed);
            this.addChild(connectionButton);

            this.graphics.beginFill(0x000000, 0.7);
            this.graphics.drawRect(0, 0, width, this.height);
            this.graphics.endFill();
            this.x = 0;
            this.y = 310;
            maxInputFieldTextPosition = this.width;
        }

        public function onAddressFieldChangedHandler(e:Event):void
        {
            // ALTERNATE IDEA: instead of scrolling the text, just start decreasing the font size when we reach the right edge.
            // then once we get to some minimum font size we stop shrinking and don't allow any more characters to be entered.
            // hm though. ideally I could just get this scrolling working... ughhhhh...
            // maybe I'll just do the scrolling completely manually by directly modifying the textfield's x position
            // and using stuff like caret listeners and mousewheel listeners for scrolling it back.

            // ACTUALLY WAIT THIS SEEMS TO WORK FINE IF I MAKE THE TEXTFIELD RIGHT ALIGNED!
            // keeping it left aligned and making it RTL might also work apparently but I haven't tested that.
            // I'll probably want to add a label saying "address" or whatever next to the addressField so making it RTL should be fine.
            // AI overview also says that just calling validateNow might also work for left aligned text? (double check that if you try implementing it)
            // ehhhh ok but it doesn't work amazingly.

            // Main.debugLogAP.print("onAddressFieldChangedHandler: addressField.width: " + addressField.width.toString() + " this.width: " + this.width.toString()
            // + " addressField.x: " + addressField.x.toString() + " addressField.maxScrollH: "
            // + addressField.maxScrollH.toString() + " maxInputFieldTextPosition: " + maxInputFieldTextPosition.toString());
            // var textRightEdge:Number = addressField.width + addressField.x;
            // if (textRightEdge > maxInputFieldTextPosition)
            // {
            //     //addressField.width = maxInputFieldTextPosition - addressField.x;// use right alignment for this
            //     addressField.scrollH = textRightEdge - maxInputFieldTextPosition;
            //     Main.debugLogAP.print("attempted to scroll. addressField.scrollH: " + addressField.scrollH.toString())
            // }

            // https://stackoverflow.com/a/5097770 (no code just a text reply basically)
            // welp...
            // that post is from 2011 but yeah no I think it's still accurate. guess I just have to make it myself.
            // THINGS TO LISTEN FOR:
            // - mousewheel scrolling up and down, maybe up/down arrow keys to jump to the far left or far right (directly scroll up/down)
            // - left/right arrow keys, and mouse clicks (use the caret position and selectionBeginIndex/selectionEndIndex to decide if we should scroll)
            // ==> for selectionBeginIndex/selectionEndIndex I might need to store what they were previously and use the change to detect what direction the user
            //     9s selecting in. ideally the caret position could just tell me that information depending on which end it is at but IDK if that works. I'll have to test.
            // ok yeah it really shouldn't be that hard to implement. hopefully. I really don't want to delay these PRs even more...
            Main.debugLogAP.print("caretIndex: " + addressField.caretIndex.toString());
            Main.debugLogAP.print("selectionBeginIndex: " + addressField.selectionBeginIndex.toString());
            Main.debugLogAP.print("selectionEndIndex: " + addressField.selectionEndIndex.toString());
        }

        public function onConnectionButtonPressed(e:MouseEvent):void
        {
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