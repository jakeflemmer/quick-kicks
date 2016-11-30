package classes
{
	import classes.*;
	
	public class DestinationManager
	{
		public var i :uint ;  // as looping counter
		
		public function DestinationManager()
		{
			// This class is here to manage all destinations
			// It must reset destinations ( at the start of the game or after a goal, etc...)
			// It must give new destinations to players to help them get space from the players marking them
		}
		
		//--------------------------------------------------------------------------------------------------
		// PUBLIC MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		public function resetDestinations(playersArray:Array):Array{
			
			// Since each player has already been assigned a zone we can just make each player's destination
			// the center of it's zone
			// ( which we caluculate by adding the min and the max and dividing by 2 !!)
			for ( i=0; i < playersArray.length; i++)
			{
				(playersArray[i].data as PlayerData).destinationX = 
					( (playersArray[i].data as PlayerData).zone.minX + (playersArray[i].data as PlayerData).zone.maxX  ) / 2;
					
				(playersArray[i].data as PlayerData).destinationY = 
					( (playersArray[i].data as PlayerData).zone.minY + (playersArray[i].data as PlayerData).zone.maxY  ) / 2;
					
					(playersArray[i].data as PlayerData).destinationManagerHasAssignedDestination = true;
			}			
			
			return playersArray;
		}
		public function giveAllPlayersGetFreeDestinations(playersArray:Array):Array{
			
			// Basically this function gives players random motion so that they create space between
			// themselves and the players marking them which creates opportunities for passing
			
			// Each player data has a "zone" that the player moves around in
			// Their next get free destination is a random position in this zone
			
			// First we need to check that they have arrived at their previous destination before assigning them a new one
			// But only if they had a previous destination in the first place !
			for ( i=1; i < playersArray.length; i++)
			{
				if ( (playersArray[i] as AbstractPlayerController).data.hasBall )
				{
					continue;
				}
				if ( (playersArray[i] as AbstractPlayerController).data.destinationManagerHasAssignedDestination )
				{
					var xDist:Number = ( (playersArray[i].data as PlayerData).xPos - (playersArray[i].data as PlayerData).destinationX );
					var yDist:Number = ( (playersArray[i].data as PlayerData).yPos - (playersArray[i].data as PlayerData).destinationY );
					var totalDist:Number = Math.sqrt( (xDist*xDist) + (yDist*yDist) );
				
					if ( totalDist < 7 || isNaN(totalDist)) // HARD CODING HERE !!
					{				
						playersArray[i] = givePlayerNewGetFreeDestination( playersArray[i] );	// close enuff - give em a new destination
					}
				}
				else
				{	
					playersArray[i] = givePlayerNewGetFreeDestination( playersArray[i] );	// give initial destination
				}
			}			
			
			return playersArray;
		}
		
		//--------------------------------------------------------------------------------------------------
		// PRIVATE METHODS
		//--------------------------------------------------------------------------------------------------
		
		private function givePlayerNewGetFreeDestination(plyr:AbstractPlayerController):AbstractPlayerController{
			
			// we want to reduce the scope of travel within zone by half
			
			var midX:Number = Calculator.instance.returnAverage(plyr.data.zone.minX, plyr.data.zone.maxX);
			var midY:Number = Calculator.instance.returnAverage(plyr.data.zone.minY, plyr.data.zone.maxY);
			
			var quarterX:Number = Calculator.instance.returnAverage(midX, plyr.data.zone.minX);
			var quarterY:Number = Calculator.instance.returnAverage(midY, plyr.data.zone.minY);
						
			var rndX:Number = ( Math.random()* ( plyr.data.zone.maxX - plyr.data.zone.minX )) ;
			var rndY:Number = ( Math.random()* ( plyr.data.zone.maxY - plyr.data.zone.minY )) ;
			
			//plyr.data.destinationX = plyr.data.zone.minX + rndX;
			//plyr.data.destinationY = plyr.data.zone.minY + rndY;
			
			//plyr.data.destinationX = midX;
			//plyr.data.destinationY = midY;
			
			plyr.data.destinationX = quarterX + (rndX/2);
			plyr.data.destinationY = quarterY + (rndY/2);	
			
			plyr.data.destinationManagerHasAssignedDestination = true;	
						
			return plyr;
		}

	}
}