package classes.views
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import classes.data.SoccerBallData;
	import classes.events.GameEvents;

	public class SoccerBallView extends Sprite
	{
		private var _data:SoccerBallData;
		private var _redFilter:GlowFilter;
		private var _blueFilter:GlowFilter;
		
		private var loader:Loader =new Loader();
		private var image:Bitmap;
		
		private var ballMask:Shape = new Shape();
		private var ballShape:Shape = new Shape();
		
		
		public function SoccerBallView()
		{
			_data = SoccerBallData.getInstance();
			
			_data.addEventListener(GameEvents.CHANGE_POSSESSION,onChangePossession);
			
			_redFilter = new GlowFilter(0xff0000,1,SoccerBallData.getInstance().radius/2,SoccerBallData.getInstance().radius/2,1);
			_blueFilter = new GlowFilter(0x0000ff,1,SoccerBallData.getInstance().radius/2,SoccerBallData.getInstance().radius/2,1);
			
			loadImage();
		}
		
		private function loadImage():void {
			//Note: listeners are added to the contentLoaderInfo property of 'loader'
			//and not to 'loader' itself.
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,doneLoad);	
			
			loader.load(new URLRequest("../pics/clouds.jpg"));
		}
		
		
		private function doneLoad(e:Event):void {
			image = Bitmap(loader.content);
			this.addChild(image);
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,doneLoad);
			loader=null;
			maskBall();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		private function maskBall():void{
			
			ballMask.graphics.beginFill(0x000000);
			ballMask.graphics.drawCircle(0,0,_data.radius);
			ballMask.graphics.endFill();
			
			addChild(ballMask);
			
			image.mask = ballMask;
			
			ballShape.graphics.lineStyle(1,0x808000);
			var colors:Array = [0xffaa00,0x330000];
			var alphas:Array = [0,.9];
			var ratios:Array = [200,255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(
				_data.radius*2,
				_data.radius*2,
				45*(Math.PI/180),
				-_data.radius,
				-_data.radius);
			ballShape.graphics.beginGradientFill(
				GradientType.RADIAL,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			
			ballShape.graphics.drawCircle(0,0,_data.radius);
			addChild(ballShape);
			
		}
		
		
		
		
		
		private function onEnterFrame(e:Event = null):void
		{
			ballMask.x = _data.xPos;
			ballMask.y = _data.yPos;
		
			ballShape.x = _data.xPos;
			ballShape.y = _data.yPos;
			
		
			_data.spinX += (  _data.speed * ( Math.cos(_data.direction ) ) ) * .2;
			_data.spinY += (  _data.speed * ( Math.sin(_data.direction ) ) ) * .2;
			
			if (_data.spinX < -300 )
			{
				_data.spinX = -200;
			}
			if (_data.spinY < 100 )
			{
				_data.spinY = 200;
			}
			
			if (_data.spinX > -100 )
			{
				_data.spinX = -200;
			}
			if (_data.spinY > 300 )
			{
				_data.spinY = 200;
			}
			
		
			
			image.x = _data.xPos + _data.spinX;
			image.y = _data.yPos - _data.spinY;
		
			
			
		}
		
		
		
		
		
		
		
		private function onChangePossession(e:GameEvents):void
		{
			if(_data.redPossession)this.filters = [_redFilter];
			if (_data.bluePossession) this.filters = [_blueFilter];
		}
		
	}
}