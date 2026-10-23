;;; smoke.el --- Load the real configuration in batch -*- lexical-binding: t; -*-
(setq user-emacs-directory
      (file-name-as-directory
       (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name)))))
(setq debug-on-error t)
(load (expand-file-name "early-init.el" user-emacs-directory) nil nil t)
(load (expand-file-name "init.el" user-emacs-directory) nil nil t)
(require 'org)
(with-temp-buffer
  (org-mode)
  (unless (and org-appear-mode org-modern-mode org-fragtog-mode)
    (error "Org mode extensions did not start")))
(dolist (package '(quickrun magit diff-hl))
  (unless (package-installed-p package)
    (error "Missing package: %s" package)))
(unless (and (featurep 'use-package)
             (custom-theme-enabled-p 'gruber-darker)
             (file-directory-p org-roam-directory))
  (error "Configuration bootstrap is incomplete"))
(when (and (fboundp 'sqlite-available-p) (sqlite-available-p))
  (unless (equal (org-roam-db-query [:select 1]) '((1)))
    (error "Org-roam database query failed")))
(princ "Configuration smoke test passed.\n")
