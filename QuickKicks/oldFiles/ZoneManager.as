package classes
{
	import flash.events.EventDispatcher;

	public class ZoneManager extends EventDispatcher
	{
		public var zonesArray:Array;
		public var i : uint//  for loop counting
//		private var zoneXSize:uint;
//		private var zoneYSize:uint;
		
		public function ZoneManager()
		{
			// This class is here to assign each player data a zone that the player must move around in and try to get 
			// space from the player marking them in
			// The zone is obviously calculated based on the number of players
			// Also , whenever the player with the ball moves into another team mates zone
			// then that team mate must switch zones with the player with the ball
			
			defineZones();
		}
		
		//--------------------------------------------------------------------------------------------------
		// PUBLIC MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		public function assignEveryPlayerTheirZone(playersArray:Array):Array{
			
			if ( ! playersArray || ! playersArray.length > 1 )
			 	throw new Error("Zone Assigner was passed a null array");
			 	
			 // ignore the keeper - he is never trying to get free - only trying to protect the goal
			 // keepers zone is always zone zero
			 
			 
			 if ( (playersArray[0] ).data.teamId == "red" )
			 {
			 	return assignAllRedPlayersTheirZones(playersArray);
			 }else{
			 	return assignAllBluePlayersTheirZones(playersArray);
			 }			
			
		}
		
		public function checkZonePlayerWithBallIsIn(pwbd:PlayerData):uint{ // returns zone number
			if (pwbd.isKeeper) {
			//	trace ( "Player with ball is keeper !!" )
				return 0;			
			}
			var x:Number = pwbd.xPos;
			var y:Number = pwbd.yPos;
			var i:uint;
			for (i=1;i<GameSettingsData.getInstance().numberOfPlayers;i++)
			{
				if ( x >= ( zonesArray[i] as PlayerZone ).minX && x < ( zonesArray[i] as PlayerZone ).maxX )
				{
					if ( y >= ( zonesArray[i] as PlayerZone ).minY && y < ( zonesArray[i] as PlayerZone ).maxY )
					{
						return ( zonesArray[i] as PlayerZone ).zoneNum;
					}
				}
			}	
		//	trace ( "Player with ball is not in any zone !!" )
			return 0;		
		}
		
		
		
		
		
		
		
		//--------------------------------------------------------------------------------------------------
		// PRIVATE METHODS
		//--------------------------------------------------------------------------------------------------
		
		private function defineZones():void{
			
			// zones occur between x=300 and x=1200 and y=100 and y=900
			
			zonesArray = new Array();
			 // keepers zone is always zone zero	
			zonesArray[0] = new PlayerZone;	 // keeper zone has no properties 
			
			switch ( GameSettingsData.getInstance().numberOfPlayers )
			{
				case ( 5 ):
//					this.zoneXSize =  ( 900 / 2 ) ;
//					this.zoneYSize = ( 800 / 2) ;

					for ( i=0; i < 5; i++)
					{
						zonesArray[i] = new PlayerZone();
					}
					
					(zonesArray[1] as PlayerZone).minX = 300;
					(zonesArray[1] as PlayerZone).maxX = 750;
					(zonesArray[1] as PlayerZone).minY = 100;
					(zonesArray[1] as PlayerZone).maxY = 500;
					
					(zonesArray[2] as PlayerZone).minX = 300;
					(zonesArray[2] as PlayerZone).maxX = 750;
					(zonesArray[2] as PlayerZone).minY = 500;
					(zonesArray[2] as PlayerZone).maxY = 900;
					
					(zonesArray[3] as PlayerZone).minX = 750;
					(zonesArray[3] as PlayerZone).maxX = 1200;
					(zonesArray[3] as PlayerZone).minY = 100;
					(zonesArray[3] as PlayerZone).maxY = 500;
					
					(zonesArray[4] as PlayerZone).minX = 750;
					(zonesArray[4] as PlayerZone).maxX = 1200;
					(zonesArray[4] as PlayerZone).minY = 500;
					(zonesArray[4] as PlayerZone).maxY = 900;
					
					break;
				case ( 7 ):
//					this.zoneXSize = ( 900 / 2 );
//					this.zoneYSize = int ( ( 800 / 3) ) ;
					
					for ( i=0; i < 7; i++)
					{
						zonesArray[i] = new PlayerZone();
					}
					
					(zonesArray[1] as PlayerZone).minX = 300;
					(zonesArray[1] as PlayerZone).maxX = 750;
					(zonesArray[1] as PlayerZone).minY = 100;
					(zonesArray[1] as PlayerZone).maxY = 350;
					
					(zonesArray[2] as PlayerZone).minX = 300;
					(zonesArray[2] as PlayerZone).maxX = 750;
					(zonesArray[2] as PlayerZone).minY = 350;
					(zonesArray[2] as PlayerZone).maxY = 650;
					
					(zonesArray[3] as PlayerZone).minX = 300;
					(zonesArray[3] as PlayerZone).maxX = 750;
					(zonesArray[3] as PlayerZone).minY = 650;
					(zonesArray[3] as PlayerZone).maxY = 900;
					
					(zonesArray[4] as PlayerZone).minX = 750;
					(zonesArray[4] as PlayerZone).maxX = 1200;
					(zonesArray[4] as PlayerZone).minY = 100;
					(zonesArray[4] as PlayerZone).maxY = 350;
					
					(zonesArray[5] as PlayerZone).minX = 750;
					(zonesArray[5] as PlayerZone).maxX = 1200;
					(zonesArray[5] as PlayerZone).minY = 350;
					(zonesArray[5] as PlayerZone).maxY = 650;
					
					(zonesArray[6] as PlayerZone).minX = 750;
					(zonesArray[6] as PlayerZone).maxX = 1200;
					(zonesArray[6] as PlayerZone).minY = 650;
					(zonesArray[6] as PlayerZone).maxY = 900;
					
					break;
				case ( 10):
//					this.zoneXSize = ( 900 / 3 );
//					this.zoneYSize = int ( ( 800 / 3) );
					
					for ( var q:uint=0; q < 10; q++)
					{
						zonesArray[q] = new PlayerZone();
					}
					(zonesArray[1] as PlayerZone).minX = 300;
					(zonesArray[1] as PlayerZone).maxX = 600;
					(zonesArray[1] as PlayerZone).minY = 100;
					(zonesArray[1] as PlayerZone).maxY = 350;
					
					(zonesArray[2] as PlayerZone).minX = 300;
					(zonesArray[2] as PlayerZone).maxX = 600;
					(zonesArray[2] as PlayerZone).minY = 350;
					(zonesArray[2] as PlayerZone).maxY = 650;
					
					(zonesArray[3] as PlayerZone).minX = 300;
					(zonesArray[3] as PlayerZone).maxX = 600;
					(zonesArray[3] as PlayerZone).minY = 650;
					(zonesArray[3] as PlayerZone).maxY = 900;
					
					(zonesArray[4] as PlayerZone).minX = 600;
					(zonesArray[4] as PlayerZone).maxX = 900;
					(zonesArray[4] as PlayerZone).minY = 100;
					(zonesArray[4] as PlayerZone).maxY = 350;
					
					(zonesArray[5] as PlayerZone).minX = 600;
					(zonesArray[5] as PlayerZone).maxX = 900;
					(zonesArray[5] as PlayerZone).minY = 350;
					(zonesArray[5] as PlayerZone).maxY = 650;
					
					(zonesArray[6] as PlayerZone).minX = 600;
					(zonesArray[6] as PlayerZone).maxX = 900;
					(zonesArray[6] as PlayerZone).minY = 650;
					(zonesArray[6] as PlayerZone).maxY = 900;
					
					(zonesArray[7] as PlayerZone).minX = 900;
					(zonesArray[7] as PlayerZone).maxX = 1200;
					(zonesArray[7] as PlayerZone).minY = 100;
					(zonesArray[7] as PlayerZone).maxY = 350;
					
					(zonesArray[8] as PlayerZone).minX = 900;
					(zonesArray[8] as PlayerZone).maxX = 1200;
					(zonesArray[8] as PlayerZone).minY = 350;
					(zonesArray[8] as PlayerZone).maxY = 650;
					
					(zonesArray[9] as PlayerZone).minX = 900;
					(zonesArray[9] as PlayerZone).maxX = 1200;
					(zonesArray[9] as PlayerZone).minY = 650;
					(zonesArray[9] as PlayerZone).maxY = 900;					
					
					break;		 
				
			}
			for ( var i:uint=0; i < GameSettingsData.getInstance().numberOfPlayers; i++)
			{
				(this.zonesArray[i] as PlayerZone).zoneNum = i;
			}
		
		}	
		
		private function assignAllRedPlayersTheirZones(playersArray:Array):Array{
			
			var i :uint;
			for ( i=0;i<playersArray.length; i++)
			{
				playersArray[i].data.zone = this.zonesArray[i];
			}
			for ( i=0;i<playersArray.length; i++)
			{
				if ( playersArray[i].data.hasBall )
				{
					var z:uint = checkZonePlayerWithBallIsIn( playersArray[i].data ); // returns zone number 
					// whichever zone pwb is in zone - that zone's player must switch places and go to pwb's zone
					if ( z!= 0 )
						playersArray[z].data.zone = (this.zonesArray[i] as PlayerZone); 
				}
			}
			
			return playersArray;		
			
		}
		
		private function assignAllBluePlayersTheirZones(playersArray:Array):Array{
			
			var i :uint;
			var zn:uint = this.zonesArray.length;  // zl = zones number
			
			playersArray[0].data.zone = this.zonesArray[0];
			
			for ( i=1;i<playersArray.length; i++)
			{
				playersArray[i].data.zone = this.zonesArray[zn-i];
			}
			for ( i=0;i<playersArray.length; i++)
			{
				if ( playersArray[i].data.hasBall )
				{
					var z:uint = checkZonePlayerWithBallIsIn( playersArray[i].data ); // returns zone number 
					// whichever zone pwb is in zone - that zone's player must switch places and go to pwb's zone
					if ( z!= 0 )
						playersArray[z].data.zone = (this.zonesArray[i] as PlayerZone); 
				}
			}
			
			return playersArray;
		}	
		
		
		
		
		
		
	}
}