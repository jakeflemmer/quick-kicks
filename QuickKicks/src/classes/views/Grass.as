package classes.views
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import classes.data.FieldData;
	
		public class Grass extends Shape
		{
			
			private var FIELD_WIDTH:Number = 0;
			private var FIELD_HEIGHT:Number = 0;
			private var _data:FieldData;
			
			public function Grass()
			{
				_data = FieldData.getInstance();
				_data.addEventListener(Event.RESIZE,draw);
				
				FIELD_WIDTH = _data.fieldWidth;
				FIELD_HEIGHT = _data.fieldHeight;
				
				drawCircles();
				
			}
			
			private function drawCircles():void{
				
				var darkColors:Array = [0x228822,0x33cc33];
				var lightColors:Array = [0x33aa33,0x55cc55];
				
				
				var colors:Array;
				var circleRadius:Number = ( FIELD_WIDTH * .5 ) / 5;
				var radius:Number;
				
				for ( var i : uint = 0 ; i < 5; i++ )
				{
					if ( i % 2 )
					{
						colors = darkColors;
					}else{
						colors = lightColors;
					}
					radius = ( FIELD_WIDTH * .5 ) - ( circleRadius * i );
					drawCircle(colors,radius);
				}
			}
			private function drawCircle(colors:Array,_radius:Number):void{
				graphics.lineStyle(0,0,0);
				
				var alphas:Array = [1,1];
				var ratios:Array = [0,255];
				var matrix:Matrix = new Matrix();
				
				matrix.createGradientBox(FIELD_WIDTH,FIELD_HEIGHT,
					//_radius,
					//_radius,
					0,
					FIELD_WIDTH*.25,
					FIELD_HEIGHT*.25);
				
				graphics.beginGradientFill(
					GradientType.RADIAL,
					colors,
					alphas,
					ratios,
					matrix,
					null,
					null,
					0);
				
				graphics.drawCircle(FIELD_WIDTH*.5,FIELD_HEIGHT*.5,_radius);
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
				
				//halfWayLine();
				
			}
			
			
			private function halfWayLine():void
			{
				// DRAW HALF WAY LINE
				with (graphics)
				{
					lineStyle(5,0xffffff,.2);
					moveTo(750,50);
					lineTo( 750,950);
				}			
			}
			
		} // close class
	}
