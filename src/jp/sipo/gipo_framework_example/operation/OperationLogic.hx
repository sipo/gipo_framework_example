package jp.sipo.gipo_framework_example.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.context.reproduce.ExampleUpdateKind;
import jp.sipo.util.Note;
import jp.sipo.gipo_framework_example.context.Top.TopDiffuseKey;
import String;
import flash.utils.ByteArray;
import jp.sipo.gipo_framework_example.operation.ReproduceBase;
import haxe.Serializer;
import jp.sipo.util.HandlerUtil;
import flash.events.Event;
import flash.net.FileReference;
import jp.sipo.util.Copy;
import jp.sipo.gipo_framework_example.operation.OperationHook.OperationHookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
import haxe.Unserializer;
interface OperationPeek
{
	
}
class OperationLogic extends GearHolderImpl
{
	@:absorb
	private var operationView:OperationView;
	@:absorbWithKey(TopDiffuseKey.ReproduceKey)
	private var reproduce:ReproduceBase<ExampleUpdateKind>;
	
	
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
		switch (event)
		{
			case OperationHookEvent.LogUpdate : 
			{
				var reproduceLog:ReproduceLog<Dynamic> = reproduce.getRecordLog();
				operationView.updateLog(reproduceLog.getLength());
			}
			case OperationHookEvent.LocalSave : localSave();
			case OperationHookEvent.LocalLoad :  localLoad();
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
			afterLoadFile(fileReference.data);
		});
		fileReference.browse();
	}
	
	/* ファイルデータ取得後 */
	private function afterLoadFile(fileData:ByteArray):Void
	{
		// バイナリを文字列に変換
		fileData.position = 0;
		var dataString:String = fileData.readUTFBytes(fileData.length);
		// データを解析
		var reproduceFile:ReproduceFile = Unserializer.run(dataString);
		var reproduceFileCopy:ReproduceFile = Unserializer.run(dataString);
		// バイナリデータは消しておく
		fileData.clear();
		operationView.displayFile(reproduceFileCopy);
		// リプレイを開始
//			reproduce.replay(reproduceFile.reproduceLog);
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
	public var reproduceLog:ReproduceLog<ExampleUpdateKind>;
}
