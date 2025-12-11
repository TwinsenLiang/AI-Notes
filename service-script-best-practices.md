# 通用服务管理脚本 service.sh 📦

写了个 API 服务，每次启动要打一堆命令？停止不知道 PID 是多少？日志不知道在哪看？

**别急！** 一个 `service.sh` 全搞定 😎

## 痛点：每次启动服务都要打一堆命令 😫

### 你可能是这样的

**启动服务**：
```bash
# Python 项目
source venv/bin/activate  # 先激活虚拟环境
pip install -r requirements.txt  # 装依赖
nohup python app.py > logs/app.log 2>&1 &  # 后台运行
echo $! > app.pid  # 保存 PID
```

**停止服务**：
```bash
# PID 是多少来着？
cat app.pid
kill 12345  # 希望没搞错
rm app.pid  # 记得删 PID 文件
```

**重启服务**：
```bash
# 先停止...再启动...
# 上面两套命令再来一遍 😭
```

**查看日志**：
```bash
# 日志在哪来着？
tail -f logs/app.log
```

### 痛点总结

- 😩 命令太长，每次都要查笔记
- 😩 PID 忘了，不知道怎么停
- 😩 多个项目，每个项目命令都不一样
- 😩 出了问题，不知道服务死没死
- 😩 重启很麻烦，停止+启动要敲两遍

---

## 用 service.sh 之后的生活 ✨

### 就是这么简单

```bash
./service.sh start    # 启动 → 1 秒搞定
./service.sh stop     # 停止 → 1 秒搞定
./service.sh restart  # 重启 → 1 秒搞定
./service.sh status   # 状态 → 1 秒搞定
./service.sh logs     # 日志 → 1 秒搞定
```

### 爽在哪里？

✅ **一个命令，统一天下**
```
Python 项目 → ./service.sh start
Node.js 项目 → ./service.sh start
Go 项目 → ./service.sh start
全部一样！记一个就够了！
```

✅ **自动化全包了**
- 自动后台运行（不用 nohup）
- 自动保存 PID（不用记）
- 自动记录日志（不用管）
- 自动检查状态（一眼就知道死没死）

✅ **防呆设计**
- 已经运行了？告诉你，不会重复启动
- 进程死了？自动清理 PID 文件
- 停不掉？优雅停止 → 强制停止，总能停下来

### 对比一下

| 操作 | 传统方式 | 用 service.sh |
|------|---------|---------------|
| 启动服务 | 打 3-4 行命令 | `./service.sh start` |
| 停止服务 | 找 PID → kill | `./service.sh stop` |
| 重启服务 | 停止+启动 | `./service.sh restart` |
| 查看状态 | 手动 ps 查 | `./service.sh status` |
| 看日志 | 找日志文件路径 | `./service.sh logs` |
| 多个项目 | 每个都不一样 | 全部一样！|

---

## 支持啥项目？ 🎯

- ✅ Python (Flask、FastAPI、Django...)
- ✅ Node.js (Express、Koa、Next.js...)
- ✅ Go 程序
- ✅ Java 程序
- ✅ 任何需要后台运行的东西

---

## 快速开始 🚀

### 1. 获取脚本

脚本位置：`~/Workspace/service.sh`

```bash
# 复制到你的项目目录
cp ~/Workspace/service.sh /path/to/your/project/
chmod +x service.sh
```

### 2. 修改配置（关键！）

打开 `service.sh`，修改文件顶部的配置变量（20-52 行）：

```bash
# ============================================================
# 配置变量 - 根据实际项目修改这些变量
# ============================================================

# 服务显示名称
SERVICE_NAME="我的API服务"

# 应用名称（用于标识）
APP_NAME="myapi"

# PID 文件路径
PID_FILE="app.pid"

# 日志文件路径
LOG_FILE="logs/app.log"

# 启动命令（根据项目类型修改）
START_CMD="python app.py"

# 服务端口（用于状态检查，可选）
SERVICE_PORT="5000"

# 是否启用 Python 虚拟环境 (true/false)
USE_VENV="true"

# 是否需要检查依赖 (true/false)
CHECK_DEPS="true"

# 依赖文件路径（如果 CHECK_DEPS=true）
DEPS_FILE="requirements.txt"
```

### 3. 使用脚本

```bash
# 启动服务
./service.sh start

# 查看状态
./service.sh status

# 查看实时日志
./service.sh logs

# 停止服务
./service.sh stop

# 重启服务
./service.sh restart
```

---

## 配置变量详解 📝

### 基础配置

| 变量 | 说明 | 示例 |
|------|------|------|
| `SERVICE_NAME` | 服务显示名称，用于界面显示 | `"图片处理API"` |
| `APP_NAME` | 应用标识，用于进程识别 | `"img_api"` |
| `PID_FILE` | PID 文件路径，存储进程号 | `"app.pid"` |
| `LOG_FILE` | 日志文件路径 | `"logs/app.log"` |

### 启动配置

| 变量 | 说明 | 示例 |
|------|------|------|
| `START_CMD` | 启动命令 | `"python app.py"` |
| `SERVICE_PORT` | 服务端口（可选） | `"5000"` |

**常见启动命令**:
```bash
# Python
START_CMD="python app.py"
START_CMD="python -m uvicorn main:app --host 0.0.0.0 --port 8000"

# Node.js
START_CMD="node app.js"
START_CMD="npm start"

# Go
START_CMD="./myapp"

# Java
START_CMD="java -jar app.jar"
```

### Python 专属配置

| 变量 | 说明 | 可选值 |
|------|------|--------|
| `USE_VENV` | 是否使用虚拟环境 | `"true"` / `"false"` |
| `CHECK_DEPS` | 是否检查依赖 | `"true"` / `"false"` |
| `DEPS_FILE` | 依赖文件路径 | `"requirements.txt"` |

**说明**:
- `USE_VENV="true"`: 脚本会自动激活 `venv/` 虚拟环境
- `CHECK_DEPS="true"`: 启动前会自动安装/更新依赖
- 其他语言项目设置为 `"false"` 即可

---

## 不同项目类型的配置示例 💼

### Python Flask 项目

```bash
SERVICE_NAME="Flask API服务"
APP_NAME="flask_api"
PID_FILE="flask.pid"
LOG_FILE="logs/flask.log"
START_CMD="python app.py"
SERVICE_PORT="5000"
USE_VENV="true"
CHECK_DEPS="true"
DEPS_FILE="requirements.txt"
```

### Python FastAPI 项目

```bash
SERVICE_NAME="FastAPI服务"
APP_NAME="fastapi_app"
PID_FILE="app.pid"
LOG_FILE="logs/api.log"
START_CMD="python -m uvicorn main:app --host 0.0.0.0 --port 8000"
SERVICE_PORT="8000"
USE_VENV="true"
CHECK_DEPS="true"
DEPS_FILE="requirements.txt"
```

### Node.js Express 项目

```bash
SERVICE_NAME="Express API"
APP_NAME="express_api"
PID_FILE="app.pid"
LOG_FILE="logs/app.log"
START_CMD="node app.js"
SERVICE_PORT="3000"
USE_VENV="false"
CHECK_DEPS="false"
DEPS_FILE=""
```

### Go 项目

```bash
SERVICE_NAME="Go Web服务"
APP_NAME="go_web"
PID_FILE="app.pid"
LOG_FILE="logs/app.log"
START_CMD="./myapp"
SERVICE_PORT="8080"
USE_VENV="false"
CHECK_DEPS="false"
DEPS_FILE=""
```

---

## 脚本功能详解 ⚙️

### start - 启动服务

**功能**:
1. ✅ 检查服务是否已运行（避免重复启动）
2. ✅ 检查 Python 虚拟环境（如果启用）
3. ✅ 安装/更新依赖（如果启用）
4. ✅ 后台启动服务
5. ✅ 保存 PID 到文件
6. ✅ 验证进程是否成功启动

**输出示例**:
```
==========================================
我的API服务 - 启动服务
==========================================
正在启动服务...
✓ 服务启动成功!
  PID: 12345
  访问地址: http://localhost:5000
  日志文件: logs/app.log

管理命令:
  ./service.sh status - 查看状态
  ./service.sh logs   - 查看日志
  ./service.sh stop   - 停止服务
```

---

### stop - 停止服务

**功能**:
1. ✅ 检查服务是否运行
2. ✅ 优雅停止（发送 SIGTERM）
3. ✅ 等待进程结束（最多 10 秒）
4. ✅ 如果优雅停止失败，强制停止（SIGKILL）
5. ✅ 清理 PID 文件

**输出示例**:
```
==========================================
我的API服务 - 停止服务
==========================================
正在停止服务 (PID: 12345)...
✓ 服务已优雅停止
```

---

### restart - 重启服务

**功能**:
1. ✅ 先停止服务
2. ✅ 再启动服务

**适用场景**:
- 更新代码后重启
- 修改配置后重启
- 服务出现问题需要重启

---

### status - 查看状态

**功能**:
1. ✅ 检查进程是否运行
2. ✅ 显示进程 ID
3. ✅ 显示启动时间
4. ✅ 显示 CPU 和内存使用率
5. ✅ 检查端口监听状态（如果配置了端口）

**输出示例**:
```
==========================================
我的API服务 - 服务状态
==========================================
服务状态: ✓ 正在运行
进程ID: 12345
启动时间: Tue Dec 10 10:30:00 2025
CPU使用: 2.5%
内存使用: 3.2%
命令行: python app.py

访问地址: http://localhost:5000
日志文件: logs/app.log

管理命令:
  ./service.sh logs     - 查看日志
  ./service.sh restart  - 重启服务
  ./service.sh stop     - 停止服务

端口监听状态:
  端口 5000: ✓ 正在监听
```

---

### logs - 查看日志

**功能**:
1. ✅ 实时显示日志（`tail -f`）
2. ✅ 按 Ctrl+C 退出

**输出示例**:
```
==========================================
我的API服务 - 实时日志
==========================================
按 Ctrl+C 退出日志查看

[2025-12-10 10:30:15] INFO: Server starting...
[2025-12-10 10:30:16] INFO: Listening on port 5000
[2025-12-10 10:32:20] INFO: GET /api/users 200 OK
```

---

## 常见使用场景 🎯

### 场景 1: 开发环境

**需求**: 本地开发，频繁重启

```bash
# 启动开发服务器
./service.sh start

# 修改代码后重启
./service.sh restart

# 查看日志调试
./service.sh logs
```

---

### 场景 2: 生产环境

**需求**: 稳定运行，定期检查

```bash
# 首次部署
./service.sh start

# 定期检查状态（可以加到 crontab）
./service.sh status

# 发布新版本
git pull
./service.sh restart
```

---

### 场景 3: 多个服务

**需求**: 同一台机器运行多个服务

```bash
# 项目结构
~/projects/
├── api_service/
│   └── service.sh
├── web_service/
│   └── service.sh
└── worker_service/
    └── service.sh

# 分别管理
cd ~/projects/api_service && ./service.sh start
cd ~/projects/web_service && ./service.sh start
cd ~/projects/worker_service && ./service.sh start
```

**配置要点**:
- 每个项目使用不同的 `APP_NAME`
- 使用不同的 `SERVICE_PORT`
- PID 和日志文件互不冲突

---

### 场景 4: 开机自动启动

**需求**: 服务器重启后自动启动服务

**方法 1: 使用 crontab**

```bash
# 编辑 crontab
crontab -e

# 添加以下行
@reboot cd /path/to/project && ./service.sh start
```

**方法 2: 使用 systemd**

创建 `/etc/systemd/system/myapp.service`:

```ini
[Unit]
Description=My App Service
After=network.target

[Service]
Type=forking
User=your_username
WorkingDirectory=/path/to/project
ExecStart=/path/to/project/service.sh start
ExecStop=/path/to/project/service.sh stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
# 启用服务
sudo systemctl enable myapp
sudo systemctl start myapp
```

---

## 最佳实践 ✨

### 1. 一个项目一个脚本

❌ **错误做法**
```
# 多个项目共用一个脚本
~/service.sh  # 用于所有项目？？？
```

✅ **正确做法**
```
# 每个项目有自己的 service.sh
~/project1/service.sh
~/project2/service.sh
~/project3/service.sh
```

---

### 2. 修改配置变量，不要改通用代码

**脚本结构**:
```bash
# ============================================================
# 配置变量 - 根据实际项目修改这些变量 (20-52 行)
# ============================================================
SERVICE_NAME="..."
START_CMD="..."
# ...

# ============================================================
# 以下为通用功能代码，一般不需要修改 (54 行以后)
# ============================================================
start_service() {
    # ...
}
```

**原则**:
- ✅ 只修改配置变量（20-52 行）
- ❌ 不要修改通用功能代码（54 行以后）

**好处**:
- 升级脚本时只需替换通用部分
- 减少出错概率
- 便于维护

---

### 3. 合理设置日志路径

❌ **不推荐**
```bash
LOG_FILE="app.log"  # 和代码文件混在一起
```

✅ **推荐**
```bash
LOG_FILE="logs/app.log"  # 单独的 logs 目录
```

**建议**:
- 日志放在 `logs/` 目录
- 添加到 `.gitignore`
- 定期清理旧日志

---

### 4. 虚拟环境管理

**Python 项目**:
```bash
# 首次运行前，手动创建虚拟环境
python3 -m venv venv

# 或者让脚本自动创建
USE_VENV="true"  # 脚本会自动检查并创建
```

**Node.js 项目**:
```bash
# 不需要虚拟环境
USE_VENV="false"
```

---

### 5. 端口配置

```bash
SERVICE_PORT="5000"  # 配置端口
```

**作用**:
- `status` 命令会检查端口是否在监听
- 显示访问地址

**如果不需要端口检查**:
```bash
SERVICE_PORT=""  # 留空
```

---

## 故障排查 🔍

### 问题 1: 启动失败

**现象**:
```
✗ 服务启动失败，请检查日志: logs/app.log
```

**排查步骤**:
1. 查看日志
   ```bash
   cat logs/app.log
   ```

2. 手动尝试启动命令
   ```bash
   # 查看配置的启动命令
   grep START_CMD service.sh

   # 手动执行看看报错
   python app.py
   ```

3. 检查依赖
   ```bash
   # Python 项目
   pip install -r requirements.txt

   # Node.js 项目
   npm install
   ```

---

### 问题 2: 停止失败

**现象**:
```
✗ 无法停止服务，请手动检查
```

**解决方案**:
```bash
# 查看 PID
cat app.pid

# 手动强制停止
kill -9 $(cat app.pid)

# 清理 PID 文件
rm app.pid
```

---

### 问题 3: 端口被占用

**现象**:
```
端口 5000: ✗ 未监听
```

但进程显示运行中

**排查**:
```bash
# 检查端口是否被其他进程占用
lsof -i :5000  # macOS/Linux
netstat -ano | findstr :5000  # Windows

# 修改配置使用其他端口
SERVICE_PORT="5001"
```

---

### 问题 4: PID 文件存在但进程不在

**现象**:
```
PID 文件存在但进程不存在，清理旧的 PID 文件
```

**原因**: 进程异常终止，没有清理 PID 文件

**解决**: 脚本会自动清理，然后可以重新启动

---

## 进阶技巧 🚀

### 1. 多实例运行

如果需要运行同一个应用的多个实例：

```bash
# 修改配置使用不同的端口和 PID
cp service.sh service1.sh
cp service.sh service2.sh

# service1.sh
SERVICE_PORT="5001"
PID_FILE="app1.pid"

# service2.sh
SERVICE_PORT="5002"
PID_FILE="app2.pid"
```

---

### 2. 环境变量配置

在启动命令中添加环境变量：

```bash
START_CMD="ENV=production PORT=5000 python app.py"
```

或者：

```bash
START_CMD="export ENV=production && python app.py"
```

---

### 3. 自定义启动参数

```bash
START_CMD="python app.py --config production.ini --workers 4"
```

---

### 4. 组合其他命令

```bash
# 启动前执行数据库迁移
START_CMD="python migrate.py && python app.py"
```

---

## 与 Claude Code 配合使用 🤖

### 让 Claude 帮你配置

```
我有一个 Flask 项目在 /home/user/myapi
端口是 5000，使用虚拟环境 venv
帮我配置 service.sh 脚本
```

Claude 会：
1. 读取 `~/Workspace/service.sh` 范本
2. 根据你的项目信息修改配置
3. 生成配置好的脚本到你的项目目录

---

### 让 Claude 生成项目和脚本

```
帮我创建一个 FastAPI 项目，包括：
1. 基本的 API 结构
2. requirements.txt
3. service.sh 服务管理脚本
```

---

## 总结 🎯

### 核心要点

1. **一个脚本，统一管理** - 所有服务用同样的命令
2. **只改配置，不改代码** - 修改 20-52 行配置变量即可
3. **自动化运行** - 后台运行、日志记录、进程管理
4. **完善功能** - 启动、停止、重启、状态、日志

### 使用流程

```
1. 复制脚本到项目目录
   ↓
2. 修改配置变量 (20-52 行)
   ↓
3. ./service.sh start
   ↓
4. 完成！
```

### 适用场景

- ✅ 开发环境本地测试
- ✅ 生产环境部署
- ✅ 多个服务管理
- ✅ 开机自动启动

---

## 延伸阅读 📚

- [用 Claude Code 解决电脑问题](./claude-solve-computer-problems.md) - AI 辅助解决技术问题
- [Claude Code 省钱小技巧](./claude-save-tokens-tips.md) - 高效使用 Claude

---

*最后更新: 2025-12-10*
