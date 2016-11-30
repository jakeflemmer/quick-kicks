package classes.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import classes.events.GameEvents;

	public class SoccerBallData extends EventDispatcher
	{
		private static var _instance:SoccerBallData;
		
		private var _radius:uint = GameSettingsData.getInstance().soccerBallRadius;
		private var _xPos:Number;
		private var _yPos:Number;
		private var _speed:Number = 0;
		private var _direction:Number = 1;
		private var _isFree:Boolean = true;
		private var _justKicked : Boolean = false;
		private var _redPossession:Boolean = false;
		private var _bluePossession:Boolean = false;
		private var _passReceiver:PlayerData = null;
		private var _ballCarrier:PlayerData = null;
		public var spinX:int = 0;
		public var spinY:int = 0;
		
		public function SoccerBallData(parameter:SingletonEnforcer):void
		{
			_xPos = 750;
			_yPos = 500;
		}
		public static function getInstance():SoccerBallData
		{
			if (_instance == null)
			{
				_instance = new SoccerBallData(new SingletonEnforcer());
			}
			return _instance;
		}
		public function get ballCarrier():PlayerData{
			return _ballCarrier;
		} 
		public function set ballCarrier(data:PlayerData):void{
			_ballCarrier = data;
		}
		public function get passReceiver():PlayerData{
			return _passReceiver;
		}
		public function set passReceiver(data:PlayerData):void{
			_passReceiver = data;
		}
		public function get redPossession():Boolean{
			return _redPossession;
		}
		public function get bluePossession():Boolean{
			return _bluePossession;
		}
		public function set bluePossession(data:Boolean):void{
			var oldPossession :Boolean = _bluePossession;
			_bluePossession = data;
			if ( data ) _redPossession = false;		
			if ( oldPossession != _bluePossession ) {
				dispatchEvent(new GameEvents(GameEvents.CHANGE_POSSESSION));
			}
		}
		public function set redPossession(data:Boolean):void{
			var oldPossession :Boolean = _redPossession;
			_redPossession = data;
			if ( data ) _bluePossession = false;			
			if ( oldPossession != _redPossession ) {
				dispatchEvent(new GameEvents(GameEvents.CHANGE_POSSESSION));
			}
		}
		public function get radius():Number{
			return _radius;
		}
		public function get xPos():Number{
			return _xPos;
		}
		public function set xPos(data:Number):void{
			_xPos = data;
			
		}
		public function get yPos():Number{
			return _yPos;
		}
		public function set yPos(data:Number):void{
			_yPos = data;
			
		}
		public function get speed():Number{
			return _speed;
		}
		public function get direction():Number{
			return _direction;
		}
		public function get isFree():Boolean{
			return _isFree;
		}
		public function set speed(data:Number):void{
			_speed = data;
		}
		public function set direction(data:Number):void{			
			_direction = data;
		}
		public function set isFree(data:Boolean):void{
			if ( data != _isFree && data ) dispatchEvent(new GameEvents (GameEvents.BALL_NOW_FREE));
			_isFree = data;			
			if ( ! data ) {
				_justKicked = false;
			}
			
		}
		public function get justKicked():Boolean{
			return _justKicked;
		}
		public function set justKicked(value:Boolean):void{
			_justKicked = value;
		}
		
		
		
		
	}
}
class SingletonEnforcer{}