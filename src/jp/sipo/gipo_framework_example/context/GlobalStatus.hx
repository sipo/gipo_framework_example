package jp.sipo.gipo_framework_example.context;
/**
 * 全体処理変数
 * 
 * @auther sipo
 */
import haxe.ds.Option;
// TODO:<<尾野>>GlobalStatusは不必要？GlobalContextならわかる
class GlobalStatus
{
	/** 画面基本サイズ */
	inline public static var stageWidth:Int = 480;
	inline public static var stageHEIGHT:Int = 720;
	
	/** 可変画面サイズ */
	public var screenSize:Option<{width:Int, height:Int}> = Option.None;
	
	/** コンストラクタ */
	public function new() 
	{
	}
}
