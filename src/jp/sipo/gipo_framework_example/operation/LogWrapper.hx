package jp.sipo.gipo_framework_example.operation;
/**
 * Logの配列のWrapper。基本的には配列のみもつ
 * 
 * @auther sipo
 */
import Type;
import jp.sipo.gipo_framework_example.operation.LogPart;
import flash.Vector;
class LogWrapper<UpdateKind>
{
	private var list = new Array<LogPart<UpdateKind>>();
	
	/** コンストラクタ */
	public function new() {  }
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[LogWrapper(${Type.getClassName(Type.getClass(this))}) ${list}]';
	}
}
/**
 * 記録用のWrapper
 * 保存ファイルも担当する
 * 
 * @auther sipo
 */
class RecordLog<UpdateKind> extends LogWrapper<UpdateKind>
{
	/** コンストラクタ */
	public function new() { super(); }
	
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
	 * 再生用データに変換する
	 */
	public function convertReplay():ReplayLog<UpdateKind>
	{
		return new ReplayLog<UpdateKind>(list);
	}
}

/**
 * 再生用のWrapper
 * 
 * @auther sipo
 */
class ReplayLog<UpdateKind> extends LogWrapper<UpdateKind>
{
	/* 再生インデックス */
	private var position:Int = 0;
	/* 配列サイズ（固定のはずなので） */
	private var length:Int = 0;
	
	/** コンストラクタ */
	public function new(list:Array<LogPart<UpdateKind>>) 
	{
		super();
		this.list = list;
		length = list.length;
	}
	
	/**
	 * スナップショット表示用の配列データを返す
	 */
	public function createDisplaySnapshotList():Vector<DisplaySnapshot>
	{
		var displaySnapshotList = new Vector<DisplaySnapshot>();
		for (i in 0...list.length)
		{
			var part:LogPart<Dynamic> = list[i];
			// snapshotだけを配列へ
			switch (part.logway)
			{
				case LogwayKind.Input(_), LogwayKind.Ready(_) : continue;
				case LogwayKind.Snapshot(value) : 
				{
					var snapshot:Snapshot = value;
					displaySnapshotList.push(new DisplaySnapshot(snapshot.getDisplayName(), i));
				}
			}
		}
		return displaySnapshotList;
	}
	
	/**
	 * 再生ヘッドの設定
	 */
	public function setPosition(position:Int):Void
	{
		this.position = position;
	}
	
	/**
	 * 再生位置のLogが存在するかどうか
	 */
	public function isExist():Bool
	{
		return position < length;
	}
	
	/**
	 * 現在の位置のデータを返す
	 */
	public function get():LogPart<UpdateKind>
	{
		return list[position];
	}
	
	/**
	 * 現在の位置を進める
	 */
	public function progress():Void
	{
		position++;
	}
}

/**
 * 表示用のSnapshot
 * 
 * @auther sipo
 */
class DisplaySnapshot
{
	/** 表示名称 */
	public var display:String;
	/** 元のLogの番号 */
	public var logIndex:Int;
	
	/** コンストラクタ */
	public function new(display:String, logIndex:Int) 
	{
		this.display = display;
		this.logIndex = logIndex;
	}
	
}
