package classes
{
	public class MarkingManager
	{
		private static var instance:MarkingManager;
		
		public function MarkingManager()
		{
			// this class is here to manage each players other player that they are marking
			// so if they are marking a player and their marked player is going for the ball
			// but another teammate is closer to the ball so they start going for it
			// then the teammates need to switch marked men
			
			if ( instance != null)
			{
				throw new Error("singleton error");
			}
		}
		public static function getInstance():MarkingManager{
			if ( instance == null)
			{
				instance = new MarkingManager();
			}
			return instance;
		}
		
		//=========================================================================================
		// PUBLIC METHODS
		//=========================================================================================
		
		public function setDefaultPlayersToMark(rpda:Array, bpda:Array):Array{
			
			// assign each player their opposite number as their defaultPlayerToMark
			var i:uint;
			var numP:uint = GameSettingsData.getInstance().numberOfPlayers;
			for ( i=1;i<numP;i++)
			{
				(bpda[i] as PlayerData).defaultPlayerToMark = (rpda[numP-i] as PlayerData);
				(rpda[i] as PlayerData).defaultPlayerToMark = (bpda[numP-i] as PlayerData);				
			}	
			for ( i=1;i<numP;i++)
			{				
				(bpda[i] as PlayerData).playerMarking = (bpda[i] as PlayerData).defaultPlayerToMark;
				(rpda[i] as PlayerData).playerMarking = (rpda[i] as PlayerData).defaultPlayerToMark;
			}	
			
			return cpda(rpda,bpda);
			
		}
		
		public function assignMarkedMen(pda:Array):Array{
			
			var i:uint;
			for (i=1; i < pda.length; i++)
			{
				// red first
				if ( pgbd(pda))        // if nobody is getting the ball then shouldn't be marking anyways 
				{	
					
					pda = resetDefaultMarking(pda);
					
									
					if ( !(pgbd(pda) as PlayerData).isKeeper )   // if the keeper is getting the ball then go back to default marking
					{ 
						
						var plyrData:PlayerData = (pda[i] as PlayerData);
						var plyrGettingBallData:PlayerData = pgbd(pda);
						
						if ( plyrData.playerMarking )   
						{
							if ( plyrData.playerMarking.gettingBall )
							{
								// the guy he's marking is getting the ball	
								if ( plyrData.id != plyrGettingBallData.id )// and he himself is not getting the ball
								{
									// we know that another teammate is getting the ball so this player needs to mark this other instead
									var debug1:String = plyrData.id;
									var debug2:String = plyrData.playerMarking.id;
									var debug3:String = ( pgbd(pda) as PlayerData).defaultPlayerToMark.id;
									plyrData.playerMarking = ( pgbd(pda) as PlayerData).defaultPlayerToMark;
								
								}else{
									// otherwise just mark the default player
									plyrData.playerMarking = plyrData.defaultPlayerToMark;
								}
							}else{
									// otherwise just mark the default player
									plyrData.playerMarking = plyrData.defaultPlayerToMark;
							}
							
						} else throw new Error("player not marking anybody ??");
					}
					
				}else{
					throw new Error("no player is getting ball so nobody should be marking");
				}
				traceDebugInfo(pda);
			}	
			
			testThatNoTwoPlayersAreMarkingTheSameMan(pda);
			testThatIfPlayerNotGettingBallPlayerMarkingIsNotNull(pda); // since we throw an error if player marking is null this test is useless
						
			return pda; 	
			
		}

		
		public function resetDefaultMarking(c:Array):Array{
			
			var i :uint;
			
			for ( i=0; i < c.length; i++)
			{
				(c[i] as PlayerData).playerMarking = (c[i] as PlayerData).defaultPlayerToMark;
			}
			return c;
		}
		
		
		
		//=========================================================================================
		// PRIVATE METHODS
		//=========================================================================================
		
		private function pgbd(pda:Array):PlayerData{	//player getting ball data
			var i :uint;
			for ( i=0; i < pda.length; i++)
			{
				if ( (pda[i] as PlayerData).gettingBall ) return (pda[i] as PlayerData);
			}
			//throw new Error("no player getting ball");
			return null;
		}
		
		private function cpda(rpda:Array, bpda:Array):Array{
			var cpda:Array = new Array();
			var i :uint;
			for ( i=0;i<rpda.length;i++)
			{
				cpda.push(rpda[i]);
			}
			for ( i=0; i <bpda.length; i++)
			{
				cpda.push(bpda[i]);
			}
			return cpda;
		}
		
		private function testThatNoTwoPlayersAreMarkingTheSameMan(pda:Array):void{
			var i:uint; var j:uint;
			
			if ( pgbd(pda) == null) return;
			
			for ( i=1;i<pda.length;i++)
			{
				for ( j=1; j <pda.length; j++)
				{
					if ( i != j )
					{
						if ( (pda[i] as PlayerData).playerMarking && (pda[j] as PlayerData).playerMarking )
						{
							if ( (pda[i] as PlayerData).playerMarking.id == (pda[j] as PlayerData).playerMarking.id )
							{
								if ( ! (pda[i] as PlayerData).gettingBall && ! (pda[j] as PlayerData).gettingBall )
								{
									throw new Error("two players marking same man");
								}
							}
						}
					}
				}	
			}
		}
		
		private function testThatIfPlayerNotGettingBallPlayerMarkingIsNotNull(pda:Array):void{
			
			var i:uint;
			for ( i=1;i<pda.length;i++)
			{
				if ( ! pda[i].gettingBall )
				{
					if ( pda[i].playerMarking == null)
					{
						throw new Error("player not getting ball is not marking anybody");
					}
				}
			}		
			
		}
		
		private function traceDebugInfo(rpda:Array):void{
			
			var s:String = "";
			
			for ( var i:uint = 1 ; i <rpda.length; i++ )
			{
				s += rpda[i].gettingBall.toString() + "  " + rpda[i].teamId.toString() + rpda[i].id.toString() + " marking " + rpda[i].playerMarking.teamId.toString() + rpda[i].playerMarking.id.toString()  +"\n";	
			}
			trace("playerMarking info" + "\n" + s);
		}
		
		//=========================================================================================
		// PUBLIC METHODS
		//=========================================================================================
		
		
		
		//=========================================================================================
		// EVENT HANDLERS
		//=========================================================================================
		
		
		//=========================================================================================
		// GETTERS and SETTERS
		//=========================================================================================
		
		
	}
}