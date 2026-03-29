package archipelago
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.events.Event;
    // really basic on screen logger meant for quick and dirty debug stuff. i just want a way to get easy visual feedback because we can't (easily) view the trace() output.
    public class APDebugLogger extends flash.display.Sprite
    {
        public var textField:TextField;

        public function APDebugLogger()
        {
            super()
        }

        public function initTextField():void
        {
            textField = new TextField();
            textField.setTextFormat(GUI.globalTextFormat);
            textField.backgroundColor = 0x77000000;
            addChild(textField);
        }

        public function print(text:String):void
        {
            this.textField.text += text + "\n"
        }
    }
}