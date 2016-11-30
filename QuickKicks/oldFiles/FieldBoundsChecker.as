package classes
{
	public class FieldBoundsChecker
	{
		private static var instance:FieldBoundsChecker;
		
		public function FieldBoundsChecker()
		{
			// This class is obviously here to check the field bounds
			// and make sure each player remains within them
			if ( instance != null )
			{
				throw new Error("hey this is sposed to be a singleton !!");
			}
		}
		public static function getInstance():FieldBoundsChecker{
			
			if ( instance == null )
			{
				instance = new FieldBoundsChecker();
			}
			return instance;
		}
		
		//--------------------------------------------------------------------------------------------------
		// PUBLIC MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		// This method is functioning correctly if it returns a PlayerData that has
		// its xPos and yPos set to withing the field's bounds
		public function checkFieldBounds(pd:PlayerData):PlayerData{
						
			
			if ( pd.isKeeper && pd.teamId == "blue")
			{
				if ( pd.xPos >= (1500 - pd.radius - 50  )){
					pd.xPos = ( 1500 - pd.radius  -50 ) - 5;
					pd.speedX = 0;
				}
				if ( pd.xPos <=  (1050 + pd.radius) ){
					pd.xPos = 1055 + pd.radius;
					pd.speedX = 0;
				}
				if ( pd.yPos >= (750 - pd.radius )){
					pd.yPos = ( 750 - pd.radius ) - 5;
					pd.speedY = 0;
				}
				if ( pd.yPos <= (250 + pd.radius) ){
					pd.yPos = 250 + pd.radius + 5;
					pd.speedY = 0;
				}			
				return pd;
			}
			if ( pd.isKeeper && pd.teamId == "red" )
			{
				if ( pd.xPos >= (450 - pd.radius  )){
					pd.xPos = ( 450 - pd.radius  ) - 5;
					pd.speedX = 0;
				}
				if ( pd.xPos <=  (50 + pd.radius) ){
					pd.xPos = 55 + pd.radius;
					pd.speedX = 0;
				}
				if ( pd.yPos >= ( 750 - pd.radius )){
					pd.yPos = ( 750 - pd.radius ) - 5;
					pd.speedY = 0;
				}
				if ( pd.yPos <= (250 + pd.radius) ){
					pd.yPos = 250 + pd.radius + 5;
					pd.speedY = 0;
				}			
				return pd;
			}
			if ( ! pd.hasBall )
			{
				if ( pd.xPos >= (1500 - pd.radius - 50 )){
					pd.xPos = ( 1500 - pd.radius - 50 ) - 5;
					pd.speedX = 0;
				}
				if ( pd.xPos <=  (50 + pd.radius) ){
					pd.xPos = 55 + pd.radius;
					pd.speedX = 0;
				}
				if ( pd.yPos >= (1000 - pd.radius - 50 )){
					pd.yPos = ( 1000 - pd.radius - 50 ) - 5;
					pd.speedY = 0;
				}
				if ( pd.yPos <= (50 + pd.radius) ){
					pd.yPos = 55 + pd.radius;
					pd.speedY = 0;
				}
			} else {      // smaller bounds with ball so ball doesn't go through the wall.
				if ( pd.xPos >= ( 1500 - pd.radius - 50 - SoccerBallData.getInstance().radius)){
					pd.xPos = ( 1500 - pd.radius - 50 - SoccerBallData.getInstance().radius) - 5;
					pd.speedX = 0;
				}
				if ( pd.xPos <=  (50 + pd.radius + SoccerBallData.getInstance().radius) ){
					pd.xPos = 55 + pd.radius + SoccerBallData.getInstance().radius;
					pd.speedX = 0;
				}
				if ( pd.yPos >= (1000 - pd.radius - 50 - SoccerBallData.getInstance().radius)){
					pd.yPos = ( 1000 - pd.radius - 50 - SoccerBallData.getInstance().radius) - 5;
					pd.speedY = 0;
				}
				if ( pd.yPos <= (50 + pd.radius + SoccerBallData.getInstance().radius) ){
					pd.yPos = 55 + pd.radius + SoccerBallData.getInstance().radius;
					pd.speedY = 0;
				}
			}
		
			return pd;		
			
			
		}
		//--------------------------------------------------------------------------------------------------
		// PRIVATE MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------------------------------
		// EVENT HANDLERS 
		//--------------------------------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------------------------------
		// GETTERS & SETTERS 
		//--------------------------------------------------------------------------------------------------
		
		
		

	}
}