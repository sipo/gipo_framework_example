package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo_framework_example.operation.OperationHook;
import jp.sipo.gipo_framework_example.operation.LogPart;
import jp.sipo.util.Note;
import GipoFrameworkExample.ExampleNoteTag;
import jp.sipo.gipo_framework_example.operation.LogWrapper;
import jp.sipo.gipo_framework_example.operation.Reproduce;
class ReproduceRecord<UpdateKind> extends StateGearHolderImpl implements ReproduceState<UpdateKind>
{
	@:absorb
	private var operationHook:OperationHook;
	@:absorb
	private var hook:HookForReproduce;
	/* フレームカウント */
	public var frame(default, null):Int = 0;
	/* 再生可能かどうかの判定 */
	public var canProgress(default, null):Bool = true;
	/* 記録ログ */
	private var recordLog:RecordLog<UpdateKind> = new RecordLog<UpdateKind>();
	
	private var note:Note;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		note = new Note([ExampleNoteTag.Reproduse]);
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		frame++;
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(phaseValue:ReproducePhase<UpdateKind>, logway:LogwayKind):Void
	{
		// 非同期イベントが、updatePhase内で発生したら警告
		if (LogPart.isAsyncLogway(logway) && !LogPart.isMeantimePhase(phaseValue)) throw "非同期イベントは、updateタイミングで発生してはいけません。（再現時の待機に問題が出るため）。meantimeUpdate等の関数で発生するようにしてください。";
		// 記録に追加
		recordLog.add(phaseValue, frame, logway);
		// 記録が更新されたことをOperationの表示へ通知
		operationHook.input(OperationHookEvent.LogUpdate);
		// 実行する
		hook.executeEvent(logway);
	}
	
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<UpdateKind>):Void
	{
		// 特になし
	}
	
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<UpdateKind>
	{
		return recordLog;
	}
}
