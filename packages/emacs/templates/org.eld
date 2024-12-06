org-mode

(src "#+begin_src " q n r n "#+end_src")
(emacs-lisp "#+begin_src emacs-lisp" n r n "#+end_src"
            :post (org-edit-src-code))
