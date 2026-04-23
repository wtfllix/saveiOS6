# Architecture

## MVP 目标

第一版只解决一个问题：

让 `iOS 6` 设备上的原生客户端可以连接一个用户自定义的 `OpenAI-compatible` 聊天接口。

## 模块划分

建议按下面 5 个模块组织。

### 1. App Shell

职责：

- 启动 app
- 管理导航结构
- 承载欢迎页、聊天页、侧边栏

这一层尽量保留原项目已有 UI 结构，减少大改动。

### 2. Settings / Provider Config

职责：

- 读取与保存 provider 配置
- 暴露统一配置对象
- 为网络层提供 endpoint、鉴权信息和模型名

建议配置对象字段：

- `displayName`
- `baseURL`
- `apiKey`
- `chatPath`
- `chatModel`
- `imagePath`
- `imageModel`

第一版不要做 provider 列表或插件机制。

### 3. Chat Service

职责：

- 构造聊天请求
- 发起网络调用
- 解析响应
- 映射为 app 内部消息对象

建议拆成三个小职责：

- `CGProviderConfig`
- `CGRequestBuilder`
- `CGChatService`

这样比把全部逻辑继续塞在一个 `CGAPICommunicator` 里更稳。

### 4. Conversation Store

职责：

- 保存消息历史
- 加载会话列表
- 删除会话
- 更新标题

建议：

- 第一版继续用 JSON 文件
- 但路径迁到长期目录
- 不急着上 SQLite

### 5. Presentation Helpers

职责：

- 文本高度计算
- Markdown 基础渲染
- 错误信息转用户可见文案

这部分继续保持简单，避免新引入复杂渲染器。

## 推荐的数据流

```text
UI
-> Provider Config
-> Request Builder
-> Chat Service
-> Response Parser
-> Message Model
-> Conversation Store
-> UI refresh
```

## 配置设计

第一版统一假设所有服务都尽量兼容 OpenAI 风格。

### 最小必要配置

- `Base URL`
- `API Key`
- `Chat Model`

### 带默认值的配置

- `Chat Path` 默认 `/v1/chat/completions`
- `Image Path` 默认 `/v1/images/generations`

### 后续可扩展配置

- `System Prompt`
- `Temperature`
- `Max Tokens`
- `Extra Header`
- `Request Timeout`

## 网络层改造建议

### 当前样板的问题

- domain 硬编码
- 登录逻辑与 provider 绑定
- 响应解析与请求构造耦合
- 错误处理分散

### 新结构建议

保留原有类名也可以，但职责要调整：

- `CGAPIHelper`
  负责提示、转换和通用工具
- `CGProviderConfig`
  负责读取配置
- `CGAPICommunicator`
  只负责发请求
- `CGChatService`
  负责聊天业务流程

### 第一版响应兼容假设

聊天响应优先解析：

- `choices[0].message.content`

如果未来某些 provider 返回轻微差异结构，再在解析器里加兼容分支。

## 存储设计

### 当前样板问题

- 会话写在临时目录
- 用户头像和会话文件混在一起

### 建议方案

- `Library/Application Support/Conversations/`
- `Library/Application Support/Caches/`

文件示意：

```text
Application Support/
  Conversations/
    <uuid>.json
  Caches/
    avatar.png
```

## MVP 范围边界

### 本轮必须做

- 自定义 provider 配置
- 文本聊天
- 历史保存
- 真机可运行

### 本轮可延后

- 图片生成
- 图片理解
- 多 provider 管理
- 高级参数面板
- 复杂网络诊断

## 开发顺序建议

1. 复制并建立本地代码基线
2. 去掉强绑定登录流程
3. 引入 provider 配置对象
4. 替换聊天请求构造
5. 跑通文本聊天
6. 迁移存储路径
7. 再做文案与命名收口
