;;; mac-mnemonic-key-mode.el --- provide mac-style key bindings where most shortcuts have two keystrokes: the first one defines a group and the second one defines an action in this group.

;; Copyright (C) 2004-2010  Seiji Zenitani
;; Copyright (C) 2023-2024  Alex Zolotko

;; Author: Seiji Zenitani <zenitani@mac.com>
;; $Id$
;; Keywords: tools, mac, mnemonic
;; Created: 2004-12-27
;; URL(en): https://github.com/azolotko/mac-mnemonic-key-mode

;; Contributors: Tetsuro Kurita, Nozomu Ando, Dave Peck, Alex Zolotko

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This package provides mac-mnemonic-key-mode, a minor mode that provides
;; mac-like key bindings and relevant elisp functions.
;;
;; To use this package, add these lines to your .emacs file:
;;
;;     (require 'mac-mnemonic-key-mode)
;;     (mac-mnemonic-key-mode 1)
;;
;; Note that mac-mnemonic-key-mode works better with redo+.el (but I don't use
;; it...)  In order to set additional key bindings, modify
;; mac-mnemonic-key-mode-map in your .emacs file:
;;
;;     (require 'mac-mnemonic-key-mode)
;;     (define-key mac-mnemonic-key-mode-map [(super l)] 'goto-line)

;;; Code:


(defgroup mac-mnemonic-key-mode nil
  "Mac-style key-binding mode where most shortcuts have two keystrokes."
  :group 'mac
  :version "22.3")
(defconst mac-mnemonic-key-mode-lighter (char-to-string 8984) ; the command mark
  "A lighter string which is displayed in the modeline
when `mac-mnemonic-key-mode' is on.")

(defcustom mac-mnemonic-key-mode-hook nil
  "The hook to run when mac-mnemonic-key-mode is toggled."

  :type 'hook
  :group 'mac-mnemonic-key-mode)

(defcustom mac-mnemonic-key-advanced-setting t
  "If non-nil, `mac-mnemonic-key-mode' activates addional settings:
menu items are added to the File menu and the Edit menu."
  :group 'mac-mnemonic-key-mode
  :type 'boolean)

(defvar mac-mnemonic-key-mode-map
  (let ((map (make-sparse-keymap))
        (block-map (make-sparse-keymap))
        (debug-map (make-sparse-keymap))
        (editor-map (make-sparse-keymap))
        (inspect-map (make-sparse-keymap))
        (jump-map (make-sparse-keymap))
        (kommit-map (make-sparse-keymap))
        (line-map (make-sparse-keymap))
        (navigate-map (make-sparse-keymap))
        (project-map (make-sparse-keymap))
        (refactor-map (make-sparse-keymap))
        (test-map (make-sparse-keymap))
        (utilities-map (make-sparse-keymap))
        (window-map (make-sparse-keymap)))
    (define-key map [(super o)] (lambda()(interactive)(let(last-nonmenu-event)(menu-find-file-existing))))
    (define-key map [(super s)] 'save-buffer)
    (define-key map [(super shift s)] 'mac-mnemonic-key-save-as)
    (define-key map [(super q)] 'save-buffers-kill-emacs)
    (define-key map [(super z)] 'undo)
    (define-key map [(super shift z)] 'undo-fu-only-redo)
    (define-key map [(super x)] 'clipboard-kill-region)
    (define-key map [(super c)] 'clipboard-kill-ring-save)
    (define-key map [(super v)] 'clipboard-yank)
    (define-key map [(super a)] 'mark-whole-buffer)
    (define-key map [(super f)] 'isearch-with-initial-region)
    (define-key map [(super meta f)] 'occur)
    (define-key map [(super g)] 'isearch-repeat-forward)
    (define-key map [(super shift g)] 'isearch-repeat-backward)
    (define-key map [(super m)] 'iconify-frame)
    (define-key map [(super \`)] 'other-frame)
    (define-key map [(super shift n)] 'make-frame-command)
    (define-key map [(super shift w)] 'delete-frame)
    (define-key map [(super \?)] 'info)
    (define-key map [(super /)] 'info)
    (define-key map [(super .)] 'keyboard-quit)
    (define-key map [(super up)] 'beginning-of-buffer)
    (define-key map [(super down)] 'end-of-buffer)
    (define-key map [(super left)] 'beginning-of-line)
    (define-key map [(super right)] 'end-of-line)
    (define-key map [(super \{)] 'previous-buffer)
    (define-key map [(super \})] 'next-buffer)
    (define-key map (kbd "A-<left>") 'backward-word)
    (define-key map (kbd "A-<right>") 'forward-word)
    (define-key map [A-mouse-1] 'browse-url-at-mouse)
    (define-key map [A-S-mouse-1] 'mouse-buffer-menu)
    (define-key map [S-down-mouse-1] 'mac-mnemonic-key-shift-mouse-select)

    (define-key map [(super b)] block-map)
    (define-key map [(super d)] debug-map)

    (define-key map [(super e)] editor-map)
    (define-key editor-map (kbd "f") 'clang-format-buffer)
    (define-key editor-map [(super f)] 'clang-format-buffer)
    (define-key editor-map (kbd "x") 'kill-buffer-and-window)
    (define-key editor-map [(super x)] 'kill-buffer-and-window)

    (define-key map [(super h)] 'iconify-frame)


    (define-key map [(super i)] inspect-map)

    (define-key map [(super j)] jump-map)
    (define-key jump-map (kbd "d") 'xref-find-definitions)
    (define-key jump-map [(super d)] 'xref-find-definitions)
    (define-key jump-map (kbd "j") 'avy-goto-word-or-subword-1)
    (define-key jump-map [(super j)] 'avy-goto-word-or-subword-1)
    (define-key jump-map (kbd "r") 'ff-find-related-file)
    (define-key jump-map [(super r)] 'ff-find-related-file)

    (define-key map [(super k)] kommit-map)
    (define-key kommit-map (kbd "b") 'magit-branch-or-checkout)
    (define-key kommit-map [(super b)] 'magit-branch-or-checkout)
    (define-key kommit-map (kbd "c") 'magit-commit-create)
    (define-key kommit-map [(super c)] 'magit-commit-create)
    (define-key kommit-map (kbd "c") 'magit-commit-create)
    (define-key kommit-map [(super c)] 'magit-commit-create)
    (define-key kommit-map (kbd "l") 'magit-pull)
    (define-key kommit-map [(super l)] 'magit-pull)
    (define-key kommit-map (kbd "p") 'magit-push)
    (define-key kommit-map [(super p)] 'magit-push)
    (define-key kommit-map (kbd "y") 'magit-blame-addition)
    (define-key kommit-map [(super y)] 'magit-blame-addition)

    (define-key map (kbd "S-<escape>") 'delete-window)
    (define-key map (kbd "S-<tab>") 'decrease-left-margin)
    (define-key map (kbd "<backtab>") 'decrease-left-margin)

    (define-key map (kbd "s-[") 'better-jumper-jump-backward)
    (define-key map (kbd "s-]") 'better-jumper-jump-forward)

    (define-key map (kbd "s-<backspace>") 'goto-last-change)

    (define-key map [(super l)] line-map)
    (define-key line-map (kbd "b") 'bookmark-set)
    (define-key line-map [(super b)] 'bookmark-set)
    (define-key line-map (kbd "c") 'comment-line)
    (define-key line-map [(super c)] 'comment-line)
    (define-key line-map (kbd "d") 'duplicate-line)
    (define-key line-map [(super d)] 'duplicate-line)
    (define-key line-map (kbd "g") 'goto-line)
    (define-key line-map [(super g)] 'goto-line)
    (define-key line-map (kbd "i") 'lisp-indent-line)
    (define-key line-map [(super i)] 'lisp-indent-line)
    (define-key line-map (kbd "j") 'join-line)
    (define-key line-map [(super j)] 'join-line)
    (define-key line-map (kbd "n") 'doom/toggle-line-numbers)
    (define-key line-map [(super n)] 'doom/toggle-line-numbers)
    (define-key line-map (kbd "r") 'reverse-region)
    (define-key line-map [(super r)] 'reverse-region)
    (define-key line-map (kbd "s") 'sort-lines)
    (define-key line-map [(super s)] 'sort-lines)
    (define-key line-map (kbd "x") 'kill-whole-line)
    (define-key line-map [(super x)] 'kill-whole-line)

    (define-key map [(super n)] navigate-map)
    (define-key navigate-map (kbd "f") '+vertico/project-search)
    (define-key navigate-map [(super f)] '+vertico/project-search)
    (define-key navigate-map (kbd "o") 'projectile-find-file)
    (define-key navigate-map [(super o)] 'projectile-find-file)
    (define-key navigate-map (kbd "r") 'consult-recent-file) ; 'projectile-recentf)
    (define-key navigate-map [(super r)] 'consult-recent-file) ; 'projectile-recentf)
    (define-key navigate-map (kbd "u") 'xref-find-references)
    (define-key navigate-map [(super u)] 'xref-find-references)

    (define-key map [(super p)] project-map)
    (define-key project-map (kbd "o") (lambda()(interactive)(call-interactively 'dired 'projectile-add-known-project)))
    (define-key project-map [(super o)] (lambda()(interactive)(call-interactively 'dired 'projectile-add-known-project)))
    (define-key project-map (kbd "p") 'projectile-switch-project)
    (define-key project-map [(super p)] 'projectile-switch-project)
    (define-key project-map (kbd "r") 'projectile-replace)
    (define-key project-map [(super r)] 'projectile-replace)

    (define-key map [(super r)] refactor-map)
    (define-key map [(super t)] test-map)

    (define-key map [(super u)] utilities-map)
    (define-key utilities-map (kbd "a") 'execute-extended-command)
    (define-key utilities-map [(super a)] 'execute-extended-command)

    (define-key map [(super w)] window-map)
    (define-key window-map (kbd "p") 'treemacs-select-window)
    (define-key window-map [(super p)] 'treemacs-select-window)
    (define-key window-map (kbd "t") 'projectile-run-vterm)
    (define-key window-map [(super t)] 'projectile-run-vterm)
    (define-key window-map (kbd "v") 'magit)
    (define-key window-map [(super v)] 'magit)
    (define-key window-map (kbd "x") 'delete-window)
    (define-key window-map [(super x)] 'delete-window)
    (define-key window-map (kbd "w") 'ace-window)
    (define-key window-map [(super w)] 'ace-window)

    map)
  "Keymap for `mac-mnemonic-key-mode'.")

;; mode-line menu
(define-key-after mode-line-mode-menu [mac-mnemonic-key-mode]
  `(menu-item ,(purecopy
                (concat "Mac Mnemonic Key (" mac-mnemonic-key-mode-lighter ")"))
              mac-mnemonic-key-mode :button (:toggle . mac-mnemonic-key-mode))
  'highlight-changes-mode)

;;;###autoload
(define-minor-mode mac-mnemonic-key-mode
  "Toggle Mac Mnemonic Key mode.
With arg, turn Mac Mnemonic Key mode on if arg is positive.
When Mac Mnemonic Key mode is enabled, mac-style key bindings are provided."
  :global t
  :group 'mac-mnemonic-key-mode
  :lighter (" " mac-mnemonic-key-mode-lighter)
  :keymap 'mac-mnemonic-key-mode-map
  (if mac-mnemonic-key-mode
      (progn
        (setq mac-command-modifier 'super
              mac-option-modifier 'meta)

        (define-key minibuffer-local-map [(super z)] 'undo)
        (define-key minibuffer-local-map [(super v)] 'clipboard-yank)
        (define-key minibuffer-local-map [(super a)] 'mark-whole-buffer)
        (define-key minibuffer-local-map [(super x)] 'clipboard-kill-region)
        (define-key minibuffer-local-map [(super left)] 'beginning-of-line)
        (define-key minibuffer-local-map [(super right)] 'end-of-line)
        (define-key minibuffer-local-map (kbd "A-<left>") 'backward-word)
        (define-key minibuffer-local-map (kbd "A-<right>") 'forward-word)
      )
    (progn)))

(defun isearch-with-initial-region ()
  "Start `isearch` with the current region (if active)."
  (interactive)
  (deactivate-mark)
  (if (use-region-p)
      (progn
        (isearch-mode t nil nil nil)
        (isearch-yank-string (buffer-substring-no-properties (mark) (point))))
    (isearch-forward)))

;; save as.. dialog (shift + command + S)
(defun mac-mnemonic-key-save-as (filename &optional wildcards)
  "Write current buffer to another file using standard file open dialog."
  (interactive
   (let (last-nonmenu-event)
     (find-file-read-args "Write file: " nil)))
   (write-file filename))

;; shift+click
;; Contributed by Dave Peck

(defun mac-mnemonic-key-shift-mouse-select (event)
  "Set the mark and then move point to the position clicked on with
the mouse.  This should be bound to a mouse click event type."
  (interactive "e")
  (mouse-minibuffer-check event)
  (if mark-active (exchange-point-and-mark))
  (set-mark-command nil)
  ;; Use event-end in case called from mouse-drag-region.
  ;; If EVENT is a click, event-end and event-start give same value.
  (posn-set-point (event-end event)))

(provide 'mac-mnemonic-key-mode)

;;; mac-mnemonic-key-mode.el ends here.
