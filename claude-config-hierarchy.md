# CLAUDE.md 配置层级指南 📁

## 什么是 CLAUDE.md？

CLAUDE.md 是 Claude Code 的"记忆文件"。你可以把它理解成给 Claude 的小纸条，告诉它你喜欢什么风格、项目有什么规范、哪些事情要特别注意。

每次启动 Claude Code 时，它都会自动读取这些文件，就像每天早上看一遍备忘录一样～

## 配置层级 🎯

Claude Code 支持多层级配置，从全局到局部，各司其职：

```
~/.claude/CLAUDE.md             # 个人配置（全局生效）
    ↓
~/Workspace/CLAUDE.md           # 工作区配置（Workspace 目录下生效）
    ↓
~/Workspace/MyProject/CLAUDE.md # 项目配置（仅该项目生效）
```

### 配置优先级

- 所有层级的配置会**合并加载**，不是覆盖
- 越靠近项目目录的配置，优先级越高
- 适合把通用规则放上层，特殊规则放下层

## 各层级用途 📋

### 1. 个人配置 `~/.claude/CLAUDE.md`

适合存放你的个人偏好，在任何项目中都生效：

```markdown
# 个人工作偏好

## 语言
- 所有交互请使用中文

## 代码风格
- 使用清晰、描述性的变量名
- 添加适当的注释
- 保持代码简洁，遵循 DRY 原则

## Git 规范
- Commit 信息简洁明了
- 不添加 "Generated with Claude Code" 标记
```

### 2. 工作区配置 `~/Workspace/CLAUDE.md`

适合存放工作区级别的信息：

```markdown
# 工作区配置

## 项目列表
- ProjectA: 前端项目
- ProjectB: 后端服务
- ProjectC: 工具脚本

## 服务器信息
- 测试服务器: user@192.168.1.100
- 生产服务器: user@10.0.0.100

## 私有项目提醒
- ProjectC 包含敏感信息，注意保密
```

### 3. 项目配置 `~/Workspace/MyProject/CLAUDE.md`

适合存放项目特有的规范：

```markdown
# MyProject 项目配置

## 技术栈
- React + TypeScript
- Node.js 后端

## 开发规范
- 组件使用函数式写法
- 状态管理使用 Zustand

## 常用命令
- npm run dev: 启动开发服务器
- npm run test: 运行测试
```

## 动手实践 🛠️

### 创建个人配置

```bash
# 创建配置文件
mkdir -p ~/.claude
nano ~/.claude/CLAUDE.md
```

写入你的个人偏好，保存即可。

### 创建项目配置

```bash
# 进入项目目录
cd ~/Workspace/MyProject

# 创建配置文件
nano CLAUDE.md
```

### 查看当前加载的配置

在 Claude Code 中执行：

```
/memory
```

会列出所有已加载的配置文件。

## 实用技巧 💡

### 1. 使用 @ 导入其他文件

```markdown
# 项目配置
- 参考 @README.md 了解项目概述
- 开发规范见 @docs/coding-style.md
```

### 2. 常用配置项建议

| 配置项 | 说明 | 适合放在 |
|--------|------|----------|
| 语言偏好 | 中文/英文交互 | 个人配置 |
| 代码风格 | 命名规范、注释风格 | 个人配置 |
| Git 规范 | commit 格式 | 个人配置 |
| 服务器信息 | SSH 连接信息 | 工作区配置 |
| 项目列表 | 各项目简介 | 工作区配置 |
| 技术栈 | 框架、库版本 | 项目配置 |
| 常用命令 | 构建、测试命令 | 项目配置 |

### 3. 避免敏感信息

⚠️ **注意**：不要在 CLAUDE.md 中存放密码、API Key 等敏感信息！

## 小结 📝

- **个人配置**：你的专属风格，跟着你走
- **工作区配置**：团队共享信息，协作更顺畅
- **项目配置**：项目特有规范，精准高效

配置好这三层，Claude 就真正成为懂你的助手啦～

## 下一步 ⏭️

- [自动恢复会话配置](./claude-auto-resume-session.md) - 让 Claude 记住你们的对话
- [Claude Code 注册与安装指南](./claude-installation-guide.md) - 从零开始安装 Claude

---

*创建时间: 2025-11-21*
