package jp.sipo.gipo_framework_example.operation;
/**
 * 再生を途中で開始するためのデータ
 * Logicでは重要な切り替わり部分は、SnapshotKindのデータのみで全て同じように再現されるようにする。
 * 
 * @auther sipo
 */
interface Snapshot
{
	/**
	 * 表示する場合の文字列を返す
	 * 形式は自由だが最初のほうで、どういったsnapShotか分かるのが望ましい
	 */
	public function getDisplayName():String;
}
// TODO:<<尾野>>共通へ編入
