#### telegram频道地址：[yex图标包](https://t.me/yex031)
#### 如果图标组内没有你想要的图标，可以直接在Issues内留言，我看到后会更新。
## 本项目可用于QuantumultX 1.07及以上版本
#### 注意： 本项目图标可用于订阅，Task，策略组等位置的远程引用
##### Quantumult X使用方法： 
###### 1、订阅链接中引用 
打开QuanX 配置文件-编辑，找到［server_remote］字段，在想要增加图标的相应订阅中修改，在enable＝true之前加上 img-url=https://raw.githubusercontent.com/cai23511/yex/master/name.png

*完整示例：*

https://raw.githubusercontent.com/crossutility/Quantumult-X/master/server-complete.txt, tag=Sample-02, as-policy=static, https://raw.githubusercontent.com/cai23511/yex/master/name.png, enabled=false

注意此句和前后句都要用英文逗号隔开，并且逗号后先要空一格
###### 2、策略组引用 
如果通过as-policy生成策略组，会直接引用和订阅链接字段同样的图标，且无法更改

##### 如果通过UI生成策略组，或者想直接在策略组中使用本项目图标，请打开QuanX 配置文件-编辑，找到［policy］字段，并在相应策略组中末尾，加上img-url=https://raw.githubusercontent.com/cai23511/yex/master/name.png 注意同样要用英文逗号与前面句子隔开，并在逗号后面空一格

*完整示例：*

static=policy-name-1, Sample-A, Sample-B, Sample-C, img-url=https://raw.githubusercontent.com/cai23511/yex/master/name.png
#### 重启 Quantumult X 即可见到效果。
更新方法：当远程图标更新时，请手动清理本地图标缓存(打开“文件”应用，依次进入“我的 iPhone 或 iCloud Drive-Quantumult X-Images”，删除Images文件夹内所有缓存文件)，并重启 Quantumult X，远程图标会重新下载并生效。
