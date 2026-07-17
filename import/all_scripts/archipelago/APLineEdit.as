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
    public class APLineEdit extends flash.text.TextField //implements IMainLoopHandler
    {
        public var scrollDeltaMultiplier:uint = 2;
        private var oldCaretIndex:int = 0;
        private var oldTextLength:uint = 0;
        private var rightEdgeBorderPadding:int = 12;
        //private var maxViewWidth:uint;

        public function APLineEdit(borderPaddingPx:int = 12)
        {
            super();
            rightEdgeBorderPadding = borderPaddingPx;
            this.type = TextFieldType.INPUT;
            // THINGS TO LISTEN FOR:
            // - mousewheel scrolling up and down, maybe up/down arrow keys to jump to the far left or far right (directly scroll up/down)
            // - left/right arrow keys, and mouse clicks (use the caret position and selectionBeginIndex/selectionEndIndex to decide if we should scroll)
            // ==> for selectionBeginIndex/selectionEndIndex I might need to store what they were previously and use the change to detect what direction the user
            //     is selecting in. ideally the caret position could just tell me that information depending on which end it is at but IDK if that works. I'll have to test.
            this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheelScroll);
            //this.addEventListener(Event.CHANGE, onCaretPositionPoll);
            //this.addEventListener(KeyboardEvent.KEY_DOWN, onCaretPositionPoll);
            // we need to detect text input and caret position changes (there are no caret events unfortunately) after the textfield has been changed.
            this.addEventListener(Event.EXIT_FRAME, onCaretPositionPoll);
            Main.debugLogAP.print("APLineEdit() finished.");
        }
        
        // NOTE FOR SCROLLING: you can't directly assign the properties of scrollRect. scrollRect always needs to be directly set to a `Rectangle` object.

        public function onCaretPositionPoll(e:Event):void
        {
            if (scrollRect == null || (caretIndex == oldCaretIndex && text.length == oldTextLength))
            {
                return;
            }
            if (text.length == 0)
            {
                oldTextLength = text.length;
                scrollRect = scrollToStart();
                return;
            }

            var newRect:Rectangle = scrollRect;
            var charRect:Rectangle = null;
            var farX:Number = null;

            if (caretIndex <= text.length - 1)
            {
                charRect = getCharBoundaries(caretIndex);
                farX = charRect.x + charRect.width;

                Main.debugLogAP.print("farX: " + farX.toString() + " charRect.x: " + charRect.x.toString() + " charRect.width: " + charRect.width.toString() + " this.x: " + this.x + " newRect.x: " + newRect.x.toString() + " newRect.width: " + newRect.width.toString()
                + " newRect.x + newRect.width: " + (newRect.x + newRect.width).toString())
            }

            if (!(caretIndex == 0 || caretIndex == text.length)) // if the caret is not at the very start or very end of the text.
            {
                if (farX > newRect.x + newRect.width)
                {
                    Main.debugLogAP.print("farX > newRect.x + newRect.width");
                    newRect.x += charRect.width;
                }
                if (charRect.x < newRect.x)
                {
                    Main.debugLogAP.print("farX < newRect.x");
                    newRect.x = charRect.x;
                }
                // checking again to see if we need to jump to see the character after scrolling by the character width feels a lot nicer for text input.
                if (farX > newRect.x + newRect.width)
                {
                    Main.debugLogAP.print("farX - (newRect.x + newRect.width): " + (farX - newRect.x + newRect.width).toString() + " farX:" + farX.toString() + " newRect.x: " + newRect.x.toString() + " newRect.width: " + newRect.width.toString())
                    newRect.x += farX - (newRect.x + newRect.width);
                    /*if (checkCanNotScrollRight(newRect))
                    {
                        newRect = scrollToEnd();
                        Main.debugLogAP.print("scrolling to end.");
                    }*/
                }
                if (charRect.x < newRect.x)
                {
                    newRect.x = charRect.x;
                }
                scrollRect = newRect;
            }
            else
            {
                if (caretIndex == 0)
                {
                    scrollRect = scrollToStart();
                }
                else
                {
                    scrollRect = scrollToEnd();
                }
            }
            oldTextLength = text.length;
            oldCaretIndex = caretIndex;
            //Main.debugLogAP.print("onCaretPositionPoll finished. scrollRect.x: " + scrollRect.x.toString());
        }

        public function onMouseWheelScroll(e:MouseEvent):void
        {
            if (scrollRect == null)
            {
                return;
            }
            var newRect:Rectangle = scrollRect;
            var scrollPx:int = e.delta * scrollDeltaMultiplier;
            newRect.x += scrollPx;
            scrollRect = newRect;

            if (checkCanNotScrollRight(newRect))
            {
                scrollRect = scrollToEnd();
            }
            if (checkCanNotScrollLeft(newRect))
            {
                scrollRect = scrollToStart();
            }
        }

        public function checkCanNotScrollRight(newRect:Rectangle):Boolean
        {
            return getLineWidth() - newRect.x <= newRect.width;
        }

        public function checkCanNotScrollLeft(newRect:Rectangle):Boolean
        {
            return newRect.x < 0;
        }

        public function scrollToEnd():Rectangle
        {
            if (getLineWidth() < scrollRect.width)
            {
                return scrollToStart();
            }
            var newRect:Rectangle = scrollRect;
            newRect.x = getLineWidth() - newRect.width;
            return newRect;
            //scrollRect = newRect;
        }

        public function scrollToStart():Rectangle
        {
            var newRect:Rectangle = scrollRect;
            newRect.x = 0;
            return newRect;
            //scrollRect = newRect;
        }

        public function getLineWidth():int
        {
            return getLineMetrics(0).width + rightEdgeBorderPadding;
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