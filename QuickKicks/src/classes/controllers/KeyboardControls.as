package classes.controllers
{
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;

	public class KeyboardControls extends EventDispatcher
	{
		public static var instance:KeyboardControls;
		
		public var leftKey:Boolean = false;
		public var rightKey:Boolean = false;
		public var upKey:Boolean = false;
		public var downKey:Boolean = false;
		public var buildingKickPower:Boolean = false;
		public var passBall:Boolean = false;
		public var dribbleCCW:Boolean = false;
		public var dribbleCW:Boolean = false;
		public var upRightKey:Boolean = false;
		public var upLeftKey:Boolean = false;
		public var downRightKey:Boolean = false;
		public var downLeftKey:Boolean = false;
		
		public var twoLeft:Boolean = false;
		public var twoRight:Boolean = false;
		public var twoUp:Boolean = false;
		public var twoDown:Boolean = false;
		public var twoPass:Boolean = false;
		
		public function KeyboardControls(parameter:SingletonEnforcer)
		{
			
		}
		public static function getInstance():KeyboardControls
		{
			if (instance == null)
			{
				instance = new KeyboardControls(new SingletonEnforcer());
			}
			return instance;
		}
		public function onKeyDown(key:KeyboardEvent):void
		{
			// Arrow Keys
			//trace (key.keyCode);
			switch(key.keyCode)
			{
				case 33:
					upRightKey = true;
					break;
				case 34:
					downRightKey = true;
					break
				case 35:
					downLeftKey = true;
					break;
				case 36:
					upLeftKey = true;
					break;
				case 37:         						// left arrow key
					leftKey = true;
					break;
				case 38:
					upKey = true;
					break;
				case 39:
					rightKey = true;
					break;
				case 40:
					downKey = true;
					break;
				case 88:					// x
					dribbleCCW = true;
					break;trace("x");
				case 67:					// c
					dribbleCW = true;
					break;trace("c");
				case 77:                   //  m
					buildingKickPower = true;
					break;				
				// two player
				case 69:		// e
					twoUp = true;
					break;
				case 70:		// f
					twoRight = true;
					break;
				case 68:		// d
					twoDown	= true;
					break;
				case 83:		// s
					twoLeft = true;
					break;
				case 81:		// q
					twoPass = false;
					break;					
			}
		}
		public function onKeyUp(key:KeyboardEvent):void
		{
			switch(key.keyCode)
			{
				case 33:
					upRightKey = false;
					break;
				case 34:
					downRightKey = false;
					break
				case 35:
					downLeftKey = false;
					break;
				case 36:
					upLeftKey = false;
					break;
				case 37:         						// left arrow key
					leftKey = false;
					break;
				case 38:
					upKey = false;
					break;
				case 39:
					rightKey = false;
					break;
				case 40:
					downKey = false;
					break;
				case 88:					// x
					dribbleCCW = false;
					break;
				case 67:					// c
					dribbleCW = false;
					break
				case 90:   //77 is m - 90 is z
					passBall = true;					
					buildingKickPower = false;
					break;
				// two player				
				case 69:		// e
					twoUp = false;
					break;
				case 70:		// f
					twoRight = false;
					break;
				case 68:		// d
					twoDown	= false;
					break;
				case 83:		// s
					twoLeft = false;
					break;
				case 81:		// q
					twoPass = true;
					break;				
			}			
		}
		
//		public function get leftKey():Boolean{
//			return leftKey;
//		}
//		public function get rightKey():Boolean{
//			return rightKey;
//		} 
//		public function get upKey():Boolean{
//			return upKey;
//		}
//		public function get downKey():Boolean{
//			return downKey;
//		}
//		public function get buildingKickPower():Boolean{
//			return buildingKickPower;
//		}
//		public function get dribbleCCW():Boolean{
//			return dribbleCCW;
//		}		
//		public function get dribbleCW():Boolean{
//			return dribbleCW;
//		}
//		public function get passBall():Boolean{
//			return passBall;
//		}
//		public function set passBall(data:Boolean):void{
//			passBall = data;
//		}
//		public function get upLeftKey():Boolean{
//			return upLeftKey;
//		}
//		public function get upRightKey():Boolean{
//			return upRightKey;
//		}
//		public function get downLeftKey():Boolean{
//			return downLeftKey;
//		}
//		public function get downRightKey():Boolean{
//			return downRightKey;
//		}

	}
}
class SingletonEnforcer{}