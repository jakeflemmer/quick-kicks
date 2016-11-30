package classes.events
{
	import flash.events.Event;

	public class GameEvents extends Event
	{
		public static const GOT_BALL:String = "gotBall";
		public static const PASS_BALL:String = "passBall";
		public static const GENERATING_KICK_POWER:String = "generatingKickPower";
		public static const PLAYER_HAS_BALL:String = "playerHasBall";
		public static const PLAYER_CONTROL_CHANGE:String = "playerControlChange";
		public static const PLAYER_GETTING_BALL_CHANGE:String = "playerGettingBallChange";
		public static const AUTO_PASS:String = "autoPass";
		public static const PASS_RECEIVER:String = " passReceiver";
		public static const JUST_PASSED:String = "justPassed";
		public static const X_POS_CHANGED:String = "xPosChanged";
		public static const Y_POS_CHANGED:String = "yPosChanged";
		public static const BALL_NOW_FREE:String = "ballNowFree";
		public static const CHANGE_POSSESSION:String = "changePossession";
		public static const PASS_NOW:String = "passNow";
		public static const JUST_BEATEN:String = "justBeaten";
		public static const PLAYER_RECOVERED:String = "playerRecovered";
		public static const NEW_GAME:String = "newGame";
		public static const GAME_PAUSED:String = "gamePaused";
		public static const GAME_UNPAUSED:String = "gameUnPaused";
		public static const GOAL_ANIMATION_OVER:String = "goalAnimationOver";
		public static const MANUAL_PASS:String = "manualPass";
		
		
		public function GameEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}