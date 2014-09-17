package jp.sipo.gipo_framework_example.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.scene.mock0.Mock0;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo_framework_example.pilotView.PilotViewScene;
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock0PilotView extends PilotViewScene implements Mock0ViewOrder
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// UIの配置準備
		bgLayer = new Sprite();
		layer.addChild(bgLayer);
		gear.disposeTask(function () layer.removeChild(bgLayer));
		uiLayer = new Sprite();
		layer.addChild(uiLayer);
		gear.disposeTask(function () layer.removeChild(uiLayer));
		uiContainer = new MinimalcompsGipoContainer(uiLayer);
		gear.addChild(uiContainer);
		// 表示設置
		// ラベルの設置
		uiContainer.addLabel("開発テスト画面0");
		// ボタンの設置
		uiContainer.addPushButton("入力テスト", demoDisplayButton_click);
		uiContainer.addPushButton("遷移テスト", demoChangeSceneButton_click);
		uiContainer.addPushButton("非同期テスト", demoAsyncSceneButton_click);
		
	}
	
	/* 反応テスト */
	private function demoDisplayButton_click():Void
	{
		hook.viewInput(Mock0Input.DemoDisplayButton);
	}
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInput(Mock0Input.DemoChangeSceneButton);
	}
	
	/* 非同期テスト */
	private function demoAsyncSceneButton_click():Void
	{
		hook.viewInput(Mock0Input.DemoAsyncSceneButton);
	}
	
	/* ================================================================
	 * Order by Logic 
	 * ===============================================================*/
	
	/**
	 * デモ用表示命令
	 */
	public function demoDisplay():Void
	{
		uiContainer.addLabel("ボタン入力がありました");
	}
}
