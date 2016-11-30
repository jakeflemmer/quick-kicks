package classes
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class AbstractPlayerController extends Sprite 
	{
		
		protected var frameNo:uint;
		protected var oldFrameNo:uint;
		protected var radCalc:RadiansCalculator = new RadiansCalculator;
		
		protected var _data:PlayerData;	
		protected var _view:PlayerView;
		
		//--------------------------------------------------------------------------------------------------
		
		public function AbstractPlayerController():void
		{
			_data = new PlayerData;
			_view = new PlayerView(_data);
			
			addChild(_view);			
			
			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);
			
		}
		
		//--------------------------------------------------------------------------------------------------
		// ON ENTER FRAME
		//--------------------------------------------------------------------------------------------------
		
		protected function ON_ENTER_FRAME(e:Event = null):void
		{
			if(_data.teamId == "blue" ) return;
			
			_data.totalFrameCount++;			
								
			if ( _data.marking ) markPlayer(); // set destination to marked player

						
			if ( _data.gettingBall ) 
			{				
			//	if ( (SmartDefender.closeEnoughToTakeBall(_data)) || sbd.isFree || _data.isKeeper )
			//	{
					getBall();  // set destination to soccer ball position
			//	}else{
			//		smartDefend();  // keep defender between player with ball and goal				
			//	}
			}				
									
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
		
			if ( shouldHitTestBall() ) hitTestBall();
			
		}
		
		//--------------------------------------------------------------------------------------------------
		// DELEGATED MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		protected function checkFieldBounds():void{
			
			_data = FieldBoundsChecker.getInstance().checkFieldBounds(this._data);
		}
		
		protected function smartDefend():void{
			this._data = SmartDefender.smartDefend(_data);
		}
		
		
		//--------------------------------------------------------------------------------------------------
		// PROTECTED MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		protected function positionPlayer():void
		{
			_data.xPos += _data.speedX;
			_data.yPos += _data.speedY;			
		}
		
		protected function moveToDestination():void
		{	
			//if ( isNaN(_data.destinationX) || isNaN(_data.destinationY) ) throw new Error("player doesn't have destination set");
			// keep players within bounds
			
			if ( _data.isKeeper && _data.teamId == "red" && _data.destinationX > 125 ) throw new Error("bad keeper destination");
			
			if ( ! _data.gettingBall ) {	
				if ( _data.destinationX <= 100 ) 
				{
					_data.destinationX = 100;
					//trace("player " + _data.id + "  is having their destination kept at 100");
				}
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
		
		protected function checkMaxSpeed():void
		{		
			//TODO not pythagorean !!	
//			if ( _data.teamId == "blue" )
//			{
				if (_data.speedX >= gsd.maxSpeed ) _data.speedX = gsd.maxSpeed;
				if (_data.speedX <= (-gsd.maxSpeed) ) _data.speedX = (-gsd.maxSpeed);
				if (_data.speedY >= gsd.maxSpeed ) _data.speedY = gsd.maxSpeed;
				if (_data.speedY <= (-gsd.maxSpeed) ) _data.speedY = (-gsd.maxSpeed);
//			} 
//			else if (_data.teamId == "red" )
//			{			
//				if (_data.speedX >= gsd.redTeamMaxSpeed ) _data.speedX = gsd.redTeamMaxSpeed;
//				if (_data.speedX <= (-gsd.redTeamMaxSpeed) ) _data.speedX = (-gsd.redTeamMaxSpeed);
//				if (_data.speedY >= gsd.redTeamMaxSpeed ) _data.speedY = gsd.redTeamMaxSpeed;
//				if (_data.speedY <= (-gsd.redTeamMaxSpeed) ) _data.speedY = (-gsd.redTeamMaxSpeed);
//			} 
//			else 
//			{
//				throw new Error("player data does not have it's team id set correctly");
//			}
			
			
		}
		
		protected function hitTestBall():void{
			
			var bX:Number = SoccerBallData.getInstance().xPos;
			var bY:Number = SoccerBallData.getInstance().yPos;
			var x:Number = _data.xPos;
			var y:Number = _data.yPos;
				
			var xDistance:Number =  x - bX ;
			var yDistance:Number =  y - bY ;
			var totalDistance:Number = Math.sqrt( (xDistance*xDistance) + (yDistance*yDistance) );		
			
			if ( totalDistance <= ( _data.radius * 2 ) )  // Got the ball!  HARD CODING here
			{	
				if ( _data.justBeaten || _data.justPassed){
					//ballBounceOff();
					return;
				} 				
				_data.hasBall = true;
				_data.passPaused = true;
				sbd.isFree = false; 
				sbd.redPossession = (_data.teamId == "red" ? true:false);
				sbd.bluePossession = (_data.teamId == "blue" ? true:false);
				sbd.ballCarrier = _data;
							
				_data.dribble = RadiansCalculator.calc( bX - x, bY - y );			
		 
				var ge:GameEvents = new GameEvents(GameEvents.PLAYER_JUST_GOT_BALL);
				ge.playerWhoJustGotBall = this;
				this.dispatchEvent(ge);	
			}
		}		
		
		protected function calculateDirection():void{
			
			if ( _data.speedX == 0 && _data.speedY == 0 ) return;			
			_data.direction = RadiansCalculator.calc( _data.speedX , _data.speedY );			
		}
		
		protected function markPlayer():void
		{// do player marking similarly to keeper tracking
		// i.e calculate the angle of the marked player to the goal center
		// set the defender destinations x and y	 to a position on the same angle but closer to the goal
		// calculate the sum total distance of the marked man from goal
		// place the defender x at cos (markedManAngle) * sum toal distance minus 100;
		if ( _data.hasBall ) throw new Error("pwbd should not be marking!");
		if ( _data.isKeeper ) return;
		if ( _data.playerMarking == null )
		{
			throw new Error("playermarking is null ?!");
		}
		var c:Calculator = Calculator.instance;
		if ( _data.playerMarking.passReceiver )
		{
			if ( c.distanceFromBall(_data) < gsd.takeBallDistance || c.distanceFromBall(_data)+gsd.playerRadius < c.distanceFromBall(_data.playerMarking) )
			{
				getBall();			
				return;
			}
		}	
		var goalCenterX:uint = (_data.teamId == "blue"?1450:50);	
		var deltaX:Number = ( goalCenterX - _data.playerMarking.xPos );  // 1450 = goalCenterX
		var deltaY:Number = ( 500 - _data.playerMarking.yPos );  //  500 = goalCenterY
		var theAngleFromGoal:Number = RadiansCalculator.calc(deltaX,deltaY);
		var markedTotalDistance:Number = Math.sqrt((deltaX*deltaX)+(deltaY*deltaY)); 
		var markingDistance:Number = gsd.markingDistance;		
		
		var theX:uint = (_data.teamId == "blue"?1475:25);
		_data.destinationX = (theX - ( (markedTotalDistance - markingDistance) * Math.cos(theAngleFromGoal)));
		_data.destinationY = (500 - ( (markedTotalDistance - markingDistance) * Math.sin(theAngleFromGoal)));
		
		keepPlayersMarkingDestinationWithinZone(); // if the player they are marking is not getting the ball or doesn't have the ball
		
		}
		
		private function keepPlayersMarkingDestinationWithinZone():void{
			
			if ( _data.playerMarking.gettingBall || _data.playerMarking.hasBall ) return;
			
			if ( _data.destinationX > _data.zone.maxX ) _data.destinationX = _data.zone.maxX;
			if ( _data.destinationX < _data.zone.minX ) _data.destinationX = _data.zone.minX;
			if ( _data.destinationY > _data.zone.maxY ) _data.destinationY = _data.zone.maxY;
			if ( _data.destinationY < _data.zone.minY ) _data.destinationY = _data.zone.minY;
		}
			
		protected function dribbleBall():void
		{					
		 //	if ( _data.speedX == 0 && _data.speedY == 0 ) return;		 			
							
			var drib : Number = _data.dribble;
			var dir : Number = _data.direction;

			// add acceleration to velocity
			var acc:Number = GameSettingsData.getInstance().dribbleAcceleration;
			var maxSpeed:Number = GameSettingsData.getInstance().maxDribbleSpeed;				
			
			// dir = 6 dib = .5
			if ( Math.abs( drib - dir ) <= acc || Math.abs( drib - dir ) >= Math.PI*2 - acc )
			{
				_data.dribble = _data.direction;
			}
			else
			{
				if ( dir > drib )
				{
					if ( dir - drib < Math.PI ) {
						_data.dribbleVelocity += acc ;
					} 			
					if ( dir - drib > Math.PI ){ 
						_data.dribbleVelocity -= acc ;					
					}  
				}	
				if ( drib > dir )
				{			
					if ( drib - dir < Math.PI ){
						_data.dribbleVelocity -= acc ;
					}  			
					if ( drib - dir > Math.PI ) {
						_data.dribbleVelocity += acc ;
					}
				}
					
				if ( _data.dribbleVelocity > maxSpeed ) _data.dribbleVelocity = maxSpeed;
				if ( _data.dribbleVelocity < -maxSpeed ) _data.dribbleVelocity = -maxSpeed;
			
				_data.dribble += _data.dribbleVelocity;
			}			
			// place ball according to _data.dribble
			var bX:Number = _data.xPos + ( ( 1.75 * _data.radius) * Math.cos( _data.dribble) );
			var bY:Number = _data.yPos + ( ( 1.75 * _data.radius) * Math.sin( _data.dribble) );
			
			SoccerBallData.getInstance().xPos = bX;
			SoccerBallData.getInstance().yPos = bY;
		}
			
		protected function getBall():void
		{
			// sets player's destination to the balls current position
			// TODO should set player's destination to balls future predicted position
			if ( !_data.isKeeper ) 
				_data.destinationX = SoccerBallData.getInstance().xPos;
				_data.destinationY = SoccerBallData.getInstance().yPos;	
			}		
			//if ( _data.hasBall ) throw new Error("v");
		
		protected function passBall():void
		{
			if ( _data.justPassed ) return;	
				
		
			_data.kickPower = gsd.kickPower;
			if (_data.isKeeper ) _data.kickPower += 10;			
			
			sbd.direction = _data.autoPassAngle;
			// we use a crystal ball to predict a future destination for the pass receiver and we put that in the event data				
			var XYDestinationsArray:Array = CrystalBall.getInstance().setPassingAngleForWhereReceiverIsGoing(_data);
			var ge:GameEvents = new GameEvents(GameEvents.JUST_PASSED);
			if ( XYDestinationsArray )
			{
				ge.passDestinationX = XYDestinationsArray[0];
				ge.passDestinationY = XYDestinationsArray[1];
				ge.numberOfFramesToCompleteThePass = XYDestinationsArray[2];
			}			
			
			SoccerBallController.getInstance().kick(_data.kickPower);  // here is where the pass really happens
			resetAfterPass();
			dispatchEvent(ge);
		}
		private function resetAfterPass():void{
			sbd.justKicked = true;
			sbd.isFree = true;
			_data.kickPower = 0;
			_data.hasBall = false;
			_data.justPassed = true;
			_data.passPaused = true;
			_data.passNow = false;			
			KeyboardControls.getInstance().passBall = false;
		}
		
		protected function speedEasing():void
		{
			var dX:Number = _data.destinationX - _data.xPos;
			var dY:Number = _data.destinationY - _data.yPos;
			var distToDest:Number = Math.sqrt((dX*dX)+(dY*dY));
			
			var spd:Number = Math.sqrt((_data.speedX*_data.speedX)+(_data.speedY*_data.speedY));
			var aveSpd:Number = spd/2;
			var acc:Number = (this.data.teamId=="red" ? gsd.redTeamAcceleration:gsd.blueTeamAcceleration);
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
		
		protected function debugBreakPointer():void{
			if(_data.id == "player7")
			{
			//	trace("player7");
			}
		}
		
		//--------------------------------------------------------------------------------------------------
		// PRIVATE METHODS
		//--------------------------------------------------------------------------------------------------
		
		private function shouldHitTestBall():Boolean{	
			
			if ( SoccerBallData.getInstance().isFree ) return true;		
			
			if ( SoccerBallData.getInstance().redPossession && _data.teamId == "blue" ) return true;
			
			if ( SoccerBallData.getInstance().bluePossession && _data.teamId == "red" ) return true;
			
			if ( ! SoccerBallData.getInstance().redPossession && ! SoccerBallData.getInstance().bluePossession ) return true;			 
			
			return false;
			
		}
		
		//--------------------------------------------------------------------------------------------------
		// EVENT HANDLERS
		//--------------------------------------------------------------------------------------------------
		
		
		//--------------------------------------------------------------------------------------------------
		// GETTERS & SETTERS
		//--------------------------------------------------------------------------------------------------
		
		public function get gsd():GameSettingsData{
			return GameSettingsData.getInstance();
		}
		
		public function get sbd():SoccerBallData{
			return SoccerBallData.getInstance();
		}
		
		public function get data():PlayerData{
			return _data;
		}
		public function set data(data:PlayerData):void{
			_data = data;
		}
		
		
//  ___________________________________________________________________________________________________________________________________
		
					
	} // close class
} // close package