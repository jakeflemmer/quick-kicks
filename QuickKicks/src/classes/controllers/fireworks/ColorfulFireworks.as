/****************************************************************************

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Copyright 2009 Terence Tsang
-- admin@shinedraw.com
-- http://www.shinedraw.com
-- Your Flash vs Silverlight Repositry

****************************************************************************/


package classes.controllers.fireworks {
	
	/*
	*	A Colorful Fireworks Demonstration in Actionscript 3
	*   from shinedraw.com
	*/
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ColorfulFireworks extends Sprite {
        private static var DOT_SIZE_MIN:Number = 1.5;        // The minimum dot size
        private static var DOT_SIZE_MAX:Number = 7.0;        // The maximum dot size
        private static var COLOR_OFFSET:Number = 128;      // Configure the brightness of the dots
	    private static var X_VELOCITY:Number = 5;              // Maximum X Velocity
        private static var Y_VELOCITY:Number = 5;              // Maximum Y Velocity
		private static var GRAVITY:Number = 0.5;               // Gravity
		private static var FIREWORK_NUM:Number = 3;            // Number of Dot generated each time
		private static var CRITICAL_ALPHA:Number = 0.1;			// Critical Point for removing useless dots
		
		// List for storing the added dots in the stage
        private var _fireworks : Array = new Array();
        
		public function ColourfulFirework():void
		{

		}

        /////////////////////////////////////////////////////        
        // Handlers
        /////////////////////////////////////////////////////	
        
        
        
        
		private function on_enter_frame(e:Event):void{
			// reposition all the magic dots
			moveFirework();
        	addFirework( (Math.random() * 1300) + 100, (Math.random() * 900) + 100);
		}
		
        /////////////////////////////////////////////////////        
        // Private Methods
        /////////////////////////////////////////////////////	


       	private function moveFirework():void
        {
            for (var i:int = _fireworks.length - 1; i >= 0; i--)
            {
                var dot : MagicDot = _fireworks[i] as MagicDot;
                dot.runFirework();
                
                // remove the dot if the alpha is too small
                if (dot.alpha <= CRITICAL_ALPHA)
                {
                    removeChild(dot);
                    _fireworks.splice(i, 1);
                }
            }
        }

        private function addFirework(x:Number, y:Number):void
        {
			
            for (var i:int = 0; i < FIREWORK_NUM; i++)
            {
                // define random properties of the magic dots
                var size : Number = DOT_SIZE_MIN + (DOT_SIZE_MAX - DOT_SIZE_MIN) * Math.random();
                var red : int = (COLOR_OFFSET + ((255 - COLOR_OFFSET) * Math.random()));
                var green : int = (COLOR_OFFSET + ((255 - COLOR_OFFSET) * Math.random()));
                var blue : int = (COLOR_OFFSET + ((255 - COLOR_OFFSET) * Math.random()));

                var xVelocity:Number = X_VELOCITY/2 +  - X_VELOCITY * Math.random();
                var yVelocity:Number = -Y_VELOCITY * Math.random();

                var dot : MagicDot = new MagicDot(red, green, blue, size);
                dot.x = x;
                dot.y = y;
                dot.xVelocity = xVelocity;
                dot.yVelocity = yVelocity;
                dot.gravity = GRAVITY;
                dot.runFirework();
                _fireworks.push(dot);

                addChild(dot);
            }
        }
        
        /////////////////////////////////////////////////////        
        // Private Methods
        /////////////////////////////////////////////////////	

		public function start():void{
			this.addEventListener(Event.ENTER_FRAME, on_enter_frame);	
			
		}
		public function stop():void{
			this.removeEventListener(Event.ENTER_FRAME, on_enter_frame);
		}
	}
}
