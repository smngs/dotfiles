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
    yatex
    mozc
	evil
	evil-collection
	websocket
	xclip
    web-server
    uuidgen
    markdown-mode
	magit
    evil-magit
	git-gutter-fringe
    rainbow-delimiters
	yaml-mode
	docker-tramp
	dockerfile-mode
	helm
	which-key
	py-autopep8
	yasnippet
	helm-c-yasnippet
	elpy
	python-mode
	diminish
	flycheck
	helm-flycheck
    ))

(let ((not-installed (loop for x in installing-package-list
                            when (not (package-installed-p x))
                            collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
        (package-install pkg))))

(add-to-list 'default-frame-alist '(font . "CodeM-10" ))

; --- color-theme (iceberg) --- ;
(load-theme 'iceberg t)

; --- evil-mode --- ;
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(require 'evil)
(when (require 'evil-collection nil t)
  (evil-collection-init))

; --- evil-mode --- ;
(require 'evil)
(evil-mode 1)

; --- Powerline --- ;
(require 'powerline-evil)
(powerline-evil-vim-theme)
(require 'airline-themes)
(load-theme 'airline-powerlineish t)

(setq airline-helm-colors 0)
(setq airline-cursor-colors 0)

; --- doom-modeline --- ;
; (defun setup-custom-doom-modeline ()
;   (doom-modeline-set-modeline 'my-simple-line 'default))
; 
; (add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline)
; 
; (require 'doom-modeline)
; (doom-modeline-mode 1)

; --- helm --- ;
(require 'helm)
(require 'helm-config)

(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")  'helm-select-action)

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p t
      helm-move-to-line-cycle-in-source t
      helm-ff-search-library-in-sexp t
      helm-scroll-amount 8
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)

(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(helm-autoresize-mode 1)
(helm-mode 1)

(global-set-key (kbd "M-x") 'helm-M-x)
(setq helm-M-x-fuzzy-match t)

(global-set-key (kbd "C-x C-f") 'helm-find-files)

(global-set-key (kbd "M-y") 'helm-show-kill-ring)

; --- flycheck --- ;
(which-key-mode)

; --- flycheck --- ;
(global-flycheck-mode)

; --- YaTeX --- ;
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
         (setq tex-pdfview-command "xdg-open"))
)
(add-hook 'yatex-mode-hook
		  (function
           (lambda ()
         (YaTeX-define-key "\C-c" '(lambda () (interactive) (YaTeX-typeset-menu nil ?j)))
)))

; --- RefTeX --- ;
(add-hook 'yatex-mode-hook 'turn-on-reftex)

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
(require 'evil-magit)
(global-set-key (kbd "C-c g") 'magit-status)

; --- git-gutter --- ;
(require 'git-gutter-fringe)

;  --- yaml-mode --- ;
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

; --- py-autopep8 --- ;
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)

; --- yasnippet --- ;
(require 'yasnippet)
(require 'helm-c-yasnippet)
(setq helm-yas-space-match-any-greedy t)
(global-set-key (kbd "C-c y") 'helm-yas-complete)
(push '("emacs.+/snippets/" . snippet-mode) auto-mode-alist)
(yas-global-mode 1)

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
; (setq display-time-string-forms
;       '((format "%s/%s/%s(%s) %s:%s" year month day dayname 24-hours minutes)
;         load
;         (if mail " Mail" "")))
; (setq display-time-kawakami-form t)
; (setq display-time-24hr-format t)
; (display-time)

; Language
(set-locale-environment nil)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

; Tab
(setq default-tab-width 4)

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

(require 'xclip)
(xclip-mode 1)

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
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
	(doom-modeline dashboard-project-status diminish yatex yaml-mode websocket web-server uuidgen tabbar rainbow-delimiters python-mode py-autopep8 powerline-evil mozc markdown-mode magit flymake-python-pyflakes flymake-cursor elpy dockerfile-mode docker-tramp dashboard auto-complete atom-one-dark-theme airline-themes))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
