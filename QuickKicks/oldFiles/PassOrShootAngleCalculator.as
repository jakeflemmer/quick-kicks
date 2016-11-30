package classes
{
	import classes.*;
	
	public class PassOrShootAngleCalculator
	{
		
		public var i:uint;  // loop counter
		public var c:RadiansCalculator = new RadiansCalculator();
		public var passReciever: PlayerData = null;
		public var scoreBall:Boolean = false;
		public var closestGoalPostX:Number;
		public var closestGoalPostY:Number;
		
		public function PassOrShootAngleCalculator()
		{
			// This class is here as the name suggests to calculate the pass or the shoot angle			
		}
		
		//--------------------------------------------------------------------------------------------------
		// PUBLIC MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		public function calculatePassOrShootAngle(pda:Array,pwbd:PlayerData,gpX:Number,lgpY:Number,rgpY:Number):Number  // player data array , goalPost X,Y
		{		
			// pass to the player who's angle is closest to dribble angle of the playerWithBall			
			// consider each side of the goal as a player / target and if that's the closest angle then scoreBall = true;		
			// but don't consider keeper for score ball	
			
			resetProperties(pda);
			
			var passAngle:Number;			
			
			var teamMateAngles:Array = new Array();	
			var teamMateDatas:Array = new Array();		
			
			// push the angle of each teammate into an array
			for ( i=0; i <pda.length;i++)
			{
				(pda[i] as PlayerData).angleFromPlayerWithBall = 10000;
				
				if ( (pda[i] as PlayerData).hasBall || (pda[i] as PlayerData).justPassed )
				{
					continue;
				}
				if ( Calculator.instance.distanceBetweenPlayers(pda[i],pwbd) > 1200 )
				{
					continue;
				}
				//calculate angle of each player
				var angle:Number = RadiansCalculator.calc( (pda[i] as PlayerData).xPos - pwbd.xPos , ( pda[i] as PlayerData).yPos - pwbd.yPos );
							 
				teamMateAngles.push(angle);
				teamMateDatas.push(pda[i]);
				(pda[i] as PlayerData).angleFromPlayerWithBall = angle;
				
			}				
			
			// now we have a complete array of every angle of each player 
			// we just need to cycle through and see which angle is the smallest			
			
			var smallestAngle:Number = 10000;
			for ( i=0; i <teamMateAngles.length; i ++)
			{
				if ( Math.abs(teamMateAngles[i] - pwbd.dribble) < smallestAngle )
				{
					smallestAngle = Math.abs(teamMateAngles[i] - pwbd.dribble);	
					passReciever = teamMateDatas[i];	
					passAngle = teamMateAngles[i];
				}	
			}			
			
			// then we see if the goal angle is smaller	( if the pwbd is in the attacking half )
				
			if ( inAttackingHalf(pwbd) )
			{			
			
			// LEFT goal
			angle = RadiansCalculator.calc( gpX - pwbd.xPos , lgpY - pwbd.yPos );		
				
			if ( Math.abs( angle - pwbd.dribble ) < smallestAngle )
			{
				// SCORE BALL
				smallestAngle = Math.abs( angle - pwbd.dribble );
				passAngle = angle;
				this.scoreBall = true;
				this.closestGoalPostX = gpX;
				this.closestGoalPostY = lgpY;
			}
			
			// RIGHT goal			
			angle = RadiansCalculator.calc( gpX - pwbd.xPos , rgpY - pwbd.yPos );		
				
			if ( Math.abs( angle - pwbd.dribble ) < smallestAngle )
			{
				// SCORE BALL
				smallestAngle = Math.abs( angle - pwbd.dribble );
				passAngle = angle;
				this.scoreBall = true;
				this.closestGoalPostX =gpX;
				this.closestGoalPostY = rgpY;
			}
			
			if ( this.scoreBall ) 
			{
				this.passReciever = null;
				pwbd.teamMateAimingPassAt = null;
				return passAngle;
			}	
			
			}
			else  // pwbd.not in attacking half
			{ 		
				this.scoreBall = false;				
			}
			
			if ( this.passReciever == null )
			{
				throw new Error("no pass receiver");
			}
			
			pwbd.teamMateAimingPassAt = this.passReciever;
			return passAngle;	
		}
		
		
		public function returnPassLineInfo(pwbd:PlayerData):Array{
			
			var passLineInfo:Array = new Array();
			passLineInfo[0] = pwbd.xPos;
			passLineInfo[1] = pwbd.yPos; 

			if ( this.scoreBall )
			{
				passLineInfo[2] = this.closestGoalPostX;
				passLineInfo[3] = this.closestGoalPostY;
			} 
			else 
			{
				passLineInfo[2] = this.passReciever.xPos
				passLineInfo[3] = this.passReciever.yPos;
			}
			return passLineInfo;
		}
		
		public function setPassReceiver():PlayerData{
			// TODO ??
			return null;
		}
		
		
		//--------------------------------------------------------------------------------------------------
		// PRIVATE MEHTODS 
		//--------------------------------------------------------------------------------------------------
		
		private function resetProperties(pda:Array):void{
			this.scoreBall = false;
			this.closestGoalPostX = null;
			this.closestGoalPostY = null;
			this.passReciever = null;
			for ( var i:uint=0; i < pda.length; i++)
			{
				(pda[i] as PlayerData).teamMateAimingPassAt = null;
			}
		}
		
		private function inAttackingHalf(pwbd:PlayerData):Boolean{
			
			var inAttackingHalf:Boolean = false;
			if ( pwbd.teamId == "red" && pwbd.xPos > 750 ) inAttackingHalf = true;
			if ( pwbd.teamId == "blue" && pwbd.xPos < 750 ) inAttackingHalf = true;
			return inAttackingHalf;			
		}
		
		//--------------------------------------------------------------------------------------------------
		// OLD CODE 
		//--------------------------------------------------------------------------------------------------
		
		
				// we need to find which is the team mate with the closest angle
			// a) the closest angle
			// b) which team mate it is
			// c) make that team mate the receiver 
			// d) give receiver filter
			// e) make receiver stop moving to get pass.
			// f) add the goal as a target
			
//			if ( SoccerBallData.getInstance().isFree ) return;
//			
//			if ( pwbd == null )	return;
			
//			if ( frameCount > oldFrameCount + 5)
//			{
//				oldFrameCount = frameCount;
//			}else{
//				return;
//			}
			
//			pwbd.scoreBall = false;
			
			//noPassReceiver(); TODO  this must still be done - just not here			
			
//			var tm1a:Number;
//			var tm2a:Number;
//			var tm3a:Number;
//			var tm4a:Number;		
//			var lga:Number;  // left goal angle
//			var rga:Number;   // right goal angle
//			var tm1X:Number; var tm1Y:Number;
//			var tm2X:Number; var tm2Y:Number;
//			var tm3X:Number; var tm3Y:Number;
//			var tm4X:Number; var tm4Y:Number;
//			var lgX:Number; var lgY:Number;
//			var rgX:Number; var rgY:Number;
//			var pwbX:Number = pwbd.xPos;
//			var pwbY:Number = pwbd.yPos;
//			var pwbD:Number = pwbd.dribble;
//			
//			lgX = _data.scorePostX;lgY = _data.scorePost.leftPostY;
//			rgX = _data.scorePost.postsX;rgY = _data.scorePost.rightPostY;
//			
//			if (pwbd == keeper.data ){			
//				tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//				tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//				tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//				tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//			}
//			if (pwbd == player1.data ){			
//				tm1X = keeper.data.xPos; tm1Y = keeper.data.yPos;
//				tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//				tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//				tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//			}
//			if (pwbd == player2.data ){			
//				tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//				tm2X = keeper.data.xPos; tm2Y = keeper.data.yPos;
//				tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//				tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//			}
//			if (pwbd == player3.data ){			
//				tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//				tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//				tm3X = keeper.data.xPos; tm3Y = keeper.data.yPos;
//				tm4X = player4.data.xPos; tm4Y = player4.data.yPos;
//			}
//			if (pwbd == player4.data ){			
//				tm1X = player1.data.xPos; tm1Y = player1.data.yPos;
//				tm2X = player2.data.xPos; tm2Y = player2.data.yPos;
//				tm3X = player3.data.xPos; tm3Y = player3.data.yPos;
//				tm4X = keeper.data.xPos; tm4Y = keeper.data.yPos;
//			}
//			
//			
//			tm1a = radCalc.calc(tm1X - pwbX, tm1Y - pwbY);
//			tm2a = radCalc.calc(tm2X - pwbX, tm2Y - pwbY); 
//			tm3a = radCalc.calc(tm3X - pwbX, tm3Y - pwbY);
//			tm4a = radCalc.calc(tm4X - pwbX, tm4Y - pwbY);
//			lga = radCalc.calc(lgX - pwbX, lgY - pwbY);
//			rga = radCalc.calc(rgX - pwbX, rgY - pwbY);
			
			
//			if (!pwbd.isKeeper)
//			{
//				teamMateAngles = 
//					[Math.abs(pwbD - tm1a),Math.abs(pwbD - tm2a),
//						Math.abs(pwbD - tm3a), Math.abs(pwbD - tm4a),
//						Math.abs(pwbD - lga), Math.abs(pwbD - rga)];
//			} else {
//				teamMateAngles =
//					[Math.abs(pwbD - tm1a),Math.abs(pwbD - tm2a),
//						Math.abs(pwbD - tm3a), Math.abs(pwbD - tm4a)];
//			}
//			
			
			
			
//			var closestTeamMateAngle:Array = [];// for debugging - if this array gets larger than one - error
//			var closestTeamMateNo:uint = 0; 		
//			var smallestNumber : Number = 1000; var biggestNumber : Number = 0;
//			var i:uint = 0;		
			
			// loop to find the smallest angle and biggest angle and call it smallestNumber and biggestNumber
//			for (i = 0; i < teamMateAngles.length; i++)	{
//				if ( teamMateAngles[i] <= smallestNumber ) smallestNumber = teamMateAngles[i];
//				if ( teamMateAngles[i] >= biggestNumber ) biggestNumber = teamMateAngles[i]; 		
//			}
//			//choose which is closer - the smallest number or the biggest
//			if ( smallestNumber <= ( (2 * Math.PI) - biggestNumber ) )
//			{
//				// loop to push the smallest angle into the closestTeamMateAngleArray and name the closestTeamMateNo
//				for (i=0; i < teamMateAngles.length; i++) {
//					if ( smallestNumber == teamMateAngles[i] ) {
//						closestTeamMateAngle.push( teamMateAngles[i]);
//						closestTeamMateNo = i;			
//					}
//				}
//			} else {
//				// loop to push the biggest angle into the closestTeamMateAngleArray and name the closestTeamMateNo
//				for (i=0; i < teamMateAngles.length; i++) {
//					if ( biggestNumber == teamMateAngles[i] ) {
//						closestTeamMateAngle.push( teamMateAngles[i]);
//						closestTeamMateNo = i;			
//					}
//				}
//			}	
			
//			if ( closestTeamMateAngle.length > 1 ) trace ("cpuTC.autoPass()-error"); // choose closest player
//			
//			passLine.clear();
//			
//			if ( closestTeamMateNo > GameSettingsData.getInstance().numberOfPlayers - 2) //score ball
//			{
//				pwbd.scoreBall = true;
//				var gpX:int; var gpY:int;  //goal post x and y
//				
//				if ( closestTeamMateNo == GameSettingsData.getInstance().numberOfPlayers - 1)
//				{
//					//left goal angle is 5
//					gpX = _data.scorePost.postsX; gpY = _data.scorePost.leftPostY;
//					_data.scorePost.goingForPost = gpY;
//					_data.autoPassAngle = radCalc.calc(gpX - pwbX, gpY - pwbY); 
//					passLine.draw( pwbX, pwbY, gpX, gpY ); //draw line
//					
//				} else {
//					// right goal angle is 6
//					gpX = _data.scorePost.postsX; gpY = _data.scorePost.rightPostY;
//					_data.scorePost.goingForPost = gpY;
//					_data.autoPassAngle = radCalc.calc(gpX - pwbX, gpY - pwbY); 
//					passLine.draw( pwbX, pwbY, gpX, gpY );//draw line					
//				}				
//				
//			}else{
				
//				setClosestTeamMateProperty(closestTeamMateNo)
//				
//				_data.autoPassAngle = radCalc.calc( _data.closestTeamMate.xPos - pwbX, 
//				_data.closestTeamMate.yPos - pwbY ); // calc pass angle
//				passLine.draw( pwbX, pwbY, _data.closestTeamMate.xPos, _data.closestTeamMate.yPos );//draw line
//				
//				_data.closestTeamMate.passReceiver = true;
//			}								
//			
//			pwbd.autoPassAngle = _data.autoPassAngle;	
//			
//			//make closest team mate receiver, give em filter, make em wait
//			
//			
//			//		
//			
//			//pwbd.passNow = true;
//			//throughPass();
//			

	}// close class
}// close package