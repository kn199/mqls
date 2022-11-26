// 引数にconst修飾子を付けた場合には関数内で値を変更できない。変更すればコンパイルエラーになる
int Hoge(const int hoge) {}

// &をつけると参照渡しになる 2 + 1で3になる。メモリの番地を受け渡す？
int SampleFunction(int &value){
   value = value + 1;
   return(value);
}

int OnInit(){
  int a= 2;
  int b = SampleFunction(a);
}

// 引数にag_hogeとagがついているのは、定義済み変数名と引数名が同じだとエラーになるから

// 引数の配列は必ず参照渡し(&をつける)

// 引数同士は,とスペース 
// 関数はmethod(){ 
// }

// ifとforは
// if (){ 
// }

// input hogeの変数は、コード上で再代入するとエラーになる。
// start_hourを動的に変更する、かつinputでも設定する場合はエラー

// スプレッドが0.2pipsの時、バックテストでは2と入力
// コード的には以下で取得できる
// int MarketInfo(Symbol(),MODE_SPREAD);
// landでは0.9なのでバックテストでは1.0にしておく

// datetime
// 引き算すると秒数になる
// TimeLocal() を使う

// slippage … どれだけずれて約定してもいいか。USDJPYが小数点以下3桁の価格まで表示されるFX会社の場合、1ポイント＝0.001円
// https://memoja.net/p/oanyb2a/
// titan,landともに3桁表示
// Print(Point());
// 0.001
// Print(Digits());
// 3
// slippage 3なら0.003ずれて良い？多分。
