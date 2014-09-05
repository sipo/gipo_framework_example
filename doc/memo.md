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

