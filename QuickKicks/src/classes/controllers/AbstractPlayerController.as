package classes.controllers
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import classes.data.FieldData;
	import classes.data.GameSettingsData;
	import classes.data.PlayerData;
	import classes.data.SoccerBallData;
	import classes.interfaces.IPlayerController;
	import classes.tools.Calculator;
	import classes.tools.ESP;
	import classes.tools.RadiansCalculator;
	import classes.views.PlayerView;

	public class AbstractPlayerController extends Sprite implements IPlayerController
	{
		
//		protected var frameNo:uint;
		protected var oldFrameNo:uint;
		protected var radCalc:RadiansCalculator;
		
		protected var _data:PlayerData;	
		protected var _view:PlayerView;
		
		public function AbstractPlayerController():void
		{
				
			radCalc = new RadiansCalculator;	
			
			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);
			
		}
		protected function ON_ENTER_FRAME(e:Event = null):void
		{
			throw new Error("this function must be overriden"); 
		}
		
//  ___________________________________________________    PUBLIC METHODS     ______________________________________________________
	
		public function get gsd():GameSettingsData{
			return GameSettingsData.getInstance();
		}
		
		public function get sbd():SoccerBallData{
			return SoccerBallData.getInstance();
		}
		
		public function get data():PlayerData{
			return _data;
		}
		public function set data(data:PlayerData):void{
			_data = data;
		}
		protected function frameNumber():void{
			if ( _data.justPassed )
			{
				var fn:uint = FieldData.getInstance().frameNumber;
				if ( FieldData.getInstance().frameNumber > _data.passedFrameNo + gsd.passPauseFrames )
				{
					_data.justPassed = false;z
				}
			}	
			if ( _data.justBeaten )
			{
				var fn:uint = FieldData.getInstance().frameNumber;
				if ( FieldData.getInstance().frameNumber > _data.beatenFrameNo + gsd.beatenPauseFrames )
				{
					_data.justBeaten = false;z
				}
			}	
		}
		
		protected function positionPlayer():void
		{
			_data.xPos += _data.speedX;
			_data.yPos += _data.speedY;
		}
		protected function calculateDirection():void
		{
			if ( _data.speedX == 0 && _data.speedY == 0 ) return;		
			
			var radCalc:RadiansCalculator = new RadiansCalculator;
			_data.direction = RadiansCalculator.calc( _data.speedX , _data.speedY );			
		}
			
		
		
		protected function dribbleBall():void
		{					
//			if ( _data.speedX == 0 && _data.speedY == 0 ) {
//				_data.dribble = _data.direction;
//				return;			
//			}
			
			var drib : Number = _data.dribble;
			var dir : Number = _data.direction;
			var dribbleEasing:Number = GameSettingsData.getInstance().dribbleEaasing;
			var dribbleDelta:Number = dir - drib;
			if ( dribbleDelta > Math.PI ) {
				dribbleDelta = ( 2* Math.PI ) - dribbleDelta;
				dribbleDelta *= -1;
			} else if ( dribbleDelta < (-1 ) * Math.PI ) {
				dribbleDelta *= -1;
				dribbleDelta = ( 2 * Math.PI ) - dribbleDelta;
			}
			
			_data.dribble = _data.dribble + ( dribbleDelta * dribbleEasing );
			
			// place ball according to _data.dribble
			var bX:Number = _data.xPos + ( ( 1.75 * _data.radius) * Math.cos( _data.dribble) );
			var bY:Number = _data.yPos + ( ( 1.75 * _data.radius) * Math.sin( _data.dribble) );
			SoccerBallData.getInstance().xPos = bX;
			SoccerBallData.getInstance().yPos = bY;
			SoccerBallData.getInstance().speed = _data.speed;
			SoccerBallData.getInstance().direction = _data.direction;
		}
			
		protected function getBall():void
		{
			_data.destinationX = SoccerBallData.getInstance().xPos;
			_data.destinationY = SoccerBallData.getInstance().yPos;	
			ESP.p("getting ball","abstract","getting ball");
		}
		
		
		
		
		
		
		protected function hitTestBall():void
		{
			var bX:Number = SoccerBallData.getInstance().xPos;
			var bY:Number = SoccerBallData.getInstance().yPos;
			var x:Number = _data.xPos;
			var y:Number = _data.yPos;
			
			var distance:Number = Calculator.instance.pythagoreanDistance(bX-x,bY-y);		
			
			if ( distance <= ( _data.radius + SoccerBallData.getInstance().radius ) )  // Got the ball!
			{	
				if ( _data.justBeaten || _data.justPassed ){
				//ballBounceOff();
					return;
				} 				
				_data.hasBall = true;				
				SoccerBallData.getInstance().isFree = false; 
				SoccerBallData.getInstance().ballCarrier = _data;
				
				if ( _data.teamId == "red" )
				{
					SoccerBallData.getInstance().redPossession = true;	
				}else{
					SoccerBallData.getInstance().bluePossession = true;
				}
				
				
				var rC:RadiansCalculator = new RadiansCalculator;
				_data.dribble = RadiansCalculator.calc( bX - x, bY - y );				
			}
		}
		
		
		
		
		
			


//  ___________________________________________________________________________________________________________________________________

		
		
		
		
		
		
		
		
		
		
		
		
		
		
					
	} // close class
} // close package