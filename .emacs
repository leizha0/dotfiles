;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; package installation source
(require 'package)
(add-to-list 'package-archives
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize)

(defvar my-packages '(zenburn
                      goto-last-change
                      expand-region
                      smex
                      nrepl
                      clojure-mode))


;; (dolist (p my-packages)
;;   (package-install p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; my preferences

(load-theme 'zenburn t)
;; (load-theme 'solarized-light t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(setq line-number-mode t)
(setq column-number-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
;; (setq visible-bell t)
(setq inhibit-splash-screen t)

;; use spaces instead of tabs
(setq-default indent-tabs-mode nil)

(setq scroll-preserve-screen-position t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; disable backup files
(setq make-backup-files nil)

;; remember last edit position
(setq save-place-file "~/.emacs.d/saveplace")
(setq-default save-place t)
(require 'saveplace)

(define-key global-map (kbd "RET") 'newline-and-indent)

;;(global-set-key (kbd "ESC") 'keyboard-escape-quit)

;; (require 'auto-complete-config)
;; (ac-config-default)
;; (ac-set-trigger-key "TAB")
;; (ac-set-trigger-key "<tab>")

(setq vc-handled-backends nil)

(global-set-key (kbd "<home>") 'move-beginning-of-line)
(global-set-key (kbd "<end>") 'move-end-of-line)

(global-set-key (kbd "M-`") 'other-window)
(global-set-key (kbd "C-x /") 'comment-or-uncomment-region)

;; go to last change
(require 'goto-last-change)
(global-set-key "\C-q" 'goto-last-change)

;; delete the selected region on typing
(delete-selection-mode 1)

;; remove trailing whitespaces on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; linux style c-indent
(setq c-default-style "linux"
      c-basic-offset 2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; expand-region
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ido mode

(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)

;; disable search
(setq ido-auto-merge-delay-time 9)

(require 'smex)
(global-set-key (kbd "M-x") 'smex)

;; font and color
(set-cursor-color "#ffff00")
(set-face-attribute 'default nil :height 200)
(set-default-font "Monaco")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hippie-expand

(global-set-key "\M- " 'hippie-expand)

(defun try-expand-flexible-abbrev (old)
  "Try to complete word using flexible matching.

Flexible matching works by taking the search string and then
interspersing it with a regexp for any character. So, if you try
to do a flexible match for `foo' it will match the word
`findOtherOtter' but also `fixTheBoringOrange' and
`ifthisisboringstopreadingnow'.

The argument OLD has to be nil the first call of this function, and t
for subsequent calls (for further possible completions of the same
string).  It returns t if a new completion is found, nil otherwise."
  (if (not old)
      (progn
	(he-init-string (he-lisp-symbol-beg) (point))
	(if (not (he-string-member he-search-string he-tried-table))
	    (setq he-tried-table (cons he-search-string he-tried-table)))
	(setq he-expand-list
	      (and (not (equal he-search-string ""))
		   (he-flexible-abbrev-collect he-search-string)))))
  (while (and he-expand-list
	      (he-string-member (car he-expand-list) he-tried-table))
    (setq he-expand-list (cdr he-expand-list)))
  (if (null he-expand-list)
      (progn
	(if old (he-reset-string))
	())
      (progn
	(he-substitute-string (car he-expand-list))
	(setq he-expand-list (cdr he-expand-list))
	t)))

(defun he-flexible-abbrev-collect (str)
  "Find and collect all words that flex-matches STR.
See docstring for `try-expand-flexible-abbrev' for information
about what flexible matching means in this context."
  (let ((collection nil)
        (regexp (he-flexible-abbrev-create-regexp str)))
    (save-excursion
      (goto-char (point-min))
      (while (search-forward-regexp regexp nil t)
        ;; Is there a better or quicker way than using
        ;; `thing-at-point' here?
        (setq collection (cons (thing-at-point 'symbol) collection))))
    collection))

(defun he-flexible-abbrev-create-regexp (str)
  "Generate regexp for flexible matching of STR.
See docstring for `try-expand-flexible-abbrev' for information
about what flexible matching means in this context."
  (let ((constituent "[A-za-z0-9_]*"))
    (concat (mapconcat (lambda (x) (concat constituent (list x))) str "")
            constituent)))

(setq hippie-expand-try-functions-list
      (cons 'try-expand-flexible-abbrev hippie-expand-try-functions-list))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clojure

(add-hook 'nrepl-interaction-mode-hook
  'nrepl-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)
(setq nrepl-popup-stacktraces nil)
(setq nrepl-popup-stacktraces-in-repl nil)
(add-to-list 'same-window-buffer-names "*nrepl*")
(add-hook 'nrepl-mode-hook 'subword-mode)
(add-hook 'nrepl-mode-hook 'paredit-mode)

;; enable paredit
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(add-hook 'clojure-mode-hook          #'enable-paredit-mode)

(require 'clojure-mode)

(define-clojure-indent
  (defroutes 'defun)
  (GET 2)
  (POST 2)
  (PUT 2)
  (DELETE 2)
  (HEAD 2)
  (ANY 2)
  (context 2))

(add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tramp mode
(setq shell-prompt-pattern "\[leizha@dev\d+ .+\]$")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "e16a771a13a202ee6e276d06098bc77f008b73bbac4d526f160faa2d76c1dd0e" "dd4db38519d2ad7eb9e2f30bc03fba61a7af49a185edfd44e020aa5345e3dca7" "30fe7e72186c728bd7c3e1b8d67bc10b846119c45a0f35c972ed427c45bacc19" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; facebook stuff

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(indent-tabs-mode nil)
 '(c-basic-offset 2))

(defvar master-dir (getenv "ADMIN_SCRIPTS"))
(load-library (concat master-dir "/master.emacs"))

(setq hack-for-hiphop-root "~/www")
(load "/home/engshare/tools/hack-for-hiphop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
