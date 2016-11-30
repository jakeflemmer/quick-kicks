package classes
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class FieldData extends EventDispatcher
	{
		private static var _instance:FieldData;
				
		private var _sBallData: SoccerBallData;
		private var _frameNo:uint = 0;
		private var _team1Score:uint =0;
		private var _team2Score:uint =0;
		private var _goalsAndWalls:GoalsAndWalls;
		private var _gameState:String;
		private var _fieldWidth:Number;
		private var _fieldHeight:Number;
		private var _fieldFriction:Number = GameSettingsData.getInstance().fieldFriction;
		private var _soccerBallFriction:Number = GameSettingsData.getInstance().soccerBallFriction;
		private var _redKeeperOnHisLine:String = "middle";
		private var _blueKeeperOnHisLine:String = "middle";
		public var redTeamData:TeamData;
		public var blueTeamData:TeamData;
		public var replayArrayA:Array = new Array();
		public var replayArrayB:Array = new Array();
		public var combinedReplayArray:Array;		
		public var replayFrameCounter:uint =0;
		public var frameCounter:uint=0;
		public var teamJustScoredOn:String = "";
		public var goalAnimationPlaying:Boolean = false;
		public var clearPassCacheFrameNumber:uint;
		
		
				
		public function FieldData(parameter:SingletonEnforcer)
		{
			_sBallData = SoccerBallData.getInstance();			 
			_gameState = "notStarted";
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				
		}
		public static function getInstance():FieldData
		{
			if (_instance == null)
			{
				_instance = new FieldData(new SingletonEnforcer());
			}
			return _instance;
		}
		private function onEnterFrame(event:Event):void
		{
			
		}		
	
		public function get soccerBallFriction():Number{
			return _soccerBallFriction;
		}
		public function set soccerBallFriction(data:Number):void{
			_soccerBallFriction = data;
		}
		public function get redKeeperOnHisLine():String{
			return _redKeeperOnHisLine;
		}
		public function set redKeeperOnHisLine(data:String):void{
			_redKeeperOnHisLine = data;
		}
		public function get blueKeeperOnHisLine():String{
			return _blueKeeperOnHisLine;
		}
		public function set blueKeeperOnHisLine(data:String):void{
			_blueKeeperOnHisLine = data;
		}
		
//		public function get team1Data():TeamData{
//			return _team1Data;
//		} 
//		public function get team2Data():TeamData{
//			return _team2Data;
//		}
		public function get sBallData():SoccerBallData{
			return _sBallData;
		}
		public function get team1Score():uint{
			return _team1Score;
		}
		public function get team2Score():uint{
			return _team2Score;
		}
		public function get gameState():String{
			return _gameState;
		}
		
		public function set sBallData(data:SoccerBallData):void{
			_sBallData = data;
		}
		public function set team1Score(data:uint):void{
			_team1Score = data;
		}
		public function set team2Score(data:uint):void{
			_team2Score = data;
		}
		public function set gameState(data:String):void{
			_gameState = data;
		}
		public function get fieldWidth():Number{
			return _fieldWidth;
		} 
		public function get fieldHeight():Number{
			return _fieldHeight;
		}
		public function set fieldWidth(data:Number):void{
			_fieldWidth = data;
			dispatchEvent(new Event(Event.RESIZE));
		}
		public function set fieldHeight(data:Number):void{
			_fieldHeight = data;
			dispatchEvent(new Event(Event.RESIZE));
		}
		public function set fieldFriction(data:Number):void{
			_fieldFriction = data;
		}
		public function get fieldFriction():Number{
			return _fieldFriction;
		}
		
		
	}
}
class SingletonEnforcer{}