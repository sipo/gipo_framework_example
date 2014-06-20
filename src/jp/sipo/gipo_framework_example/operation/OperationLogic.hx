package jp.sipo.gipo_framework_example.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.Reproduce.LogPart;
import haxe.Serializer;
import jp.sipo.util.HandlerUtil;
import flash.events.Event;
import flash.net.FileReference;
import jp.sipo.util.Copy;
import jp.sipo.gipo_framework_example.operation.OperationHook.OperationHookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
interface OperationPeek
{
	
}
class OperationLogic extends GearHolderImpl
{
	@:absorb
	private var operationView:OperationView;
	@:absorb
	private var reproduce:Reproduce;
	
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * OperationLogicそのものに対するイベント発生
	 */
	public function noticeEvent(event:OperationHookEvent):Void
	{
		trace('stb OperationLogic noticeEvent($event)');
		switch (event)
		{
			case OperationHookEvent.LogUpdate : operationView.updateLog(reproduce.getRecordLog().length);
			case OperationHookEvent.LocalSave : localSave();
			case OperationHookEvent.LocalLoad :  localLoad();// TODO:ローカル読み込み処理
		}
	}
	
	/* ローカルデータに保存 */
	private function localSave():Void
	{
		var fileReference:FileReference = new FileReference();
		var dataString:String = Serializer.run(reproduce.getRecordLog());
		var date:Date = Date.now();
		var milliSecond:String = StringTools.lpad(Std.string((date.getTime() % 1000)),"0",3);
		var dateString:String = DateTools.format(date, "%Y_%m_%d_%H_%M_%S_") + milliSecond;
		fileReference.save(dataString, 'log_${dateString}.txt');
	}
	
	/* ローカルデータから呼び出し */
	private function localLoad():Void
	{
		var fileReference:FileReference = new FileReference();
		HandlerUtil.once(fileReference, Event.SELECT, function (event:Event){
			// http://www.sousakuba.com/weblabo/actionscript-filereference.html
		});
		// TODO:ローカル保存処理
		
		
//		fileReference.addEventListener(Event.COMPLETE, completeHandler);
//		var completeHandler:Dynamic -> Void = function ()
//		{
//			
//		};
	}
}
/**
 * 保存用データ形式。後でライブラリ側に移動する
 * 
 * @author sipo
 */
typedef ReproduceFile =
{
	/** log */
	public var reproduceLog:Array<LogPart>;
}
