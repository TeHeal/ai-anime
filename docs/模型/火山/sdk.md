
<span id="f116fb9f"></span>
# Go SDK
<span id="0fa8c2bc"></span>
## 前提条件
检查 Go 版本，需 1.18 或以上。
```Bash
go version
```

如未安装或版本不满足，可访问 [Go 语言官方网站](https://golang.google.cn/dl/)下载并安装，请选择 1.18 或以上版本。
<span id="ae8b42ab"></span>
## 安装 Go SDK

1. Go SDK 使用 go mod 管理，可运行以下命令初始化 go mod。`<your-project-name>` 替换为项目名称。

```Bash
# 如在文件夹 ark-demo 下打开终端窗口，运行命令go mod init ark-demo
go mod init <your-project-name>
```


2. 在本地初始化 go mod 后，运行以下命令安装最新版 SDK。

```Bash
go get -u github.com/volcengine/volcengine-go-sdk 
```

:::tip
如需安装特定版本的SDK，可使用命令：
`go get -u github.com/volcengine/volcengine-go-sdk@<VERSION>`
其中`<VERSION>`替换为版本号。SDK 版本可查询： https://github.com/volcengine/volcengine-go-sdk/releases
:::

3. 在代码中引入 SDK 使用。

```Go
import "github.com/volcengine/volcengine-go-sdk/service/arkruntime"
```


4. 更新依赖后，使用命令整理依赖。

```Bash
go mod tidy
```

<span id="f0739bb0"></span>
## 升级 Go SDK
步骤与安装 Go SDK相同，可参考[安装 Go SDK](/docs/82379/1541595#ae8b42ab)，第1，2步升级至最新/指定版本SDK。

* 升级至最新版本

```Bash
go get -u github.com/volcengine/volcengine-go-sdk
```


* 升级至指定版本

```Bash
go get -u github.com/volcengine/volcengine-go-sdk@<VERSION>
```
