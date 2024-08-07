(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)


(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'evil)
  (package-install 'evil))
(unless (package-installed-p 'org)
  (package-install 'org))

;; Enable Evil mode
(require 'evil)
(evil-mode 1)

;; Org-mode configuration
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/daily.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
         "* %?\n  %i\n  %a")))

(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files (directory-files-recursively "~/org/" "\\.org$"))
 '(package-selected-packages '(org-roam-ui websocket org-roam org-mode evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "/home/adhd/org/roam.d")
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-setup))


(unless (package-installed-p 'websocket)
  (package-install 'websocket))
(use-package websocket
    :after org-roam)

(unless (package-installed-p 'org-roam-ui)
  (package-install 'org-roam-ui))
(use-package org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))


(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))  ;; Enable Python support

