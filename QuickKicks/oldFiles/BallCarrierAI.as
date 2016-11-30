package classes
{
	import flash.utils.Timer;
	
	public class BallCarrierAI
	{
		public var scoreBall:Boolean;
		public var openPass:Boolean;
		//public var openScoreBall:Boolean;
		public var space:Number;
		public var doingA360:Boolean;
		public var dontHoldBallTooLongFrameCounter:uint;
		public var lookingLeft:Boolean;
		public var lookingRight:Boolean;
		public var state:String = "nothing";
		public var action:String = "nothing";
		public var frameCounter:uint=0;
		public var lookForLongPassFrameCounter:uint=0;
		public var lookForGoalFrameCounter:uint = 0;
		public var cuttingFrameCounter:uint=0;
				
		
		public function BallCarrierAI()
		{
			// this class is here so that the player with the ball can formulate an intelligent strategy about what to do
			// i.e. - should he pass or shoot or try to hold the ball and try to school defenders etc... ???
			
			// TODO
			// spinn is the new ball protector :)
			
			// when spinning, player should look at which side the player marking them is on
			// and then spin the other way.
			// if when spinning the ball will spin too close to the player marking then player
			// must change direction and spin the other way
			// so ultimately the protect the ball method will be redundant
			// spin is the new ball protector :)
			
		}		
		
		//-------------------------------------------------------------------------------------------------------
		//   ON ENTER FRAME ( sort of )
		//-------------------------------------------------------------------------------------------------------
		
		public function decideWhatToDo(playersArray:Array, pwbd:PlayerData):void{					
					
			//-------------------------------------------------------------
			if ( ! gsd.ballCarrierAIOn )
			{
				if ( openPass )
				{
					pwbd.passNow = true;
				}
				return;
			} 
			//-------------------------------------------------------------
					
			frameCounter++;
			
			if ( pwbd.isKeeper )
			{				
				doKeeperStrategy(playersArray,pwbd);
				return;
			}
			
			if ( scoreBall && openPass )
			{
				pullTrigger(pwbd);				
				return;
			}			
			
			switch (state)
			{	// evaluate functions
				case "nothing":				
					decideState(pwbd);
					break;
					
				// has space to try something
				case "lookForLongPass":
					lookForLongPass(pwbd);		// is a long pass available? how long has he been doing this? 
					break;
//				case "tryToBeatDefender":
//					tryToBeatDefender(pwbd);	// is it possible to beat defender?	check each turn
//					break;
				case "cutting":
					cutting(pwbd);				// how long has he been doing this?
					break;
				case "lookForGoal":
					lookForGoal(pwbd);			// is a striker with more space open? how long has he been doing this?
					break;
					
				// has no space
				case "protecting":				// should we continue spinning in same direction or switch?  
					protecting(pwbd);			// is any pass available yet?
					break;									
			}		
			
			switch (action)
			{	
				case "goStraight":
					goStraight(pwbd);
					break;
				case "cutLeft":
					cutLeft(pwbd);
					break;
				case "cutRight":
					cutRight(pwbd);
					break;
				case "spinCW":
					spinCW(pwbd);
					break;
				case "spinCCW":
					spinCCW(pwbd);
					break;
			}
			
			if ( dontHoldBallTooLongFrameCounter > gsd.dontHoldBallTooLongFrameLimit )
				{	
					//TODO this is gay
					pwbd.passNow = true;
					if( pwbd.teamId == "red" ) trace("player held ball too long");
					return;
				}
			
			//trace ( pwbd.teamId + " state: " + state + " action: "+action+ " direction: "+pwbd.direction);
			// trace ( "action: "+action+ " direction: "+pwbd.direction.toPrecision(3) + " x: " + pwbd.xPos.toPrecision(3) + " y: " + pwbd.yPos.toPrecision(3));
			// trace ( "spdX: " + pwbd.speedX.toPrecision(3) + " spdY: " + pwbd.speedY.toPrecision(3) );
		}
		
		//-------------------------------------------------------------------------------------------------------	
		
		private function decideState(pwbd:PlayerData):void{
			
			if ( pwbd.space > gsd.enoughSpaceToTrySomething )
				{					
					if ( isDefender(pwbd) )
					{				
						state = "lookForLongPass";	
						lookForLongPassFrameCounter = frameCounter + 20; // hard coding here					
					}
					else if ( isMidFielder(pwbd) )
					{
						//TODO midfield has most options
						state = "lookForGoal";
					}
					else if ( isStriker(pwbd) )
					{
						if ( tryToBeatDefender(pwbd) )
						{
							state = "cutting";
							cuttingFrameCounter = frameCounter + 15; // hard coding here
						}
						else
						{
							state = "lookForGoal";
							lookForGoalFrameCounter = frameCounter + 20;
						}											
					}
					else
					{
						throw new Error("what kind of player is this if none of the above?");
					}								
				}				 
				else 
				{	
					state = "protecting";					
				}						
		}
		//-------------------------------------------------------------------------------------------------------
		//  ESSENTIAL FUNCTIONS
		//-------------------------------------------------------------------------------------------------------
		private function protecting(pwbd:PlayerData):void{			
			
			if ( openPass )
			{
				pullTrigger(pwbd);
				return;
			}
			action = directionOfSpinToAvoidPlayer(pwbd, guyPressingBallTheMost(pwbd));							
		}			
		private function doKeeperStrategy(playersArray:Array,pwbd:PlayerData):void{
			
			pullTrigger(pwbd);			
		}		
		private function lookForLongPass(pwbd:PlayerData):void{

			if ( frameCounter >= lookForLongPassFrameCounter )
			{
				state = "protecting";
				protecting(pwbd);
				return;
			}						
			if ( isStriker(pwbd.teamMateAimingPassAt) )
			{
				if ( openPass )
				{
					pullTrigger(pwbd);
				}
			}
			action = directionOfSpinToAvoidPlayer(pwbd, guyPressingBallTheMost(pwbd));			
		}
		private function cutting(pwbd:PlayerData):void{
			
			if ( frameCounter >= cuttingFrameCounter )
			{
				state = "nothing";								
			}			
		}	
		private function lookForGoal(pwbd:PlayerData):void{
			
			if ( frameCounter >= lookForGoalFrameCounter )
			{
				state = "protecting";								
			}	
			if ( isStriker(pwbd.teamMateAimingPassAt) && ( pwbd.teamMateAimingPassAt.space > pwbd.space ))
			{
				pullTrigger(pwbd);									
			}
			else
			{
				action = directionOfSpinToAvoidPlayer(pwbd, guyPressingBallTheMost(pwbd));
			}					
			
		}	
		
//		private function tryToScore(pwbd:PlayerData):void{
//			
//			 
//			tryToBeatDefender(pwbd);		
//						
//			if ( isStriker(pwbd.teamMateAimingPassAt) && ( pwbd.teamMateAimingPassAt.space > pwbd.space ))
//			{
//				pullTrigger(pwbd);									
//			}
//			else
//			{
//				action = directionOfSpinToAvoidPlayer(pwbd, guyPressingBallTheMost(pwbd));
//			}			
//		}
//		private function protectBallFromPlayerMarking(pwbd:PlayerData):void{
//			
//			dontHoldBallTooLongFrameCounter++;				
//			var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
//			pwbd.destinationX = pwbd.xPos + (20 * Math.cos( angleofDefender + Math.PI));
//			pwbd.destinationY = pwbd.yPos + (20 * Math.sin( angleofDefender + Math.PI));		
//		}
//		
//		private function protectBallFromClosestDefender(pwbd:PlayerData):void{
//			
//			dontHoldBallTooLongFrameCounter++;
//			var angleofDefender:Number = RadiansCalculator.calc( pwbd.closestDefender.xPos - pwbd.xPos, pwbd.closestDefender.yPos - pwbd.yPos);
//			pwbd.destinationX = pwbd.xPos + (20 * Math.cos( angleofDefender + Math.PI));
//			pwbd.destinationY = pwbd.yPos + (20 * Math.sin( angleofDefender + Math.PI));					
//			
//		}
		//-------------------------------------------------------------------------------------------------------
		//   PRIVATE METHODS
		//-------------------------------------------------------------------------------------------------------
		
		private function pullTrigger(pwbd:PlayerData):void{
			trace("trigger pulled");
			pwbd.passNow = true;
			state = "nothing";
			action = "nothing";
		}
		
		private function guyPressingBallTheMost(pwbd:PlayerData):PlayerData{
			if ( pwbd.closestDefender == null )	return pwbd.playerMarking;
			
			if ( pwbd.playerMarking.id == pwbd.closestDefender.id )
			{
				return pwbd.playerMarking;
			}else{
				return pwbd.closestDefender;
			}
			
		}
		private function directionOfSpinToAvoidPlayer(pwbd:PlayerData,playerToAvoid:PlayerData):String{
			
			var angle:Number = RadiansCalculator.calc(playerToAvoid.xPos - pwbd.xPos, playerToAvoid.yPos - pwbd.yPos);
			var drib:Number = pwbd.dribble;
			
			if ( Math.abs(drib - angle) < Math.PI)
			{
				if ( angle < drib )
				{
					return "spinCW";
				}
				if ( angle > drib )
				{
					return "spinCCW";
				}				
			}else{
				if ( angle > drib )
				{
					return "spinCW";
				}
				if ( angle < drib )
				{
					return "spinCCW";
				}
			}			
			
			return "spinCW";
		}	
		private function tryToBeatDefender(pwbd:PlayerData):Boolean
		{			
						
			var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
			//red
			if ( (pwbd.teamId == "red" && pwbd.xPos < 1200) )
			{
//				// go straight past defender
//				if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius * 2 )
//				{						
//					action = "goStraight";
//					return true;			
//				}	
				// cut left			
				if ( pwbd.yPos < pwbd.playerMarking.yPos - gsd.playerRadius && pwbd.yPos >= 200 ) 
				{				
					action = "cutLeft";			
					return true;
				}		
				// cut right
				if ( pwbd.yPos > pwbd.playerMarking.yPos + gsd.playerRadius && pwbd.yPos <= 800 )
				{			
					action = "cutRight";		
					return true;
				}
			}
			
			if ( (pwbd.teamId == "blue" && pwbd.xPos > 300) )
			{
//				// go straight past defender
//				if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius * 2 )
//				{						
//					action = "goStraight";
//					return true;			
//				}	
				// cut left			
				if ( pwbd.yPos > pwbd.playerMarking.yPos + gsd.playerRadius && pwbd.yPos <= 800 ) 
				{				
					action = "cutLeft";			
					return true;
				}		
				// cut right
				if ( pwbd.yPos < pwbd.playerMarking.yPos - gsd.playerRadius && pwbd.yPos >= 200 )
				{			
					action = "cutRight";		
					return true;
				}
			}			
			return false;	
		}
		private function goStraight(pwbd:PlayerData):void{
			pwbd.destinationX = pwbd.xPos + (pwbd.teamId == "red" ? 10:-10);
			pwbd.destinationY = pwbd.yPos; 				
		}
		private function cutLeft(pwbd:PlayerData):void{
			var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI)));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));			
		}
		private function cutRight(pwbd:PlayerData):void{
			var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI )));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));		
		}	
		
		private function spaceFromDefender(pwbd:PlayerData):Number{						
			return Calculator.instance.distanceBetweenPlayers(pwbd,pwbd.playerMarking);
		}		
		
		private function isDefender(pwbd:PlayerData):Boolean{
			switch (gsd.numberOfPlayers)
			{
				case 5:
					if ( pwbd.id == "player1" || pwbd.id == "player2" )
						return true;
					else
						return false;
					break;
				case 7:
					if ( pwbd.id == "player1" || pwbd.id == "player2" || pwbd.id == "player3" )
						return true;
					else
						return false;
					break;
				case 10:
					if ( pwbd.id == "player1" || pwbd.id == "player2" || pwbd.id == "player3" )
						return true;
					else
						return false;
					break;
				
			}
			throw new Error("incorrect number of players");
			return null;
		}
		private function isMidFielder(pwbd:PlayerData):Boolean{
			switch (gsd.numberOfPlayers)
			{
				case 5:
					return false;
					break;
				case 7:
					return false;
					break;
				case 10:
					if ( pwbd.id == "player4" || pwbd.id == "player5" || pwbd.id == "player6" )
						return true;
					else
						return false;
					break;
				
			}
			throw new Error("incorrect number of players");
			return null;
		}
		private function isStriker(pwbd:PlayerData):Boolean{
			
			if ( !pwbd ) return false;	// TODO why would this be null??
			
			switch (gsd.numberOfPlayers)
			{
				case 5:
					if ( pwbd.id == "player3" || pwbd.id == "player4" )
						return true;
					else
						return false;
					break;
				case 7:
					if ( pwbd.id == "player4" || pwbd.id == "player5" || pwbd.id == "player6" )
						return true;
					else
						return false;
					break;
				case 10:
					if ( pwbd.id == "player7" || pwbd.id == "player8" || pwbd.id == "player9" )
						return true;
					else
						return false;
					break;
				
			}
			throw new Error("incorrect number of players");
			return null;
		}
		private function spinCW(pwbd:PlayerData):void{			
		
			if ( pwbd.direction > 0 && pwbd.direction < Math.PI/2)
			{
				pwbd.destinationY = pwbd.yPos + 100;
				pwbd.destinationX = pwbd.xPos - 100;					
			}
			if ( pwbd.direction > (Math.PI/2) && pwbd.direction < Math.PI)
			{
				pwbd.destinationX = pwbd.xPos - 100;
				pwbd.destinationY = pwbd.yPos - 100;
			}
			if ( pwbd.direction > (Math.PI) && pwbd.direction < (Math.PI/2)*3)
			{
				pwbd.destinationY = pwbd.yPos - 100;
				pwbd.destinationX = pwbd.xPos + 100;
			}
			if ( pwbd.direction > (Math.PI/2)*3 && pwbd.direction < Math.PI*2)
			{
				pwbd.destinationX = pwbd.xPos + 100;
				pwbd.destinationY = pwbd.yPos + 100;
			}
		}
		private function spinCCW(pwbd:PlayerData):void{
		
			if ( pwbd.direction > (Math.PI/2)*3 && pwbd.direction < Math.PI*2) // quadrant IV
			{
				pwbd.destinationY = pwbd.yPos - 100;
				pwbd.destinationX = pwbd.xPos - 100;
			}
			if ( pwbd.direction > (Math.PI) && pwbd.direction < (Math.PI/2)*3)
			{
				pwbd.destinationX = pwbd.xPos - 100;
				pwbd.destinationY = pwbd.yPos + 100;
			}
			if ( pwbd.direction > (Math.PI/2) && pwbd.direction < Math.PI)
			{
				pwbd.destinationY = pwbd.yPos + 100;
				pwbd.destinationX = pwbd.xPos + 100;
			}
			if ( pwbd.direction > 0 && pwbd.direction < Math.PI/2)
			{
				pwbd.destinationX = pwbd.xPos + 100;
				pwbd.destinationY = pwbd.yPos - 100;
			}
		}
		
		//-------------------------------------------------------------------------------------------------------
		//   EVENT HANDLERS
		//-------------------------------------------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------------
		//   GETTERS & SETTERS
		//-------------------------------------------------------------------------------------------------------
		
		private function get gsd():GameSettingsData{
			return GameSettingsData.getInstance();
		}

		
		
		//-------------------------------------------------------------------------------------------------------
		//   OLD CODE
		//-------------------------------------------------------------------------------------------------------
//					var space:Number = pwbd.space;					
//					var three:Number = gsd.playerRadius * 5;
//					var two:Number = gsd.playerRadius * 2;
//					var one:Number = gsd.playerRadius;
//					
//					if ( space >= three )
//					{
//				//		tryToBeatDefender();
//						_data.pressureToPass = false;
//						
//					}
//						//				else if ( space >= two )
//						//				{
//						//					lookForBestPass();					
//						//					
//						//				}
//					else //if ( space < two )
//					{
//			//			protectBall();
//						_data.pressureToPass = true;										
//					}
//					
//				} else {
//					_data.pressureToPass = true;
//				}
//				
//				if ( _data.pressureToPass )
//				{	
//					if ( Calculator.instance.openPass(pwbd,_data.closestTeamMate) )
//					{
////					if ( openPass() )
////					{					
////						if ( receiverNotCovered() )  // prevent interceptions
////						{
//							//if ( Math.abs(_data.autoPassAngle - pwbd.dribble) < Math.PI * .5 || Math.abs(_data.autoPassAngle - pwbd.dribble) > Math.PI * 1.5)
//							//{
//						//	precisionPass();
//							pwbd.passNow = true;
//							//sbd.passReceiver = pwbd;
//							//}						
////						}				 
////					}
//					}
//				}							
//			}	

		
	}
}