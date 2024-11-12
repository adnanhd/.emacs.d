(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(package-initialize)


(setq package-check-signature nil)

(setq user-full-name "Adnan Harun Dogan")
(setq user-email-adress "adnanharundogan@gmail.com")


(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(unless (file-directory-p "~/.emacs.d/backups")
  (make-directory "~/.emacs.d/backups" t))

;; Enable versioned backups and configure the number of versions
(setq version-control t)
(setq kept-new-versions 10)
(setq kept-old-versions 2)
(setq delete-old-versions t)

;; Auto-save configuration
(setq auto-save-default t)
(setq auto-save-timeout 20)
(setq auto-save-interval 200)
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/auto-saves/" t)))

;; Create a directory for auto-save files if it doesn't exist
(unless (file-directory-p "~/.emacs.d/auto-saves")
  (make-directory "~/.emacs.d/auto-saves" t))

(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
    (package-install 'use-package))

(require 'use-package)


;; Install and configure Org mode
(unless (package-installed-p 'org)
  (package-install 'org))

(use-package org
  :ensure t
  :pin gnu
  :config
  (setq org-agenda-files
	'("/home/adhd/org/agenda/diary.org"
          "/home/adhd/org/agenda/diary.org"
          "/home/adhd/org/agenda/faces.org"
          "/home/adhd/org/agenda/ideal.org"
          "/home/adhd/org/agenda/maybe.org"
          "/home/adhd/org/agenda/money.org"
          "/home/adhd/org/agenda/notes.org"
          "/home/adhd/org/agenda/plans.org"
          "/home/adhd/org/agenda/projects.org"
          "/home/adhd/org/agenda/resources.org"))
;	(directory-files-recursively "~/org/resources/" "\\.org$")
  )

(add-to-list 'load-path "~/git/git-org-mode/lisp")
(add-to-list 'load-path "~/git/git-org-mode/contrib/lisp")
(require 'org)

(setq evil-want-C-i-jump nil)

;; Install and configure Evil mode
(unless (package-installed-p 'evil)
  (package-install 'evil))

(use-package evil
  :ensure t
  :config
  (evil-mode 1))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(evil org-contrib org-drill org-habit org-journal org-ref org-roam-ui
	  org-super-agenda use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; load contrib library
;(add-to-list 'load-path
;             (expand-file-name "~/git/org-mode/lisp"
;                              (file-name-directory
;                               org-find-library-dir "org")))

(use-package org-journal
  :ensure t
  :defer t
  :init
  ;; Change default prefix key; needs to be set before loading org-journal
  (setq org-journal-prefix-key "C-c j ")
  :config
  (setq org-journal-dir "~/org/journal/"
        org-journal-date-format "%A, %d %B %Y"))

(require 'org-habit)
(add-to-list 'org-modules 'org-habit)

(setq org-todo-repeat-to-state "NEXT")

;; I prefer to log TODO creation also
(setq org-treat-insert-todo-heading-as-state-change t)

;; log into LOGBOOK drawer
(setq org-log-into-drawer t)
(setq org-log-done 'time)


(setq org-habit-graph-column 60)  ; Adjusts the column where the habit graph appears in the agenda
(setq org-habit-preceding-days 21) ; Number of days shown before today in the habit graph
(setq org-habit-following-days 7)  ; Number of days shown after today in the habit graph


(use-package org-drill
  :ensure t
  :after org
  :config
  ;; set `org-drill-scope` to only include Org-roam files under "~/org/roam.d/"
  (setq org-drill-scope (directory-files-recursively "~/org/roam.d/" "\\.org$"))

  ;; Optional: Additional drill settings for customization
  (setq org-drill-window-setup 'other-frame)
  (setq org-drill-add-random-noise-to-intervals-p t)
  (setq org-drill-hint-separator "||")
  (setq org-dill-left-cloze-delimiter "[")
  (setq org-dill-right-cloze-delimiter "]")
  (setq org-drill-learn-fraction 0.25) ; adjust learning rate
)

(defun org-drill-present-default-answer (session reschedule-fn)
  "Present a default answer.

SESSION is the current session.
RESCHEDULE-FN is the function to reschedule."
  (prog1 (cond
	  ((oref session drill-answer)
	   (org-drill-with-replaced-entry-text
	   (format "\nAnswer:\n\n %s\n" (oref session drill-answer))
	   (funcall reschedule-fn session)
	   ))
	  (t
	   (org-drill-hide-subheadings-if 'org-drill-entry-p)
	   (org-drill-unhide-clozed-text)
	   (org-drill--show-latex-fragments)
	   (ignore-errors
	     (org-display-inline-images t))
	   (org-cycle-hide-drawers 'all)
	   (org-remove-latex-fragment-image-overlays)
	   (save-excursion
	     (org-mark-subtree)
	     (let ((beg (region-beginning))
		   (end (region-end)))
	       (if (window-system)
		   (org--latex-preview-region beg end))
	       )
	     (deactivate-mark))
	   (org-drill-with-hidden-cloze-hints
	    (funcall reschedule-fn session))))))


;; manage citations
(require 'ol-bibtex)

;; export citations
(require 'ox-bibtex)
(setq org-bibtex-file "~/org/agenda/resources.org")

;; Set global bibliography
(setq org-cite-global-bibliography (directory-files-recursively "~/org/resources/" "\\.bib$"))
;; (setq org-cite-export-processors
;;  '((md . (csl "~/org/contrib/csl-styles/chicago-fullnote-bibliography.csl"))   ; Footnote reliant
;;    (latex biblatex)                                   ; For humanities
;;    (odt . (csl "~/org/contrib/csl-styles/chicago-fullnote-bibliography.csl"))  ; Footnote reliant
;;    (html . (csl "~/org/contrib/csl-styles/apa7.csl"))))      ; Fallback


;; Configure Org-cite with oc-csl
(use-package oc-csl
  :ensure nil  ; oc-csl is part of Org-mode
  :after org
  :config
  ;; Define the directory where CSL styles are stored
  (setq org-cite-csl-styles-dir "~/org/contrib/csl-styles/")
  
  ;; Set a default CSL style
  (setq org-cite-csl-style "ieee")  ; Replace "ieee" with your preferred default style
  
  ;; Specify citation processors for different backends
  (setq org-cite-export-processors '((latex biblatex) (t csl))))

(require 'org-ref)

;; see org-ref for use of these variables
(setq org-ref-bibliography-notes '("~/org/agenda/resources.org" "~/org/agenda/literature.org" "~/org/agenda/new_note.org")
      org-ref-default-bibliography '("~/org/contrib/bibtex/literature.bib")
      org-ref-pdf-directory "~/org/contrib/ref/pdf/"
      org-ref-bibliography-style "apa")


;; Optional: Customize org-ref behavior further if needed
;; Example: Ensure better handling of missing references
(setq org-ref-show-broken-links t)

;; Wrap Lines
(global-visual-line-mode t)

(use-package org-contrib
  :ensure t
  :after org)

; ;; Set default directories for exports
; (defun my-org-export-output-file-name (output-file backend)
;   "Set the export output path prefix based on BACKEND type."
;   (let* ((base-name (file-name-nondirectory output-file))
;          (html-dir "~/org/export/html/")
;          (latex-dir "~/org/export/latex/"))
;     (cond
;      ;; For HTML export, use the HTML directory
;      ((eq backend 'html)
;       (concat html-dir base-name))
;      ;; For LaTeX and PDF export, use the LaTeX directory
;      ((or (eq backend 'latex) (eq backend 'pdf))
;       (concat latex-dir base-name))
;      ;; Default case: return the original output file name
;      (t
;       output-file))))
; 
; (defun my-org-set-export-path-prefix ()
;   "Set custom export paths based on backend using prefix."
;   (setq org-export-output-file-name-function 'my-org-export-output-file-name))
; 
; ;; Add this function to the org-export-before-processing-hook
; (add-hook 'org-export-before-processing-hook 'my-org-set-export-path-prefix)


(require 'org-depend)
(setq org-enforce-todo-dependencies t)

(require 'org-protocol)

(setq org-link-abbrev-alist
        ;; fundamental abbreviations
      '(("drive" . "https://drive.google.com/open?id=")
        ("meet" . "https://meet.google.com/")
        ("zoom" . "https://zoom.us/j/")
        ("dropbox" . "https://www.dropbox.com/")
        ("arxiv" . "https://arxiv.org/abs/")
        ("wiki" . "https://en.wikipedia.org/wiki/")
        ("doi" . "https://doi.org/")
        ("github" . "https://github.com/")
        ("gitlab" . "https://gitlab.com/")
        ;; Additional abbreviations
        ("slack" . "https://slack.com/app_redirect?channel=")
        ("notion" . "https://www.notion.so/")
        ("linkedin" . "https://www.linkedin.com/in/")
        ("trello" . "https://trello.com/b/")
        ("twitter" . "https://x.com/")
        ("youtube" . "https://www.youtube.com/watch?v=")
        ("gcal" . "https://calendar.google.com/calendar/r/eventedit?text=")
        ("gdocs" . "https://docs.google.com/document/d/")
        ("gsheets" . "https://docs.google.com/spreadsheets/d/")
        ("gmaps" . "https://www.google.com/maps/place/")))

(setq org-refile-targets
      '(("~/org/agenda/daily.org" :maxlevel . 2)
        ("~/org/agenda/maybe.org" :maxlevel . 1)
        ("~/org/agenda/money.org" :maxlevel . 2)
        ("~/org/agenda/ideal.org" :level . 1)
        ("~/org/agenda/notes.org" :maxlevel . 2)
        ("~/org/agenda/resources.org" :maxlevel . 3)
        ("~/org/agenda/projects.org" :maxlevel . 2)))

(use-package websocket
  :after org-roam)

;; Org-mode configuration
(setq org-capture-templates
      '(("t" "To-Do Item" entry (file+headline "~/org/agenda/daily.org" "Inbox")
         "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n  %i\n  %a")

        ;; Journal Entry
        ("j" "Journal" entry (file+datetree "~/org/agenda/diary.org")
         "* %<%H:%M>\t %?\n" :clock-in t :clock-resume t :empty-lines 0)

        ;; Bug or Feature Request
        ("b" "Bug/Feature Request" entry (file+headline "~/org/agenda/notes.org" "Code Feedback")
         "* %^{Description} :bug:feature:\n:PROPERTIES:\n:CREATED: %U\n:FILE: %^{File/Repo URL}\n:LINE: %^{Line Number}\n:END:\n%?")

        ;; Website Capture using org-protocol
        ("w" "Web site" entry (file "~/org/notes.org")
         "* %(org-protocol-capture-title)\n:PROPERTIES:\n:CREATED: %U\n:URL: %:link\n:END:\n%i%?")

        ;; Org-roam Zettel
        ("r" "Org-roam Zettel" entry (file+headline "~/org/agenda/notes.org" "Org-roam Zettels")
         "* %^{Zettel Title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?")

        ;; BibTeX Resource Capture
        ("B" "BibTeX Entry" entry (file "~/org/agenda/daily.org")
         "** %^{Title}\n %?\n" 
         :immediate-finish t
         :hook org-bibtex-yank)

        ;; Meeting Notes under Project Level 2 Headings
        ("m" "Meeting" entry (file+olp+datetree "~/org/agenda/projects.org" "Research Projects")
         "*** %<%Y-%m-%d>\n<<meeting notes>>\n%?\n" :empty-lines 1)))


;; Custom TODO keywords
(setq org-todo-keywords
      '((sequence "MAYBE(m)" "TODO(t)" "NEXT(n)" "DOING(o)" "WAIT(w@)" "HOLD(h@/!)" "|" "DONE(d!)" "DROP(c@)")
        (sequence "EVENT(e)" "CONF(f)" "|" "HELD(a)" "SKIP(u@)" "VOID(X@)")))

;; Faces for TODO keywords
(setq org-todo-keyword-faces
      '(("MAYBE" . "white")
	("TODO" . org-warning)
        ("NEXT" . "yellow")
        ("DOING" . "orange")
	("HOLD" . "gray")
        ("WAIT" . "gray")
        ("DONE" . "green")
        ("DROP" . "gray")

        ("EVENT" . "light blue")
        ("CONF" . "yellow")
        ("HELD" . "green")
        ("SKIP" . "red")
        ("VOID" . "gray")))

;; Agenda views
(setq org-agenda-custom-commands
      '(("n" "Next Action List"
         (todo "NEXT" (org-agenda-sorting-strategy '(priority-up))))
        ("t" "Tasks"
         ((todo "TODO")
          (todo "NEXT")
          (todo "DOING")
          (todo "WAITING")
          (todo "DONE")
          (todo "CANCALLED")))
        ("p" "Projects"
         ((todo "PROJECT")
          (todo "ACTIVE")
          (todo "ON-HOLD")
          (todo "COMPLETED")
          (todo "DROPPED")))))


(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

;; Add Python to Org Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (latex . t)))

;; Set Python executable if needed
(setq org-babel-python-command "python3")

(require 'ox-publish)
(setq org-publish-project-alist
  '(("org-roam-notes-html"
     :auto-sitemap t
     :sitemap-title "Sitemap"
     :sitemap-filename "sitemap.org"
     :auto-index t
     :base-directory "~/org/roam.d/"
     :base-extension "org"
     :publishing-directory "~/public_html"
     :publishing-function org-html-publish-to-html
     :recursive t
     :headline-levels 4
     :auto-preamble t)
  ("org-roam-static-html"
     :base-directory "~/org/roam.d/"
     :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
     :publishing-directory "~/public_html"
     :publishing-function org-publish-attachment
     :recursive t
     :headline-levels 4
     :auto-preamble t)
  ("org-roam"
   :components ("org-roam-notes-html" "org-roam-static-html"))))


;; Agenda enhancement
(setq org-priority-highest ?A)  ;; Highest priority is A
(setq org-priority-lowest ?E)   ;; Lowest priority is E
(setq org-priority-default ?C)  ;; Default priority is C (or any priority you prefer as default)

;; Agenda View "d"
(defun air-org-skip-subtree-if-priority (priority)
  "Skip an agenda subtree if it has a priority of PRIORITY.

  PRIORITY may be one of the characters ?A, ?B, or ?C."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (pri-value (* 1000 (- org-lowest-priority priority)))
        (pri-current (org-get-priority (thing-at-point 'line t))))
    (if (= pri-value pri-current)
        subtree-end
      nil)))

(setq org-agenda-skip-deadline-if-done t)
(setq org-use-tag-inheritance t)
(setq org-global-properties
      '(("Effort_ALL" . "0:10 0:30 1:00 2:00 4:00 8:00")))

;; Define tags for Org-mode in init.el
(setq org-tag-alist '(
    ;; Resource Tags
    (:startgroup)
    ("paper" . ?P) ("article" . ?I) ("journal" . ?J) ("blog" . ?B) ;; blog or zettel
    ("forum" . ?F) ("repository" . ?R) ("book" . ?K) ("video" . ?V) ;; video or audio
    ("podcast" . ?J) ("presentation" . ?T) ("note" . ?Z)
    (:endgroup)

    ;; Actional Tags
    (:startgroup)
    ("emailing" . ?m) ("planning" . ?p) ("reading" . ?r) ("writing" . ?w)
    ("watching" . ?t) ("coding" . ?c) ("presenting" . ?g) ("documenting" . ?d)
    ("meeting" . ?m) ("debugging" . ?b) ("researching" . ?s) ("analyzing" . ?z)
    ("paying" . ?y)
    (:endgroup)

    ;; Temporal Tags
    (:startgroup)
    ("morning" . ?o) ("afternoon" . ?a) ("evening" . ?e) ("night" . ?i)
    ("weekend" . ?E) ("weekday" . ?A) ("work_hours" . ?O) ("off_hours" . ?U)
    (:endgroup)

    ;; Locational Tags
    (:startgroup)
    ("@computer" . ?C) ("@office" . ?o) ("@home" . ?h) ("@mobile" . ?M)
    ("@gym" . ?G) ("@pool" . ?L) ("@stadium" . ?S) ("@cafe" . ?f)
    ("@commute" . ?t) ("device_free" . ?x) ("online" . ?l) ("offline" . ?n)
    (:endgroup)

    ; ;; Periodal Tags
    ; ("@2024") ("@2024spring") ("@2024summer") ("@2024fall") ("@2024winter")
    ; ("@2025") ("@2025spring") ("@2025summer") ("@2025fall") ("@2025winter")
    ; ("@2026") ("@2026spring") ("@2026summer") ("@2026fall") ("@2026winter")

    ;; Pace Tags
    (:startgroup)
    ("distraction_free" . ?D) ("multitaskable" . ?M)
    (:endgroup)

    ("drill" . ?q) ("habit" . ?b) ("corpus")
))


(setq org-agenda-custom-commands
      '(("n" "Next Action List"
         (todo "NEXT" (org-agenda-sorting-strategy '(priority-up))))
        ;; Daily Agenda & TODOs
        ("d" "Daily agenda and all TODOs"

         ;; Display items with priority A
         ((tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "High-priority unfinished tasks:")))

          ;; View 7 days in the calendar view
          (agenda "" ((org-agenda-span 7)))

          ;; Display items with priority B (really it is view all items minus A & C)
          (alltodo ""
                   ((org-agenda-skip-function '(or (air-org-skip-subtree-if-priority ?A)
                                                   (air-org-skip-subtree-if-priority ?C)
                                                   (org-agenda-skip-if nil '(scheduled deadline))))
                    (org-agenda-overriding-header "ALL normal priority tasks:")))

          ;; Display items with pirority C
          (tags "PRIORITY=\"C\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Low-priority Unfinished tasks:")))
          )

         ;; Don't compress things (change to suite your tastes)
         ((org-agenda-compact-blocks nil)))
        ))          


;; Org-roam configuration
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "/home/adhd/org/roam.d")
  :bind (("C-c n b" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 ("C-c n c" . org-roam-capture))
  :config
  (org-roam-setup))

;; Org-Roam Template Configuration
(setq org-roam-capture-templates
      '(("p" "Philosopher" plain "%?"
	 :target (file+head "reasoning/philosophers/${slug}.org"
			    "#+TITLE: ${title}\n#+ROAM_TAGS: philosophy, philosopher\n")
         :unnarrowed t)
	("m" "Philosophical Movement" plain "%?"
	 :target (file+head "reasoning/movements/${slug}.org"
			    "#+TITLE: ${title}\n#+ROAM_TAGS: philosophy, movement\n")
         :unnarrowed t)
	("s" "Philosophical Study" plain "%?"
	 :target (file+head "reasoning/studies/${slug}.org"
			    "#+TITLE: ${title}\n#+ROAM_TAGS: philosophy, study\n")
         :unnarrowed t)
	("g" "General Culture" plain "%?"
	 :target (file+head "${slug}.org"
			    "#+TITLE: ${title}\n#+ROAM_TAGS: ${roam_tags}\n")
         :unnarrowed t)
	))

(use-package org-roam-ui
  :after org-roam ;; or :after org
  ;; normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;; a hookable mode anymore, you're advised to pick something yourself
  ;; if you don't care about startup time, use
  ;;  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))


; (use-package org-roam-ql
;   :ensure t 
;   ;; If using quelpa
;   ; :quelpa (org-roam-ql :fetcher github :repo "ahmed-shariff/org-roam-ql"
;   ;                      :files (:defaults (:exclude "org-roam-ql-ql.el")))
;   ;; Simple configuration
;   :after (org-roam)
;   :bind ((:map org-roam-mode-map
;                ;; Have org-roam-ql's transient available in org-roam-mode buffers
;                ("v" . org-roam-ql-buffer-dispatch)
;                :map minibuffer-mode-map
;                ;; Be able to add titles in queries while in minibuffer.
;                ;; This is similar to `org-roam-node-insert', but adds
;                ;; only title as a string.
;                ("C-c n i" . org-roam-ql-insert-node-title))))
