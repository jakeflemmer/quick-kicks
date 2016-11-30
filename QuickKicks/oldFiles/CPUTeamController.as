package classes
{ 
	import classes.*;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.events.FlexEvent;
	
	public class CPUTeamController extends AbstractTeamController 
	{
		
		public function CPUTeamController()		
		{
						
			super();
			
			initializeTeam(false);

			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);
			
		}	
		
		//------------------------------------------------------------------------------------------------
		// PUBLIC FUNCTIONS 
		//------------------------------------------------------------------------------------------------
		
		public function resetEverything():void{
			
			resetAfterNewStart();
		}
		public function reset():void
		{
			//resetDestinations();
			_data.pressureToPass = false;	
		//	initializePlayerPositions();						
			noPlayersGettingBall();			
			resetAllPlayerProperties();			
			resetZones();
		}
		public function goalReset():void
		{
			resetAfterNewStart();
		}

//		
		public function ballNowFree():void
		{
			resetZones();
			var i:int;
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.scoreBall = false;
			}
		}						
		private function resetZones():void
		{
		// assign team mates reverse zones to human team
//			var j:uint = 5;
//			for (var i:uint=1; i<5; i ++)	// set basic default zones
//			{
//				j--;
//				playersArray[i].data.zone = j;			
//			//	giveNewGetFreeDestination(i);
//			}		
		}
	//--------------------------------------------------------------------------------------------------
	//  ON ENTER FRAME
	//--------------------------------------------------------------------------------------------------

	override protected function ON_ENTER_FRAME(e:Event=null):void
	{
		if (gsd.paused || gsd.goalAnimation) return;		
		
		if ( sbd.redPossession ) _data.state = "defending";
		if ( sbd.bluePossession ) _data.state = "attacking";
					
		if (! gsd.twoPlayerMode)
		{
		// 	CPU MODE   ========================================	
			
			super.ON_ENTER_FRAME();
			return;
			
					
		keeperTracking();				

		determineWhoHasBallOrWhoIsGettingBall();		
		
		if ( pwbd != null ){
			
			calculatePassOrShootAngle(); // cpuTeamAutoPass();	// sets _data.playerWithBall.autoPassAngle				
			
			if ( pwbd.scoreBall ){
					if ( Calculator.instance.openGoal(pwbd, _data.scorePost) ) // openPass()  needs to be openGoal() function
					{	
						var spy:Number = _data.scorePost.scorePostY;  // for debug
						takeTheShot();
						return;
					}
				}				
				
			if ( ! pwbd.isKeeper ) 
			{			
				var space:Number = pwbd.space;
				
				var three:Number = gsd.playerRadius * 5;
				var two:Number = gsd.playerRadius * 2;
				var one:Number = gsd.playerRadius;
				
				if ( space >= three )
				{
					tryToBeatDefender();
					_data.pressureToPass = false;
					
				}
//				else if ( space >= two )
//				{
//					lookForBestPass();					
//					
//				}
				else //if ( space < two )
				{
					protectBall();
					_data.pressureToPass = true;										
				}
				
			} else {
				_data.pressureToPass = true;
			}
			
				if ( _data.pressureToPass )
				{		
					if ( Calculator.instance.openPass(pwbd,_data.closestTeamMate) )
					{
								precisionPass();
								pwbd.passNow = true;
					}			
				}	
								
		}
		
		if ( ctmd.passReceiver )
		{
			// determine who is closer - ctmd or ctmdefd
			if (c.defenderCloserToBallThanReceiver(ctmd))
			{
				ctmd.gettingBall =true;
			}else{
				//plan first touch
				//either move to a point
			}
			
		}
		
	//	doTeamStrategy();
		
	//	doBallCarrierStrategy();
		
		
	}else
	//  TWO PLAYER MODE    =======================================
	{
		//	determineWhoHasBallAndWhoIsControlled();			
						
	//		doTeamStrategy();
		
			keeperTracking();
			//TODO
		//	autoPassIndicator();
	}
	}
	
	
	
//  __________________________________________________________________________________________________________________________________________
//   ____________________________________________________________________________________________________________________________________________

	private function lookForBestPass():void
	{
		// use the Calculator to get the team mate who is in the most space
		// make their position the player with ball data's destination
		// when the bestPassOption == _data,passReceiver
		// pressure to pass == true;
	}
	
	
//	protected function determineWhoHasBallAndWhoIsControlleddddd():void
//	{		
//		var i:int; var j:int; var k:int;
//		
//		pwbd = null;
//		if ( playersArray[0].data.hasBall ) pwbd = playersArray[0].data;
//		if ( playersArray[1].data.hasBall ) pwbd = playersArray[1].data;
//		if ( playersArray[2].data.hasBall ) pwbd = playersArray[2].data;
//		if ( playersArray[3].data.hasBall ) pwbd = playersArray[3].data;
//		if ( playersArray[4].data.hasBall ) pwbd = playersArray[4].data;
//		
//		if ( pwbd != null )
//		{
//			for ( i = 0 ; i < playersArray.length ; i ++ )
//			{
//				playersArray[i].data.isControlled = false;		
//			}		
//			pwbd.isControlled = true;			
//			return;
//		}
//		
//		/*if ( _data.justPassed )
//		{
//			for ( j = 0; j < 5; j++)
//			{
//				playersArray[j].data.gettingBall = false;
//			}
//			_data.closestTeamMate.gettingBall = true;
//			return;
//		}*/	
//						
//		var bX:Number = sbd.xPos;
//		var bY:Number = sbd.yPos;
//		var xDistance:Number = 0;
//		var yDistance:Number = 0;
//		var totalDistance:Number = 0;
//		var smallestNumber:Number = 10000;
//		var lastPlayerControlled:uint;
//					
//		for ( i = 0 ; i < playersArray.length ; i ++ )
//			{
//				if ( playersArray[i].data.isControlled ) lastPlayerControlled = i;
//				playersArray[i].data.isControlled = false;		
//			}		
//		for ( i = 0; i < playersArray.length; i++)
//		{	
//			if ( ! playersArray[i].data.justBeaten )
//			{
//				xDistance = Math.abs ( playersArray[i].data.xPos - bX );
//				yDistance = Math.abs ( playersArray[i].data.yPos - bY );
//				totalDistance = xDistance + yDistance;
//				// bias the distance here
//				// increase it for the keeper
//				if ( playersArray[i].data.isKeeper ) totalDistance += 200;
//				// decrease it for the player last in control
//				if ( i == lastPlayerControlled ) totalDistance -= gsd.playerRemainControlledBias;
//				
//				if ( totalDistance < smallestNumber ) 
//				{
//					smallestNumber = totalDistance;
//					for ( k = 0; k < i; k++)
//					{
//						playersArray[k].data.isControlled = false;
//					}
//					playersArray[i].data.isControlled = true;
//				}
//			}			
//		}
//	}
	
//	private function autoPassIndicator():void
//	{
//		// we need to find which is the team mate with the closest angle
//		// a) the closest angle
//		// b) which team mate it is
//		// c) make that team mate the closestTeamMate		
//		// d) add the goal as a target
//		
//				
//		if ( sbd.isFree ) {
//			passLine.clear();
//			return;
//		}
//		if ( frameCount > oldFrameCount + 200)
//		{
//			oldFrameCount = frameCount;
//		}else{
//			return;
//		}
//		
//		if ( pwbd == null )return;	
//		
//		var tm1a:Number;
//		var tm2a:Number;
//		var tm3a:Number;
//		var tm4a:Number;
//		
//		var tm1X:Number; var tm1Y:Number;
//		var tm2X:Number; var tm2Y:Number;
//		var tm3X:Number; var tm3Y:Number;
//		var tm4X:Number; var tm4Y:Number;
//		var pwbX:Number = pwbd.xPos;
//		var pwbY:Number = pwbd.yPos;
//		var pwbD:Number = pwbd.dribble;
//		//trace("pwb x : " + pwbX);
//		if (pwbd == keeper.data ){			
//			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//		}
//		if (pwbd == player1.data ){			
//			tm1X = keeper.data.xPos; tm1Y = keeper.data.yPos;
//			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//		}
//		if (pwbd == player2.data ){			
//			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//			tm2X = keeper.data.xPos; tm2Y = keeper.data.yPos;
//			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//		}
//		if (pwbd == player3.data ){			
//			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//			tm3X = keeper.data.xPos; tm3Y = keeper.data.yPos;
//			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//		}
//		if (pwbd == player4.data ){			
//			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//			tm4X = keeper.data.xPos; tm4Y = keeper.data.yPos;
//		}		
//			tm1a = radCalc.calc(tm1X - pwbX, tm1Y - pwbY);
//			tm2a = radCalc.calc(tm2X - pwbX, tm2Y - pwbY); 
//			tm3a = radCalc.calc(tm3X - pwbX, tm3Y - pwbY);
//			tm4a = radCalc.calc(tm4X - pwbX, tm4Y - pwbY);
//	
//		var teamMateAngles:Array = [Math.abs(pwbD - tm1a),Math.abs(pwbD - tm2a), Math.abs(pwbD - tm3a), Math.abs(pwbD - tm4a)];
//		var closestTeamMateAngle:Array = [];
//		var closestTeamMateNo:uint =0; 		
//		var smallestNumber : Number = 1000; var biggestNumber : Number = 0;
//		var i:uint = 0;		
//		
//		// loop to find the smallest angle and biggest angle and call it smallestNumber and biggestNumber
//		for (i = 0; i < teamMateAngles.length; i++)	{
//			if ( teamMateAngles[i] <= smallestNumber ) smallestNumber = teamMateAngles[i];
//			if ( teamMateAngles[i] >= biggestNumber ) biggestNumber = teamMateAngles[i]; 		
//		}
//		//choose which is closer - the smallest number or the biggest
//		if ( smallestNumber <= ( (2 * Math.PI) - biggestNumber ) )
//		{
//			// loop to push the smallest angle into the closestTeamMateAngleArray and name the closestTeamMateNo
//			for (i=0; i < teamMateAngles.length; i++) {
//				if ( smallestNumber == teamMateAngles[i] ) {
//					closestTeamMateAngle.push( teamMateAngles[i]);
//					closestTeamMateNo = i;			
//				}
//			}
//		} else {
//			// loop to push the biggest angle into the closestTeamMateAngleArray and name the closestTeamMateNo
//			for (i=0; i < teamMateAngles.length; i++) {
//				if ( biggestNumber == teamMateAngles[i] ) {
//					closestTeamMateAngle.push( teamMateAngles[i]);
//					closestTeamMateNo = i;			
//				}
//			}
//		}
//		
//		if ( closestTeamMateAngle.length > 1 ) trace ("oops"); // choose closest player		
//			
//		switch (pwbd) {
//			case keeper.data:			
//				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
//				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
//				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
//				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
//				break;
//			case player1.data:
//				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = keeper.data;
//				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
//				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
//				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
//				break;
//			case player2.data:
//				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
//				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = keeper.data;
//				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
//				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
//				break;
//			case player3.data:
//				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
//				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
//				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = keeper.data;
//				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
//				break;
//			case player4.data:
//				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
//				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
//				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
//				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = keeper.data;
//				break;
//		}		
//		// now compare the closest team mate angle with the goal angle ( except for keeper and players too far away)
//		if ( ! pwbd.isKeeper && pwbd.xPos > 600)  // keeper can't score nor can players too far away
//		{
////  _______________________________________________   sharp shooter   _________________________________________________________
//
//		var leftGoalAngle:Number; var rightGoalAngle:Number;
//		var leftGoalY:uint = 350; var rightGoalY:uint = 650;
//		var goalX:uint = 1450; 
//		
//		leftGoalAngle = radCalc.calc( goalX - pwbd.xPos , leftGoalY - pwbd.yPos );		
//		rightGoalAngle =  radCalc.calc( goalX - pwbd.xPos , rightGoalY - pwbd.yPos );
//				
//		// leftGoal
//		if ( Math.abs(pwbD - leftGoalAngle) < smallestNumber )   // score ball ! 
//		{ 	
//			smallestNumber = Math.abs( pwbD - leftGoalAngle );
//			// draw line
//			passLine.draw( pwbX, pwbY, goalX, leftGoalY );//draw line
//		
//			_data.autoPassAngle = radCalc.calc( goalX - pwbX, leftGoalY - pwbY ); // calc shoot angle
//				
//			pwbd.autoPassAngle = _data.autoPassAngle;	
//			pwbd.scoreBall = true;
//			noPassReceiver();		
//			return;
//		}
//		// right goal
//		if ( Math.abs(pwbD - rightGoalAngle) < smallestNumber )   // score ball ! 
//		{ 	
//			// draw line
//			passLine.clear();
//			passLine.draw( pwbX, pwbY, goalX, rightGoalY );//draw line
//		
//			_data.autoPassAngle = radCalc.calc( goalX - pwbX, rightGoalY - pwbY ); // calc shoot angle
//				
//			pwbd.autoPassAngle = _data.autoPassAngle;
//			pwbd.scoreBall = true;
//			noPassReceiver();			
//			return;
//		}
//		pwbd.scoreBall = false;
//		
//		}	// ___________ end sharp shooter __________
//		
//		// draw the line here					
//		passLine.draw( pwbX, pwbY, _data.closestTeamMate.xPos, _data.closestTeamMate.yPos );//draw line
//		
//		_data.autoPassAngle = radCalc.calc( _data.closestTeamMate.xPos - pwbX, _data.closestTeamMate.yPos - pwbY ); // calc pass angle
//	 
//		pwbd.autoPassAngle = _data.autoPassAngle;	
//		
//		//make closest team mate receiver, give em filter, make em wait
//		
//		noPassReceiver();		
//		
//		//throughPass();
//							
//	}
//	private function noPassReceiver():void
//	{
//		var i :uint = 0;
//		for ( i=0; i <5;i++)
//		{
//			playersArray[i].data.passReceiver = false;
//		}
//	}
	private function precisionPass():void
	{
		if (pwbd.scoreBall ) return;
		
		var theX:Number = ( _data.closestTeamMate.xPos - sbd.xPos );
		var theY:Number = ( _data.closestTeamMate.yPos - sbd.yPos );
		var precisionPassAngle:Number = RadiansCalculator.calc(theX, theY); 		
		_data.autoPassAngle = precisionPassAngle;
		pwbd.autoPassAngle = precisionPassAngle;		
	}
			
	
	
//	private function doTeamStrategy():void
//	{
//		if (_data.state == null) return;
//		if ( pwbd == null ) return;				
//		if (_data.state != "attacking" ) return;
		
		
		
		// if zone Player with ball is in has changed then set new zones for teamMates
		// and give all players new get free zones
//		_data.oldZone = pwbd.zone;
//		checkZonePlayerWithBallIsIn();
//		var newZone:uint = pwbd.zone;
//		if ( newZone != _data.oldZone ) 
//		{			
//			setNewTeamMateZones();
//			giveAllNewGetFreeDestinations();
//			return;			
//		}		
//	
//		//see if players have reached their last get free zone and if they have then give em new ones
//		var closeEnough:uint = 10;
//		for ( var i:int = 0;i < 5; i++)
//		{
//			if ( calculatedDistanceFromGetFreeZone(i) < 2 )
//			{
//				//trace ("humTeamCont doStrategy() closeEnough");
//				giveNewGetFreeDestination(i);
//			}
//		}	
//	}
	
	private function setNewTeamMateZones():void
	{			
//			switch (pwbd )  // then change based on ball carriers zone
//			{
//				case keeper.data:
//					break;
//				case player1.data:     // player 1 has the ball 
//					switch (pwbd.zone)
//					{
//						case 1:				// in zone 1
//							player3.data.zone = 0; // superAttack!
//							break;
//						case 2:				// in zone 2
//							player4.data.zone = 0; // superAttack!
//							break;
//						case 3:
//							player2.data.zone = 4; 
//							break;
//						case 4:							 
//							// all stays the same - is as it should be
//							break;
//					}
//					break;
//				case player2.data:    // player 2 has ball				
//					switch (pwbd.zone)
//					{
//						case 1:				// in zone 1
//							player4.data.zone = 0; // superAttack!				
//							break;
//						case 2:				// in zone 2							
//							player3.data.zone = 0; // superAttack!
//							break;
//						case 3:
//							// all stays the same - is as it should be
//							break;
//						case 4:
//							player1.data.zone = 3;  
//							break;
//					}
//					break;		
//				case player3.data:
//					switch (pwbd.zone)
//					{
//						case 1:				// in zone 1
//							player4.data.zone = 2;
//							break;
//						case 2:				// in zone 2							
//							// all stays the same;	
//							break;
//						case 3:							
//							player2.data.zone = 2;						
//							break;
//						case 4:
//							player1.data.zone = 2;  
//							break;
//					}
//					break;
//				case player4.data:
//					switch (pwbd.zone)
//					{
//						case 1:				// in zone 1
//							// all stays the same;							
//							break;
//						case 2:				// in zone 2							
//							player3.data.zone = 1;
//							break;
//						case 3:				// in zone 3
//							player2.data.zone = 1;					
//							break;
//						case 4:
//							player1.data.zone = 1;						  
//							break;
//					}
//					break;
//				}				
	
	}	
	
	protected function determineWhoHasBallOrWhoIsGettingBall():void
	{	
		var i:int; var j:int; var k:int;
			
		pwbd = null;
		if ( playersArray[0].data.hasBall ) pwbd = playersArray[0].data;
		if ( playersArray[1].data.hasBall ) pwbd = playersArray[1].data;
		if ( playersArray[2].data.hasBall ) pwbd = playersArray[2].data;
		if ( playersArray[3].data.hasBall ) pwbd = playersArray[3].data;
		if ( playersArray[4].data.hasBall ) pwbd = playersArray[4].data;
		
		if ( pwbd )
		{				
			noPlayersGettingBall();
			
			if (pwbd == keeper.data ) _data.pressureToPass = true;				
			return;
		}	
		
		/*
		if ( _data.justPassed )
		{
			for ( j = 0; j < 5; j++)
			{
				playersArray[j].data.gettingBall = false;
			}
			_data.closestTeamMate.gettingBall = true;
			return;
		}*/			
	
		var bX:Number = sbd.xPos;
		var bY:Number = sbd.yPos;
		var xDistance:Number = 0;
		var yDistance:Number = 0;
		var totalDistance:Number = 0;
		var smallestNumber:Number = 100000;
		var lastPlayerGettingBall:uint;				
				
		lastPlayerGettingBall = theLastPlayerGettingBall(playersArray);
		noPlayersGettingBall();

		for ( i = 1; i < playersArray.length; i++) // skip keeper - keeper never charges
		{	
			//if ( ! playersArray[i].data.justBeaten )
			//{
				//calculate the distance
				xDistance = Math.abs ( playersArray[i].data.xPos - bX );
				yDistance = Math.abs ( playersArray[i].data.yPos - bY );
				totalDistance = Math.sqrt((xDistance*xDistance) + (yDistance*yDistance));
				
				// bias the distance here
				// increase it for the keeper
				//if ( playersArray[i].data.isKeeper ) totalDistance = smallestNumber*10;//gsd.keeperGoesForBallBias;
				// decrease it for the player last in control
				if ( i == lastPlayerGettingBall ) totalDistance -= gsd.playerRemainControlledBias;
	
				if ( totalDistance < smallestNumber ) 
				{
					smallestNumber = totalDistance;					
					noPlayersGettingBall();
					playersArray[i].data.gettingBall = true;					
				}
			//}			
		}		
	}
	private function theLastPlayerGettingBall(arrayOfPlayers:Array):uint{
		
		var lastPlayerGettingBall:uint =0;
		for ( var i:int = 1 ; i < arrayOfPlayers.length ; i ++ )
		{
			if ( arrayOfPlayers[i].data.gettingBall ) lastPlayerGettingBall = i;		
		}
		return lastPlayerGettingBall;
	}
	protected function noPlayersBeControlled( arrayOfPlayers:Array ):void{
		
		for ( var i:int = 0 ; i < arrayOfPlayers.length ; i ++ )
		{
			arrayOfPlayers[i].data.isControlled = false;		
		}		
	}		

//	protected function noPlayersGettingBall( arrayOfPlayers:Array ):void{
//		for ( var i:int = 0 ; i < arrayOfPlayers.length ; i ++ )
//		{
//			arrayOfPlayers[i].data.gettingBall = false;		
//		}
//	}		
	
	
	
	private function passAngleCloseEnoughToDribbleDirection():Boolean
	{
		if ( Math.abs(_data.autoPassAngle - pwbd.dribble) < Math.PI * .5 || Math.abs(_data.autoPassAngle - pwbd.dribble) > Math.PI * 1.5)
		{
			return true;
		} else {
			return false;
		}
	}
	
	private function throughPass():void
	{
		// calulate distance from pass receiver
		// divide the ditance by kickPower to get time
		// multiply passReceiver speed x by time and passReceriver speed y by time
		// get future passReceiverX and futurePassReceiverY
		// calulate angle of future x,y
		// set autoPassAngle to said angle
		
		var xDistance:Number = Math.abs(_data.closestTeamMate.xPos - pwbd.xPos);
		var yDistance:Number = Math.abs(_data.closestTeamMate.yPos - pwbd.yPos);
		var distanceFromPassReceiver:Number = xDistance + yDistance;
		var kickPower:uint = gsd.kickPower;
		var time:Number = distanceFromPassReceiver/kickPower;
		
		var speedX:Number = _data.closestTeamMate.speedX;
		var speedY:Number = _data.closestTeamMate.speedY;
		var xPos:Number = _data.closestTeamMate.xPos;
		var yPos:Number = _data.closestTeamMate.yPos;
		var futureX:Number = xPos + (time * speedX);
		var futureY:Number = yPos + (time * speedY);		
		var newAutoPassAngle:Number = RadiansCalculator.calc(futureX - pwbd.xPos, futureY - pwbd.yPos);
				
		
		_data.autoPassAngle = newAutoPassAngle;
		
		
	}
	
	
	
	
	
//	private function doBallCarrierStrategy():void
//	{	
//		if ( pwbd == null || pwbd.playerMarking == null) return;
//		
//		_data.pressureToPass = true;
//	
//		if ( pwbd == keeper.data ) return;
//			
//		// if defender is alredy beat then strike or go to strike position  ____________________________________________________
//		if ( pwbd.xPos < pwbd.playerMarking.xPos )
//		{
//			if ( inStrikingPosition())
//			{
//				lookForGoal();
//				return;
//			} else
//			{
//				getIntoStrikePosition();
//				return;				
//			}
//		}
//		
//		if ( pwbd.xPos < 250 ) // close enough to goal
//		{
//			lookForCross();
//			return;
//		}
//		
//		tryToBeatDefenderOrProtectBall();			
//	
//	}
	private function lookForGoal():void
	{
		if ( pwbd.dribble > (1.5 * Math.PI))
		{
			pwbd.dribble -= gsd.basicDribbleSpeed;
		}
		if ( pwbd.dribble < (.5 * Math.PI))
		{
			pwbd.dribble += gsd.basicDribbleSpeed;
		}
	}
	private function inStrikingPosition():Boolean
	{
		var inPos:Boolean = false;
		if ( pwbd.xPos < 600 )
		{
			if (pwbd.yPos > 300 && pwbd.yPos < 700)
			{
				inPos = true;
			}
		}
		return inPos;
	}
	
	private function lookForCross():void
	{
		protectBall();
		_data.pressureToPass = true;
	}

	private function protectBall():void
	{		
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
		pwbd.destinationX = pwbd.xPos + (20 * Math.cos( angleofDefender + Math.PI));
		pwbd.destinationY = pwbd.yPos + (20 * Math.sin( angleofDefender + Math.PI));
		//prevent being trapped in corner		
	}

	private function enoughSpaceToBeatDefender():Boolean
	{
		var xDistFromDefender:Number = Math.abs(sbd.xPos - pwbd.playerMarking.xPos);
		var yDistFromDefender:Number = Math.abs(sbd.yPos - pwbd.playerMarking.yPos);
		var totalDistFromDefender:Number = xDistFromDefender + yDistFromDefender;	
		
		if ( totalDistFromDefender >= gsd.spaceToTryBeatDefender) // space to tryToBeat()
		{
			return true;	
		}
		return false;
		
	}
	
	private function tryToBeatDefenderOrProtectBall():void
	{
		var angleOfGoal:Number = RadiansCalculator.calc( 50 - pwbd.xPos, 500 - pwbd.yPos);
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);		
		_data.pressureToPass = true;
		if ( enoughSpaceToBeatDefender() )
		{	
			//trace("demo    try to beat defender");	
			// go straight past defender
			if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius )
			{	
				//trace("demo                             straight ");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( Math.PI));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( Math.PI));
				//_data.pressureToPass = false;
				return;
			}	
			// cut left			
			if ( pwbd.yPos < pwbd.playerMarking.yPos && pwbd.yPos >= 200 ) 
			{
				//trace("demo                   cut right");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI)));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));
				//_data.pressureToPass = false;
				return;
			}		
			// cut right
			if ( pwbd.yPos > pwbd.playerMarking.yPos && pwbd.yPos <= 800 )
			{
				//trace("demo                           cut left");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI )));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));
				//_data.pressureToPass = false;
				return;
			}			
		}
		
		protectBall();
		_data.pressureToPass = true;
			
			// drop left
			/*trace("cpuTC getPastDef() - drop left");
			pwbd.destinationX = pwbd.xPos + (100 * Math.cos( .35 * Math.PI ));
			pwbd.destinationY = pwbd.yPos + (100 * Math.sin( .35 * Math.PI));
			return;*/
			// drop right
			/*trace("cpuTC getPastDef() - drop right");
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( 1.75 * Math.PI));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( 1.75 * Math.PI));
			return;*/				
	}
	
	private function tryToBeatDefender():void
	{	
		if ( pwbd.isKeeper )
			return;		// keeper shouldn't leave goal to try beat anyone
		
		var angleOfGoal:Number = RadiansCalculator.calc( 50 - pwbd.xPos, 500 - pwbd.yPos);
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
	
		if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius )
		{	
			//trace("demo                             straight ");
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( Math.PI));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( Math.PI));			
			return;
		}	
		// cut left			
		if ( pwbd.yPos < pwbd.playerMarking.yPos && pwbd.yPos >= 200 ) 
		{
			//trace("demo                   cut left");
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI)));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));			
			return;
		}		
		// cut right
		if ( pwbd.yPos > pwbd.playerMarking.yPos && pwbd.yPos <= 800 )
		{
			//trace("demo                           cut right");
			pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI )));
			pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));			
			return;
		}
	}

	private function getIntoStrikePosition():void
	{		
		//trace("demo     go to strike position ");
		pwbd.destinationX = 500;
		pwbd.destinationY = 500;
		if ( pwbd.playerMarking.yPos < pwbd.yPos ) pwbd.destinationY = 700;
		if ( pwbd.playerMarking.yPos > pwbd.yPos ) pwbd.destinationY = 300;		
	}
	
	
	
	
	//====================== Deprecating below inteli-shooter  ===================
	// now compare the closest team mate angle with the goal angle ( except for keeper)
	// and as long as past the half way mark
	//		pwbd.scoreBall = false;
	//		if ( ! pwbd.isKeeper && pwbd.xPos < 600)   //gsd.distanceBlueCanScoreFrom)
	//		{
	////  ========================================  intelli shooter  ================
	//		var leftGoalAngle:Number; var rightGoalAngle:Number;
	//		var leftGoalY:uint = 650; var rightGoalY:uint = 350;
	//		var goalX:uint = 50; 
	//		
	//		leftGoalAngle = radCalc.calc( goalX - pwbd.xPos , leftGoalY - pwbd.yPos );		
	//		rightGoalAngle =  radCalc.calc( goalX - pwbd.xPos , rightGoalY - pwbd.yPos );
	//	 		
	//	 	//intelli - pass means that we only test this goal angle if we already know it will beat the keeper
	//	 			
	//		// leftGoal
	//		if ( FieldData.getInstance().redKeeperOnHisLine == "left" )
	//		{
	//			if ( Math.abs(pwbD - leftGoalAngle) < smallestNumber || Math.abs(pwbD - leftGoalAngle) < gsd.angleCloseEnoughForScoreBall)   // score ball !
	//			{ 									
	//				//  don't draw line
	//							
	//				_data.autoPassAngle = radCalc.calc( goalX - pwbX, leftGoalY - pwbY ); // calc shoot angle
	//				pwbd.autoPassAngle = _data.autoPassAngle;
	//				if ( passAngleCloseEnoughToDribbleDirection () )
	//				{	
	//					pwbd.scoreBall = true;				
	//					return;	
	//				}
	//			}
	//		}
	//		
	//		// right goal
	//		if ( FieldData.getInstance().redKeeperOnHisLine == "right" )
	//		{
	//			if ( Math.abs(pwbD - leftGoalAngle) < smallestNumber || Math.abs(pwbD - leftGoalAngle) < gsd.angleCloseEnoughForScoreBall)   // score ball ! 
	//			{ 	
	//				// don't draw line
	//					
	//				_data.autoPassAngle = radCalc.calc( goalX - pwbX, rightGoalY - pwbY ); // calc shoot angle
	//				pwbd.autoPassAngle = _data.autoPassAngle;
	//				if ( passAngleCloseEnoughToDribbleDirection () )
	//				{	
	//					pwbd.scoreBall = true;				
	//					return;	
	//				}				
	//			}		
	//		}
	//		
	//		}
	
	//		private function resetDestinations():void
//		{
//			keeper.data.destinationX = 1350;
//			keeper.data.destinationY = 500;
//			player1.data.destinationX = 1200;
//			player2.data.destinationX = 1200;
//			player3.data.destinationX = 900;
//			player4.data.destinationX = 900;
//			player1.data.destinationY = 750;
//			player2.data.destinationY = 250;
//			player3.data.destinationY = 650;
//			player4.data.destinationY = 350;			
//		}

//private function initializePlayerPositions():void
//		{
//			keeper.data.xPos = 1350;
//			keeper.data.yPos = 500;
//			player1.data.xPos = 1200;
//			player2.data.xPos = 1200;
//			player3.data.xPos = 900;
//			player4.data.xPos = 900;
//			player1.data.yPos = 750;
//			player2.data.yPos = 250;
//			player3.data.yPos = 650;
//			player4.data.yPos = 350;
//		
//			 resetZones();
//		}


	
	}// close class
}// close package