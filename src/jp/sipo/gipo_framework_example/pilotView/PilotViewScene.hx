package jp.sipo.gipo_framework_example.pilotView;
/**
 * PilotViewのシーンごとの定義
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.handler.GearDispatcher;
import jp.sipo.gipo_framework_example.context.ViewForLogic.ViewSceneOrder;
import jp.sipo.gipo_framework_example.pilotView.PilotView.PilotViewDiffuseKey;
import jp.sipo.gipo_framework_example.context.View;
import jp.sipo.gipo_framework_example.context.Hook.HookForView;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.handler.AddBehaviorPreset;
import flash.display.Sprite;
class PilotViewScene extends StateGearHolderImpl implements ViewSceneOrder
{
	@:absorbWithKey(PilotViewDiffuseKey.GameLayer)
	private var layer:Sprite;
	@:absorb
	private var hook:HookForView;
	/** フレーム間の更新 */
	public var meantimeUpdateDispatcher(default, null):GearDispatcher;
	/** ドラッグなどの入力状態の更新 */
	public var updateDispatcher(default, null):GearDispatcher;
	/** 情報やカウンタの更新 */
	public var inputUpdateDispatcher(default, null):GearDispatcher;
	/** 表示の更新（特に、必須ではない重い処理に使用する） */
	public var drawDispatcher(default, null):GearDispatcher;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		meantimeUpdateDispatcher = gear.dispatcher(AddBehaviorPreset.addTail, false, PilotViewSceneDispatcherKind.MeantimeUpdate);
		updateDispatcher = gear.dispatcher(AddBehaviorPreset.addTail, false, PilotViewSceneDispatcherKind.Update);
		inputUpdateDispatcher = gear.dispatcher(AddBehaviorPreset.addTail, false, PilotViewSceneDispatcherKind.InputUpdate);
		drawDispatcher = gear.dispatcher(AddBehaviorPreset.addTail, false, PilotViewSceneDispatcherKind.Draw);
	}
	
}
enum PilotViewSceneDispatcherKind
{
	/** フレーム間の更新 */
	MeantimeUpdate;
	/** ドラッグなどの入力状態の更新 */
	Update;
	/** 情報やカウンタの更新 */
	InputUpdate;
	/** 表示の更新（特に、必須ではない重い処理に使用する） */
	Draw;
}
