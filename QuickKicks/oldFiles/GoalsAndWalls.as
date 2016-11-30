package classes
{
	import classes.*;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class GoalsAndWalls extends Shape
	{
		
		private var FIELD_WIDTH:Number = 0;
		private var FIELD_HEIGHT:Number = 0;
		private var _data:FieldData;
		
		public function GoalsAndWalls()
		{
			_data = FieldData.getInstance();
			_data.addEventListener(Event.RESIZE,draw);
			
		}
		
		public function draw(e:Event = null):void
		{
		
			graphics.clear();	

			FIELD_WIDTH = _data.fieldWidth;
			FIELD_HEIGHT = _data.fieldHeight;

			// w a l l s
			var colors:Array = [0x11790b,0x16be0e,0x11790b];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,128,255];
			var matrix:Matrix = new Matrix();
				
			//  TOP WALL
			matrix.createGradientBox(FIELD_HEIGHT,
				50,
				Math.PI/2,
				0,
				25);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);

			with (graphics)  
			{
			lineStyle(0,0,0);
			moveTo(0,0);
			
			lineTo(FIELD_WIDTH,0);
			lineTo(FIELD_WIDTH-50,50);
			lineTo(50,50);
			lineTo(0,0);
			}
			
			//  RIGHT WALL
			matrix.createGradientBox(50,
				FIELD_HEIGHT,
				Math.PI,
				FIELD_WIDTH-75,
				0);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			
			with (graphics)  
			{
			moveTo(FIELD_WIDTH,0);
			
			lineTo(FIELD_WIDTH-50,50);
			lineTo(FIELD_WIDTH-50,FIELD_HEIGHT-50);
			lineTo(FIELD_WIDTH,FIELD_HEIGHT);
			lineTo(FIELD_WIDTH,0);
			}
			
			// BOTTOM WALL
			matrix.createGradientBox(FIELD_HEIGHT,
				50,
				3*(Math.PI/2),
				300,
				FIELD_HEIGHT-75);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);

			with (graphics)
			{
			
			moveTo(FIELD_WIDTH,FIELD_HEIGHT);
			
			lineTo(0,FIELD_HEIGHT);
			lineTo(50,FIELD_HEIGHT-50);
			lineTo(FIELD_WIDTH-50,FIELD_HEIGHT-50);
			lineTo(FIELD_WIDTH,FIELD_HEIGHT);
			}

			// LEFT WALL
			matrix.createGradientBox(50,
				FIELD_HEIGHT,
				0,
				25,
				0);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			
			with (graphics)
			{
				
			moveTo(0,FIELD_HEIGHT);
			
			lineTo(0,0);
			lineTo(50,50);
			lineTo(50,FIELD_HEIGHT-50);
			lineTo(0,FIELD_HEIGHT);
			}
					
//  ________________________________________________   goals
		// g o a l s
			// LEFT GOAL  -- Red's goal	

			with (graphics)
			{
			matrix.createGradientBox(50,
				200,
				Math.PI ,
				-15,
				0);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				[0xcc0f00,0x0f0f00,0x00ff00],
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			moveTo(0,(FIELD_HEIGHT/2)-200);
			lineTo(50,(FIELD_HEIGHT/2)-200);
			lineTo(50,(FIELD_HEIGHT/2)+200);
			lineTo(0,(FIELD_HEIGHT/2)+200);
			lineTo(0,(FIELD_HEIGHT/2)-200);
			
			// RIGHT GOAL	--  Blue's goal
			matrix.createGradientBox(50,
				200,
				0,
				FIELD_WIDTH-35,
				0);
			graphics.beginGradientFill(
				GradientType.LINEAR,
				[0x0000ff,0x0f0f00,0x00ff00],
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
				
			
			moveTo(FIELD_WIDTH-50,(FIELD_HEIGHT/2)-200);
			lineTo(FIELD_WIDTH,(FIELD_HEIGHT/2)-200);
			lineTo(FIELD_WIDTH,(FIELD_HEIGHT/2)+200);
			lineTo(FIELD_WIDTH-50,(FIELD_HEIGHT/2)+200);
			lineTo(FIELD_WIDTH-50,(FIELD_HEIGHT/2)-200);
			
			
			} // close graphics
			
			halfWayLine();
			halfWayCircle();
			redGoalBox();
			blueGoalBox();
			
		}
		
		
		private function halfWayLine():void
		{
			// DRAW HALF WAY LINE
			with (graphics)
			{
				lineStyle(5,0xffffff,.5);
				moveTo(750,50);
				lineTo( 750,950);
			}			
		}
		private function halfWayCircle():void
		{
			// DRAW HALF WAY CIRCLE
			with (graphics)
			{
				endFill();
				lineStyle(5,0xffffff,.5);				
				drawCircle(750,500,100);
			}			
		}
		private function redGoalBox():void
		{			
			with (graphics)
			{				
				lineStyle(5,0xffffff,.5);				
				moveTo(50,300);
				lineTo(200,300);
				lineTo(200,700);
				lineTo(50,700);
			}			
		}
		private function blueGoalBox():void
		{		
			with (graphics)
			{				
				lineStyle(5,0xffffff,.5);				
				moveTo(1450,300);
				lineTo(1300,300);
				lineTo(1300,700);
				lineTo(1450,700);
			}			
		}
		
				
	} // close class
} // close package