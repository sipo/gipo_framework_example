package jp.sipo.gipo_framework_example.operation;
/**
 * イベントの再生を担当する。
 * Gipoライブラリに編入を目指すこと
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.context.Hook;
import flash.Vector;
import jp.sipo.gipo_framework_example.operation.ReproduceLog;
import GipoFrameworkExample.NoteTag;
import jp.sipo.util.Note;
import haxe.ds.Option;
import haxe.ds.Option;
import haxe.ds.Option;
import jp.sipo.gipo_framework_example.operation.OperationHook;
import jp.sipo.util.Copy;
import jp.sipo.gipo.core.GearHolderImpl;
class ReproduceBase<UpdateKind> extends GearHolderImpl
{
	@:absorb
	private var operationHook:OperationHook;
	@:absorb
	private var hook:HookForReproduce;
	/* 記録ログ */
	private var recordLog:ReproduceLog<UpdateKind> = new ReproduceLog<UpdateKind>();
	/* 記録状態 */
	private var phase:Option<ReproducePhase<UpdateKind>> = Option.None;
	
	/* フレームカウント */
	private var frame:Int = 0;
	/* 再生ログ */
	private var replayLog:Option<ReproduceLog<UpdateKind>> = Option.None;
	
	/* 記録・再生状態 */
	private var mode:ReproduceMode = ReproduceMode.Record;
	/* 再生時、次に再生するログの番号 */
	private var replayIndex:Int = 0;
	
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
	 * イベントを記録する
	 */
	public function record(logway:LogwayKind):Void
	{
		var phaseValue:ReproducePhase<UpdateKind> = switch(phase)
		{
			case Option.None : throw 'フェーズ中でなければ記録できません $phase';
			case Option.Some(v) : v;
		}
		var logPart:LogPart<UpdateKind> = new LogPart<UpdateKind>(phaseValue, frame, logway);
		// 全体記録
		recordLog.add(Copy.deep(logPart));	// 速度を上げるためには場合分けしてもいい
		// 記録が更新されたことをOperationの表示へ通知
		operationHook.input(OperationHookEvent.LogUpdate);
		// 実行
		switch(mode)
		{
			case ReproduceMode.Record:	hook.executeEvent(logway);	// 実行する
			case ReproduceMode.Replay:	// リプレイ時はここからのイベントは止める
		}
		
	}
	
	// MEMO:フェーズ終了で実行されるのはリプレイの時のみで、通常動作時は、即実行される
	/*
	理由
	確かに、両方共endにしておくことで、統一性が担保されるが、
	・コマンドに起因して更にコマンドが発生する場合に問題になる。
	・コマンドを受け取ったLogicがViewにボタンの無効命令を出しても間に合わない
	・スタックトレースが悪化する
	といったデメリットがある。
	それに対して、通常時にendでないタイミングで発生する場合でも、少し不安な程度で、
	順序は確保され、ViewからのLogicへのデータはロックされているはずなので明確なデメリットは無いはず
	 */
	
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
		// 再生状態ならここでログを再生するかチェック
		switch(mode)
		{
			case ReproduceMode.Record:	// 特に何もない
			case ReproduceMode.Replay: replayLog();	// ログの再生
		}
		// FIXME:<<尾野>>古い仕様
		// コマンド実行中にコマンドのスタックが増える可能性があるので、
//		while(0 < phaseRecord.length)
//		{
//			var tmpPhaseRecord:Vector<LogPart<UpdateKind>> = phaseRecord;
//			// フェーズ単位のログをクリア
//			phaseRecord = new Vector<LogPart<UpdateKind>>();
//			for (i in 0...tmpPhaseRecord.length)
//			{
//				// 実行
//				hook.executeEvent(tmpPhaseRecord[i].logway);
//			}
//		}
		// フェーズを無しに
		phase = Option.None;
	}
	/* ログの再生 */
	private function replayLog():Void
	{
		replayLog
	}
	
	/**
	 * 更新
	 */
	public function update():Void
	{
		frame++;
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
	public function replay(log:ReproduceLog<UpdateKind>, logIndex:Int):Void
	{
		note.log('replayStart($logIndex) $log');
		replayLog = Option.Some(log);
		// FIXME:<<尾野>>未実装
	}
}
/**
 * 記録状態
 **/
enum ReproduceMode
{
	/* 記録中 */
	Record;
	/* 再生中 */
	Replay;
}
