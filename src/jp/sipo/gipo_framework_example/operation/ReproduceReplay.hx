package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import Type;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo_framework_example.operation.LogPart;
import flash.Vector;
import jp.sipo.util.Note;
import GipoFrameworkExample.ExampleNoteTag;
import jp.sipo.gipo_framework_example.operation.LogWrapper;
import jp.sipo.gipo_framework_example.operation.Reproduce;
class ReproduceReplay<UpdateKind> extends StateGearHolderImpl implements ReproduceState<UpdateKind>
{
	@:absorb
	private var hook:HookForReproduce;
	
	/* フレームカウント */
	public var frame(default, null):Int = 0;
	/* 再生ログ */
	private var replayLog:ReplayLog<UpdateKind>;
	
	/* 再生可能かどうかの判定 */
	public var canProgress(default, null):Bool = true;
	/* 現在フレームで再現実行されるPart */
	private var nextLogPartList:Vector<LogPart<UpdateKind>> = new Vector<LogPart<UpdateKind>>();
	/* 非同期処理のうち通知が来たが、フレーム処理がまだであるもののリスト */
	private var aheadAsyncList:Vector<LogPart<UpdateKind>> = new Vector<LogPart<UpdateKind>>();
	/* 非同期処理のうちフレーム処理が先に来たが、通知がまだであるもののリスト */
	private var yetAsyncList:Vector<LogPart<UpdateKind>> = new Vector<LogPart<UpdateKind>>();
	
	private var note:Note;
	
	/** コンストラクタ */
	public function new(replayLog:ReplayLog<UpdateKind>) 
	{
		super();
		this.replayLog = replayLog;
	}
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		note = new Note([ExampleNoteTag.Reproduse]);
		replayLog.setPosition(0);
		// 起動時処理を擬似再現
		// FIXME:<<尾野>>タイミングが不安定なので、Reproduceにもらう
		// FIXME:<<尾野>>状況のNote表示
		frame = -1;
		update();
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		if (canProgress)
		{
			// ここに来た時は前フレームのリストは全て解消されているはず
			if (nextLogPartList.length != 0) throw '解消されていないLogPartが残っています $nextLogPartList';
			// 実行可能ならフレームを進める
			frame++;
			// 発生するイベントをリストアップする
			// このフレームで実行されるパートを取り出す
			var isYet:Bool = false;
			while(replayLog.hasNext() && replayLog.nextPartFrame == frame)
			{
				var part:LogPart<UpdateKind> = replayLog.next();
				// フレームで発生するモノリストに追加
				nextLogPartList.push(part);
				// 非同期イベントなら
				if (LogPart.isAsyncLogway(part.logway))
				{
					// 相殺を確認
					var setoff:Bool = compensate(part.phase, part.logway, aheadAsyncList);
					// 相殺できなければ待機リストへ追加
					if (!setoff)
					{
						yetAsyncList.push(part);
						isYet = true;
					}
				} 
			}
			// 未解決のものがあれば、次へ進めないとする
			canProgress = !isYet;
		}else{
			// 全ての未解決状態の非同期イベントが無くなれば進行可能状態とする
			canProgress = (yetAsyncList.length == 0);
		}
	}
	/* 対象の再生Partがリスト内と同じものがあるか確認し、あれば相殺してtrueを返す */
	private function compensate(phaseValue:ReproducePhase<UpdateKind>, logway:LogwayKind, list:Vector<LogPart<UpdateKind>>):Bool
	{
		for (i in 0...list.length)
		{
			var target:LogPart<UpdateKind> = list[i];
			if (target.isSameParam(phaseValue, logway))
			{
				list.splice(i, 1);	// リストから削除
				return true;
			}
		}
		// 対象が無ければfalse
		return false;
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(phaseValue:ReproducePhase<UpdateKind>, logway:LogwayKind):Void
	{
		// 非同期でなければ何もしない
		if (!LogPart.isAsyncLogway(logway)) return;
		// 停止中なら、yetListが存在するはずなので相殺をチェックする。実行中は相殺対象は無いはず。
		if (!canProgress)
		{
			// 相殺を確認
			var setoff:Bool = compensate(phaseValue, logway, yetAsyncList);
			// 相殺したなら追加しないでいい
			if (setoff) return;
		}
		// 相殺出来なかった場合は、aheadリストへ追加
		aheadAsyncList.push(new LogPart<UpdateKind>(phaseValue, frame, logway, -1));	// idはひとまず-1で
		// TODO:<<尾野>>余計なイベントが発生した場合、aheadに溜め込まれてしまう問題があるので、対策を検討
	}
	
	
	/**
	 * 切り替えの問い合わせ
	 */
	public function getChangeWay():ReproduceSwitchWay<UpdateKind>
	{
		return ReproduceSwitchWay.None;
	}
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<UpdateKind>):Void
	{
		if (!canProgress) return;
		// 再生予定リストを再生
		while (nextLogPartList.length != 0)
		{
			var part:LogPart<UpdateKind> = nextLogPartList[0];
			// phaseが一致しているもののみ
			if (!Type.enumEq(part.phase, phaseValue)) break;
			hook.executeEvent(part.logway);
			nextLogPartList.shift();
		}
	}
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<UpdateKind>
	{
		throw '記録状態の時のみ';
	}
}
