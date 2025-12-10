# Claude Code 注册与安装指南 🚀

## 什么是 Claude Code？

Claude Code 是 Anthropic 公司推出的命令行 AI 编程助手。它可以帮你写代码、改 bug、管理文件、执行命令，简直就是程序员的贴心小助手～

## 注册账号

### 获取 API Key

你可以通过以下方式获取 API Key：

1. **Anthropic 官方**：访问 **https://console.anthropic.com/** 注册账号并获取 API Key
2. **第三方服务商**：也可以在像 **[https://aicodewith.com/](https://aicodewith.com/login?tab=register&invitation=MMEJVFQD)* 这样的第三方服务商获取

💡 **小提示**：国内用户访问官方网站可能需要配置代理。第三方服务商通常对国内网络更友好。

## 安装 Claude Code

### 系统要求

- macOS、Linux 或 Windows (WSL)
- Node.js 18+

### 安装命令

```bash
npm install -g @anthropic-ai/claude-code
```

### 验证安装

```bash
claude --version
```

看到版本号就说明安装成功了 🎉

## 配置 API

### 配置 API Token

```bash
# 将你的 API Key 添加到环境变量
echo 'export ANTHROPIC_AUTH_TOKEN="<你的API Key>"' >> ~/.zshrc

# 使配置生效
source ~/.zshrc
```

记得将 `<你的API Key>` 替换为你获取的实际 Key。

💡 **注意**：如果使用第三方服务商，可能需要额外配置 `ANTHROPIC_BASE_URL`，请参考服务商提供的文档。

### 验证配置

```bash
echo $ANTHROPIC_AUTH_TOKEN
# 应该显示你的 API Key
```

## 首次使用

```bash
# 启动 Claude Code
claude

# 试着打个招呼
> 你好，请介绍一下你自己
```

## 常见问题 🤔

### Q: 安装时提示权限错误？

```bash
# 方法1：使用 sudo
sudo npm install -g @anthropic-ai/claude-code

# 方法2：修复 npm 权限（推荐）
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g @anthropic-ai/claude-code
```

### Q: 命令找不到？

确保 npm 全局安装路径在 PATH 中：

```bash
# 添加到 ~/.zshrc
export PATH=$HOME/.local/bin:$PATH
source ~/.zshrc
```

### Q: 提示认证失败？

检查环境变量是否正确配置：

```bash
echo $ANTHROPIC_AUTH_TOKEN
```

## 下一步 ⏭️

安装完成后，建议阅读：
- [CLAUDE.md 配置层级指南](./claude-config-hierarchy.md) - 学习如何配置你的专属 Claude
- [自动恢复会话配置](./claude-auto-resume-session.md) - 让 Claude 记住你们的对话

---

*创建时间: 2025-11-21*
