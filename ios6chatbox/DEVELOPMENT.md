# Development Guide

这份文档记录 `ios6chatbox` 的本地开发流程，目标是以后忘记环境怎么搭时，可以从安装 Theos、复制旧 iPhoneOS SDK、编译、打包到真机测试一路照着做。

项目目标平台优先是 `iOS 6` 真机，因此所有配置都按保守兼容路线处理。

## 1. 准备 macOS 环境

### 1.1 安装 Xcode

Theos 在 macOS 上需要完整 Xcode，只有 Command Line Tools 不够。

建议准备两类 Xcode：

- 当前可用的 Xcode：给 Theos 提供现代编译工具链。
- 旧 Xcode：只用于取旧版 `iPhoneOS*.sdk`。

如果机器上只能保留一个 Xcode，也可以把旧 Xcode 里的 SDK 单独复制出来，后续编译仍用当前 Xcode。

检查当前 Xcode：

```sh
xcode-select -p
xcodebuild -version
```

如果路径不对，切换到要使用的 Xcode：

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### 1.2 安装 Homebrew 依赖

```sh
brew install ldid make dpkg
```

说明：

- `ldid` 用于给越狱设备上的程序做伪签名。
- `make` 用于跑 Theos 的构建流程。
- `dpkg` 用于生成 `.deb` 包。

如果系统里同时存在 BSD make 和 GNU make，优先使用 Homebrew 安装的 GNU make。

检查：

```sh
make --version
ldid -v
dpkg-deb --version
```

## 2. 安装 Theos

官方安装命令：

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
```

安装完成后，确认 `THEOS` 路径：

```sh
echo "$THEOS"
ls "$THEOS"
```

如果 `echo "$THEOS"` 为空，把下面内容加入 `~/.zshrc`：

```sh
export THEOS="$HOME/theos"
export PATH="$THEOS/bin:$PATH"
```

然后重新加载 shell：

```sh
source ~/.zshrc
```

再次检查：

```sh
echo "$THEOS"
ls "$THEOS/makefiles"
```

## 3. 复制旧 iPhoneOS SDK

Theos 会从 `$THEOS/sdks/` 查找 SDK。旧 iOS 项目不要直接依赖最新 SDK 的行为，建议固定使用一个已验证的旧 SDK。

### 3.1 推荐 SDK 选择

优先顺序：

1. `iPhoneOS7.1.sdk`：通常来自 Xcode 5.1.1，适合以 `iOS 6` 为部署目标进行构建。
2. `iPhoneOS6.1.sdk`：通常来自 Xcode 4.6.x，更贴近 iOS 6，但现代 macOS 上搭配新工具链可能更容易遇到兼容问题。
3. `iPhoneOS9.3.sdk`：Theos 官方 patched SDK 仓库可获取，适合先验证 Theos 流程，但不是本项目的首选老设备基线。

实际开发中，先用 `iPhoneOS7.1.sdk + TARGET_OS_DEPLOYMENT_VERSION = 6.0` 建立基线，真机验证稳定后再决定是否切换更老 SDK。

### 3.2 从旧 Xcode 复制 SDK

假设旧 Xcode 放在 `/Applications/Xcode_5.1.1.app`：

```sh
mkdir -p "$THEOS/sdks"
cp -R "/Applications/Xcode_5.1.1.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk" "$THEOS/sdks/"
```

如果使用 Xcode 4.6.x 里的 iOS 6.1 SDK：

```sh
mkdir -p "$THEOS/sdks"
cp -R "/Applications/Xcode_4.6.3.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk" "$THEOS/sdks/"
```

检查复制结果：

```sh
ls "$THEOS/sdks"
ls "$THEOS/sdks/iPhoneOS7.1.sdk/System/Library/Frameworks/UIKit.framework"
```

### 3.3 从 Theos patched SDK 仓库复制 SDK

如果只是想先确认 Theos 能跑，可以使用 Theos patched SDK 仓库里的 SDK：

```sh
cd /tmp
git clone https://github.com/theos/sdks.git theos-sdks
mkdir -p "$THEOS/sdks"
cp -R /tmp/theos-sdks/iPhoneOS9.3.sdk "$THEOS/sdks/"
```

注意：patched SDK 适合 Theos 开发，但本项目仍要以 iOS 6 真机运行结果为准。

## 4. 项目 Makefile 基线

本项目后续接入 Theos 工程时，Makefile 建议使用下面这种保守配置：

```make
export THEOS ?= $(HOME)/theos

TARGET := iphone:clang:7.1:6.0
ARCHS := armv7

APPLICATION_NAME := ios6chatbox
ios6chatbox_FILES := main.m AppDelegate.m
ios6chatbox_FRAMEWORKS := UIKit Foundation CoreGraphics
ios6chatbox_CFLAGS := -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk
```

关键点：

- `iphone:clang:7.1:6.0` 表示使用 `iPhoneOS7.1.sdk`，部署目标为 `iOS 6.0`。
- `ARCHS := armv7` 适合常见 iOS 6 设备，比如 iPhone 4、iPhone 4S、iPhone 5。
- 如果要支持更老的 armv6 设备，需要单独评估工具链和 SDK，不作为当前默认目标。
- 如果代码不使用 ARC，把 `ios6chatbox_CFLAGS := -fobjc-arc` 删除。

如果使用 `iPhoneOS6.1.sdk`，改成：

```make
TARGET := iphone:clang:6.1:6.0
```

如果使用 `iPhoneOS9.3.sdk` 临时验证，改成：

```make
TARGET := iphone:clang:9.3:6.0
```

## 5. 编译

在项目根目录执行：

```sh
make clean
make
```

如果要看完整编译命令：

```sh
make messages=yes
```

如果改了头文件、资源文件、SDK 或 Makefile，优先重新完整构建：

```sh
make clean package
```

## 6. 打包

生成普通测试包：

```sh
make package
```

生成更接近发布的包：

```sh
make package FINALPACKAGE=1
```

打包完成后，产物在：

```sh
ls packages/
```

通常会看到类似：

```text
packages/com.example.ios6chatbox_0.0.1-1+debug_iphoneos-arm.deb
```

## 7. 安装到 iOS 6 真机

### 7.1 配置设备 IP

确认 iPhone 和 Mac 在同一网络，iPhone 已越狱并开启 SSH。

设置设备地址：

```sh
export THEOS_DEVICE_IP=192.168.1.23
export THEOS_DEVICE_PORT=22
```

可以写入 `~/.zshrc`，也可以只在当前终端临时设置。

测试 SSH：

```sh
ssh root@$THEOS_DEVICE_IP
```

iOS 6 越狱设备常见默认密码是 `alpine`。如果还没改密码，建议改掉。

### 7.2 编译并安装

```sh
make do
```

`make do` 等价于：

```sh
make package install
```

如果只想安装已经打好的包：

```sh
make install
```

### 7.3 手动安装 deb

如果自动安装失败，可以手动复制：

```sh
scp packages/*.deb root@$THEOS_DEVICE_IP:/tmp/
ssh root@$THEOS_DEVICE_IP
dpkg -i /tmp/*.deb
uicache
killall SpringBoard
```

如果 `killall SpringBoard` 后设备回到锁屏或桌面，是正常现象。

## 8. 本项目开发闭环

每轮开发建议按下面顺序做：

1. 修改一个小模块。
2. 本地执行 `make clean package`。
3. 执行 `make do` 安装到真机。
4. 在 iOS 6 真机上验证核心路径。
5. 记录失败现象、崩溃日志或网络错误。

第一阶段重点验证：

- App 能启动。
- 设置页能保存 `Base URL`、`API Key`、`Chat Model`。
- 能发起一轮文本聊天。
- 回复能显示。
- 重启 app 后历史会话仍在。

## 9. 常见问题

### 9.1 找不到 SDK

现象：

```text
Could not find SDK "iPhoneOS7.1.sdk"
```

检查：

```sh
echo "$THEOS"
ls "$THEOS/sdks"
```

确认 Makefile 里的 `TARGET := iphone:clang:7.1:6.0` 和 `$THEOS/sdks/iPhoneOS7.1.sdk` 名字一致。

### 9.2 找不到 UIKit/Foundation 头文件

检查 SDK 是否复制完整：

```sh
ls "$THEOS/sdks/iPhoneOS7.1.sdk/System/Library/Frameworks/Foundation.framework/Headers"
ls "$THEOS/sdks/iPhoneOS7.1.sdk/System/Library/Frameworks/UIKit.framework/Headers"
```

如果目录不存在，重新从旧 Xcode 复制 SDK。

### 9.3 链接失败或出现新系统符号

优先检查：

- Makefile 是否设置了 `TARGET := iphone:clang:7.1:6.0`。
- 代码是否调用了 iOS 7+ API。
- 新 API 是否需要 `respondsToSelector:` 保护。

iOS 6 项目里，宁可使用老 UIKit API，也不要为了写法现代而引入不稳定兼容风险。

### 9.4 安装后桌面没有图标

尝试：

```sh
ssh root@$THEOS_DEVICE_IP
uicache
killall SpringBoard
```

同时检查 app 的 `Info.plist` 是否包含正确的 bundle id、display name 和 executable name。

### 9.5 App 启动闪退

优先看设备日志：

```sh
ssh root@$THEOS_DEVICE_IP
tail -f /var/log/syslog
```

然后重新启动 app，记录崩溃附近的日志。

如果没有 syslog，可以安装 `syslogd` 或使用设备上的崩溃日志工具导出。

### 9.6 HTTPS 请求失败

iOS 6 的 TLS 和证书能力很老，现代 HTTPS 服务可能握手失败。

排查顺序：

1. 确认 `Base URL` 是服务根地址，例如 `https://example.com`，不要填完整 `/v1/chat/completions`。
2. 确认服务端支持旧设备能协商的 TLS 配置。
3. 如需中转，优先用自己的兼容代理服务，不要在客户端里关闭证书校验作为默认方案。

## 10. 参考资料

- Theos macOS 安装文档：https://theos.dev/docs/installation-macos
- Theos 命令说明：https://theos.dev/docs/commands
- Theos 变量说明：https://theos.dev/docs/variables
- Theos patched SDK 仓库：https://github.com/theos/sdks
