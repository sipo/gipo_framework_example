package jp.sipo.gipo_framework_example.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import haxe.ds.Option;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo_framework_example.context.reproduce.ExampleUpdateKind;
import jp.sipo.gipo_framework_example.context.Top;
import String;
import flash.utils.ByteArray;
import jp.sipo.gipo.reproduce.Reproduce;
import haxe.Serializer;
import jp.sipo.util.HandlerUtil;
import flash.events.Event;
import flash.net.FileReference;
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
	private var reproduce:Reproduce<ExampleUpdateKind>;
	
	/* 最後に読み込んだログ */
	private var loadFile:Option<RecordLog<ExampleUpdateKind>> = Option.None;
	
	
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
				var reproduceLog:RecordLog<Dynamic> = reproduce.getRecordLog();
				operationView.updateLog(reproduceLog.getLength());
			}
			case OperationHookEvent.LocalSave : localSave();
			case OperationHookEvent.LocalLoad :  localLoad();
			case OperationHookEvent.StartReplay(logIndex) :  startReplay(logIndex);
		}
	}
	
	/* ローカルデータに保存 */
	private function localSave():Void
	{
		var fileReference:FileReference = new FileReference();
		var recordLog:RecordLog<ExampleUpdateKind> = reproduce.getRecordLog();
		var dataString:String = Serializer.run(recordLog);
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
		var reproduceFile:RecordLog<ExampleUpdateKind> = Unserializer.run(dataString);
		var replayLog:ReplayLog<ExampleUpdateKind> = reproduceFile.convertReplay();
		// バイナリデータは消しておく
		fileData.clear();
		// メンバ変数に保持
		loadFile = Option.Some(reproduceFile);
		// コンボボックスに入れるために、snapshotだけを取り出す
		operationView.displayFile(replayLog.createDisplaySnapshotList());
	}
	
	/* リプレイの開始命令 */
	private function startReplay(logIndex:Int):Void
	{
		var reproduceFile:RecordLog<ExampleUpdateKind> = switch(loadFile)
		{
			case Option.None : throw '開始するデータがロードされていません';
			case Option.Some(v) : v;
		}
		// リプレイを開始
		reproduce.startReplay(reproduceFile.convertReplay(), logIndex); 
	}
	
	
	
}
