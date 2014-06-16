package jp.sipo.gipo_framework_example.etc;
/**
 * Logicを特定の状態にするための命令
 * 
 * @auther sipo
 */
import jp.sipo.util.Copy;
import jp.sipo.gipo_framework_example.context.LogicStatus;
class Snapshot
{
	/** 種類と個別変数 */
	public var kind:SnapshotKind;
	/** 種類と個別変数 */
	public var logicStatus:LogicStatus;
	
	// 共通の変数、例えば全体データの指定などはここに持つ
	
	/** コンストラクタ */
	public function new(kind:SnapshotKind, logicStatus:LogicStatus) 
	{
		this.kind = kind;
		this.logicStatus = logicStatus;
	}
	
}
enum SnapshotKind
{
	/** 初期化 */
	Initialize;
	/** Mock1表示直前 */
	Mock1;
}
