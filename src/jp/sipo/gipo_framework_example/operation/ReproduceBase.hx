package jp.sipo.gipo_framework_example.operation;
/**
 * イベントの再生を担当する。
 * Gipoライブラリに編入を目指すこと
 * 
 * @auther sipo
 */
import haxe.ds.Option;
import haxe.ds.Option;
import jp.sipo.gipo_framework_example.operation.OperationHook.OperationHookEvent;
import jp.sipo.util.Copy;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo.core.GearHolderImpl;
class ReproduceBase<Phase> extends GearHolderImpl
{
	@:absorb
	private var operationHook:OperationHook;
	/* 記録ログ */
	private var recordLog:Array<LogPart<Phase>> = new Array<LogPart<Phase>>();
	/* 記録状態 */
	private var optionPhase:Option<Phase> = Option.None;
	
	// TODO:<<尾野>>記録と再生の内部分離
	
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * フェーズ切り替え
	 */
	public function startPhase(nextPhase:Phase):Void
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
	}
	
	/**
	 * イベントを記録する
	 */
	public function record(logway:HookEventLogway):Void
	{
		var phase:Phase = null;
		switch(optionPhase)
		{
			case Option.None : throw 'フェーズ中でなければ記録できません $optionPhase';
			case Option.Some(v) : phase = v;
		}
		var logPart:LogPart<Phase> = {phase:phase, frame:0, logway:logway};
		recordLog.push(Copy.deep(logPart));	// 速度を上げるためには場合分けしてもいい
		operationHook.input(OperationHookEvent.LogUpdate);
	}
	
	/**
	 * ログを返す
	 */
	public function getRecordLog():Array<LogPart<Phase>>
	{
		return recordLog;
	}
	
	/**
	 * 再生する
	 */
	public function replay(log:Array<LogPart<Phase>>):Void
	{
		trace(log);
	}
}
typedef LogPart<Phase> =
{
	/** 再現フェーズ */
	public var phase:Phase;
	/** 発生フレーム */
	public var frame:Int;
	/** ログ情報 */
	public var logway:HookEventLogway;
}
