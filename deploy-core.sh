#! /bin/bash
# args[1] = env
# args[2] = port
# args[3] = branch

echo '正在构建项目'
mkdir -p ~/cugoj/src
mkdir -p ~/cugoj/output/CUGOJ_Core
cd ~/cugoj/src
git clone -b $3 https://github.com/CUGOJ/CUGOJ_Core.git
cd CUGOJ_Core

rm -rf output
sh ./build.sh
mv output/* ~/cugoj/output/CUGOJ_Core/

echo `构建成功`
echo `正在部署项目`

mkdir -p ~/cugoj/deploy/$1/CUGOJ_Core
cp -r ~/cugoj/output/CUGOJ_Core/* ~/cugoj/deploy/$1/CUGOJ_Core/
cd ~/cugoj/deploy/$1/CUGOJ_Core/

sh run.sh $1 $2 &


