# Self-Host Claude Marketplace

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

一个 **个人自托管的 Claude Code 插件市场（Plugin Marketplace）**，为 Claude Code 用户集中分发和安装自定义插件。

## 概述

Claude Code 的插件系统允许你通过 Skills、Agents、Hooks、MCP 服务器等扩展其能力。本仓库将所有精心挑选的插件打包到一个 **marketplace** 中，你可以：

- 一键将多个插件添加到你的 Claude Code 工作流
- 集中管理插件版本和更新
- 与团队或社区共享插件集合

## 核心概念

- **Marketplace**：一个目录，列出并分发多个 Plugin。每个用户只能为一个名称注册一个 Marketplace。
- **Plugin**：将来自不同源的 Skills、Agents、Hooks、MCP 服务器打包在一起的单元。
- **Skill**：一个 Markdown 文件，定义 Claude Code 在特定任务上的行为。

## 当前收录的插件

| 插件 | 版本 | 描述 | 作者 |
|------|------|------|------|
| **rust-skills** | 2.1.0 | 全面的 Rust 开发助手，包含元问题路由、编码规范、版本查询和生态系统支持 | ZhangHanDong |
| **search** | 1.0.0 | 综合网络搜索与调研工具 —— Tavily MCP (搜索/提取), Tavily CLI 技能 (搜索/提取/爬取/映射/研究), agent-browser 浏览器自动化 | lywa1998 |
| **isaac-sim** | 1.0.0 | NVIDIA Isaac Sim 具身智能开发工具包 —— 场景编排、机器人资产管线、物理仿真、导航、抓取、传感器、渲染、SDG、USD 管线等完整技能链 | lywa1998 |
| **tools** | 1.0.0 | 实用工具 —— book-to-skill 转换器等 | — |
| **finance** | 1.0.0 | 金融交易技能 —— Hyperliquid 跟单交易、蜡烛图技术分析 | — |
| **science** | 1.0.0 | AI 科研助手 —— 基于 alphaXiv MCP，发现论文、读取内容、查询 PDF、探索 GitHub 代码、管理文献库 | lywa1998 |

## 快速开始

### 添加本 Marketplace

```bash
# 从 GitHub 添加
claude plugin marketplace add lywa1998/self-host-claude-marketplace

# 或克隆后本地添加
git clone https://github.com/lywa1998/self-host-claude-marketplace.git
cd self-host-claude-marketplace
claude plugin marketplace add .
```

### 安装插件

```bash
# 安装 Rust 开发助手
claude plugin install rust-skills@self-host

# 安装搜索与调研工具
claude plugin install search@self-host

# 安装 Isaac Sim 具身智能开发工具
claude plugin install isaac-sim@self-host

# 安装工具集
claude plugin install tools@self-host

# 安装金融交易技能
claude plugin install finance@self-host
```

### 验证配置

```bash
# 验证 marketplace 配置
claude plugin validate .

# 验证单个插件
claude plugin validate ./plugins/rust
```

### 更新插件

```bash
# 刷新所有 Marketplace
claude plugin marketplace update

# 更新单个插件
claude plugin update rust-skills@self-host
```

## 项目结构

```
.
├── .claude-plugin/
│   └── marketplace.json          # Marketplace 清单（插件列表）
├── CLAUDE.md                     # 项目指令（Claude Code 专用）
├── plugins/
│   ├── rust/                     # Rust 开发插件
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json       # 插件元数据
│   │   ├── skills/               # 24 个 Rust 开发 Skills
│   │   ├── agents/               # 后台代理
│   │   ├── hooks/                # 关键词触发钩子
│   │   ├── scripts/              # 辅助脚本
│   │   ├── .mcp.json             # MCP 服务器配置
│   │   └── README.md
│   ├── search/                   # 搜索与调研插件
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── .mcp.json             # Tavily 远程 MCP 服务器配置
│   │   └── skills/
│   │       ├── agent-browser/    # 浏览器自动化
│   │       ├── tavily-search/    # Tavily 搜索
│   │       ├── tavily-extract/   # 内容提取
│   │       ├── tavily-crawl/     # 网站爬取
│   │       ├── tavily-map/       # 站点映射
│   │       ├── tavily-research/  # 深度研究
│   │       └── tavily-best-practices/ # 最佳实践参考
│   ├── isaac-sim/                # NVIDIA Isaac Sim 具身智能开发
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── isaac-sim-orchestrator/   # 场景编排调度器
│   │       ├── isaac-sim-remote/         # 远程控制 API
│   │       ├── meta-skills/              # 技能编排模式
│   │       ├── skill-distillation/       # 知识蒸馏
│   │       ├── physics-simulation/       # 物理仿真
│   │       ├── urdf-mjcf-to-usd-conversion/ # 机器人资产转换
│   │       ├── usd-articulation/         # USD 角色验证
│   │       ├── navigation-primitives/    # 导航基元
│   │       ├── isaac-sim-robot-navigation/ # 机器人导航
│   │       ├── manipulation-ik/          # IK 和抓取
│   │       ├── isaac-sim-sensor/         # 传感器
│   │       ├── isaac-camera/             # 相机
│   │       ├── isaac-sim-rendering/      # 渲染
│   │       ├── data-collection-sim/      # 数据采集
│   │       ├── mobility-gen/             # 移动生成 SDG
│   │       ├── spatial-reasoning/        # 空间推理
│   │       ├── usd-pipeline/             # USD 管线
│   │       ├── usd-composition-architecture/ # USD 组合架构
│   │       ├── isaac-sim-ros2-bridge/    # ROS 2 桥接
│   │       ├── occupancy-map/            # 占据地图
│   │       ├── isaac-sim-headless-deployment/ # 无头部署
│   │       ├── isaac-sim-validator/      # 验证器
│   │       ├── isaac-sim-troubleshooting/ # 故障排查
│   │       ├── validation-diff-gifs/     # 差异 GIF
│   │       ├── profile-isaac-sim/        # 性能分析
│   │       └── SKILLS.md                 # 技能总索引
│   ├── tools/                    # 实用工具插件
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   └── finance/                  # 金融交易插件
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
└── README.md                     # 本文件
```

## 添加新插件

1. 在 `plugins/` 下创建插件目录
2. 添加 `.claude-plugin/plugin.json`（插件元数据）
3. 添加 Skills、Agents、Hooks 等组件
4. 在 `.claude-plugin/marketplace.json` 的 `plugins` 数组中添加条目

### Marketplace 配置示例

```json
{
  "name": "my-plugin",
  "source": "./plugins/my-plugin",
  "description": "My awesome plugin",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

## 技术细节

- 插件市场名称：`self-host`（kebab-case）
- 所有源路径使用 `./plugins/<name>` 相对路径
- 插件源类型为 **relative path**（本地目录）
- 仓库托管于 GitHub，支持版本控制和团队协作

## 文档参考

- [创建和分发 Plugin Marketplace](https://code.claude.com/docs/zh-CN/plugin-marketplaces) — Claude Code 官方文档
- [发现并安装预构建插件](https://code.claude.com/docs/zh-CN/discover-plugins)

## 许可证

MIT License

## 维护者

- **lywa1998** — luya.wang@qq.com
