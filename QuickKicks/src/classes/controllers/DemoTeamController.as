package classes.controllers
{ 
	import classes.data.*;
	import classes.interfaces.*;
	import classes.views.*;
	
	import flash.events.Event;
	
	public class DemoTeamController extends AbstractTeamController
	{			

		public function DemoTeamController()
		{
			initializeTeam();
			
			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);		
		}
		
//   __________________________________________________________________________________

		private function initializeTeam():void
		{							
			keeper = new HumanPlayerController;
			player1 = new HumanPlayerController;
			player2 = new HumanPlayerController;
			player3 = new HumanPlayerController;
			player4 = new HumanPlayerController;	
			
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
			setPlayerMaxSpeed();						
		}		
		public function reset():void
		{		
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
				playersArray[i].data.autoPassing = false;
				playersArray[i].data.challengingForBall = false;
				//playersArray[i].data.marking = false;
				playersArray[i].data.pressureToPass = false;
				playersArray[i].data.passNow = false;
				playersArray[i].data.justBeaten = false;
				playersArray[i].data.bumping = false;		
				playersArray[i].data.isControlled = false;				
			}			
			resetZones();
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
			player3.data.yPos = 250;
			player4.data.yPos = 750;
			
			resetZones();
		}
		private function setPlayerMaxSpeed():void
		{	
			keeper.data.maxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed;
			player1.data.maxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed;
			player2.data.maxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed;
			player3.data.maxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed;
			player4.data.maxSpeed = GameSettingsData.getInstance().redTeamMaxSpeed;			
		}
		
		public function ballNowFree():void
		{
			resetZones();
		}				
		private function resetZones():void
		{
		// assign team mate zones			
			for (var i:uint=0; i<5; i ++)	// set basic default zones
			{
				playersArray[i].data.zone = i;
				giveNewGetFreeDestination(i);
			}		
		}	
	
//  ________________________________________________________________     ON ENTER FRAME    ___________________________________________________________
//  __________________________________________________________________________________________________________________________________________


	private function ON_ENTER_FRAME(e:Event):void
	{
		frameCount ++;
		
		if ( SoccerBallData.getInstance().redPossession ) _data.state = "attacking";
		if ( SoccerBallData.getInstance().bluePossession ) _data.state = "defending";
				
		determineWhoHasBallOrWhoIsGettingBall();
		
		// field determines pressureToPass and sets it to TeamData
		if (_data.pressureToPass && _data.playerWithBallData != null ){
		
			cpuTeamAutoPass();	// sets _data.playerWithBall.autoPassAngle and sets _data.playerWithBall.passNow = true
			
			if ( openPass() )
			{
				if ( receiverNotCovered() )  // prevent interceptions
				{
					_data.playerWithBallData.passNow = true;
				}				 
			} 			
		}		
				
		doTeamStrategy();
		
		getPastDefender();
		
		keeperTracking();
		
		//autoPassIndicator();		
						
	}
	
	
	
	
	
	
	
	private function openPass():Boolean
	{
		//if ( _data.playerWithBallData == null ) return true;
		
		var openPass:Boolean = false;
		var pmX:Number = _data.playerWithBallData.xPos;
		var pmY:Number = _data.playerWithBallData.yPos;
		var playerMarkingAngle:Number =0;
		
		playerMarkingAngle = radCalc.calc( pmX - _data.playerWithBallData.xPos, pmY - _data.playerWithBallData.yPos);
		
		if ( Math.abs(_data.playerWithBallData.autoPassAngle - playerMarkingAngle )  >= ( .4 * Math.PI ))
		{
			openPass = true;
		}		
		
			//trace("cputeamCont.openPass(): " + openPass);
		return openPass;
		
	}	
	private function receiverNotCovered():Boolean
	{
		var notCovered:Boolean = false;
		var xDistToReceiver:Number = Math.abs( _data.playerWithBallData.xPos - _data.closestTeamMate.xPos);
		var yDistToReceiver:Number = Math.abs( _data.playerWithBallData.yPos - _data.closestTeamMate.yPos);
		var totalDistanceToReceiver:Number = xDistToReceiver + yDistToReceiver;
		if ( _data.closestTeamMate.playerMarking == null) // closest player is keeper 
		{ 
			if (_data.playerWithBallData.xPos <= 700 ) 
			{
				return false;		// too far to try to pass back to keeper
			} else {
				return true; 	// try to pass back to keeper
			}			
		}
		var xDistToInterceptor:Number = Math.abs( _data.playerWithBallData.xPos - _data.closestTeamMate.playerMarking.xPos);
		var yDistToIntercerptor:Number = Math.abs( _data.playerWithBallData.yPos - _data.closestTeamMate.playerMarking.yPos);
		var totalDistanceToIntercerptor:Number = xDistToInterceptor + yDistToIntercerptor;
		if ( totalDistanceToIntercerptor > totalDistanceToReceiver )
		{
			notCovered = true;	
		}
		return notCovered;
	}

	
private function getPastDefender():void
{
	// check to see that the defender is indeed in the way - less distance from goal
	// then check angle of defender relative to angle of goal
	// choose to go either 45 degrees to the right or 45 degrees to the left
	// trace to see that the choices aren't vacillating rapidly
	// go until pressure to pass naturally kicks in
	if ( _data.playerWithBallData == null || _data.playerWithBallData.playerMarking == null) return;
	
	// keeper doesn't try to get past anyone
	if ( _data.playerWithBallData == keeper.data )
	{
		keeper.data.destinationX = 1300;
		keeper.data.destinationY = 500;
		return;
	}
	
	// if defender is beat then go to strike position  ____________________________________________________
	if ( _data.playerWithBallData.xPos < _data.playerWithBallData.playerMarking.xPos )
	{
		// if already in strike position then strike
		var leftGoalY:uint = 350; var rightGoalY:uint = 650; var goalX:uint = 50;		 
		var leftGoalAngle:Number = radCalc.calc( goalX - _data.playerWithBallData.xPos , leftGoalY - _data.playerWithBallData.yPos );
		var rightGoalAngle:Number = radCalc.calc( goalX - _data.playerWithBallData.xPos , rightGoalY - _data.playerWithBallData.yPos );
				  
		// if in strike position then shoot
		// ===========================================================================================================
		if ( _data.playerWithBallData.xPos <= 600 && _data.playerWithBallData.xPos >= 400){	// shoot across goal
		
			if ( _data.playerWithBallData.yPos >= 625 ){  //enough strike angle to shoot at right goal corner
				_data.playerWithBallData.autoPassAngle = leftGoalAngle;
				_data.playerWithBallData.passNow = true;
				//trace("cpuTC.getPast(). inStrikePosition shoot left");
				return;				
			}
			if ( _data.playerWithBallData.yPos <= 475 ){	// enough strike angle to shoot at left goal center
				_data.playerWithBallData.autoPassAngle = rightGoalAngle;
				_data.playerWithBallData.passNow = true;
				//trace("cpuTC.getPast(). inStrikePosition shoot right");
				return;			
			}
		}
		if ( _data.playerWithBallData.xPos <= 400 ){	// shoot same side of goal
		
			if ( _data.playerWithBallData.yPos >= 625 ){ 
				_data.playerWithBallData.autoPassAngle = rightGoalAngle;
				_data.playerWithBallData.passNow = true;
				//trace("cpuTC.getPast(). inStrikePosition shoot left");
				return;				
			}
			if ( _data.playerWithBallData.yPos <= 475 ){	
				_data.playerWithBallData.autoPassAngle = leftGoalAngle;
				_data.playerWithBallData.passNow = true;
				//trace("cpuTC.getPast(). inStrikePosition shoot right");
				return;			
			}
		}//  ============================================================================================================		
		
		// if not yet in strike position then go to strike position
		//trace("cpuTeamC.getPast. go to strike position ");
		_data.playerWithBallData.destinationX = 500;
		_data.playerWithBallData.destinationY = 500;
		if ( _data.playerWithBallData.playerMarking.yPos < _data.playerWithBallData.yPos ) _data.playerWithBallData.destinationY = 700;
		if ( _data.playerWithBallData.playerMarking.yPos > _data.playerWithBallData.yPos ) _data.playerWithBallData.destinationY = 300;
		return;
	}// __________________________________________________________________________________________________
	
	// see if space to try to beat defender
	//______________________________________
	
	var angleOfGoal:Number = radCalc.calc( 50 - _data.playerWithBallData.xPos, 500 - _data.playerWithBallData.yPos);
	var angleofDefender:Number = radCalc.calc( _data.playerWithBallData.playerMarking.xPos - _data.playerWithBallData.xPos, _data.playerWithBallData.playerMarking.yPos - _data.playerWithBallData.yPos);
	var xDistFromDefender:Number = Math.abs(_data.playerWithBallData.xPos - _data.playerWithBallData.playerMarking.xPos);
	var yDistFromDefender:Number = Math.abs(_data.playerWithBallData.yPos - _data.playerWithBallData.playerMarking.yPos);
	var totalDistFromDefender:Number = xDistFromDefender + yDistFromDefender;
	
	if ( totalDistFromDefender >= GameSettingsData.getInstance().playerRadius * 3) // space to tryToBeat()
	{// _____________________________  try to beat defender  _____________________
	// cut left if 
	// a. defender y < playerWb - playerRadius
	// b. player y < 900;	
	// cut right if
	// a. defender y > playerWB + playerRadius
	// b. player y > 100;
		if ( frameCount < oldFrameCount + ( (Math.random()*20) + 10) ) return; // give a little time to try one strategy before changing it
	
		oldFrameCount = frameCount;
	
		// cut left		
		if ( _data.playerWithBallData.playerMarking.yPos < _data.playerWithBallData.yPos - GameSettingsData.getInstance().playerRadius ) 
		{
			if ( _data.playerWithBallData.yPos <= 800 ) // other wise cornered and must drop right
			{
				//trace("cpuTC getPastDef() - cut left");
				_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (50 * Math.cos( angleofDefender - (.35 * Math.PI)));
				_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (50 * Math.sin( angleofDefender - (.35 * Math.PI)));
				return;
			}
			// go straight past defender
				//trace("cpuTC getPastDef() - go straight past defender");
			_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (50 * Math.cos( 1 * Math.PI));
			_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (50 * Math.sin( 1 * Math.PI));
			return;
			
			// drop right
			/*trace("cpuTC getPastDef() - drop right");
			_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (50 * Math.cos( 1.75 * Math.PI));
			_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (50 * Math.sin( 1.75 * Math.PI));
			return;*/
		}
		// cut right
		if ( _data.playerWithBallData.playerMarking.yPos > _data.playerWithBallData.yPos + GameSettingsData.getInstance().playerRadius )
		{
			if ( _data.playerWithBallData.yPos >= 200 ) // other wise cornered and must protect ball
			{
				//trace("cpuTC getPastDef() - cut right");
				_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (100 * Math.cos( angleofDefender + (.35 * Math.PI )));
				_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (100 * Math.sin( angleofDefender + (.35 * Math.PI)));
				return;
			}	
			// go straight past defender
			//trace("cpuTC getPastDef() - go straight past defender");
			_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (50 * Math.cos( 1 * Math.PI));
			_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (50 * Math.sin( 1 * Math.PI));
			return;
			
			// drop left
			/*trace("cpuTC getPastDef() - drop left");
			_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (100 * Math.cos( .35 * Math.PI ));
			_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (100 * Math.sin( .35 * Math.PI));
			return;*/
		}
		// if not yet in strike position then go to strike position
		//trace("cpuTeamC.getPast.goToStrikePosition - defenderFarAway");
		_data.playerWithBallData.destinationX = 500;		
		if ( _data.playerWithBallData.playerMarking.yPos < _data.playerWithBallData.yPos ) _data.playerWithBallData.destinationY = 700;
		if ( _data.playerWithBallData.playerMarking.yPos > _data.playerWithBallData.yPos ) _data.playerWithBallData.destinationY = 300;
		return;
		
		
		
	} 
	// else protect the ball
	//  _____________________________________
		
	_data.playerWithBallData.destinationX = _data.playerWithBallData.xPos + (20 * Math.cos( angleofDefender + Math.PI));
	_data.playerWithBallData.destinationY = _data.playerWithBallData.yPos + (20 * Math.sin( angleofDefender + Math.PI));
	trace("cpuTC.getPast.protectBall");
	
}

	
	
	
//  __________________________________________________________________________________________________________________________________________
//  __________________________________________________________________________________________________________________________________________

// _________________________________________________________________________________________________
// __________________________________________________________________________________________________
// __________________________ CPU TEAM AUTO PASSING  ________________________________________________
	
	private function cpuTeamAutoPass():void
	{		
		// pass to the player who's angle is closest to dribble angle of the playerWithBall
		//  -- later only pass to open player.
		
		// player has openPass if   
		// a. passReceiver is closer than passReceiver.playerMarking
		// b. abs(closestTeamAngle - playerWithBallData.playerMarkingAngle < 30 degrees)
		 
		
		// we need to find which is the team mate with the closest angle
		// a) the closest angle
		// b) which team mate it is
		// c) make that team mate the receiver 
		// d) give receiver filter
		// e) make receiver stop moving to get pass.
		// f) add the goal as a target
		
		if ( SoccerBallData.getInstance().isFree ) {
			return;
		}
				
		if ( _data.playerWithBallData == null ){ //trace ("cpuTeam no pwb");
			return;}
						
		var tm1a:Number;
		var tm2a:Number;
		var tm3a:Number;
		var tm4a:Number;		
		var tm1X:Number; var tm1Y:Number;
		var tm2X:Number; var tm2Y:Number;
		var tm3X:Number; var tm3Y:Number;
		var tm4X:Number; var tm4Y:Number;
		var pwbX:Number = _data.playerWithBallData.xPos;
		var pwbY:Number = _data.playerWithBallData.yPos;
		var pwbD:Number = _data.playerWithBallData.dribble;
		
		if (_data.playerWithBallData == keeper.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player1.data ){			
			tm1X = keeper.data.xPos; tm1Y = keeper.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player2.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = keeper.data.xPos; tm2Y = keeper.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player3.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = keeper.data.xPos; tm3Y = keeper.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player4.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = keeper.data.xPos; tm4Y = keeper.data.yPos;
		}		
			tm1a = radCalc.calc(tm1X - pwbX, tm1Y - pwbY);
			tm2a = radCalc.calc(tm2X - pwbX, tm2Y - pwbY); 
			tm3a = radCalc.calc(tm3X - pwbX, tm3Y - pwbY);
			tm4a = radCalc.calc(tm4X - pwbX, tm4Y - pwbY);
	
		var teamMateAngles:Array = [Math.abs(pwbD - tm1a),Math.abs(pwbD - tm2a), Math.abs(pwbD - tm3a), Math.abs(pwbD - tm4a)];
		var closestTeamMateAngle:Array = [];
		var closestTeamMateNo:uint = 0; 		
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
		
		if ( closestTeamMateAngle.length > 1 ) trace ("cpuTC.autoPass()-error"); // choose closest player
		
		// no body close enough to pass to
		/*if ( smallestNumber > Math.PI /2 && biggestNumber < ( 3*Math.PI)/2) {
			trace("nodoby close enough");
			return;
		}*/		
				
		switch (_data.playerWithBallData) {
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
		// now compare the closest team mate angle with the goal angle ( except for keeper)
		if ( ! _data.playerWithBallData.isKeeper )
		{
//  ========================================  intelli shooter  ================
		var leftGoalAngle:Number; var rightGoalAngle:Number;
		var leftGoalY:uint = 350; var rightGoalY:uint = 650;
		var goalX:uint = 50; 
		
		leftGoalAngle = radCalc.calc( goalX - _data.playerWithBallData.xPos , leftGoalY - _data.playerWithBallData.yPos );		
		rightGoalAngle =  radCalc.calc( goalX - _data.playerWithBallData.xPos , rightGoalY - _data.playerWithBallData.yPos );
	 		
	 	//intelli - pass means that we only test this goal angle if we already know it will beat the keeper
	 			
		// leftGoal
		if ( FieldData.getInstance().redKeeperOnHisLine == "left" )
		{
			if ( Math.abs(pwbD - leftGoalAngle) < smallestNumber )   // score ball ! 
			{ 	
				smallestNumber = Math.abs( pwbD - leftGoalAngle );
				
				//  don't draw line
							
				_data.autoPassAngle = radCalc.calc( goalX - pwbX, leftGoalY - pwbY ); // calc shoot angle
				
				_data.playerWithBallData.autoPassAngle = _data.autoPassAngle;			
				return;
			}
		}
		
		// right goal
		if ( FieldData.getInstance().redKeeperOnHisLine == "right" )
		{
			if ( Math.abs(pwbD - rightGoalAngle) < smallestNumber )   // score ball ! 
			{ 	
				// don't draw line
					
				_data.autoPassAngle = radCalc.calc( goalX - pwbX, rightGoalY - pwbY ); // calc shoot angle
				
				_data.playerWithBallData.autoPassAngle = _data.autoPassAngle;			
				return;
			}		
		}
		
		}
		// pass line would be drawn here if this was a human team
								
		_data.autoPassAngle = radCalc.calc( _data.closestTeamMate.xPos - pwbX, _data.closestTeamMate.yPos - pwbY ); // calc pass angle
	 
		_data.playerWithBallData.autoPassAngle = _data.autoPassAngle;	
		
		//make closest team mate receiver, give em filter, make em wait
		
		keeper.data.passReceiver = false;
		player1.data.passReceiver = false;
		player2.data.passReceiver = false;
		player3.data.passReceiver = false;
		player4.data.passReceiver = false;
		_data.closestTeamMate.passReceiver = true;	
		
		//_data.playerWithBallData.passNow = true;
							
	}	

	private function keeperTracking():void
	{
		if ( keeper.data.hasBall ) return;		
		if ( keeper.data.justBeaten ) return;
					
		var deltaX:Number = ( 50 - SoccerBallData.getInstance().xPos );  // 50 = goalCenterX
		var deltaY:Number = ( 500 - SoccerBallData.getInstance().yPos );  //  500 = goalCenterY
			
		var theAngleFromGoal:Number = radCalc.calc(deltaX,deltaY);
	
		var keeperDestinationX:Number = (25 - ( 150 * Math.cos(theAngleFromGoal)));
		var keeperDestinationY:Number = (500 - ( 175 * Math.sin(theAngleFromGoal)));
			
		keeper.data.destinationX = keeperDestinationX;
		keeper.data.destinationY = keeperDestinationY;				
	}
	
	private function doTeamStrategy():void
	{
		if (_data.state == null) return;
		if ( _data.playerWithBallData == null ) return;				
		if (_data.state != "attacking" ) return;
		
		
		// if zone Player with ball is in has changed then set new zones for teamMates
		// and give all players new get free zones
		_data.oldZone = _data.playerWithBallData.zone;
		checkZonePlayerWithBallIsIn();
		var newZone:uint = _data.playerWithBallData.zone;
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
			switch (_data.playerWithBallData )  // then change based on ball carriers zone
			{
				case keeper.data:
					break;
				case player1.data:     // player 1 has the ball 
					switch (_data.playerWithBallData.zone)
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
					switch (_data.playerWithBallData.zone)
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
					switch (_data.playerWithBallData.zone)
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
					switch (_data.playerWithBallData.zone)
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
	
	
	
	protected function determineWhoHasBallOrWhoIsGettingBall():void
	{		
		_data.playerWithBallData = null;
		if ( playersArray[0].data.hasBall ) _data.playerWithBallData = playersArray[0].data;
		if ( playersArray[1].data.hasBall ) _data.playerWithBallData = playersArray[1].data;
		if ( playersArray[2].data.hasBall ) _data.playerWithBallData = playersArray[2].data;
		if ( playersArray[3].data.hasBall ) _data.playerWithBallData = playersArray[3].data;
		if ( playersArray[4].data.hasBall ) _data.playerWithBallData = playersArray[4].data;
		
		if ( _data.playerWithBallData != null )
		{
			for ( i = 0 ; i < playersArray.length ; i ++ )
			{
				playersArray[i].data.gettingBall = false;		
			}					
			return;
		}				
	
		var bX:Number = SoccerBallData.getInstance().xPos;
		var bY:Number = SoccerBallData.getInstance().yPos;
		var xDistance:Number = 0;
		var yDistance:Number = 0;
		var totalDistance:Number = 0;
		var smallestNumber:Number = 10000;
		var lastPlayerGettingBall:uint;
		
		var i : int;
					
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
				if ( i == lastPlayerGettingBall ) totalDistance -= GameSettingsData.getInstance().playerRemainControlledBias;
	
				if ( totalDistance < smallestNumber ) 
				{
					smallestNumber = totalDistance;
					for ( var j:int = 0; j < i; j++)
					{
						playersArray[j].data.gettingBall = false;
					}
					playersArray[i].data.gettingBall = true;
				}
			}			
		}		
	}
	
	protected function determineWhoHasBallAndWhoIsControlled():void
	{		
		_data.playerWithBallData = null;
		if ( playersArray[0].data.hasBall ) _data.playerWithBallData = playersArray[0].data;
		if ( playersArray[1].data.hasBall ) _data.playerWithBallData = playersArray[1].data;
		if ( playersArray[2].data.hasBall ) _data.playerWithBallData = playersArray[2].data;
		if ( playersArray[3].data.hasBall ) _data.playerWithBallData = playersArray[3].data;
		if ( playersArray[4].data.hasBall ) _data.playerWithBallData = playersArray[4].data;
		
		if ( _data.playerWithBallData != null )
		{
			for ( i = 0 ; i < playersArray.length ; i ++ )
			{
				playersArray[i].data.isControlled = false;		
			}		
			_data.playerWithBallData.isControlled = true;			
			return;
		}
		// if nobody has ball then determine who is closest							
		var bX:Number = SoccerBallData.getInstance().xPos;
		var bY:Number = SoccerBallData.getInstance().yPos;
		var xDistance:Number = 0;
		var yDistance:Number = 0;
		var totalDistance:Number = 0;
		var smallestNumber:Number = 10000;
		var lastPlayerControlled:uint;
		
		var i : int;
		
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
				if ( i == lastPlayerControlled ) totalDistance -= GameSettingsData.getInstance().playerRemainControlledBias;
				
				if ( totalDistance < smallestNumber ) 
				{
					smallestNumber = totalDistance;
					for ( var j:uint = 0; j < i; j++)
					{
						playersArray[j].data.isControlled = false;
					}
					playersArray[i].beControlled();
				}
			}			
		}
	}
//  ______________________________________  last function - AutoPass Indictator  _______________________________	
	private function autoPassIndicator():void
	{
		// we need to find which is the team mate with the closest angle
		// a) the closest angle
		// b) which team mate it is
		// c) make that team mate the receiver 
		// d) give receiver filter
		// e) make receiver stop moving to get pass.
		// f) add the goal as a target
		
				
		if ( SoccerBallData.getInstance().isFree ) {
			passLine.clear();
			return;
		}
		
		if ( _data.playerWithBallData == null )return;
				
		if (frameCount > autoPassFrameNum + 2) {
			autoPassFrameNum = frameCount;
		} else {
			return;
		}
		
		var tm1a:Number;
		var tm2a:Number;
		var tm3a:Number;
		var tm4a:Number;
		
		var tm1X:Number; var tm1Y:Number;
		var tm2X:Number; var tm2Y:Number;
		var tm3X:Number; var tm3Y:Number;
		var tm4X:Number; var tm4Y:Number;
		var pwbX:Number = _data.playerWithBallData.xPos;
		var pwbY:Number = _data.playerWithBallData.yPos;
		var pwbD:Number = _data.playerWithBallData.dribble;
		//trace("pwb x : " + pwbX);
		if (_data.playerWithBallData == keeper.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player1.data ){			
			tm1X = keeper.data.xPos; tm1Y = keeper.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player2.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = keeper.data.xPos; tm2Y = keeper.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player3.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = keeper.data.xPos; tm3Y = keeper.data.yPos;
			tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
		}
		if (_data.playerWithBallData == player4.data ){			
			tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
			tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
			tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
			tm4X = keeper.data.xPos; tm4Y = keeper.data.yPos;
		}		
			tm1a = radCalc.calc(tm1X - pwbX, tm1Y - pwbY);
			tm2a = radCalc.calc(tm2X - pwbX, tm2Y - pwbY); 
			tm3a = radCalc.calc(tm3X - pwbX, tm3Y - pwbY);
			tm4a = radCalc.calc(tm4X - pwbX, tm4Y - pwbY);
	
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
		
		if ( closestTeamMateAngle.length > 1 ) trace ("fucked"); // choose closest player
		
		// no body close enough to pass to
		if ( smallestNumber > Math.PI /2 && biggestNumber < ( 3*Math.PI)/2) {
			passLine.clear();
			return;
			trace("nodoby close enough");
		}		
			
		switch (_data.playerWithBallData) {
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
		// now compare the closest team mate angle with the goal angle ( except for keeper)
		if ( ! _data.playerWithBallData.isKeeper )  // keeper can't score
		{
//  =======================================  sharp shooter   ========================================================
		var leftGoalAngle:Number; var rightGoalAngle:Number;
		var leftGoalY:uint = 350; var rightGoalY:uint = 650;
		var goalX:uint = 1450; 
		
		leftGoalAngle = radCalc.calc( goalX - _data.playerWithBallData.xPos , leftGoalY - _data.playerWithBallData.yPos );		
		rightGoalAngle =  radCalc.calc( goalX - _data.playerWithBallData.xPos , rightGoalY - _data.playerWithBallData.yPos );
				
		// leftGoal
		if ( Math.abs(pwbD - leftGoalAngle) < smallestNumber )   // score ball ! 
		{ 	
			smallestNumber = Math.abs( pwbD - leftGoalAngle );
			// draw line
			passLine.draw( pwbX, pwbY, goalX, leftGoalY );//draw line
		
			_data.autoPassAngle = radCalc.calc( goalX - pwbX, leftGoalY - pwbY ); // calc shoot angle
				
			_data.playerWithBallData.autoPassAngle = _data.autoPassAngle;			
			return;
		}
		// right goal
		if ( Math.abs(pwbD - rightGoalAngle) < smallestNumber )   // score ball ! 
		{ 	
			// draw line
			passLine.clear();
			passLine.draw( pwbX, pwbY, goalX, rightGoalY );//draw line
		
			_data.autoPassAngle = radCalc.calc( goalX - pwbX, rightGoalY - pwbY ); // calc shoot angle
				
			_data.playerWithBallData.autoPassAngle = _data.autoPassAngle;			
			return;
		}
		
		}
		
		// draw the line here		
		//trace ("tma1:  " + tm1a.toPrecision(2) + "  tma2:  " + tm2a.toPrecision(2) + "  tm3a:  " + tm3a.toPrecision(2) + "  tm4a:  " + tm4a.toPrecision(2));
					
		passLine.draw( pwbX, pwbY, _data.closestTeamMate.xPos, _data.closestTeamMate.yPos );//draw line
		
		_data.autoPassAngle = radCalc.calc( _data.closestTeamMate.xPos - pwbX, _data.closestTeamMate.yPos - pwbY ); // calc pass angle
	 
		_data.playerWithBallData.autoPassAngle = _data.autoPassAngle;	
		
		//make closest team mate receiver, give em filter, make em wait
		
		keeper.data.passReceiver = false;
		player1.data.passReceiver = false;
		player2.data.passReceiver = false;
		player3.data.passReceiver = false;
		player4.data.passReceiver = false;
		_data.closestTeamMate.passReceiver = true;	
							
	}
	
	
	
	
	}// close class
}// close package