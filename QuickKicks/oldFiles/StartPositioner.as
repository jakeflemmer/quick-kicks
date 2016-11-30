package classes
{
	import classes.*;
	
	public class StartPositioner 
	{
		public var i:uint;  // for loop counting
		
		private var redXArray:Array = new Array();	
		private var blueXArray:Array = new Array();
		private var redYArray:Array = new Array();
		private var blueYArray:Array = new Array();
	
		
		public function StartPositioner()
		{
			// This class is here as the name suggest to set each player's start position
			defineArrays();
			
			
		}
		
		//-------------------------------------------------------------------------------------------------------
		//   PUBLIC METHODS
		//-------------------------------------------------------------------------------------------------------
		
		public function setStartPositions(pda:Array):Array{
			// takes an array of players data and sets their start positions based on their assigned zone
			// it also sets their destinations to their start positions 
			
			if ( (pda[i] as PlayerData).teamId == "red")
			{
				return setRedTeamsStartPositions(pda);
			}
			else
			{
				return setBlueTeamsStartPositions(pda);
			}		
			
		}
		
		private function average( theMin:Number, theMax:Number ):Number{
			
			return ( theMin + theMax ) / 2;
		}
		
		//-------------------------------------------------------------------------------------------------------
		//   PRIVATE METHODS
		//-------------------------------------------------------------------------------------------------------
		
		
		private function defineArrays():void{
			
			redXArray.push(0);blueXArray.push(0);
			redYArray.push(0);blueYArray.push(0);
			
			switch ( GameSettingsData.getInstance().numberOfPlayers )
			{
				case ( 5 ):
				
					redXArray.push(350,350);
					redXArray.push(650,650);					
					blueXArray.push(1150,1150);
					blueXArray.push(850,850);					
					
					redYArray.push(350,650);
					redYArray.push(350,650);					
					blueYArray.push(650,350);
					blueYArray.push(650,350);				
					
					break;
					
				case ( 7 ):
				
					redXArray.push(350,350,350);
					redXArray.push(650,650,650);					
					blueXArray.push(1150,1150,1150);
					blueXArray.push(850,850,850);					
					
					redYArray.push(250,500,750);
					redYArray.push(250,500,750);						
					blueYArray.push(750,500,250);
					blueYArray.push(750,500,250);
					
					break;
					
				case ( 10 ):
				
					redXArray.push(300,300,300);
					redXArray.push(500,500,500);
					redXArray.push(700,700,700);					
					blueXArray.push(1200,1200,1200);
					blueXArray.push(1000,1000,1000);
					blueXArray.push(800,800,800);
					
					redYArray.push(250,500,750);
					redYArray.push(250,500,750);
					redYArray.push(250,500,750);					
					blueYArray.push(750,500,250);
					blueYArray.push(750,500,250);
					blueYArray.push(750,500,250);
					
					break;					
			}
			
		}
		private function setRedTeamsStartPositions(pda:Array):Array{
			
			// the y array can only ever be as big as or bigger than the x arrays
			// the keeper x,y is extraneous
			pda[0].xPos = 50 + GameSettingsData.getInstance().playerRadius*2;
			pda[0].yPos = 500;
			
			var i :uint;
			for ( i=1; i < pda.length; i++)
			{
				var x:Number = redXArray[i];
				var y :Number = redYArray[i];
				(pda[i] as PlayerData).xPos = redXArray[i];
				(pda[i] as PlayerData).yPos = redYArray[i];	
				
				(pda[i] as PlayerData).destinationX = redXArray[i];
				(pda[i] as PlayerData).destinationY = redYArray[i];
								
			}
			return pda;	
		}
		
		private function setBlueTeamsStartPositions(pda:Array):Array{
			
			// the y array can only ever be as big as or bigger than the x arrays
			// the keeper x,y is extraneous
			pda[0].xPos = 1450 - GameSettingsData.getInstance().playerRadius * 2;
			pda[0].yPos = 500;
			
			var i :uint;			
			for ( i=1; i < pda.length; i++)
			{
				(pda[i] as PlayerData).xPos = blueXArray[i];
				(pda[i] as PlayerData).yPos = blueYArray[i] - 5;  // minus 5 to offset the players so they don't bash into each other idiotically
				
				(pda[i] as PlayerData).destinationX = blueXArray[i];
				(pda[i] as PlayerData).destinationY = blueYArray[i] -5;					
			}
			
			return pda;	
		}
		
		
		
		//-------------------------------------------------------------------------------------------------------
		//   OLD CODE
		//-------------------------------------------------------------------------------------------------------
		
//		protected function setPlayersStartPositions(red:Boolean):void{			
//			
//			//TODO hack here but cputeamcontroller should have setTeamSpecificData function and set its playerdata indo here
//			if ( ! this.playersArray) return;
//			var data:PlayerData = this.playersArray[0] as PlayerData;
//			
//			
//			data.xPos = red ? 150:1350;    // keeper
//			data.yPos = 500;		//keeper
//			
//			var i :uint;		
//			var baseMargin:int = 200;
//			
//			for ( i=1;i<GameSettingsData.getInstance().numberOfPlayers;i++)
//			{			
//				var theX:uint = calcStartPositionX(i,red);
//				var theY:uint = calcStartDestinationY(i);  // destination and position are same on Y axis			
//				(this.playersArray[i] as PlayerData).xPos = theX;
//				(this.playersArray[i] as PlayerData).yPos = theY;
//			}					
//		}
//		private function calcStartDestinationY(i:uint):uint{
//			var theY:uint;
//			if ( i > 3)
//			{
//				i -= 3;
//			}
//			switch (i)
//			{
//				case 1:
//					theY = 250;
//					break;					
//				case 2:
//					theY = 500;
//					break;
//				case 3:
//					theY = 750;
//					break;
//			}			
//			return theY;
//		}
//		private function calcStartDestinationX(i:uint,blue:Boolean):uint{
//			var theX:uint;
//			switch (i)
//			{
//				case i<4:
//					theX = (!blue ? 250:1250);
//					break;
//				case i<7:
//					theX = (!blue ? 450:1050);
//					break;
//				case i<10:
//					theX = (!blue ? 650:850);
//					break;
//			}
//			return theX;
//		}
//		private function calcStartPositionX(i:uint,blue:Boolean):uint{
//			var theX:uint;
//			var zone:String = "first";
//			if (i<4)
//			{
//				zone = "first";
//			}else if ( i < 7 )
//			{
//				zone = "second";
//			}else
//			{
//				zone = "third";
//			}			
//			
//				switch (zone)
//				{
//					case "first":
//						theX = (!blue ? 250:1250);
//						break;
//					case "second":
//						theX = (!blue ? 450:1050);
//						break;
//					case "third":
//						theX = (!blue ? 650:850);
//						break;
//				}
//				return theX;
//				}
	} // close class
}	// close package