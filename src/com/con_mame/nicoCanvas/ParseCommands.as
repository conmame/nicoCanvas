package com.con_mame.nicoCanvas
{
	/**
	 * ニコニコ動画で使用されているコマンドをパースする
	 * 
	 * @author con_mame 2009/08/03
	 * 
	 */	
	public class ParseCommands
	{

		//ユーザ指定サイズ
		public static var commentSmallSize:Number;
		public static var commentNormalSize:Number;
		public static var commentBigSize:Number;
		
		/**
		 * コマンドをパースして連想配列で返す
		 *  
		 * @param commands コマンド文字列(スペースでコマンドが区切られている)
		 * @return パース済のコマンド
		 * 
		 */		
		public static function Parse(commands:String):Array{
			var splitedCommands:Array = commands.split(/\s/);
			var parsedCommands:Array = new Array();
			
			parsedCommands["color"] = convertToColorCode(splitedCommands);
			parsedCommands["size"] = convertToSize(splitedCommands);
			parsedCommands["position"] = convertToStatic(splitedCommands);
			
			return parsedCommands;
		}
		
		/**
		 * コメント色をカラーコードに変換
		 * カラーコードを指定出来る仕様にも対応
		 *  
		 * @param colors 全コマンド
		 * @return 指定されたカラーコード
		 * 
		 */		
		private static function convertToColorCode(colors:Array):Number {
			var ret:Number = 0xffffff;
			for(var color:String in colors){
				var c:String =  colors[color];
				//trace(colors[color]);
				switch(c) {
					case "white":
						ret = 0xffffff;
						break;
					case "red":
						ret = 0xff0000;
						break;
					case "pink":
						ret = 0xff8080;
						break;
					case "orange":
						ret = 0xffcc00;
						break;
					case "yellow":
						ret = 0xffff00;
						break;
					case "green":
						ret = 0x00FF00;
						break;
					case "cyan":
						ret = 0x00ffff;
						break;
					case "blue":
						ret = 0x0000ff;
						break;
					case "purple":
						ret = 0xc000ff;
						break;
					case "niconicowhite":
					case "white2":
						ret = 0xcccc99;
						break;
					case "truered":
					case "red2":
						ret = 0xcc0033;
						break;
					case "orange2":
					case "orange2":
						ret = 0xff6600;
						break;
					case "madyellow":
					case "yellow2":
						ret = 0x999900;
						break;
					case "elementalgreen":
					case "green2":
						ret = 0x00cc66;
						break;
					case "marineblue":
					case "blue2":
						ret = 0x33fffc;
						break;
					case "nobleviolet":
					case "purple2":
						ret = 0x6633cc;
						break;
					case "black":
						ret = 0x000000;
						break;
					default:
						if(c.indexOf("#") != 0) break;
						ret = Number(c.split("#").join("0x"));
						break;
				}
			}
			return ret;
		}
		
		/**
		 * コメントサイズを変換
		 * 
		 * @param size 全コマンド
		 * @return 指定されたコメントサイズ
		 * 
		 */		
		private static function convertToSize(size:Array):Number{
			var comSize:Number = commentNormalSize || NicoConstants.COMMENT_NORMAL_SIZE;
			for(var s:String in size){
				//trace(size[s]);
				switch(size[s]){
					case "big":
						return commentBigSize || NicoConstants.COMMENT_BIG_SIZE;
					case "small":
						return commentSmallSize || NicoConstants.COMMENT_SMALL_SIZE;
				}
			}
			return comSize;
		}
		
		/**
		 * コメント位置の指定
		 *  
		 * @param position 全コマンド
		 * @return コメント位置情報
		 * 
		 */		
		private static function convertToStatic(position:Array):Number{
			var pos:Number = NicoConstants.COMMENT_POSITION_NORMAL;
			for(var p:String in position){
				//trace(position[p]);
				switch(position[p]){
					case "ue":
						pos = NicoConstants.COMMENT_POSITION_UE;
						break;
					case "shita":
						pos = NicoConstants.COMMENT_POSITION_SHITA;
						break;
				}
			}
			
			return pos;
		}
	}
}