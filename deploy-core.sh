#! /bin/bash
# args[1] = env
# args[2] = port
# args[3] = branch

echo '正在构建项目'
mkdir -p ~/cugoj/src
rm -rf ~/cugoj/output/CUGOJ_Core
mkdir -p ~/cugoj/output/CUGOJ_Core
cd ~/cugoj/src
rm -rf CUGOJ_Core
git clone -b $3 https://ghproxy.com/https://github.com/CUGOJ/CUGOJ_Core.git
cd CUGOJ_Core

rm -rf output
sh ./build.sh
mv output/* ~/cugoj/output/CUGOJ_Core/

echo '构建成功'
echo '正在部署项目'

rm -rf ~/cugoj/deploy/$1/CUGOJ_Core/output
mkdir -p ~/cugoj/deploy/$1/CUGOJ_Core/output
cp -r ~/cugoj/output/CUGOJ_Core/* ~/cugoj/deploy/$1/CUGOJ_Core/output/
cd ~/cugoj/deploy/$1/CUGOJ_Core/output

nohup sh run.sh $1 $2 &

echo '部署成功'


