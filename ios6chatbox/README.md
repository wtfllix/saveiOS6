# ios6chatbox

`ios6chatbox` 是一个面向 `iOS 6` 老设备的原生聊天客户端项目。

它的目标不是复刻某一个特定厂商的官方客户端，而是提供一个：

- 运行在老设备上的轻量聊天界面
- 可自定义 `API Base URL`
- 可自定义模型与服务提供商
- 尽量兼容 `OpenAI-compatible` 接口
- 可长期维护的最小工程

## 项目起点

当前路线基于对 `bag-xml/ChatGPT-for-Legacy-iOS` 的分析。

那个项目已经证明了这些事情是可行的：

- `iOS 6` 真机可以运行原生 AI 聊天客户端
- 旧式 `Objective-C + UIKit` 方案足够支撑基础聊天体验
- 侧边栏、历史会话、图片附件这些交互都可以落地

但它也有几个不适合直接继承的点：

- 强绑定 `OpenAI / ChatGPT`
- 网络层与产品逻辑耦合过深
- 会话持久化位置不适合长期使用
- TLS 与证书校验策略不适合作为正式产品方案

所以 `ios6chatbox` 的方向是：

保留老 iOS 原生客户端的轻量结构，重做配置层、网络层和产品定位。

## 第一阶段目标

第一阶段只做一个最小可用版本：

- 启动 app
- 配置 `Base URL`
- 配置 `API Key`
- 配置 `Chat Model`
- 发起文本聊天请求
- 正常显示回复
- 保存并加载历史会话

第一阶段暂时不追求：

- 多 provider 深度适配
- 复杂参数面板
- 完整图片能力
- 高级账号系统

## 文档

- [ROADMAP.md](/Users/lx/projects/ios6things/ios6chatbox/ROADMAP.md)
- [ARCHITECTURE.md](/Users/lx/projects/ios6things/ios6chatbox/ARCHITECTURE.md)
- [DEVELOPMENT.md](/Users/lx/projects/ios6things/ios6chatbox/DEVELOPMENT.md)
