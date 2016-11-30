 package classes
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class PlayerData extends EventDispatcher
	{
		private var _id:String = "";
		private var _radius:uint = GameSettingsData.getInstance().playerRadius;
		private var _color:Array;
		private var _hasBall:Boolean = false;
		private var _isControlled:Boolean = false;
		private var _state:String = "nothing";
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
		private var _frameNo:uint = 0;
		private var _kickPower:uint = 0;
		private var _generatingKickPower:Boolean = false;
		private var _speedGenerateKickPower:Number = 3;
		private var _justPassed:Boolean = false;
		private var _passReciever:Boolean = false;
		//private var _autoPassing:Boolean = true;
		private var _autoPassAngle:Number = 0;
		private var _gettingBall:Boolean = false;		
		private var _opponent:PlayerData;		
		private var _sBallData: SoccerBallData;
		private var _playerMarking:PlayerData;
		private var _marking:Boolean = false;
		private var _pressureToPass:Boolean = false;
		private var _passNow:Boolean = false;
		private var _justBeaten:Boolean = false;		
		//private var _bumpAngle:Number = 0;
		private var _getPastAngle:Number = 0;
		public var angleFromPlayerWithBall:Number = 10000;
		public var teamMateAimingPassAt:PlayerData;
		public var defaultPlayerToMark:PlayerData;
		public var destinationManagerHasAssignedDestination:Boolean;
		public var closestDefender:PlayerData;
		public var hitTestCaptureDistance:uint;	
		
		public var totalFrameCount:uint;
		public var passFrameCount:uint;
		
		public var thrust:Number=0;
		
		//private var _beingBumped:Boolean = false;		
		private var _zone:PlayerZone;
		private var _teamId:String = "nothing";
		private var _passPaused:Boolean = false;
		private var _scoreBall:Boolean = false;
		private var _dribbleVelocity:Number = 0;
		private var _lightSourceAngle:Number = 0;
		private var _space:Number=100000;
		
		
		public function PlayerData():void
		{
			_sBallData = SoccerBallData.getInstance();		
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
		public function get passPaused():Boolean{
			return _passPaused;
		}
		public function set passPaused(data:Boolean):void{
			_passPaused = data;
			if ( data ) {
				var passPauseTimer:Timer = new Timer(GameSettingsData.getInstance().passingSpeed,1);
				passPauseTimer.start();
				passPauseTimer.addEventListener(TimerEvent.TIMER, onPassPauseTimer);
			}
		}
		private function onPassPauseTimer(e:TimerEvent):void
		{
			_passPaused = false;
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
		public function get zone():PlayerZone{
			return _zone;
		}
		public function set zone(data:PlayerZone):void{
			_zone = data;
		}
	
//		public function get beingBumped():Boolean{
//			return _beingBumped;
//		}
//		public function set beingBumped(data:Boolean):void{
//			_beingBumped = data;
//		}
		
		public function get justBeaten():Boolean{
			return _justBeaten;
		}
		public function set justBeaten(data:Boolean):void{
			if ( data ) 
			{
				var beatenTimer:Timer = new Timer(GameSettingsData.getInstance().justBeatTimer,1);
				beatenTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onBeatenTimer);
				beatenTimer.start();
				dispatchEvent(new GameEvents(GameEvents.JUST_BEATEN));
			}
			_justBeaten = data;
		}
		
//		public function get bumpAngle():Number{
//			return _bumpAngle;
//		}
//		public function set bumpAngle(data:Number):void{
//			_bumpAngle = data;
//		}
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
			if (_passNow) dispatchEvent(new GameEvents(GameEvents.PASS_NOW));  // listener is on player pass fx
		}
		public function get marking():Boolean{			
			return _marking;
		}
		public function set marking(data:Boolean):void{
			if (_id == "player1" && _teamId == "red"){
			//	trace("");
			}
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
			
			if ( _id != "keeper" && data == null)
			{
				throw new Error("playerMarking cannot be null");
			}
			if (_id == "player1" && _teamId == "red"){
			//	trace("");
			}
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
			if (_id == "player1" && data  && _teamId == "red"){
			//	trace("");
			}
			_gettingBall = data;				
			dispatchEvent( new GameEvents(GameEvents.PLAYER_GETTING_BALL_CHANGE));
		}
		public function get state():String{
			return _state;
		}
		public function set state(data:String):void{
			_state = data;
			//if ( _state == "attacking" ) _marking = false;
			//if ( _state == "defending" ) _marking = true;		
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
			this.dispatchEvent(new GameEvents(GameEvents.PLAYER_DATA_HAD_COLOR_SET));
		}
		public function get hasBall():Boolean{
			return _hasBall;
		}
		public function set hasBall(value:Boolean):void{
			
			if (_id == "player1" && value && _teamId == "red"){
			//	trace("");
			}
			_hasBall = value;
			//trace("playerData.hasBall id: " + _teamId + _id +" : " + value); 
			if ( value ) {	
				_marking = false;
				_gettingBall = false;	
				_scoreBall = false;								
				//dispatchEvent( new Event(GameEvents.GOT_BALL));  doesn't seem like anyone listens to this anyways				
			}			
		}
		public function get isControlled():Boolean{
			return _isControlled;
		}
		public function set isControlled(value:Boolean):void{
			if ( value )
			{
				//trace(this.id + "  " + this.teamId );
			}
			_isControlled = value;
			dispatchEvent( new GameEvents(GameEvents.PLAYER_CONTROL_CHANGE));
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
		public function set dribble(value:Number):void{		// this automatically keep dribble between 0 and 2pi
			_dribble = value;
			if ( _dribble > ( 2 * Math.PI ) ) _dribble -= 2 * Math.PI;
			if ( _dribble < 0 ) _dribble = ( 2 * Math.PI ) + _dribble; 
		}
		public function get destinationX():Number{
			return _destinationX;
		}
		public function set destinationX(value:Number):void{
			if (_id == "keeper" && _teamId == "red" && value > 125){
				//2throw new Error("invalid keeper destination set")
			}
			if ( hasBall )
			{
			//	trace ("booya");
			}
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
			dispatchEvent(new GameEvents(GameEvents.PLAYER_POS_CHANGED));							
		}
		public function get yPos():Number{
			return _yPos;
		}
		public function set yPos(value:Number):void{
			_yPos = value;
			dispatchEvent(new GameEvents(GameEvents.PLAYER_POS_CHANGED));						
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
			if ( hasBall )
			{
			//	trace("booya");
			}
		}
		public function get kickPower():Number{
			return _kickPower;
		}
		public function set kickPower(data:Number):void{
			_kickPower = data;
			if ( data != 0 ) dispatchEvent(new GameEvents(GameEvents.GENERATING_KICK_POWER));
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
		public function get justPassed():Boolean{
			return _justPassed;
		}
		public function set justPassed(data:Boolean):void{
			_justPassed = data;
			if (data) 
			{			
				dispatchEvent(new GameEvents(GameEvents.JUST_PASSED));
				passFrameCount = totalFrameCount;
				var passTimer:Timer = new Timer(100,100);
				passTimer.addEventListener(TimerEvent.TIMER, onPassTimer);
				passTimer.start();
			}
		}
		public function get passReceiver():Boolean{
			return _passReciever;
		}
		public function set passReceiver(data:Boolean):void{
			if (data)
			{
				trace(data);
				trace("bull crap");
			}
			_passReciever = data;		
			dispatchEvent(new GameEvents(GameEvents.PASS_RECEIVER));	
		}
//		public function get autoPassing():Boolean{
//			return _autoPassing;
//		}
//		public function set autoPassing(data:Boolean):void{
//			_autoPassing = data;
//		}
		public function get autoPassAngle():Number{
			return _autoPassAngle;
		}
		public function set autoPassAngle(data:Number):void{
			_autoPassAngle = data;
		}
		
		
		
		//---------------------------------------------------------------------------------------------
		// EVENT HANDLERS
		//---------------------------------------------------------------------------------------------
		
		private function onPassTimer(e:Event):void
		{
			if ( totalFrameCount > passFrameCount + 10 )
			{
				_justPassed = false;
			}			
		}
		private function onBeatenTimer(e:Event):void
		{			
			_justBeaten = false;
			dispatchEvent(new GameEvents(GameEvents.PLAYER_RECOVERED));
		}
	}
}