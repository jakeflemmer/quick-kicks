package classes
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class LevelSettingsData extends EventDispatcher
	{
		public function LevelSettingsData(target:IEventDispatcher=null)
		{
			super(target);
		}
		public static function demo():void
		{
			//demo mode
			GameSettingsData.getInstance().demoMode = true;
									
			
		}
		public static function setLevel(level:uint):void
		{
//			switch (level){
//				case 1:
//					GameSettingsData.getInstance().level = 1;
//									
//					GameSettingsData.getInstance().blueTeamMaxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed * .7;
//					GameSettingsData.getInstance().blueTeamAcceleration =  GameSettingsData.getInstance().redTeamAcceleration *.7;
//					GameSettingsData.getInstance().blueTeamKickPower = GameSettingsData.getInstance().redTeamKickPower * .7;		
//					break;
//				case 2:
//					GameSettingsData.getInstance().level = 2;
//			
//					GameSettingsData.getInstance().blueTeamMaxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed * .85;
//					GameSettingsData.getInstance().blueTeamAcceleration =  GameSettingsData.getInstance().redTeamAcceleration *.85;
//					GameSettingsData.getInstance().blueTeamKickPower = GameSettingsData.getInstance().redTeamKickPower * .85;		
//					break;
//				case 3:
//					GameSettingsData.getInstance().level = 3;
//			
//					GameSettingsData.getInstance().blueTeamMaxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed ;
//					GameSettingsData.getInstance().blueTeamAcceleration =  GameSettingsData.getInstance().redTeamAcceleration ;
//					GameSettingsData.getInstance().blueTeamKickPower = GameSettingsData.getInstance().redTeamKickPower ;
//					break;
//				case 4:
//					GameSettingsData.getInstance().level = 4;
//			
//					GameSettingsData.getInstance().blueTeamMaxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed * 1.15;
//					GameSettingsData.getInstance().blueTeamAcceleration =  GameSettingsData.getInstance().redTeamAcceleration * 1.15;
//					GameSettingsData.getInstance().blueTeamKickPower = GameSettingsData.getInstance().redTeamKickPower *1.15;
//					break;
//			}
		}
		public static function level1():void
		{
			//easy mode
		}
		public static function level2():void
		{
			//medium
		}
		public static function level3():void
		{
			//easy mode
					
				
		}
		public static function level4():void
		{
			//super level
			
		}
		
	}
}