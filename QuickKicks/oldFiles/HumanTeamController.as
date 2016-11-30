package classes
{ 
	import flash.events.Event;
	
	public class HumanTeamController extends AbstractTeamController
	{	

		public function HumanTeamController()
		{
			super();
			
			initializeTeam(true);  // red = true , blue = false	
			
			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);		
		}	
	
		//--------------------------------------------------------------------------------------------------
		//  ON ENTER FRAME
		//--------------------------------------------------------------------------------------------------

	override protected function ON_ENTER_FRAME(e:Event=null):void
	{
		if (gsd.paused || gsd.goalAnimation) return;	
		
		if (gsd.demoMode)  
		{
			
			super.ON_ENTER_FRAME(e);
		
		} else {	
			
			_data.currentFrameNumber ++;	
	
			keeperTracking();			
			
			determineState();
			
			if ( _data.state == "attacking")
			{
				
				setAllPlayersMarking(false);			
				
				assignAllPlayersTheirZones();	// which change depending on which zone pwb is in
			
				givePlayersNewGetFreeDestinations();
				
				if ( pwbd != null )
				{
				
					calculatePasses();
					noPlayersControlled();	
					pwbd.isControlled = true;					
					//doBallCarrierStrategy();  da human being playing is gonna do dis						
				
				}
				else if ( pwbd == null )
				{
				
					testCheckPassReceiverIsSet(); // this function can be removed in time
					chooseWhoIsControlled();
						
				}			
				
			}
			else if ( _data.state == "defending")
			{
				
				setAllPlayersMarking(true);		
				chooseWhoIsControlled();				
								
			}
			
			else throw new Error("no state");			
		
			//testThatOnePlayerIsEitherGettingTheBallOrHasTheBall();  // this should only be there for cpu teams
			
			testThatNoTwoPlayersAreMarkingTheSameMan();
			
			testThatNoTwoPlayersAreControlled();
			
			testThatIfDefendingAndPlayerNotGettingBallPlayerMarkingIsNotNull();	
		}	
				
	}
	
	private function chooseWhoIsControlled():void{
		var pc:AbstractPlayerController = determineWhoIsClosestToBall();
		noPlayersControlled();
		pc.data.isControlled = true;			
	}
	
	private function testThatNoTwoPlayersAreControlled():void{
		var numOfPlayersControlled:uint=0;
		for ( var i:uint =0 ; i < playersArray.length; i++)
		{
			if ( (playersArray[i] as AbstractPlayerController).data.isControlled )
			{
				numOfPlayersControlled++;
			}
		}
		if ( numOfPlayersControlled > 1)
		{
			throw new Error("more than one player controlled");
		}
	}
		
	
	
	//--------------------------------------------------------------------------------------------------
	// EVENT HANDLERS	
	//--------------------------------------------------------------------------------------------------
	
	private function onPlayerMakesPass(e:GameEvents):void
	{
		_data.closestTeamMate.passReceiver = true;
	}
	private function onPlayerGotBall(e:GameEvents):void
	{
		noPassReceiver();
	}
	private function precisionPass(e:GameEvents = null):void
	{
		// this function simply makes the pass angle be calculated from the center of the ball
		// as opposed to the center of the ball carrier
		
		if (pwbd.scoreBall ) return;
		
		if (_data.closestTeamMate == null) return;
		
		var theX:Number = ( _data.closestTeamMate.xPos - sbd.xPos );
		var theY:Number = ( _data.closestTeamMate.yPos - sbd.yPos );
		var precisionPassAngle:Number = RadiansCalculator.calc(theX, theY); 		
		_data.autoPassAngle = precisionPassAngle;
		pwbd.autoPassAngle = precisionPassAngle;		
	}
	
	override protected function onPlayerJustPassed(ge:GameEvents):void{
		if (  ! passOrShootAngleCalculator.scoreBall )
		{
			pwbd.teamMateAimingPassAt.passReceiver = true;
		} 
		else if ( passOrShootAngleCalculator.scoreBall )
		{
			noPassReceiver();
		}						
		super.onPlayerJustPassed(ge);
		
	}
	
	//--------------------------------------------------------------------------------------------------
	// COMPLEX FUNCTIONS
	//--------------------------------------------------------------------------------------------------
	
		
//	private function doTeamStrategy():void
//	{
//		if (_data.state == null) return;			
//		if (_data.state != "attacking" ) return; // TODO apparently there is no srategy for defending ?	
//		
//		assignAllPlayersTheirZones();
//		givePlayersNewGetFreeDestinations();
//	}		
	

	
	private function throughPass():void
	{
		// calulate distance from pass receiver
		// divide the ditance by kickPower to get time
		// multiply passReceiver speed x by time and passReceriver speed y by time
		// get future passReceiverX and futurePassReceiverY
		// calulate angle of future x,y
		// set autoPassAngle to said angle
		
		var xDistance:Number = Math.abs(_data.closestTeamMate.xPos - pwbd.xPos);
		var yDistance:Number = Math.abs(_data.closestTeamMate.yPos - pwbd.yPos);
		var distanceFromPassReceiver:Number = xDistance + yDistance;
		var kickPower:uint = gsd.kickPower;
		var friction:Number = gsd.soccerBallFriction;		
		
		var time:Number = distanceFromPassReceiver/(kickPower/2);
		
		var speedX:Number = _data.closestTeamMate.speedX;
		var speedY:Number = _data.closestTeamMate.speedY;
		var xPos:Number = _data.closestTeamMate.xPos;
		var yPos:Number = _data.closestTeamMate.yPos;
		var futureX:Number = xPos + (time * speedX);
		var futureY:Number = yPos + (time * speedY);		
		var newAutoPassAngle:Number = RadiansCalculator.calc(futureX - pwbd.xPos, futureY - pwbd.yPos);
				
		
		_data.autoPassAngle = newAutoPassAngle;
		
		
	}
	private function getIntoStrikePosition():void
	{		
		//trace("demo     go to strike position ");
		pwbd.destinationX = 1000;
		pwbd.destinationY = 500;
		if ( pwbd.playerMarking.yPos < pwbd.yPos ) pwbd.destinationY = 700;
		if ( pwbd.playerMarking.yPos > pwbd.yPos ) pwbd.destinationY = 300;		
	}
	
	
	
//	private function doBallCarrierStrategy():void
//	{	
//		if ( pwbd == null || pwbd.playerMarking == null) return;
//	
//		// TODO this doesn't make sense
////		if ( pwbd == keeper.data ){          // keeper doesn't try to get past anyone
////			keeper.data.destinationX = 300;	keeper.data.destinationY = 500;
////			return;
////		}
//	
//		// if defender is alredy beat then strike or go to strike position 
//		if ( pwbd.xPos > pwbd.playerMarking.xPos )
//		{
//			if ( inStrikingPosition())
//			{
//				lookForGoal();
//				return;
//			} else
//			{
//				getIntoStrikePosition();
//				return;				
//			}
//		}
//		
//		if ( pwbd.xPos > 1250 ) // close enough to goal
//		{
//			lookForCross();
//			return;
//		}
//		
//		tryToBeatDefenderOrProtectBall();			
//	
//	}// end getPastDefender()
	private function lookForGoal():void
	{
		if ( pwbd.dribble < (1.5 * Math.PI))
		{
			pwbd.dribble += gsd.basicDribbleSpeed;
		}
		if ( pwbd.dribble > (.5 * Math.PI))
		{
			pwbd.dribble -= gsd.basicDribbleSpeed;
		}
	}
	private function inStrikingPosition():Boolean
	{
		var inPos:Boolean = false;
		if ( pwbd.xPos > 900 )
		{
			if (pwbd.yPos > 300 && pwbd.yPos < 700)
			{
				inPos = true;
			}
		}
		return inPos;
	}
	
	
	private function lookForCross():void
	{
		protectBall();
		_data.pressureToPass = true;
	}
	private function protectBall():void
	{
		//TODO delegate to ballcarrierAi
		//trace("demo               protectBall");
//		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
//		pwbd.destinationX = pwbd.xPos + (20 * Math.cos( angleofDefender + Math.PI));
//		pwbd.destinationY = pwbd.yPos + (20 * Math.sin( angleofDefender + Math.PI));		
	}
	private function enoughSpaceToBeatDefender():Boolean
	{
		var xDistFromDefender:Number = Math.abs(SoccerBallData.getInstance().xPos - pwbd.playerMarking.xPos);
		var yDistFromDefender:Number = Math.abs(SoccerBallData.getInstance().yPos - pwbd.playerMarking.yPos);
		var totalDistFromDefender:Number = xDistFromDefender + yDistFromDefender;
		
		var enoughSpace:Boolean = false;
		
		if ( totalDistFromDefender >= gsd.playerRadius * 4) // space to tryToBeat()
		{
			enoughSpace = true;	
		}
		return enoughSpace;
		
	}
	
	private function tryToBeatDefenderOrProtectBall():void
	{
		var angleOfGoal:Number = RadiansCalculator.calc( 1450 - pwbd.xPos, 500 - pwbd.yPos);
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);		
		
		if ( enoughSpaceToBeatDefender() )
		{	
			//trace("demo    try to beat defender");	
			// go straight past defender
			if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius )
			{	
				//trace("demo                             straight ");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( 0));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( 0));
				_data.pressureToPass = false;
				return;
			}	
			// cut left			
			if ( pwbd.yPos < pwbd.playerMarking.yPos && pwbd.yPos >= 200 ) 
			{
				//trace("demo                   cut left");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI)));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));
				_data.pressureToPass = false;
				return;
			}		
			// cut right
			if ( pwbd.yPos > pwbd.playerMarking.yPos && pwbd.yPos <= 800 )
			{
				//trace("demo                           cut right");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI )));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));
				_data.pressureToPass = false;
				return;
			}			
		}
		
		protectBall();
		//_data.pressureToPass = true;
			
			// drop left
			/*trace("cpuTC getPastDef() - drop left");
			pwbd.destinationX = pwbd.xPos + (100 * Math.cos( .35 * Math.PI ));
			pwbd.destinationY = pwbd.yPos + (100 * Math.sin( .35 * Math.PI));
			return;*/
			// drop right
			/*trace("cpuTC getPastDef() - drop right");
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( 1.75 * Math.PI));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( 1.75 * Math.PI));
			return;*/				
	}
	private function tryToBeatDefender():void
	{
		var angleOfGoal:Number = RadiansCalculator.calc( 1450 - pwbd.xPos, 500 - pwbd.yPos);
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);		
				
			// go straight past defender
			if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius )
			{					
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( 0));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( 0));				
				return;
			}	
			// cut left			
			if ( pwbd.yPos < pwbd.playerMarking.yPos && pwbd.yPos >= 200 ) 
			{				
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI)));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));				
				return;
			}		
			// cut right
			if ( pwbd.yPos > pwbd.playerMarking.yPos && pwbd.yPos <= 800 )
			{				
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI )));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));				
				return;
			}			
	}
	
	
	//-----------------------------------------------------------------------------------
	// DUBIOUS FUNCTIONS HERE TO PREVENT COMPILATION ERRORS
	//-----------------------------------------------------------------------------------
	public function ballNowFree():void
		{
		//	resetZones();
			var i:int;
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.scoreBall = false;
			}
		}						
		
		public function goalReset():void
		{
			resetAfterNewStart();
			//resetDestinations();			
//			_data.pressureToPass = false;			
//			resetAllPlayerProperties();
		}
		
		public function reset():void
		{			
			_data.pressureToPass = false;	
							
			noPlayersGettingBall();			
			resetAllPlayerProperties();			
		//	resetZones();
		}
		public function resetEverything():void{
			
			resetAfterNewStart();
		}

	
	// OLD CODE BELOW
	//  ___________________________________________________________________________________________________________________________________
// demo team stuff here    xxxx
	

//	private function receiverNotCovered():Boolean
//	{
//		if ( _data.closestTeamMate == null) return true;
//		var notCovered:Boolean = false;
//		var xDistToReceiver:Number = Math.abs( _data.closestTeamMate.xPos - pwbd.xPos );
//		var yDistToReceiver:Number = Math.abs( _data.closestTeamMate.yPos - pwbd.yPos );
//		var totalDistanceToReceiver:Number = Math.sqrt( (xDistToReceiver*xDistToReceiver) + (yDistToReceiver*yDistToReceiver) );
//		if ( _data.closestTeamMate.playerMarking == null) // closest player is keeper 
//		{ 
//			if (pwbd.xPos >= 800 ) 
//			{
//				return false;		// too far to try to pass back to keeper
//			} else {
//				return true; 	// try to pass back to keeper
//			}			
//		}
//		var xDistToInterceptor:Number = Math.abs( _data.closestTeamMate.playerMarking.xPos - pwbd.xPos );
//		var yDistToIntercerptor:Number = Math.abs( _data.closestTeamMate.playerMarking.yPos - pwbd.yPos );
//		var totalDistanceToIntercerptor:Number =  Math.sqrt( (xDistToInterceptor*xDistToInterceptor) + (yDistToIntercerptor*yDistToIntercerptor) );
//		
//		if ( totalDistanceToIntercerptor > totalDistanceToReceiver )
//		{
//			notCovered = true;	
//			//trace ("cpu recNotCov() notCovered");
//		}
//		return notCovered;
//	}


	
	
	}// close class
}// close package