package jp.sipo.gipo_framework_example.operation;
/**
 * イベントの再生を担当する。
 * Gipoライブラリに編入を目指すこと
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.state.StateGearHolder;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.operation.LogPart;
import jp.sipo.gipo_framework_example.context.Hook;
import flash.Vector;
import jp.sipo.gipo_framework_example.operation.LogWrapper;
import GipoFrameworkExample.ExampleNoteTag;
import jp.sipo.util.Note;
import haxe.ds.Option;
import haxe.ds.Option;
import haxe.ds.Option;
import jp.sipo.gipo_framework_example.operation.OperationHook;
import jp.sipo.util.Copy;
import jp.sipo.gipo.core.GearHolderImpl;
class Reproduce<UpdateKind> extends StateSwitcherGearHolderImpl<ReproduceState<UpdateKind>>
{
	@:absorb
	private var operationHook:OperationHook;
	@:absorb
	private var hook:HookForReproduce;
	/* 記録フェーズ */
	private var phase:Option<ReproducePhase<UpdateKind>> = Option.None;
	
	
	private var note:Note;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		note = new Note([ExampleNoteTag.Reproduse]);
		tool.diffuse(note, Note);
	}
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		stateSwitcherGear.changeState(new ReproduceRecord<UpdateKind>());
	}
	
	/**
	 * 再生可能かどうかを問い合わせる
	 */
	public function getCanProgress():Bool
	{
		return state.canProgress;
	}
	
	/**
	 * 更新
	 */
	public function update():Void
	{
		state.update();
	}
	
	/**
	 * フレーム間のフェーズ切り替え
	 */
	public function startOutFramePhase():Void
	{
		startPhase(ReproducePhase.OutFrame);
	}
	/**
	 * フレーム内のフェーズ切り替え
	 */
	public function startInFramePhase(updateKind:UpdateKind):Void
	{
		startPhase(ReproducePhase.InFrame(updateKind));
	}
	/* フェーズ切り替え共通動作 */
	private function startPhase(nextPhase:ReproducePhase<UpdateKind>):Void
	{
		switch(phase)
		{
			case Option.None : this.phase = Option.Some(nextPhase);	// 新しいPhaseに切り替える
			case Option.Some(v) : throw '前回のフェーズが終了していません $v->$nextPhase';
		}
	}
	
	
	
	/**
	 * イベントの発生を受け取る
	 */
	public function noticeLog(logway:LogwayKind, factorPos:PosInfos):Void
	{
		var phaseValue:ReproducePhase<UpdateKind> = switch(phase)
		{
			case Option.None : throw 'フェーズ中でなければ記録できません $phase';
			case Option.Some(v) : v;
		}
		// メイン処理
		state.noticeLog(phaseValue, logway, factorPos);
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
		var phaseValue:ReproducePhase<UpdateKind> =switch(phase)
		{
			case Option.None : throw '開始していないフェーズを終了しようとしました $phase';
			case Option.Some(value) : value;
		}
		// meanTimeの時は、ここから再生モードに移行する可能性を調べる
		var phaseIsOutFrame:Bool = switch (phaseValue)
		{
			case ReproducePhase.OutFrame : true;
			case ReproducePhase.InFrame : false;
		}
		if (phaseIsOutFrame)
		{
			// 必要ならReplayへ以降
			var stateSwitchWay:ReproduceSwitchWay<UpdateKind> = state.getChangeWay();
			switch (stateSwitchWay)
			{
				case ReproduceSwitchWay.None :
				case ReproduceSwitchWay.ToReplay(log) : stateSwitcherGear.changeState(new ReproduceReplay(log));
			}
		}
		// メイン処理
		state.endPhase(phaseValue);
		// フェーズを無しに
		phase = Option.None;
	}
	
	
	/**
	 * ログを返す
	 */
	public function getRecordLog():RecordLog<UpdateKind>
	{
		return state.getRecordLog();
	}
	
	/**
	 * 再生状態に切り替える
	 */
	public function startReplay(log:ReplayLog<UpdateKind>, logIndex:Int):Void
	{
		note.log('replayStart($logIndex) $log');
		log.setPosition(logIndex);
		stateSwitcherGear.changeState(new ReproduceReplay(log));
	}
}
interface ReproduceState<UpdateKind> extends StateGearHolder
{
	/* フレームカウント */
	public var frame(default, null):Int;
	/* フレーム処理実行可能かどうかの判定 */
	public var canProgress(default, null):Bool;
	
	/**
	 * 更新処理
	 */
	public function update():Void;
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(phaseValue:ReproducePhase<UpdateKind>, logway:LogwayKind, factorPos:PosInfos):Void;
	
	/**
	 * 切り替えの問い合わせ
	 */
	public function getChangeWay():ReproduceSwitchWay<UpdateKind>;
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<UpdateKind>):Void;
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<UpdateKind>;
}
enum ReproduceSwitchWay<UpdateKind>
{
	None;
	ToReplay(replayLog:ReplayLog<UpdateKind>);
}
