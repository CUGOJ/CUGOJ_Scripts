#! /bin/bash
# args[1] = password of cugoj
# args[2] = port of docker
# args[3] = name of docker-pod
# curl -O https://ghproxy.com/https://raw.githubusercontent.com/CUGOJ/CUGOJ_Base/main/mysql-cugoj.sh && sh mysql-cugoj.sh

if [ ! $# -eq 3 ]; then
    echo "参数数量错误,应依次为 cugoj用户密码;docker端口;docker-pod名称"
    exit 1
fi

mkdir -p $(pwd)/conf
mkdir -p $(pwd)/data
cat>$(pwd)/conf/init.sh<<FILEEOF
echo '进入docker容器'
mysql -uroot -pcugoj123456 <<EOF
use mysql;
create user if not exists 'cugoj'@'%' identified with mysql_native_password by '$1';
grant all privileges on *.* to 'cugoj'@'%';
flush privileges;
exit
EOF
echo '数据库配置成功'

echo '开始创建database'
mysql -h127.0.0.1 -P 3306 -ucugoj -p$1 </etc/mysql/conf.d/init.sql

echo 'Mysql for CUGOJ已启动'
FILEEOF

cat>$(pwd)/conf/init.sql<<SQLEOF
drop database if exists \`cugoj\`;

create database if not exists \`cugoj\`;

use \`cugoj\`;

create table \`user\`(
    \`id\` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`user_id\` bigint  NOT NULL COMMENT '用户ID',
    \`username\` varchar(40) NOT NULL COMMENT '用户名',
    \`password\` varchar(130) NOT NULL COMMENT '密码',
    \`salt\` varchar(130) NOT NULL COMMENT '密码加盐',
    \`phone\` varchar(30) COMMENT '电话号码',
    \`email\` varchar(64) COMMENT '邮箱',
    \`signature\` varchar(512) COMMENT '个性签名',
    \`organization_id\` bigint  NOT NULL DEFAULT 0 COMMENT '所属组织',
    \`nickname\` varchar(64) COMMENT '昵称',
    \`realname\` varchar(64) COMMENT '真名',
    \`avatar\` varchar(128) COMMENT '头像',
    \`user_type\` int  NOT NULL DEFAULT 3 COMMENT '用户类型1:super admin,2:admin,3:user',
    \`extra\` varchar(4096) COMMENT '额外信息',
    \`allowed_ip\` varchar(2048) COMMENT '允许访问的IP',
    \`status\` int NOT NULL COMMENT '状态',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (\`id\`),
    KEY \`idx_uid\` (\`user_id\`),
    KEY \`idx_user_name\` (\`username\`),
    KEY \`idx_phone\` (\`phone\`),
    KEY \`idx_email\` (\`email\`),
    KEY \`idx_status\` (\`status\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '用户元信息表';

create table \`user_login\`(
    \`id\` bigint  NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`user_id\` bigint  NOT NULL COMMENT '用户ID',
    \`ip\` bigint  NOT NULL COMMENT '登录IP',
    \`device_id\` varchar(128) NOT NULL COMMENT '设备ID',
    \`platform\` int  NOT NULL COMMENT '平台',
    \`login_type\` int  NOT NULL COMMENT '登录类型',
    \`time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (\`id\`),
    KEY \`idx_user_time\` (\`user_id\`, \`time\`),
    KEY \`idx_user_platform_time\` (\`user_id\`, \`platform\`, \`time\`),
    KEY \`idx_user_device_time\` (\`user_id\`, \`device_id\`, \`time\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '用户登录记录表';

create table \`team\`(
    \`id\` bigint  NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`name\` varchar(64) NOT NULL COMMENT '队伍名',
    \`signature\` varchar(512) COMMENT '个性签名',
    \`description\` varchar(512) COMMENT '队伍介绍',
    \`leader\` bigint  NOT NULL COMMENT '队长',
    \`organization_id\` bigint  NOT NULL DEFAULT 0 COMMENT '所属组织',
    \`avatar\` varchar(128) COMMENT '头像',
    \`status\` int NOT NULL COMMENT '状态',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (\`id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '队伍信息表';

create table \`team_user\`(
    \`id\` bigint  NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`user_id\` bigint  NOT NULL COMMENT '用户Id',
    \`team_id\` bigint  NOT NULL COMMENT '队伍Id',
    \`user_type\` int NOT NULL COMMENT '用户类型',
    \`status\` int NOT NULL COMMENT '状态',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (\`id\`),
    KEY \`idx_team\` (\`team_id\`),
    KEY \`idx_user\` (\`user_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '队员表';

create table \`organization\`(
    \`id\` bigint  NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`name\` varchar(64) NOT NULL COMMENT '组织名',
    \`description\` varchar(4096) COMMENT '描述',
    \`owner\` bigint  NOT NULL COMMENT '组织所有人',
    \`parent_id\` bigint  NOT NULL DEFAULT 0 COMMENT '父组织',
    \`avatar\` varchar(128) COMMENT '头像',
    \`status\` int NOT NULL COMMENT '状态',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (\`id\`),
    KEY \`idx_owner\` (\`owner\`),
    KEY \`idx_parent\` (\`parent_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '组织信息表';

CREATE TABLE \`problem_base\` (
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '题目ID',
    \`title\` VARCHAR(512) NOT NULL COMMENT '题目标题',
    \`writer_id\` BIGINT  NOT NULL COMMENT '出题人ID',
    \`properties\` VARCHAR(1024) DEFAULT NULL COMMENT '针对不同题目类型的描述JSON',
    \`show_id\` VARCHAR(16) NOT NULL COMMENT '展示的题号',
    \`source_id\` BIGINT  NOT NULL COMMENT '题目来源',
    \`submission_count\` BIGINT  DEFAULT 0 COMMENT '提交数',
    \`accepted_count\` BIGINT  DEFAULT 0 COMMENT '通过数',
    \`type\` INT NOT NULL COMMENT '题目类型',
    \`status\` INT NOT NULL COMMENT '题目状态',
    \`version\` BIGINT  DEFAULT 0 COMMENT '版本',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY(\`id\`),
    KEY \`idx_type_writer\` (\`type\`, \`writer_id\`),
    KEY \`idx_type_source_show\` (\`type\`, \`source_id\`, \`show_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题目基本信息表';

CREATE TABLE \`problem_source\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`name\` VARCHAR(128) NOT NULL COMMENT '题目来源名',
    \`url\` VARCHAR(128) NOT NULL COMMENT '题目源主页',
    \`properties\` VARCHAR(4098) COMMENT '题目show_id组合源链接策略',
    PRIMARY KEY (\`ID\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题目来源表';

CREATE TABLE \`problem_content\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '题目内容ID',
    \`problem_id\` BIGINT  NOT NULL COMMENT '题目ID',
    \`content\` TEXT COMMENT '题目具体内容',
    PRIMARY KEY(\`id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题目内容';

CREATE TABLE \`contest_base\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '比赛ID',
    \`organization_id\` BIGINT  NOT NULL COMMENT '承办组织',
    \`owner_id\` BIGINT  NOT NULL COMMENT '所有者',
    \`type\` INT NOT NULL COMMENT '赛事类型',
    \`writers\` VARCHAR(512) DEFAULT NULL COMMENT '出题人',
    \`start_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    \`end_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '结束时间',
    \`title\` VARCHAR(64) NOT NULL COMMENT '比赛名称',
    \`profile\` VARCHAR(1024) DEFAULT NULL COMMENT '赛事的简单描述',
    \`status\` INT NOT NULL COMMENT '比赛状态枚举',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY(\`id\`),
    KEY \`idx_type_owner\` (\`type\`, \`owner_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛列表';

CREATE TABLE \`contest_content\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '比赛内容ID',
    \`contest_id\` BIGINT  NOT NULL COMMENT '比赛ID',
    \`content\` TEXT COMMENT '赛事描述文字',
    PRIMARY KEY(\`id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛文字内容列表';

CREATE TABLE \`register\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '自增ID',
    \`contest_id\` BIGINT  NOT NULL COMMENT '比赛ID',
    \`registrant_id\` BIGINT  NOT NULL COMMENT '注册人ID',
    \`registrant_type\` INT  NOT NULL COMMENT '注册人类型',
    \`team_id\` BIGINT  COMMENT '队伍ID',
    \`extra\` VARCHAR(1024) COMMENT '额外信息',
    \`status\` INT NOT NULL COMMENT '比赛状态枚举',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY(\`id\`),
    KEY \`idx_contest\`(\`contest_id\`, \`status\`),
    KEY \`idx_registrant\`(\`registrant_id\`, \`status\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '比赛注册表';

CREATE TABLE \`contest_problem\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '赛题ID',
    \`contest_id\` BIGINT  NOT NULL COMMENT '比赛ID',
    \`problem_id\` BIGINT  NOT NULL COMMENT '题目ID',
    \`submission_count\` BIGINT  NOT NULL COMMENT '提交数',
    \`accepted_count\` BIGINT  NOT NULL COMMENT 'AC数',
    \`version\` BIGINT  NOT NULL COMMENT '版本',
    \`status\` INT NOT NULL COMMENT '状态枚举',
    \`properties\` VARCHAR(2048) DEFAULT NULL COMMENT '分数、语言等信息的JSON格式',
    PRIMARY KEY(\`id\`),
    KEY \`idx_contest\` (\`contest_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '赛题列表';

CREATE TABLE \`submission_base\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '提交ID',
    \`submit_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    \`submitter_id\` BIGINT  NOT NULL COMMENT '提交者ID',
    \`submitter_type\` INT  NOT NULL COMMENT '提交者类型（团队或个人）',
    \`status\` INT NOT NULL COMMENT '提交结果',
    \`type\` INT NOT NULL COMMENT '提交类型',
    \`contest_id\` BIGINT  COMMENT '关联的比赛',
    \`problem_id\` BIGINT  COMMENT '关联的题目',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP  COMMENT '创建时间',
    \`properties\` VARCHAR(1024) DEFAULT NULL COMMENT '特定配置JSON',
    PRIMARY KEY(\`id\`),
    KEY \`idx_submitter_problem\` (\`submitter_id\`, \`problem_id\`),
    KEY \`idx_contest_submitter\` (\`contest_id\`, \`submitter_id\`),
    KEY \`idx_contest_problem\` (\`contest_id\`, \`problem_id\`),
    KEY \`idx_contest_create_time\` (\`contest_id\`, \`create_time\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '提交基本信息表';

CREATE TABLE \`submission_content\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '提交内容ID',
    \`submission_id\` BIGINT  NOT NULL COMMENT '提交ID',
    \`content\` TEXT COMMENT '提交内容',
    PRIMARY KEY(\`id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '提交内容表';

CREATE TABLE \`solution_base\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '题解ID',
    \`writer_id\` BIGINT  NOT NULL COMMENT '作者ID',
    \`contest_id\` BIGINT  COMMENT '关联的比赛',
    \`problem_id\` BIGINT  COMMENT '关联的题目',
    \`status\` INT NOT NULL COMMENT '状态枚举',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY(\`id\`),
    KEY \`idx_writer\` (\`writer_id\`),
    KEY \`idx_contest\` (\`contest_id\`),
    KEY \`idx_problem\` (\`problem_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题解基本信息表';

CREATE TABLE \`solution_content\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '题解内容ID',
    \`solution_id\` BIGINT  NOT NULL COMMENT '题解ID',
    \`content\` TEXT COMMENT '题解内容',
    PRIMARY KEY(\`id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题解内容表';

CREATE TABLE \`problemset\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '题单ID',
    \`title\` VARCHAR(64) NOT NULL COMMENT '题单名称',
    \`creator_id\` BIGINT  NOT NULL COMMENT '创建者ID',
    \`description\` VARCHAR(1024) DEFAULT NULL COMMENT '简短描述',
    \`status\` INT NOT NULL COMMENT '状态枚举',
    \`update_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    \`create_time\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY(\`id\`),
    KEY \`idx_creator\` (\`creator_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题单表';

CREATE TABLE \`problemset_problem\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '题单-题目ID',
    \`problemset_id\` BIGINT  NOT NULL COMMENT '题单ID',
    \`problem_id\` BIGINT  NOT NULL COMMENT '题目ID',
    \`properties\` VARCHAR(1024) DEFAULT NULL COMMENT 'JSON',
    \`status\` INT NOT NULL COMMENT '状态枚举',
    PRIMARY KEY(\`id\`),
    KEY \`idx_problemset_id\`(\`problemset_id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题单-题目关系表';

CREATE TABLE \`tag\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '标签ID',
    \`name\` VARCHAR(32) NOT NULL COMMENT '标签名称',
    \`color\` VARCHAR(8) COMMENT '标签颜色',
    \`target_type\` INT NOT NULL COMMENT '目标主体类型',
    \`properties\` VARCHAR(1024) DEFAULT NULL COMMENT '配置项JSON',
    \`status\` INT NOT NULL COMMENT '状态枚举',
    PRIMARY KEY(\`id\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '标签表';

CREATE TABLE \`object_tag\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT '主体-标签ID',
    \`target_id\` BIGINT  NOT NULL COMMENT '主体ID',
    \`target_type\` INT NOT NULL COMMENT '目标主体类型',
    \`tag_id\` BIGINT  NOT NULL COMMENT '标签ID',
    \`status\` int NOT NULL COMMENT '状态',
    PRIMARY KEY (\`id\`),
    KEY \`idx_target_type_id\`(\`target_id\`, \`target_type\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '题目-标签关系表';

CREATE TABLE \`score\`(
    \`id\` BIGINT  NOT NULL AUTO_INCREMENT COMMENT 'ScoreID',
    \`name\` VARCHAR(32) NOT NULL COMMENT 'Score名称',
    \`target_type\` INT NOT NULL COMMENT '目标主体类型',
    \`target_id\` BIGINT  NOT NULL COMMENT '目标主体ID',
    \`agg_id\` BIGINT  NOT NULL COMMENT '聚合基准',
    \`value\` BIGINT  NOT NULL COMMENT '得分',
    \`status\` INT NOT NULL COMMENT '状态枚举',
    \`type\` INT NOT NULL COMMENT '类型',
    PRIMARY KEY(\`id\`),
    KEY \`idx_type_agg_id_status_value\` (\`type\`, \`agg_id\`, \`status\`, \`value\`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '得分表';
SQLEOF

docker pull mysql:8.0.30

a=`docker kill $3`
a=`docker rm $3`

docker run -itd --name $3 -p $2:3306 -v $(pwd)/conf:/etc/mysql/conf.d -v $(pwd)/data/:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=cugoj123456 mysql
echo 'docker已启动'

echo '等待docker就绪'
b=''
i=0
while [ $i -le 100 ]
do
 printf "[%-10s] %d%% \r" "$b" "$i";
 sleep 0.3
 ((i=i+1))
 b+='#'
done
echo

docker exec $3 sh /etc/mysql/conf.d/init.sh
