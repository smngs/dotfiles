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
	atom-one-dark-theme
	dashboard
    yatex
    mozc
	evil
	websocket
    web-server
    uuidgen
    markdown-mode
    magit
	tabbar
    rainbow-delimiters
	yaml-mode
	docker-tramp
	dockerfile-mode
	auto-complete
	py-autopep8
	yasnippet
	elpy
	python-mode
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

; --- atom-one-dark --- ;
(load-theme 'atom-one-dark t)

; --- evil-mode --- ;
(require 'evil)
(evil-mode 1)

(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd ":") 'evil-repeat-find-char)
  (define-key evil-motion-state-map (kbd ";") 'evil-ex))

; --- Powerline --- ;
(require 'powerline-evil)

(require 'airline-themes)
(load-theme 'airline-powerlineish t)

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

(require 'cl-lib)
(require 'color)
(defun rainbow-delimiters-using-stronger-colors ()
  (interactive)
  (cl-loop
   for index from 1 to rainbow-delimiters-max-face-count
   do
   (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
    (cl-callf color-saturate-name (face-foreground face) 30))))
(add-hook 'emacs-startup-hook 'rainbow-delimiters-using-stronger-colors)

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

; --- tabbar --- ;
(when window-system
(require 'tabbar)
(tabbar-mode 1)

(tabbar-mwheel-mode -1)
(setq tabbar-buffer-groups-function nil)

(dolist (btn '(tabbar-buffer-home-button
               tabbar-scroll-left-button
               tabbar-scroll-right-button))
        (set btn (cons (cons "" nil)
                 (cons "" nil))))

(setq tabbar-auto-scroll-flag nil)
(setq tabbar-separator '(1.5))

(set-face-attribute
 'tabbar-default nil
 :family "CodeM"
 :background "#282C34"
 :foreground "gray28"
 :height 0.9)
(set-face-attribute
 'tabbar-unselected nil
 :background "#282C34"
 :foreground "grey28"
 :box '(:line-width 3 :color "#282C34"))
(set-face-attribute
 'tabbar-selected nil
 :background "#282C34"
 :foreground "gray72"
 :box '(:line-width 3 :color "#282C34"))
(set-face-attribute
 'tabbar-button nil
 :box nil)

(defvar my-tabbar-displayed-buffers
 '("scratch*" "*Messages*" "*Backtrace*" "*Colors*" "*Faces*")
  "*Regexps matches buffer names always included tabs.")
(defun my-tabbar-buffer-list ()
  "Return the list of buffers to show in tabs.
Exclude buffers whose name starts with a space or an asterisk.
The current buffer and buffers matches `my-tabbar-displayed-buffers'
are always included."
  (let* ((hides (list ?\  ?\*))
         (re (regexp-opt my-tabbar-displayed-buffers))
         (cur-buf (current-buffer))
         (tabs (delq nil
                     (mapcar (lambda (buf)
                               (let ((name (buffer-name buf)))
                                 (when (or (string-match re name)
                                           (not (memq (aref name 0) hides)))
                                   buf)))
                             (buffer-list)))))
    (if (memq cur-buf tabs)
        tabs
      (cons cur-buf tabs))))
(setq tabbar-buffer-list-function 'my-tabbar-buffer-list)
)
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

(cond(window-system
      (setq x-select-enable-clipboard t)
      ))

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
	(yatex yaml-mode websocket web-server uuidgen tabbar rainbow-delimiters powerline-evil mozc markdown-mode magit dockerfile-mode docker-tramp atom-one-dark-theme airline-themes))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
