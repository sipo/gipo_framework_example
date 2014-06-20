package jp.sipo.gipo_framework_example.operation;
/**
 * イベントの再生を担当する。
 * Gipoライブラリに編入を目指すこと
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.OperationHook.OperationHookEvent;
import jp.sipo.util.Copy;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo.core.GearHolderImpl;
class Reproduce extends GearHolderImpl
{
	@:absorb
	private var operationHook:OperationHook;
	/* 記録ログ */
	private var recordLog:Array<LogPart> = new Array<LogPart>();
	/* 記録状態 */
	private var phase:ReproducePhase = ReproducePhase.None;
	
	// TODO:<<尾野>>記録と再生の内部分離
	
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * フェーズ切り替え
	 */
	public function startPhase(nextPhase:ReproducePhase):Void
	{
		if (!Type.enumEq(phase, ReproducePhase.None)) throw '前回のフェーズが終了していません $phase->$nextPhase';
		this.phase = nextPhase;
	}
	
	/**
	 * フェーズ終了
	 */
	public function endPhase():Void
	{
		if (Type.enumEq(phase, ReproducePhase.None)) throw '開始していないフェーズを終了しようとしました $phase';
		// TODO:<<尾野>>[reploduce]再生状態ならここでログを再生するかチェック
		// メモ：再生入力もHook経由で記録される
		phase = ReproducePhase.None;
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
		if (Type.enumEq(phase, ReproducePhase.None)) throw 'フェーズ中でなければ記録できません $phase';
		var logPart:LogPart = {phase:phase, frame:0, logway:logway};
		recordLog.push(Copy.deep(logPart));	// 速度を上げるためには場合分けしてもいい
		operationHook.input(OperationHookEvent.LogUpdate);
	}
	
	/**
	 * ログを返す
	 */
	public function getRecordLog():Array<LogPart>
	{
		return recordLog;
	}
}
typedef LogPart =
{
	/** 再現フェーズ */
	public var phase:ReproducePhase;
	/** 発生フレーム */
	public var frame:Int;
	/** ログ情報 */
	public var logway:HookEventLogway;
}
