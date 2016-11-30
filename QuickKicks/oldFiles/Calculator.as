package classes
{
	import classes.*;
	
	import mx.collections.ArrayCollection;

	public class Calculator
	{
		private static var _instance:Calculator;
		public var radCalc:RadiansCalculator = new RadiansCalculator();		
		public function Calculator()
		{
			
		}
		
		public function get fd():FieldData{
			return FieldData.getInstance();
		}
		
		public function get gsd():GameSettingsData{
			return GameSettingsData.getInstance();
		}
		
		public function get sbd():SoccerBallData{
			return SoccerBallData.getInstance();
		}
		
		public function returnAverage(numA:Number,numB:Number):Number{
			return ( numA + numB ) / 2;
		}
		
		public static function get instance():Calculator{
			if (_instance == null)
			{
				_instance = new Calculator();
			}
			return _instance;
		}
		
		public function calculateSpace():void{
			// a function that calulate each players space from every other player
			// and assigns it to the space property
		}
		
		public function openPass(pwbd:PlayerData,receiver:PlayerData):Boolean
		{			
			var i:uint =0;
			var goodPass:Boolean = true;
//			if ( bluePlayers == null || redPlayers == null) return false;
//			switch ( pwbd.teamId )
//			{
//				case "red":
//					// so see if any blue players are in the way of pass
//					for ( i =0; i < bluePlayers.length;i++)
//					{
//						if ( playerCanIntercept(pwbd,receiver,bluePlayers[i]) )
//							goodPass = false;
//					}					
//					break;
//				
//				case "blue":
//					for ( i =0; i < redPlayers.length;i++)
//					{
//						if ( playerCanIntercept(pwbd,receiver,redPlayers[i]) )
//							goodPass = false;
//					}								
//					break;
//			}
			return goodPass;
		}
		
		public function openGoal(pwbd:PlayerData,scorePost:ScorePostData):Boolean
		{			
			var i:uint =0;
			var goodPass:Boolean = true;
//			if ( bluePlayers == null || redPlayers == null) return false;
//			switch ( pwbd.teamId )
//			{
//				case "red":
//					// so see if any blue players are in the way of pass
//					for ( i =0; i < bluePlayers.length;i++)
//					{
//						if ( playerCanBlockShot(pwbd,scorePost,bluePlayers[i]) )
//							goodPass = false;
//					}					
//					break;
//				
//				case "blue":
//					for ( i =0; i < redPlayers.length;i++)
//					{
//						if ( playerCanBlockShot(pwbd,scorePost,redPlayers[i]) )
//							goodPass = false;
//					}								
//					break;
//			}
			return goodPass;
		}
		private function playerCanBlockShot(pwbd:PlayerData,scorePost:ScorePostData, defender:PlayerData):Boolean
		{
			/*
			a. calc angle of defender
			b. calc angle of scorePost
			c. get difference and call it "a"
			d. calc distance to scorePost and call it hypoteneuse
			e. tan(a) = opposite/ adjacent		
			f. tan(a) = x / distanceToDefender
			g. tan(a) * distanceToDefender = x		
			h if ( x > playerRadius + ballRadius )
			passNotBlockedByThisDefender = true;	
			*/
			var debug1:String = pwbd.id;
			var debug2:String = pwbd.teamId;
			var debug3:Number = scorePost.scorePostY;
			var debug4:String = defender.id;
			
			var xDistToPost:Number = Math.abs( scorePost.postsX - pwbd.xPos );
			var yDistToPost:Number = Math.abs( scorePost.scorePostY - pwbd.yPos );
			var totalDistanceToPost:Number = pythagoreanDistance(xDistToPost,yDistToPost);		
			
			var xDistToDefender:Number = Math.abs(defender.xPos - pwbd.xPos );
			var yDistToDefender:Number = Math.abs(defender.yPos - pwbd.yPos );
			var totalDistanceToDefender:Number = pythagoreanDistance(xDistToDefender, yDistToDefender);
			
			if ( totalDistanceToDefender > totalDistanceToPost )
			{					
				return false;			
			}
			var angleOfDefender:Number = RadiansCalculator.calc( (defender.xPos - pwbd.xPos),(defender.yPos - pwbd.yPos));
			var angleOfPost:Number = RadiansCalculator.calc(( scorePost.postsX - pwbd.xPos ),(scorePost.scorePostY - pwbd.yPos ));
			var a:Number = Math.abs( angleOfDefender - angleOfPost );
			// the problem here is that angles from opposite quadrants look alike
			if (  ( a > (Math.PI/2)) && a < ((Math.PI*3)/2) )
				return false;
			// x = tan(a) * distanceToDefender;
			var x:Number = Math.abs( Math.tan(a) ) * totalDistanceToDefender;
			if ( x > gsd.playerRadius + sbd.radius + gsd.passInterceptionSafetyDistance)
				return false;
			else
				return true;
			
		}
		
		private function playerCanIntercept(pwbd:PlayerData,receiver:PlayerData, defender:PlayerData):Boolean
		{
			/*
			a. calc angle of defender
			b. calc angle of receiver
			c. get difference and call it "a"
			d. calc distance to receiver and call it hypoteneuse
			e. tan(a) = opposite/ adjacent		
			f. tan(a) = x / distanceToDefender
			g. tan(a) * distanceToDefender = x		
			h if ( x > playerRadius + ballRadius )
			passNotBlockedByThisDefender = true;	
			*/
			var debug1:String = pwbd.id;
			var debug2:String = pwbd.teamId;
			var debug3:String = receiver.id;
			var debug4:String = defender.id;
			
			var xDistToReceiver:Number = Math.abs( receiver.xPos - pwbd.xPos );
			var yDistToReceiver:Number = Math.abs( receiver.yPos - pwbd.yPos );
			var totalDistanceToReceiver:Number = pythagoreanDistance(xDistToReceiver,yDistToReceiver);		
			
			var xDistToDefender:Number = Math.abs(defender.xPos - pwbd.xPos );
			var yDistToDefender:Number = Math.abs(defender.yPos - pwbd.yPos );
			var totalDistanceToDefender:Number = pythagoreanDistance(xDistToDefender, yDistToDefender);
			
			if ( totalDistanceToDefender > totalDistanceToReceiver )
			{					
				return false;			
			}
			var angleOfDefender:Number = RadiansCalculator.calc( (defender.xPos - pwbd.xPos),(defender.yPos - pwbd.yPos));
			var angleOfReceiver:Number = RadiansCalculator.calc(( receiver.xPos - pwbd.xPos ),(receiver.yPos - pwbd.yPos ));
			var a:Number = Math.abs( angleOfDefender - angleOfReceiver );
			// the problem here is that angles from opposite quadrants look alike
			if (  ( a > (Math.PI/2)) && a < ((Math.PI*3)/2) )
				return false;
			// x = tan(a) * distanceToDefender;
			var x:Number = Math.abs( Math.tan(a) ) * totalDistanceToDefender;
			if ( x > gsd.playerRadius + sbd.radius + gsd.passInterceptionSafetyDistance)
				return false;
			else
				return true;
			
		}	
			
		public function distanceFromBall(pd:PlayerData):Number{
			var dX:Number = pd.xPos - SoccerBallData.getInstance().xPos;
			var dY:Number = pd.xPos - SoccerBallData.getInstance().yPos;
			return pythagoreanDistance(dX,dY);
		}	
			
		
		public function pythagoreanDistance(theX:Number, theY:Number):Number
		{
			return  Math.sqrt( (theX*theX) + (theY*theY) );
		}
		
		public function defenderCloserToBallThanReceiver(ctmd:PlayerData):Boolean
		{
			return true;
		}
		
		public function distanceBetweenPlayers(playerA:PlayerData, playerB:PlayerData):Number{
			var deltaX:Number; var deltaY:Number; 
			deltaX = (playerA.xPos - playerB.xPos);
			deltaY = (playerA.yPos - playerB.yPos);
			return pythagoreanDistance(deltaX,deltaY);	
		}	
		
		private function maintainPlayersSphericalIntegrity(plyrA:PlayerData,plyrB:PlayerData):void{
			// all of below is true however its complicated by;
			// this function needs to take place on field controller or in the calculator class
			
			// we need to maintain players spherical integrity
			// must test that no two players are positioned with less than collision distance between them
			// the first evolution of this function will hit test every player with every other player
			// if there is less than collion distance between them then
			// collision distance is divided by two 
			// midpoint is calculated and each player is moved half of collision distance away.
			// they are moved by calculating their angle relative to midpoint and then calculating their x and y
			// by multiplying the cos and sin of the angle by the safeDistance
			
			//var dbps:Number = distanceBetweenPlayers(plyrA,plyrB);   dont think we actually need this
			var midpoint:Object = new Object();
			midpoint.x = Math.abs((( plyrA.xPos - plyrB.xPos )/2)) + ( plyrA.xPos < plyrB.xPos ? plyrA.xPos:plyrB.xPos );
			midpoint.y = Math.abs((( plyrA.yPos - plyrB.yPos )/2)) + ( plyrA.yPos < plyrB.yPos ? plyrA.yPos:plyrB.yPos );
			
			//calculate each players angle relative to midpoint
			// move them to safe distance
			
			var array:Array = new Array(plyrA,plyrB);
			var deltaX:Number; var deltaY:Number; var angleFromMidpoint:Number;
			var ppod:Number = GameSettingsData.getInstance().preventPlayerOverlapDistance;
			var i:uint=0;
			for ( i=0;i<array.length;i++)
			{
				//calculate the players angle from midpoint
				var plyr:PlayerData = (array[i] as PlayerData);
				deltaX = plyr.xPos - midpoint.x;
				deltaY = plyr.yPos - midpoint.y;
				angleFromMidpoint = RadiansCalculator.calc(deltaX,deltaY);
				//move the player to midpoint
				plyr.xPos = midpoint.x;
				plyr.yPos = midpoint.y;
				//move the player to ppod from the midpoint
				plyr.xPos += ( Math.cos(angleFromMidpoint) * ppod);
				plyr.yPos += ( Math.sin(angleFromMidpoint) * ppod);
			}
			 
		}		
		public function maintainBallsSphericalIntegrity(plyr:PlayerData):void{
						
			// we need to maintain the balls spherical integrity
						
			// collision distance is divided by two 
			// midpoint is calculated and each player is moved half of collision distance away.
			// they are moved by calculating their angle relative to midpoint and then calculating their x and y
			// by multiplying the cos and sin of the angle by the safeDistance
			
			//var dbps:Number = distanceBetweenPlayers(plyrA,plyrB);   dont think we actually need this
			var ball:SoccerBallData = SoccerBallData.getInstance();
			var midpoint:Object = new Object();
			midpoint.x = Math.abs((( plyr.xPos - ball.xPos )/2)) + ( plyr.xPos < ball.xPos ? plyr.xPos:ball.xPos );
			midpoint.y = Math.abs((( plyr.yPos - ball.yPos )/2)) + ( plyr.yPos < ball.yPos ? plyr.yPos:ball.yPos );
			
			//calculate each players angle relative to midpoint
			// move them to safe distance
						
			var deltaX:Number; var deltaY:Number; var angleFromMidpoint:Number;
			var pbod:Number = GameSettingsData.getInstance().preventBallOverlapDistance;
					
			//calculate the players angle from midpoint			
			deltaX = plyr.xPos - midpoint.x;
			deltaY = plyr.yPos - midpoint.y;
			angleFromMidpoint = RadiansCalculator.calc(deltaX,deltaY);
			//move the player to midpoint
			plyr.xPos = midpoint.x;
			plyr.yPos = midpoint.y;
			//move the player to pbod from the midpoint
			plyr.xPos += ( Math.cos(angleFromMidpoint) * pbod);
			plyr.yPos += ( Math.sin(angleFromMidpoint) * pbod);
			
			//calculate the balls angle from midpoint			
			deltaX = ball.xPos - midpoint.x;
			deltaY = ball.yPos - midpoint.y;
			angleFromMidpoint = RadiansCalculator.calc(deltaX,deltaY);
			//move the ball to midpoint
			ball.xPos = midpoint.x;
			ball.yPos = midpoint.y;
			//move the ball to pbod from the midpoint
			ball.xPos += ( Math.cos(angleFromMidpoint) * pbod);
			ball.yPos += ( Math.sin(angleFromMidpoint) * pbod);
			
			
		}		
		public function doCollision(ball0:PlayerData,ball1:PlayerData):void{
		
			maintainPlayersSphericalIntegrity(ball0,ball1);
							
			var ball0Mass:Number = 1; var ball1Mass:Number = 1;
			
			var dx:Number = ball1.xPos - ball0.xPos;
			var dy:Number = ball1.yPos - ball0.yPos;
			var dist:Number = distanceBetweenPlayers(ball0,ball1);
			
			var angle:Number = Math.atan2(dy,dx);
			var sine:Number = Math.sin(angle);
			var cosine:Number = Math.cos(angle);
			
			var x0:Number =0; var y0:Number = 0;
			
			var x1:Number = dx * cosine + dy * sine;
			var y1:Number = dy * cosine - dx * sine;
			
			var bouncy:Number = 1;
			ball0.speedX *= bouncy;
			ball0.speedY *= bouncy;
			ball1.speedX *= bouncy;
			ball1.speedY *= bouncy;
//			if (ball0.speedX == 0) ball0.speedX = 0.1;
//			if (ball0.speedY == 0) ball0.speedY = 0.1;
//			if (ball1.speedX == 0) ball0.speedX = 0.1;
//			if (ball1.speedY == 0) ball0.speedY = 0.1;
			
			//rotate ball0's velocity
			var vx0:Number = ball0.speedX * cosine + ball0.speedY * sine;
			var vy0:Number = ball0.speedY * cosine - ball0.speedX * sine;
			
			//rotate ball1's velocity
			var vx1:Number = ball1.speedX * cosine + ball1.speedY * sine;
			var vy1:Number = ball1.speedY * cosine - ball1.speedX * sine;
			
			//collision reaction
			var vxTotal:Number = vx0 - vx1;
			vx0 = ((ball0Mass - ball1Mass) * vx0 + 2 * ball1Mass * vx1) / ( ball0Mass + ball1Mass);
			vx1 = vxTotal + vx0;
			
			// update position
			x0 += vx0;
			x1 += vx1;
			
			//rotate positions back
			var x0Final:Number = x0 * cosine - y0 * sine;
			var y0Final:Number = y0 * cosine + x0 * sine;
			var x1Final:Number = x1 * cosine - y1 * sine;
			var y1Final:Number = y1 * cosine + x1 * sine;
			
			//adjust positions to actual screen positions
			ball1.xPos = ball0.xPos + x1Final;
			ball1.yPos = ball0.yPos + y1Final;
			ball0.xPos = ball0.xPos + x0Final;
			ball0.yPos = ball0.yPos + y0Final;
			
			//rotate valocities back
			ball0.speedX = vx0 * cosine - vy0 * sine;
			ball0.speedY = vy0 * cosine + vx0 * sine;
			ball1.speedX = vx1 * cosine - vy1 * sine;
			ball1.speedY = vy1 * cosine + vx1 * sine;
			
			
			
		}		
	}
}