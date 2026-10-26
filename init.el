;;; init.el --- Portable personal Emacs configuration -*- lexical-binding: t; -*-

(when (version< emacs-version "30.1")
  (error "This configuration requires Emacs 30.1 or newer"))

;; 提高启动时的 GC 阈值，加快加载速度
(setq gc-cons-threshold (* 50 1024 1024))

;; 启动完成后恢复到一个合理的水平，避免长时间卡顿
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024))))

;; ======================================
;; 自定义设置文件（分离自定义配置）
;; ======================================
(defvar rc/config-dir (file-name-directory (or load-file-name buffer-file-name)))
(load (expand-file-name "custom-defaults.el" rc/config-dir))
(setq custom-file (expand-file-name "custom.el" rc/config-dir))
(when (file-exists-p custom-file)
  (load custom-file))
(setq package-user-dir (expand-file-name "elpa" rc/config-dir))
(require 'package)
(package-initialize)
;; Package sources and pins stay independent of package loading.
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/"))
      package-pinned-packages
      '((magit . "nongnu") (magit-section . "nongnu")))
(require 'use-package)
(require 'subr-x)
;; ======================================
;; 界面设置,功能启用
;; ======================================
(setq initial-frame-alist '((fullscreen . maximized)));默认为最大化
(when (display-graphic-p)
 (cond
 ;; Windows 系统
 ((eq system-type 'windows-nt)
  (set-frame-font "Consolas-16"))

 ;; macOS 系统 (通常用 Menlo 或 Monaco)
 ((eq system-type 'darwin)
  (set-frame-font "Menlo-16"))

 ;; Linux 系统 (通常用 DejaVu Sans Mono 或 JetBrains Mono)
 (t
  (set-frame-font "Monospace-16"))))

(use-package gruber-darker-theme
  :ensure t
  :demand t
  :config
  (load-theme 'gruber-darker t))
(menu-bar-mode -1)    ; 禁用菜单栏
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))    ; 禁用工具栏
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1)) ; 禁用滚动条
(electric-pair-mode t);自动补全括号
(fset 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t);自动刷新buffer
(add-hook 'prog-mode-hook #'show-paren-mode) ; 编程模式下，光标在括号上时高亮另一个括号
(setq make-backup-files nil)

(setq display-line-numbers-type 'relative);相对行号
(global-display-line-numbers-mode 1) ; 启用行号
(setq compile-command "")
(setq inhibit-startup-message t) ; 关闭欢迎界面
(setq frame-title-format "%f") ;显示文件相对路径
(setq ring-bell-function 'ignore);屏蔽警告音
(setq c-basic-offset 4)

(use-package dashboard
  :ensure t
  :demand t
  :config
  (setq dashboard-startup-banner (expand-file-name "banners/rao-emacs-flat.txt" rc/config-dir)
        dashboard-banner-logo-title nil
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-set-init-info t
        dashboard-items '((recents . 5)
                          (bookmarks . 5)))
  (when (and (boundp 'org-agenda-files) org-agenda-files)
    (add-to-list 'dashboard-items '(agenda . 5) t))
  (dashboard-setup-startup-hook)
)

(ido-mode 1)
(setq ido-everywhere t)
(ido-everywhere 1)
(setq ido-auto-merge-work-directories-length -1)
(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("C-c C-c M-x" . execute-extended-command)))

(use-package vertico
  :ensure t
  :demand t
  :custom
  (vertico-count 4)
  (vertico-resize nil)
  :config
  (vertico-mode 1))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-\"" . mc/skip-to-next-like-this)
         ("C-:" . mc/skip-to-previous-like-this)))

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")

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
(use-package magit
  :ensure t
  :bind (("C-c g s" . magit-status)
         ("C-c g l" . magit-log-current)
         ("C-c g b" . magit-blame-addition)))

(use-package diff-hl
  :ensure t
  :hook ((after-init . global-diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (after-save . diff-hl-update))
  :bind (("C-c g n" . diff-hl-next-hunk)
         ("C-c g p" . diff-hl-previous-hunk)
         ("C-c g r" . diff-hl-revert-hunk)))

;; ======================================
;; gt.el 配置
;; ======================================
(defvar gt-long-text-translator nil)

(use-package gt
  :ensure t
  :commands gt-start
  :bind (("C-c t" . gt-translate)
         ("C-c T" . rc/translate-long-text))
  :config
  (defun rc/translate-long-text ()
    "Translate long text using the configured Google engine."
    (interactive)
    (gt-start gt-long-text-translator))
  (setq gt-default-translator
        (gt-translator
         :taker (gt-taker :langs '(en zh))
         :engines (list (gt-youdao-dict-engine) (gt-bing-engine))
         :render (gt-buffer-render))
        gt-long-text-translator
        (gt-translator
         :taker (gt-taker :langs '(en zh))
         :engines (list (gt-google-engine))
         :render (gt-buffer-render))))

;; ======================================
;; Org: settings are ready before the first Org buffer is created.
;; ======================================
(use-package org
  :ensure nil
  :defer t
  :init
  ;; 1. 基础视觉优化：隐藏标记符号，开启缩进
  (setq org-startup-indented t            ; 开启自动缩进
        org-hide-emphasis-markers t       ; 隐藏 *粗体* / /斜体/ 的符号
        org-startup-with-inline-images t  ; 自动显示图片
        org-image-actual-width nil        ; 允许图片缩放
        org-fontify-whole-heading-line t  ; 标题行整行高亮
        org-support-shift-select t        ; 支持 Shift 选择
        org-preview-latex-default-process 'dvisvgm ; 使用 SVG 渲染公式
        org-preview-latex-image-directory (expand-file-name "org-latex-preview/" user-emacs-directory))
  :config
  (plist-put org-format-latex-options :scale 1.6)
  (keymap-set org-mode-map "C-c p" #'org-download-clipboard)

  ;; 2. 增强标题字号 (让它看起来更像 Markdown 编辑器)
  (custom-set-faces
   '(org-level-1 ((t (:height 1.4 :weight bold :foreground "#6699cc"))))
   '(org-level-2 ((t (:height 1.2 :weight bold :foreground "#99cc99"))))
   '(org-level-3 ((t (:height 1.1 :weight bold :foreground "#f2777a"))))
   '(org-document-title ((t (:height 1.7 :weight bold :underline t))))
   '(org-block ((t (:inherit fixed-pitch :background "#181818" :extend t))))
   '(org-block-begin-line ((t (:background "#202020" :foreground "#cc8c3c" :extend t))))
   '(org-block-end-line ((t (:background "#202020" :foreground "#7c6f64" :extend t))))
   '(org-meta-line ((t (:background "#202020" :foreground "#cc8c3c" :weight bold :extend t))))
   '(org-code ((t (:inherit fixed-pitch :background "#202020" :foreground "#e4e4ef"))))
   '(org-verbatim ((t (:inherit fixed-pitch :background "#202020" :foreground "#e4e4ef")))))

  ;; 3. 快速插入代码块 (输入 <s 然后按 TAB)
  (add-to-list 'org-structure-template-alist '("s" . "src"))
  (add-to-list 'org-structure-template-alist '("e" . "example"))
  )

(use-package org-tempo
  :ensure nil
  :after org)

(use-package ox-md
  :ensure nil
  :after org)
;; Org extensions load when entering Org, preserving the current editing UI.
(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star 'replace))

;; Retained for compatibility; the original configuration did not enable it.
(use-package visual-fill-column
  :ensure t
  :commands visual-fill-column-mode)

(use-package org-fragtog
  :ensure t
  :hook (org-mode . org-fragtog-mode))

(use-package org-download
  :ensure t
  :commands (org-download-clipboard org-download-screenshot)
  :hook (dired-mode . org-download-enable)
  :init
  (setq-default org-download-image-dir "./images"))

(defvar rc/org-roam-idle-timer nil)

(defun rc/start-org-roam ()
  "Enable note synchronization before editing Org or once Emacs is idle."
  (when (timerp rc/org-roam-idle-timer)
    (cancel-timer rc/org-roam-idle-timer)
    (setq rc/org-roam-idle-timer nil))
  (when (and (fboundp 'sqlite-available-p) (sqlite-available-p))
    ;; Loading runs the declaration's :config and enables synchronization.
    (require 'org-roam)
    (unless (bound-and-true-p org-roam-db-autosync-mode)
      (org-roam-db-autosync-mode 1))))

(use-package org-roam
  :ensure t
  :commands org-roam-db-autosync-mode
  :hook (org-mode . rc/start-org-roam)
  :bind (("C-c n c" . org-roam-capture)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n l" . org-roam-buffer-toggle))
  :init
  (defvar org-roam-directory (expand-file-name "~/org/roam-notes/"))
  (unless noninteractive
    (setq rc/org-roam-idle-timer
          (run-with-idle-timer 2 nil #'rc/start-org-roam)))
  :config
  (make-directory org-roam-directory t)
  (if (and (fboundp 'sqlite-available-p) (sqlite-available-p))
      (org-roam-db-autosync-mode 1)
    (display-warning 'rc "Org-roam needs an Emacs build with SQLite support.")))

(use-package org-roam-ui
  :ensure t
  :bind ("C-c n u" . org-roam-ui-mode))

;; ======================================
;; 显示启动时间
;; ======================================

(defun startup-timer ()
  (message "Start up finished in %.3f s"
           (float-time (time-subtract after-init-time before-init-time))))
(add-hook 'emacs-startup-hook #'startup-timer)
