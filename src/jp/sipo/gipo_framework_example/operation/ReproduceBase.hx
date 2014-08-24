package jp.sipo.gipo_framework_example.operation;
/**
 * イベントの再生を担当する。
 * Gipoライブラリに編入を目指すこと
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.ReproduceLog;
import GipoFrameworkExample.NoteTag;
import jp.sipo.util.Note;
import haxe.ds.Option;
import haxe.ds.Option;
import haxe.ds.Option;
import jp.sipo.gipo_framework_example.operation.OperationHook.OperationHookEvent;
import jp.sipo.util.Copy;
import jp.sipo.gipo.core.GearHolderImpl;
class ReproduceBase<UpdateKind> extends GearHolderImpl
{
	@:absorb
	private var operationHook:OperationHook;
	/* 記録ログ */
	private var recordLog:ReproduceLog<UpdateKind> = new ReproduceLog<UpdateKind>();
	/* 記録状態 */
	private var phase:Option<ReproducePhase<UpdateKind>> = Option.None;
	
	/* フレームカウント */
	private var frame:Int = 0;
	/* 再生ログ */
	private var replayLog:Option<ReproduceLog<UpdateKind>> = Option.None;
	
	var note:Note;
	
	// TODO:<<尾野>>記録と再生の内部分離
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		note = new Note([NoteTag.Reproduse]);
	}
	
	/**
	 * フェーズ切り替え
	 */
	public function startPhase(nextPhase:ReproducePhase<UpdateKind>):Void
	{
		switch(phase)
		{
			case Option.None : this.phase = Option.Some(nextPhase);	// 新しいPhaseに切り替える
			case Option.Some(v) : throw '前回のフェーズが終了していません $v->$nextPhase';
		}
	}
	
	/**
	 * フェーズ終了
	 */
	public function endPhase():Void
	{
		switch(phase)
		{
			case Option.None : throw '開始していないフェーズを終了しようとしました $phase';
			case Option.Some(_) : // 特になし
		}
		// TODO:<<尾野>>[reploduce]再生状態ならここでログを再生するかチェック
		// メモ：再生入力もHook経由で記録される
		phase = Option.None;
	}
	
	/**
	 * 更新
	 */
	public function update():Void
	{
		frame++;
	}
	
	/**
	 * イベントを記録する
	 */
	public function record(logway:LogwayKind):Void
	{
		var phaseValue:ReproducePhase<UpdateKind> = null;
		switch(phase)
		{
			case Option.None : throw 'フェーズ中でなければ記録できません $phase';
			case Option.Some(v) : phaseValue = v;
		}
		var logPart:LogPart<UpdateKind> = new LogPart<UpdateKind>(phaseValue, frame, logway);
		recordLog.add(Copy.deep(logPart));	// 速度を上げるためには場合分けしてもいい
		operationHook.input(OperationHookEvent.LogUpdate);
	}
	
	/**
	 * ログを返す
	 */
	public function getRecordLog():ReproduceLog<UpdateKind>
	{
		return recordLog;
	}
	
	/**
	 * 再生する
	 */
	public function replay(log:ReproduceLog<UpdateKind>):Void
	{
		note.log(log);
		replayLog = Option.Some(log);
	}
}
