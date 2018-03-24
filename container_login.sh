#! /bin/bash

## use login_service.sh dev erp-backend

## 设置环境变量
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin;
export PATH;

loginUser="root";

serviceIp="111.231.75.205";

servicePort="2222";

## 要登录的环境 DEV/TEST
if [[ ! -n $1 ]]; then
	echo "请输入要登录的环境";
	echo "示例：$0 dev/test"
	exit -1;
fi

serviceEnv=$1;

if [[ $serviceEnv != 'dev' &&  $serviceEnv != 'test' ]]; then
    echo '登录的环境不合法:dev/test';
    exit -1;
fi

## DEV 转换为大写
serviceEnv=$(echo $serviceEnv |tr '[:lower:]' '[:upper:]')

## chedianAI 容器的正则匹配
chedianAiReg="r-CHEDIANAI-$serviceEnv-chedianai-[^redis]"

## 登录主机
lineCount=$(ssh $loginUser@$serviceIp -p $servicePort docker ps |grep -E $chedianAiReg |wc -l);


if [[ $lineCount -gt 1 ]]; then
	echo "查找到的微服务不止一个，请重新输入，精确搜索！"
	exit -1;
fi

services=$(ssh $loginUser@$serviceIp -p $servicePort docker ps |grep -E $chedianAiReg);


if [[ $lineCount -eq 0 ]]; then
	echo "未发现符合规则的容器";
	exit -1;
fi

for word in $services
do
	containerId=$word;
	break;
done

ssh $loginUser@$serviceIp -p $servicePort -t "docker exec -it $containerId /bin/bash"