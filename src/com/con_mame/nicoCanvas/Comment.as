package com.con_mame.nicoCanvas
{
	
	import flash.filters.BevelFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * コメントクラス
	 *  
	 * @author con_mame 2009/08/03
	 * 
	 */	
	public class Comment extends TextField
	{
		private var _commentSpeed:Number = -1;				//コメントスピード
		private var _isDanmaku:Boolean = false;			//弾幕モード判定
		private var _isStaticComment:Boolean = false;		//静止コメント判定
		private var _staticPosition:Number = 0;			//静止コメント位置
		
		//accesser		
		public function get speed():Number{ return _commentSpeed; }
		public function get isDanmaku():Boolean{ return _isDanmaku; }
		public function get isStaticComment():Boolean{ return _isStaticComment; }
		public function get commentPosition():Number{ return _staticPosition; }
		
		public function set speed(speed:Number):void{ _commentSpeed = speed; }
		public function set isDanmaku(danmakuFlag:Boolean):void{ _isDanmaku = danmakuFlag; }
		public function set isStaticComment(staticCommnetFlag:Boolean):void{ _isStaticComment = staticCommnetFlag; }
			
		
		/**
		 * コンストラクタ 
		 * 
		 */		
		public function Comment(comment:String, commands:Array)
		{
			super();
			var tf:TextFormat = new TextFormat();
			tf.size = commands["size"];
			tf.color = commands["color"];
			tf.bold = true;
			
			var filter:BevelFilter = new BevelFilter(1, 45, 0x000000, 1, 0, 1, 2, 2, 1, 1, "outer");
			//コメント色が黒だったら白色ベベルフィルタに変更
			if(tf.color == 0){
				filter.highlightColor = 0xffffff;
			}
			filters = [filter];
			
			var pos:Number = commands["position"];
			if(pos != NicoConstants.COMMENT_POSITION_NORMAL){
				_isStaticComment = true;
				_staticPosition = pos;
			}
			
			this.text = comment;
			this.selectable = false;
			this.autoSize = TextFieldAutoSize.LEFT;
			this.setTextFormat(tf);
		}
		
		/**
		 * コメントを指定されたスピードで移動 
		 * 
		 */		
		public function moveComment():void{
			this.x -= _commentSpeed;
		}
	}
}