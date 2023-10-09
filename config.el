;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Li Yang"
      user-mail-address "wood9366@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "Sarasa Mono SC" :size 14)
      doom-variable-pitch-font (font-spec :family "Sarasa Fixed SC" :size 14))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(defadvice! projectile-files-via-ext-command-around (fn root command)
  :around '(projectile-files-via-ext-command)
  (when command
    (let ((cmd command))
      (let ((unity-ver-file (cond ((locate-file "ProjectVersion.txt"
                                                `(,(concat (file-name-as-directory root)
                                                           "ProjectSettings"))))
                                  ((locate-file "ProjectVersion.txt"
                                                `(,(concat (file-name-as-directory root)
                                                           (file-name-as-directory "unity")
                                                           "ProjectSettings")))))))
        (if unity-ver-file
            (setq cmd (concat cmd " -e sh -e cs -e txt -e md -e txt -e json -e xml -e bytes -e lua -e shader -e cginc"))))
      (message "ext command run at root %s with command %s" root cmd)
      (funcall fn root cmd))))

(add-to-list 'auto-mode-alist '("cginc\\'" . shader-mode))
(add-to-list 'auto-mode-alist '("glslinc\\'" . shader-mode))

(use-package! lsp-mode
  :config
  (setq lsp-csharp-server-path "/usr/local/bin/omnisharp")
  (cl-loop for it in '("[/\\\\]Library\\'"
                       "[/\\\\]Temp\\'"
                       "[/\\\\]Builds\\'"
                       "[/\\\\]DownloadAssets\\'"
                       "[/\\\\]Logs\\'"
                       "[/\\\\]obj\\'"
                       "[/\\\\]_Android\\'"
                       "[/\\\\]_iOS\\'")
           do (add-to-list 'lsp-file-watch-ignored-directories it))

  (cl-loop for it in '("[/\\\\].+\\.csproj\\'"
                       "[/\\\\].+\\.sln\\'"
                       "[/\\\\].+\\.meta\\'")
           do (add-to-list 'lsp-file-watch-ignored-files it))
  (setq lsp-file-watch-threshold 2000))

(defun wood9366/project-try-projectile (dir)
  (let ((probe (locate-dominating-file dir ".projectile")))
    (when probe (cons 'transient probe))))

(add-hook 'project-find-functions #'wood9366/project-try-projectile 'append)

(add-hook 'c++-mode-hook
          (lambda()
            (setq-local flycheck-disabled-checkers '(c/c++-clang c/c++-gcc c/c++-cppcheck))))


;; org reveal
(after! org-re-reveal
  (setq org-re-reveal-root (concat "file://" (expand-file-name "~/packs/reveal.js"))
        org-re-reveal-revealjs-version "4"))

;; lua
(add-to-list 'auto-mode-alist '("lua\\.txt\\'" . lua-mode))
(add-to-list 'auto-mode-alist '("lua\\.bytes\\'" . lua-mode))

(after! lua-mode
  (setq lua-indent-level 4))

(add-hook! lua-mode
  (add-hook! 'xref-backend-functions :local #'etags--xref-backend))

;; perl
(defalias 'perl-mode 'cperl-mode)

(add-to-list 'auto-mode-alist
             '("Construct\\'" . perl-mode))

(after! cperl-mode
  (setq
   cperl-close-paren-offset -4
   cperl-continued-statement-offset 4
   cperl-indent-level 4
   cperl-indent-parens-as-block t
   cperl-tabs-always-indent t))

(defun markdown-preview-filter (buffer)
  (princ (with-current-buffer buffer
    (format "<!DOCTYPE html><html><title>Impatient Markdown</title><xmp theme=\"united\" style=\"display:none;\"> %s  </xmp><script src=\"http://strapdownjs.com/v/0.2/strapdown.js\"></script></html>" (buffer-substring-no-properties (point-min) (point-max))))
  (current-buffer)))

(defun markdown-preview-start ()
  "start preview markdown in browser"
  (interactive)
  (if (eq major-mode 'markdown-mode)
      (progn
        (unless (httpd-running-p)
          (httpd-start))
        (impatient-mode)
        (imp-set-user-filter #'markdown-preview-filter)
        (browse-url (format "http://localhost:8080/imp/live/%s/" (buffer-name))))
    (message "current buffer isn't markdown mode")))

(defun markdown-preview-stop()
  "stop preview markdown in browser"
  (interactive)
  (if (eq major-mode 'markdown-mode)
      (progn
        (if (httpd-running-p)
            (httpd-stop))
        (impatient-mode 0)
        (imp-remove-user-filter))))
