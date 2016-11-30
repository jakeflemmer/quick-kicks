package classes
{
	import flash.events.EventDispatcher;
	
	[Bindable]
	public class GameSettingsData extends EventDispatcher
	{
		public var numberOfPlayers:uint = 10;	
		
		public var device:String = "phone";
		private var _level:uint = 3;
		private var _speed:uint = 4;	
		public var blueScore:uint=0;
		public var redScore:uint=0;		
		private var _gameState:String = "demo";
		public var goalTimer:uint = 1000;
				
		public var blueTeamColor:Array = [0x0000ff,0x0f0f00];
		public var redTeamColor:Array = [0xff0000,0x0f0f00];
			
		public var playerRadius:uint = 13;
		public var soccerBallRadius:uint = 8;
		
		public var ballCarrierAIOn:Boolean = true;
		
		// game play settings
		
		public var numberOfFramesForGoalAnimation:uint = 10;

		// game state
		public var demoMode:Boolean = true;
		public var twoPlayerMode:Boolean = false;
		private var _paused:Boolean = false;
		private var _goalAnimation:Boolean = false;
		

		// passing
		public var passingSpeed:uint = 300;
		public var justPassedFrames:Number = 50;
		public var kickPower:uint = 45;
		public var soccerBallFriction:Number = 1.3;
		
		//moving
		public var blueTeamAcceleration:Number = 5;
		public var redTeamAcceleration:Number = 8;
		public var maxSpeed:uint = 30;
		public var fieldFriction:Number = 1;
		public var turningSpeed:Number = .4;
		
		//dribbling
		public var basicDribbleSpeed:Number = .4;
		public var dribbleAcceleration:Number = .3;
		public var maxDribbleSpeed:Number = .8;
		
		//marking && defending
		public var markingDistance:Number = playerRadius*4;
		public var takeBallDistance:Number = playerRadius*3;
		public var hitTestCaptureDistance:uint = playerRadius*3;
		
		// ball carrying
		public var enoughSpaceToTrySomething:uint = playerRadius * 4;
		public var dontHoldBallTooLongFrameLimit:uint = 20;	
		
		// instant replay settings			
		private var _replayPlaying:Boolean = false;
		public var numberOfFramesOfInstantReplay:uint = 20;
		
		public var showIcon:Boolean = true;
		
		public var justBeatTimer:Number = 600;			
		public var angleCloseEnoughForScoreBall:Number = Math.PI/2;
		public var openPassAngle:Number = .3;
	
		public var gamePlayerDecelerationFactor:Number = 3;
	//	public var dribbleSpeed:uint = 40;  // the smaller the number the faster the soccer balls spins around p[layer
	//	public var redDribbleAcceleration:Number = 0.5;
		
		//public var redMaxDribbleSpeed:Number = .3;
		public var spaceToTryBeatDefender:Number = playerRadius*4;
		public var passInterceptionSafetyDistance:uint = 15;
		
		public var keeperGoesForBallBias:int = -2000;
			
		private var _acceleration:Number = 1.5;
		
		public function get acceleration():Number{
			return _acceleration;
		}
		public function set acceleration(value:Number):void{
			_acceleration = value;
			blueTeamAcceleration = value;
			redTeamAcceleration = value;
			//dribbleAcceleration = value /3;
		}
		
		
		
		// blue team settings
		
		
		public var distanceBlueCanScoreFrom:uint = 800;
		
				
		// red team setting
	//	public var redTeamMaxSpeed:uint = 12;
	//	public var redTeamKickPower:uint = 60;
		
		public var distanceRedCanScoreFrom:uint = 700;

		// team function settings
		
		public var playerRemainControlledBias:uint = playerRadius;

		public var pressureThresholdDistance:Number = playerRadius*6;
		public var ballRadius:uint = 10;
		public var collisionDistance:Number = playerRadius * 2.1;
		public var minumumBumpSpeed:Number = 5;
		
		
		
		public var preventPlayerOverlapDistance:Number = playerRadius + ( playerRadius * .15);		
		public var preventBallOverlapDistance:Number = (playerRadius/2) + (soccerBallRadius/2) + (soccerBallRadius*.15);
		
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
				//	SpeedSettingsData.slower();
					trace("slower()");
				}	
			}
			if ( _speed > oldSpeed)
			{
				var timesFaster:uint = _speed - oldSpeed;
				for (i=0;i<timesFaster;i++)
				{
				//	SpeedSettingsData.faster();
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
		public function set replayPlaying(value:Boolean):void{
			_replayPlaying = value;
			_paused = value;			
		}
		public function get replayPlaying():Boolean{
			return _replayPlaying;
		}
		
		
		
		
		public function GameSettingsData(parameter:SingletonEnforcer)
		{
			if ( _instance != null ) throw new Error("singleton error");
			
			initEventListeners();
		
		}
		public static function getInstance():GameSettingsData
		{
			if (_instance == null)
			{
				_instance = new GameSettingsData(new SingletonEnforcer());
			}
			return _instance;
		}
		private function initEventListeners():void{
			
			TouchPad.getInstance().addEventListener(GameEvents.PASS_NOW, onTouchPadPassNow);
			KeyboardControls.getInstance().addEventListener(GameEvents.PASS_NOW, onKeyboardPassNow);
		}
		//===================================================================================================
		// EVENT HANDLERS
		//===================================================================================================
		
		private function onTouchPadPassNow(ge:GameEvents):void{
			if ( _replayPlaying )
			{				
				FieldData.getInstance().replayFrameCounter = 0;
			}
		}
		private function onKeyboardPassNow(ge:GameEvents):void{
			if ( _replayPlaying )
			{				
				FieldData.getInstance().replayFrameCounter = 0;
			}
		}
		
	}
}
class SingletonEnforcer{}