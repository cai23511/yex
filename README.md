本项目可用于QuantumultX 1.07及以上版本，和Pharos Pro（iOS）tf1.3.3（36）及以上版本中

注意： 本项目图标可用于订阅，Task，策略组等位置的远程引用

Telegram频道： mini计划-图标聚合
Quantumult X使用方法：
1、订阅链接中引用
打开QuanX 配置文件-编辑，找到［server_remote］字段，在想要增加图标的相应订阅中修改，在enable＝true之前加上 img-url=https://raw.githubusercontent.com/Orz-3/mini/master/name.png 注意此句和前后句都要用英文逗号隔开，并且逗号后先要空一格

完整示例：https://raw.githubusercontent.com/crossutility/Quantumult-X/master/server-complete.txt, tag=Sample-02, as-policy=static, img-url=https://raw.githubusercontent.com/Orz-3/mini/master/name.png, enabled=false

2、策略组引用
2.1 如果通过as-policy生成策略组，会直接引用和订阅链接字段同样的图标，且无法更改

2.2 如果通过UI生成策略组，或者想直接在策略组中使用本项目图标，请打开QuanX 配置文件-编辑，找到［policy］字段，并在相应策略组中末尾，加上img-url=https://raw.githubusercontent.com/Orz-3/mini/master/name.png 注意同样要用英文逗号与前面句子隔开，并在逗号后面空一格

完整示例：static=policy-name-1, Sample-A, Sample-B, Sample-C, img-url=https://raw.githubusercontent.com/Orz-3/mini/master/name.png# yex
