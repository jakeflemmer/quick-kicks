package classes.data
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class SpeedSettingsData extends EventDispatcher
	{
		public function SpeedSettingsData(target:IEventDispatcher=null)
		{
			super(target);
		}	
		
		public static function faster():void
		{
			GameSettingsData.getInstance().basicDribbleSpeed +=.03;
			GameSettingsData.getInstance().soccerBallFriction +=.2;
			GameSettingsData.getInstance().passingSpeed -= 100;
			GameSettingsData.getInstance().justBeatTimer -=100;
			
			GameSettingsData.getInstance().redTeamAcceleration  += .1; 
			GameSettingsData.getInstance().redTeamKickPower += 4; 
			GameSettingsData.getInstance().redTeamMaxSpeed += 1;
			
			GameSettingsData.getInstance().blueTeamAcceleration += .1;
			GameSettingsData.getInstance().blueTeamKickPower += 6;
			GameSettingsData.getInstance().blueTeamMaxSpeed += 1;
		}
		public static function slower():void
		{
			GameSettingsData.getInstance().basicDribbleSpeed -=.03;
			GameSettingsData.getInstance().soccerBallFriction -=.2;
			GameSettingsData.getInstance().passingSpeed += 100;
			GameSettingsData.getInstance().justBeatTimer +=100;
			
			GameSettingsData.getInstance().redTeamAcceleration  -= .1;
			GameSettingsData.getInstance().redTeamKickPower -= 4; 
			GameSettingsData.getInstance().redTeamMaxSpeed -= 1; 
			
			GameSettingsData.getInstance().blueTeamAcceleration -= .1; 
			GameSettingsData.getInstance().blueTeamKickPower -= 6;
			GameSettingsData.getInstance().blueTeamMaxSpeed -= 1;
		}
	}
}