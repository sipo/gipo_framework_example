package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.core.GearHolderImpl;
class OperationHook extends GearHolderImpl implements OperationHookForReproduce
{	
	@:absorb
	private var logic:OperationLogic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	
	/**
	 * 入力処理の発生
	 */
	public function input(event:OperationHookEvent):Void
	{
		logic.noticeEvent(event);
	}
}
