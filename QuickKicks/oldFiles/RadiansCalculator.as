package classes
{
	public class RadiansCalculator
	{
		public function RadiansCalculator()
		{
		}
		public static function calc(theX:Number =0,theY:Number=0):Number	// the destination minus the origin = theX
		{
			if ( theX == 0 ) theX = .01;
			if ( theY == 0 ) theY = .01;
			
					
				var absoluteRadians:Number = Math.atan( Math.sqrt( theY * theY )/ Math.sqrt( theX * theX ) );
				var trueRadians:Number = 0;
				
				// Determine Quadrant
				if ( theX > 0 && theY > 0 )		// Quadrant I
				{
					trueRadians = absoluteRadians;					
				}
				if ( theX > 0 && theY < 0 )		// Quadrant II
				{
					trueRadians =  - absoluteRadians ;					
				}
				if ( theX < 0 && theY > 0 )		// Quadrant III
				{
					trueRadians = ( Math.PI ) - absoluteRadians ;					
				}
				if ( theX < 0 && theY < 0 )		// Quadrant IV
				{
					trueRadians = ( - Math.PI ) + absoluteRadians ;					
				}
				
				if ( trueRadians < 0 ) trueRadians = ( 2 * Math.PI ) + trueRadians; // keep it positive
				if ( trueRadians > Math.PI * 2 ) trueRadians -= (Math.PI * 2);
				 
				return trueRadians;
		}
	}
}