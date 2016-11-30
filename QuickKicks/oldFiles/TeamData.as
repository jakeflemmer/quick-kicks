package classes
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;


	public class TeamData extends EventDispatcher
	{
		private var _id:String = "";
		private var _color:Array;

		private var _playerWithBallData:PlayerData;
		private var _playerWithMostSpace:PlayerData;
		private var _state:String = "nothing";
		private var _hasPossession:Boolean = false;
		private var _newPlayerJustGotBall:Boolean = false;
		private var _maxSpeed:Number = 4;
		private var _pressureToPass:Boolean = false;
		private var _closestTeamMate:PlayerData = null;
		private var _oldZone:uint = 0;
		private var _justPassed:Boolean = false;
		public var scorePost:ScorePostData = new ScorePostData();
		public var passDestinationX:Number;
		public var passDestinationY:Number;
		public var passing:Boolean = false;
		public var passCompleted:Boolean = false;
		public var passJustFailed:Boolean = false;
		public var currentFrameNumber:uint;
		public var passShouldBeCompletedByFrameNumber:uint;
		
		[Bindable]
		private var _autoPassAngle:Number = 0;
		
				
		//public function TeamData(keeper:PlayerData, player1:PlayerData, player2:PlayerData, player3:PlayerData, player4:PlayerData )
		//public function TeamData(arrayOfPlayers:Array)
		public function TeamData()	
		{	
			
							
		}
		public function onJustPassed(e:GameEvents):void
		{
			_justPassed = true;
			var passTimer:Timer = new Timer(600,1);
			passTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onPassTimer);
			passTimer.start();
		}
		public function onPassTimer(e:Event):void
		{
			_justPassed = false;
		}
		public function get playerWithMostSpace():PlayerData{
			return _playerWithMostSpace;
		}
		public function set playerWithMostSpace(val:PlayerData):void{
			_playerWithMostSpace = val;
		}
		public function get justPassed():Boolean{
			return _justPassed;
		}
		public function set justPassed(data:Boolean):void{
			_justPassed = data;
		}		
		
		public function get closestTeamMate():PlayerData{
			return _closestTeamMate;
		}
		public function set closestTeamMate(data:PlayerData):void{
			_closestTeamMate = data;
		}
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			_id = value;
			
			if (_id == "red")
			{
				scorePost.postsX = 1450;
				scorePost.leftPostY = 350;
				scorePost.rightPostY = 650;
			}else if (id == "blue")
			{
				scorePost.postsX = 50;
				scorePost.leftPostY = 650;
				scorePost.rightPostY = 350;
			}else{
				throw new Error("crap team name");
			}
		}
		public function get pressureToPass():Boolean{
			return _pressureToPass;
		}
		public function set pressureToPass(data:Boolean):void{
			_pressureToPass = data;			
		}
		public function get maxSpeed():Number{
			return _maxSpeed;
		}
		public function set maxSpeed(data:Number):void{
			_maxSpeed = data;
		}
		public function get color():Array{
			return _color;
		}
		public function set color(data:Array):void{
			_color = data;
//			_keeper.color = data;
//			var i:uint;
//			for ( i=1;i<GameSettingsData.getInstance().numberOfPlayers;i++)
//			{
//				(this["player"+i.toString()] as PlayerData).color = data;
//			}
//			player1.color = data;
//			player2.color = data;
//			player3.color = data;
//			player4.color = data;
		}
		public function get playerWithBallData():PlayerData{
			return _playerWithBallData;
		}
		public function set playerWithBallData(data:PlayerData):void{
			_playerWithBallData = data;
		}
//		public function get keeper():PlayerData{
//			return _keeper;
//		}
//		public function get player1():PlayerData{
//			return _player1;
//		}
//		public function get player2():PlayerData{
//			return _player2;
//		}
//		public function get player3():PlayerData{
//			return _player3;
//		}
//		public function get player4():PlayerData{
//			return _player4;
//		}
//		public function set keeper(data:PlayerData):void{
//			_keeper = data;
//		}
//		public function set player1(data:PlayerData):void{
//			_player1 = data;
//		}
//		public function set player2(data:PlayerData):void{
//			_player2 = data;
//		}
//		public function set player3(data:PlayerData):void{
//			_player3 = data;
//		}
//		public function set player4(data:PlayerData):void{
//			_player4 = data;
//		}
		public function get state():String{
			return _state;
		}
		public function set state(data:String):void{
			_state = data;
//			player1.state = data;
//			player2.state = data;
//			player3.state = data;
//			player4.state = data;
//			_keeper.state = data;
		}		
		public function get newPlayerJustGotBall():Boolean{
			return _newPlayerJustGotBall;
		}
		public function set newPlayerJustGotBall(data:Boolean):void{
			_newPlayerJustGotBall = data;
			
		}
		public function set autoPassAngle(data:Number):void{
			_autoPassAngle = data;
				
		}
		public function get autoPassAngle():Number{
			return _autoPassAngle;
		}
		
		private function onGotBall(e:Event):void
		{
			_hasPossession = true;
			_newPlayerJustGotBall = true;
			SoccerBallData.getInstance().justKicked = false;
		
		}
		
		
	}
}