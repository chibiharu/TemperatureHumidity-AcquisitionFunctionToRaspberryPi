#######################################################################################
#
# <スクリプト名>
# 温湿度情報スクリプト
#
# <概要>
# 取得した温湿度情報を基に以下の処理を実行する
# - 温湿度情報のSLAを判定
#     - 判定結果をログとして出力
#
# <更新履歴>
# 20220409 - 新規作成
#
#######################################################################################
#!/bin/bash


#####################################################################
## 事前設定
#####################################################################

# 今日の日付を取得
today=$(date "+%Y%m%d")

# 現在の時刻を取得
time=$(date '+%Y/%m/%d %T')

# カレントパスを取得
current_path=$(cd $(dirname $0); pwd)


####################################################################
# パラメータ設定
####################################################################
#設定ファイルから変数を取得
source $current_path/../01_param/common.conf


####################################################################
# 事前準備
####################################################################
# ログファイル格納先ディレクトリを作成
if [ ! -d $LogDir ];then mkdir $LogDir ;fi
# データファイル格納先ディレクトリを作成
if [ ! -d $CsvDir ];then mkdir $CsvDir ;fi


###################################################################
## 温湿度を取得
###################################################################
# 温湿度値取得スクリプトを実行
str_raw=`python $current_path/basicdht22.py`


####################################################################
## 関数：取得した温湿度情報から必要事項を各変数に格納
####################################################################
# -- 設定パラメータ情報 --
# [str_time] = 時刻
# [str_temp] = 温度
# [str_humi] = 湿度
#
####################################################################
function FuncSedTH() {
  # 配列に格納
  ary=(`echo $str_raw`)
  # 配列から要素を抜き出す
  str_time=`echo ${ary[0]}`
  str_temp=`echo ${ary[1]}`
  str_temp_bc=`echo $str_temp | sed s/\.[0-9,]*$//g`
  str_humi=`echo ${ary[2]}`
  str_humi_bc=`echo $str_humi | sed s/\.[0-9,]*$//g`
}


####################################################################
## 関数：SLA判定
####################################################################
function FuncSla() {
  # 温度を判定
  if [[ $str_temp_bc -gt $TMax ]] || [[ $str_temp_bc -lt $TMin ]];then ECode=101 FuncOutLog ;fi
  # 湿度を判定
  if [[ $str_humi_bc -gt $HMax ]] || [[ $str_humi_bc -lt $HMin ]];then ECode=102 FuncOutLog ;fi
  # SLAに合格した時の処理
  if [[ $i -eq 1 ]];then ECode=100 FuncOutLog ;fi
}


#####################################################################
## 関数：ログ出力
#####################################################################
function FuncOutLog() {
  case "$ECode" in
    "101")
      ECode="ErrorCode[101]"
      Error="Error=[TemperatureFailed]"
      Massage="Massage=[An abnormal value was detected in the temperature value]"
      Value="Value=["$str_humi"*C]"
      i=2
      ;;
    "102")
      ECode="ErrorCode[102]"
      Error="Error=[HumidityFailed]"
      Massage="Massage=[An abnormal value was detected in the Humidity value]"
      Value="Value=["$str_humi"%]"
      i=2
      ;;
    "100")
      ECode="ErrorCode[100]"
      Error="Error=[success]"
      Massage="Massage=[Procceeing completed successfully]"
      Value="Value=[ Temprature="$str_temp"*C & Humidity="$str_humi"% ]"
      ;;
  esac
  echo -e $time"\t"$ECode"\t"$Error"\t"$Massage"\t"$Value | tee -a $LogPath
}


#####################################################################
## メイン処理
#####################################################################
FuncSedTH
FuncSla
