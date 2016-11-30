package classes
{
	public class CrystalBall
	{
		// this class is here so that pass receivers can move to where the ball is going to be
		// as opposed to moving to where it is
		// also it sposed to pass to where player is moving to as opposed to where they are
		// it is also here to allow through passing
		
		// 1. pass receivers move to where ball will be
		// 2. passers pass to where recievers are moving
		// 3. later through pass
		
		private static var instance:CrystalBall;
		 
		public function CrystalBall()
		{
			if ( instance != null)
			{
				throw new Error("singleton error");
			}
		}
		public static function getInstance():CrystalBall{
			if ( instance == null )
			{
				instance = new CrystalBall();
			}
			return instance;
		}
		
		public function setPassingAngleForWhereReceiverIsGoing(passer:PlayerData):Array{
			
			if ( passer.teamMateAimingPassAt == null )
			{
				return null;
			}
			var initalPassAngle:Number = SoccerBallData.getInstance().direction;
			
			var receiver:PlayerData = passer.teamMateAimingPassAt;
			receiver.passReceiver = true;	 //TODO shouldn't this be redundant here?	
			
			//get pass receiver distance
			var distanceToReceiver:Number = Calculator.instance.distanceBetweenPlayers(passer,receiver);
			
			// calculate time for ball to get there
			var kp:Number = passer.kickPower;		// keeper already has their kickPower += 10; 
			kp = kp - GameSettingsData.getInstance().soccerBallFriction;		// TODO this doesn't make sense
			var timeForBallToGetToReceiver:Number = distanceToReceiver / kp;	// ??maybe = distanceToReceiver / ( kp - ((soccerballfirction*distanceToReceiever)/2)
			
			// calculate receiver's future x and y positions
			var futureXPos:Number = receiver.xPos + ( receiver.speedX * timeForBallToGetToReceiver );
			var futureYPos:Number = receiver.yPos + ( receiver.speedY * timeForBallToGetToReceiver );
			
			//keep it in the field bounds
			if ( futureXPos > 1450 - GameSettingsData.getInstance().playerRadius ) futureXPos = 1450 - GameSettingsData.getInstance().playerRadius;
			if ( futureXPos < 50 + GameSettingsData.getInstance().playerRadius ) futureXPos = 50 + GameSettingsData.getInstance().playerRadius;
			if ( futureYPos > 950 - GameSettingsData.getInstance().playerRadius ) futureYPos = 950 - GameSettingsData.getInstance().playerRadius;
			if ( futureYPos < 50 + GameSettingsData.getInstance().playerRadius ) futureYPos = 50 + GameSettingsData.getInstance().playerRadius; 
			
			// keep it in goal bounds for the keeper
			if ( receiver.isKeeper )
			{
				if ( futureYPos > 700 - GameSettingsData.getInstance().playerRadius ) futureYPos = 700 - GameSettingsData.getInstance().playerRadius;
				if ( futureYPos < 300 + GameSettingsData.getInstance().playerRadius ) futureYPos = 300 + GameSettingsData.getInstance().playerRadius;				
			}
			
			// calculate the angle from the passer to this future position
			var futurePassAngle:Number = RadiansCalculator.calc( futureXPos - passer.xPos, futureYPos - passer.yPos );
			
			SoccerBallData.getInstance().direction = futurePassAngle;
			
			// test
//			if ( 	(Math.abs(initalPassAngle - futurePassAngle) > Math.PI/2) 
//					&& (Math.abs(initalPassAngle - futurePassAngle) !> (2*Math.PI)/3) ) 	)
//			{
//				throw new Error("future pass angle is too different from initial pass angle");
//			}
//			
			var passXYDestinationsArray:Array = new Array();
			passXYDestinationsArray[0] = futureXPos;
			passXYDestinationsArray[1] = futureYPos;
			passXYDestinationsArray[2] = timeForBallToGetToReceiver;	
			return passXYDestinationsArray;
		}
		
		

	}
}