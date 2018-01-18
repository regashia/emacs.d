;;; Init
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Use y-or-n to important questions
(defalias 'yes-or-no-p 'y-or-n-p)


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


;;; Network security
(setq network-security-level 'low)


;;; bind-key
(require-package 'bind-key)


;;; Hydra
(require-package 'hydra)


;;; Prefix
(bind-key "C-q" nil global-map)
(bind-key* "C-q C-q" 'quoted-insert)


;;; Emacs server
(server-start)


;;; Font
(set-face-attribute 'default nil :font "Ricty-14")


;;; Editing utils
;; Disable menu bar
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

;; Cursor type
(setq-default cursor-type 'bar)

;; Disable backup file
(setq make-backup-files nil)

;; Always follow symlink
(setq vc-follow-symlinks t)

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
;; bind-key* を使用すると term-mode(fzf) での挙動がおかしくなるため、 bind-key
(bind-key "C-a" 'back-to-indentation-or-beginning)

;; Auto complete brackets
(when (maybe-require-package 'smartparens)
  (require 'smartparens-config)
  (smartparens-global-mode)

  ;; .rb
  (sp-pair "do |" "|")
  (sp-pair "{ |" "| }")
  ;; .erb
  (sp-pair "<% " " %>")
  (sp-pair "<%=" "%>")
  (sp-pair "<%= " " %>"))


;;; 終了時の状態を復元
(desktop-save-mode)


;;; multiple-cursors
(when (maybe-require-package 'multiple-cursors)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this))


;;; like vim eazymotion
(when (maybe-require-package 'avy)
  (bind-key* "C-q ;" 'avy-goto-char)
  (bind-key* "C-q '" 'avy-goto-char-2)
  (bind-key* "C-q l" 'avy-goto-line))


;;; Window
;; Change
(when (maybe-require-package 'switch-window)
  (setq switch-window-shortcut-style 'qwerty)
  (bind-key* "C-q o" 'switch-window))
(bind-key* "C-q w b" 'windmove-left)
(bind-key* "C-q w f" 'windmove-right)
(bind-key* "C-q w p" 'windmove-up)
(bind-key* "C-q w n" 'windmove-down)

;; Resize
(when (require 'hydra nil t)
  (defhydra hydra-change-window-size
    (global-map "C-q w" :timeout 0.5)
    "Change window"
    ("C-b"
      (lambda()
        (interactive)
        (shrink-window-horizontally 10)))
    ("C-f"
      (lambda()
        (interactive)
        (enlarge-window-horizontally 10)))
    ("C-p"
      (lambda()
        (interactive)
        (shrink-window 5)))
    ("C-n"
      (lambda()
        (interactive)
        (enlarge-window 5)))))

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

;; Zoom
(when (maybe-require-package 'zoom-window)
  (bind-key* (kbd "C-q 1") 'zoom-window-zoom))

;; popwin
(when (maybe-require-package 'popwin)
  (require 'popwin)
  (popwin-mode))


;;; Undo tree
(when (maybe-require-package 'undo-tree)
  (global-undo-tree-mode))


;;; ido
(ido-mode)
(ido-everywhere)
(when (maybe-require-package 'ido-completing-read+)
  (ido-ubiquitous-mode))

;; C-a
(add-hook 'ido-minibuffer-setup-hook
  (lambda ()
    (local-set-key (kbd "C-a") 'back-to-indentation-or-beginning)))

;; Fuzzy matching
(when (maybe-require-package 'flx-ido)
  (flx-ido-mode)
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil))

;; smex
(when (maybe-require-package 'smex)
  (smex-initialize)
  (bind-key* "M-x" 'smex)
  (bind-key* "M-X" 'smex-major-mode-commands)
  (bind-key* "C-q M-x" 'execute-extended-command))

;; Like helm
(when (maybe-require-package 'ido-vertical-mode)
  (ido-vertical-mode)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only)
  (setq ido-vertical-show-count t))


;;; Display key bindings
(when (maybe-require-package 'which-key)
  (which-key-mode))


;;; Dired
(require 'wdired)
(setq wdired-allow-to-change-permissions t)
(bind-key "e" 'wdired-change-to-wdired-mode dired-mode-map)

;; macos の ls コマンドに --dired オプションはない
(if (eq system-type 'darwin)
  (setq dired-use-ls-dired nil))


;;; EditorConfig
(when (maybe-require-package 'editorconfig)
  (editorconfig-mode))


;;; Git
(when (maybe-require-package 'magit)
  (bind-key* "C-q g" 'magit-status)
  (setq magit-completing-read-function 'magit-ido-completing-read)
  (setq magit-diff-refine-hunk t))

;; 変更箇所を右側に表示する
(when (maybe-require-package 'git-gutter+)
  (global-git-gutter+-mode))


;;; direnv
(when (maybe-require-package 'direnv)
  (add-hook 'find-file-hook 'direnv-update-environment))


;;; Google translate
(when (maybe-require-package 'google-translate)
  ;; 翻訳のデフォルト値を設定 (en -> zh)
  (custom-set-variables
    '(google-translate-default-source-language "en")
    '(google-translate-default-target-language "zh"))
  (global-set-key (kbd "C-q t") 'google-translate-at-point))


;;; Code completion
(when (maybe-require-package 'company)
  (global-company-mode)
  (bind-key "M-/" 'company-complete company-mode-map)
  (bind-key "M-/" 'company-select-next company-active-map)
  (bind-key "C-n" 'company-select-next company-active-map)
  (bind-key "C-p" 'company-select-previous company-active-map))


;;; Snippet
(when (maybe-require-package 'yasnippet)
  (require-package 'yasnippet-snippets)
  (yas-global-mode))


;;; Syntax checking
(when (maybe-require-package 'flycheck)
  (global-flycheck-mode))


;;; fzf
(when (maybe-require-package 'fzf)
  (bind-key* "C-q C-f"
    (lambda ()
      (interactive)
      (setq fzf/executable (concat user-emacs-directory "fzf-files"))
      (fzf)))
  (bind-key* "C-q d"
    (lambda ()
      (interactive)
      (setq fzf/executable (concat user-emacs-directory "fzf-directories"))
      (fzf))))


;;; YAML
(when (maybe-require-package 'yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode)))


;;; 括弧を特殊扱いする (Lisp 用)
(require-package 'paredit)


;;; Emacs lisp
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)


;;; Clojure
(when (maybe-require-package 'cider)
  (add-hook 'clojure-mode-hook 'paredit-mode))


;;; Ruby
;; Do not insert coding utf-8 comment
(setq ruby-insert-encoding-magic-comment nil)

;; Use enh-ruby-mode
(when (maybe-require-package 'enh-ruby-mode)
  (add-to-list 'auto-mode-alist
    '("\\(?:\\.rb\\|ru\\|rake\\|thor\\|jbuilder\\|gemspec\\|podspec\\|/\\(?:Gem\\|Rake\\|Cap\\|Thor\\|Vagrant\\|Guard\\|Pod\\)file\\)\\'" . enh-ruby-mode))
  (setq enh-ruby-add-encoding-comment-on-save nil))

;; Code completion
(when (maybe-require-package 'robe)
  (add-hook 'enh-ruby-mode-hook 'robe-mode)
  (when (require 'company nil t)
    (eval-after-load 'company
      '(push 'company-robe company-backends))))

;; Format on save
(when (maybe-require-package 'rubocop)
  (setq rubocop-autocorrect-command "bundle exec rubocop -a")

  (add-hook 'after-save-hook
    (lambda()
      (when (eq major-mode 'ruby-mode)
        (rubocop-autocorrect-current-file))))
  (add-hook 'after-save-hook
    (lambda()
      (when (eq major-mode 'enh-ruby-mode)
        (rubocop-autocorrect-current-file))))

  (when (require 'popwin nil t)
    (push '("\*RuboCop /.*\*" :regexp t) popwin:special-display-config)))

;; Rails
(when (maybe-require-package 'projectile-rails)
  (projectile-rails-global-mode)
  (setq
    projectile-rails-vanilla-command "bin/rails"
    projectile-rails-spring-command "bin/spring"))


;;; Go
(when (maybe-require-package 'go-mode)
  (require-package 'company-go)
  (add-hook 'go-mode-hook
    (lambda ()
      (when (require 'company-go nil t)
        (set (make-local-variable 'company-backends) '(company-go)))
      (add-hook 'before-save-hook 'gofmt-before-save))))


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
  ;; Auto quoting after = inside tag
  (setq web-mode-enable-auto-quoting t))


;;; Haml
(when (maybe-require-package 'haml-mode)
  (add-to-list 'auto-mode-alist '("\\.haml\\'" . haml-mode)))


;;; TypeScript
(when (maybe-require-package 'typescript-mode)
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode)))


;;; Groovy
(require-package 'groovy-mode)


;;; PlantUML
(when (maybe-require-package 'plantuml-mode)
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode)))


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

;; キーバインド
(bind-key* "C-q e"
  (lambda (keywords)
    (interactive "sEnter keywords")
    (split-window-right)
    (select-window (next-window))
    (eww keywords)))


;;; Final
(when (file-exists-p custom-file)
  (load custom-file))
