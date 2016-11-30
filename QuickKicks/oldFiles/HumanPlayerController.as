package classes
{
	import flash.events.Event;


	public class HumanPlayerController extends AbstractPlayerController 
	{			
		public function HumanPlayerController()
		{			
			this.data.teamId = "red";
			super;
		}		
				
		//--------------------------------------------------------------------------------------------------
		// ON ENTER FRAME 
		//--------------------------------------------------------------------------------------------------
		
		override protected function ON_ENTER_FRAME(E:Event=null):void
		{
			if (gsd.paused) return;
			
			if ( gsd.goalAnimation)
			{
				//moveToDestination();
				//checkMaxSpeed();
				//positionPlayer();
				return;
			}
		//=========================   DEMO MODE   ============================	
		if (gsd.demoMode )
		{				
			
			super.ON_ENTER_FRAME(E);		
//			if ( _data.marking ) markPlayer(); // set destination to marked player
//			
//			if ( _data.gettingBall ) smartDefend(); // set destination to soccer ball position
//						
//			if ( _data.passNow ) passBall();	// pass the damn ball
//						
//			moveToDestination();		//  i.e set speedX and speedY based on destinations	
//												
//			checkMaxSpeed();		// adjust speed					
//
//			factorInFriction();		// adjust speed 									
//						  
//			checkFieldBounds();
//				
//			positionPlayer();  // change x,y based on speedX, speedY
//								
//			if ( _data.hasBall ) {
//				calculateDirection();
//				dribbleBall();
//			}					
//		
//			if ( SoccerBallData.getInstance().isFree || SoccerBallData.getInstance().bluePossession ) hitTestBall();
			
		} else
		//==========================  PLAY MODE   ==================================
		{	
			_data.totalFrameCount++;

			// KEYBOARD		
			if ( gsd.device == "keyboard")
			{
			
				if ( _data.isControlled ) respondToControls();	// respond to controls
						
				if ( _data.marking ) markPlayer(); // set destination to marked player
							
				if (!_data.isControlled ) moveToDestination();			// set speedX,Y based on destination
	
				checkMaxSpeed();							
									
				factorInFriction();									
						
				checkFieldBounds();
				
				positionPlayer();  // change x,y based on speedX, speedY
													
				if ( _data.hasBall ) {
					calculateDirection();
					dribbleBall();
				}			
			
				//hitTestBall();
				if ( SoccerBallData.getInstance().isFree || SoccerBallData.getInstance().bluePossession ) hitTestBall();
			}
			// PHONE 
			else if (gsd.device == "phone")
			{
						
				if ( _data.marking ) markPlayer(); // set destination to marked player							
			
				if (!_data.isControlled ) moveToDestination();			// set speedX,Y based on destination
	
				checkMaxSpeed();							
									
				factorInTouchPadFriction();									
						
				checkFieldBounds();
				
				if ( _data.isControlled )
				{
					//calculateDirection();
					respondToTouchPadControls();	// respond to controls - set direction and thrust					
				} 
								
				deriveSpeedXYFromDirectionAndThrust();  // set speedX , speedY based on direction and thrust					
				
				positionPlayer();  // change x,y based on speedX, speedY
				
				if ( _data.hasBall ) {
					dribbleBall();
				}			
							
				if ( SoccerBallData.getInstance().isFree || SoccerBallData.getInstance().bluePossession ) hitTestBall();				
							
			}
		
		}
		
		
	}// end function

		private function deriveSpeedXYFromDirectionAndThrust():void{
			
			_data.speedX = _data.thrust * Math.cos(_data.direction);
			_data.speedY = _data.thrust * Math.sin(_data.direction);
			
		}
		protected function factorInTouchPadFriction():void
		{
			if ( _data.thrust >= FieldData.getInstance().fieldFriction ) _data.thrust -= FieldData.getInstance().fieldFriction;			
			// come to full stop
			if ( _data.thrust < FieldData.getInstance().fieldFriction  ) _data.thrust = 0;			
		}	
		
		
		protected function respondToTouchPadControls():void
		{			
			var tp:TouchPad = TouchPad.getInstance();
			
			if ( tp.thrust )
			{ 
				var acc:Number = gsd.redTeamAcceleration;
				_data.thrust += acc;
				if ( _data.thrust > gsd.maxSpeed ) _data.thrust = gsd.maxSpeed;  // TODO not pythagorean
			}	
			
			if ( tp.spinCCW )
			{
				//spinCCW(_data);
				turnCCW();
			}
			if ( tp.spinCW )
			{
				//spinCW(_data);
				turnCW();
			}
						
			if (KeyboardControls.getInstance().passBall){
				if ( _data.hasBall ) {						
					dispatchEvent(new GameEvents(GameEvents.MANUAL_PASS));
					passBall();
				}
			}				
		}
		private function turnCW():void{
			_data.direction += gsd.dribbleAcceleration;
		}
		private function turnCCW():void{
			_data.direction -= gsd.dribbleAcceleration;
		}

		private function spinCW(pwbd:PlayerData):void{			
		
			if ( pwbd.direction > 0 && pwbd.direction < Math.PI/2)
			{
				pwbd.speedY += gsd.redTeamAcceleration/10;
				pwbd.speedX -= gsd.redTeamAcceleration/10;					
			}
			if ( pwbd.direction > (Math.PI/2) && pwbd.direction < Math.PI)
			{
				pwbd.speedX -= gsd.redTeamAcceleration/10;
				pwbd.speedY -= gsd.redTeamAcceleration/10;
			}
			if ( pwbd.direction > (Math.PI) && pwbd.direction < (Math.PI/2)*3)
			{
				pwbd.speedY -= gsd.redTeamAcceleration/10;
				pwbd.speedX += gsd.redTeamAcceleration/10;
			}
			if ( pwbd.direction > (Math.PI/2)*3 && pwbd.direction < Math.PI*2)
			{
				pwbd.speedX += gsd.redTeamAcceleration/10;
				pwbd.speedY += gsd.redTeamAcceleration/10;
			}
		}
		private function spinCCW(pwbd:PlayerData):void{
		
			if ( pwbd.direction > (Math.PI/2)*3 && pwbd.direction < Math.PI*2) // quadrant IV
			{
				pwbd.speedY -= gsd.redTeamAcceleration/10;
				pwbd.speedX -= gsd.redTeamAcceleration/10;
			}
			if ( pwbd.direction > (Math.PI) && pwbd.direction < (Math.PI/2)*3)
			{
				pwbd.speedX -= gsd.redTeamAcceleration/10;
				pwbd.speedY += gsd.redTeamAcceleration/10;
			}
			if ( pwbd.direction > (Math.PI/2) && pwbd.direction < Math.PI)
			{
				pwbd.speedY += gsd.redTeamAcceleration/10;
				pwbd.speedX += gsd.redTeamAcceleration/10;
			}
			if ( pwbd.direction > 0 && pwbd.direction < Math.PI/2)
			{
				pwbd.speedX += gsd.redTeamAcceleration/10;
				pwbd.speedY -= gsd.redTeamAcceleration/10;
			}
		}
		
		protected function respondToControls():void
		{			
				if (KeyboardControls.getInstance().leftKey)
				{					
					if (_data.speedX <= 0)	{
						_data.speedX -= gsd.redTeamAcceleration;;						
					} else 	{
						_data.speedX -= gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;}
				}
				if (KeyboardControls.getInstance().rightKey)
				{				
					if (_data.speedX >=0 )					{
						_data.speedX += gsd.redTeamAcceleration;
					} else	{
						_data.speedX += gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;
					}
				}
				if (KeyboardControls.getInstance().upKey)
				{
					if (_data.speedY <= 0)	{
						_data.speedY -= gsd.redTeamAcceleration;						
					} else 	{
						_data.speedY -= gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;}
				}
				if (KeyboardControls.getInstance().downKey){
					if (_data.speedY >=0 )					{
						_data.speedY += gsd.redTeamAcceleration;
					} else	{
						_data.speedY += gsd.gamePlayerDecelerationFactor* gsd.redTeamAcceleration;
					}
				}
				
				if (KeyboardControls.getInstance().upLeftKey)
				{
					if (_data.speedX <= 0)	{
						_data.speedX -= gsd.redTeamAcceleration;						
					} else 	{
						_data.speedX -= gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;}
					if (_data.speedY <= 0)	{
						_data.speedY -= gsd.redTeamAcceleration;						
					} else 	{
						_data.speedY -= gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;}
				}
				
				if (KeyboardControls.getInstance().upRightKey)
				{
					if (_data.speedY <= 0)	{
						_data.speedY -= gsd.redTeamAcceleration;						
					} else 	{
						_data.speedY -= gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;}
					if (_data.speedX >=0 )					{
						_data.speedX += gsd.redTeamAcceleration;
					} else	{
						_data.speedX += gsd.gamePlayerDecelerationFactor* gsd.redTeamAcceleration;
					}
				}
				
				if (KeyboardControls.getInstance().downLeftKey){
					if (_data.speedY >=0 )					{
						_data.speedY += gsd.redTeamAcceleration;
					} else	{
						_data.speedY += gsd.gamePlayerDecelerationFactor* gsd.redTeamAcceleration;
					}				
					if (_data.speedX <= 0)	{
						_data.speedX -= gsd.redTeamAcceleration;						
					} else 	{
						_data.speedX -= gsd.gamePlayerDecelerationFactor*gsd.redTeamAcceleration;}
				}
				if (KeyboardControls.getInstance().downRightKey){
					if (_data.speedY >=0 )					{
						_data.speedY += gsd.redTeamAcceleration;
					} else	{
						_data.speedY += gsd.gamePlayerDecelerationFactor* gsd.redTeamAcceleration;
					}				
					if (_data.speedX >=0 )					{
						_data.speedX += gsd.redTeamAcceleration;
					} else	{
						_data.speedX += gsd.gamePlayerDecelerationFactor* gsd.redTeamAcceleration;
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
						dispatchEvent(new GameEvents(GameEvents.MANUAL_PASS));
						passBall();
					}
				}				
		}
		
//		private function spinCW(pwbd:PlayerData):void{			
//		
//			if ( pwbd.direction > 0 && pwbd.direction < Math.PI/2)
//			{
//				pwbd.destinationY = pwbd.yPos + 100;
//				pwbd.destinationX = pwbd.xPos - 100;					
//			}
//			if ( pwbd.direction > (Math.PI/2) && pwbd.direction < Math.PI)
//			{
//				pwbd.destinationX = pwbd.xPos - 100;
//				pwbd.destinationY = pwbd.yPos - 100;
//			}
//			if ( pwbd.direction > (Math.PI) && pwbd.direction < (Math.PI/2)*3)
//			{
//				pwbd.destinationY = pwbd.yPos - 100;
//				pwbd.destinationX = pwbd.xPos + 100;
//			}
//			if ( pwbd.direction > (Math.PI/2)*3 && pwbd.direction < Math.PI*2)
//			{
//				pwbd.destinationX = pwbd.xPos + 100;
//				pwbd.destinationY = pwbd.yPos + 100;
//			}
//		}
//		private function spinCCW(pwbd:PlayerData):void{
//		
//			if ( pwbd.direction > (Math.PI/2)*3 && pwbd.direction < Math.PI*2) // quadrant IV
//			{
//				pwbd.destinationY = pwbd.yPos - 100;
//				pwbd.destinationX = pwbd.xPos - 100;
//			}
//			if ( pwbd.direction > (Math.PI) && pwbd.direction < (Math.PI/2)*3)
//			{
//				pwbd.destinationX = pwbd.xPos - 100;
//				pwbd.destinationY = pwbd.yPos + 100;
//			}
//			if ( pwbd.direction > (Math.PI/2) && pwbd.direction < Math.PI)
//			{
//				pwbd.destinationY = pwbd.yPos + 100;
//				pwbd.destinationX = pwbd.xPos + 100;
//			}
//			if ( pwbd.direction > 0 && pwbd.direction < Math.PI/2)
//			{
//				pwbd.destinationX = pwbd.xPos + 100;
//				pwbd.destinationY = pwbd.yPos - 100;
//			}
//		}
		
		//==========================================================================================================
		//  OLD CODE
		//==========================================================================================================
		
//		private function ballBounceOff():void
//		{
//			// all that happens when ball bounces off player is that its direction changes based on its hit angle
//			// if it hits at 0 degrees then its direction changes by 180 degrees
//			// if it hits at 90 degrees then its direction doesnt change at all
//			
//			var plyrX:Number = _data.xPos;
//			var plyrY:Number = _data.yPos;
//			var ballX:Number = SoccerBallData.getInstance().xPos;
//			var ballY:Number = SoccerBallData.getInstance().yPos;
//		
//			var ballDirection:Number = SoccerBallData.getInstance().direction;
//			var hitAngle:Number = RadiansCalculator.calc( plyrX - ballX , plyrY - ballY );
//		
//			if ( Math.abs(ballDirection - hitAngle ) > Math.PI/2) return; // more than 90 degrees - no effect
//		
//			var newBallDirection:Number = ballDirection + Math.PI * ( ballDirection - hitAngle );
//			SoccerBallData.getInstance().direction = newBallDirection; 
//				
//		}
		
		//		protected function checkMaxSpeed():void
//		{
//			if (_data.speedX >= gsd.redTeamMaxSpeed ) _data.speedX = gsd.redTeamMaxSpeed;
//			if (_data.speedX <= (-gsd.redTeamMaxSpeed) ) _data.speedX = (-gsd.redTeamMaxSpeed);
//			if (_data.speedY >= gsd.redTeamMaxSpeed ) _data.speedY = gsd.redTeamMaxSpeed;
//			if (_data.speedY <= (-gsd.redTeamMaxSpeed) ) _data.speedY = (-gsd.redTeamMaxSpeed);
//		}
		
//		protected function checkFieldBounds():void
//		{
//			if ( _data.isKeeper )
//			{
//				if ( _data.xPos >= (450 - _data.radius  )){
//					_data.xPos = ( 450 - _data.radius  ) - 5;
//					_data.speedX = 0;
//				}
//				if ( _data.xPos <=  (50 + _data.radius) ){
//					_data.xPos = 55 + _data.radius;
//					_data.speedX = 0;
//				}
//				if ( _data.yPos >= ( 750 - _data.radius )){
//					_data.yPos = ( 750 - _data.radius ) - 5;
//					_data.speedY = 0;
//				}
//				if ( _data.yPos <= (250 + _data.radius) ){
//					_data.yPos = 250 + _data.radius + 5;
//					_data.speedY = 0;
//				}			
//				return;
//			}
//			if ( ! _data.hasBall )
//			{
//				if ( _data.xPos >= (1500 - _data.radius - 50 )){
//					_data.xPos = ( 1500 - _data.radius - 50 ) - 5;
//					_data.speedX = 0;
//				}
//				if ( _data.xPos <=  (50 + _data.radius) ){
//					_data.xPos = 55 + _data.radius;
//					_data.speedX = 0;
//				}
//				if ( _data.yPos >= (1000 - _data.radius - 50 )){
//					_data.yPos = ( 1000 - _data.radius - 50 ) - 5;
//					_data.speedY = 0;
//				}
//				if ( _data.yPos <= (50 + _data.radius) ){
//					_data.yPos = 55 + _data.radius;
//					_data.speedY = 0;
//				}
//			} else {      // smaller bounds with ball so ball doesn't go through the wall.
//				if ( _data.xPos >= ( 1500 - _data.radius - 50 - SoccerBallData.getInstance().radius)){
//					_data.xPos = ( 1500 - _data.radius - 50 - SoccerBallData.getInstance().radius) - 5;
//					_data.speedX = 0;
//				}
//				if ( _data.xPos <=  (50 + _data.radius + SoccerBallData.getInstance().radius) ){
//					_data.xPos = 55 + _data.radius + SoccerBallData.getInstance().radius;
//					_data.speedX = 0;
//				}
//				if ( _data.yPos >= (1000 - _data.radius - 50 - SoccerBallData.getInstance().radius)){
//					_data.yPos = ( 1000 - _data.radius - 50 - SoccerBallData.getInstance().radius) - 5;
//					_data.speedY = 0;
//				}
//				if ( _data.yPos <= (50 + _data.radius + SoccerBallData.getInstance().radius) ){
//					_data.yPos = 55 + _data.radius + SoccerBallData.getInstance().radius;
//					_data.speedY = 0;
//				}
//			}
//		} 
		
		// moved to abstract player controller
//		protected function markPlayer():void
//		{// do player marking similarly to keeper tracking
//		// i.e calculate the angle of the marked player to the goal center
//		// set the defender destinations x and y	 to a position on the same angle but closer to the goal
//		// calculate the sum total distance of the marked man from goal
//		// place the defender x at cos (markedManAngle) * sum toal distance minus 100;
//		if ( _data.playerMarking == null ) return;
//				
//		var radCalc:RadiansCalculator = new RadiansCalculator;
//		
//		var deltaX:Number = ( 50 - _data.playerMarking.xPos );  // 50 = goalCenterX
//		var deltaY:Number = ( 500 - _data.playerMarking.yPos );  //  500 = goalCenterY
//		
//		var theAngleFromGoal:Number = radCalc.calc(deltaX,deltaY);
//		var xDistanceFromGoal:Number = _data.playerMarking.xPos - 50;
//		var yDistanceFromGoal:Number = 500 - _data.playerMarking.yPos;
//		
//		_data.destinationX = (25 - ( (xDistanceFromGoal - gsd.playerRadius *3 ) * Math.cos(theAngleFromGoal)));
//		_data.destinationY = 500 - yDistanceFromGoal ;		
//	
//		
//		}	
//  _________________________________________________________________________________________________________________________________________
//  _________________________________________________________________________________________________________________________________________
		
		//moved to abstract player controller
//		protected function smartDefend():void
//		{
//			// smart defend means that the defender is not dumb and doesn't allow themselves to get turned easily
//			// they do this by staying between the ball carrier and their goal
//			// obviously if the ball is free then it's not necessary
//			if (sbd.bluePossession)
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
//				// same as mark player but markingDistance depends on ball carriers speed
//				if ( SoccerBallData.getInstance().ballCarrier == null ) return;				
//				var bc:PlayerData = SoccerBallData.getInstance().ballCarrier; // ball carrier				
//				
//				var deltaX:Number = ( bc.xPos - 50);  // 50 = goalCenterX
//				var deltaY:Number = ( 500 - bc.yPos );  //  500 = goalCenterY
//				var theAngleFromGoal:Number = radCalc.calc(deltaX,deltaY);
//				var bcd:Number = Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)); // ball carrier distance from goal
//				var sdd:Number = 0;// smart defender distance from ball carrier
//				var bcs:Number = Math.sqrt((bc.speedX*bc.speedX)+(bc.speedY*bc.speedY)); // ball carrier speed
//				var bcms:Number = gsd.blueTeamMaxSpeed; // ball carrier max speed 
//				sdd = (bcs/bcms) * (gsd.playerRadius*3); // at max speed stay 3*radius away
//				_data.destinationX = (25 + ( (bcd - sdd) * Math.cos(theAngleFromGoal)));
//				_data.destinationY = (500 - ( (bcd - sdd) * Math.sin(theAngleFromGoal)));
//			
//			}		
//			else
//			{				
//				getBall();
//			}
//		}
	
		// moved to AbstractPlayerController
//		protected function moveToDestination():void
//		{	// keep players within bounds
//			if ( ! _data.gettingBall ) {	
//				if ( _data.destinationX <= 100 ) _data.destinationX = 100;
//				if ( _data.destinationX >= 1400 ) _data.destinationX = 1400;			
//			}
//			if ( _data.justBeaten ) {		// just beaten player destinations x,y = current x, y
//				_data.destinationX = _data.xPos;
//				_data.destinationY = _data.yPos;
//			}	
//								
//			_data.direction	= radCalc.calc(_data.destinationX - _data.xPos, _data.destinationY - _data.yPos);
//	        	        
//			speedEasing();			
//		}	
		
			
					
	} // close class
} // close package