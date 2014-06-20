package jp.sipo.gipo_framework_example.operation;
/**
 * 再現のタイミングの種類
 * 
 * @auther sipo
 */
enum ReproducePhase
{
	/** フェーズなし。入力があるとエラー */
	None;
	/** 非同期。フレームとフレームの間で発生する。ユーザー入力やロード待ちなどほとんどがこれ */
	Asynchronous;
	/** ViewのinputUpdateで発生する。ドラッグなど */
	ViewInputUpdate;
	// その他、セクションのUpdateで発生するものがあればここに追加
}
