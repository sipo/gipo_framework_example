package jp.sipo.gipo_framework_example.context;
/**
 * 各セクションからのイベントをロジックに伝える
 * MVCで言うところのC
 * データの保存と再現も担当する（予定）
 * 
 * Hookイベントの種類
 * 	Input
 * 		ユーザー入力等、基本的なイベント
 * 		入力情報は、再現データから瞬時に復元できるものである必要がある（外部ファイルとかを読む必要が無い）
 * 	Ready
 * 		データの読み込みなど、非同期であったり、終了時間が読めないイベント
 * 		GPUへの非同期な準備や、必要データの非同期な展開などもこれに含む。
 * 		再現時には、Logicのほうがセクションに合わせて停止する必要がある。
 * 		
 * 	※イベントの発生がセクションに依存し、かつそれがフレーム進行を必要とするものは、対応できない。
 * 	例えば、表示演出などは、仮にその演出が途中で、ボタンが画面に無くともボタンの入力イベントに対応しなければいけない。
 * 	
 * 
 * @auther sipo
 */

import jp.sipo.gipo_framework_example.operation.ReproducePhase;
import jp.sipo.gipo_framework_example.operation.Reproduce;
import jp.sipo.gipo_framework_example.etc.Snapshot;
import jp.sipo.gipo_framework_example.context.Logic.LogicForHook;
import jp.sipo.gipo.core.GearHolderImpl;
/* ================================================================
 * インターフェース
 * ===============================================================*/
interface HookForView
{
	/** Viewからの即時発行できる入力イベント */
	public function viewInput(command:EnumValue):Void;
	/** Viewからの非同期に発生するイベント */
	public function viewReady(command:EnumValue):Void;
}
interface HookForLogic
{
	/** Logicからのデータの構成の状態 */
	public function logicSnapshot(snapshot:Snapshot):Void;
}
/* ================================================================
 * 実装
 * ===============================================================*/
class Hook extends GearHolderImpl implements HookForView implements HookForLogic
{
	@:absorb
	private var logic:LogicForHook;
	@:absorb
	private var reproduce:Reproduce;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/* ================================================================
	 * View向けのメソッド
	 * ===============================================================*/
	
	public function viewInput(command:EnumValue):Void
	{
		executeEvent(HookEventLogway.Input(command));
	}
	
	public function viewReady(command:EnumValue):Void
	{
		executeEvent(HookEventLogway.Ready(command));
	}
	
	/* ================================================================
	 * Logic向けのメソッド
	 * ===============================================================*/
	
	public function logicSnapshot(snapshot:Snapshot):Void
	{
		executeEvent(HookEventLogway.Snapshot(snapshot));
	}
	
	/* ================================================================
	 * 内部処理
	 * ===============================================================*/
	 
	/**
	 * イベントの実行を処理
	 */
	private function executeEvent(logWay:HookEventLogway):Void
	{
		switch (logWay)
		{
			case HookEventLogway.Input(command) :
				// 発生イベントの登録
				reproduce.record(logWay);
				// イベントの実行
				logic.noticeEvent(command);
			case HookEventLogway.Ready(command) : 
				// TODO:readyを待つ処理
				// 発生イベントの登録
				reproduce.record(logWay);
				// イベントの実行
				logic.noticeEvent(command);
			case HookEventLogway.Snapshot(value) :
				// 発生イベントの登録
				reproduce.record(logWay); 
				// イベントの実行
				logic.setSnapshot(value);
		}
	}
}

/**
 * Logの記録と再生方法の種類
 */
enum HookEventLogway
{
	/** 対象タイミングで実行 */
	Input(command:EnumValue);
	/** 対象タイミングで準備が整うまで全体を待たせる（処理時間が不明瞭な動作） */
	Ready(command:EnumValue);
	/** Logicを生成するのに必要。再生の最初のほか、途中再開にも使用できる */
	Snapshot(value:Snapshot);
}














