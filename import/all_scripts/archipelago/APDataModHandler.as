package archipelago
{
   public class APDataModHandler implements IJSONMessageRecivedHandler
   {
      // Currently controlled by a JSON message but can be
      // changed to update based on other data being tracked
      private var isReady:Boolean = false;

      // Current seed information
      public var startPlayerName:String = "matt";
      public var startEquips:Object =
         {
            "matt": [
               Equips.ultrapro9000,
               Equips.hoboclothes,
               Equips.captainhat
            ],
            "natalie": [
               Equips.darktooth,
               Equips.reddress,
               Equips.redribbon
            ],
            "lance": [
               Equips.shadowblaster,
               Equips.officercoat,
               Equips.officerhat
            ],
            "anna": [
               Equips.fairybow,
               Equips.rangerskirt,
               Equips.orangebauble
            ],
            "nolegs": [
               Equips.steelbuckler,
               Equips.heroicarmor,
               Equips.knighthelmet
            ]
         };

      private var defaultStartEquips:Object =
         {
            "matt": [
               Equips.ultrapro9000,
               Equips.hoboclothes,
               Equips.captainhat
            ],
            "natalie": [
               Equips.darktooth,
               Equips.reddress,
               Equips.redribbon
            ],
            "lance": [
               Equips.shadowblaster,
               Equips.officercoat,
               Equips.officerhat
            ],
            "anna": [
               Equips.fairybow,
               Equips.rangerskirt,
               Equips.orangebauble
            ],
            "nolegs": [
               Equips.steelbuckler,
               Equips.heroicarmor,
               Equips.knighthelmet
            ]
         };

      // Receive JSON types
      private static var READY:String = "ready";
      private static var SEED_DATA:String = "seed_data";

      public function APDataModHandler(apSocket:APSocket)
      {
         apSocket.onJSONMessageReceivedCallbackHandlers.push(this);
      }

      public function onJSONMessageReceived(jsonData:Object):void
      {
         if (!jsonData || !jsonData.type)
         {
            return;
         }

         if (jsonData.type == READY)
         {
            isReady = true;
            return;
         }

         if (jsonData.type == SEED_DATA)
         {
            Main.debugLogAP.print("Setting AP seed data from received JSON message: " + JSON.stringify(jsonData));
            var requestedStartPlayer:String = jsonData.start_player != null ? String(jsonData.start_player) : "matt";
            if (defaultStartEquips[requestedStartPlayer] == null)
            {
               Main.debugLogAP.print("Unknown start_player in seed_data: " + requestedStartPlayer + ". Falling back to matt.");
               requestedStartPlayer = "matt";
            }
            startPlayerName = requestedStartPlayer;

            // Start with a copy of the default equips and then overwrite with any data from the seed.
            startEquips = {};
            for (var defaultPlayer:String in defaultStartEquips)
            {
               startEquips[defaultPlayer] = defaultStartEquips[defaultPlayer].slice();
            }

            var startEquipData = jsonData.start_equips != null ? jsonData.start_equips : {};
            for (var player:String in startEquipData)
            {
               if (startEquips[player] == null)
               {
                  Main.debugLogAP.print("Ignoring start_equips entry for unknown player: " + player);
                  continue;
               }

               if (startEquipData[player] == null || startEquipData[player].length != 3)
               {
                  Main.debugLogAP.print("Ignoring invalid start_equips entry for " + player + ". Expected an array of 3 equip SIDs.");
                  continue;
               }

               var weaponSID:String = String(startEquipData[player][0]);
               var armorSID:String = String(startEquipData[player][1]);
               var hatSID:String = String(startEquipData[player][2]);
               var weapon:Equip = APItemHelpers.getEquipBySID(weaponSID);
               var armor:Equip = APItemHelpers.getEquipBySID(armorSID);
               var hat:Equip = APItemHelpers.getEquipBySID(hatSID);

               if (weapon == null || armor == null || hat == null)
               {
                  Main.debugLogAP.print(
                        "Ignoring start_equips entry for " + player +
                        " because one or more equip SIDs were not found: " +
                        weaponSID + ", " + armorSID + ", " + hatSID
                     );
                  continue;
               }

               startEquips[player] = [weapon, armor, hat];
            }

            Main.debugLogAP.print("AP seed data applied. startPlayerName=" + startPlayerName);
            return;
         }
      }

      public function supportsJSONType(jsonType:String):Boolean
      {
         return jsonType == READY || jsonType == SEED_DATA;
      }

      public function get isReadyToStart():Boolean
      {
         return isReady;
      }

      public function onGameInit():void
      {
         var startPlayer:Player = getPlayerByName(this.startPlayerName);

         if (startPlayer == null)
         {
            Main.debugLogAP.print("Start player was invalid during game init. Falling back to matt.");
            startPlayerName = "matt";
            startPlayer = Players.player1;
         }

         startPlayer.weapon = startEquips[this.startPlayerName][0];
         startPlayer.armor = startEquips[this.startPlayerName][1];
         startPlayer.hat = startEquips[this.startPlayerName][2];
         startPlayer.weapon.owned = true;
         startPlayer.armor.owned = true;
         startPlayer.hat.owned = true;
         startPlayer.setEquipGraphics();

         Game.party = [startPlayer];
      }

      public function getPlayerByName(playerName:String):Player
      {
         if (playerName == "matt")
         {
            return Players.player1;
         }
         else if (playerName == "natalie")
         {
            return Players.player2;
         }
         else if (playerName == "lance")
         {
            return Players.player3;
         }
         else if (playerName == "anna")
         {
            return Players.player4;
         }
         else if (playerName == "nolegs")
         {
            return Players.player5;
         }
         else
         {
            Main.debugLogAP.print("getPlayerByName was called with an invalid player name: " + playerName);
            return null;
         }
      }

      public function addPlayerToParty(playerName:String):void
      {
         var player:Player = getPlayerByName(playerName);
         if (player == null)
         {
            Main.debugLogAP.print("Cannot add player to party because player name is invalid: " + playerName);
            return;
         }

         if (Game.party.indexOf(player) != -1)
         {
            return;
         }

         player.weapon = startEquips[playerName][0];
         player.armor = startEquips[playerName][1];
         player.hat = startEquips[playerName][2];
         player.weapon.owned = true;
         player.armor.owned = true;
         player.hat.owned = true;
         player.setEquipGraphics();

         // - 1 since setLevel is really add levels and they start at level 1
         Debug.setLevel(Players.getAverageLevel() - 1, player);
         setPlayerAP(player);

         // Temporarily set dead while players are in their vanilla spots so that the reward UI does not error out.
         // Once players get moved to being added on the map, this won't be needed.
         player.dead = true;

         Game.party.push(player);
      }

      public function setPlayerAP(player:Player)
      {
         // Set AP based on character's level
         if (player.level < 10)
         {
            player.AP = player.level * 40;
         }
         else if (player.level < 20)
         {
            player.AP = player.level * 400;
         }
         else if (player.level < 30)
         {
            player.AP = player.level * 900;
         }
         else if (player.level < 40)
         {
            player.AP = player.level * 1400;
         }
         else
         {
            player.AP = player.level * 2000;
         }
      }
   }
}
