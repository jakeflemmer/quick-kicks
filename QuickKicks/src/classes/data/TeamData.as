package classes.data
{
	import classes.events.GameEvents;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;


	public class TeamData extends EventDispatcher
	{
		private var _id:String = "";
		private var _color:Array;
		private var _keeper:PlayerData;
		private var _player1:PlayerData;
		private var _player2:PlayerData;
		private var _player3:PlayerData;
		private var _player4:PlayerData;
		private var _playerWithBallData:PlayerData;
		private var _playerWithMostSpace:PlayerData;
		private var _state:String = "nothing";
		private var _hasPossession:Boolean = false;
		private var _newPlayerJustGotBall:Boolean = false;
		private var _maxSpeed:Number = 4;
		private var _pressureToPass:Boolean = false;
		private var _closestTeamMate:PlayerData = new PlayerData();;
		private var _oldZone:uint = 0;
		private var _justPassed:Boolean = false;
		public var scorePost:ScorePostData = new ScorePostData();
		
		public var passLineFrameNo:uint = 0;
		public var justChangedPassLineIndicator: Boolean = false;
		
		[Bindable]
		private var _autoPassAngle:Number = 0;
		
				
		public function TeamData(keeper:PlayerData, player1:PlayerData, player2:PlayerData, player3:PlayerData, player4:PlayerData )
		{			
			_keeper = keeper;
			_player1 = player1;
			_player2 = player2;
			_player3 = player3;
			_player4 = player4;
			
			_keeper.xPos = 500;
			_keeper.yPos = 500;
			/*
			_keeper.addEventListener(GameEvents.GOT_BALL, onGotBall);
			_player1.addEventListener(GameEvents.GOT_BALL, onGotBall);
			_player2.addEventListener(GameEvents.GOT_BALL, onGotBall);
			_player3.addEventListener(GameEvents.GOT_BALL, onGotBall);
			_player4.addEventListener(GameEvents.GOT_BALL, onGotBall);
			
			_keeper.addEventListener(GameEvents.JUST_PASSED, onJustPassed);
			_player1.addEventListener(GameEvents.JUST_PASSED, onJustPassed);
			_player2.addEventListener(GameEvents.JUST_PASSED, onJustPassed);
			_player3.addEventListener(GameEvents.JUST_PASSED, onJustPassed);
			_player4.addEventListener(GameEvents.JUST_PASSED, onJustPassed);
			
			
			*/				
		}
		/*
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
		*/
		public function get playerWithMostSpace():PlayerData{
			return _playerWithMostSpace;
		}
		public function set playerWithMostSpace(val:PlayerData):void{
			_playerWithMostSpace = val;
		}
		public function get justPassed():Boolean{
			return _justPassed;
		}		
		public function get oldZone():uint{
			return _oldZone;
		}
		public function set oldZone(data:uint):void{
			_oldZone = data;
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
			_keeper.teamId = _id;
			_player1.teamId = _id;
			_player2.teamId = _id;
			_player3.teamId = _id;
			_player4.teamId = _id;
			
			_keeper.id = "keeper";
			_player1.id = "player1";
			_player2.id = "player2";
			_player3.id = "player3";
			_player4.id = "player4";
			
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
			_keeper.color = data;
			_player1.color = data;
			_player2.color = data;
			_player3.color = data;
			_player4.color = data;
		}
		public function get playerWithBallData():PlayerData{
			return _playerWithBallData;
		}
		public function set playerWithBallData(data:PlayerData):void{
			_playerWithBallData = data;
		}
		public function get keeper():PlayerData{
			return _keeper;
		}
		public function get player1():PlayerData{
			return _player1;
		}
		public function get player2():PlayerData{
			return _player2;
		}
		public function get player3():PlayerData{
			return _player3;
		}
		public function get player4():PlayerData{
			return _player4;
		}
		public function set keeper(data:PlayerData):void{
			_keeper = data;
		}
		public function set player1(data:PlayerData):void{
			_player1 = data;
		}
		public function set player2(data:PlayerData):void{
			_player2 = data;
		}
		public function set player3(data:PlayerData):void{
			_player3 = data;
		}
		public function set player4(data:PlayerData):void{
			_player4 = data;
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
			_keeper.justPassed = false;
			_player1.justPassed = false;
			_player2.justPassed = false;
			_player3.justPassed = false;
			_player4.justPassed = false;
		}
		
		
	}
}