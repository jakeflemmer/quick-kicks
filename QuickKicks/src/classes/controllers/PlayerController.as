package classes.controllers
{
	import classes.data.FieldData;
	import classes.data.GameSettingsData;
	import classes.data.PlayerData;
	import classes.data.SoccerBallData;
	import classes.tools.RadiansCalculator;
	import classes.views.PlayerView;
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class PlayerController extends Sprite
	{
		private var _data:PlayerData;	
		private var _view:PlayerView;
		private var frameNo:uint;
		private var oldFrameNo:uint;
	
		public function PlayerController()
		{
			_data = new PlayerData;
			_view = new PlayerView(_data);
			
			addChild(_view);
			
			this.addEventListener(Event.ENTER_FRAME, on_ENTER_FRAME);
			
		}
		public function get data():PlayerData{
			return _data;
		}
		public function set data(value:PlayerData):void{
			_data = value;
		}
//  ___________________________________________________    PUBLIC METHODS     ______________________________________________________

		public function gotoKeeper():void
		{
			_data.destinationX = 150;
			_data.destinationY = 500;			
		}
		public function gotoZone1():void
		{
			_data.destinationX = 350;
			_data.destinationY = 300;
		}
		public function gotoZone2():void
		{
			_data.destinationX = 350;
			_data.destinationY = 700;
		}
		public function gotoZone3():void
		{
			_data.destinationX = 600;
			_data.destinationY = 250;
		}
		public function gotoZone4():void
		{
			_data.destinationX = 600;
			_data.destinationY = 750;
		}
		public function beControlled():void{
			_data.isControlled = true;
		}
		public function dontBeControlled():void{
			_data.isControlled = false;
		}
		public function gettingBall():void{
			_data.gettingBall = true;
		}
		public function notGettingBall():void{
			_data.gettingBall = false;
		}

//  ____________________________________________________    ON ENTER  FRAME      _____________________________________________________	
//  __________________________________________________      PRIVATE METHODS        ____________________________________________________	
//  ____________________________________________________________________________________________________________________________________
//  ___________________________________________________________________________________________________________________________________

		private function on_ENTER_FRAME(E:Event):void
		{
			frameNumber();
			
			if ( _data.isControlled )
			{
				respondToControls();			// respond to controls
				checkMaxSpeed();							
			}
			
			if(_data.gettingBall) getBall();
			
			if (!_data.isControlled ) moveToDestination();			// or move to destinations	
						
									
			factorInFriction();									
			
			if ( _data.passReceiver && SoccerBallData.getInstance().justKicked )   
			{
				_data.speedX = 0;
				_data.speedY = 0;
			}  
			checkFieldBounds();
				
			positionPlayer();  // change x,y based on speedX, speedY
						
			if ( _data.hasBall ) {
				calculateDirection();
				dribbleBall();
			}			
		
			if ( SoccerBallData.getInstance().isFree ) hitTestBall();
		}
//  _________________________________________________________________________________________________________________________________________
//  _________________________________________________________________________________________________________________________________________
		
		private function frameNumber():void{
			frameNo ++;
			if ( frameNo - oldFrameNo >= GameSettingsData.getInstance().justPassedFrames ) 
			{
				_data.justPassed = false;
			}
		}
		private function getBall():void
		{
			_data.destinationX = SoccerBallData.getInstance().xPos;
			_data.destinationY = SoccerBallData.getInstance().yPos;
		}
		
		private function positionPlayer():void
		{
				_data.xPos += _data.speedX;
				_data.yPos += _data.speedY;
		}	
		private function moveToDestination():void
		{	// keep players within bounds
			if (! _data.isKeeper) {
				if ( _data.destinationX <= 200 ) _data.destinationX = 200;
			} else {
				if ( _data.destinationX <= 100 ) _data.destinationX = 100;
			}
			if ( _data.destinationX >= 1300 ) {
				_data.destinationX = 1300;
			}
			if (_data.xPos != _data.destinationX ){
				if (_data.xPos <= _data.destinationX ) {
					if (_data.speedX >= 0 ) _data.speedX += _data.acceleration;
					else { _data.speedX += 2 * _data.acceleration}
				}
				if (_data.xPos >= _data.destinationX ) {
					if (_data.speedX <= 0 ) _data.speedX -= _data.acceleration;
					else { _data.speedX -= 2 * _data.acceleration}			
				}
			}
			if (_data.yPos != _data.destinationY ){
				if (_data.yPos <= _data.destinationY ) {
					if (_data.speedY >= 0 ) _data.speedY += _data.acceleration;
					else { _data.speedY += 2 * _data.acceleration}
				}
				if (_data.yPos >= _data.destinationY ) {
					if (_data.speedY <= 0 ) _data.speedY -= _data.acceleration;
					else { _data.speedY -= 2 * _data.acceleration}			
				}
			}
			checkReducedSpeed(1.5);			
		}	
		private function respondToControls():void
		{			
				if (KeyboardControls.getInstance().leftKey)
				{
					if (_data.speedX <= 0)	{
						_data.speedX -= _data.acceleration;						
					} else 	{
						_data.speedX -= 2*_data.acceleration;}
				}
				if (KeyboardControls.getInstance().rightKey)
				{
					if (_data.speedX >=0 )					{
						_data.speedX += _data.acceleration;
					} else	{
						_data.speedX += 2* _data.acceleration;
					}
				}
				if (KeyboardControls.getInstance().upKey)
				{
					if (_data.speedY <= 0)	{
						_data.speedY -= _data.acceleration;						
					} else 	{
						_data.speedY -= 2*_data.acceleration;}
				}
				if (KeyboardControls.getInstance().downKey){
					if (_data.speedY >=0 )					{
						_data.speedY += _data.acceleration;
					} else	{
						_data.speedY += 2* _data.acceleration;
					}
				}
				
				if (KeyboardControls.getInstance().upLeftKey)
				{
					if (_data.speedX <= 0)	{
						_data.speedX -= _data.acceleration;						
					} else 	{
						_data.speedX -= 2*_data.acceleration;}
					if (_data.speedY <= 0)	{
						_data.speedY -= _data.acceleration;						
					} else 	{
						_data.speedY -= 2*_data.acceleration;}
				}
				
				if (KeyboardControls.getInstance().upRightKey)
				{
					if (_data.speedY <= 0)	{
						_data.speedY -= _data.acceleration;						
					} else 	{
						_data.speedY -= 2*_data.acceleration;}
					if (_data.speedX >=0 )					{
						_data.speedX += _data.acceleration;
					} else	{
						_data.speedX += 2* _data.acceleration;
					}
				}
				
				if (KeyboardControls.getInstance().downLeftKey){
					if (_data.speedY >=0 )					{
						_data.speedY += _data.acceleration;
					} else	{
						_data.speedY += 2* _data.acceleration;
					}				
					if (_data.speedX <= 0)	{
						_data.speedX -= _data.acceleration;						
					} else 	{
						_data.speedX -= 2*_data.acceleration;}
				}
				if (KeyboardControls.getInstance().downRightKey){
					if (_data.speedY >=0 )					{
						_data.speedY += _data.acceleration;
					} else	{
						_data.speedY += 2* _data.acceleration;
					}				
					if (_data.speedX >=0 )					{
						_data.speedX += _data.acceleration;
					} else	{
						_data.speedX += 2* _data.acceleration;
					}
				}
				
				
				
				
				
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
						passBall();
					}
				}				
		}
		private function passBall():void
		{
			SoccerBallData.getInstance().direction = _data.autoPassAngle;
			if (_data.kickPower <=10 ) _data.kickPower = 10;
			if (_data.kickPower >=40 ) _data.kickPower = 40;
			if (_data.isKeeper ) {
				if (_data.kickPower <=20) _data.kickPower = 20;
			}
			SoccerBallController.getInstance().kick(_data.kickPower);
			SoccerBallData.getInstance().isFree = true;
			SoccerBallData.getInstance().justKicked = true;
			KeyboardControls.getInstance().passBall = false;
			_data.kickPower = 0;
			_data.hasBall = false;
			_data.justPassed = true;
			oldFrameNo = frameNo;
		}
		private function checkMaxSpeed():void
		{
			if (_data.speedX >= _data.maxSpeed ) _data.speedX = _data.maxSpeed;
			if (_data.speedX <= (-_data.maxSpeed) ) _data.speedX = (-_data.maxSpeed);
			if (_data.speedY >= _data.maxSpeed ) _data.speedY = _data.maxSpeed;
			if (_data.speedY <= (-_data.maxSpeed) ) _data.speedY = (-_data.maxSpeed);
		}
		private function checkReducedSpeed(data:Number):void
		{
			if (_data.speedX >= _data.maxSpeed / data ) _data.speedX = _data.maxSpeed/data;
			if (_data.speedX <= (-_data.maxSpeed/data) ) _data.speedX = (-_data.maxSpeed/data);
			if (_data.speedY >= _data.maxSpeed/data ) _data.speedY = _data.maxSpeed/data;
			if (_data.speedY <= (-_data.maxSpeed/data) ) _data.speedY = (-_data.maxSpeed/data);
		}
		private function checkFieldBounds():void
		{
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
		private function factorInFriction():void
		{
			if ( _data.speedX >= FieldData.getInstance().fieldFriction ) _data.speedX -= FieldData.getInstance().fieldFriction;
			if ( _data.speedX <= (-1*FieldData.getInstance().fieldFriction) ) _data.speedX += FieldData.getInstance().fieldFriction;
			if ( _data.speedY >= FieldData.getInstance().fieldFriction ) _data.speedY -= FieldData.getInstance().fieldFriction;
			if ( _data.speedY <= (-1*FieldData.getInstance().fieldFriction) ) _data.speedY += FieldData.getInstance().fieldFriction;
			// come to full stop
			if ( _data.speedX < FieldData.getInstance().fieldFriction && _data.speedX > -1*FieldData.getInstance().fieldFriction ) _data.speedX = 0;
			if ( _data.speedY < FieldData.getInstance().fieldFriction && _data.speedY > -1*FieldData.getInstance().fieldFriction ) _data.speedY = 0;
		}
		private function hitTestBall():void
		{
			if ( ! _data.justPassed ){
				var bX:Number = SoccerBallData.getInstance().xPos;
				var bY:Number = SoccerBallData.getInstance().yPos;
				var x:Number = _data.xPos;
				var y:Number = _data.yPos;
					
				var xDistance:Number = ( Math.sqrt( Math.pow( ( x - bX ), 2)));
				var yDistance:Number = ( Math.sqrt( Math.pow( ( y - bY ), 2)));
				var totalDistance:Number = xDistance + yDistance;		
			
				if ( totalDistance <= ( _data.radius * 2 ) )  // Got the ball!
				{
					_data.hasBall = true;
					SoccerBallData.getInstance().isFree = false;
										
					var rC:RadiansCalculator = new RadiansCalculator;
					_data.dribble = rC.calc( bX - x, bY - y );				
				}
			}	
		}
		private function calculateDirection():void
		{
			if ( _data.speedX == 0 && _data.speedY == 0 ) return;		
			
			var radCalc:RadiansCalculator = new RadiansCalculator;
			_data.direction = radCalc.calc( _data.speedX , _data.speedY );			
		}
		private function dribbleBall():void
		{					
		 	if ( _data.speedX == 0 && _data.speedY == 0 ) return;			
							 						
			var totalSpeed:Number = ( (Math.abs(_data.speedX) + Math.abs(_data.speedY)) ) / 40 ;
			if ( _data.isKeeper ) totalSpeed *=3;
			if (totalSpeed >= .2) totalSpeed = .2;
			
							
			var drib : Number = _data.dribble;
			var dir : Number = _data.direction;
			var dribVsDir : Number;			
			if ( (Math.abs(dir - drib)) < totalSpeed ) totalSpeed = .03;
			
			if ( dir > drib )
			{
				if ( dir - drib < Math.PI ) _data.dribble += totalSpeed ; 			
				if ( dir - drib > Math.PI ) _data.dribble -= totalSpeed ; 
			}	
			if ( drib > dir )
			{
			//	trace("drib : " + drib.toPrecision(2) + " dir : " + dir.toPrecision(2) );
				if ( drib - dir < Math.PI ) _data.dribble -= totalSpeed ; 			
				if ( drib - dir > Math.PI ) _data.dribble += totalSpeed ; ;
			}	
			
			// place ball according to _data.dribble
			var bX:Number = _data.xPos + ( ( 1.75 * _data.radius) * Math.cos( _data.dribble) );
			var bY:Number = _data.yPos + ( ( 1.75 * _data.radius) * Math.sin( _data.dribble) );
			SoccerBallData.getInstance().xPos = bX;
			SoccerBallData.getInstance().yPos = bY;
		}		
					
	} // close class
} // close package