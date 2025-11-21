# Claude Code 自动恢复会话配置 🔄

## 痛点：每次都要重新介绍自己？

刚开始用 Claude Code 的时候，是不是遇到过这样的尴尬：

- 早上聊到一半，午饭后再打开，Claude 忘了你是谁 😅
- 重启电脑后，之前的讨论全都找不到了
- 每次都要重新解释项目背景，累不累啊

别担心！通过简单配置，就能让 Claude 拥有"记忆"，自动恢复上次的对话～

## 恢复会话的几种方式 🛠️

| 命令 | 说明 | 适合场景 |
|------|------|----------|
| `claude --resume` 或 `-r` | 恢复会话，会出现选择界面 | 想从历史会话中挑一个恢复 |
| `claude --continue` 或 `-c` | 直接恢复最近的会话 | 就想接着上次的继续聊（推荐） |
| `claude --history` | 查看历史对话列表 | 想看看之前都聊了什么 |
| `claude --resume <session-id>` | 恢复指定会话 | 知道具体会话 ID |

## 一劳永逸的配置方法 ⚙️

只需三步，让 Claude 永远记得你～

### 步骤 1：打开配置文件

```bash
# zsh 用户（Mac 默认）
nano ~/.zshrc

# bash 用户
nano ~/.bashrc
```

💡 **不知道用哪个？** 执行 `echo $SHELL` 看看输出，包含 `zsh` 就用第一个，包含 `bash` 就用第二个。

### 步骤 2：添加别名

在文件**最后面**添加这几行：

```bash
# Claude Code 自动恢复上次对话
alias claude="claude --continue"

# 可选：更短的别名，输入 AI 就能启动
alias AI="claude --continue"
```

保存文件（Ctrl + O，然后回车，再 Ctrl + X 退出）。

### 步骤 3：让配置生效

```bash
# 重新加载配置
source ~/.zshrc
# 或
source ~/.bashrc
```

✅ 搞定！

## 开始使用 🎮

配置完成后，享受丝滑体验：

```bash
# 方式 1：直接输入 claude，自动恢复上次对话
claude

# 方式 2：更简短（如果你配置了 AI 别名）
AI
```

🎉 看！Claude 还记得你们上次聊到哪儿～

### 偶尔想开新会话怎么办？

```bash
# 绕过别名，启动全新会话
command claude

# 或者用完整路径
/usr/local/bin/claude
```

## 小贴士 💡

### 会话保存在哪里？

所有会话记录都保存在 `~/.claude/history.jsonl` 文件中，Claude Code 会自动管理，无需手动维护。

### 会话太多了怎么办？

```bash
# 查看所有历史会话
claude --history

# 然后可以选择删除不需要的
```

## 常见问题 🤔

### Q: 配置后还是没生效？

记得执行 `source ~/.zshrc` 重新加载配置，或者重启终端窗口。

### Q: 我想恢复更早的会话？

```bash
# 查看历史
claude --history

# 选择想恢复的会话 ID
claude --resume <session-id>
```

## 下一步 ⏭️

现在 Claude 会记得你了！接下来可以：
- [CLAUDE.md 配置层级指南](./claude-config-hierarchy.md) - 教 Claude 你的个人风格
- [Claude Code 注册与安装指南](./claude-installation-guide.md) - 帮朋友也装一个

---

*创建时间: 2025-11-21*
