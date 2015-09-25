;;; spaceline-segments.el --- Segments for spaceline

;; Copyright (C) 2015 TheBB
;;
;; Author: Eivind Fonn <evfonn@gmail.com>
;; Keywords: modeline powerline
;; Created: 21 Sep 2015
;; Version: 0.1

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
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

;;; Code:

(require 'spaceline)

;; Stock segments - no dependencies (except evil)
;; ==============================================

(defvar spaceline-minor-modes-separator "|")
(spaceline-define-segment minor-modes
  (progn
   (mapcar
    (lambda (m)
      (propertize m
                  'mouse-face 'mode-line-highlight
                  'help-echo (concat "Minor mode\n"
                                     "mouse-1: Display minor mode menu\n"
                                     "mouse-2: Show help for minor mode\n"
                                     "mouse-3: Toggle minor mode")
                  'local-map (let ((map (make-sparse-keymap)))
                               (define-key map
                                 [mode-line down-mouse-1]
                                 (powerline-mouse 'minor 'menu m))
                               (define-key map
                                 [mode-line down-mouse-2]
                                 (powerline-mouse 'minor 'help m))
                               (define-key map
                                 [mode-line down-mouse-3]
                                 (powerline-mouse 'minor 'menu m))
                               (define-key map
                                 [header-line down-mouse-3]
                                 (powerline-mouse 'minor 'menu m))
                               map)))
   (split-string (format-mode-line minor-mode-alist))))
  :separator spaceline-minor-modes-separator)

(spaceline-define-segment evil-state
  (s-trim (evil-state-property evil-state :tag t))
  :when (bound-and-true-p evil-local-mode))

(spaceline-define-segment buffer-modified "%*")

(spaceline-define-segment buffer-size
  (powerline-buffer-size))

(spaceline-define-segment buffer-id
  (powerline-buffer-id))

(spaceline-define-segment remote-host
  (concat "@" (file-remote-p default-directory 'host))
  :when (file-remote-p default-directory 'host))

(spaceline-define-segment major-mode
  (powerline-major-mode))

(spaceline-define-segment process
  (powerline-raw mode-line-process)
  :when (spaceline--mode-line-nonempty mode-line-process))

(spaceline-define-segment version-control
  (s-trim (powerline-vc))
  :when (powerline-vc))

(spaceline-define-segment buffer-encoding
  (format "%s" buffer-file-coding-system))

(spaceline-define-segment buffer-encoding-abbrev
  (let ((buf-coding (format "%s" buffer-file-coding-system)))
    (if (string-match "\\(dos\\|unix\\|mac\\)" buf-coding)
        (match-string 1 buf-coding)
      buf-coding)))

(spaceline-define-segment point-position
  (format "%d" (point))
  :when spacemacs-mode-line-display-point-p)

(spaceline-define-segment line "%l")
(spaceline-define-segment column "%l")
(spaceline-define-segment line-column "%l:%2c")
(spaceline-define-segment buffer-position "%p")

(defvar spaceline-global-excludes nil)
(defun spaceline--global ()
  (-difference global-mode-string spaceline-global-excludes))
(spaceline-define-segment global
  (powerline-raw (spaceline--global))
  :when (spaceline--mode-line-nonempty (spaceline--global)))

(defun spaceline--column-number-at-pos (pos)
  "Analog to line-number-at-pos."
  (save-excursion (goto-char pos) (current-column)))
(spaceline-define-segment selection-info
  (let* ((lines (count-lines (region-beginning) (min (1+ (region-end)) (point-max))))
         (chars (- (1+ (region-end)) (region-beginning)))
         (cols (1+ (abs (- (spaceline--column-number-at-pos (region-end))
                           (spaceline--column-number-at-pos (region-beginning))))))
         (evil (and (bound-and-true-p evil-state) (eq 'visual evil-state)))
         (rect (or (bound-and-true-p rectangle-mark-mode)
                   (and evil (eq 'block evil-visual-selection))))
         (multi-line (or (> lines 1) (and evil (eq 'line evil-visual-selection)))))
    (cond
     (rect (format "%d×%d block" lines (if evil cols (1- cols))))
     (multi-line (format "%d lines" lines))
     (t (format "%d chars" (if evil chars (1- chars))))))
  :when (or mark-active
            (and (bound-and-true-p evil-local-mode)
                 (eq 'visual evil-state))))

(spaceline-define-segment hud
  (powerline-hud evil-state-face default-face)
  :tight t
  :when (string-match "\%" (format-mode-line "%p")))


;; Segments requiring optional dependencies
;; ========================================

(spaceline-define-segment anzu
  (anzu--update-mode-line)
  :when (and active (bound-and-true-p anzu--state)))

(spaceline-define-segment erc-track
  (mapcar (lambda (b) (buffer-name (car b)))
          erc-modified-channels-alist)
  :when (bound-and-true-p erc-track-mode))

(spaceline-define-segment battery
  (powerline-raw (s-trim (fancy-battery-default-mode-line))
                 (fancy-battery-powerline-face))
  :when (bound-and-true-p fancy-battery-mode))

(spaceline-define-segment org-clock
  (substring-no-properties (funcall spacemacs-mode-line-org-clock-format-function))
  :when (and spacemacs-mode-line-org-clock-current-taskp
             (fboundp 'org-clocking-p)
             (org-clocking-p)))

(spaceline-define-segment org-pomodoro
  (nth 1 org-pomodoro-mode-line)
  :when (and (fboundp 'org-pomodoro-active-p)
             (org-pomodoro-active-p)))

(spaceline-define-segment nyan-cat
  (powerline-raw (nyan-create) default-face)
  :when (bound-and-true-p nyan-mode))

(defun spaceline--unicode-number (str)
  (cond
   ((string= "1" str) "➊")
   ((string= "2" str) "➋")
   ((string= "3" str) "➌")
   ((string= "4" str) "➍")
   ((string= "5" str) "➎")
   ((string= "6" str) "❻")
   ((string= "7" str) "➐")
   ((string= "8" str) "➑")
   ((string= "9" str) "➒")
   ((string= "0" str) "➓")))

(defvar spaceline-window-numbers-unicode nil)
(spaceline-define-segment window-number
  (let* ((num (window-numbering-get-number))
         (str (when num (int-to-string num))))
    (if spaceline-window-numbers-unicode
        (spaceline--unicode-number str)
      str))
  :when (bound-and-true-p window-numbering-mode))

(defvar spaceline-workspace-numbers-unicode nil)
(spaceline-define-segment workspace-number
  (let* ((num (eyebrowse--get 'current-slot))
         (str (when num (int-to-string num))))
    (if spaceline-workspace-numbers-unicode
        (spaceline--unicode-number str)
      str))
  :when (bound-and-true-p eyebrowse-mode))

(provide 'spaceline-segments)

;;; spaceline-segments.el ends here
