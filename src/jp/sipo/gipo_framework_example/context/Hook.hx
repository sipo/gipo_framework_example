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

import jp.sipo.gipo_framework_example.operation.LogPart;
import jp.sipo.gipo_framework_example.context.reproduce.ExampleUpdateKind;
import jp.sipo.gipo_framework_example.operation.ReproduceBase;
import jp.sipo.gipo_framework_example.context.Top.TopDiffuseKey;
import jp.sipo.gipo_framework_example.operation.Snapshot;
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
interface HookForReproduce
{
	/** イベントの実行 */
	public function executeEvent(logWay:LogwayKind):Void;
}
/* ================================================================
 * 実装
 * ===============================================================*/
class Hook extends GearHolderImpl implements HookForView implements HookForLogic implements HookForReproduce
{
	@:absorb
	private var logic:LogicForHook;
	@:absorbWithKey(TopDiffuseKey.ReproduceKey)
	private var reproduce:ReproduceBase<ExampleUpdateKind>;
	
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
		recordEvent(LogwayKind.Input(command));
	}
	
	public function viewReady(command:EnumValue):Void
	{
		recordEvent(LogwayKind.Ready(command));
	}
	
	/* ================================================================
	 * Logic向けのメソッド
	 * ===============================================================*/
	
	public function logicSnapshot(snapshot:Snapshot):Void
	{
		recordEvent(LogwayKind.Snapshot(snapshot));
	}
	
	/* ================================================================
	 * 内部処理
	 * ===============================================================*/
	 
	/**
	 * イベントの実行を処理
	 */
	private function recordEvent(logWay:LogwayKind):Void
	{
		// 発生イベントの登録
		reproduce.record(logWay);
	}
	
	/* ================================================================
	 * Reproduce向けのメソッド
	 * ===============================================================*/
	
	/**
	 * イベントの実行
	 */
	public function executeEvent(logWay:LogwayKind):Void
	{
		switch (logWay)
		{
			case LogwayKind.Input(command) :
				// イベントの実行
				logic.noticeEvent(command);
			case LogwayKind.Ready(command) : 
				// TODO:readyを待つ処理
				// イベントの実行
				logic.noticeEvent(command);
			case LogwayKind.Snapshot(value) :
				// イベントの実行
				logic.setSnapshot(value);
		}
	}
}













