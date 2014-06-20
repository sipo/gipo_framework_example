package jp.sipo.gipo_framework_example.context;
/**
 * 最上位GearHolder
 * 各種セクションの設定などをする
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolderLow;
import jp.sipo.gipo.core.GearHolder;
import jp.sipo.gipo_framework_example.operation.ReproducePhase;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.context.Logic;
import jp.sipo.util.GlobalDispatcher;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo_framework_example.operation.Reproduce;
import jp.sipo.gipo_framework_example.operation.OperationView;
import jp.sipo.gipo_framework_example.operation.OperationHook;
import jp.sipo.gipo_framework_example.operation.OperationLogic;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolderImpl;
class Top extends GearHolderImpl
{
	/* 基本表示レイヤ */
	private var current:Sprite;
	/* 開発設定 */
	private var devConfig:DevConfig;
	/* 各セクションを超えた全体状態管理 */
	private var globalStatus:GlobalStatus;
	
	/* 基本インスタンス */
	private var logic:Logic;
	private var hook:Hook;
	private var view:View;
	private var operationLogic:OperationLogic;
	private var operationHook:OperationHook;
	private var operationView:OperationView;
	private var reproduce:Reproduce;
	
	/* 全体イベントの発行 */
	private var globalDispatcher:GlobalDispatcher;
	
	/** コンストラクタ */
	public function new(current:Sprite, devConfig:DevConfig) 
	{
		super();
		this.current = current;
		this.devConfig = devConfig;
	}
	
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		globalStatus = new GlobalStatus();
		
		// configの拡散
		tool.diffuse(devConfig, DevConfig);
		tool.diffuse(globalStatus, GlobalStatus);
		// operationcの用意
		operationLogic = new OperationLogic();
		tool.bookChild(operationLogic);
		var operationViewClass = devConfig.operationView;
		operationView = Type.createInstance(operationViewClass, []);
		tool.bookChild(operationView);
		operationHook = new OperationHook();
		tool.bookChild(operationHook);
		// reproduceの用意
		reproduce = new Reproduce();
		tool.bookChild(reproduce);
		// hookの用意
		hook = new Hook();
		tool.bookChild(hook);
		// viewの用意
		var viewClass = devConfig.view;
		view = Type.createInstance(viewClass, []);
		tool.bookChild(view);
		// logicの用意
		logic = new Logic();
		tool.bookChild(logic);
		
		// 関係性の追加
		// 	Logic周り
		childDiffuse(hook , logic, LogicForHook);
		childDiffuse(view , hook , HookForView);
		childDiffuse(logic, view , ViewForLogic);
		childDiffuse(logic, hook , HookForLogic);
		// 	Operation周り
		childDiffuse(hook , reproduce, Reproduce);
		childDiffuse(operationHook , operationLogic, OperationLogic);
		childDiffuse(operationView , operationHook , OperationHook);
		childDiffuse(operationLogic, operationView , OperationView);
		childDiffuse(operationLogic, reproduce, Reproduce);
		childDiffuse(reproduce, operationHook, OperationHook);
		
		// ビューのレイヤーとなるSprite。DisplayObjectを使用するViewのみ使用し、Starlingを使用するViewでは無視されるかデバッグ表示のみに使用される
		var viewLayer:Sprite = new Sprite();
		current.addChild(viewLayer);
		view.setContext(viewLayer);
		view.gearOutside().disposeTask(function () current.removeChild(viewLayer));	// layerの削除処理をViewに連動させる
		var operationViewLayer:Sprite = new Sprite();
		current.addChild(operationViewLayer);
		operationView.setContext(operationViewLayer);
		view.gearOutside().disposeTask(function () current.removeChild(operationViewLayer));	// layerの削除処理をViewに連動させる
		
		
		// イベント準備
		globalDispatcher = new GlobalDispatcher();
		globalDispatcher.setFlashContext(current);
		tool.diffuse(globalDispatcher, GlobalDispatcher);
		tool.bookChild(globalDispatcher);
		globalDispatcher.addFrameHandler(frame);	// フレームイベント
		
		// reproduseの準備
		reproduce.startPhase(ReproducePhase.Asynchronous);
	}
	/* child以下にtargetをdiffuseする */
	inline private function childDiffuse(child:GearHolderLow, target:GearHolderLow, clazz:Class<Dynamic>):Void
	{
		child.gearOutside().otherDiffuse(target, clazz);
	}
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// 開始
		logic.start();
	}
	
	/* フレーム動作 */
	private function frame():Void
	{
		// 非同期状態を終了
		reproduce.endPhase();
		// 再現状態の更新処理
		reproduce.update();
		// inputUpdate（マウスドラッグなどの入力）
		reproduce.startPhase(ReproducePhase.ViewInputUpdate);
		view.inputUpdate();
		reproduce.endPhase();
		// Logicのメイン処理
		logic.update();
		view.update();
		view.draw();
		// 再現状態を非同期に切り替え
		reproduce.startPhase(ReproducePhase.Asynchronous);
	}
}
