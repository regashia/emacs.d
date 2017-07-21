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
;; Disable menu bar
(menu-bar-mode 0)

;; Unix style C-h
(define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))
(define-key key-translation-map (kbd "M-h") (kbd "<C-backspace>"))
(define-key key-translation-map (kbd "DEL") (kbd "C-h"))
(define-key key-translation-map (kbd "M-DEL") (kbd "M-h"))

;; Set C-a to back to indentation or beginning
(defun back-to-indentation-or-beginning ()
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point)))
    (beginning-of-line)))
(bind-key* "C-a" 'back-to-indentation-or-beginning)


;;; Window
;; Window move
(bind-key* "C-c b" 'windmove-left)
(bind-key* "C-c f" 'windmove-right)
(bind-key* "C-c p" 'windmove-up)
(bind-key* "C-c n" 'windmove-down)

;; Change window size
(bind-key* "C-c C-b"
  (lambda()
    (interactive)
    (shrink-window-horizontally 10)))
(bind-key* "C-c C-f"
  (lambda()
    (interactive)
    (enlarge-window-horizontally 10)))
(bind-key* "C-c C-p"
  (lambda()
    (interactive)
    (shrink-window 5)))
(bind-key* "C-c C-n"
  (lambda()
    (interactive)
    (enlarge-window 5)))

;; Split and move to the window
(bind-key* "C-x 2"
  (lambda()
    (interactive)
    (split-window-below)
    (select-window (next-window))))
(bind-key* "C-x 3"
  (lambda()
    (interactive)
    (split-window-right)
    (select-window (next-window))))

;; Auto complete brackets
(electric-pair-mode)


;;; EditorConfig
(when (maybe-require-package 'editorconfig)
  (editorconfig-mode))


;;; Git
(when (maybe-require-package 'magit)
  (bind-key "C-c g" 'magit-status))


;;; direnv
(when (maybe-require-package 'direnv)
  (direnv-mode))


;;; Google translate
(when (maybe-require-package 'google-translate)
  ;; 翻訳のデフォルト値を設定 (en -> zh)
  (custom-set-variables
    '(google-translate-default-source-language "en")
    '(google-translate-default-target-language "zh"))
  (global-set-key (kbd "C-c t") 'google-translate-at-point))


;;; eww
;; 背景・文字色を無効化する
(defvar eww-disable-colorize t)
(defun shr-colorize-region--disable (orig start end fg &optional bg &rest _)
  (unless eww-disable-colorize
    (funcall orig start end fg)))
(advice-add 'shr-colorize-region :around 'shr-colorize-region--disable)
(advice-add 'eww-colorize-region :around 'shr-colorize-region--disable)
(defun eww-disable-color ()
  "文字色を反映させない"
  (interactive)
  (setq-local eww-disable-colorize t)
  (eww-reload))
(defun eww-enable-color ()
  "文字色を反映させる"
  (interactive)
  (setq-local eww-disable-colorize nil)
  (eww-reload))

;; デフォルトの検索エンジンを Google に変更
(setq eww-search-prefix "http://www.google.co.jp/search?q=")

;; 複数起動可能
(defun eww-mode-hook--rename-buffer ()
  "Rename eww browser's buffer so sites open in new page."
  (rename-buffer "eww" t))
(add-hook 'eww-mode-hook 'eww-mode-hook--rename-buffer)

;; 画像はデフォルトで非表示
(defun eww-disable-images ()
  "画像表示させない"
  (interactive)
  (setq-local shr-put-image-function 'shr-put-image-alt)
  (eww-reload))
(defun eww-enable-images ()
  "画像表示させる"
  (interactive)
  (setq-local shr-put-image-function 'shr-put-image)
  (eww-reload))
(defun shr-put-image-alt (spec alt &optional flags)
  (insert alt))
;; はじめから非表示
(defun eww-mode-hook--disable-image ()
  (setq-local shr-put-image-function 'shr-put-image-alt))
(add-hook 'eww-mode-hook 'eww-mode-hook--disable-image)


;;; YAML
(when (maybe-require-package 'yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode)))


;;; Ruby
;; Use enh-ruby-mode
(when (maybe-require-package 'enh-ruby-mode)
  (add-to-list 'auto-mode-alist
    '("\\(?:\\.rb\\|ru\\|rake\\|thor\\|jbuilder\\|gemspec\\|podspec\\|/\\(?:Gem\\|Rake\\|Cap\\|Thor\\|Vagrant\\|Guard\\|Pod\\)file\\)\\'" . enh-ruby-mode))
  (setq enh-ruby-add-encoding-comment-on-save nil))

;; Rails
(when (maybe-require-package 'projectile-rails)
  (projectile-rails-global-mode)
  (setq
    projectile-rails-vanilla-command "bin/rails"
    projectile-rails-spring-command "bin/spring"))


;;; HTML
(when (maybe-require-package 'web-mode)
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

  ;; Auto close tag
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-pairing t)
  ;; Auto quoting after = inside tag
  (setq web-mode-enable-auto-quoting t))


;;; TypeScript
(when (maybe-require-package 'typescript-mode)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode)))


;;; Final
(when (file-exists-p custom-file)
  (load custom-file))
