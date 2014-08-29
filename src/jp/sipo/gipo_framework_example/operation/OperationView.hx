package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.LogWrapper.DisplaySnapshot;
import flash.Vector;
import jp.sipo.gipo.core.GearHolderLow;
import flash.display.Sprite;
interface OperationView extends GearHolderLow
{
	/** 必要データの付与 */
	public function setContext(operationViewLayer:Sprite):Void;
	
	/** 再現ログの更新 */
	public function updateLog(logcount:Int):Void;
	
	/** 読み込んだファイルデータの表示 */
	public function displayFile(displaySnapshotList:Vector<DisplaySnapshot>):Void;
	
}
