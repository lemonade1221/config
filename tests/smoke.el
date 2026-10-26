;;; smoke.el --- Exercise real lazy-loading paths offline -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'ert)
(setq user-emacs-directory
      (file-name-as-directory
       (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name)))))
(setq debug-on-error t)
(defvar rc/test-notes (make-temp-file "emacs-roam-test-" t))
(setq org-roam-directory rc/test-notes
      org-roam-db-location (expand-file-name "org-roam.db" rc/test-notes))
;; An already installed configuration must never need network access to start.
(cl-letf (((symbol-function 'package-refresh-contents)
           (lambda (&rest _) (error "Unexpected package archive refresh")))
          ((symbol-function 'package-install)
           (lambda (&rest _) (error "Unexpected package installation"))))
  (load (expand-file-name "early-init.el" user-emacs-directory) nil nil t)
  (load (expand-file-name "init.el" user-emacs-directory) nil nil t))

(ert-deftest rc/configuration-integration ()
  ;; Visible startup behavior remains ready; heavy optional features stay lazy.
  (should (custom-theme-enabled-p 'gruber-darker))
  (should (bound-and-true-p vertico-mode))
  (should (bound-and-true-p ido-mode))
  (should (featurep 'dashboard))
  (dolist (feature '(gt org org-download org-roam org-roam-ui magit quickrun
                       multiple-cursors rust-mode))
    (should-not (featurep feature)))
  (dolist (binding '(("M-x" . smex)
                     ("C-c t" . gt-translate)
                     ("C-c T" . rc/translate-long-text)
                     ("C-c q" . quickrun)
                     ("C-c g s" . magit-status)
                     ("C-c n f" . org-roam-node-find)
                     ("C-c n u" . org-roam-ui-mode)
                     ("C->" . mc/mark-next-like-this)))
    (should (eq (key-binding (kbd (car binding))) (cdr binding))))
  ;; The startup hook must enable Git indicators without requiring a save first.
  (run-hooks 'after-init-hook)
  (should (bound-and-true-p global-diff-hl-mode))
  ;; First invocation of the long-text shortcut must pass its Google translator,
  ;; rather than nil from evaluating arguments before loading the configuration.
  (let* (received
         (capture (lambda (translator &rest _) (setq received translator))))
    (advice-add 'gt-start :override capture)
    (unwind-protect
        (progn
          (call-interactively (key-binding (kbd "C-c T")))
          (should (featurep 'gt))
          (should received)
          (should (eq received gt-long-text-translator))
          (should (object-of-class-p (car (oref received engines)) 'gt-google-engine)))
      (advice-remove 'gt-start capture)))
  ;; First Org buffer must get all existing visual modes and clipboard binding.
  (with-temp-buffer
    (insert "* Heading\nSome *bold* text.\n")
    (org-mode)
    (should org-appear-mode)
    (should org-modern-mode)
    (should org-fragtog-mode)
    (should org-indent-mode)
    (should org-hide-emphasis-markers)
    (should (eq (local-key-binding (kbd "C-c p")) 'org-download-clipboard))
    (should (featurep 'org-tempo))
    (should (featurep 'ox-md)))
  (when (and (fboundp 'sqlite-available-p) (sqlite-available-p))
    (should org-roam-db-autosync-mode)
    (should (equal (org-roam-db-query [:select 1]) '((1))))
    ;; Verify that a newly created note enters the real SQLite index on save.
    (let ((file (expand-file-name "integration.org" rc/test-notes)))
      (with-current-buffer (find-file-noselect file)
        (unwind-protect
            (progn
              (insert ":PROPERTIES:\n:ID: 4b5d9480-13f7-45e4-b2ab-7911f37243ca\n:END:\n#+title: Migration test\n")
              (save-buffer)
              (should (org-roam-node-from-id "4b5d9480-13f7-45e4-b2ab-7911f37243ca")))
          (set-buffer-modified-p nil)
          (kill-buffer)))))
  (with-temp-buffer
    (setq buffer-file-name "example.rs")
    (set-auto-mode)
    (should (eq major-mode 'rust-mode)))
  (dired rc/test-notes)
  (should (featurep 'org-download))
  (should (equal (default-value 'org-download-image-dir) "./images")))

(let (stats)
  (unwind-protect
      (setq stats (ert-run-tests-batch t))
    (when (fboundp 'org-roam-db--close-all) (org-roam-db--close-all))
    (delete-directory rc/test-notes t))
  (kill-emacs (if (zerop (ert-stats-completed-unexpected stats)) 0 1)))
