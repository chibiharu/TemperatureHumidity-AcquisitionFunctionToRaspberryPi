#!/bin/bash
#######################################################################################
#
# <スクリプト名>
# スタートアップスクリプト
#
# <概要>
# 温湿度管理に必要なパッケージやモジュールをインストールする
#
# <更新履歴>
# 20220408 - 新規作成
#
#######################################################################################

#####################################################################
## 事前設定
#####################################################################
# カレントパスを取得
CPath=$(cd $(dirname $0); pwd)

# 実行ログ出力先パス(デフォルト：カレントディレクトリ)
SetUpLog=$CPath"/setuplog.log"


#####################################################################
## 資材
#####################################################################
### Rootユーザか判定 ###
function FuncRoot() {
  echo "### Start function FuncRoot ###"
  if [[ `whoami` != "root" ]]; then
    echo "rootユーザで実行してください。"
    exit 1
  fi
  echo "### End function FuncRoot ###"
}

### 事前準備 ###
function FuncPre() {
  echo "### Start function FuncPre ###"
  apt-get update
  apt-get upgrade -y
  echo "### End function FuncPre ###"
}

### Python開発ツール ###
function FuncInstallPython() {
  echo "### Start function FuncInstallPython ###"
  wget https://www.python.org/ftp/python/3.9.4/Python-3.9.4.tgz
  tar zxvf Python-3.9.4.tgz
  cd Python-3.9.4
  ./configure
  make
  make install
  python3.9 -v
  echo "### End function FuncInstallPython ###"
}

### Git ###
# Git Latest
function FuncInstallGit() {
  echo "### Start function FuncInstallGit ###"
  apt-get install -y git
  git --version
  echo "### End function FuncInstallGit ###"
}

### Adafruit_Python_DHT ###
function FuncCloneAdafruit() {
  echo "### Start function FuncCloneAdafruit ###"
  git clone https://github.com/adafruit/Adafruit_Python_DHT.git
  cd Adafruit_Python_DHT/
  python setup.py install
  echo "### End function FuncCloneAdafruit ###"
}


#####################################################################
## メイン処理
#####################################################################
FuncRoot >> $SetUpLog
FuncPre >> $SetUpLog
FuncInstallPython >> $SetUpLog
FuncInstallGit >> $SetUpLog
FuncCloneAdafruit >> $SetUpLog
