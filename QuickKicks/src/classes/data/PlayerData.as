 package classes.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import classes.events.GameEvents;

	public class PlayerData extends EventDispatcher
	{
		private var _id:String = "";
		private var _radius:uint = GameSettingsData.getInstance().playerRadius;
		private var _color:Array;
		private var _hasBall:Boolean = false;
		private var _isControlled:Boolean = false;
		private var _direction:Number;
		private var _speed:Number;
		private var _maxSpeed:Number=0;
		private var _dribble:Number;
		private var _destinationX:Number;
		private var _destinationY:Number;
		private var _isKeeper:Boolean;
		private var _xPos:Number=-500;
		private var _yPos:Number=-500;
		private var _speedX:Number=0;
		private var _speedY:Number=0;
		private var _kickPower:uint = 0;
		private var _generatingKickPower:Boolean = false;
		private var _speedGenerateKickPower:Number = 3;
		private var _justPassed:Boolean = false;
		private var _passReciever:Boolean = false;
		private var _autoPassAngle:Number = 0;
		private var _gettingBall:Boolean = false;		
		
		private var _marking:Boolean = false;
		private var _pressureToPass:Boolean = false;
		private var _passNow:Boolean = false;
		private var _justBeaten:Boolean = false;		
		private var _bumpAngle:Number = 0;
		private var _getPastAngle:Number = 0;
		
		private var _zone:uint = 99;
		private var _teamId:String = "nothing";
		
		private var _scoreBall:Boolean = false;
		private var _dribbleVelocity:Number = 0;
		private var _lightSourceAngle:Number = 0;
		private var _space:Number=100000;
		
		private var _opponent:PlayerData;
		private var _playerMarking:PlayerData;
		public var playerPassingTo:PlayerData;
		public var closestDefender:PlayerData;	
		
		public var passedFrameNo:uint;
		public var beatenFrameNo:uint;
		
		
		
		
		public function PlayerData():void
		{
		
		}
		public function get space():Number{
			return _space;
		}
		public function set space(val:Number):void{
			_space = val;
		}
		
		public function get lightSourceAngle():Number{
			return _lightSourceAngle;
		}
		public function set lightSourceAngle(data:Number):void{
			_lightSourceAngle = data;
		}
		public function get dribbleVelocity():Number{
			return _dribbleVelocity;
		}		
		public function set dribbleVelocity(data:Number):void{
			_dribbleVelocity = data;
		}

		public function get scoreBall():Boolean{	
			return _scoreBall;
		}
		public function set scoreBall(data:Boolean):void{
			_scoreBall = data;			
		}
		public function get teamId():String{
			return _teamId;
		}
		public function set teamId(data:String):void{
			_teamId = data;
		}
		public function get zone():uint{
			return _zone;
		}
		public function set zone(data:uint):void{
			_zone = data;
		}
	
	
		public function get justBeaten():Boolean{
			return _justBeaten;
		}
		public function set justBeaten(data:Boolean):void{
			_justBeaten = data;
			if ( data ) 
			{
				beatenFrameNo = FieldData.getInstance().frameNumber;
			}
			
		}
		
		public function set justPassed(data:Boolean):void{
			_justPassed = data;
			if (data) 
			{			
				passedFrameNo = FieldData.getInstance().frameNumber;
			}
		}
		
		
		public function get bumpAngle():Number{
			return _bumpAngle;
		}
		public function set bumpAngle(data:Number):void{
			_bumpAngle = data;
		}
		public function get getPastAngle():Number{
			return _getPastAngle;
		}
		public function set getPastAngle(data:Number):void{
			_getPastAngle = data;
		}
		public function get passNow():Boolean{
			return _passNow;
		}
		public function set passNow(data:Boolean):void{
			_passNow = data;
		}
		public function get marking():Boolean{
			return _marking;
		}
		public function set marking(data:Boolean):void{
			_marking = data;
		}
		public function get pressureToPass():Boolean{
			return _pressureToPass;
		}
		public function set pressureToPass(data:Boolean):void{
			_pressureToPass = data;
		}
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			_id = value;
		}
		public function get playerMarking():PlayerData{
			return _playerMarking;
		}
		public function set playerMarking(data:PlayerData):void{
			_playerMarking = data;
		}
		
		public function get opponent():PlayerData{
			return _opponent;
		}
		public function set opponent(data:PlayerData):void{
			_opponent = data;
		}
		
		public function get gettingBall():Boolean{
			return _gettingBall;
		}
		public function set gettingBall(data:Boolean):void{
			_gettingBall = data;
		}
		public function get radius():Number	{
			return _radius;
		}
		public function set radius(radius:Number):void	{
			_radius = radius;
		}
		public function get color ():Array	{
			return _color;
		} 
		public function set color (color:Array) :void {
			_color = color;
		}
		public function get hasBall():Boolean{
			return _hasBall;
		}
		public function set hasBall(value:Boolean):void{
			_hasBall = value;
			//trace("playerData.hasBall id: " + _teamId + _id +" : " + value); 
			if ( value ) {	
				_marking = false;
				_gettingBall = false;	
				_scoreBall = false;					
			}
		}
		public function get isControlled():Boolean{
			return _isControlled;
		}
		public function set isControlled(value:Boolean):void{
			_isControlled = value;
		}
		public function get direction():Number{
			return _direction;
		}
		public function set direction(value:Number):void{
			_direction = value;
			if ( _direction > ( 2 * Math.PI ) ) _direction -= 2 * Math.PI; 
			if ( _direction < 0 ) _direction = ( 2 * Math.PI ) + _direction; 
		}
		public function get speed():Number{
			return _speed;
		}
		public function set speed(value:Number):void{
			_speed = value;
		}
		public function get maxSpeed():Number{
			return _maxSpeed;
		}
		public function set maxSpeed(value:Number):void{
			_maxSpeed = value;
		}
		public function get dribble():Number{
			return _dribble;
		}
		public function set dribble(value:Number):void{
			_dribble = value;
			if ( _dribble > ( 2 * Math.PI ) ) _dribble -= 2 * Math.PI;
			if ( _dribble < 0 ) _dribble = ( 2 * Math.PI ) + _dribble; 
		}
		public function get destinationX():Number{
			return _destinationX;
		}
		public function set destinationX(value:Number):void{
			_destinationX = value;
		}
		public function get destinationY():Number{
			return _destinationY;
		}
		public function set destinationY(value:Number):void{
			_destinationY = value;
		}
		public function get isKeeper():Boolean{
			return _isKeeper;
		}
		public function set isKeeper(value:Boolean):void{
			_isKeeper = value;
		}		
		public function get xPos():Number{
			return _xPos;
		}
		public function set xPos(value:Number):void{
			_xPos = value;
		}
		public function get yPos():Number{
			return _yPos;
		}
		public function set yPos(value:Number):void{
			_yPos = value;						
		}
		public function get speedX():Number{
			return _speedX;
		}
		public function get speedY():Number{
			return _speedY;
		}
		public function set speedX(data:Number):void{
			_speedX = data;
		}
		public function set speedY(data:Number):void{
			_speedY = data;
		}
		public function get kickPower():Number{
			return _kickPower;
		}
		public function set kickPower(data:Number):void{
			_kickPower = data;
		}
		public function get generatingKickPower():Boolean{
			return _generatingKickPower;
		}
		public function set generatingKickPower(data:Boolean):void{
			_generatingKickPower = data;
		}
		public function get speedGenerateKickPower():Number{
			return _speedGenerateKickPower;
		}
		public function set speedGenerateKickPower(data:Number):void{
			_speedGenerateKickPower = data;
		}
		
		
		//----------------------------------------------------------
		public function get justPassed():Boolean{
			return _justPassed;
		}
		
		
	
		
		//-----------------------------------------------------------
		
		public function get passReceiver():Boolean{
			return _passReciever;
		}
		public function set passReceiver(data:Boolean):void{
			_passReciever = data;		
			dispatchEvent(new GameEvents(GameEvents.PASS_RECEIVER));	
		}
		
		public function get autoPassAngle():Number{
			return _autoPassAngle;
		}
		public function set autoPassAngle(data:Number):void{
			_autoPassAngle = data;
		}
		private function onPassTimer(e:Event):void
		{
			_justPassed = false;			
		}
		private function onBeatenTimer(e:Event):void
		{			
			_justBeaten = false;
			dispatchEvent(new GameEvents(GameEvents.PLAYER_RECOVERED));
		}
	}
}