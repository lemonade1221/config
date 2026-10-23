# Emacs 配置

个人 Emacs 配置：Gruber Darker、Dashboard、Vertico/Smex、多光标、Magit、翻译，以及 Org / Org-roam 和 LaTeX 预览。

## 安装

需要 **Emacs 30.1 或更新版本**、Git，以及首次启动时能访问 GNU ELPA、NonGNU ELPA 和 MELPA 的网络。Org-roam 数据库需要 Emacs 编译时启用 SQLite；可用 `M-: (sqlite-available-p)` 检查。缺少 SQLite 时，其他配置仍可加载，但不会自动开启 Org-roam 数据库同步。

macOS / Linux：先备份已有配置，然后运行：

```sh
mkdir -p ~/.config
git clone https://github.com/lemonade1221/config.git ~/.config/emacs
emacs
```

若已有 `~/.emacs`、`~/.emacs.el` 或 `~/.emacs.d/`，它们可能优先于此目录加载；请先备份并移开。也可以显式指定目录：

```sh
emacs --init-directory ~/.config/emacs
```

Windows：克隆到任意目录后，使用 `emacs --init-directory "配置目录"` 启动。

首次启动会自动安装缺少的软件包，耗时取决于网络；后续启动会使用本地 `elpa/`，不会每次刷新软件包源。下载失败时检查网络后重启即可继续。配置使用软件包源当前可用版本，尚未锁定依赖版本。

macOS 图形版可用 `/Applications/Emacs.app/Contents/MacOS/Emacs` 代替上面的 `emacs`；系统自带的旧版 Emacs 不适用。

## 可选的外部工具

- Org LaTeX 公式预览：安装 TeX Live / MacTeX，确保 `latex` 和 `dvisvgm` 位于 Emacs 的 `exec-path`；未安装时仍能编辑 Org 文档。
- `org-download` 剪贴板图片：macOS 需要 `pngpaste`；Linux 通常需要 ImageMagick 的 `magick` 命令，具体取决于 `org-download-screenshot-method`。
- Quickrun：根据运行的语言安装对应编译器或解释器，例如 Rust 的 `rustc`。
- 翻译服务和 Org-roam UI 使用时需要相应的网络访问或浏览器。

## 个人数据与维护

Org-roam 首次启动会创建 `~/org/roam-notes/`。笔记内容不在本仓库内，需要单独备份或同步；可在 `init.el` 中修改 `org-roam-directory`。

`custom-defaults.el` 保存共享的界面默认设置；`custom.el` 保存本机通过 Customize 生成的覆盖设置，已被 Git 忽略。软件包安装以 `init.el` 中的 `rc/require` 和 `use-package :ensure` 声明为准，无需从旧电脑复制 `elpa/`。

会话历史、TRAMP 缓存、书签、Org-roam 数据库、LaTeX 预览缓存及自动保存文件均被 Git 忽略。提交前用 `git status` 检查，只同步配置文件。

常用快捷键：`C-c g s` 打开 Magit，`C-c t` 翻译，`C-c q` 运行代码，`C-c n f` 查找笔记，Org 中 `C-c p` 粘贴图片。

## 启动验证

从仓库根目录运行下列命令；它会使用本仓库的配置和 `elpa/`，首次运行同样会安装依赖，并创建默认笔记目录。

```sh
emacs --batch -Q -l tests/smoke.el
```

若要验证全新安装，可将仓库克隆到临时目录后运行同一命令。验证包含配置加载、Org 模式和 SQLite 可用时的 Org-roam 数据库连接。
