# 物性研スパコンハンズオン

## 概要

東京大学物性研究所(以下、物性研)に限らず、スパコンを保有する組織は、目的に合わせて複数のスパコンを持っているのが普通である。物性研は、2021年現在「システムB」と「システムC」と呼ばれる二つのスパコンを運用している。以下、物性研スパコンのシステムBの使い方を外観する。

※本資料は私が研究室向けに独自に作ったもので、物性研公式のものではありません。

## スパコンの基礎

事前に[スパコンの使い方と諸注意](https://www.youtube.com/watch?v=YcsKEyK9G00)を見ておくこと。

## ログイン

アカウントは「kXXXXYY」という形になっている。XXXXがプロジェクト番号、YYがプロジェクト中のメンバー番号で、プロジェクトリーダーが「00」、以下登録順に「01」「02」と続く。物性研スパコンのサーバ名は、システムBが「ohtaka」、システムCが「enaga」である。ドメインは「issp.u-tokyo.ac.jp」となる。例えばプロジェクト`k0000`の、アカウント番号`99`番の人がログインするためには

```sh
ssh k000099@ohtaka.issp.u-tokyo.ac.jp -AY
```

とすれば良い。ここで`-A`オプションはエージェント転送、`-Y`オプションは信頼されたX11の転送であり、それぞれ不要であれば指定しなくてもかまわわない。

物性研は公開鍵認証方式でのみアクセスできる。アクセスのためには事前に公開鍵を登録しておかなければならない。もし秘密鍵・公開鍵のペアを作成していなければ、まずそのペアを作成する必要がある。詳細については[SSH公開鍵の登録手順](https://scm-web.issp.u-tokyo.ac.jp/scm/UserSupport/ssh-pubkey-regist-flow.html)を参照のこと。

## マニュアルの閲覧

マニュアル類は以下のところにある。

[物性研スパコン各種マニュアル](https://www.issp.u-tokyo.ac.jp/supercom/for-users/documents)

まず読むべき基本となるマニュアルは「利用の手引き」である。今回のハンズオンではシステムBを用いるので「利用の手引き(システムB編: 日本語)」を読む。パスワード認証がかかっているが、以下のIDとパスワードでアクセスできる。

* ユーザID：物性研スーパーコンピュータシステムのユーザ名
* パスワード：登録メールアドレスのユーザ名 (@より前の部分)

以下ではインタラクティブ用のキューしか使わないが、通常のジョブはサイズに応じたキューに投入する。「利用の手引き」には、プログラムのコンパイル方法等に加えて、キュー(パーティション)の情報が書いてあるので、必ず目を通すこと。

他にも利用者講習会(要パスワード)やスパコンの使い方と諸注意などの資料があるので、必要に応じて読むこと。

詳しい言語仕様やライブラリのマニュアルなどは「システム B マニュアル」などにある。こちらはかなり詳細な情報を含むので、最初は読まなくて良い。必要に応じて参照すること。

## コンパイルとジョブの投入

### ハンズオンリポジトリのクローン

まずはこのハンズオンのリポジトリをクローンしよう。適当なディレクトリ(例えば`~/github`)で以下を実行せよ。

```sh
git clone https://github.com/kaityo256/issp_handson.git
```

クローンしたら、そのディレクトリに移動しておく。

```sh
cd issp_handson
```

### コンパイル

まずはMPIプログラムをコンパイルしてみよう。ディレクトリ`mpitest`に移動すると、中にMPIのサンプルコード`test.cpp`がある。

```sh
cd mpitest
```

```cpp
#include <cstdio>
#include <mpi.h>

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("%03d/%03d\n", rank, size);
  MPI_Finalize();
}
```

これは全プロセス数と、自分のプロセス番号(ランク)を取得し、それを表示するだけのプログラムだ。

このプログラムを実行するためにはコンパイルする必要がある。物性研スパコンにはコンパイラとしてGCC、インテルコンパイラ、AMDのコンパイラが入っている。GCCを使う場合、Cプログラムであれば`gcc`、C++プログラムであれば`g++`を用いてコンパイルする。さて、並列計算をする際にはMPIの使用がほぼ必須である。MPIを使うには、インクルードファイルやライブラリの場所をコンパイラに教えてやらなければならない。それは面倒なので、代わりに設定をよしなにやってくれるプログラム(ラッパー)が用意されていることが多い。物性研スパコンでは、MPIプログラムのコンパイルは`mpicxx`を用いる。

```sh
mpicxx test.cpp
```

実行可能ファイル`a.out`が作成されるはずである。`mpicxx`が、裏で実際に呼び出しているコンパイラは`--version`を指定するとわかる。

```sh
$ mpicxx --version
g++ (GCC) 8.3.1 20191121 (Red Hat 8.3.1-5)
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

今回のケースでは、`g++`が呼ばれていることがわかる。ちなみに、インテルコンパイラでMPIプログラムをコンパイルしたい場合は`mpiicc`(Cプログラム)、`mpiicpc`(C++プログラム)を用いる。

さて、先ほど作った実行可能ファイルを実行するためには、ジョブスケジューラに計算資源を割り当ててもらう必要がある。ジョブスケジューラには様々な種類があるが、物性研スパコンシステムBではSlurm、システムCではPBSProが使われており、それぞれコマンドが異なる。

### インタラクティブジョブ

ジョブの実行方法には、インタラクティブジョブとバッチジョブの二通りがある。まずはインタラクティブジョブによりジョブを実行しよう。インタラクティブジョブとは、専用に用意された計算資源をジョブスケジューラに割り当ててもらい、対話的にプログラムを実行するジョブである。物性研システムBには`i8cpu`というインタラクティブキューが用意されている。このキューを利用するには、以下のコマンドを実行する。

```sh
salloc -N 1 -n 128 -p i8cpu
```

`salloc`が計算資源要求をするためのコマンド、`-N 1`は、要求ノード数(ここでは1ノード)、`-n 128`は利用プロセス数(ここでは128プロセス)、`-p i8cpu`は計算資源(パーティション)の指定で、ここでは`i8cpu`を指定している。

実行すると以下のような表示がされる。

```txt
salloc: Pending job allocation 272941
salloc: job 272941 queued and waiting for resources
salloc: job 272941 has been allocated resources
salloc: Granted job allocation 272941
```

* これはジョブIDとして272941が割り振られ、
* リソースの割当を待っており(queued and waiting for resources)
* 計算資源が割り当てられ(has been allocated resources)
* ジョブの実行が開始された(Granted job allocation)

という意味だ。混み具合によっては最後の行しか表示されない場合もある。この状態でジョブを実行するには`srun`を用いる。

```sh
srun ./a.out
```

`srun`は、Slurmで管理されたシステムにおいて並列ジョブを実行するためのコマンドである。このジョブに割り当てられた計算資源を確認し、どのプロセスをどの計算資源に割り振るかを自動的に決定する。このプログラムは全プロセス数のうち、自分のID(ランク)を表示するだけのコードで、実行すると以下のような表示がでる。

```txt
012/128
067/128
074/128
(snip)
072/128
118/128
099/128
```

例えば「`099/128`」は、128プロセス中の99番のプロセスだよ、という意味である。なお、実行のたびに表示の順番は異なる。

実行終了したら`exit`によりインタラクティブジョブを抜けること。

### バッチジョブ

インタラクティブジョブは対話的に計算を行うが、これはデバッグや動作確認に用いるためのキューであり、一般の大きな計算はキューに積んで順番待ちをする。この順番待ちの列のことをキュー(Queue)と呼ぶ。プログラムをバッチジョブとして実行するためには、ジョブスケジューラにどんな計算資源を要求するか、どのようにプログラムを実行するのかを教えてやる必要がある。それを記述するのがジョブスクリプトである。ジョブスクリプトは、特殊なコメント欄を持つシェルスクリプトである。例えば、このリポジトリには`test.sh`というジョブスクリプトが用意されている。中身を見てみよう。

```sh
cat test.sh
```

以下のような内容が表示される。

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 128

srun ./a.out
```

シェルスクリプトは`#`以後はコメントとして扱われるが、このスクリプトでは全て意味を持っている。

最初の`#!`で始まる行はシバン(shebang)と呼ばれ、このスクリプトを処理するシェルを指定する。

次行からの`#SBATCH`で始まる行が、ジョブスケジューラ(Slurm)への指示である。それぞれの意味は以下の通り。

* `-p i8cpu` 計算資源(パーティション)の指定で、ここでは`i8cpu`を指定している。
* `-N 1` 要求ノード数(ここでは1ノード)
* `-n 128` 利用プロセス数(ここでは128プロセス)

これらは先程`salloc`にコマンド引数として渡したものと同じものである。コマンド引数として直接情報を渡すこともできるが、後でどんな計算資源を要求したかの情報がファイルに残るようにシェルスクリプトに記述しておいた方がよい。

また、PBSの場合はジョブ投入時のディレクトリが環境変数`PBS_O_WORKDIR`に入っており、コードの実行前に

```sh
cd $PBS_O_WORKDIR
```

を実行するのが一般的であるが、Slurmでは自動的に実行時のディレクトリをカレントディレクトリとするためこのコマンドは不要である。

このシェルスクリプトをジョブとして投入するには`sbatch`コマンドを使う。

```sh
sbatch test.sh
```

ジョブを投入した結果、ジョブIDが割り振られる。ジョブの状態は`squeue`コマンドで知ることができる。

```sh
squeue
```

例えば以下のような表示がでる。

```txt
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            272905     i8cpu  test.sh  k011700  R       0:03      1 c15u01n1 
```

それぞれの情報の意味は以下の通り。

* ジョブID(JOBID)として272905が割り振られた
* 計算リソース(PARTITION)は`i8cpu`を要求している
* シェルスクリプトのファイル名(NAME)は`test.sh`である
* 状態(status, ST)は実行中(R)である
* 実行開始からの時間(TIME)は3秒(0:03)
* 要求ノード数(NODES)は1である
* 実行ノードリスト(NODELIST)、もしくは待ち状態ならその理由(REASON)

実行が終わると、`slurm-ジョブID.out`というファイルが作成される。ここには標準出力が保存されている。今回はジョブIDが272905であるため、`slurm-272905.ou`というファイルができている。lessやcat等で中身を確認せよ。

### メール通知

スパコンが混んでいる場合、ジョブの実行には数日以上待たされる。そこで、ジョブが実行開始したり、実行を終了したらメールで通知する機能がある。Slurmではメール通知は`--mail-type`や`--mail-user`で指定する。

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 128
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=your@mail.address

srun ./a.out
```

`test_mail.sh`をvimで開き、上記の`your@mail.address`を自身のアドレスに変えてから

```sh
sbatch test_mail.sh
```

を実行せよ。ジョブの開始時に`root@sched1.ohtaka.issp.u-tokyo.ac.jp`というアドレスからメール通知が飛んでくるはずである。

## スレッド並列やハイブリッド並列

### スレッド並列

並列化には大きく分けてプロセス並列、スレッド並列、データ並列がある。プロセス並列はMPIというライブラリで、スレッド並列はOpenMPというディレクティブで、データ並列は組み込み関数で実装するのが一般的だ。先程はMPIでプロセス並列を試したので、次はスレッド並列を試してみよう。OpenMPを使うには、コンパイラにそれを教えてやる必要がある。`g++`なら`-fopenmp`、インテルコンパイラ`icpc`なら`-qopenmp`である。ここではインテルコンパイラを使おう。

まず、先ほどの`mpitest`ディレクトリから出て、`threadtest`ディレクトリに入る。

```sh
cd ..
cd threadtest
```

その中にあるスレッド並列のサンプルコード`test.cpp`がある。

```cpp
#include <cstdio>
#include <omp.h>

int main() {
  int num_threads = omp_get_max_threads();
#pragma omp parallel for
  for (int i = 0; i < num_threads; i++) {
    int tid = omp_get_thread_num();
    printf("%03d/%03d\n", tid, num_threads);
  }
}
```

最初にスレッド数を取得し、スレッドの数だけループを回すが、ループの中身をそれぞれ別スレッドに割り当てるコードである。

それをコンパイルしてみよう。

```sh
icpc -qopenmp test.cpp
```

そのまま実行してみよう。

```sh
$ ./a.out 
000/001
```

スレッドが1つ作成され、スレッドID0番からの出力がなされた。スレッド数を変更するには環境変数`OMP_NUM_THREADS`を指定する。

```sh
$ OMP_NUM_THREADS=4 ./a.out
003/004
000/004
001/004
002/004
```

4スレッド起動したことがわかる。ログインノードであまりスレッドを立ち上げると迷惑になるのでこれくらいにしておこう。

これをジョブスケジューラにバッチジョブとして投げるには、「プロセス数」に加えて「プロセスあたりのスレッド数」も指定してやる必要がある。ジョブスクリプトはこんな感じになる。

```sh
cat test.sh
```

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 128

srun ./a.out
```

ジョブの投入は先程と同様である。

```sh
sbatch test.sh
```

実行すると、`slurm-275559.out`のようなファイルが作成される。中身は例えば以下のようになる。

```txt
012/128
017/128
038/128
(snip)
122/128
126/128
117/128
```

意味はMPIの場合と同様で、全スレッド数と自分のスレッド番号が表示されている。

### ハイブリッド並列

SIMDはさておくと、計算科学における並列計算とは複数のCPUコアを同時につかう計算のことである。この時、使うCPUの数と同じ数のプロセスを立ち上げるのをflat-MPIと呼び、CPUの数より少ないプロセスを立ち上げ、それぞれのプロセスに複数のスレッドを起動する並列をハイブリッド並列と呼ぶ。


ハイブリッド並列のサンプルコードは`hybrid`ディレクトリに入っている。

```sh
cd ..
cd hybrid
```

こんなプログラムだ。

```cpp
#include <cstdio>
#include <mpi.h>
#include <omp.h>

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  int num_threads = omp_get_max_threads();
#pragma omp parallel for
  for (int i = 0; i < num_threads; i++) {
    int tid = omp_get_thread_num();
    printf("Thread:%03d/%03d Process:%03d/%03d\n", tid, num_threads, rank, size);
  }
  MPI_Finalize();
}
```

詳細は説明しないが、MPIとOpenMPの両方が使われている。

さて、物性研システムBは1ノードに64コアのCPUが2ソケットあるため、全体で128並列まで実行できる。これを8プロセス*16スレッドで実行してみよう。MPIプログラムのコンパイルなので`mpicxx`を使い、裏がGCCなのでオプションとして`-fopenmp`を渡す。

```sh
mpicxx -fopenmp test.cpp
sbatch test.sh
```

できたファイル`slurm-XXXXX.out`をsortコマンドで表示してみよう。

```sh
$ sort slurm-272988.out
Thread:000/016 Process:000/008
Thread:000/016 Process:001/008
Thread:000/016 Process:002/008
Thread:000/016 Process:003/008
(snip)
Thread:015/016 Process:004/008
Thread:015/016 Process:005/008
Thread:015/016 Process:006/008
Thread:015/016 Process:007/008
```

プロセスが8個、それぞれのプロセスにおいてスレッドが16個起動していることがわかるであろう。

## LAMMPSの利用

システムBではビルド済みのアプリケーションが多数インストールされている。インストール済みアプリケーションの一覧は「[インストール済みアプリケーション](https://www.issp.u-tokyo.ac.jp/supercom/visitor/applications)」を参照のこと。

アプリケーションを利用するには、それぞれのディレクトリにある アプリケーション名vars.shを実行する。LAMMPSであれば、

```sh
source /home/issp/materiapps/intel/lammps/lammpsvars.sh
```

を実行することで`lammps`にパスが通る。

これを物性研で実行してみよう。LAMMPSを使うサンプルコードは`lammps`ディレクトリにある。

```sh
cd ..
cd lammps
```

まずは原子の座標ファイルを生成しよう。

```sh
python3 generate_config.py
```

これで`collision.atoms`が作成されるはずである。この状態でインタラクティブキューを起動しよう。

```sh
salloc -N 1 -n 128 -p i8cpu
```

ジョブが開始したら、パスを通してから実行する。

```sh
source /home/issp/materiapps/intel/lammps/lammpsvars.sh
srun lammps < collision.input 
```

最初にこんな表示がされるはずだ。

```sh
LAMMPS (29 Oct 2020)
  using 1 OpenMP thread(s) per MPI task
Reading data file ...
  orthogonal box = (-40.000000 -20.000000 -20.000000) to (40.000000 20.000000 20.000000)
  8 by 4 by 4 MPI processor grid
```

これは、1プロセスに対して1スレッドのflat-MPIであり、空間を8x4x4に区切って、それぞれをプロセスに任せることで128プロセスの計算をするよ、という意味だ。

このジョブでは原子数が少ないこともあって並列化による性能向上はあまり見込めないが、大きな系を計算する際には並列化は非常に有効である。

せっかくなのでハイブリッド実行もためそう。こんなジョブスクリプトを用意してある。

```sh
#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -c 16

source /home/issp/materiapps/intel/lammps/lammpsvars.sh
srun lammps < collision.input
```

これは、8プロセス*16スレッドの並列実行ジョブだ。パスはジョブスクリプトの中で通す必要があることに注意。

実行するとこんな結果が得られるはずだ。

```txt
LAMMPS (29 Oct 2020)
  using 16 OpenMP thread(s) per MPI task
Reading data file ...
  orthogonal box = (-40.000000 -20.000000 -20.000000) to (40.000000 20.000000 20.000000)
  2 by 2 by 2 MPI processor grid
```

これは1プロセスあたり16スレッド、空間を2x2x2に分割したことを示しており、確かにプロセス/スレッドのハイブリッド並列が行われたことがわかる。

## ファイルのやりとり

スパコンとのファイルのやりとりは、`scp`を使う。scpはファイル名にリモートサーバのホスト名とコロンをつけることで、リモートにあるファイルをローカルにあるかのように扱うことができる。例えばリモートサーバが`ohtaka.issp.u-tokyo.ac.jp`、ユーザ名が`k000099`である時に、ローカルからリモートにファイルをコピーしたい場合は

```sh
scp filename k000099ohtaka.issp.u-tokyo.ac.jp:remotepath
```

リモートからローカルのカレントディレクトリにファイルをコピーしたい場合は

```sh
scp k000099ohtaka.issp.u-tokyo.ac.jp:remotepath/filename .
```

とする。
