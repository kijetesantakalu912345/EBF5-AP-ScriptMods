package archipelago
{
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldType;
    import flash.events.*;
    import flash.geom.Rectangle;

    /** A single line editable textField that scrolls left/right after a max width.
     * 
     * Use `updateScrollRectHeight()` when changing any property that could change the textField's height. Use `setMaxViewWidth()` to change the max width.
     * `setMaxViewWidth()` must be used at least once after the first time the text is set.
     * `setMaxViewWidth()` calls `updateScrollRectHeight()`.
     */
    public class APLineEdit extends flash.text.TextField
    {
        public var scrollDeltaMultiplier:uint = 2;
        //private var maxViewWidth:uint;

        public function APLineEdit()
        {
            super();
            this.type = TextFieldType.INPUT;
            // THINGS TO LISTEN FOR:
            // - mousewheel scrolling up and down, maybe up/down arrow keys to jump to the far left or far right (directly scroll up/down)
            // - left/right arrow keys, and mouse clicks (use the caret position and selectionBeginIndex/selectionEndIndex to decide if we should scroll)
            // ==> for selectionBeginIndex/selectionEndIndex I might need to store what they were previously and use the change to detect what direction the user
            //     is selecting in. ideally the caret position could just tell me that information depending on which end it is at but IDK if that works. I'll have to test.
            this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelScroll);
            //this.addEventListener(Event.CHANGE, onChange);
            // Main.debugLogAP.print("caretIndex: " + caretIndex.toString());
            // Main.debugLogAP.print("selectionBeginIndex: " + selectionBeginIndex.toString());
            // Main.debugLogAP.print("selectionEndIndex: " + selectionEndIndex.toString());
            Main.debugLogAP.print("APLineEdit() finished.")
        }
        
        // NOTE FOR SCROLLING: you can't directly assign the x or y or width or height components of scrollRect.
        // scrollRect always needs to be directly set to a `Rectangle` object.
        // also note that increaseing the x value causes the scrolling to move in the opposite direction than you'd normally expect higher x values to go in, in flash.

        // public function onChange(e:TextEvent):void
        // {
        //     if (scrollRect == null)
        //     {
        //         return;
        //     }
        //     if (text.length == 0)
        //     {
        //         scrollRect.x = 0;
        //         return;
        //     }
        //     // needs to run after the length == 0 check.
        //     if (caretIndex > text.length - 1)
        //     {
        //         return;
        //     }
        //     var charRect:Rectangle = getCharBoundaries(caretIndex);
        //     var farX:Number = charRect.x + charRect.width;
        //     if (farX > this.x - scrollRect.x + scrollRect.width) // remember that scrollRect is effectively sign reversed from flash's normal positioning.
        //     {
        //         scrollRect.x += charRect.width
        //     }
        // }

        public function onMouseWheelScroll(e:MouseEvent):void
        {
            if (scrollRect == null)
            {
                return;
            }
            Main.debugLogAP.print("attempting to scroll.")
            var newRect:Rectangle = scrollRect;
            var scrollPx:int = e.delta * scrollDeltaMultiplier;
            newRect.x += scrollPx;
            var lineWidth:Number = getLineMetrics(0).width + 12; // yup this needs 12 pixels of padding.
            Main.debugLogAP.print("newRect.x: " + newRect.x.toString() + " scrollRect.x: " + scrollRect.x.toString() + " scrollPx: " + scrollPx.toString() + " newRect.width: " + newRect.width.toString() + " lineWidth: " + lineWidth.toString());
            if (lineWidth - newRect.x <= newRect.width)
            {
                newRect.x = lineWidth - newRect.width;
                Main.debugLogAP.print("scrollPx > 0 && lineWidth - newRect.x <= newRect.width. newRect.x: " + newRect.x.toString())
            }
            if (newRect.x < 0)
            {
                newRect.x = 0;
                Main.debugLogAP.print("scrollPx < 0 && newRect.x < 0. newRect.x:" + newRect.x.toString())
            }
            scrollRect = newRect;
            Main.debugLogAP.print("scrollRect.x: " + scrollRect.x.toString())
        }

        public function updateScrollRectHeight():void
        {
            var maxHeight:Number = this.height;
            if (border)
            {
                maxHeight += 1;
            }
            var newRect:Rectangle = scrollRect;
            newRect.height = maxHeight;
            scrollRect = newRect;
            //scrollRect = new Rectangle(0, 0, maxViewWidth, maxHeight);
            Main.debugLogAP.print(scrollRect.toString())
        }

        public function setMaxViewWidth(maxViewWidth_:uint):void
        {
            //maxViewWidth = maxViewWidth_;
            if (scrollRect == null)
            {
                scrollRect = new Rectangle(0, 0, 0, 0);
            }
            var newRect:Rectangle = scrollRect;
            newRect.width = maxViewWidth_;
            scrollRect = newRect;
            updateScrollRectHeight();
        }

        public function getMaxViewWidth():uint
        {
            return scrollRect.width;
        }
    }
}