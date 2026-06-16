;;; early-init.el --- Early startup settings -*- lexical-binding: t; -*-

;; Keep installed packages in the config directory; this config
;; repository only tracks hand-written configuration.
(setq package-enable-at-startup nil)
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))

;;; early-init.el ends here
