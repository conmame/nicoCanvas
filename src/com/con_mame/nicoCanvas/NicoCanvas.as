package com.con_mame.nicoCanvas
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;

	/**
	 * 追加されたコメントをニコニコ動画の様に流すCanvas
	 * 
	 * Commentクラスのインスタンスを追加するだけで衝突判定やue,shitaコメントを指定の
	 * 位置に表示させる
	 * 
	 * @author con_mame 2009/08/03
	 * 
	 */	
	public class NicoCanvas extends UIComponent
	{
		
		private var _uePositonList:Array;		//ueコメントの位置情報管理
		private var _shitaPositonList:Array;	//shitaコメントの位置情報管理
		private var _commentTime:Number;		//コメントの表示時間
		private var _staticCommentTime:Number	//ue・shitaコメント表示時間
		
		/**
		 * コンストラクタ 
		 * 
		 */		
		public function NicoCanvas(commentTime:Number = NicoConstants.COMMENT_SPEED, staticCommentTime:Number = NicoConstants.STATIC_COMMENT_TIME)
		{
			super();
			_uePositonList = new Array();
			_shitaPositonList = new Array();
			_commentTime = commentTime;
			_staticCommentTime = staticCommentTime;
		}
		
		/**
		 * コメントをCanvasに追加する
		 *  
		 * @param comment 追加するコメント
		 * @param position 追加位置
		 * 
		 */		
		public function addComment(comment:Comment, speed:Number = NicoConstants.COMMENT_SPEED):void{
			comment.speed = (comment.speed == -1) ? ((unscaledWidth + comment.textWidth)/ (stage.frameRate * _commentTime)) : comment.speed;
			//trace(comment.speed);
			
			var position:Number = comment.commentPosition;
			if(position == NicoConstants.COMMENT_POSITION_NORMAL){
				var speed:Number = comment.speed;	//コメントスピード
				comment.x = unscaledWidth;			//コメントのスタートX座標
				comment.y = getYPosion(comment);	//コメントスタートY座標
				
				//コメント移動イベントを設定
				var moveComment:Function = function():void{
					if(comment.x >= -comment.textWidth){
						comment.x -= speed;
					}else{
						removeChild(comment);
						comment.removeEventListener(Event.ENTER_FRAME, moveComment);
					}
				}
				comment.addEventListener(Event.ENTER_FRAME, moveComment);
				
			}else if(position == NicoConstants.COMMENT_POSITION_UE || position == NicoConstants.COMMENT_POSITION_SHITA){
				if(comment.textWidth > unscaledWidth){									//長いコメントを画面の中に収める
					comment.scaleX = unscaledWidth/comment.textWidth
					comment.scaleY = comment.scaleX;
				}
				var staticX:Number = (unscaledWidth/2) - (comment.width/2);		//ue shitaコメントの表示用X座標
				comment.x = staticX;											//コメント表示X座標
				comment.y = getStaticYPositon(comment, position);				//コメント表示Y座標
				
				//コメント表示用タイマーイベント設定
				var removeTimer:Timer = new Timer(_staticCommentTime * 1000, 1);
				removeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function removeComment():void{
					removeChild(comment);
					if(position == NicoConstants.COMMENT_POSITION_UE){
						_uePositonList.shift();
					}else{
						_shitaPositonList.shift();
					}
					removeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, removeComment);
				});
				removeTimer.start();
				
			}else{
				throw new Error("コメントポジションが不正");
			}
			
			addChild(comment);		//コメントを追加
		}
		
		/**
		 * コメント表示時のY座標を算出
		 * 
		 * 衝突判定を行ってコメントが重ならないようにする
		 * 
		 * @param comment 追加するコメント
		 * @return 追加時のY座標
		 * 
		 */		
		private function getYPosion(comment:Comment):Number{
			var yPosition:Number = -1;									//Y座標の初期化
			
 			for(var index:Number = 1; index<numChildren; index++){						//表示中コメントとの衝突を調査
				var targetComment:Comment = Comment(getChildAt(index));					//調査対象のコメント
				if(targetComment.isDanmaku || targetComment.isStaticComment) continue;	//弾幕モードとue shitaコメントの場合は除外
				
				var leftTime:Number = (targetComment.x + targetComment.textWidth)/targetComment.speed	//調査対象の退場までの残り時間を計算
				var commentEndPositon:Number = comment.x - (comment.speed * leftTime);	//調査対象コメントが退場する時点でのコメント位置計算
				var targetEndPositon:Number = (targetComment.x - targetComment.speed * leftTime) + targetComment.textWidth;	//調査対象のコメントの挿入コメントが流れきる時点のX座標

				/**
				 * コメントスタート位置で挿入コメントと調査対象コメントが重なっている
				 * 挿入コメントが流れきる時点で調査対象コメントと重なる
				 * のどちらかに当てはまる場合はY座標を移動
				 * マージンで衝突判定領域を確保
				*/
 				if(yPosition >= targetComment.y && yPosition <= targetComment.y + targetComment.textHeight){
					if(((targetComment.x <= comment.x) && (comment.x <= targetComment.x + targetComment.textWidth + NicoConstants.COMMENT_MARGIN)) || 
						(commentEndPositon <= targetEndPositon)){
						yPosition = targetComment.y + targetComment.textHeight + NicoConstants.COMMENT_MARGIN;	//調査対象のコメントの高さ分Y座標を移動
						index = 1;												//再度調査開始
						if((yPosition + comment.textHeight) > unscaledHeight){		//コメントのY座標がCanvasサイズをはみ出す場合は弾幕モードに移行
							//trace("Danmaku Now!");
							comment.isDanmaku = true;
							return Math.random() * (unscaledHeight - comment.textHeight);
						}
					}
				}
			}
			return yPosition;
		}
		
		/**
		 * ue shitaコメント用のY座標を算出
		 *  
		 * @param comment 追加するコメント
		 * @param position ue shita
		 * @return 追加時のY座標
		 * 
		 */		
		private function getStaticYPositon(comment:Comment, position:Number):Number{
			var commentBottom:Number;					//コメントの高さ
			var basePosition:Number;					//コメント表示の初期位置
			var isRandomPosition:Boolean = false;		//ランダム状態
			
			if(position == NicoConstants.COMMENT_POSITION_UE){				//ueコメント
				commentBottom = basePosition = 0;							//初期化
	
				if(_uePositonList.length != 0){								//表示中ueコメントがあれば
					var ueTmp:Array = clone(_uePositonList);					//DeepCopyを作成し、挿入位置用ソートとsjiftの問題を回避
					ueTmp.sortOn("base", Array.NUMERIC);					//Y座標でソート
					
					for(var ue:Number = 0; ue<ueTmp.length; ue++){	//ueコメントが重ならないようにY座標計算
						var targetUeComment:Object = ueTmp[ue];
						if(targetUeComment["random"]) continue;
						commentBottom = basePosition+comment.textHeight;
						
						if((basePosition >= targetUeComment["base"] && basePosition <= targetUeComment["bottom"]) || 
							(commentBottom <= targetUeComment["bottom"] && commentBottom > targetUeComment["base"])){
							basePosition += targetUeComment["bottom"] - targetUeComment["base"];		//コメントの高さ分下へ移動
						}
						
						if(commentBottom > unscaledHeight){
							basePosition = Math.random()*(unscaledHeight-comment.height);		//最下部まで行って挿入出来なければランダム
							isRandomPosition = true;
							break;
						}
					}
				}
				_uePositonList.push({"base":basePosition, "bottom":basePosition+comment.textHeight, "random":isRandomPosition});		//表示位置を格納
				
			}else if(position == NicoConstants.COMMENT_POSITION_SHITA){				//shitaコメント
				basePosition = commentBottom = unscaledHeight - comment.textHeight;				//Canvas最下部からコメントの高さを引く
	
				if(_shitaPositonList.length != 0){
					var shitaTmp:Array = clone(_shitaPositonList);
					shitaTmp.sortOn("base", Array.NUMERIC|Array.DESCENDING);		//表示中shitaコメントを逆ソート
					
					for(var shita:Number = 0; shita<shitaTmp.length; shita++){
						var targetShitaComment:Object = shitaTmp[shita];
						if(targetShitaComment["random"]) continue
						commentBottom = basePosition + comment.textHeight;
						
						if((commentBottom > targetShitaComment["base"] && commentBottom <= targetShitaComment["bottom"]) ||
							(basePosition >= targetShitaComment["base"] && basePosition < targetShitaComment["bottom"])){
							basePosition -= targetShitaComment["bottom"]-targetShitaComment["base"];
						}
						
						if(basePosition < 0){
							basePosition = Math.random()*(unscaledHeight-comment.textHeight);
							isRandomPosition = true;
							break;								
						}
					}
				}
				_shitaPositonList.push({"base":basePosition, "bottom":basePosition+comment.textHeight, "random":isRandomPosition});
			}
			
			return basePosition;
		}
		
		/**
		 * DeepCopyを作成する
		 *  
		 * @param src コピー元配列
		 * @return コピーObject
		 * 
		 */		
		private function clone(src:Object):*{
			var dist:ByteArray = new ByteArray();
		    dist.writeObject(src);
		    dist.position = 0;
		    return dist.readObject();
		}
		
		/**
		 * UIComponentのcreateChildrenメソッドをoverride
		 * 
		 * NicoCanvasがChildに設定されたタイミングでマスクを設定し
		 * Canvasをはみ出したコメントが見えないようにする
		 * コメント入場時と退場時にNicoCanvasの領域外
		 * 
		 */		
		protected override function createChildren():void{
			super.createChildren();
			var mask:Sprite = new Sprite();
			mask.graphics.clear();
			mask.graphics.lineStyle(1);
			mask.graphics.beginFill(0xffffff);
			mask.graphics.drawRect(0,0,unscaledWidth,unscaledHeight);
			mask.graphics.endFill();
			addChild(mask);
			this.mask = mask;			
		}
	}
}