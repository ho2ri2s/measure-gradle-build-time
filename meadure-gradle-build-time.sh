#!/bin/bash
# ./build/build-time-2020-01-29-17-50-00.txt のようなファイルにビルド時間を書き込むスクリプト


read -p "How many tasks do you try ? [1~99] => " -r n
if [[ ! $n =~ [0-9]{1,2} ]] || [ $n == 0 ]; then
  echo "input number range of [1~99]"
  exit
fi
read -p "use build cache? [y/n] => " -r yn
case "$yn" in
  "y") echo "start tasks with using build cache.";;
  "n") echo "start tasks with full build.";;
    *) echo "input y or n. "
            exit;;
esac

dirPath=./buildtime
if [[ ! -e $dirPath ]]; then
   mkdir "buildtime"
fi

filePath=$dirPath/build-time-`date '+%Y-%m-%d-%H-%M-%S'`.txt
touch "$filePath"

# taskの実行とcleanを行い、ビルド実行時間をtextファイルに書き出す
for count in `seq 1 "$n"`
do
  echo "now caliculating... $count"
  noBuildCache=""
  if [ "$yn" == "n" ]; then
    ./gradlew clean > /dev/null
    noBuildCache="--no-build-cache"
  fi
  ./gradlew app:assembleDebug $noBuildCache | while read -r line
  do
    if [[ $line =~ ^'BUILD SUCCESSFUL in '([0-5]{0,1}[0-9]{1}.)$ ]]
   then
    echo "${BASH_REMATCH[1]}, " >> $filePath
   elif [[ $line =~ ^'BUILD SUCCESSFUL in '([0-9]{*}.[0-5]{0,1}[0-9]{1}.)$ ]]
   then
    echo "${BASH_REMATCH[1]}" >> $filePath
   fi
  done
done

echo "gradle tasks completed"
