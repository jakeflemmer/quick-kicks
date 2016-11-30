package classes.data
{
	import flash.events.EventDispatcher;
	
	import classes.events.GameEvents;
	
	[Bindable]
	public class GameSettingsData extends EventDispatcher
	{
			
		public var demoMode:Boolean = true;
		public var twoPlayerMode:Boolean = false;
		private var _level:uint = 3;
		private var _speed:uint = 1;
		
		private var _paused:Boolean = false;
		private var _goalAnimation:Boolean = false;
		public var blueScore:uint=0;
		public var redScore:uint=0;		
		private var _gameState:String = "demo"; 
		
		
		
			
		public var playerRadius:uint = 45;
		public var soccerBallRadius:uint = 25;
		public var goalTimer:uint = 2000;


		// SPEED SETTINGS
		//==================================================================================
		
		public var fieldFriction:Number = .1;
		public var soccerBallFriction:Number = 0.5;
		
		public var decelerationFactor:Number = 4;
		public var gamePlayerDecelerationFactor:Number = 1;
		
		public var blueDribbleAcceleration:Number = 0.3;	// the speed at which rotation of ball around player increases
		public var redDribbleAcceleration:Number = 0.3;
		
		public var blueMaxDribbleSpeed:Number = .4;	// speed at which ball rotates around player
		public var redMaxDribbleSpeed:Number = .4;
		
		public var dribbleEaasing:Number = .2;
		
		public var blueTeamAcceleration:Number = .4;
		public var redTeamAcceleration:Number =.4;
		
		public var blueTeamMaxSpeed:uint = 8;
		public var redTeamMaxSpeed:uint = 8;
		
		public var blueTeamKickPower:uint = 30;
		public var redTeamKickPower:uint = 30;
		
		
		public var distanceBlueCanScoreFrom:uint = 800;
		public var distanceRedCanScoreFrom:uint = 700;
		
		public var passPauseFrames:int = 25;
		public var passLinePauseFrames:int = 5;
		
		public var beatenPauseFrames:int = 7;
		
		
		
		//==================================================================================
		
		// COLORS
		public var redTeamColors:Array = [0xff0000,0x220000];
		public var redTeamKeeperColor:Array = [0xffff00,0x220000];
		public var blueTeamColors:Array = [0x0000ff,0x000022];		
		public var blueTeamKeeperColor:Array = [0x00ff00,0x000022];
		//----------------------------------------------------
		
		//game settings
		public var markingDistance:Number = playerRadius*3;
		
		public var justBeatTimer:Number = 600;	
		
		
		
		public var angleCloseEnoughForScoreBall:Number = Math.PI/2;
		public var justPassedFrames:Number = 500;	// apparently useless
		public var openPassAngle:Number = .3;
		
		
		
		public var basicDribbleSpeed:Number = .3;
		
		
		
		
		
		
		
		public var takeBallDistance:Number = playerRadius;
		public var spaceToTryBeatDefender:Number = playerRadius*4;
		public var passInterceptionSafetyDistance:uint = 15;
		
		public var keeperGoesForBallBias:int = -2000;
			
		
		

		// team function settings
		
		public var playerRemainControlledBias:uint = playerRadius * 4;

		public var pressureThresholdDistance:Number = playerRadius*6;
		public var ballRadius:uint = 10;
		public var collisionDistance:Number = playerRadius * 2.1;
		public var minumumBumpSpeed:Number = 5;
		
		public var numberOfPlayers:uint = 5;
		
		
		public var preventPlayerOverlapDistance:Number = playerRadius + ( playerRadius * .15);		
		public var preventBallOverlapDistance:Number = (playerRadius/2) + (soccerBallRadius/2) + (soccerBallRadius*.15);
		
		
		
		
		// apparently not used
		//==============================================================================
		public var dribbleSpeed:uint = 3;  // - apparently not used -  the smaller the number the faster the soccer balls spins around p[layer
		public var passingSpeed:uint = 100;	// appears to have no effect
		
		private static var _instance:GameSettingsData;
		
		
		public function get level():uint{
			return _level;
		}
		public function set level(data:uint):void{			
			_level = data;
			LevelSettingsData.setLevel(data);
		}
		public function get speed():uint{
			return _speed;
		}
		public function set speed(data:uint):void{
			var oldSpeed:uint = _speed;
			_speed = data;
			var i:uint = 0;
			if ( _speed < oldSpeed)
			{
				var timesSlower:uint = oldSpeed - _speed;
				for (i=0;i<timesSlower;i++)
				{
					SpeedSettingsData.slower();
					trace("slower()");
				}	
			}
			if ( _speed > oldSpeed)
			{
				var timesFaster:uint = _speed - oldSpeed;
				for (i=0;i<timesFaster;i++)
				{
					SpeedSettingsData.faster();
					trace("faster()");
				}
			}
		}
		
		
		public function get goalAnimation():Boolean{
			return _goalAnimation;
		}
		public function set goalAnimation(data:Boolean):void{
			_goalAnimation = data;
			if ( ! data )
			{
				dispatchEvent(new GameEvents(GameEvents.GOAL_ANIMATION_OVER));
			}
		}
		public function get paused():Boolean{
			return _paused;
		}
		public function set paused(data:Boolean):void{
			if (data) dispatchEvent(new GameEvents(GameEvents.GAME_PAUSED));			
			if (!data) dispatchEvent(new GameEvents(GameEvents.GAME_UNPAUSED));
			_paused = data;
		}
		public function get gameState():String{
			return _gameState;
		}
		public function set gameState(data:String):void{
			_gameState = data;
		}
		//public function get redScore():uint{
		//	return _redScore;
		//}
		//public function set redScore(data:uint):void{
		//	_redScore = data;
		//}
		//public function get blueScore():uint{
		//	return _blueScore;
		//}
		//public function set blueScore(data:uint):void{
		//	_blueScore = data;
		//}
		
		public function newGame():void
		{
			dispatchEvent(new GameEvents(GameEvents.NEW_GAME));
			redScore = 0;
			blueScore = 0;
			//trace(_redScore + " : " + _blueScore);
		}
		public function GameSettingsData(parameter:SingletonEnforcer)
		{
			
		
		}
		public static function getInstance():GameSettingsData
		{
			if (_instance == null)
			{
				_instance = new GameSettingsData(new SingletonEnforcer());
			}
			return _instance;
		}
		
		
	}
}
class SingletonEnforcer{}