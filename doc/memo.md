各種機能メモ

# Gipo dispatcher-handler

テンプレートパターンを使った際に発生する Call super アンチパターンを回避するためのもの。

例えば、あるキャラクターを実装する場合、基底クラスでupdateを定義し、派生クラスでupdateをoverrideするのがテンプレートパターンだが、
この場合さらに派生クラスを作りupdateタイミングでの処理を追加する場合、クラス内にsuper.update()を呼びださなければ、親クラスの処理が消えてしまう。 
super.update()を書き忘れてもエラーが出ないために非常に危険。

そもそもとして、overrideはあまり使用するべきではなく、テンプレートパターンはあまり良いデザインパターンだとは考えていない。

## デフォルト用意

以下の３つが使用可能

    @:handler(GearDispatcherKind.Diffusible)

    @:handler(GearDispatcherKind.Run)

    @:handler(GearDispatcherKind.Bubble)

## 具体例

dispatcherを管理する変数を用意する

```haxe
/* updateイベント発行 */
private var updateDispatcher:GearDispatcher;
```

コンストラクタ内で、dispatcherの初期設定を行う。

第１引数は、２つ以上のイベントの追加処理の扱い  
第２引数は、１回のみの実行でイベントを消去してしまうかどうか
第３引数で、イベントのキーを決定する

```haxe
updateDispatcher = gear.dispatcher(AddBehaviorPreset.addTail, false, LogicSceneDispatcherKind.Update);
```

イベントを受け取る関数を設定する。複数可能かつ、継承先でも定義できる（ただし、Haxeの仕様上、関数名は変えなければいけない）

```haxe
/**
 * 更新処理
 */
@:handler(LogicSceneDispatcherKind.Update)
public function update():Void
{
	// 何らかの処理
}
```

以下のようにイベント発行を行うと、メソッドが呼び出される

```haxe
updateDispatcher.execute();
```

基本的には外部のイベントを、サブクラスに伝えるために、以下の様な形になる

```haxe
/**
 * 更新処理
 */
public function sceneUpdate():Void
{
	updateDispatcher.execute();
}
```

# Gipo dispatcher-handler（RedTape）

dispatcher-handlerがEnumを１つ引数に取るもの。

RadTapeの語源は「お役所仕事」。指定されたEnumのみを処理するため。

## 具体例

dispatcherを管理する変数を用意する


```haxe
/* シーンごとのviewInputの受け取り処理 */
private var viewInputRedTape:GearDispatcherRedTape;
```

コンストラクタ内で、dispatcherの初期設定を行う。


```haxe
viewInputRedTape = gear.dispatcherRedTape(LogicSceneDispatcherKind.ViewInput);
```

受け取り関数を用意する。引数必ず何らかのEnum型になる。

```haxe
/* Viewからの入力 */
@:redTapeHandler(LogicSceneDispatcherKind.ViewInput)
private function viewInput(command:Mock0Input):Void
{
	switch(command)
	{
		case Mock0Input.DemoDisplayButton: input_demoTraceButton();
		case Mock0Input.DemoChangeSceneButton: input_demoChangeSceneButton();
	}
}
```

イベントの発生は以下。

```haxe
/**
 * 入力などのイベント
 */
inline public function noticeEvent(command:EnumValue):Void
{
	viewInputRedTape.execute(command);
}
```

この時、引数はEnumValueなので、どんなEnumでも取りうる。
複数の種類のEnumを扱うことができ、その場合渡されたEnumを持つ関数に自動的に振り分けられる。

redTapeHandlerが設定されている関数が無ければエラーとなる。

// todo:後で分割

#Reproduce

Reproduceはゲームの進行情報を記録するシステム。

SectionからHookを介してのLogicへの入力（command）はLogPartとして、記録される。再生時はこれと同じcommandがReproduceからHookを介してLogicへ送出されることで、Logicは同じ挙動をすることになる。

以上の機能を得るためには、状況によって値やタイミングが変動する処理、例えばランダムや日付、サーバー通信、非同期処理などは必ずLogicではなくSectionに置く必要がある。

LogPartは、ReproducePhaseと、LogWayという２つのパラメータで挙動が分類される。

##ReproducePhase

そのコマンドが発生したフレーム依存のタイミング。再生時になるべく同じ状況を再現するために、フレームの処理の中のどこで発生したかが記録される。

###OutFrame

フレームとフレームの間で発生する。ユーザー入力やロード待ちなどほとんどがこれにあたる。

再現時は、次のフレームの頭で送出される。よって、正確にはコマンドが発生したタイミングではないのだが、Logicの処理がちゃんとフレーム依存になっていればズレることはない。

###InFrame

Updateタイミングで発生するもの。ドラッグなど。

フレーム間は各セクションごとにさらに区分が分かれており、再現時はその区分の最後で送出される。

##LogWay

記録と再生の方法。記録の中には、すぐに再現できるものの他に、再現に不安定な時間がかかったり、再現に特殊な処理が必要な場合があるため、それを分類する。

###Instant

再現時にすぐにダミーを用意できるコマンド。マウスやキーボード入力や、同期的なランダムの発生、日付の取得など。

###Ready

再現時にメソッドの命令だけではなく実際にリソースの用意などが必要な処理。

例えば素材のロードは「素材がロードできた」という嘘のデータを作ることはできるが、再現時に素材が本当はロードできていないタイミングでこれをしてしまうと、以後の進行に問題がある場合がある。そこでAsyncの場合は、先に再現フレームが来てしまっても、ゲーム全体を停止し、Sectionから本来のコマンドが送られてくるまで待機するという仕様になる。この際、Logicなどのフレーム依存処理は完全に停止する。

###SnapShot

特殊なコマンド。このコマンドには、その時点のLogicの構成に必要なデータが全て含まれ、またSnapShotが叩かれた直後はLogicは必ず必要な素材などのロードの処理を挟んで開始するという制約がある。これにより、どのようなタイミングでSnapShotが送られてきてもLogicは完璧に対応しなければいけない。

非常に面倒なコマンドではあるが、このSnapShotから再現を開始することが出来るため、長いログを使ってデバッグする際にショートカットとなる。バトルの開始など、状況が一変するような処理の時に挟み込みたいところ。送出は例外的にSectionではなくLogicが行う。




