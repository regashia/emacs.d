;;; Init
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))


;;; package
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")
	("org" . "http://orgmode.org/elpa/")))
(package-initialize)

(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (if (boundp 'package-selected-packages)
            ;; Record this as a package the user installed explicitly
            (package-install package nil)
          (package-install package))
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nil if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to
locate PACKAGE."
  (condition-case err
      (require-package package min-version no-refresh)
    (error
     (message "Couldn't install optional package `%s': %S" package err)
     nil)))


;;; bind-key
(require-package 'bind-key)


;;; Editing utils
;; Unix style C-h
(bind-keys*
 ("C-h" . backward-delete-char-untabify)
 ("M-h" . backward-kill-word)
 ("DEL" . help-for-help)
 ("M-DEL" . mark-paragraph))


;;; EditorConfig
(when (maybe-require-package 'editorconfig)
  (editorconfig-mode 1))


;;; Final
(when (file-exists-p custom-file)
  (load custom-file))
