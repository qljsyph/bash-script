# 自动系统信息显示脚本
适合armbian和debian系统server模式显示系统信息，使用前需看wiki。当前网络环境下如果无法拉取请尝试删除镜像加速地址，armbian和debian显示内容略有区别已基本满足使用。[请仔细阅读wiki]
# 版本
版本: 1.2.6
# 更新方式
重新执行一键脚本下载对应系统文件
## 一键脚本：
```
bash <(curl -sL https://ghfast.top/https://raw.githubusercontent.com/qljsyph/DPInfo-script/refs/heads/main/auto-sysinfo.sh)
```
# 系统信息显示内容
- **当前时间**
- **系统内核版本**
- **检测singbox版本提示更新**
- **singbox运行状态**
- **singbox内存占用**
- **singbox自启动状态**
- **防火墙状态**
- **自动更新配置文件状态**
- **cpu使用率**
- **内存使用率**
- **存储状况**
- **网络设置信息**
- **网络接口信息**
# 特殊新增
- **新增mihomo显示状态**
# Wiki
https://github.com/qljsyph/bash-script/wiki/bash%E2%80%90script说明
# 界面展示
- **Debian**
![Image text](https://raw.githubusercontent.com/qljsyph/bash-script/refs/heads/main/picture/1735899502390.jpg)
- **Armbian**
![Image text](https://raw.githubusercontent.com/qljsyph/bash-script/refs/heads/main/picture/1735899414883.jpg)
