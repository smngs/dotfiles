(setq load-path (cons "~/.emacs.d/elisp" load-path))

(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
		("marmalade" . "http;//marmalade-repo.org/packages")
        ("org" . "http://orgmode.org/elpa/")))
(package-initialize)

(require 'cl)

(defvar installing-package-list
  '(
    powerline-evil
    airline-themes
	powerline
	dashboard
    yatex
    mozc
	evil
	websocket
    web-server
    uuidgen
    markdown-mode
    magit
    rainbow-delimiters
	yaml-mode
	docker-tramp
	dockerfile-mode
	auto-complete
	py-autopep8
	yasnippet
	elpy
	python-mode
	diminish
	flymake-cursor
	flymake-python-pyflakes
    ))

(let ((not-installed (loop for x in installing-package-list
                            when (not (package-installed-p x))
                            collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
        (package-install pkg))))

(add-to-list 'default-frame-alist '(font . "CodeM-12" ))

; --- color-theme (iceberg) --- ;
(load-theme 'iceberg t)

; --- evil-mode --- ;
(require 'evil)
(evil-mode 1)

; --- Powerline --- ;
(require 'powerline-evil)
(powerline-evil-vim-theme)
(require 'airline-themes)
(load-theme 'airline-dark t)

(setq airline-helm-colors 0)
(setq airline-cursor-colors 0)

; --- auto-complete --- ;
(require 'auto-complete-config)
(ac-config-default)

; --- pyflakes --- ;
(add-hook 'find-file-hook 'flymake-find-file-hook)
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "/usr/bin/pyflakes"  (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))

(defun flymake-show-help ()
  (when (get-char-property (point) 'flymake-overlay)
    (let ((help (get-char-property (point) 'help-echo)))
      (if help (message "%s" help)))))
(add-hook 'post-command-hook 'flymake-show-help)

; --- Yatex --- ;
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq auto-mode-alist
      (append '(("\\.tex$" . yatex-mode)
        ("\\.ltx$" . yatex-mode)
        ("\\.sty$" . yatex-mode)) auto-mode-alist))
(setq YaTeX-kanji-code 4)
(add-hook 'yatex-mode-hook
      '(lambda ()
         (setq YaTeX-use-AMS-LaTeX t)
         (setq YaTeX-use-hilit19 nil
           YateX-use-font-lock t)
         (setq tex-command "latexmk")
         (setq dvi2-command "evince")
         (setq tex-pdfview-command "xdg-open")))

; --- Mozc --- ;
(require 'mozc)
(set-language-environment "Japanese")
(setq default-input-method "japanese-mozc")
(setq mozc-candidate-style 'echo-area)
(global-set-key (kbd "C-SPC") 'mozc-mode)
(global-set-key (kbd "C-j") 'mozc-mode)

; --- Markdown --- ;
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))
(setq markdown-command "pandoc -s --self-contained -t html5 --metadata title=Markdown -c ~/.emacs.d/github.css ")

; --- Rainbow-delimiters --- ;
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

; --- Magit --- ;
(global-set-key (kbd "C-c g") 'magit-status)

;  --- yaml-mode --- ;
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

; --- py-autopep8 --- ;
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)

; --- yasnippet --- ;
(yas-global-mode t)

; --- diminished mode --- ;

(defmacro safe-diminish (file mode &optional new-name)
  `(with-eval-after-load ,file
     (diminish ,mode ,new-name)))
(safe-diminish "abbrev" 'abbrev-mode)
(safe-diminish "auto-complete" 'auto-complete-mode)
(safe-diminish "eldoc" 'eldoc-mode)
(safe-diminish "flycheck" 'flycheck-mode)
(safe-diminish "flyspell" 'flyspell-mode)
(safe-diminish "helm-mode" 'helm-mode)
(safe-diminish "paredit" 'paredit-mode)
(safe-diminish "projectile" 'projectile-mode)
(safe-diminish "rainbow-mode" 'rainbow-mode)
(safe-diminish "simple" 'auto-fill-function)
(safe-diminish "smartparens" 'smartparens-mode)
(safe-diminish "smooth-scroll" 'smooth-scroll-mode)
(safe-diminish "undo-tree" 'undo-tree-mode)
(safe-diminish "volatile-highlights" 'volatile-highlights-mode)
(safe-diminish "yasnippet" 'yas-minor-mode)

; --- docker-tramp --- ;
(require 'docker-tramp-compat)

; --- dockerfile-mode --- ;
(autoload 'dockerfile-mode "dockerfile-mode" nil t)
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

; --- global --- ;
; Scroll Bar
(menu-bar-mode 0)
(tool-bar-mode 0)
(when window-system
  (scroll-bar-mode 0)
)

; Time
(setq display-time-string-forms
      '((format "%s/%s/%s(%s) %s:%s" year month day dayname 24-hours minutes)
        load
        (if mail " Mail" "")))
(setq display-time-kawakami-form t)
(setq display-time-24hr-format t)
(display-time)

; Language
(set-locale-environment nil)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

; BackUp Files
(setq create-lockfiles nil)
(setq make-backup-files nil)
(setq delete-auto-save-files t)

; HighLight
(show-paren-mode t)

; Disable Scratch message
(setq initial-scratch-message nil)

; Tramp
(setq tramp-default-method "scpx")

; Python Indent
(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map (kbd "\C-m") 'newline-and-indent)
            (define-key python-mode-map (kbd "RET") 'newline-and-indent)))

(global-linum-mode)
(setq linum-format "%4d ")

(setq hl-line-face 'underline)
(global-hl-line-mode)

(setq-default tab-width 4)
(setq x-select-enable-clipboard t)

(setq backup-directory-alist
  (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
        backup-directory-alist))

(unless (fboundp 'track-mouse)
  (defun track-mouse (e)))
(xterm-mouse-mode t)
(require 'mouse)
(require 'mwheel)
(mouse-wheel-mode t)

(setq auto-save-file-name-transforms
      `((".*", (expand-file-name "~/.emacs.d/backup/") t)))

(setq inhibit-startup-screen t)

(defalias 'yes-or-no-p 'y-or-n-p)
