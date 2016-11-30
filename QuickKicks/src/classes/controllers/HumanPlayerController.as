package classes.controllers
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import classes.data.FieldData;
	import classes.data.PlayerData;
	import classes.data.SoccerBallData;
	import classes.events.GameEvents;
	import classes.tools.Calculator;
	import classes.tools.RadiansCalculator;
	import classes.views.PlayerView;


	public class HumanPlayerController extends AbstractPlayerController 
	{			
		public function HumanPlayerController(isKeeper:Boolean = false)
		{			
			_data = new PlayerData();
			_data.teamId = "red";
			_data.isKeeper = ( isKeeper ? true : false );
			_view = new PlayerView(_data);
			
			addChild(_view);
			
		}
		
				
		
//  ____________________________________________________    ON ENTER  FRAME      _____________________________________________________	
//  ____________________________________________________________________________________________________________________________________
//  ___________________________________________________________________________________________________________________________________

		override protected function ON_ENTER_FRAME(E:Event=null):void
		{
			if (gsd.paused) return;
			
			if ( gsd.goalAnimation)
			{
				moveToDestination();
				checkMaxSpeed();
				positionPlayer();
				return;
			}
		//=========================   DEMO MODE   ============================	
		if (gsd.demoMode )
		{	// cpu player's on enter frame			
				
			frameNumber();
			
			if ( _data.marking ) markPlayer(); // set destination to marked player
			
			if ( _data.gettingBall ) smartDefend(); // set destination to soccer ball position
						
			if ( _data.passNow ) passBall();	// pass the damn ball
						
			moveToDestination();		//  i.e set speedX and speedY based on destinations	
												
			checkMaxSpeed();		// adjust speed					

			factorInFriction();		// adjust speed 									
						  
			checkFieldBounds();
				
			positionPlayer();  // change x,y based on speedX, speedY
								
			if ( _data.hasBall ) {
				calculateDirection();
				dribbleBall();
			}			
						
			if ( SoccerBallData.getInstance().isFree || SoccerBallData.getInstance().bluePossession ) hitTestBall();
			
		} else
		//==========================  PLAY MODE   ==================================
		{
			frameNumber();
			
			if ( _data.isControlled ) respondToControls();	// respond to controls
						
			if ( _data.marking ) markPlayer(); // set destination to marked player
						
			if ( _data.passReceiver && SoccerBallData.getInstance().isFree ) getBall(); // set destinationx x,y to ball xpos, ypos							
			
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
//  _________________________________________________________________________________________________________________________________________
//  _________________________________________________________________________________________________________________________________________
		
		protected function smartDefend():void
		{
			if (SoccerBallData.getInstance().bluePossession)
			{				
				var xDistToBall:Number = SoccerBallData.getInstance().xPos - _data.xPos;
				var yDistToBall:Number = SoccerBallData.getInstance().yPos - _data.yPos;
				var totalDistToBall:Number = Math.sqrt((xDistToBall*xDistToBall) + (yDistToBall*yDistToBall));
				
				if (totalDistToBall < gsd.takeBallDistance)
				{
					getBall();		
					return;
				}		
		
				// same as mark player but markingDistance depends on ball carriers speed
				if ( SoccerBallData.getInstance().ballCarrier == null ) return;				
				var bc:PlayerData = SoccerBallData.getInstance().ballCarrier; // ball carrier				
				var deltaX:Number = ( bc.xPos - 50);  // 50 = goalCenterX
				var deltaY:Number = ( 500 - bc.yPos );  //  500 = goalCenterY
				var theAngleFromGoal:Number = RadiansCalculator.calc(deltaX,deltaY);
				var bcd:Number = Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)); // ball carrier distance from goal
				var sdd:Number = 0;// smart defender distance from ball carrier
				var bcs:Number = Math.sqrt((bc.speedX*bc.speedX)+(bc.speedY*bc.speedY)); // ball carrier speed
				var bcms:Number = gsd.blueTeamMaxSpeed; // ball carrier max speed 
				sdd = (bcs/bcms) * (gsd.playerRadius*3); // at max speed stay 3*radius away
				_data.destinationX = (25 + ( (bcd - sdd) * Math.cos(theAngleFromGoal)));
				_data.destinationY = (500 - ( (bcd - sdd) * Math.sin(theAngleFromGoal)));
			
			}else
			{				
				getBall();
			}
		}
	
		protected function moveToDestination():void
		{	// keep players within bounds
		if ( ! _data.gettingBall ) {	
			if ( _data.destinationX <= 100 ) _data.destinationX = 100;
			if ( _data.destinationX >= 1400 ) _data.destinationX = 1400;			
		}
		if ( _data.justBeaten ) 		// just beaten player destinations x,y = current x, y
		{
			_data.destinationX = _data.xPos;
			_data.destinationY = _data.yPos;
		}							
			_data.direction	= RadiansCalculator.calc(_data.destinationX - _data.xPos, _data.destinationY - _data.yPos);
	        	        
			speedEasing();			
		}	
		protected function speedEasing():void
		{
			var dX:Number = _data.destinationX - _data.xPos;
			var dY:Number = _data.destinationY - _data.yPos;
			var distToDest:Number = Math.sqrt((dX*dX)+(dY*dY));
			
			var spd:Number = Math.sqrt((_data.speedX*_data.speedX)+(_data.speedY*_data.speedY));
			var aveSpd:Number = spd/2;
			var acc:Number = gsd.redTeamAcceleration;
			var framesToStop:Number = spd/acc;
	        var distToStop:Number = aveSpd * framesToStop;
   	        var newVectorX:Number=0;
	        var newVectorY:Number=0;
	        
	        if (distToDest <= distToStop)
	        {
	        	if ( spd > acc )
	        	{
	        		spd -= acc;
	        		_data.speedX = spd * Math.cos(_data.direction);
	        		_data.speedY = spd * Math.sin(_data.direction);
	        	}else{
	        		_data.speedX = 0; 
	        		_data.speedY = 0;
	        	}	        	
	        }else{
   				newVectorX = acc * Math.cos(_data.direction);
	        	newVectorY = acc * Math.sin(_data.direction);	        	
		        _data.speedX += newVectorX;
				_data.speedY += newVectorY;
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
		protected function passBall():void
		{
			
//			SoccerBallData.getInstance().direction = _data.autoPassAngle;
//			//if (_data.kickPower <=30 ) _data.kickPower = 30;
//			//if (_data.kickPower >=40 ) _data.kickPower = 40;
//			_data.kickPower = gsd.redTeamKickPower;
//			if (_data.isKeeper ) _data.kickPower += 10;			
//			SoccerBallController.getInstance().kick(_data.kickPower);
//			SoccerBallData.getInstance().isFree = true;
//			SoccerBallData.getInstance().justKicked = true;
//			KeyboardControls.getInstance().passBall = false;
//			_data.kickPower = 0;
//			_data.hasBall = false;
//			_data.justPassed = true;
//		
//			_data.passNow = false;		
			
			Calculator.instance.precisionPass( _data );
		}
		protected function checkMaxSpeed():void
		{
			if (_data.speedX >= gsd.redTeamMaxSpeed ) _data.speedX = gsd.redTeamMaxSpeed;
			if (_data.speedX <= (-gsd.redTeamMaxSpeed) ) _data.speedX = (-gsd.redTeamMaxSpeed);
			if (_data.speedY >= gsd.redTeamMaxSpeed ) _data.speedY = gsd.redTeamMaxSpeed;
			if (_data.speedY <= (-gsd.redTeamMaxSpeed) ) _data.speedY = (-gsd.redTeamMaxSpeed);
		}
		
		protected function checkFieldBounds():void
		{
			if ( _data.isKeeper )
			{
				if ( _data.xPos >= (450 - _data.radius  )){
					_data.xPos = ( 450 - _data.radius  ) - 5;
					_data.speedX = 0;
				}
				if ( _data.xPos <=  (50 + _data.radius) ){
					_data.xPos = 55 + _data.radius;
					_data.speedX = 0;
				}
				if ( _data.yPos >= ( 750 - _data.radius )){
					_data.yPos = ( 750 - _data.radius ) - 5;
					_data.speedY = 0;
				}
				if ( _data.yPos <= (250 + _data.radius) ){
					_data.yPos = 250 + _data.radius + 5;
					_data.speedY = 0;
				}			
				return;
			}
			if ( ! _data.hasBall )
			{
				if ( _data.xPos >= (1500 - _data.radius - 50 )){
					_data.xPos = ( 1500 - _data.radius - 50 ) - 5;
					_data.speedX = 0;
				}
				if ( _data.xPos <=  (50 + _data.radius) ){
					_data.xPos = 55 + _data.radius;
					_data.speedX = 0;
				}
				if ( _data.yPos >= (1000 - _data.radius - 50 )){
					_data.yPos = ( 1000 - _data.radius - 50 ) - 5;
					_data.speedY = 0;
				}
				if ( _data.yPos <= (50 + _data.radius) ){
					_data.yPos = 55 + _data.radius;
					_data.speedY = 0;
				}
			} else {      // smaller bounds with ball so ball doesn't go through the wall.
				if ( _data.xPos >= ( 1500 - _data.radius - 50 - SoccerBallData.getInstance().radius)){
					_data.xPos = ( 1500 - _data.radius - 50 - SoccerBallData.getInstance().radius) - 5;
					_data.speedX = 0;
				}
				if ( _data.xPos <=  (50 + _data.radius + SoccerBallData.getInstance().radius) ){
					_data.xPos = 55 + _data.radius + SoccerBallData.getInstance().radius;
					_data.speedX = 0;
				}
				if ( _data.yPos >= (1000 - _data.radius - 50 - SoccerBallData.getInstance().radius)){
					_data.yPos = ( 1000 - _data.radius - 50 - SoccerBallData.getInstance().radius) - 5;
					_data.speedY = 0;
				}
				if ( _data.yPos <= (50 + _data.radius + SoccerBallData.getInstance().radius) ){
					_data.yPos = 55 + _data.radius + SoccerBallData.getInstance().radius;
					_data.speedY = 0;
				}
			}
		} 
		protected function factorInFriction():void
		{
			if ( _data.speedX >= FieldData.getInstance().fieldFriction ) _data.speedX -= FieldData.getInstance().fieldFriction;
			if ( _data.speedX <= (-1*FieldData.getInstance().fieldFriction) ) _data.speedX += FieldData.getInstance().fieldFriction;
			if ( _data.speedY >= FieldData.getInstance().fieldFriction ) _data.speedY -= FieldData.getInstance().fieldFriction;
			if ( _data.speedY <= (-1*FieldData.getInstance().fieldFriction) ) _data.speedY += FieldData.getInstance().fieldFriction;
			// come to full stop
			if ( _data.speedX < FieldData.getInstance().fieldFriction && _data.speedX > -1*FieldData.getInstance().fieldFriction ) _data.speedX = 0;
			if ( _data.speedY < FieldData.getInstance().fieldFriction && _data.speedY > -1*FieldData.getInstance().fieldFriction ) _data.speedY = 0;
		}
		protected function markPlayer():void
		{// do player marking similarly to keeper tracking
		// i.e calculate the angle of the marked player to the goal center
		// set the defender destinations x and y	 to a position on the same angle but closer to the goal
		// calculate the sum total distance of the marked man from goal
		// place the defender x at cos (markedManAngle) * sum toal distance minus 100;
		if ( _data.playerMarking == null ) return;
				
		var radCalc:RadiansCalculator = new RadiansCalculator;
		
		var deltaX:Number = ( 50 - _data.playerMarking.xPos );  // 50 = goalCenterX
		var deltaY:Number = ( 500 - _data.playerMarking.yPos );  //  500 = goalCenterY
		
		var theAngleFromGoal:Number = RadiansCalculator.calc(deltaX,deltaY);
		var xDistanceFromGoal:Number = _data.playerMarking.xPos - 50;
		var yDistanceFromGoal:Number = 500 - _data.playerMarking.yPos;
		
		_data.destinationX = (25 - ( (xDistanceFromGoal - gsd.playerRadius *3 ) * Math.cos(theAngleFromGoal)));
		_data.destinationY = 500 - yDistanceFromGoal ;		
	
		
		}	
		
		
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
		
		
		
			
					
	} // close class
} // close package