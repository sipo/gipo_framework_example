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

import haxe.PosInfos;
import jp.sipo.gipo_framework_example.operation.LogPart;
import jp.sipo.gipo_framework_example.context.reproduce.ExampleUpdateKind;
import jp.sipo.gipo_framework_example.operation.Reproduce;
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
	public function viewInstantInput(command:EnumValue, ?pos:PosInfos):Void;
	/** Viewからの非同期に発生するイベント */
	public function viewAsyncInput(command:EnumValue, factorPos:PosInfos):Void;
}
interface HookForLogic
{
	/** Logicからのデータの構成の状態 */
	public function logicSnapshot(snapshot:Snapshot, factorPos:PosInfos):Void;
}
interface HookForReproduce
{
	/** イベントの実行 */
	public function executeEvent(logWay:LogwayKind, factorPos:PosInfos):Void;
}
/* ================================================================
 * 実装
 * ===============================================================*/
class Hook extends GearHolderImpl implements HookForView implements HookForLogic implements HookForReproduce
{
	@:absorb
	private var logic:LogicForHook;
	@:absorbWithKey(TopDiffuseKey.ReproduceKey)
	private var reproduce:Reproduce<ExampleUpdateKind>;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/* ================================================================
	 * View向けのメソッド
	 * ===============================================================*/
	
	public function viewInstantInput(command:EnumValue, ?pos:PosInfos):Void
	{
		reproduce.noticeLog(LogwayKind.Instant(command), pos);
	}
	
	public function viewAsyncInput(command:EnumValue, factorPos:PosInfos):Void
	{
		reproduce.noticeLog(LogwayKind.Async(command), factorPos);
	}
	
	/* ================================================================
	 * Logic向けのメソッド
	 * ===============================================================*/
	
	public function logicSnapshot(snapshot:Snapshot, factorPos:PosInfos):Void
	{
		// Reproduceに通知して処理を仰ぐ
		reproduce.noticeLog(LogwayKind.Snapshot(snapshot), factorPos);
	}
	
	
	/* ================================================================
	 * Reproduce向けのメソッド
	 * ===============================================================*/
	
	/**
	 * イベントの実行
	 */
	public function executeEvent(logWay:LogwayKind, factorPos:PosInfos):Void
	{
		switch (logWay)
		{
			case LogwayKind.Instant(command) :
				// イベントの実行
				logic.noticeEvent(command, factorPos);
			case LogwayKind.Async(command) : 
				// イベントの実行
				logic.noticeEvent(command, factorPos);
			case LogwayKind.Snapshot(value) :
				// イベントの実行
				logic.setSnapshot(value, factorPos);
		}
	}
}













