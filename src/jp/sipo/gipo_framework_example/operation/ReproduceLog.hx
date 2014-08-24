package jp.sipo.gipo_framework_example.operation;
/**
 * Log全体の定義。基本的には配列のみもつ
 * 
 * @auther sipo
 */
 
class ReproduceLog<UpdateKind>
{
	private var list = new Array<LogPart<UpdateKind>>();
	
	/** コンストラクタ */
	public function new() {  }
	
	/**
	 * 追加する
	 */
	public function add(logPart:LogPart<UpdateKind>):Void
	{
		list.push(logPart);
	}
	
	/**
	 * 長さを返す
	 */
	public function getLength():Int
	{
		return list.length;
	}
	
	/**
	 * 要素を１つ返す
	 */
	public function get(index:Int):LogPart<UpdateKind>
	{
		return list[index];
	}
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[ReproduceLog $list]';
	}
}

/**
 * Logの1単位
 * ReadOnlyにしたいところだが、データ構造が深く、処理速度の関係で断念。
 * ファイル単位で２つ作れば問題ない
 * 
 * @author sipo
 */
class LogPart<UpdateKind>
{
	/** 再現フェーズ */
	public var phase:ReproducePhase<UpdateKind>;
	/** 発生フレーム */
	public var frame:Int;
	/** ログ情報 */
	public var logway:LogwayKind;
	
	/** コンストラクタ */
	public function new(phase:ReproducePhase<UpdateKind>, frame:Int, logway:LogwayKind) 
	{
		this.phase = phase;
		this.frame = frame;
		this.logway = logway;
	}
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[LogPart phase=$phase frame=$frame logway=$logway]';
	}
}
/**
 * 再現のタイミングの種類
 * 
 * @auther sipo
 */
enum ReproducePhase<UpdateKind>
{
	/** 非同期。フレームとフレームの間で発生する。ユーザー入力やロード待ちなどほとんどがこれ */
	Asynchronous;
	/** Updateタイミングで発生するもの。ドラッグなど */
	Update(kind:UpdateKind);
}
/**
 * Logの記録と再生方法の種類
 */
enum LogwayKind
{
	/** 対象タイミングで実行 */
	Input(command:EnumValue);
	/** 対象タイミングで準備が整うまで全体を待たせる（処理時間が不明瞭な動作） */
	Ready(command:EnumValue);
	/** Logicを生成するのに必要。再生の最初のほか、途中再開にも使用できる */
	Snapshot(value:Snapshot);
}
