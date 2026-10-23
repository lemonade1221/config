;;; rc.el --- Package bootstrap -*- lexical-binding: t; -*-
(require 'package)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))
(setq package-pinned-packages
      '((magit . "nongnu")
        (magit-section . "nongnu")))

(defvar rc/package-contents-refreshed nil)

(defun rc/package-refresh-contents-once ()
  "Refresh package metadata at most once per startup."
  (unless rc/package-contents-refreshed
    (package-refresh-contents)
    (setq rc/package-contents-refreshed t)))

(defun rc/require-one-package (package)
  "Install PACKAGE if missing, including its dependencies."
  (unless (package-installed-p package)
    (rc/package-refresh-contents-once)
    (unless (assq package package-archive-contents)
      (error "Package %s unavailable; check network access to GNU/NonGNU ELPA and MELPA" package))
    (package-install package)))

(defun rc/require (&rest packages)
  "Ensure that all PACKAGES are installed."
  (dolist (package packages)
    (rc/require-one-package package)))

(defun rc/require-theme (theme)
  "Install and load THEME."
  (rc/require (intern (concat (symbol-name theme) "-theme")))
  (load-theme theme t))

;;; rc.el ends here
