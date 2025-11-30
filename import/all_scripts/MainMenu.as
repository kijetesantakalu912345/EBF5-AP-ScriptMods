package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.text.TextField;
   import flash.net.Socket;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol2947")]
   public class MainMenu extends MovieClip
   {
      public static const TITLE:String = "title";
      
      public static const CREDITS:String = "credits";
      
      public static const MEDALS:String = "medals";
      
      public static const OPTIONS:String = "options";
      
      public static const NEWGAME:String = "newgame";
      
      public static const CONTINUE:String = "continue";
      
      public static const START:String = "start";
      
      public static var loadFile:int = 0;
      
      public static var gallery:Boolean = false;
      
      public static var title:int = 1;
      
      public var i:int;
      
      public var icons:Array;
      
      public var medal:Object;
      
      public var saves:MovieClip;
      
      public var medalsMenu:MovieClip;
      
      public var links:MovieClip;
      
      public var premiumLabel:MovieClip;
      
      public var blocker:MovieClip;
      
      public var premiumMenu:MovieClip;
      
      public var intro:MovieClip;
      
      public var intro2:MovieClip;
      
      public var destination:String = "";
      
      public var currentMenu:String = "title";
      
      public var previousMenu:String = "";
      
      public var fader:MovieClip;
      
      public var lock:MovieClip;
      
      public var errorLog:TextField;
      
      public var b0:SimpleButton;
      
      public var b1:SimpleButton;
      
      public var b2:SimpleButton;
      
      public var b3:SimpleButton;
      
      public var b4:SimpleButton;
      
      public var b5:SimpleButton;
      
      public var b6:SimpleButton;
      
      public var b7:SimpleButton;
      
      public var b8:SimpleButton;
      
      public var b9:SimpleButton;
      
      public var t0:TextField;
      
      public var t1:TextField;
      
      public var t2:TextField;
      
      public var t3:TextField;
      
      public var t4:TextField;
      
      public var t5:TextField;
      
      public var t6:TextField;
      
      public var t7:TextField;
      
      public var t8:TextField;
      
      public var t9:TextField;

      public var APClientSocket:Socket;
      
      public function MainMenu()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,3,this.frame4,4,this.frame5,5,this.frame6,6,this.frame7);
         Game.mode = Game.MAIN_MENU;
         Global.battleMode = false;
         Global.battleSummit = false;
      }
      
      public function setPremiumButton() : *
      {
         this.b8.visible = false;
         this.blocker.visible = true;
      }
      
      public function fadeTo(param1:String) : *
      {
         this.destination = param1;
         this.fader.gotoAndPlay(2);
      }
      
      public function finishFade() : *
      {
         if(this.destination == "")
         {
            this.fader.gotoAndStop(12);
            return;
         }
         if(this.destination == START)
         {
            this.newGame();
         }
         else
         {
            this.previousMenu = this.currentMenu;
            gotoAndStop(this.destination);
            this.currentMenu = this.destination;
         }
      }
      
      public function newGame() : *
      {
         Game.root.gotoAndStop(20);
         var _loc1_:MapMenu = new MapMenu();
         Game.root.addChild(_loc1_);
         _loc1_.y = 480;
         (Game.root as Main).removeChild((Game.root as Main).mainMenu);
         (Game.root as Main).mainMenu = null;
         Game.maps = _loc1_.maps;
         if(!Options.enableSols && loadFile < 9 && loadFile != 0)
         {
            SaveData.loadGame("" + loadFile);
         }
         else if(loadFile == 8)
         {
            SaveData.loadGame("autosave");
         }
         else if(loadFile != 9)
         {
            if(loadFile != 0)
            {
               SaveData.loadGame("file" + loadFile);
            }
            else
            {
               Main.newGame();
               title = 1;
            }
         }
      }

      public function connectHandler(event:Event)
      {
         trace("connected!");
         writeUTFBytes("if you can see this, the APClientSocket has successfully sent a message to the server! yay!\n");
         flush();
      }
      
      internal function frame1() : *
      {
         stop();
         stage.addEventListener(KeyboardEvent.KEY_DOWN,function(param1:KeyboardEvent:*)
         {
            trace("106 == the multiply key");
            if(param1.keyCode == 106)
            {
               // attempt to connect a client socket to a server socket on localhost
               // OK, in theory now i just need to import this into the game and then test it with a server running on localhost.
               if(APClientSocket.connected)
               {
                  APClientSocket.close();
               }
               APClientSocket.connect("localhost", 8000)
               addEventListener(Event.CONNECT, connectHandler);
            }
         });
         this.b1.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            MainMenu.loadFile = 0;
            fadeTo(MainMenu.START);
         });
         this.b2.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            if(!SaveMenu.meowLoadingComplete && !Options.enableSols)
            {
               fadeTo("loading2");
            }
            else
            {
               fadeTo(MainMenu.CONTINUE);
            }
         });
         this.b3.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.OPTIONS);
         });
         this.b4.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.MEDALS);
         });
         this.b5.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.CREDITS);
         });
         this.b6.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo("exit");
            Options.exitGame();
         });
         this.b7.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo("custom");
         });
         this.t1.mouseEnabled = false;
         this.t2.mouseEnabled = false;
         this.t3.mouseEnabled = false;
         this.t4.mouseEnabled = false;
         this.t5.mouseEnabled = false;
         this.t6.mouseEnabled = false;
         this.t7.mouseEnabled = false;
         this.i = 1;
         while(this.i <= 6)
         {
            Global.translate(this["t" + this.i],"main" + this.i,7);
            ++this.i;
         }
         Global.translate(this["t7"],"main10",7);
         if(!Options.applicationFeatures || !Main.messagesEnabled)
         {
            this.b6.visible = false;
            this.t6.text = "";
         }
         this.fader.stop();
         this.fader.gotoAndStop(12);
      }
      
      internal function frame2() : *
      {
         this.b0.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.TITLE);
         });
         this.t0.mouseEnabled = false;
         Global.translate(this.t0,"main9");
         Global.translate(this.t1,"main5");
         this.intro2.gotoAndStop(132);
      }
      
      internal function frame3() : *
      {
         this.b0.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.TITLE);
         });
         this.t0.mouseEnabled = false;
         Global.translate(this.t0,"main9");
         Global.translate(this.t1,"main3");
         this.intro2.gotoAndStop(132);
      }
      
      internal function frame4() : *
      {
         this.b0.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            if(!SaveMenu.loadingPreview)
            {
               fadeTo(MainMenu.TITLE);
            }
         });
         this.b1.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            if(!SaveMenu.loadingPreview)
            {
               fadeTo("loading");
            }
         });
         if(!Options.applicationFeatures || !Main.messagesEnabled)
         {
            this.b1.visible = false;
         }
         this.t0.mouseEnabled = false;
         Global.translate(this.t0,"main9");
         Global.translate(this.t1,"main2");
         this.intro2.gotoAndStop(132);
      }
      
      internal function frame5() : *
      {
         this.b0.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.TITLE);
         });
         this.t0.mouseEnabled = false;
         Global.translate(this.t0,"main9");
         Global.translate(this.t1,"main4");
         this.icons = [];
         this.medalsMenu.gotoAndStop(2);
         this.medalsMenu.gotoAndStop(1);
         a = 0;
         while(a < (Main.hasPremium ? Medals.MEDALS_DISPLAY_PREMIUM.length : Medals.MEDALS_DISPLAY.length))
         {
            Icon.text = " ";
            this.medal = Main.hasPremium ? Medals.MEDALS_DISPLAY_PREMIUM[a] : Medals.MEDALS_DISPLAY[a];
            if(Options.newgroundsVersion)
            {
               this.icons.push(GUI.createIcon(this.medalsMenu,this.medal,this.medal.unlocked ? function(param1:Object = null):*
               {
                  Medals.resendMedal(param1.MID);
               } : null,true,Icon.MEDAL,0,0,0,-1,a % 19 < 4 ? 13 : 12));
            }
            else
            {
               this.icons.push(GUI.createIcon(this.medalsMenu,this.medal,this.medal.unlocked ? function(param1:Object = null):*
               {
                  Main.sendMessage("unlockMedal",param1.SID);
               } : null,true,Icon.MEDAL,0,0,0,-1,a % 19 < 4 ? 13 : 12));
            }
            ++a;
         }
         Icon.text = "";
         GUI.createIconMatrix(this.icons,19,-310 - 26 - 16,151 - 42,2);
         Medals.resendMedals();
         this.medalsMenu.txt3.text = "" + Medals.countMedals();
         this.intro2.gotoAndStop(132);
      }
      
      internal function frame6() : *
      {
         this.b0.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            fadeTo(MainMenu.TITLE);
         });
         this.t0.mouseEnabled = false;
         Global.translate(this.t0,"main9");
         this.intro2.gotoAndStop(132);
      }
      
      internal function frame7() : *
      {
         this.b0.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            Options.clearCustomOptions();
            fadeTo(MainMenu.TITLE);
            MapMenu.customSource = null;
         });
         this.b1.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            MainMenu.loadFile = 0;
            fadeTo(MainMenu.START);
            MapMenu.customSource = null;
         });
         this.t0.mouseEnabled = false;
         this.t2.mouseEnabled = false;
         Global.translate(this.t0,"customD");
         Global.translate(this.t1,"main10");
         Global.translate(this.t2,"customC");
      }
   }
}

