# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 核心理念

一个 Plugin 可以将来自不同 GitHub 仓库的 Skills、Agents、MCP 服务器、Hooks 打包合并在一起。安装一个 Plugin，Claude Code 自动加载其中所有组件。

## 插件结构

```
plugins/<name>/
├── .claude-plugin/plugin.json   # 插件元数据（plugin.json）
├── .mcp.json                    # MCP 服务器配置
├── README.md
├── skills/<skill>/SKILL.md      # Skill 定义
├── commands/<cmd>.md            # 斜杠命令
├── hooks/hooks.json             # 关键词触发钩子
└── agents/<agent>.md            # 后台代理定义
```

## 规范要求

- `marketplace.json` 中的 `name` 必须使用 kebab-case（小写字母+连字符）
- Plugin `name` 同样必须是 kebab-case
- 相对路径 `source` 必须以 `./` 开头
- `author` 字段支持 `name`（必需）和 `email`（可选）

## 验证

```bash
# 验证 marketplace 配置
claude plugin validate .

# 验证单个 plugin
claude plugin validate ./plugins/<name>
```

## 注册插件

在 `.claude-plugin/marketplace.json` 的 `"plugins"` 数组中添加条目。

## 当前插件

查看 `.claude-plugin/marketplace.json` 中的 `plugins` 数组，或使用 `claude plugin list` 查看所有已注册的插件。

## 注意事项

- `.gitignore` 仅忽略 `/tmp`
- 本地权限设置仅允许 `Bash(git *)`
