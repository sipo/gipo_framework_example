package jp.sipo.gipo_framework_example.operation;
/**
 * イベントの再生を担当する。
 * Gipoライブラリに編入を目指すこと
 * 
 * @auther sipo
 */
import GipoFrameworkExample.NoteTag;
import jp.sipo.util.Note;
import haxe.ds.Option;
import haxe.ds.Option;
import haxe.ds.Option;
import jp.sipo.gipo_framework_example.operation.OperationHook.OperationHookEvent;
import jp.sipo.util.Copy;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo.core.GearHolderImpl;
class ReproduceBase<UpdateKind> extends GearHolderImpl
{
	@:absorb
	private var operationHook:OperationHook;
	/* 記録ログ */
	private var recordLog:ReproduceLog<UpdateKind> = new ReproduceLog<UpdateKind>();
	/* 記録状態 */
	private var optionPhase:Option<ReproducePhase<UpdateKind>> = Option.None;
	
	/* フレームカウント */
	private var frame:Int = 0;
	/* 再生ログ */
	private var optionReplayLog:Option<ReproduceLog<UpdateKind>> = Option.None;
	
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
		switch(optionPhase)
		{
			case Option.None : this.optionPhase = Option.Some(nextPhase);	// 新しいPhaseに切り替える
			case Option.Some(v) : throw '前回のフェーズが終了していません $v->$nextPhase';
		}
	}
	
	/**
	 * フェーズ終了
	 */
	public function endPhase():Void
	{
		switch(optionPhase)
		{
			case Option.None : throw '開始していないフェーズを終了しようとしました $optionPhase';
			case Option.Some(_) : // 特になし
		}
		// TODO:<<尾野>>[reploduce]再生状態ならここでログを再生するかチェック
		// メモ：再生入力もHook経由で記録される
		optionPhase = Option.None;
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
	public function record(logway:HookEventLogway):Void
	{
		var phase:ReproducePhase<UpdateKind> = null;
		switch(optionPhase)
		{
			case Option.None : throw 'フェーズ中でなければ記録できません $optionPhase';
			case Option.Some(v) : phase = v;
		}
		var logPart:LogPart<UpdateKind> = new LogPart<UpdateKind>(phase, frame, logway);
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
		optionReplayLog = Option.Some(log);
	}
}
class LogPart<UpdateKind>
{
	/** 再現フェーズ */
	public var phase:ReproducePhase<UpdateKind>;
	/** 発生フレーム */
	public var frame:Int;
	/** ログ情報 */
	public var logway:HookEventLogway;
	
	/** コンストラクタ */
	public function new(phase:ReproducePhase<UpdateKind>, frame:Int, logway:HookEventLogway) 
	{
		this.phase = phase;
		this.frame = frame;
		this.logway = logway;
	}
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[LogPart phase=$phase frame=$frame logway=$logway]';
	}
}
