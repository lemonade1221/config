;; 提高启动时的 GC 阈值，加快加载速度
(setq gc-cons-threshold (* 50 1024 1024))

;; 启动完成后恢复到一个合理的水平，避免长时间卡顿
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024))))

;; 暂时禁用 file-name-handler 以加速启动
(setq default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist default-file-name-handler-alist)))
;; ======================================
;; 自定义设置文件（分离自定义配置）
;; ======================================
(defvar rc/config-dir (file-name-directory (or load-file-name buffer-file-name)))
(setq custom-file (expand-file-name "custom.el" rc/config-dir))
(when (file-exists-p custom-file)
  (load custom-file))
(setq package-user-dir (expand-file-name "elpa" rc/config-dir))
(require (quote package))
(package-initialize)
(load (expand-file-name "rc.el" rc/config-dir))
;; ======================================
;; 界面设置,功能启用
;; ======================================
(setq initial-frame-alist '((fullscreen . maximized)));默认为最大化
(cond
 ;; Windows 系统
 ((eq system-type 'windows-nt)
  (set-frame-font "Consolas-16"))

 ;; macOS 系统 (通常用 Menlo 或 Monaco)
 ((eq system-type 'darwin)
  (set-frame-font "Menlo-16"))

 ;; Linux 系统 (通常用 DejaVu Sans Mono 或 JetBrains Mono)
 (t
  (set-frame-font "Monospace-16")))
(rc/require-theme 'gruber-darker)
(menu-bar-mode -1)    ; 禁用菜单栏
(tool-bar-mode -1)    ; 禁用工具栏
(toggle-scroll-bar -1) ; 禁用滚动条
(electric-pair-mode t);自动补全括号
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t);自动刷新buffer
(add-hook 'prog-mode-hook #'show-paren-mode) ; 编程模式下，光标在括号上时高亮另一个括号
(setq make-backup-files nil)

(global-display-line-numbers-mode 1) ; 启用行号
(setq display-line-numbers-type 'relative) ; 相对行号
(setq inhibit-startup-message t) ; 关闭欢迎界面
(setq frame-title-format "%f") ;显示文件相对路径
(setq ring-bell-function 'ignore);屏蔽警告音
(setq c-basic-offset 4)

(ido-mode 1)
(setq ido-everywhere t)
(ido-everywhere 1)
(setq ido-auto-merge-work-directories-length -1)
(rc/require 'smex)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(rc/require 'vertico)
(vertico-mode 1)
(setq vertico-count 4)               
(setq vertico-resize nil)

(rc/require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

(rc/require 'rust-mode)
;; ======================================
;; 自定义功能：复制当前行
;; ======================================
(defun rc/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

(global-set-key (kbd "C-,") 'rc/duplicate-line)
;; ======================================
;; quickrun 配置（代码快速执行）
;; ======================================
(use-package quickrun
  :ensure t
  :bind (("C-c q" . quickrun)      ; 运行当前文件
         ("C-c r" . quickrun-region))) ; 运行选中区域
;; ======================================
;; Git 工作流增强
;; ======================================
(rc/require 'magit 'diff-hl)

(use-package magit
  :ensure t
  :bind (("C-c g s" . magit-status)
         ("C-c g l" . magit-log-current)
         ("C-c g b" . magit-blame-addition)))

(use-package diff-hl
  :ensure t
  :hook ((dired-mode . diff-hl-dired-mode)
         (after-save . diff-hl-update))
  :bind (("C-c g n" . diff-hl-next-hunk)
         ("C-c g p" . diff-hl-previous-hunk)
         ("C-c g r" . diff-hl-revert-hunk))
  :config
  (global-diff-hl-mode 1))

;; ======================================
;; gt.el 配置
;; ======================================
(rc/require 'gt)
(require 'gt)

;; ========= 默认翻译（短文本） =========
(setq gt-default-translator
      (gt-translator
       :taker (gt-taker :langs '(en zh))
       :engines (list
                 (gt-youdao-dict-engine)
                 (gt-bing-engine))
       :render (gt-buffer-render)))

;; ========= 长文本翻译（论文） =========
(setq gt-long-text-translator
      (gt-translator
       :taker (gt-taker :langs '(en zh))
       :engines (list
                 ;; 推荐：DeepL 或 Google
                 (gt-google-engine)
                 ;; 如果你后面接 GPT，可以替换这里
                 )
       :render (gt-buffer-render)))

;; ========= 快捷键 =========
(global-set-key (kbd "C-c t") 'gt-translate)          ;; 默认
(global-set-key (kbd "C-c T")                         ;; 大写 T：长文本
                (lambda ()
                  (interactive)
                  (gt-start gt-long-text-translator)))

;; ======================================
;; Org-mode 扩展包安装
;; ======================================
(rc/require 'org-appear)           ; 动态显示/隐藏标记 (Typora 核心体验)
(rc/require 'org-modern)           ; 现代化的 UI 元素（标题、复选框、表格）
(rc/require 'visual-fill-column)   ; 居中排版显示
(rc/require 'org-download)         ; 截图直接粘贴到 Org (类似 Typora 粘贴图片)

;; ======================================
;; Org-mode 核心配置
;; ======================================
(with-eval-after-load 'org
  ;; 1. 基础视觉优化：隐藏标记符号，开启缩进
  (setq org-startup-indented t            ; 开启自动缩进
        org-hide-emphasis-markers t       ; 隐藏 *粗体* / /斜体/ 的符号
        org-startup-with-inline-images t  ; 自动显示图片
        org-image-actual-width nil        ; 允许图片缩放
        org-fontify-whole-heading-line t  ; 标题行整行高亮
        org-support-shift-select t)       ; 支持 Shift 选择

  ;; 2. 增强标题字号 (让它看起来更像 Markdown 编辑器)
  (custom-set-faces
   '(org-level-1 ((t (:height 1.4 :weight bold :foreground "#6699cc"))))
   '(org-level-2 ((t (:height 1.2 :weight bold :foreground "#99cc99"))))
   '(org-level-3 ((t (:height 1.1 :weight bold :foreground "#f2777a"))))
   '(org-document-title ((t (:height 1.7 :weight bold :underline t)))))

  ;; 3. 快速插入代码块 (输入 <s 然后按 TAB)
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("s" . "src"))
  (add-to-list 'org-structure-template-alist '("e" . "example"))
  ;; 加载 Markdown 导出模块
  (require 'ox-md)
  )
;; ======================================
;; 功能插件配置
;; ======================================
;; 1. Org-Appear: 只有光标在上面时才显示 * / _ 等标记
(add-hook 'org-mode-hook 'org-appear-mode)
(setq org-appear-autoemphasis t
      org-appear-autolinks t
      org-appear-autosubmarkers t)

;; 2. Org-Modern: 将星号标题、复选框等修饰为现代图形
(add-hook 'org-mode-hook #'org-modern-mode)
(setq org-modern-star 'replace) ; 替换星号标题


;; . Org-Download: 类似 Typora 粘贴剪贴板图片
(require 'org-download)
(setq-default org-download-image-dir "./images") ; 图片存储目录
(add-hook 'dired-mode-hook 'org-download-enable)
(define-key org-mode-map (kbd "C-c p") 'org-download-clipboard)
;; ======================================
;; Org-roam 核心配置
;; ======================================
(rc/require 'org-roam)
(rc/require 'org-roam-ui)
(with-eval-after-load 'org-roam
  ;; 1. 设置笔记存储目录 (请修改为你自己的路径)
  (setq org-roam-directory (file-truename "~/org/roam-notes/"))

  ;; 2. 数据库自动同步 (这是 org-roam 快速搜索的基础)
  (org-roam-db-autosync-mode)
)
;; 3. 快捷键绑定 (Org-roam 的灵魂)
(global-set-key (kbd "C-c n c") 'org-roam-capture)
(global-set-key (kbd "C-c n f") 'org-roam-node-find)   ; 查找/创建笔记
(global-set-key (kbd "C-c n i") 'org-roam-node-insert) ; 在当前位置插入链接
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle) ; 显示双向链接侧边栏
(global-set-key (kbd "C-c n u") 'org-roam-ui-mode)

;; ======================================
;; 显示启动时间
;; ======================================

(defun startup-timer ()
  (let ((elapsed (float-time (time-subtract after-init-time before-init-time))))
    (with-current-buffer "*scratch*"
      (insert (format ";; Start up finished in: %.3f s。\n" elapsed)))))
(add-hook 'emacs-startup-hook #'startup-timer)
