package jp.sipo.gipo_framework_example.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import String;
import flash.utils.ByteArray;
import jp.sipo.gipo_framework_example.operation.ReproduceBase.LogPart;
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
		var reproduceFile:ReproduceFile = {reproduceLog:reproduce.getRecordLog()};
		var dataString:String = Serializer.run(reproduceFile);
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
			fileReference.load();
		});
		HandlerUtil.once(fileReference, Event.COMPLETE, function (event:Event){
			localLoadParse(fileReference.data);
		});
		fileReference.browse();
		
		// http://www.sousakuba.com/weblabo/actionscript-filereference.html
		
//		fileReference.addEventListener(Event.COMPLETE, completeHandler);
//		var completeHandler:Dynamic -> Void = function ()
//		{
//			
//		};
	}
	private function localLoadParse(data:ByteArray):Void
	{
		data.position = 0;
		var dataString:String = data.readUTFBytes(data.length);
		var reproduceFile:ReproduceFile = haxe.Unserializer.run(dataString);
		data.clear();
		reproduce.replay(reproduceFile.reproduceLog);
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
	public var reproduceLog:Array<LogPart<ReproducePhase>>;
}
