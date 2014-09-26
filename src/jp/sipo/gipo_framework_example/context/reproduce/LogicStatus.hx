package jp.sipo.gipo_framework_example.context.reproduce;
/**
 * Logicのシーンを跨ぐデータと再現時の定義
 * 
 * @auther sipo
 */
import jp.sipo.gipo.reproduce.Snapshot;
class LogicStatus
{
	/** Mock1が表示された回数をカウントしておく */
	public var mock1Count:Int = 0;
	
	/** コンストラクタ */
	public function new() {}
	
	/**
	 * データを全て書き換える。再現時など
	 */
	public function setAll(target:LogicStatus):Void
	{
		mock1Count = target.mock1Count;
	}
}
/**
 * 再生を途中で開始するためのデータ
 * Logicでは重要な切り替わり部分は、このデータのみで全て同じように再現されるようにする。
 * LogicStatusを継承してあり、LogicStatusの部分は、データの書き換えに使用される。
 * 
 * @author sipo
 */
class SnapshotImpl extends LogicStatus implements Snapshot
{
	/** 種類と固有データ */
	public var kind:SnapshotKind;
	
	/** コンストラクタ */
	public function new(kind:SnapshotKind, logicStatus:LogicStatus) 
	{
		super();
		this.kind = kind;
		// シーンを跨ぐデータの全反映
		setAll(logicStatus);
	}
	
	/**
	 * 表示する場合の文字列を返す
	 * 形式は自由だが最初のほうで、どういったsnapShotか分かるのが望ましい
	 */
	public function getDisplayName():String
	{
		return Std.string(kind);
	}
}

/**
 * 再生を途中で開始するための個別データ
 * 開始される可能性のある箇所を網羅する。
 * 
 * @author sipo
 */
enum SnapshotKind
{
	/** 初期化 */
	Initialize;
	/** Mock1表示直前 */
	Mock1;
}
