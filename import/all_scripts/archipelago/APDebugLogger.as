package archipelago
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   // really basic on screen logger meant for quick and dirty debug stuff. i just want a way to get easy visual feedback because we can't (easily) view the trace() output.
   public class APDebugLogger extends flash.display.Sprite
   {
      public var textField:TextField;
      private var textFormat:TextFormat;

      public function APDebugLogger()
      {
         super();
      }

      public function initTextField():void
      {
         textField = new TextField();
         textFormat = new TextFormat();
         textFormat.font = "Verdana Bold";
         textFormat.color = 0xFFFFFF;
         textFormat.size = 12;
         textField.background = false;
         this.mouseChildren = false;
         this.mouseEnabled = false;
         this.graphics.beginFill(0x000000, 0.5);
         this.graphics.drawRect(0, 0, 500, 300);
         this.graphics.endFill();
         textField.mouseEnabled = false; // maybe i'll add a toggle for this setting/showing this log in the first place but for now you'll have to deal with no copy pasting.
         textField.selectable = false;
         mouseChildren = false;
         textField.width = 500;
         textField.height = 300;
         textField.x = 0;
         textField.y = 0;
         textField.wordWrap = true;
         textField.setTextFormat(textFormat);
         textField.defaultTextFormat = textFormat;
         addChild(textField);
      }

      public function print(text:String):void
      {
         this.textField.text += text + "\n";
      }
   }
}