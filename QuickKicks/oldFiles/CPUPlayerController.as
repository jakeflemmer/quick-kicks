package classes
{
	import classes.*;
	
	import flash.events.Event;
	
	
	public class CPUPlayerController extends AbstractPlayerController 
	{		
		
		protected var _challengeAngle:Number = 0;
		protected var _opponent:PlayerData;
		
		
		public function CPUPlayerController()
		{
			this.data.teamId = "blue";
			
			
		}
		
		
		
		
// ____________________________________________________________________________________________________________________
//  _________________________________   ON ENTER FRAME     ___________________________________________________________
//  ___________________________________________________________________________________________________________________
		
		override protected function ON_ENTER_FRAME(e:Event=null):void
		{			
			
			if (gsd.paused) return;
			
			if ( gsd.goalAnimation)
			{
				//moveToDestination();
				//checkMaxSpeed();
				//positionPlayer();
				return;
			}
			
		//=====================================  CPU MODE    ==================================================		
		
		if ( ! gsd.twoPlayerMode )
		{
			super.ON_ENTER_FRAME(e);
					
		} else
		
		//  ==============================  TWO PLAYER MODE  ==================================================		
		{ 
						
			if ( _data.isControlled ) respondToControls();	// respond to controls
						
			if ( _data.marking ) markPlayer(); // set destination to marked player
						
			if ( _data.passReceiver ) _data.gettingBall = true;
			
			if (_data.gettingBall ) getBall(); // set destinationx x,y to ball xpos, ypos							
			
			if (!_data.isControlled ) moveToDestination();			// set speedX,Y based on destination

			checkMaxSpeed();							
									
			factorInFriction();									
						
			checkFieldBounds();
				
			positionPlayer();  // change x,y based on speedX, speedY
												
			if ( _data.hasBall ) {
				calculateDirection();
				dribbleBall();
			}			
			
			if ( SoccerBallData.getInstance().isFree || SoccerBallData.getInstance().bluePossession ) hitTestBall();
		} // end if
		}


		// moved to abstractplayercontroller
//		protected function smartDefend():void
//		{
//			if (! SoccerBallData.getInstance().isFree)
//			{				
//				var xDistToBall:Number = SoccerBallData.getInstance().xPos - _data.xPos;
//				var yDistToBall:Number = SoccerBallData.getInstance().yPos - _data.yPos;
//				var totalDistToBall:Number = Math.sqrt((xDistToBall*xDistToBall) + (yDistToBall*yDistToBall));
//				
//				if (totalDistToBall < gsd.takeBallDistance)
//				{
//					getBall();		
//					return;
//				}
//		
//		
//				// same as mark player but markingDistance depends on ball carriers speed
//				if ( SoccerBallData.getInstance().ballCarrier == null ) return;				
//				var bc:PlayerData = SoccerBallData.getInstance().ballCarrier; // ball carrier				
//				var deltaX:Number = ( 1450 - bc.xPos );  // 1450 = goalCenterX
//				var deltaY:Number = ( 500 - bc.yPos );  //  500 = goalCenterY
//				var theAngleFromGoal:Number = radCalc.calc(deltaX,deltaY);
//				var bcd:Number = Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)); // ball carrier distance from goal
//				var sdd:Number = 0;// smart defender distance from ball carrier
//				var bcs:Number = Math.sqrt((bc.speedX*bc.speedX)+(bc.speedY*bc.speedY)); // ball carrier speed
//				var bcms:Number = gsd.redTeamMaxSpeed; // ball carrier max speed 
//				sdd = (bcs/bcms) * (gsd.playerRadius*3); // at max speed stay 3*radius away
//				_data.destinationX = (1475 - ( (bcd - sdd) * Math.cos(theAngleFromGoal)));
//				_data.destinationY = (500 - ( (bcd - sdd) * Math.sin(theAngleFromGoal)));
//			
//			}else
//			{				
//				getBall();
//			}
//		}
	
		
		
		//moved to abstractPlayerController
//		protected function speedEasing():void
//		{
//			var dX:Number = _data.destinationX - _data.xPos;
//			var dY:Number = _data.destinationY - _data.yPos;
//			var distToDest:Number = Math.sqrt((dX*dX)+(dY*dY));
//			
//			var spd:Number = Math.sqrt((_data.speedX*_data.speedX)+(_data.speedY*_data.speedY));
//			var aveSpd:Number = spd/2;
//			var acc:Number = gsd.blueTeamAcceleration;
//			var framesToStop:Number = spd/acc;
//	        var distToStop:Number = aveSpd * framesToStop;
//   	        var newVectorX:Number=0;
//	        var newVectorY:Number=0;
//	        
//	        if (distToDest <= distToStop)
//	        {
//	        	if ( spd > acc )
//	        	{
//	        		spd -= acc;
//	        		_data.speedX = spd * Math.cos(_data.direction);
//	        		_data.speedY = spd * Math.sin(_data.direction);
//	        	}else{
//	        		_data.speedX = 0; 
//	        		_data.speedY = 0;
//	        	}	        	
//	        }else{
//   				newVectorX = acc * Math.cos(_data.direction);
//	        	newVectorY = acc * Math.sin(_data.direction);	        	
//		        _data.speedX += newVectorX;
//				_data.speedY += newVectorY;
//	        }	        	
//		}
		protected function respondToControls():void
		{			
				if (KeyboardControls.getInstance().twoLeft)
				{					
					if (_data.speedX <= 0)	{
						_data.speedX -= gsd.blueTeamAcceleration;;						
					} else 	{
						_data.speedX -= gsd.gamePlayerDecelerationFactor*gsd.blueTeamAcceleration;}
				}
				if (KeyboardControls.getInstance().twoRight)
				{				
					if (_data.speedX >=0 )					{
						_data.speedX += gsd.blueTeamAcceleration;
					} else	{
						_data.speedX += gsd.gamePlayerDecelerationFactor*gsd.blueTeamAcceleration;
					}
				}
				if (KeyboardControls.getInstance().twoUp)
				{
					if (_data.speedY <= 0)	{
						_data.speedY -= gsd.blueTeamAcceleration;						
					} else 	{
						_data.speedY -= gsd.gamePlayerDecelerationFactor*gsd.blueTeamAcceleration;}
				}
				if (KeyboardControls.getInstance().twoDown){
					if (_data.speedY >=0 )					{
						_data.speedY += gsd.blueTeamAcceleration;
					} else	{
						_data.speedY += gsd.gamePlayerDecelerationFactor* gsd.blueTeamAcceleration;
					}
				}
							
				// dirbble controls				
				if (KeyboardControls.getInstance().dribbleCCW){
					_data.dribble -= .1;
				}
				if (KeyboardControls.getInstance().dribbleCW){
					_data.dribble += .1;
				}	
				if (KeyboardControls.getInstance().buildingKickPower){
					if (_data.hasBall ){
						_data.kickPower += _data.speedGenerateKickPower;												
					}				
				}
				if (KeyboardControls.getInstance().passBall){
					if ( _data.hasBall ) {
						//nobody listens to the below event
						dispatchEvent(new GameEvents(GameEvents.MANUAL_PASS));
						passBall();
					}
				}
				if (KeyboardControls.getInstance().twoPass){
					if ( _data.hasBall ) {
						dispatchEvent(new GameEvents(GameEvents.MANUAL_PASS));
						passBall();
					}
				}				
		}
		
		
		
//		protected function factorInFriction():void
//		{
//			if ( _data.speedX >= FieldData.getInstance().fieldFriction ) _data.speedX -= FieldData.getInstance().fieldFriction;
//			if ( _data.speedX <= (-1*FieldData.getInstance().fieldFriction) ) _data.speedX += FieldData.getInstance().fieldFriction;
//			if ( _data.speedY >= FieldData.getInstance().fieldFriction ) _data.speedY -= FieldData.getInstance().fieldFriction;
//			if ( _data.speedY <= (-1*FieldData.getInstance().fieldFriction) ) _data.speedY += FieldData.getInstance().fieldFriction;
//			// come to full stop
//			if ( _data.speedX < FieldData.getInstance().fieldFriction && _data.speedX > -1*FieldData.getInstance().fieldFriction ) _data.speedX = 0;
//			if ( _data.speedY < FieldData.getInstance().fieldFriction && _data.speedY > -1*FieldData.getInstance().fieldFriction ) _data.speedY = 0;
//		}
//		protected function passBall():void
//		{	
//			if ( _data.passPaused ) return;
//			SoccerBallData.getInstance().direction = _data.autoPassAngle;
//			//if (_data.kickPower <=10 ) _data.kickPower = 30;
//			//if (_data.kickPower >=40 ) _data.kickPower = 40;
//			
//			_data.kickPower = gsd.blueTeamKickPower;
//			if (_data.isKeeper ) _data.kickPower +=10;
//			SoccerBallController.getInstance().kick(_data.kickPower);
//			SoccerBallData.getInstance().isFree = true;
//			SoccerBallData.getInstance().justKicked = true;
//			KeyboardControls.getInstance().twoPass = false;
//			_data.kickPower = 0;
//			_data.hasBall = false;
//			_data.justPassed = true;
//			_data.passPaused = true;
//			_data.passNow = false;				
//			oldFrameNo = frameNo;			
//		}
//		protected function hitTestBall():void
//		{				
//			
//			var bX:Number = SoccerBallData.getInstance().xPos;
//			var bY:Number = SoccerBallData.getInstance().yPos;
//			var x:Number = _data.xPos;
//			var y:Number = _data.yPos;
//				
//			var xDistance:Number = Math.abs( x - bX );
//			var yDistance:Number =  Math.abs( y - bY );
//			var totalDistance:Number = xDistance + yDistance;		
//			
//			if ( totalDistance <= ( _data.radius * 2 ) )  // Got the ball!
//			{	
//				if ( _data.justBeaten || _data.justPassed){
//					//ballBounceOff();
//					return;
//				} 		
//				_data.hasBall = true;
//				_data.space = 10000;
//				_data.dispatchEvent(new Event("playerGotTheBall")); // listen for this event and calulate space the real way
//				_data.passPaused = true;
//				SoccerBallData.getInstance().isFree = false; 
//				SoccerBallData.getInstance().bluePossession = true;
//				SoccerBallData.getInstance().ballCarrier = _data;
//				var rC:RadiansCalculator = new RadiansCalculator;
//				_data.dribble = rC.calc( bX - x, bY - y );				
//			}				
//		}
		
		//moved to abstract player controller
//		protected function markPlayer():void
//		{// do player marking similarly to keeper tracking
//		// i.e calculate the angle of the marked player to the goal center
//		// set the defender destinations x and y	 to a position on the same angle but closer to the goal
//		// calculate the sum total distance of the marked man from goal
//		// place the defender x at cos (markedManAngle) * sum toal distance minus 100;
//		if ( _data.playerMarking == null ) return;
//				
//		var deltaX:Number = ( 1450 - _data.playerMarking.xPos );  // 1450 = goalCenterX
//		var deltaY:Number = ( 500 - _data.playerMarking.yPos );  //  500 = goalCenterY
//		var theAngleFromGoal:Number = radCalc.calc(deltaX,deltaY);
//		var markedTotalDistance:Number = Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)); 
//		var markingDistance:Number = gsd.markingDistance;		
//		
//		
//		_data.destinationX = (1475 - ( (markedTotalDistance - markingDistance) * Math.cos(theAngleFromGoal)));
//		_data.destinationY = (500 - ( (markedTotalDistance - markingDistance) * Math.sin(theAngleFromGoal)));
//		
//		}	
		
		private function ballBounceOff():void
		{
			// all that happens when ball bounces off player is that its direction changes based on its hit angle
			// if it hits at 0 degrees then its direction changes by 180 degrees
			// if it hits at 90 degrees then its direction doesnt change at all
			
			var plyrX:Number = _data.xPos;
			var plyrY:Number = _data.yPos;
			var ballX:Number = SoccerBallData.getInstance().xPos;
			var ballY:Number = SoccerBallData.getInstance().yPos;
		
			var ballDirection:Number = SoccerBallData.getInstance().direction;
			var hitAngle:Number = RadiansCalculator.calc( plyrX - ballX , plyrY - ballY );
		
			if ( Math.abs(ballDirection - hitAngle ) > Math.PI/2) return; // more than 90 degrees - no effect
		
			var newBallDirection:Number = ballDirection + Math.PI * ( ballDirection - hitAngle );
			SoccerBallData.getInstance().direction = newBallDirection; 
				
		}
	

	}// class
}//close package