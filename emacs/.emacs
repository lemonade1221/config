

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
(setq frame-title-format "%f")
(ido-mode 1)
(ido-everywhere 1)

(rc/require 'smex)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

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

(global-set-key (kbd "C-,") 'rc/duplicate-line)(defun duplicate-line ()

;; ======================================
;; gtags 配置（代码导航）
;; ======================================
(rc/require 'gtags)
;; 启用 gtags 模式
(gtags-mode t)

;; 设置 gtags 相关快捷键
(global-set-key (kbd "C-c g f") 'gtags-find-file)    ; 查找文件
(global-set-key (kbd "M-.") 'gtags-find-symbol)  ; 查找符号定义
(global-set-key (kbd "C-c g r") 'gtags-find-rtag)    ; 查找引用
(global-set-key (kbd "C-c g u") 'gtags-pop-stack)    ; 返回上一位置
(global-set-key (kbd "C-c g v") 'gtags-find-with-grep) ; 使用 grep 查找

;; 自动在编程模式下启用 gtags
(add-hook 'prog-mode-hook
          (lambda ()
            (gtags-mode 1)
            (setq gtags-suggested-key-mapping t)))
;; ======================================
;; quickrun 配置（代码快速执行）
;; ======================================
(use-package quickrun
  :ensure t
  :bind (("C-c q" . quickrun)      ; 运行当前文件
         ("C-c r" . quickrun-region))) ; 运行选中区域
