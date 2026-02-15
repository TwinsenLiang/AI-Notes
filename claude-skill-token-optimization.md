# Claude Code Skill 节省 Token 的实战案例

## 目录

- [背景](#背景)
- [问题分析](#问题分析)
- [解决方案](#解决方案)
- [实施步骤](#实施步骤)
- [效果对比](#效果对比)
- [最佳实践](#最佳实践)
- [推广价值](#推广价值)

---

## 背景

### 重复性任务的 Token 浪费

在使用 Claude Code 进行项目开发时,经常需要为新项目配置标准化的服务管理脚本 (`service.sh`)。传统流程如下:

1. 读取模板文件 `~/Sites/service.sh.template` (约 700 行,~2000 tokens)
2. 读取示例文件了解配置方法 (约 575 行,~1600 tokens)
3. 分析项目需求并确定配置变量 (~500 tokens)
4. 生成并写入 service.sh 文件 (~3000 tokens)

**单次总计**: 约 7100 tokens
**10 个项目**: 71,000 tokens

这种重复性任务每次都要消耗大量 token,而且容易出错。

---

## 问题分析

### Token 消耗分析

```
原始流程 Token 分布:
┌─────────────────────────────────────┐
│ 读取模板文件     2000 tokens (28%) │
│ 读取示例文件     1600 tokens (23%) │
│ 分析项目需求      500 tokens (7%)  │
│ 生成配置文件     3000 tokens (42%) │
├─────────────────────────────────────┤
│ 总计            7100 tokens        │
└─────────────────────────────────────┘
```

### 核心问题

1. **重复读取大文件**: 每次都要读取 700 行的模板
2. **缺乏自动化**: 手动分析项目类型和配置变量
3. **无记忆能力**: 每次对话都要重新学习模板结构

---

## 解决方案

### Skill 化思路

**核心理念**: 将"项目服务标准化配置"能力转化为 Claude Code Skill

**优势**:
1. **模板内嵌**: 模板直接嵌入 Skill,无需读取外部文件
2. **自动触发**: 识别关键词自动加载 Skill
3. **标准化流程**: 提供明确的执行步骤和检查清单

### 技术架构

```
用户说"请标准化配置项目"
        ↓
Claude 识别关键词 (0 额外 tokens)
        ↓
加载 Skill (约 600 tokens,按需加载)
        ↓
按照 Skill 指引执行 (约 2600 tokens)
        ↓
生成 service.sh (约 3200 tokens 总计)
```

---

## 实施步骤

### Phase 1: Skill 文件设计

**文件位置**: `~/.claude/skills/standardize-project.md`

**文件结构**:
```markdown
---
name: "standardize-project"
description: "为项目创建标准化的 service.sh 服务管理脚本"
version: "1.0.0"
---

# 项目服务标准化 Skill

## 触发关键词
- "请标准化配置项目"
- "创建 service.sh"
...

## 标准化流程

### 步骤 1: 项目信息收集
...

### 步骤 2: 生成 service.sh 文件

**完整模板内嵌在这里** (使用 {{占位符}})

### 步骤 3: 设置可执行权限
...
```

**关键优化**:
- ❌ 不再保留外部模板文件
- ✅ 模板完整内嵌到 Skill (使用 `{{变量名}}` 占位符)
- ✅ 提供项目类型自动检测规则
- ✅ 包含 MagicMirror 等特殊项目处理逻辑

### Phase 2: 项目类型自动检测

```bash
# Python 项目
if [ -f "requirements.txt" ]; then
    PROJECT_TYPE="python"
    USE_VENV="true"
    START_CMD="python3 app.py"
fi

# Node.js 项目
if [ -f "package.json" ]; then
    PROJECT_TYPE="nodejs"
    USE_VENV="false"
    START_CMD="npm start"
fi

# MagicMirror 项目 (特殊处理)
if [ -f "js/electron.js" ]; then
    PROJECT_TYPE="magicmirror"
    START_CMD="DISPLAY=:0 ./node_modules/.bin/electron js/electron.js"
fi
```

### Phase 3: 配置变量智能推断

| 变量 | 推断规则 | 示例 |
|------|---------|------|
| SERVICE_NAME | 目录名 + "服务" | "MyApp 服务" |
| APP_NAME | 目录名小写 | "myapp" |
| START_CMD | 检测主文件 | "python3 app.py" |
| SERVICE_PORT | 搜索代码 | "5000" |
| USE_VENV | 项目类型判断 | "true" (Python) |

---

## 效果对比

### Token 消耗对比

**原始流程** (无 Skill):
```
读取 service.sh.template     2000 tokens
读取示例文件               1600 tokens
分析项目需求                500 tokens
生成 service.sh            3000 tokens
────────────────────────────────────
总计                      7100 tokens
```

**使用 Skill 后**:
```
识别意图 + 加载 Skill        600 tokens
项目类型检测                100 tokens
生成 service.sh            2500 tokens
────────────────────────────────────
总计                      3200 tokens
```

### 节省效果

| 指标 | 原始流程 | 使用 Skill | 节省 |
|-----|---------|-----------|------|
| 单次 Token | 7100 | 3200 | **3900 (55%)** |
| 10 个项目 | 71,000 | 32,000 | **39,000 (55%)** |
| 100 个项目 | 710,000 | 320,000 | **390,000 (55%)** |

### 质量提升

除了 Token 节省,还带来以下提升:

✅ **零错误率**: 自动检测项目类型,避免手动配置错误
✅ **标准化**: 所有项目使用统一的服务管理脚本
✅ **可维护性**: 更新模板只需修改 Skill 文件
✅ **用户体验**: 一句话触发,无需重复说明需求

---

## 最佳实践

### 何时应该创建 Skill

创建 Skill 的判断标准:

1. **高频重复**: 任务至少执行 5 次以上
2. **Token 消耗大**: 单次任务 > 3000 tokens
3. **流程标准化**: 任务有明确的执行步骤
4. **可模板化**: 核心逻辑可以提取为模板

**适合 Skill 化的任务**:
- ✅ 项目初始化 (service.sh, README.md, .gitignore)
- ✅ 代码规范检查 (ESLint, Prettier 配置)
- ✅ CI/CD 配置生成
- ✅ 文档生成 (API 文档, 架构图)

**不适合 Skill 化的任务**:
- ❌ 一次性任务
- ❌ 高度定制化任务
- ❌ 需要大量用户交互的任务

### 如何设计高效的 Skill

#### 1. 模板内嵌 vs 外部文件

**优先选择**: 模板内嵌

```markdown
# ✅ 推荐: 模板内嵌
## 步骤 2: 生成配置文件

```bash
#!/bin/bash
SERVICE_NAME="{{SERVICE_NAME}}"
...
完整模板内容
```

# ❌ 不推荐: 引用外部文件
读取 ~/templates/service.sh.template
```

**原因**:
- 减少文件 I/O (节省 2000+ tokens)
- 避免外部依赖
- 版本控制更简单

#### 2. 占位符命名规范

使用明确的占位符:
```bash
# ✅ 明确
{{SERVICE_NAME}}
{{START_CMD}}
{{SERVICE_PORT}}

# ❌ 模糊
{{NAME}}
{{CMD}}
{{PORT}}
```

#### 3. 提供检测规则

在 Skill 中包含自动检测逻辑:

```markdown
## 项目类型检测

```bash
# Python 项目
if [ -f "requirements.txt" ]; then
    USE_VENV="true"
fi

# Node.js 项目
if [ -f "package.json" ]; then
    USE_VENV="false"
fi
```
```

#### 4. 错误处理

明确指出缺少必需参数时的处理:

```markdown
## 缺少必需参数时

如果无法确定 START_CMD:
1. 询问用户主启动文件
2. 或生成仅包含 help 功能的 service.sh
3. 提示用户补充配置后重新运行
```

### Token 优化技巧

1. **懒加载**: Skill 只在需要时加载 (~600 tokens)
2. **增量生成**: 先生成配置,再填充模板 (分步执行)
3. **缓存结果**: 相同项目类型复用检测结果
4. **精简描述**: Skill 描述简洁明了 (避免冗长说明)

---

## 推广价值

### 为什么要分享这个经验

1. **成本节省**: 帮助其他开发者节省 AI 使用成本
2. **效率提升**: 标准化流程提高开发效率
3. **最佳实践**: 展示 Skill 化的正确姿势
4. **社区贡献**: 推动 Claude Code 生态发展

### 实际收益计算

假设:
- 每月配置 10 个项目
- Claude Code API 费用: $15 / 1M tokens (Sonnet 4.5)

**月度节省**:
```
传统方式: 71,000 tokens × $15 / 1M = $1.07
Skill 方式: 32,000 tokens × $15 / 1M = $0.48
────────────────────────────────────
每月节省: $0.59
年度节省: $7.08
```

虽然单个任务节省不多,但:
- **累积效应**: 多个 Skill 叠加效果显著
- **时间价值**: 减少重复劳动,专注核心开发
- **质量保证**: 避免手动错误导致的返工成本

### 可复用的 Skill 开发框架

基于这个案例,可以总结出通用的 Skill 开发框架:

```markdown
---
name: "skill-name"
description: "简短描述"
version: "1.0.0"
---

# Skill 名称

## 触发关键词
- 关键词1
- 关键词2

## 执行流程

### 步骤 1: 信息收集
- 自动检测规则
- 用户确认项

### 步骤 2: 生成内容
- 模板内容 (使用占位符)

### 步骤 3: 验证结果
- 检查清单

## 示例
- 示例 1
- 示例 2
```

---

## 扩展可能

### 多 Skill 组合

可以创建 Skill 组合链:

```
standardize-project (生成 service.sh)
    ↓
git-init (初始化 Git 仓库)
    ↓
readme-generator (生成 README.md)
    ↓
github-actions (生成 CI/CD 配置)
```

一句话触发完整的项目初始化流程。

### 团队共享 Skill 库

将 Skill 文件存储在团队共享仓库:

```bash
~/.claude/skills/
├── company/
│   ├── project-init.md
│   ├── api-doc-gen.md
│   └── deploy-config.md
└── personal/
    └── standardize-project.md
```

通过 Git 同步,团队成员共享最佳实践。

### Skill 版本管理

在 Skill 文件中包含版本信息:

```yaml
---
version: "1.2.0"
changelog:
  - "v1.2.0: 添加 MagicMirror 项目支持"
  - "v1.1.0: 优化 Node.js 项目检测"
  - "v1.0.0: 初始版本"
---
```

---

## 总结

### 核心要点

1. **识别高频任务**: 重复性 > 5 次,Token > 3000 的任务
2. **模板内嵌**: 避免读取外部文件,节省 2000+ tokens
3. **自动检测**: 提供智能推断规则,减少用户输入
4. **标准化流程**: 明确的步骤和检查清单

### 收益

- **Token 节省**: 55% (单项目 3900 tokens)
- **零错误率**: 自动检测避免配置错误
- **可维护性**: 集中管理,易于更新
- **用户体验**: 一句话触发,简单高效

### 下一步

1. 为其他高频任务创建 Skill
2. 建立团队 Skill 库
3. 分享到 Claude Code 社区

---

## 附录

### Skill 文件位置

```bash
~/.claude/skills/standardize-project.md
```

### 相关文档

- [Claude Code Skill 开发指南](https://docs.anthropic.com/claude-code/skills)
- [Token 优化技巧](claude-save-tokens-tips.md)
- [服务脚本最佳实践](service-script-best-practices.md)

### 版本历史

- **v1.0.0** (2026-01-17): 初始版本,支持 Python/Node.js/Go/MagicMirror 项目

---

**作者**: Twinsen Liang
**日期**: 2026-01-17
**标签**: #claude-code #skill #token-optimization #automation
