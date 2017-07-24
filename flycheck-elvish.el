;;; flycheck-elvish.el --- Defines a flycheck syntax checker for elvish

;; Copyright (c) 2017 Adam Schwalm

;; Author: Adam Schwalm <adamschwalm@gmail.com>
;; Version: 0.1.0
;; URL: https://github.com/ALSchwalm/flycheck-elvish
;; Package-Requires: ((flycheck "0.20"))

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Adds Elvish support to flycheck

;;; Code:

(require 'flycheck)

(flycheck-def-args-var flycheck-elvish-args elvish)

(defun flycheck-elvish-pos-in-buffer (buffer char)
  (with-current-buffer buffer
    (save-excursion
      (goto-char (+ 2 char))
      (cons (line-number-at-pos (point)) (list (current-column))))))

(defun flycheck-elvish-convert-errors (errors &optional offset)
  "The elvish interpreter reports errors by the character position
in the file, not line-column. This converts the matched values to
the real ones."
  (seq-do (lambda (err)
            (let* ((char (flycheck-error-column err))
                   (buff (current-buffer))
                   (pos (flycheck-elvish-pos-in-buffer buff char)))
             (setf (flycheck-error-line err) (car pos))
             (setf (flycheck-error-column err) (cadr pos))))
          errors)
  errors)

(flycheck-define-checker elvish
  "A syntax checker for the elvish programming language.
See https://elvish.io/"
  :command ("elvish" "-compileonly"
            (eval flycheck-elvish-args)
            source-inplace)
  :error-patterns
  ((error line-start (or "compilation" "parse") " error: "
          column "-" line " in " (file-name) ": " (message))

   ;; For now, only show the first error when there are multiple in
   ;; one output
   (error line-start "multiple parse errors in " (file-name) ": "
          column "-" line ":" (message (minimal-match (one-or-more anything)) ";")))
  :error-filter
  (lambda (errors)
    (flycheck-elvish-convert-errors errors))
  :modes (elvish-mode))

(add-to-list 'flycheck-checkers 'elvish)

(provide 'flycheck-elvish)
;;; flycheck-elvish.el ends here
