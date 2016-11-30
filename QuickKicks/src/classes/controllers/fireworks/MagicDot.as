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
	
	import flash.display.Shape;	
	import flash.display.Sprite;
	
	public class MagicDot extends Sprite {
        // Please study the code for the usage of these variables
        private static var ELLIPSE_COUNT:int = 5;      // Number of ellipse make up of the magic dot
        private static var OPACITY:Number = 0.6;       // Initial opacity of the magic dot
        private static var OPACITY_INC:Number = -0.15; // Opacitiy Increment for the next ellipse

        public var swingRadius:Number;
        public var counter:int = 0;
        public var swingSpeed:int = 5;
        public var upSpeed:Number = 1;
        public var centerX:Number;
        		
        // for firwork
        public var fireworkOpacityInc:Number = -0.02;
        public var xVelocity:Number = 1;
        public var yVelocity:Number = 1;
        public var gravity:Number = 1;
        		
		public function MagicDot(red:int, green:int, blue:int, size:Number) {
            var opac:Number = OPACITY;
            
            for (var i:int = 0; i < ELLIPSE_COUNT; i++)
            {
            	var ellipse : Shape = new Shape();
            	var color:uint = red * 0x010000 + green * (0x000100) + blue;
                if (i == 0)
                {
                    // add a white dot in the center
	            	ellipse.graphics.beginFill(0xFFFFFF);
					ellipse.graphics.drawEllipse(0, 0, size, size);
                }
                else
                {
	            	ellipse.graphics.beginFill(color);
					ellipse.graphics.drawEllipse(0, 0, size, size);
					ellipse.alpha = opac;
                    opac += OPACITY_INC;
                    size += size;
                }
                // reposition the dots and add to the stage
                ellipse.x = -ellipse.width/2;
                ellipse.y = -ellipse.height /2;
                addChild(ellipse);
              
            }
        }

        /////////////////////////////////////////////////////        
        // Public Methods
        /////////////////////////////////////////////////////	

        // move the dot 
        public function runFirework():void
        {
            this.alpha += fireworkOpacityInc;

            yVelocity += gravity;
            x = x + xVelocity;
            y = y + yVelocity;
        }		
	}
}
