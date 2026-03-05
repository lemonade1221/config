;; ======================================
;; 自定义设置文件（分离自定义配置）
;; ======================================
(setq custom-file "~/.emacs.custom.el")
(when (file-exists-p custom-file)
  (load custom-file))
(load "~/rc.el")
;; ======================================
;; 界面设置,功能启用
;; ======================================
(setq initial-frame-alist '((fullscreen . maximized)));默认为最大化
(set-frame-font "Consolas-14")
(rc/require-theme 'gruber-darker)
(menu-bar-mode -1)    ; 禁用菜单栏
(tool-bar-mode -1)    ; 禁用工具栏
(toggle-scroll-bar -1) ; 禁用滚动条
(electric-pair-mode t);自动补全括号
(global-auto-revert-mode t);自动刷新buffer
(add-hook 'prog-mode-hook #'show-paren-mode) ; 编程模式下，光标在括号上时高亮另一个括号

(global-display-line-numbers-mode 1) ; 启用行号
(setq display-line-numbers-type 'relative) ; 相对行号
(setq inhibit-startup-message t) ; 关闭欢迎界面
(setq frame-title-format "%f") ;显示文件相对路径
(setq ring-bell-function 'ignore);屏蔽警告音
(setq-default c-basic-offset 4)

(ido-mode 1)
(setq ido-everywhere t)
(ido-everywhere 1)
(rc/require 'smex)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
(rc/require 'vertico)
(vertico-mode 1)





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
;; gt.el 配置 (原 go-translate)
;; ======================================
(rc/require 'gt)
(require 'gt)
(setq gt-default-translator
       (gt-translator
        :taker (gt-taker :langs '(en zh))
        :engines (list (gt-youdao-dict-engine) (gt-bing-engine))
        :render (gt-buffer-render)))

;; 3. 绑定快捷键 (g_translate-at-point 已废弃，统一使用 gt-do-setup)
(global-set-key (kbd "C-c t") 'gt-translate)

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

;; 3. Visual-Fill-Column: 模拟 Typora 居中写作效果
(defun rc/org-visual-setup ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1)
  (display-line-numbers-mode -1)) ; 写作模式通常关闭行号

(add-hook 'org-mode-hook #'rc/org-visual-setup)

;; 4. Org-Download: 类似 Typora 粘贴剪贴板图片
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
  (setq org-roam-directory (file-truename "~/roam-notes/"))

  ;; 2. 数据库自动同步 (这是 org-roam 快速搜索的基础)
  (org-roam-db-autosync-mode)

  ;; 3. 自定义单词笔记模板 (针对你记单词的需求)
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${title}.org" "#+title: ${title}\n")
           :unnarrowed t)
          ("w" "word" plain "* Root: %?\n* Definition:\n* Example:"
           :target (file+head "words/%<%Y%m%d>-${title}.org" "#+title: ${title}\n#+filetags: :word:")
           :unnarrowed t))))

;; 4. 快捷键绑定 (Org-roam 的灵魂)
(global-set-key (kbd "C-c n c") 'org-roam-capture)
(global-set-key (kbd "C-c n f") 'org-roam-node-find)   ; 查找/创建笔记
(global-set-key (kbd "C-c n i") 'org-roam-node-insert) ; 在当前位置插入链接
(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle) ; 显示双向链接侧边栏
(global-set-key (kbd "C-c n u") 'org-roam-ui-mode)
