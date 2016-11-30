package classes
{
	public class SmartDefender
	{
		public function SmartDefender()
		{
			// this class is obviously here to provide smart defender functionality
			// Smart defender means that instead of the defender just trying to take the ball
			// the defender keeps himself between the player with the ball and goal
			// He only goes straight for the ball when he thinks he has a chance to get it
		}
		
		//--------------------------------------------------------------------------------------------------
		// PUBLIC MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		public static function smartDefend(pd:PlayerData):PlayerData{		
		
				// same as mark player but markingDistance depends on ball carriers speed
				if ( SoccerBallData.getInstance().ballCarrier == null ) 
				{
					throw new Error("smart defend fail b/c soccer ball data has no ball carrier set");
				}				
				var bc:PlayerData = SoccerBallData.getInstance().ballCarrier; // ball carrier	
				var deltaX:Number;
				var deltaY:Number;
				
				if ( pd.teamId == "blue")
				{ 			
					deltaX = ( 1450 - bc.xPos );  // 1450 = goalCenterX
					deltaY = ( 500 - bc.yPos );  //  500 = goalCenterY
				}
				else
				{
					deltaX = ( bc.xPos - 50);  // 50 = goalCenterX
					deltaY = ( 500 - bc.yPos );  //  500 = goalCenterY
				}
				
				var theAngleFromGoal:Number = RadiansCalculator.calc(deltaX,deltaY);
				var bcd:Number = Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)); 			// ball carrier distance from goal
				var sdd:Number = 0;														// smart defender distance from ball carrier
				var bcs:Number = Math.sqrt((bc.speedX*bc.speedX)+(bc.speedY*bc.speedY)); // ball carrier speed
				var bcms:Number = gsd.maxSpeed; 										// ball carrier max speed 
				// smart defender diatnce
				sdd = (bcs/bcms) * (gsd.playerRadius*3); 								// at max speed stay 3*radius away
				
				if ( pd.teamId == "blue" )
				{
					pd.destinationX = (1475 - ( (bcd - sdd) * Math.cos(theAngleFromGoal)));
					pd.destinationY = (500 - ( (bcd - sdd) * Math.sin(theAngleFromGoal)));
				}
				else
				{
					pd.destinationX = (25 + ( (bcd - sdd) * Math.cos(theAngleFromGoal)));
					pd.destinationY = (500 - ( (bcd - sdd) * Math.sin(theAngleFromGoal)));
				}
				return pd;
			
		}
		
		public static function closeEnoughToTakeBall(pd:PlayerData):Boolean{
			
			var xDistToBall:Number = SoccerBallData.getInstance().xPos - pd.xPos;
			var yDistToBall:Number = SoccerBallData.getInstance().yPos - pd.yPos;
			var totalDistToBall:Number = Math.sqrt((xDistToBall*xDistToBall) + (yDistToBall*yDistToBall));
			
			if (totalDistToBall <= gsd.takeBallDistance)
			{						
				return true;
			}
			else 
			{
				return false;
			}
		}
		
		//--------------------------------------------------------------------------------------------------
		// GETTERS & SETTERS
		//--------------------------------------------------------------------------------------------------
		
		public static function get gsd():GameSettingsData{
			return GameSettingsData.getInstance();
		}

	}
}