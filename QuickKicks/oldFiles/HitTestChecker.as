package classes
{
	import flash.events.EventDispatcher;


	public class HitTestChecker extends EventDispatcher
	{
		public static var _instance:HitTestChecker;
		
		protected var _redKeeperX:Number;
		protected var _redKeeperY:Number;
		
		protected var _redPlayer1X:Number;
		protected var _redPlayer1Y:Number;
		
		protected var _redPlayer2X:Number;
		protected var _redPlayer2Y:Number;
		
		protected var _redPlayer3X:Number;
		protected var _redPlayer3Y:Number;
		
		protected var _redPlayer4X:Number;
		protected var _redPlayer4Y:Number;
		
		protected var _blueKeeperX:Number;
		protected var _blueKeeperY:Number;
		
		protected var _bluePlayer1X:Number;
		protected var _bluePlayer1Y:Number;
		
		protected var _bluePlayer2X:Number;
		protected var _bluePlayer2Y:Number;
		
		protected var _bluePlayer3X:Number;
		protected var _bluePlayer3Y:Number;
		
		protected var _bluePlayer4X:Number;
		protected var _bluePlayer4Y:Number;
		
		protected var _redXPlayersArray:Array;
		protected var _redYPlayersArray:Array;
		protected var _blueXPlayersArray:Array;
		protected var _blueYPlayersArray:Array; 
		
		protected var collisionDistance:Number=100;
		
		
		public function HitTestChecker(parameter:SingletonEnforcer)
		{
			_redXPlayersArray = new Array(5);
			
			_redYPlayersArray = new Array(5);
			
			_blueXPlayersArray = new Array(5);
			
			_blueYPlayersArray = new Array(5);
		
				
		}
		public function doTests():void
		{
			_redXPlayersArray = [_redKeeperX,_redPlayer1X,_redPlayer2X,_redPlayer3X,_redPlayer4X];
			_redYPlayersArray = [_redKeeperY,_redPlayer1Y,_redPlayer2Y,_redPlayer3Y,_redPlayer4Y];
			_blueXPlayersArray = [_blueKeeperX,_bluePlayer1X,_bluePlayer2X,_bluePlayer3X,_bluePlayer4X];
			_blueYPlayersArray = [_blueKeeperY,_bluePlayer1Y,_bluePlayer2Y,_bluePlayer3Y,_bluePlayer4Y];
				
			hitTestRedKeeper();			
			
		}		
		public static function getInstance():HitTestChecker
		{
			if (_instance == null)
			{
				_instance = new HitTestChecker(new SingletonEnforcer());
			}
			return _instance;
		}
		
		private function hitTestRedKeeper():void{
			
			var deltaX:Number = 0;
			var deltaY:Number = 0;
			var sumDelta:Number = 0;
			
			//hit test red keeper against all other red player
			
			for (var i:int = 1;i < _redXPlayersArray.length; i++)
			{
				deltaX = Math.abs( _redKeeperX - _redXPlayersArray[i] );
				deltaY = Math.abs( _redKeeperY - _redYPlayersArray[i] );
				sumDelta = deltaX + deltaY;
				if ( sumDelta <= collisionDistance)
				{
					redKeeperHitRed(i);
				}		
			}
			
			//hit test red keeper against all blue players
			
		
		}
		private function redKeeperHitRed(who:int):void
		{
			trace("red keeper hit red" + who );
			
		}
		
		
		
		
		
		
		
//  _______________________________________________________________________________________________________________
//  _______________________________________________________________________________________________________________

		public function get redKeeperX():Number{
			return _redKeeperX;
		}
		public function get redKeeperY():Number{
			return _redKeeperY;
		}
		public function get redPlayer1X():Number{
			return _redPlayer1X;
		}
		public function get redPlayer1Y():Number{
			return _redPlayer1Y;
		}
		public function get redPlayer2X():Number{
			return _redPlayer2X;
		}
		public function get redPlayer2Y():Number{
			return _redPlayer2Y;
		}
		public function get redPlayer3X():Number{
			return _redPlayer3X;
		}
		public function get redPlayer3Y():Number{
			return _redPlayer3Y;
		}
		public function get redPlayer4X():Number{
			return _redPlayer4X;
		}
		public function get redPlayer4Y():Number{
			return _redPlayer4Y;
		}
		public function get blueKeeperX():Number{
			return _blueKeeperX;
		}
		public function get blueKeeperY():Number{
			return _blueKeeperY;
		}
		public function get bluePlayer1X():Number{
			return _bluePlayer1X;
		}
		public function get bluePlayer1Y():Number{
			return _bluePlayer1Y;
		}
		public function get bluePlayer2X():Number{
			return _bluePlayer2X;
		}
		public function get bluePlayer2Y():Number{
			return _bluePlayer2Y;
		}
		public function get bluePlayer3X():Number{
			return _bluePlayer3X;
		}
		public function get bluePlayer3Y():Number{
			return _bluePlayer3Y;
		}
		public function get bluePlayer4X():Number{
			return _bluePlayer4X;
		}
		public function get bluePlayer4Y():Number{
			return _bluePlayer4Y;
		}
//  ________________________________________________________________________________________________________________________________
//  ________________________________________________________________________________________________________________________________

		public function set redKeeperX(data:Number) :void{
			_redKeeperX = data;
		}
		public function set redKeeperY(data:Number) :void{
			_redKeeperY = data;;
		}
		public function set redPlayer1X(data:Number) :void{
			_redPlayer1X = data;;
		}
		public function set redPlayer1Y(data:Number) :void{
			_redPlayer1Y = data;
		}
		public function set redPlayer2X(data:Number) :void{
			_redPlayer2X = data;
		}
		public function set redPlayer2Y(data:Number) :void{
			_redPlayer2Y = data;
		}
		public function set redPlayer3X(data:Number) :void{
			_redPlayer3X = data;
		}
		public function set redPlayer3Y(data:Number) :void{
			_redPlayer3Y = data;
		}
		public function set redPlayer4X(data:Number) :void{
			_redPlayer4X = data;
		}
		public function set redPlayer4Y(data:Number) :void{
			_redPlayer4Y = data;
		}
		public function set blueKeeperX(data:Number) :void{
			_blueKeeperX = data;
		}
		public function set blueKeeperY(data:Number) :void{
			 _blueKeeperY = data;
		}
		public function set bluePlayer1X(data:Number) :void{
			 _bluePlayer1X = data;
		}
		public function set bluePlayer1Y(data:Number) :void{
			 _bluePlayer1Y = data;
		}
		public function set bluePlayer2X(data:Number) :void{
			 _bluePlayer2X = data;
		}
		public function set bluePlayer2Y(data:Number) :void{
			 _bluePlayer2Y = data;
		}
		public function set bluePlayer3X(data:Number) :void{
			 _bluePlayer3X = data;
		}
		public function set bluePlayer3Y(data:Number) :void{
			 _bluePlayer3Y = data;
		}
		public function set bluePlayer4X(data:Number) :void{
			 _bluePlayer4X = data;
		}
		public function set bluePlayer4Y(data:Number) :void{
			 _bluePlayer4Y = data;
		}
		
		
		
	}
}
class SingletonEnforcer{}