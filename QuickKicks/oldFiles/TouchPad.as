package classes
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Timer;

	public class TouchPad extends Sprite
	{
		
		// this is a super cool and exciting class !! :)
		
		// a couple of things need to be developed here
		// this new tecnology of movement allows itself to express the idea of the first touch in soccer pretty well
		// if user swypes accross screen then even after they lift the finger off the pad
		// there should be a linger effect based on the amount of movement they expressed
		
		// and obviously a quick tap must be a pass
		
		private static var instance:TouchPad;
		
		//CONTROLS
		
		public var spinCCW:Boolean = false;
		public var spinCW:Boolean = false;
		public var thrust:Boolean = false;
		
		
		
		public var tpScaleX:Number;
		public var tpScaleY:Number;

		private var startX:Number;
		private var startY:Number;
		
		private var touchTimer:Timer;
		private var moveTimer:Timer;
		
		
		
		
		private var touching:Boolean = false;
		
		
		public function TouchPad()
		{
			super();
			
			if ( instance != null)
			{
				throw new Error("singleton error");
			}
			
			drawPadAreas();			
			
			touchTimer = new Timer(300,100);
			moveTimer = new Timer(50,100);
		}
		
		public static function getInstance():TouchPad{
			if ( instance == null)
			{
				instance = new TouchPad();
			}
			return instance;
		}
		private function drawPadAreas():void{
			
			with ( graphics )
			{
				lineStyle(1,0xffffff,1);
				beginFill(0xff0000,1);
				drawRect(0,800,750,200);
				beginFill(0x00ff00,.3);
				drawRect(750,800,750,100);
				beginFill(0x0000ff,.3);
				drawRect(750,900,750,100);
			}
		}
		
		
		
		//==========================================================================================================
		// OLD CODE
		//==========================================================================================================
		
		public function touchdown(me:MouseEvent):void{
			
			startX = me.localX;// * ( 1/scaleX);
			startY = me.localY;// * ( 1/scaleY);	
			
			touching = true;
			touchTimer.reset();			
			touchTimer.start();
			moveTimer.reset();	
			moveTimer.start(); 
			
			//drawCircle();
			
		}
		
		public function oldMove(me:MouseEvent):void{
			
			if ( !touching ) return;
			
			if ( moveTimer.currentCount > 0 )
			{
				startX = me.localX;
				startY = me.localY;
			}
			
			moveTimer.reset();
			
			var trueX:Number = me.localX;// * ( 1/ scaleX);
			var trueY:Number = me.localY;// * ( 1/ scaleY);
			
			var moveX:Number = ( trueX - startX );
			var moveY:Number = ( trueY - startY );
			
			if ( moveX > 0 )
			{
				KeyboardControls.getInstance().rightKey = true;
				KeyboardControls.getInstance().leftKey = false;
			}
			if ( moveX < -0 )
			{
				KeyboardControls.getInstance().leftKey = true;
				KeyboardControls.getInstance().rightKey = false;
			}
			if ( moveY > 0 )
			{
				KeyboardControls.getInstance().downKey = true;
				KeyboardControls.getInstance().upKey = false;
			}
			if ( moveY < -0 )
			{
				KeyboardControls.getInstance().upKey = true;
				KeyboardControls.getInstance().downKey = false;
			}
			
		}
		public function touchup(me:MouseEvent):void{
			
			touching = false;
			
			if ( touchTimer.currentCount < 1 )
			{
				KeyboardControls.getInstance().passBall = true;	
				var ge:GameEvents = new GameEvents(GameEvents.PASS_NOW);  // listened for by game setting data so skip instant replays
				this.dispatchEvent(ge);										// and field controller to clear passing cache		
			}
			
			KeyboardControls.getInstance().resetAllKeys();
			
		}
		
	}
}