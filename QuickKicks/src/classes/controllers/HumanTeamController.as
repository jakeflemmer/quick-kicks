package classes.controllers
{ 
	import flash.events.Event;
	
	import classes.data.FieldData;
	import classes.data.SoccerBallData;
	import classes.data.TeamData;
	import classes.events.GameEvents;
	import classes.tools.Calculator;
	import classes.tools.ESP;
	import classes.tools.RadiansCalculator;
	import classes.views.PlayerShadow;
	
	public class HumanTeamController extends AbstractTeamController
	{			

		public function HumanTeamController()
		{
			initializeTeam();
			
			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);		
		}
		
//   __________________________________________________________________________________

		private function initializeTeam():void
		{							
			keeper = new HumanPlayerController( true );
			player1 = new HumanPlayerController();
			player2 = new HumanPlayerController();
			player3 = new HumanPlayerController();
			player4 = new HumanPlayerController();	
						
			keeperShadow = new PlayerShadow(keeper.data);
			player1Shadow = new PlayerShadow(player1.data);
			player2Shadow = new PlayerShadow(player2.data);
			player3Shadow = new PlayerShadow(player3.data);
			player4Shadow = new PlayerShadow(player4.data);
			
			addChild(keeperShadow);
			addChild(player1Shadow);
			addChild(player2Shadow);
			addChild(player3Shadow);
			addChild(player4Shadow);
			
			keeper.data.isKeeper = true;
						
			addChild(passLine);
				
			addChild(keeper);
			addChild(player1);
			addChild(player2);
			addChild(player3);
			addChild(player4);
					
			_data = new TeamData(keeper.data, player1.data, player2.data, player3.data, player4.data);
			
			playersArray = new Array(5);
			playersArray[0] = keeper;
			playersArray[1] = player1;
			playersArray[2] = player2;
			playersArray[3] = player3;
			playersArray[4] = player4;
						
			initializePlayerPositions();
			addEventListeners();
							
		}		
		private function addEventListeners():void
		{
			keeper.addEventListener(GameEvents.MANUAL_PASS,precisionPass);
			player1.addEventListener(GameEvents.MANUAL_PASS,precisionPass);
			player2.addEventListener(GameEvents.MANUAL_PASS,precisionPass);
			player3.addEventListener(GameEvents.MANUAL_PASS,precisionPass);
			player4.addEventListener(GameEvents.MANUAL_PASS,precisionPass);
			
			keeper.addEventListener(GameEvents.GOT_BALL,onPlayerGotBall);
			player1.addEventListener(GameEvents.GOT_BALL,onPlayerGotBall);
			player2.addEventListener(GameEvents.GOT_BALL,onPlayerGotBall);
			player3.addEventListener(GameEvents.GOT_BALL,onPlayerGotBall);
			player4.addEventListener(GameEvents.GOT_BALL,onPlayerGotBall);
			
			keeper.addEventListener(GameEvents.MANUAL_PASS,onPlayerMakesPass);
			player1.addEventListener(GameEvents.MANUAL_PASS,onPlayerMakesPass);
			player2.addEventListener(GameEvents.MANUAL_PASS,onPlayerMakesPass);
			player3.addEventListener(GameEvents.MANUAL_PASS,onPlayerMakesPass);
			player4.addEventListener(GameEvents.MANUAL_PASS,onPlayerMakesPass);
		}
		public function reset():void
		{		
			resetDestinations();
			_data.pressureToPass = false;	
			initializePlayerPositions();	
				
			noPlayersHaveBall();
			
			var i:int;
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.speed = 0;
				playersArray[i].data.speedX = 0;
				playersArray[i].data.speedY=0;
				playersArray[i].data.generatingKickPower = false;
				playersArray[i].data.kickPower = 0;
				playersArray[i].data.justPassed = false;
				playersArray[i].data.passReceiver = false;
				playersArray[i].data.pressureToPass = false;
				playersArray[i].data.passNow = false;
				playersArray[i].data.justBeaten = false;						
				playersArray[i].data.isControlled = false;				
			}			
			resetZones();
		}		
		public function goalReset():void
		{
			resetDestinations();
			
			_data.pressureToPass = false;				
			noPlayersHaveBall();
			
			var i:int;
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.speed = 0;
				playersArray[i].data.speedX = 0;
				playersArray[i].data.speedY=0;
				playersArray[i].data.generatingKickPower = false;
				playersArray[i].data.kickPower = 0;
				playersArray[i].data.justPassed = false;
				playersArray[i].data.passReceiver = false;			
				//playersArray[i].data.marking = false;
				playersArray[i].data.pressureToPass = false;
				playersArray[i].data.passNow = false;
				playersArray[i].data.justBeaten = false;						
				playersArray[i].data.isControlled = false;				
			}
			
		}
		private function resetDestinations():void
		{
			keeper.data.destinationX = 150;
			keeper.data.destinationY = 500;
			player1.data.destinationX = 300;
			player2.data.destinationX = 300;
			player3.data.destinationX = 600;
			player4.data.destinationX = 600;
			player1.data.destinationY = 250;
			player2.data.destinationY = 750;
			player3.data.destinationY = 350;
			player4.data.destinationY = 650;
			
		}
		private function initializePlayerPositions():void
		{		
			keeper.data.xPos = 150;
			keeper.data.yPos = 500;
			player1.data.xPos = 300;
			player2.data.xPos = 300;
			player3.data.xPos = 600;
			player4.data.xPos = 600;
			player1.data.yPos = 250;
			player2.data.yPos = 750;
			player3.data.yPos = 350;
			player4.data.yPos = 650;
			
			resetZones();
		}
		
		public function ballNowFree():void
		{
			resetZones();
		}				
		private function resetZones():void
		{
		// assign team mate zones			
			for (var i:uint=1; i<5; i ++)	// set basic default zones
			{
				playersArray[i].data.zone = i;
				giveNewGetFreeDestination(i);
			}		
		}	
	
//  ________________________________________________________________     ON ENTER FRAME    ___________________________________________________________
//  __________________________________________________________________________________________________________________________________________


	private function ON_ENTER_FRAME(e:Event):void
	{
		if (gsd.paused || gsd.goalAnimation) return;
		
		frameNumber();
		
		passLine.clear();
	
		if (gsd.demoMode)  
		{
		///   DEMO MODE !!  ___________________________________________
		
			determineWhoHasBallOrWhoIsGettingBall();
			
			doTeamStrategy();
			
			doBallCarrierStrategy();
		
			keeperTracking();				
			
			if ( pwbd != null ){
				
				ESP.p("pwbd player has ball", "human", "humanTeam");
				
				calculatePassOrShootAngle();  //cpuTeamAutoPass();	// sets _data.playerWithBall.autoPassAngle 
				
				if ( pwbd.scoreBall ){
					ESP.p("pwbd has scoreBall", "human", "humanTeam");
					if ( true ) // openPass()  needs to be openScoreBall() function
					{	
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
					else 
					{
						protectBall();
						_data.pressureToPass = true;										
					}
					
				} else {
					_data.pressureToPass = true;
				}
				
				if ( _data.pressureToPass && ! pwbd.justPassed)
				{	
					if ( Calculator.instance.openPass(pwbd,_data.closestTeamMate) )
					{
							precisionPass();
							pwbd.passNow = true;
					}
				}							
			}			
		
		} else {  
		//  PLAYER MODE  !!  _____________________________________________________________________
			
			determineWhoHasBallAndWhoIsControlled();			
						
			doTeamStrategy();
		
			keeperTracking();
		
			autoPassIndicator();		
		}				
	}
//  __________________________________________________________________________________________________________________________________________
//  __________________________________________________________________________________________________________________________________________
	private function onPlayerMakesPass(e:GameEvents):void
	{
		_data.closestTeamMate.passReceiver = true;
	}
	private function onPlayerGotBall(e:GameEvents):void
	{
		noPassReceiver();
	}
	private function precisionPass(e:GameEvents = null):void
	{
		if (pwbd.scoreBall ) return;
		
		if (_data.closestTeamMate == null) return;
		
		var theX:Number = ( _data.closestTeamMate.xPos - SoccerBallData.getInstance().xPos );
		var theY:Number = ( _data.closestTeamMate.yPos - SoccerBallData.getInstance().yPos );
		var precisionPassAngle:Number = RadiansCalculator.calc(theX, theY); 		
		_data.autoPassAngle = precisionPassAngle;
		pwbd.autoPassAngle = precisionPassAngle;		
	}
	private function keeperTracking():void
	{
		if ( keeper.data.gettingBall ) return;
		if ( keeper.data.justBeaten ) return;
		if ( keeper.data.hasBall ) 
		{
			keeper.data.destinationX = 200;
			if ( keeper.data.yPos > 525 ) keeper.data.destinationY = 400;
			if ( keeper.data.yPos < 475 ) keeper.data.destinationY = 600;
			//if ( keeper.data.dribble > Math.PI * .5 && keeper.data.dribble < Math.PI * 1.5 ) keeper.data.destinationX = keeper.data.xPos + 10;
			_data.pressureToPass = true;
			return;
		}		
					
		var deltaX:Number = ( 50 - SoccerBallData.getInstance().xPos );  // 50 = goalCenterX
		var deltaY:Number = ( 500 - SoccerBallData.getInstance().yPos );  //  500 = goalCenterY
			
		var theAngleFromGoal:Number = RadiansCalculator.calc(deltaX,deltaY);
	
		var keeperDestinationX:Number = (25 - ( 150 * Math.cos(theAngleFromGoal)));
		var keeperDestinationY:Number = (500 - ( 175 * Math.sin(theAngleFromGoal)));
			
		keeper.data.destinationX = keeperDestinationX;
		keeper.data.destinationY = keeperDestinationY;				
	}
	
	private function doTeamStrategy():void
	{
		
		if ( pwbd == null ) return;				
		
		// if zone Player with ball is in has changed then set new zones for teamMates
		// and give all players new get free zones
		_data.oldZone = pwbd.zone;
		checkZonePlayerWithBallIsIn();
		var newZone:uint = pwbd.zone;
		if ( newZone != _data.oldZone ) 
		{			
			setNewTeamMateZones();
			giveAllNewGetFreeDestinations();
			return;			
		}		
	
		//see if players have reached their last get free zone and if they have then give em new ones
		var closeEnough:uint = 10;
		for ( var i:int = 0;i < 5; i++)
		{
			if ( calculatedDistanceFromGetFreeZone(i) < 2 )
			{
				//trace ("humTeamCont doStrategy() closeEnough");
				giveNewGetFreeDestination(i);
			}
		}	
	}	
	
	private function setNewTeamMateZones():void
	{			
			switch (pwbd )  // then change based on ball carriers zone
			{
				case keeper.data:
					break;
				case player1.data:     // player 1 has the ball 
					switch (pwbd.zone)
					{
						case 1:				// in zone 1
							// all stays the same;
							break;
						case 2:				// in zone 2
							player2.data.zone =1;
							break;
						case 3:
							player3.data.zone = 5; // superAttack!
							break;
						case 4:
							player4.data.zone = 5; // superAttack ! 
							break;
					}
					break;
				case player2.data:    // player 2 has ball				
					switch (pwbd.zone)
					{
						case 1:				// in zone 1
							player1.data.zone = 2;				
							break;
						case 2:				// in zone 2							
							// all stays the same;
							break;
						case 3:
							player3.data.zone = 5; // superAttack!
							break;
						case 4:
							player4.data.zone = 5; // superAttack ! 
							break;
					}
					break;		
				case player3.data:
					switch (pwbd.zone)
					{
						case 1:				// in zone 1
							player1.data.zone = 3;
							break;
						case 2:				// in zone 2							
							player2.data.zone = 3;
							break;
						case 3:
							// all stays the same;							
							break;
						case 4:
							player4.data.zone = 3;  
							break;
					}
					break;
				case player4.data:
					switch (pwbd.zone)
					{
						case 1:				// in zone 1
							player1.data.zone = 4;
							break;
						case 2:				// in zone 2							
							player2.data.zone = 4;
							break;
						case 3:				// in zone 3
							player3.data.zone = 4;					
							break;
						case 4:
							// all stays the same;							  
							break;
					}
					break;
				}				
	
	}	
	
	
	
	
	
	protected function determineWhoHasBallAndWhoIsControlled():void
	{		
		var i:int; var j:int; var k:int;
		
		pwbd = null;
		if ( playersArray[0].data.hasBall ) pwbd = playersArray[0].data;
		if ( playersArray[1].data.hasBall ) pwbd = playersArray[1].data;
		if ( playersArray[2].data.hasBall ) pwbd = playersArray[2].data;
		if ( playersArray[3].data.hasBall ) pwbd = playersArray[3].data;
		if ( playersArray[4].data.hasBall ) pwbd = playersArray[4].data;
		
		if ( pwbd != null )
		{
			for ( i = 0 ; i < playersArray.length ; i ++ )
			{
				playersArray[i].data.isControlled = false;		
			}		
			
			pwbd.isControlled = true;			
			return;
		}
		
					
		var bX:Number = SoccerBallData.getInstance().xPos;
		var bY:Number = SoccerBallData.getInstance().yPos;
		var xDistance:Number = 0;
		var yDistance:Number = 0;
		var totalDistance:Number = 0;
		var smallestNumber:Number = 10000;
		var lastPlayerControlled:uint;
					
		for ( i = 0 ; i < playersArray.length ; i ++ )
			{
				if ( playersArray[i].data.isControlled ) lastPlayerControlled = i;
				playersArray[i].data.isControlled = false;		
			}		
		for ( i = 0; i < playersArray.length; i++)
		{	
			if ( ! playersArray[i].data.justBeaten )
			{
				xDistance = Math.abs ( playersArray[i].data.xPos - bX );
				yDistance = Math.abs ( playersArray[i].data.yPos - bY );
				totalDistance = xDistance + yDistance;
				// bias the distance here
				// increase it for the keeper
				if ( playersArray[i].data.isKeeper ) totalDistance += 200;
				// decrease it for the player last in control
				if ( i == lastPlayerControlled ) totalDistance -= gsd.playerRemainControlledBias;
				
				if ( totalDistance < smallestNumber ) 
				{
					smallestNumber = totalDistance;
					for ( k = 0; k < i; k++)
					{
						playersArray[k].data.isControlled = false;
					}
					playersArray[i].data.isControlled = true;
				}
			}			
		}
	}
//  ______________________________________  last function - AutoPass Indictator  _______________________________	
	private function autoPassIndicator():void
	{
		if ( pwbd == null )return;	
		calculatePassOrShootAngle();
		return;
		// we need to find which is the team mate with the closest angle
		// a) the closest angle
		// b) which team mate it is
		// c) make that team mate the closestTeamMate		
		// d) add the goal as a target
		
				
		if ( SoccerBallData.getInstance().isFree ) {
			passLine.clear();
			return;
		}
		
		if ( pwbd == null )return;	
		
		var tm1a:Number;
		var tm2a:Number;
		var tm3a:Number;
		var tm4a:Number;
		
		var tm1X:Number; var tm1Y:Number;
		var tm2X:Number; var tm2Y:Number;
		var tm3X:Number; var tm3Y:Number;
		var tm4X:Number; var tm4Y:Number;
		var pwbX:Number = pwbd.xPos;
		var pwbY:Number = pwbd.yPos;
		var pwbD:Number = pwbd.dribble;
		//trace("pwb x : " + pwbX);
		if (pwbd == keeper.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (pwbd == player1.data ){			
			tm1X = keeper.data.xPos; tm1Y = keeper.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (pwbd == player2.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = keeper.data.xPos; tm2Y = keeper.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (pwbd == player3.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = keeper.data.xPos; tm3Y = keeper.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (pwbd == player4.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = keeper.data.xPos; tm4Y = keeper.data.yPos;
		}		
			tm1a = RadiansCalculator.calc(tm1X - pwbX, tm1Y - pwbY);
			tm2a = RadiansCalculator.calc(tm2X - pwbX, tm2Y - pwbY); 
			tm3a = RadiansCalculator.calc(tm3X - pwbX, tm3Y - pwbY);
			tm4a = RadiansCalculator.calc(tm4X - pwbX, tm4Y - pwbY);
	
		var teamMateAngles:Array = [Math.abs(pwbD - tm1a),Math.abs(pwbD - tm2a), Math.abs(pwbD - tm3a), Math.abs(pwbD - tm4a)];
		var closestTeamMateAngle:Array = [];
		var closestTeamMateNo:uint =0; 		
		var smallestNumber : Number = 1000; var biggestNumber : Number = 0;
		var i:uint = 0;		
		
		// loop to find the smallest angle and biggest angle and call it smallestNumber and biggestNumber
		for (i = 0; i < teamMateAngles.length; i++)	{
			if ( teamMateAngles[i] <= smallestNumber ) smallestNumber = teamMateAngles[i];
			if ( teamMateAngles[i] >= biggestNumber ) biggestNumber = teamMateAngles[i]; 		
		}
		//choose which is closer - the smallest number or the biggest
		if ( smallestNumber <= ( (2 * Math.PI) - biggestNumber ) )
		{
			// loop to push the smallest angle into the closestTeamMateAngleArray and name the closestTeamMateNo
			for (i=0; i < teamMateAngles.length; i++) {
				if ( smallestNumber == teamMateAngles[i] ) {
					closestTeamMateAngle.push( teamMateAngles[i]);
					closestTeamMateNo = i;			
				}
			}
		} else {
			// loop to push the biggest angle into the closestTeamMateAngleArray and name the closestTeamMateNo
			for (i=0; i < teamMateAngles.length; i++) {
				if ( biggestNumber == teamMateAngles[i] ) {
					closestTeamMateAngle.push( teamMateAngles[i]);
					closestTeamMateNo = i;			
				}
			}
		}
		
		if ( closestTeamMateAngle.length > 1 ) trace ("oops"); // choose closest player		
			
		switch (pwbd) {
			case keeper.data:			
				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
				break;
			case player1.data:
				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = keeper.data;
				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
				break;
			case player2.data:
				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = keeper.data;
				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
				break;
			case player3.data:
				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = keeper.data;
				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = player4.data;
				break;
			case player4.data:
				if ( closestTeamMateNo == 0 ) _data.closestTeamMate = player1.data;
				if ( closestTeamMateNo == 1 ) _data.closestTeamMate = player2.data;
				if ( closestTeamMateNo == 2 ) _data.closestTeamMate = player3.data;
				if ( closestTeamMateNo == 3 ) _data.closestTeamMate = keeper.data;
				break;
		}		
		// now compare the closest team mate angle with the goal angle ( except for keeper and players too far away)
		if ( ! pwbd.isKeeper && pwbd.xPos > 600)  // keeper can't score nor can players too far away
		{
//  _______________________________________________   sharp shooter   _________________________________________________________

		var leftGoalAngle:Number; var rightGoalAngle:Number;
		var leftGoalY:uint = 350; var rightGoalY:uint = 650;
		var goalX:uint = 1450; 
		
		leftGoalAngle = RadiansCalculator.calc( goalX - pwbd.xPos , leftGoalY - pwbd.yPos );		
		rightGoalAngle =  RadiansCalculator.calc( goalX - pwbd.xPos , rightGoalY - pwbd.yPos );
				
		// leftGoal
		if ( Math.abs(pwbD - leftGoalAngle) < smallestNumber )   // score ball ! 
		{ 	
			smallestNumber = Math.abs( pwbD - leftGoalAngle );
			// draw line
			passLine.draw( pwbX, pwbY, goalX, leftGoalY );//draw line
		
			_data.autoPassAngle = RadiansCalculator.calc( goalX - pwbX, leftGoalY - pwbY ); // calc shoot angle
				
			pwbd.autoPassAngle = _data.autoPassAngle;	
			pwbd.scoreBall = true;
			noPassReceiver();		
			return;
		}
		// right goal
		if ( Math.abs(pwbD - rightGoalAngle) < smallestNumber )   // score ball ! 
		{ 	
			// draw line
			passLine.clear();
			passLine.draw( pwbX, pwbY, goalX, rightGoalY );//draw line
		
			_data.autoPassAngle = RadiansCalculator.calc( goalX - pwbX, rightGoalY - pwbY ); // calc shoot angle
				
			pwbd.autoPassAngle = _data.autoPassAngle;
			pwbd.scoreBall = true;
			noPassReceiver();			
			return;
		}
		pwbd.scoreBall = false;
		
		}	// ___________ end sharp shooter __________
		
		// draw the line here					
		passLine.draw( pwbX, pwbY, _data.closestTeamMate.xPos, _data.closestTeamMate.yPos );//draw line
		
		_data.autoPassAngle = RadiansCalculator.calc( _data.closestTeamMate.xPos - pwbX, _data.closestTeamMate.yPos - pwbY ); // calc pass angle
	 
		pwbd.autoPassAngle = _data.autoPassAngle;	
		
		//make closest team mate receiver, give em filter, make em wait
		
		noPassReceiver();		
		
		//throughPass();
							
	}
	
//  ___________________________________________________________________________________________________________________________________
//  ___________________________________________________________________________________________________________________________________
// demo team stuff here    xxxx
	private function noPassReceiver():void
	{
		var i :uint = 0;
		for ( i=0; i <5;i++)
		{
			playersArray[i].data.passReceiver = false;
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
		var kickPower:uint = gsd.blueTeamKickPower;
		var friction:Number = gsd.soccerBallFriction;		
		
		var time:Number = distanceFromPassReceiver/(kickPower/2);
		
		var speedX:Number = _data.closestTeamMate.speedX;
		var speedY:Number = _data.closestTeamMate.speedY;
		var xPos:Number = _data.closestTeamMate.xPos;
		var yPos:Number = _data.closestTeamMate.yPos;
		var futureX:Number = xPos + (time * speedX);
		var futureY:Number = yPos + (time * speedY);		
		var newAutoPassAngle:Number = RadiansCalculator.calc(futureX - pwbd.xPos, futureY - pwbd.yPos);
				
		
		_data.autoPassAngle = newAutoPassAngle;
		
		
	}
	private function getIntoStrikePosition():void
	{		
		//trace("demo     go to strike position ");
		pwbd.destinationX = 1000;
		pwbd.destinationY = 500;
		if ( pwbd.playerMarking.yPos < pwbd.yPos ) pwbd.destinationY = 700;
		if ( pwbd.playerMarking.yPos > pwbd.yPos ) pwbd.destinationY = 300;		
	}
	
	
	
	private function doBallCarrierStrategy():void
	{	
		if ( pwbd == null || pwbd.playerMarking == null) return;
	
		if ( pwbd == keeper.data ){          // keeper doesn't try to get past anyone
			keeper.data.destinationX = 300;	keeper.data.destinationY = 500;
			return;
		}
	
		// if defender is alredy beat then strike or go to strike position  ____________________________________________________
		if ( pwbd.xPos > pwbd.playerMarking.xPos )
		{
			if ( inStrikingPosition())
			{
				lookForGoal();
				return;
			} else
			{
				getIntoStrikePosition();
				return;				
			}
		}
		
		if ( pwbd.xPos > 1250 ) // close enough to goal
		{
			lookForCross();
			return;
		}
		
		tryToBeatDefenderOrProtectBall();			
	
	}// end getPastDefender()
	private function lookForGoal():void
	{
		if ( pwbd.dribble < (1.5 * Math.PI))
		{
			pwbd.dribble += gsd.basicDribbleSpeed;
		}
		if ( pwbd.dribble > (.5 * Math.PI))
		{
			pwbd.dribble -= gsd.basicDribbleSpeed;
		}
	}
	private function inStrikingPosition():Boolean
	{
		var inPos:Boolean = false;
		if ( pwbd.xPos > 900 )
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
		//trace("demo               protectBall");
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);
		pwbd.destinationX = pwbd.xPos + (20 * Math.cos( angleofDefender + Math.PI));
		pwbd.destinationY = pwbd.yPos + (20 * Math.sin( angleofDefender + Math.PI));		
	}
	private function enoughSpaceToBeatDefender():Boolean
	{
		var xDistFromDefender:Number = Math.abs(SoccerBallData.getInstance().xPos - pwbd.playerMarking.xPos);
		var yDistFromDefender:Number = Math.abs(SoccerBallData.getInstance().yPos - pwbd.playerMarking.yPos);
		var totalDistFromDefender:Number = xDistFromDefender + yDistFromDefender;
		
		var enoughSpace:Boolean = false;
		
		if ( totalDistFromDefender >= gsd.playerRadius * 4) // space to tryToBeat()
		{
			enoughSpace = true;	
		}
		return enoughSpace;
		
	}
	
	private function tryToBeatDefenderOrProtectBall():void
	{
		var angleOfGoal:Number = RadiansCalculator.calc( 1450 - pwbd.xPos, 500 - pwbd.yPos);
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);		
		
		if ( enoughSpaceToBeatDefender() )
		{	
			//trace("demo    try to beat defender");	
			// go straight past defender
			if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius )
			{	
				//trace("demo                             straight ");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( 0));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( 0));
				_data.pressureToPass = false;
				return;
			}	
			// cut left			
			if ( pwbd.yPos < pwbd.playerMarking.yPos && pwbd.yPos >= 200 ) 
			{
				//trace("demo                   cut left");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI)));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));
				_data.pressureToPass = false;
				return;
			}		
			// cut right
			if ( pwbd.yPos > pwbd.playerMarking.yPos && pwbd.yPos <= 800 )
			{
				//trace("demo                           cut right");
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI )));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));
				_data.pressureToPass = false;
				return;
			}			
		}
		
		protectBall();
		//_data.pressureToPass = true;
			
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
		var angleOfGoal:Number = RadiansCalculator.calc( 1450 - pwbd.xPos, 500 - pwbd.yPos);
		var angleofDefender:Number = RadiansCalculator.calc( pwbd.playerMarking.xPos - pwbd.xPos, pwbd.playerMarking.yPos - pwbd.yPos);		
				
			// go straight past defender
			if ( Math.abs( pwbd.yPos - pwbd.playerMarking.yPos) > gsd.playerRadius )
			{					
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( 0));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( 0));				
				return;
			}	
			// cut left			
			if ( pwbd.yPos < pwbd.playerMarking.yPos && pwbd.yPos >= 200 ) 
			{				
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI)));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));				
				return;
			}		
			// cut right
			if ( pwbd.yPos > pwbd.playerMarking.yPos && pwbd.yPos <= 800 )
			{				
				pwbd.destinationX = pwbd.xPos + (50 * Math.cos( angleofDefender + (.35 * Math.PI )));
				pwbd.destinationY = pwbd.yPos + (50 * Math.sin( angleofDefender + (.35 * Math.PI)));				
				return;
			}			
	}
	
	


protected function determineWhoHasBallOrWhoIsGettingBall():void
	{		
		var i:int; 
		var j:int; 
		var	k:int;
		
		pwbd = null;
		if ( playersArray[0].data.hasBall ) pwbd = playersArray[0].data;
		if ( playersArray[1].data.hasBall ) pwbd = playersArray[1].data;
		if ( playersArray[2].data.hasBall ) pwbd = playersArray[2].data;
		if ( playersArray[3].data.hasBall ) pwbd = playersArray[3].data;
		if ( playersArray[4].data.hasBall ) pwbd = playersArray[4].data;
		
		if ( pwbd != null )
		{
			for ( i = 0 ; i < playersArray.length ; i ++ )
			{
				playersArray[i].data.gettingBall = false;		
			}					
			if (pwbd == keeper.data ) _data.pressureToPass = true;
			return;
		}
							
	
		var bX:Number = SoccerBallData.getInstance().xPos;
		var bY:Number = SoccerBallData.getInstance().yPos;
		var xDistance:Number = 0;
		var yDistance:Number = 0;
		var totalDistance:Number = 0;
		var smallestNumber:Number = 10000;
		var lastPlayerGettingBall:uint;	
					
		for ( i = 0 ; i < playersArray.length ; i ++ )
		{
			if ( playersArray[i].data.gettingBall ) lastPlayerGettingBall = i;
			playersArray[i].data.gettingBall = false;		
		}		
		for ( i = 0; i < playersArray.length; i++)
		{	
			if ( ! playersArray[i].data.justBeaten )
			{
				xDistance = Math.abs ( playersArray[i].data.xPos - bX );
				yDistance = Math.abs ( playersArray[i].data.yPos - bY );
				totalDistance = xDistance + yDistance;
				// bias the distance here
				// increase it for the keeper
				if ( playersArray[i].data.isKeeper ) totalDistance += 200;
				// decrease it for the player last in control
				if ( i == lastPlayerGettingBall ) totalDistance -= gsd.playerRemainControlledBias;
	
				if ( totalDistance < smallestNumber ) 
				{
					smallestNumber = totalDistance;
					for ( j = 0; j < i; j++)
					{
						playersArray[j].data.gettingBall = false;
					}
					playersArray[i].data.gettingBall = true;
				}
			}			
		}		
	}
	
	


	
	
	}// close class
}// close package