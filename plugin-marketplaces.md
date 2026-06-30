Title: 创建和分发 plugin marketplace - Claude Code Docs

URL Source: https://code.claude.com/docs/zh-CN/plugin-marketplaces

Markdown Content:
**plugin marketplace** 是一个目录，让你能够将 plugins 分发给他人。Marketplace 提供集中式发现、版本跟踪、自动更新以及对多种源类型（git 存储库、本地路径等）的支持。本指南展示了如何创建自己的 marketplace，与你的团队或社区共享 plugins。想要从现有 marketplace 安装 plugins？请参阅[发现和安装预构建的 plugins](https://code.claude.com/docs/zh-CN/discover-plugins)。

## 概述

创建和分发 marketplace 涉及：

1.   **创建 plugins**：使用 skills、agents、hooks、MCP servers 或 LSP servers 构建一个或多个 plugins。本指南假设你已经有要分发的 plugins；有关如何创建 plugins 的详细信息，请参阅[创建 plugins](https://code.claude.com/docs/zh-CN/plugins)。
2.   **创建 marketplace 文件**：定义一个 `marketplace.json`，列出你的 plugins 及其位置（请参阅[创建 marketplace 文件](https://code.claude.com/docs/zh-CN/plugin-marketplaces#create-the-marketplace-file)）。
3.   **托管 marketplace**：推送到 GitHub、GitLab 或其他 git 主机（请参阅[托管和分发 marketplaces](https://code.claude.com/docs/zh-CN/plugin-marketplaces#host-and-distribute-marketplaces)）。
4.   **与用户共享**：用户使用 `/plugin marketplace add` 添加你的 marketplace 并安装单个 plugins（请参阅[发现和安装 plugins](https://code.claude.com/docs/zh-CN/discover-plugins)）。

一旦你的 marketplace 上线，你可以通过推送更改到你的存储库来更新它。用户使用 `/plugin marketplace update` 刷新他们的本地副本。

此示例创建一个包含一个 plugin 的 marketplace：一个用于代码审查的 `quality-review` skill。你将创建目录结构、添加 skill、创建 plugin manifest 和 marketplace 目录，然后安装并测试它。

1

2

3

4

5

6

要了解更多关于 plugins 可以做什么的信息，包括 hooks、agents、MCP servers 和 LSP servers，请参阅 [Plugins](https://code.claude.com/docs/zh-CN/plugins)。

## 创建 marketplace 文件

在你的存储库根目录中创建 `.claude-plugin/marketplace.json`。此文件定义你的 marketplace 的名称、所有者信息以及包含其源的 plugins 列表。每个 plugin 条目至少需要一个 `name` 和 `source`（从哪里获取它）。有关所有可用字段，请参阅下面的[完整架构](https://code.claude.com/docs/zh-CN/plugin-marketplaces#marketplace-schema)。

```
{
  "name": "company-tools",
  "owner": {
    "name": "DevTools Team",
    "email": "devtools@example.com"
  },
  "plugins": [
    {
      "name": "code-formatter",
      "source": "./plugins/formatter",
      "description": "Automatic code formatting on save",
      "version": "2.1.0",
      "author": {
        "name": "DevTools Team"
      }
    },
    {
      "name": "deployment-tools",
      "source": {
        "source": "github",
        "repo": "company/deploy-plugin"
      },
      "description": "Deployment automation tools"
    }
  ]
}
```

## Marketplace 架构

### 必需字段

| 字段 | 类型 | 描述 | 示例 |
| --- | --- | --- | --- |
| `name` | string | Marketplace 标识符（kebab-case，无空格）。这是面向公众的：用户在安装 plugins 时会看到它（例如，`/plugin install my-tool@your-marketplace`）。每个用户只能为每个名称注册一个 marketplace：添加第二个同名 marketplace 会替换第一个。要在一个 marketplace 名称下发布多个 plugins，请在[单个 `marketplace.json`](https://code.claude.com/docs/zh-CN/plugin-marketplaces#create-the-marketplace-file) 中列出它们。 | `"acme-tools"` |
| `owner` | object | Marketplace 维护者信息（[见下面的字段](https://code.claude.com/docs/zh-CN/plugin-marketplaces#owner-fields)） |  |
| `plugins` | array | 可用 plugins 列表 | 见下文 |

### 所有者字段

| 字段 | 类型 | 必需 | 描述 |
| --- | --- | --- | --- |
| `name` | string | 是 | 维护者或团队的名称 |
| `email` | string | 否 | 维护者的联系电子邮件 |

### 可选字段

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `$schema` | string | 用于编辑器自动完成和验证的 JSON Schema URL。Claude Code 在加载时忽略此字段。 |
| `description` | string | 简短的 marketplace 描述 |
| `version` | string | Marketplace 清单版本 |
| `metadata.pluginRoot` | string | 前置到相对 plugin 源路径的基目录（例如，`"./plugins"` 让你写 `"source": "formatter"` 而不是 `"source": "./plugins/formatter"`） |
| `allowCrossMarketplaceDependenciesOn` | array | 此 marketplace 中的 plugins 可能依赖的其他 marketplaces。来自此处未列出的 marketplace 的依赖项在安装时被阻止。见[依赖来自另一个 marketplace 的 plugin](https://code.claude.com/docs/zh-CN/plugin-dependencies#depend-on-a-plugin-from-another-marketplace)。 |

`description` 和 `version` 也可以在 `metadata` 下接受，以实现向后兼容性。

## Plugin 条目

`plugins` 数组中的每个 plugin 条目描述一个 plugin 及其位置。你可以包含 [plugin manifest 架构](https://code.claude.com/docs/zh-CN/plugins-reference#plugin-manifest-schema)中的任何字段（如 `description`、`version`、`author`、`commands`、`hooks` 等），加上这些 marketplace 特定的字段：`source`、`category`、`tags`、`strict` 和 `relevance`。

### 必需字段

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `name` | string | Plugin 标识符（kebab-case，无空格）。这是面向公众的：用户在安装时会看到它（例如，`/plugin install my-plugin@marketplace`）。 |
| `source` | string|object | 从哪里获取 plugin（见下面的 [Plugin 源](https://code.claude.com/docs/zh-CN/plugin-marketplaces#plugin-sources)） |

### 可选 plugin 字段

**标准元数据字段：**

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `displayName` | string | 在 UI 界面中显示的人类可读名称。当省略时回退到 `name`。可以包含空格和任何大小写。不用于命名空间或查找。需要 Claude Code v2.1.143 或更高版本。 |
| `description` | string | 简短的 plugin 描述 |
| `version` | string | Plugin 版本。如果设置（在此处或在 `plugin.json` 中），plugin 将固定到此字符串，用户仅在其更改时才会收到更新。省略以回退到 git commit SHA。见 [版本解析](https://code.claude.com/docs/zh-CN/plugin-marketplaces#version-resolution-and-release-channels)。 |
| `author` | object | Plugin 作者信息（`name` 必需，`email` 可选） |
| `homepage` | string | Plugin 主页或文档 URL |
| `repository` | string | 源代码存储库 URL |
| `license` | string | SPDX 许可证标识符（例如，MIT、Apache-2.0） |
| `keywords` | array | 用于 plugin 发现和分类的标签 |
| `category` | string | Plugin 类别以供组织 |
| `tags` | array | 用于可搜索性的标签 |
| `strict` | boolean | 控制 `plugin.json` 是否是组件定义的权威（默认：true）。见下面的 [Strict 模式](https://code.claude.com/docs/zh-CN/plugin-marketplaces#strict-mode)。 |
| `relevance` | object | 告诉 Claude Code 何时向用户建议此 plugin 的信号。仅对管理员在托管设置中允许列表的 marketplace 生效。见 [为你的组织推荐 plugin](https://code.claude.com/docs/zh-CN/plugin-relevance)。需要 Claude Code v2.1.152 或更高版本。 |
| `defaultEnabled` | boolean | plugin 安装后是否启用（默认：true）。设置为 `false` 以安装禁用的 plugin，直到用户选择启用。优先于 plugin 的 `plugin.json` 中的同一字段。见 [默认启用](https://code.claude.com/docs/zh-CN/plugins-reference#default-enablement)。需要 Claude Code v2.1.154 或更高版本。 |

**组件配置字段：**

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `skills` | string|array | 包含 `<name>/SKILL.md` 的 skill 目录的自定义路径 |
| `commands` | string|array | 平面 `.md` skill 文件或目录的自定义路径 |
| `agents` | string|array | agent 文件的自定义路径 |
| `hooks` | string|object | 自定义 hooks 配置或 hooks 文件的路径 |
| `mcpServers` | string|object | MCP server 配置或 MCP 配置的路径 |
| `lspServers` | string|object | LSP server 配置或 LSP 配置的路径 |

## Plugin 源

Plugin 源告诉 Claude Code 在你的 marketplace 中列出的每个单独 plugin 从哪里获取。这些在 `marketplace.json` 中每个 plugin 条目的 `source` 字段中设置。一旦 plugin 被克隆或复制到本地机器，它就会被复制到本地版本化 plugin 缓存中，位置为 `~/.claude/plugins/cache`。

| 源 | 类型 | 字段 | 注释 |
| --- | --- | --- | --- |
| 相对路径 | `string`（例如 `"./my-plugin"`） | 无 | marketplace repo 中的本地目录。必须以 `./` 开头。相对于 marketplace 根目录解析，而不是 `.claude-plugin/` 目录 |
| `github` | object | `repo`、`ref?`、`sha?` |  |
| `url` | object | `url`、`ref?`、`sha?` | Git URL 源 |
| `git-subdir` | object | `url`、`path`、`ref?`、`sha?` | git repo 中的子目录。稀疏克隆以最小化大型 monorepos 的带宽 |
| `npm` | object | `package`、`version?`、`registry?` | 通过 `npm install` 安装 |

基于 git 的源类型如下所示为 `github`、`url` 和 `git-subdir`。当在其中任何一个上同时设置 `ref` 和 `sha` 时，`sha` 是有效的固定。Claude Code 直接获取并检出固定的提交。在大多数 git 主机上，包括 GitHub、GitLab 和 Bitbucket，这意味着即使上游的 `ref` 命名的分支或标签已被删除，只要提交仍然可从存储库到达，安装也会成功。某些服务器（如 AWS CodeCommit）不支持通过 SHA 获取提交。在这些服务器上，`ref` 必须仍然存在，固定的提交必须可从其到达。

### 相对路径

对于同一存储库中的 plugins，使用以 `./` 开头的路径：

```
{
  "name": "my-plugin",
  "source": "./plugins/my-plugin"
}
```

路径相对于 marketplace 根目录解析，即包含 `.claude-plugin/` 的目录。在上面的示例中，`./plugins/my-plugin` 指向 `<repo>/plugins/my-plugin`，即使 `marketplace.json` 位于 `<repo>/.claude-plugin/marketplace.json`。不要使用 `../` 来引用 marketplace 根目录外的路径。

### GitHub 存储库

```
{
  "name": "github-plugin",
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo"
  }
}
```

你可以固定到特定的分支、标签或提交：

```
{
  "name": "github-plugin",
  "source": {
    "source": "github",
    "repo": "owner/plugin-repo",
    "ref": "v2.0.0",
    "sha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
  }
}
```

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `repo` | string | 必需。`owner/repo` 格式的 GitHub 存储库 |
| `ref` | string | 可选。Git 分支或标签（默认为存储库默认分支） |
| `sha` | string | 可选。完整的 40 字符 git 提交 SHA 以固定到精确版本 |

### Git 存储库

```
{
  "name": "git-plugin",
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git"
  }
}
```

你可以固定到特定的分支、标签或提交：

```
{
  "name": "git-plugin",
  "source": {
    "source": "url",
    "url": "https://gitlab.com/team/plugin.git",
    "ref": "main",
    "sha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
  }
}
```

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `url` | string | 必需。完整的 git 存储库 URL（`https://` 或 `git@`）。`.git` 后缀是可选的，所以 Azure DevOps 和 AWS CodeCommit URL 不带后缀也可以工作 |
| `ref` | string | 可选。Git 分支或标签（默认为存储库默认分支） |
| `sha` | string | 可选。完整的 40 字符 git 提交 SHA 以固定到精确版本 |

### Git 子目录

使用 `git-subdir` 指向位于 git 存储库子目录中的 plugin。Claude Code 使用稀疏的部分克隆来仅获取子目录，最小化大型 monorepos 的带宽。

```
{
  "name": "my-plugin",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/acme-corp/monorepo.git",
    "path": "tools/claude-plugin"
  }
}
```

你可以固定到特定的分支、标签或提交：

```
{
  "name": "my-plugin",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/acme-corp/monorepo.git",
    "path": "tools/claude-plugin",
    "ref": "v2.0.0",
    "sha": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0"
  }
}
```

`url` 字段也接受 GitHub 简写（`owner/repo`）或 SSH URL（`git@github.com:owner/repo.git`）。

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `url` | string | 必需。Git 存储库 URL、GitHub `owner/repo` 简写或 SSH URL |
| `path` | string | 必需。repo 中包含 plugin 的子目录路径（例如，`"tools/claude-plugin"`） |
| `ref` | string | 可选。Git 分支或标签（默认为存储库默认分支） |
| `sha` | string | 可选。完整的 40 字符 git 提交 SHA 以固定到精确版本 |

### npm 包

作为 npm 包分发的 Plugins 使用 `npm install` 安装。这适用于公共 npm registry 上的任何包或你的团队托管的私有 registry。

```
{
  "name": "my-npm-plugin",
  "source": {
    "source": "npm",
    "package": "@acme/claude-plugin"
  }
}
```

要固定到特定版本，请添加 `version` 字段：

```
{
  "name": "my-npm-plugin",
  "source": {
    "source": "npm",
    "package": "@acme/claude-plugin",
    "version": "2.1.0"
  }
}
```

要从私有或内部 registry 安装，请添加 `registry` 字段：

```
{
  "name": "my-npm-plugin",
  "source": {
    "source": "npm",
    "package": "@acme/claude-plugin",
    "version": "^2.0.0",
    "registry": "https://npm.example.com"
  }
}
```

| 字段 | 类型 | 描述 |
| --- | --- | --- |
| `package` | string | 必需。包名称或作用域包（例如，`@org/plugin`） |
| `version` | string | 可选。版本或版本范围（例如，`2.1.0`、`^2.0.0`、`~1.5.0`） |
| `registry` | string | 可选。自定义 npm registry URL。默认为系统 npm registry（通常为 npmjs.org） |

### 高级 plugin 条目

此示例显示了使用许多可选字段的 plugin 条目，包括命令、agents、hooks 和 MCP servers 的自定义路径：

```
{
  "name": "enterprise-tools",
  "source": {
    "source": "github",
    "repo": "company/enterprise-plugin"
  },
  "description": "Enterprise workflow automation tools",
  "version": "2.1.0",
  "author": {
    "name": "Enterprise Team",
    "email": "enterprise@example.com"
  },
  "homepage": "https://docs.example.com/plugins/enterprise-tools",
  "repository": "https://github.com/company/enterprise-plugin",
  "license": "MIT",
  "keywords": ["enterprise", "workflow", "automation"],
  "category": "productivity",
  "commands": [
    "./commands/core/",
    "./commands/enterprise/",
    "./commands/experimental/preview.md"
  ],
  "agents": ["./agents/security-reviewer.md", "./agents/compliance-checker.md"],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "enterprise-db": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  },
  "strict": false
}
```

需要注意的关键事项：

*   **`commands` 和 `agents`**：你可以指定多个目录或单个文件。路径相对于 plugin 根目录。
*   **`${CLAUDE_PLUGIN_ROOT}`**：在 hooks 和 MCP server 配置中使用此变量来引用 plugin 安装目录中的文件。这是必要的，因为 plugins 在安装时被复制到缓存位置。对于应该在 plugin 更新后保留的依赖项或状态，请改用 [`${CLAUDE_PLUGIN_DATA}`](https://code.claude.com/docs/zh-CN/plugins-reference#persistent-data-directory)。
*   **`strict: false`**：由于这设置为 false，plugin 不需要自己的 `plugin.json`。marketplace 条目定义了一切。见下面的 [Strict 模式](https://code.claude.com/docs/zh-CN/plugin-marketplaces#strict-mode)。

默认情况下，plugin 的 skills 从其 `source` 下的 `skills/` 目录加载。`skills` 字段中列出的路径添加到该扫描中：

```
"skills": ["./skills/", "./extra-skills/"]
```

当多个 plugin 条目在 marketplace 根目录（`source: "./"`）共享一个 `skills/` 文件夹时，改为列出特定子目录，以便每个条目仅加载自己的 skills：

```
"source": "./",
"skills": ["./skills/code-review", "./skills/docs"]
```

使用 marketplace 根源，列出的路径是该条目的完整集合，共享 `skills/` 文件夹中的其他目录不会加载。列出 `./skills/` 本身或 plugin 根目录会保持完整扫描。如果列出的路径都不存在，则改为运行默认扫描。

### Strict 模式

`strict` 字段控制 `plugin.json` 是否是组件定义（skills、agents、hooks、MCP servers、输出样式）的权威。

| 值 | 行为 |
| --- | --- |
| `true`（默认） | `plugin.json` 是权威。marketplace 条目可以用额外的组件补充它，两个源都被合并。 |
| `false` | marketplace 条目是完整的定义。如果 plugin 也有声明组件的 `plugin.json`，那就是冲突，plugin 无法加载。 |

**何时使用每种模式：**

*   **`strict: true`**：plugin 有自己的 `plugin.json` 并管理自己的组件。marketplace 条目可以在顶部添加额外的 skills 或 hooks。这是默认值，适用于大多数 plugins。
*   **`strict: false`**：marketplace 操作员想要完全控制。plugin repo 提供原始文件，marketplace 条目定义这些文件中的哪些被公开为 skills、agents、hooks 等。当 marketplace 以不同于 plugin 作者意图的方式重组或策划 plugin 的组件时很有用。

## 托管和分发 marketplaces

### 在 GitHub 上托管（推荐）

GitHub 提供最简单的分发方法：

1.   **创建存储库**：为你的 marketplace 设置一个新存储库
2.   **添加 marketplace 文件**：使用你的 plugin 定义创建 `.claude-plugin/marketplace.json`
3.   **与团队共享**：用户使用 `/plugin marketplace add owner/repo` 添加你的 marketplace

**优点**：内置版本控制、问题跟踪和团队协作功能。

### 在其他 git 服务上托管

任何 git 托管服务都可以工作，例如 GitLab、Bitbucket 和自托管服务器。用户使用完整的存储库 URL 添加：

```
/plugin marketplace add https://gitlab.com/company/plugins.git
```

### 私有存储库

Claude Code 支持从私有存储库安装 plugins。对于手动安装和更新，Claude Code 使用你现有的 git 凭证助手，所以通过 `gh auth login`、macOS Keychain 或 `git-credential-store` 的 HTTPS 访问工作方式与你的终端中相同。SSH 访问工作，只要主机已经在你的 `known_hosts` 文件中，并且密钥已加载到 `ssh-agent` 中，因为 Claude Code 会抑制主机指纹和密钥密码的交互式 SSH 提示。后台自动更新在启动时运行，不使用凭证助手，因为交互式提示会阻止 Claude Code 启动。要为私有 marketplaces 启用自动更新，请在你的环境中设置适当的身份验证令牌：

| 提供商 | 环境变量 | 注释 |
| --- | --- | --- |
| GitHub | `GITHUB_TOKEN` 或 `GH_TOKEN` | 个人访问令牌或 GitHub App 令牌 |
| GitLab | `GITLAB_TOKEN` 或 `GL_TOKEN` | 个人访问令牌或项目令牌 |
| Bitbucket | `BITBUCKET_TOKEN` | 应用密码或存储库访问令牌 |

在你的 shell 配置中设置令牌（例如，`.bashrc`、`.zshrc`）或在运行 Claude Code 时传递它：

```
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

### 在分发前本地测试

在共享前本地测试你的 marketplace：

```
/plugin marketplace add ./my-local-marketplace
/plugin install test-plugin@my-local-marketplace
```

有关完整的添加命令范围（GitHub、Git URL、本地路径、远程 URL），请参阅[添加 marketplaces](https://code.claude.com/docs/zh-CN/discover-plugins#add-marketplaces)。

### 为你的团队要求 marketplaces

你可以配置你的存储库，以便当团队成员信任项目文件夹时，他们会自动被提示安装你的 marketplace。将你的 marketplace 添加到 `.claude/settings.json`：

```
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

你也可以指定默认应启用哪些 plugins：

```
{
  "enabledPlugins": {
    "code-formatter@company-tools": true,
    "deployment-tools@company-tools": true
  }
}
```

有关完整的配置选项，请参阅 [Plugin 设置](https://code.claude.com/docs/zh-CN/settings#plugin-settings)。

### 为容器预填充 plugins

对于容器镜像和 CI 环境，你可以在构建时预填充 plugins 目录，以便 Claude Code 启动时已经有 marketplaces 和 plugins 可用，无需在运行时克隆任何内容。设置 `CLAUDE_CODE_PLUGIN_SEED_DIR` 环境变量以指向此目录。要分层多个种子目录，请在 Unix 上用 `:` 分隔路径，或在 Windows 上用 `;` 分隔。Claude Code 按顺序搜索每个目录，第一个包含给定 marketplace 或 plugin 缓存的种子获胜。种子目录镜像 `~/.claude/plugins` 的结构：

```
$CLAUDE_CODE_PLUGIN_SEED_DIR/
  known_marketplaces.json
  marketplaces/<name>/...
  cache/<marketplace>/<plugin>/<version>/...
```

要构建种子目录，请在镜像构建期间运行 Claude Code 一次，安装你需要的 plugins，然后将生成的 `~/.claude/plugins` 目录复制到你的镜像中，并将 `CLAUDE_CODE_PLUGIN_SEED_DIR` 指向它。要跳过复制步骤，请在构建期间将 `CLAUDE_CODE_PLUGIN_CACHE_DIR` 设置为你的目标种子路径，以便 plugins 直接安装到那里：

```
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin marketplace add your-org/plugins
CLAUDE_CODE_PLUGIN_CACHE_DIR=/opt/claude-seed claude plugin install my-tool@your-plugins
```

然后在你的容器的运行时环境中设置 `CLAUDE_CODE_PLUGIN_SEED_DIR=/opt/claude-seed`，以便 Claude Code 在启动时从种子读取。在启动时，Claude Code 将种子的 `known_marketplaces.json` 中找到的 marketplaces 注册到主配置中，并使用在 `cache/` 下找到的 plugin 缓存，而无需重新克隆。这在交互模式和使用 `-p` 标志的非交互模式中都有效。行为详情：

*   **只读**：种子目录永远不会被写入。由于 git pull 会在只读文件系统上失败，种子 marketplaces 的自动更新被禁用。
*   **种子条目优先**：在每次启动时，种子中声明的 marketplaces 会覆盖用户配置中的任何匹配条目。要选择退出种子 plugin，请使用 `/plugin disable` 而不是删除 marketplace。
*   **路径解析**：Claude Code 通过在运行时探测 `$CLAUDE_CODE_PLUGIN_SEED_DIR/marketplaces/<name>/` 来定位 marketplace 内容，而不是信任存储在种子 JSON 内的路径。这意味着即使在与构建时不同的路径上挂载，种子也能正确工作。
*   **变更被阻止**：针对种子管理的 marketplace 运行 `/plugin marketplace remove` 或 `/plugin marketplace update` 会失败，并提示你要求管理员更新种子镜像。
*   **与设置组合**：如果 `extraKnownMarketplaces` 或 `enabledPlugins` 声明的 marketplace 已经存在于种子中，Claude Code 使用种子副本而不是克隆。

### 托管 marketplace 限制

对于需要严格控制 plugin 源的组织，管理员可以使用托管设置中的 [`strictKnownMarketplaces`](https://code.claude.com/docs/zh-CN/settings#strictknownmarketplaces) 设置限制用户允许添加哪些 plugin marketplaces。当在托管设置中配置 `strictKnownMarketplaces` 时，限制行为取决于值：

| 值 | 行为 |
| --- | --- |
| 未定义（默认） | 无限制。用户可以添加任何 marketplace |
| 空数组 `[]` | 完全锁定。用户无法添加任何新 marketplaces |
| 源列表 | 用户只能添加与允许列表完全匹配的 marketplaces |

#### 常见配置

禁用所有 marketplace 添加：

```
{
  "strictKnownMarketplaces": []
}
```

仅允许特定 marketplaces：

```
{
  "strictKnownMarketplaces": [
    {
      "source": "github",
      "repo": "acme-corp/approved-plugins"
    },
    {
      "source": "github",
      "repo": "acme-corp/security-tools",
      "ref": "v2.0"
    },
    {
      "source": "url",
      "url": "https://plugins.example.com/marketplace.json"
    }
  ]
}
```

使用主机上的正则表达式模式匹配允许来自内部 git 服务器的所有 marketplaces。这是 [GitHub Enterprise Server](https://code.claude.com/docs/zh-CN/github-enterprise-server#plugin-marketplaces-on-ghes) 或自托管 GitLab 实例的推荐方法：

```
{
  "strictKnownMarketplaces": [
    {
      "source": "hostPattern",
      "hostPattern": "^github\\.example\\.com$"
    }
  ]
}
```

使用路径上的正则表达式模式匹配允许来自特定目录的基于文件系统的 marketplaces：

```
{
  "strictKnownMarketplaces": [
    {
      "source": "pathPattern",
      "pathPattern": "^/opt/approved/"
    }
  ]
}
```

使用 `".*"` 作为 `pathPattern` 来允许任何文件系统路径，同时仍然使用 `hostPattern` 控制网络源。

#### 限制如何工作

限制在任何网络或文件系统操作之前进行检查。检查在 marketplace 添加以及 plugin 安装、更新、刷新和自动更新时运行。如果 marketplace 在配置策略之前被添加，其源不再与允许列表匹配，Claude Code 会拒绝从中安装或更新 plugins。相同的强制执行也适用于 `blockedMarketplaces`。允许列表对大多数源类型使用精确匹配。要允许 marketplace，所有指定的字段必须完全匹配：

*   对于 GitHub 源：`repo` 是必需的，如果在允许列表中指定，`ref` 或 `path` 也必须匹配
*   对于 URL 源：完整 URL 必须完全匹配
*   对于 `hostPattern` 源：marketplace 主机与正则表达式模式匹配
*   对于 `pathPattern` 源：marketplace 的文件系统路径与正则表达式模式匹配

精确匹配不规范化 URL：尾部斜杠、`.git` 后缀或 `ssh://` 与 `https://` 形式被视为不同的值。如果你的组织的 marketplace 可以通过多个 URL 形式克隆，优先使用 `hostPattern` 条目而不是字面 URL，以便所有形式都匹配。因为 `strictKnownMarketplaces` 在[托管设置](https://code.claude.com/docs/zh-CN/settings#settings-files)中设置，个别用户和项目配置无法覆盖这些限制。有关完整的配置详细信息，包括所有支持的源类型和与 `extraKnownMarketplaces` 的比较，请参阅 [strictKnownMarketplaces 参考](https://code.claude.com/docs/zh-CN/settings#strictknownmarketplaces)。

### 版本解析和发布渠道

Plugin 版本确定缓存路径和更新检测：如果解析的版本与用户已有的版本匹配，`/plugin update` 和自动更新会跳过该 plugin。Claude Code 从以下第一个设置的内容解析 plugin 的版本：

1.   plugin 的 `plugin.json` 中的 `version`
2.   plugin 的 marketplace 条目中的 `version`
3.   plugin 源的 git 提交 SHA

对于 git 源类型 `github`、`url`、`git-subdir` 和 git 托管 marketplace 内的相对路径，你可以完全省略 `version`，每个新提交都被视为新版本。这是内部或积极开发的 plugins 的最简单设置。

#### 设置发布渠道

要为你的 plugins 支持”稳定”和”最新”发布渠道，你可以设置两个指向同一 repo 的不同 refs 或 SHAs 的 marketplaces。然后，你可以通过[托管设置](https://code.claude.com/docs/zh-CN/settings#settings-files)将两个 marketplaces 分配给不同的用户组。

```
{
  "name": "stable-tools",
  "plugins": [
    {
      "name": "code-formatter",
      "source": {
        "source": "github",
        "repo": "acme-corp/code-formatter",
        "ref": "stable"
      }
    }
  ]
}
```

```
{
  "name": "latest-tools",
  "plugins": [
    {
      "name": "code-formatter",
      "source": {
        "source": "github",
        "repo": "acme-corp/code-formatter",
        "ref": "latest"
      }
    }
  ]
}
```

通过托管设置将每个 marketplace 分配给适当的用户组。例如，稳定组接收：

```
{
  "extraKnownMarketplaces": {
    "stable-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/stable-tools"
      }
    }
  }
}
```

早期访问组改为接收 `latest-tools`：

```
{
  "extraKnownMarketplaces": {
    "latest-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/latest-tools"
      }
    }
  }
}
```

#### 固定依赖版本

Plugin 可以将其依赖约束到 semver 范围，以便对依赖的更新不会破坏依赖的 plugin。有关 `{plugin-name}--v{version}` git 标签约定、范围语法以及如何组合对同一依赖的多个约束，请参阅[约束 plugin 依赖版本](https://code.claude.com/docs/zh-CN/plugin-dependencies)。

## 验证和测试

在共享前测试你的 marketplace。验证你的 marketplace JSON 语法：

```
claude plugin validate .
```

或从 Claude Code 内：

```
/plugin validate .
```

添加 marketplace 进行测试：

```
/plugin marketplace add ./path/to/marketplace
```

安装测试 plugin 以验证一切正常：

```
/plugin install test-plugin@marketplace-name
```

有关完整的 plugin 测试工作流，请参阅[本地测试你的 plugins](https://code.claude.com/docs/zh-CN/plugins#test-your-plugins-locally)。有关技术故障排除，请参阅 [Plugins 参考](https://code.claude.com/docs/zh-CN/plugins-reference)。

## 从 CLI 管理 marketplaces

Claude Code 提供非交互式 `claude plugin marketplace` 子命令用于脚本编写和自动化。这些等同于交互式会话中可用的 `/plugin marketplace` 命令。

### Plugin marketplace add

从 GitHub 存储库、git URL、远程 URL 或本地路径添加 marketplace。

```
claude plugin marketplace add <source> [options]
```

**参数：**

*   `<source>`：GitHub `owner/repo` 简写、git URL、指向 `marketplace.json` 文件的远程 URL 或本地目录路径。要固定到分支或标签，请将 `@ref` 附加到 GitHub 简写或 `#ref` 附加到 git URL

**选项：**

| 选项 | 描述 | 默认值 |
| --- | --- | --- |
| `--scope <scope>` | 声明 marketplace 的位置：`user`、`project` 或 `local`。见 [Plugin 安装范围](https://code.claude.com/docs/zh-CN/plugins-reference#plugin-installation-scopes) | `user` |
| `--sparse <paths...>` | 通过 git sparse-checkout 限制检出到特定目录。对 monorepos 有用 |  |

从 GitHub 使用 `owner/repo` 简写添加 marketplace：

```
claude plugin marketplace add acme-corp/claude-plugins
```

使用 `@ref` 固定到特定分支或标签：

```
claude plugin marketplace add acme-corp/claude-plugins@v2.0
```

从非 GitHub 主机上的 git URL 添加：

```
claude plugin marketplace add https://gitlab.example.com/team/plugins.git
```

从直接提供 `marketplace.json` 文件的远程 URL 添加：

```
claude plugin marketplace add https://example.com/marketplace.json
```

从本地目录添加以进行测试：

```
claude plugin marketplace add ./my-marketplace
```

在项目范围声明 marketplace，以便通过 `.claude/settings.json` 与你的团队共享：

```
claude plugin marketplace add acme-corp/claude-plugins --scope project
```

对于 monorepo，限制检出到包含 plugin 内容的目录：

```
claude plugin marketplace add acme-corp/monorepo --sparse .claude-plugin plugins
```

### Plugin marketplace list

列出所有配置的 marketplaces。

```
claude plugin marketplace list [options]
```

**选项：**

| 选项 | 描述 |
| --- | --- |
| `--json` | 输出为 JSON |

使用 `--json`，每个条目包括 `name`、`source` 和源特定字段：GitHub 源的 `repo`、git 和 URL 源的 `url`，以及本地源的 `path`。当 marketplace 使用固定分支或标签添加时，GitHub 和 git 源也包括 `ref` 字段。

### Plugin marketplace remove

删除配置的 marketplace。别名 `rm` 也被接受。

```
claude plugin marketplace remove <name> [options]
```

**参数：**

*   `<name>`：marketplace 名称要删除，如 `claude plugin marketplace list` 所示。这是来自 `marketplace.json` 的 `name`，而不是你传递给 `add` 的源

**选项：**

| 选项 | 描述 | 默认值 |
| --- | --- | --- |
| `--scope <scope>` | 限制删除到单个设置范围：`user`、`project` 或 `local`。见 [Plugin 安装范围](https://code.claude.com/docs/zh-CN/plugins-reference#plugin-installation-scopes)。省略时，声明从每个可编辑的范围中删除。给定时，仅删除该范围的声明；当 marketplace 仍在另一个范围中声明时，共享状态、缓存和已安装的 plugin 数据将被保留 | （所有范围） |

### Plugin marketplace update

从其源刷新 marketplaces 以检索新 plugins 和版本更改。

```
claude plugin marketplace update [name]
```

**参数：**

*   `[name]`：marketplace 名称要更新，如 `claude plugin marketplace list` 所示。如果省略，更新所有 marketplaces

`remove` 和 `update` 在针对种子管理的 marketplace 运行时都会失败，这是只读的。更新所有 marketplaces 时，种子管理的条目被跳过，其他 marketplaces 仍然更新。要更改种子提供的 plugins，请要求你的管理员更新种子镜像。见 [为容器预填充 plugins](https://code.claude.com/docs/zh-CN/plugin-marketplaces#pre-populate-plugins-for-containers)。

## 故障排除

### Marketplace 未加载

**症状**：无法添加 marketplace 或从中看到 plugins**解决方案**：

*   验证 marketplace URL 是否可访问
*   检查 `.claude-plugin/marketplace.json` 是否存在于指定路径
*   使用 `claude plugin validate` 或 `/plugin validate` 确保 JSON 语法有效。要检查 skill、agent 和 command frontmatter，请针对每个 plugin 目录运行该命令
*   对于私有存储库，确认你有访问权限

### Marketplace 验证错误

从你的 marketplace 目录运行 `claude plugin validate .` 或 `/plugin validate .` 来检查问题。当指向 marketplace 目录时，验证器仅检查 `marketplace.json`：schema、重复的 plugin 名称、源路径遍历和版本不匹配与每个引用的 `plugin.json`。要验证单个 plugin 的 `plugin.json` 及其 skill、agent、command 和 hook 文件，请针对 plugin 目录本身运行该命令，例如 `claude plugin validate ./plugins/my-plugin`。常见错误：

| 错误 | 原因 | 解决方案 |
| --- | --- | --- |
| `File not found: .claude-plugin/marketplace.json` | 缺少 manifest | 使用必需字段创建 `.claude-plugin/marketplace.json` |
| `Invalid JSON syntax: Unexpected token...` | JSON 语法错误 | 检查缺少的逗号、多余的逗号或未引用的字符串 |
| `Duplicate plugin name "x" found in marketplace` | 两个 plugins 共享相同的名称 | 给每个 plugin 一个唯一的 `name` 值 |
| `plugins[0].source: Path contains ".."` | 源路径包含 `..` | 使用相对于 marketplace 根目录的路径，不包含 `..`。见[相对路径](https://code.claude.com/docs/zh-CN/plugin-marketplaces#relative-paths) |
| `YAML frontmatter failed to parse: ...` | skill、agent 或 command 文件中的 YAML 无效 | 修复 frontmatter 块中的 YAML 语法。在运行时，此文件加载时不带元数据。仅在验证 plugin 目录时报告 |
| `Invalid JSON syntax: ...`（hooks.json） | 格式错误的 `hooks/hooks.json` | 修复 JSON 语法。格式错误的 `hooks/hooks.json` 会阻止整个 plugin 加载。仅在验证 plugin 目录时报告 |

**警告**（非阻止）：

*   `Marketplace has no plugins defined`：将至少一个 plugin 添加到 `plugins` 数组
*   `No marketplace description provided`：添加顶级 `description` 以帮助用户理解你的 marketplace
*   `Plugin name "x" is not kebab-case`：plugin 名称包含大写字母、空格或特殊字符。重命名为仅包含小写字母、数字和连字符（例如，`my-plugin`）。Claude Code 接受其他形式，但 Claude.ai marketplace 同步会拒绝它们。

### Plugin 安装失败

**症状**：Marketplace 出现但 plugin 安装失败**解决方案**：

*   验证 plugin 源 URL 是否可访问
*   检查 plugin 目录是否包含必需的文件
*   对于 GitHub 源，确保存储库是公开的或你有访问权限
*   通过手动克隆/下载来测试 plugin 源
*   如果源同时固定了 `ref` 和 `sha`，删除的上游分支或标签不会阻止大多数 git 主机（包括 GitHub、GitLab 和 Bitbucket）上的安装。在不支持通过 SHA 获取提交的服务器上（如 AWS CodeCommit），`ref` 必须仍然存在，固定的提交必须可从其到达。如果安装仍然失败，请确认固定的提交仍然存在于存储库中

### 私有存储库身份验证失败

**症状**：从私有存储库安装 plugins 时出现身份验证错误**解决方案**：对于手动安装和更新：

*   验证你已使用你的 git 提供商进行身份验证（例如，对于 GitHub 运行 `gh auth status`）
*   检查你的凭证助手是否配置正确：`git config --global credential.helper`
*   尝试手动克隆存储库以验证你的凭证有效

对于后台自动更新：

*   在你的环境中设置适当的令牌：`echo $GITHUB_TOKEN`
*   检查令牌是否具有所需的权限（对存储库的读取访问权限）
*   对于 GitHub，确保令牌对私有存储库具有 `repo` 范围
*   对于 GitLab，确保令牌至少具有 `read_repository` 范围
*   验证令牌未过期

### Marketplace 更新在离线环境中失败

**症状**：Marketplace `git pull` 失败，Claude Code 清除现有缓存，导致 plugins 变得不可用。**原因**：默认情况下，当 `git pull` 失败时，Claude Code 会删除陈旧的克隆并尝试重新克隆。在离线或隔离的环境中，重新克隆以相同的方式失败，导致 marketplace 目录为空。**解决方案**：设置 `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1` 以在拉取失败时保留现有缓存，而不是清除它：

```
export CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE=1
```

设置此变量后，Claude Code 在 `git pull` 失败时保留陈旧的 marketplace 克隆，并继续使用最后已知的良好状态。对于存储库永远无法访问的完全离线部署，请改用 [`CLAUDE_CODE_PLUGIN_SEED_DIR`](https://code.claude.com/docs/zh-CN/plugin-marketplaces#pre-populate-plugins-for-containers) 在构建时预填充 plugins 目录。

### Git 操作超时

**症状**：Plugin 安装或 marketplace 更新失败，出现超时错误，如”Git clone timed out after 120s”或”Git pull timed out after 120s”。**原因**：Claude Code 对所有 git 操作使用 120 秒超时，包括克隆 plugin 存储库和拉取 marketplace 更新。大型存储库或缓慢的网络连接可能超过此限制。**解决方案**：使用 `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` 环境变量增加超时。该值以毫秒为单位：

```
export CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS=300000  # 5 minutes
```

### 相对路径 Plugins 在基于 URL 的 Marketplaces 中失败

**症状**：通过 URL（如 `https://example.com/marketplace.json`）添加了 marketplace，但具有相对路径源（如 `"./plugins/my-plugin"`）的 plugins 无法安装，出现”path not found”错误。**原因**：基于 URL 的 marketplaces 仅下载 `marketplace.json` 文件本身。它们不从服务器下载 plugin 文件。marketplace 条目中的相对路径引用远程服务器上未下载的文件。**解决方案**：

*   **使用外部源**：将 plugin 条目更改为使用 GitHub、npm 或 git URL 源而不是相对路径：```
{ "name": "my-plugin", "source": { "source": "github", "repo": "owner/repo" } }
``` 
*   **使用基于 Git 的 Marketplace**：在 Git 存储库中托管你的 marketplace 并使用 git URL 添加它。基于 Git 的 marketplaces 克隆整个存储库，使相对路径有效。

### 安装后文件未找到

**症状**：Plugin 安装但对文件的引用失败，特别是 plugin 目录外的文件**原因**：Plugins 被复制到缓存目录而不是就地使用。引用 plugin 目录外文件的路径（如 `../shared-utils`）不会工作，因为这些文件不会被复制。**解决方案**：见 [Plugin 缓存和文件解析](https://code.claude.com/docs/zh-CN/plugins-reference#plugin-caching-and-file-resolution) 了解解决方法，包括符号链接和目录重组。有关其他调试工具和常见问题，请参阅[调试和开发工具](https://code.claude.com/docs/zh-CN/plugins-reference#debugging-and-development-tools)。

## 另见

*   [发现和安装预构建的 plugins](https://code.claude.com/docs/zh-CN/discover-plugins) - 从现有 marketplaces 安装 plugins
*   [Plugins](https://code.claude.com/docs/zh-CN/plugins) - 创建你自己的 plugins
*   [Plugins 参考](https://code.claude.com/docs/zh-CN/plugins-reference) - 完整的技术规范和架构
*   [Plugin 设置](https://code.claude.com/docs/zh-CN/settings#plugin-settings) - Plugin 配置选项
*   [strictKnownMarketplaces 参考](https://code.claude.com/docs/zh-CN/settings#strictknownmarketplaces) - 托管 marketplace 限制

