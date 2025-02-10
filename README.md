## 设置默认端口为8080 用户名:root 密码为:admin
 # 安装&升级

```
apk add curl && apk add bash && bash <(curl -Ls https://raw.githubusercontent.com/CNFs404/Alpine-x-ui-Ms404/main/alpine-xui.sh)
```
仅支持Alpine linux 安装  
支持x86与arm64架构的小鸡安装
# 部分问题解决方案
若跑太猛，面板crashed了，请使用以下命令重启面板
```
/etc/init.d/x-ui restart
```
特别感谢mocikate大佬，安装脚本有部分参考其脚本并修改  
感谢F大编译维护的x-ui
