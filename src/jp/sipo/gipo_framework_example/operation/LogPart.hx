package jp.sipo.gipo_framework_example.operation;
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
	/** 通し番号 */
	public var id:Int;
	
	/** コンストラクタ */
	public function new(phase:ReproducePhase<UpdateKind>, frame:Int, logway:LogwayKind, id:Int) 
	{
		this.phase = phase;
		this.frame = frame;
		this.logway = logway;
		this.id = id;
	}
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[LogPart phase=$phase frame=$frame logway=$logway]';
	}
	
	/**
	 * 同じログかどうかをチェックする。１度ファイル化されていることを考慮して、参照比較は出来ない場合に使用する。
	 * 比較するのはphaseとlogwayで、違うframeとidでも、内容が同じであれば同じものと判断する。
	 */
	public function isSame(target:LogPart<UpdateKind>):Bool
	{
		return isSameParam(target.phase, target.logway);
	}
	public function isSameParam(phase:ReproducePhase<UpdateKind>, logway:LogwayKind):Bool
	{
		return Type.enumEq(this.phase, phase) && Type.enumEq(this.logway, logway);
	}
	
	/**
	 * 対象のLogwayがAsyncかどうか判別する
	 */
	public static inline function isAsyncLogway(logway:LogwayKind):Bool
	{
		return switch(logway)
		{
			case LogwayKind.Async(_) : true;
			case LogwayKind.Instant(_), LogwayKind.Snapshot(_): false;
		}
	}
	
	/**
	 * 対象のPhaseがMeantimeかどうか判別する
	 */
	public static inline function isMeantimePhase<UpdateKind>(phase:ReproducePhase<UpdateKind>):Bool
	{
		return switch(phase)
		{
			case ReproducePhase.Meantime : true;
			case ReproducePhase.Update(_): false;
		}
	}
}
/**
 * 再現のタイミングの種類
 * 
 * @auther sipo
 */
enum ReproducePhase<UpdateKind>
{
	/** フレームとフレームの間で発生する。ユーザー入力やロード待ちなどほとんどがこれ */
	Meantime;
	/** Updateタイミングで発生するもの。ドラッグなど */
	Update(kind:UpdateKind);
}
/**
 * Logの記録と再生方法の種類
 */
enum LogwayKind
{
	/** 対象タイミングで実行 */
	Instant(command:EnumValue);
	/** 対象タイミングで準備が整うまで全体を待たせる（処理時間が不明瞭な動作） */
	Async(command:EnumValue);
	/** Logicを生成するのに必要。再生の最初のほか、途中再開にも使用できる */
	Snapshot(value:Snapshot);
}
