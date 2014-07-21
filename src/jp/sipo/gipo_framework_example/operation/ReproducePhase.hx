package jp.sipo.gipo_framework_example.operation;
/**
 * 再現のタイミングの種類
 * 
 * @auther sipo
 */
enum ReproducePhase<UpdateKind>
{
	/** 発生しない */
	None;
	/** 非同期。フレームとフレームの間で発生する。ユーザー入力やロード待ちなどほとんどがこれ */
	Asynchronous;
	/** Updateタイミングで発生するもの。ドラッグなど */
	Update(kind:UpdateKind);
}
