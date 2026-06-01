package archipelago
{
   public class APItemHelpers
   {
      public function APItemHelpers()
      {
         super();
      }

      public static function getEquipBySID(sid:String):Equip
      {
         for each (var equip:Equip in Equips.ALL_EQUIPS)
         {
            if (equip && equip.SID == sid)
            {
               return equip;
            }
         }

         return null;
      }
   }
}
