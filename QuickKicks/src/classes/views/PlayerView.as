package classes.views
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import classes.data.GameSettingsData;
	import classes.data.PlayerData;
	import classes.data.SoccerBallData;
	import classes.events.GameEvents;
	import classes.tools.RadiansCalculator;

	public class PlayerView extends Sprite
	{
		private var _data:PlayerData;
		private var _radius:Number;
		private var controlledFilter:GlowFilter;
		private var receiverFilter:GlowFilter;
		private var generatingKickPowerLevel1:GlowFilter;
		private var generatingKickPowerLevel2:GlowFilter;
		private var generatingKickPowerLevel3:GlowFilter;
		private var generatingKickPowerLevel4:GlowFilter;
		private var justBeatenFilter:GlowFilter;
		private var filtersArray:Array;
		
		private var radCalc:RadiansCalculator;
		
		private var colors:Array;
	
		private var loader:Loader =new Loader();
		private var image:Bitmap;
		
		
		public function PlayerView(playerData:PlayerData)
		{
		_data = playerData;
		_radius = _data.radius;
		radCalc = new RadiansCalculator;
		
		
		var redGettingBallFilter:GlowFilter = new GlowFilter(0xffcc99,1, _radius, _radius, 3,3);		
		var blueGettingBallFilter:GlowFilter = new GlowFilter(0x99ccff, 1, _radius, _radius,3,3);
		
		if (_data.teamId == "red") {
			controlledFilter = redGettingBallFilter;
			colors = GameSettingsData.getInstance().redTeamColors;
			if ( _data.isKeeper )
			{
				colors = GameSettingsData.getInstance().redTeamKeeperColor;
			}else{
				colors = GameSettingsData.getInstance().redTeamColors;
			}
		}else {
			controlledFilter = blueGettingBallFilter;
			if ( _data.isKeeper )
			{
				colors = GameSettingsData.getInstance().blueTeamKeeperColor;
			}else{
				colors = GameSettingsData.getInstance().blueTeamColors;
			}
			
		}
			
		justBeatenFilter = new GlowFilter(0x000000,0, _radius, _radius,0);		
		receiverFilter = new GlowFilter(0x9999ff,1, _radius, _radius,3,3);
		
		generatingKickPowerLevel1 = new GlowFilter(0xffffcc,1, _radius, _radius*5,2);
		generatingKickPowerLevel2 = new GlowFilter(0xffffcc,1, _radius, _radius*5,3);
		generatingKickPowerLevel3 = new GlowFilter(0xffffcc,1, _radius, _radius*5,4);
		generatingKickPowerLevel4 = new GlowFilter(0xffffcc,1, _radius, _radius*5,5);
		
		filtersArray = new Array();
		filtersArray = [];
		
		
		this.addEventListener(Event.ENTER_FRAME,ON_ENTER_FRAME);
		
		
		drawPlayer();	
		
			
		}
		
		
		
		
		
		
		
		
		
		
		private function drawPlayer(e:Event = null):void
		{
			
			graphics.clear();
			
					// Draw Player
			graphics.lineStyle(0);
			
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,128,255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_radius*4,
				_radius*4,
				45*(Math.PI/180),
				-_radius*1.7,
				-_radius*1.7);
			graphics.beginGradientFill(
				GradientType.RADIAL,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			
			graphics.drawCircle(0,0,_radius);
		
			this.x = _data.xPos;
			this.y = _data.yPos;			
			
		}
		
		//-------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------
		//-------------------------------------------------------------------------------------
		private function ON_ENTER_FRAME(e:Event):void
		{
			this.x = _data.xPos;
			this.y = _data.yPos;
						
			var lightSourceAngle:Number = RadiansCalculator.calc(0 - this.x, 500- this.y);
			lightSourceAngle += Math.PI;
			_data.lightSourceAngle = lightSourceAngle;
			
				graphics.clear();
			
					// Draw Player
			graphics.lineStyle(1);
			
			var alphas:Array = [1,1];
			var ratios:Array = [0,255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_radius*2,
				_radius*2,
				lightSourceAngle,
				-_radius,
				-_radius);
			graphics.beginGradientFill(
				GradientType.RADIAL,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			
			graphics.drawCircle(0,0,_radius);
				
			
			filtersArray = [];
			
			if ( _data.hasBall || _data.gettingBall || _data.isControlled )
			{
				filtersArray.push(controlledFilter);	
			}
			if ( _data.passReceiver )
			{
				if ( SoccerBallData.getInstance().isFree == false )
				{
					_data.passReceiver = false;
				}else{
					filtersArray.push(receiverFilter);	
				}
				
			}
			if ( _data.justBeaten )
			{
				filtersArray.push(justBeatenFilter);
			}
		
			filters = filtersArray;
		}
	}// close class
}// close packag	e