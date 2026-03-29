package archipelago
{
    import flash.net.Socket;
    import flash.errors.*;
    import flash.events.*;

    public class APSocket extends Socket
    {
        
        // 4999 is just some random port number that according to wikipedia's list of TCP and UDP port numbers doesn't seem to have much usage.
        public function APSocket(host:String = null, port:uint = 4999)
        {
            super();
            //addEventListener(Event.CLOSE, closeHandler);
            //addEventListener(Event.CONNECT, );
            //addEventListener(IOErrorEvent.IO_ERROR, );
            //addEventListener(SecurityErrorEvent.SECURITY_ERROR, );
            //addEventListener(ProgressEvent.SOCKET_DATA, );
        }

        private function closeHandler(event:Event):void
        {
            // hmmm. we don't actually have a super easy way to log stuff in a place we can see. I guess I could make a custom on screen text field thing for it?
            // as a basic placeholder i could probably use debug flashplayer and just throw errors at the end of functions like this.
            trace("closed. event: " + event) 

        }

    }
}