package classes
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class SoccerBallController extends Sprite
	{
		public static var _instance:SoccerBallController;
		private var _data:SoccerBallData;
		private var _view:SoccerBallView;
		private var _soccerBallFriction:Number;
		private var radCalc:RadiansCalculator;
		
		public function SoccerBallController(parameter:SingletonEnforcer)
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_data = SoccerBallData.getInstance();
			_view = new SoccerBallView;
			radCalc = new RadiansCalculator;
		
			_soccerBallFriction = FieldData.getInstance().soccerBallFriction;
				
			addChild(_view);			
		}
		public static function getInstance():SoccerBallController
		{
			if (_instance == null)
			{
				_instance = new SoccerBallController(new SingletonEnforcer());
			}
			return _instance;
		}
		
		public function kick(value:Number):void
		{
			_data.speed = value;
		}
//  __________________________________________________   ON ENTER FRAME    ___________________________________________
		
		private function onEnterFrame(e:Event):void
		{
			if (GameSettingsData.getInstance().paused) return;
			
			if (_data.isFree)
			{
				factorInFriction();				
								
				_data.xPos += ( _data.speed * Math.cos(_data.direction));
				_data.yPos += ( _data.speed * Math.sin(_data.direction));
			
			} 	
		

			
			checkBounds();
			
			//bendIt();
			
		}
		private function bendIt():void
		{
			if (_data.passReceiver == null ) return;
			
			var angleOfPassReceiver:Number = RadiansCalculator.calc(_data.passReceiver.xPos - _data.xPos, _data.passReceiver.yPos - _data.yPos);
			if ( Math.abs(angleOfPassReceiver - _data.direction) > Math.PI)  // problem of 0 - 2PI at 0 degrees
			{
				// solve problem here
			}
			if ( angleOfPassReceiver > _data.direction)
			{
				_data.direction +=.05;
			}
			if ( angleOfPassReceiver < _data.direction)
			{
				_data.direction -=.05;
			}
		}
		private function factorInFriction():void
		{
			if ( _data.speed >=  _soccerBallFriction ) 
				{
					_data.speed -=  _soccerBallFriction;
				} else {
					_data.speed = 0;
				}
		}
		private function checkBounds():void
		{
			if (_data.yPos <= 50 )
			{
				_data.yPos +=10;
				_data.direction = ( 2 * Math.PI ) - _data.direction;				
			}
			if (_data.xPos <= 50 )
			{
				_data.xPos += 15;
				_data.direction = (  Math.PI ) - _data.direction;
			}
			if (_data.xPos >= 1450)
			{
				_data.xPos -= 10;
				_data.direction = (  Math.PI ) - _data.direction;
			}
			if (_data.yPos >= 950 )
			{
				_data.yPos -=10;
				_data.direction = ( 2 * Math.PI ) - _data.direction;
			}
		}
	}
}
class SingletonEnforcer{}