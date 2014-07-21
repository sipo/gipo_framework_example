package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.ReproduceBase.LogPart;
class ReproduceLog<UpdateKind>
{
	private var list = new Array<LogPart<UpdateKind>>();
	
	/** コンストラクタ */
	public function new() {  }
	
	/**
	 * 追加する
	 */
	public function add(logPart:LogPart<UpdateKind>):Void
	{
		list.push(logPart);
	}
	
	/**
	 * 長さを返す
	 */
	public function getLength():Int
	{
		return list.length;
	}
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[ReproduceLog $list]';
	}
}
