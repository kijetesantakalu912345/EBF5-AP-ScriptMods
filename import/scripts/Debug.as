package
{
   import flash.display.*;
   import flash.geom.*;
   import flash.system.*;
   import flash.utils.*;
   
   public class Debug
   {
      internal static var time:int;
      
      internal static var ti:int;
      
      internal static var fps:int;
      
      internal static var prevTime:int = 0;
      
      public static var allMedals:Boolean = false;
      
      public static var stunFoes:Boolean = false;
      
      public static var instantKills:Boolean = false;
      
      public static var alwaysCounter:Boolean = false;
      
      public static var noLanguage:Boolean = false;
      
      public static var showCutscenes:Boolean = true;
      
      public static var showMinorCutscenes:Boolean = true;
      
      public static var skipIntros:Boolean = true;
      
      public static var bestiary:Boolean = false;
      
      public static var allSummons:Boolean = false;
      
      public static var moreAutoSkills:Boolean = false;
      
      public static var disableMusic:Boolean = false;
      
      public static var skipBattles:Boolean = false;
      
      public static var fullParty:Boolean = false;
      
      public static var allItems:Boolean = false;
      
      public static var allSpells:Boolean = false;
      
      public static var players:int = 1;
      
      public static var randomEquips:Boolean = false;
      
      public static var showStatus:Boolean = false;
      
      public static var showAllQuests:Boolean = false;
      
      public static var infiniteSP:Boolean = false;
      
      public static var wholeMap:Boolean = false;
      
      public static var disableMedals:Boolean = false;
      
      public static var trailerMode:Boolean = false;
      
      public static var expoDemo:Boolean = false;
      
      public static var limitedWaves:int = 7;
      
      public static var dialogueEnabled:Boolean = true;
      
      public static var mappingMode:Boolean = false;
      
      public static var mappingMode2:Boolean = false;
      
      public static var skillSet:int = 0;
      
      public static var weaponSet:int = 0;
      
      public static var boss:int = 1;
      
      public static var bossDemo:Boolean = false;
      
      public static var enableSteamAPI:Boolean = false;
      
      public static var SteamVersion:Boolean = false;
      
      public static var armorGames:Boolean = false;
      
      public static var enableMochi:Boolean = false;
      
      public static var enableKong:Boolean = false;
      
      public static var enablePlaytomic:Boolean = false;
      
      public static var forcePremium:Boolean = false;
      
      public static var noMusic:Boolean = false;
      
      public static var weakFoes:Boolean = false;
      
      public function Debug()
      {
         super();
      }
      
      public static function init() : *
      {
         if(expoDemo)
         {
            stunFoes = false;
            instantKills = false;
            infiniteSP = false;
            dialogueEnabled = true;
            bossDemo = false;
            bestiary = true;
            Options.quality = Options.HIGH;
            Options.titties = false;
            Options.blood = false;
            Options.mature = false;
            Options.screenShake = false;
         }
         var _loc1_:int = 4;
         if(skillSet == 2)
         {
            _loc1_ = 16;
         }
         if(skillSet == 3)
         {
            _loc1_ = 32;
         }
         _loc1_ = 1;
         var _loc2_:int = 1;
         while(_loc2_ < _loc1_)
         {
            Debug.getLevel();
            _loc2_++;
         }
      }
      
      public static function fullScreen() : *
      {
         Game.root.stage.fullScreenSourceRect = new Rectangle(0,0,700,500);
         Game.root.stage.scaleMode = StageScaleMode.SHOW_ALL;
         Game.root.stage.displayState = StageDisplayState.FULL_SCREEN;
         Game.root.stage.scaleMode = StageScaleMode.SHOW_ALL;
      }
      
      internal static function display() : *
      {
         ++ti;
         if(ti % 30 == 0)
         {
            ti = 0;
            time = getTimer();
            fps = 30000 / (time - prevTime) + 1;
            if(fps > 30)
            {
               fps = 30;
            }
            Game.frame.fpsBox.text = "" + fps + " FPS";
            Game.frame.memBox.text = "" + int(System.totalMemory / 1024 / 1024) + " MB";
            prevTime = getTimer();
         }
         if(Game.mode == Game.BATTLE && Boolean(Game.frame))
         {
            Game.frame.busyBox.text = "" + Battle.stage.checkBusy() + " busy";
         }
      }
      
      public static function getWarps() : *
      {
         Maps.warpData = [true,true,true,true,true,true,true,true,true,true,true,true];
      }
      
      public static function incQuest() : *
      {
         ++SaveData.questNo;
         if(SaveData > 3)
         {
            SaveData = 1;
         }
      }
      
      public static function getParty() : *
      {
         if(Players.party.length > 1)
         {
            return;
         }
         Players.getMatt();
         Players.getNatalie();
         Players.getLance();
      }
      
      internal static function debug() : *
      {
         var _loc1_:String = "";
         var _loc2_:uint = 0;
         while(_loc2_ < Battle.stage.numChildren)
         {
            _loc1_ += "\n" + _loc2_ + "\t " + Battle.stage.getChildAt(_loc2_);
            _loc2_++;
         }
         Game.frame.damageBox.text = "STAGE CHILDREN: " + _loc1_;
      }
      
      public static function togglePremium() : *
      {
         Main.hasPremium = !Main.hasPremium;
      }
      
      public static function getMedals() : *
      {
         var _loc1_:Object = null;
         if(Main.hasPremium)
         {
            for each(_loc1_ in Medals.MEDALS_DISPLAY_PREMIUM)
            {
               _loc1_.unlocked = true;
            }
         }
         else
         {
            for each(_loc1_ in Medals.MEDALS_DISPLAY)
            {
               _loc1_.unlocked = true;
            }
         }
      }
      
      public static function getItems() : *
      {
         var _loc1_:Item = null;
         var _loc2_:Equip = null;
         var _loc3_:Card = null;
         for each(_loc1_ in Items.ALL_ITEMS)
         {
            _loc1_.quantity += 10;
         }
         Items.shovel.quantity = 1;
         Items.hammer.quantity = 1;
         Items.axe.quantity = 1;
         Items.bighammer.quantity = 1;
         Items.candle.quantity = 1;
         Items.stepladder.quantity = 1;
         Items.wingedboots.quantity = 1;
         Items.oldboots.quantity = 1;
         Items.leafyboots.quantity = 1;
         Items.magneticboots.quantity = 1;
         Items.rubberboots.quantity = 1;
         Items.spikedboots.quantity = 1;
         Items.thermalboots.quantity = 1;
         Items.raft.quantity = 1;
         for each(_loc2_ in Equips.ALL_EQUIPS)
         {
            _loc2_.owned = true;
         }
         for each(_loc3_ in Cards.ALL_CARDS)
         {
            _loc3_.quantity = 1;
         }
      }
      
      public static function getSummons() : *
      {
         Summons.OWNED_SUMMONS = Summons.ALL_SUMMONS.concat();
      }
      
      public static function getEquips() : *
      {
         var _loc1_:Equip = null;
         for each(_loc1_ in Equips.ALL_EQUIPS)
         {
            _loc1_.level = 1;
            _loc1_.owned = true;
         }
      }
      
      public static function maxSkills() : *
      {
         var _loc2_:Spell = null;
         var _loc1_:Array = Spells.ALL_SPELLS;
         for each(_loc2_ in _loc1_)
         {
            _loc2_.level = _loc2_.MP.length;
         }
      }
      
      public static function maxEquips() : *
      {
         var _loc1_:Equip = null;
         for each(_loc1_ in Equips.ALL_EQUIPS)
         {
            try
            {
               _loc1_.level = 1;
               _loc1_.owned = true;
            }
            catch(e:Error)
            {
            }
         }
         for each(_loc1_ in Equips.FLAIRS)
         {
            try
            {
               _loc1_.level = 1;
               _loc1_.owned = true;
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function getLevel() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in Players.PLAYERS)
         {
            _loc1_.EXP += _loc1_.EXPnext;
            _loc1_.levelUp();
         }
      }
      
      public static function setLevel(param1:int, param2:Player) : *
      {
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            param2.EXP += param2.EXPnext;
            param2.levelUp();
            _loc3_++;
         }
      }
      
      public static function getAP() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in Players.PLAYERS)
         {
            _loc1_.AP += 200000;
         }
      }
      
      public static function getRandomEquip() : *
      {
         var _loc1_:Equip = Equip.getRandomEquip(Equip.HAT_MALE);
         if(_loc1_)
         {
            _loc1_.owned = true;
         }
      }
      
      public static function getAllHats() : *
      {
         var _loc1_:Equip = null;
         var _loc2_:int = 0;
         for each(_loc1_ in Equips.MALE_HATS)
         {
            _loc1_.owned = false;
         }
         _loc2_ = 0;
         while(_loc2_ < 30)
         {
            getRandomEquip();
            _loc2_++;
         }
      }
      
      public static function getMoney() : *
      {
         SaveData.money += 100000;
      }
      
      public static function toggleWalkThrough() : *
      {
         Options.walkThroughWalls = !Options.walkThroughWalls;
      }
      
      public static function toggleBestiary() : *
      {
         bestiary = !bestiary;
      }
      
      public static function toggleSpeed() : *
      {
         if(Game.root.stage.frameRate == 30)
         {
            Game.root.stage.frameRate = 120;
         }
         else
         {
            Game.root.stage.frameRate = 30;
         }
      }
      
      public static function toggleWeakFoes() : *
      {
         weakFoes = !weakFoes;
      }
   }
}

