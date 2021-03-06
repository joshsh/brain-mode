;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smsn-http.el -- HTTP client for Semantic Synchrony
;;
;; Part of the SmSn-mode package for Emacs:
;;   https://github.com/synchrony/smsn-mode
;;
;; Copyright (C) 2011-2017 Joshua Shinavier and collaborators
;;
;; You should have received a copy of the GNU General Public License
;; along with this software.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'smsn-env)
(require 'smsn-serde)


(defun http-callback (callback)
  (lexical-let
    ((context (copy-alist (smsn-env-get-context)))
     (callback callback))
    (lambda (status)
      (handle-http-response status context callback))))

(defun handle-http-response (http-status context callback)
  (if http-status
    (error "%s" (concat "HTTP request failed: " (json-encode http-status)))
    (let ((response (get-buffer-content)))
      (smsn-serde-handle-response response callback context))))

(defun http-post (url params callback)
  "Issue an HTTP POST request to URL with PARAMS"
  (let ((url-request-method "POST")
        (url-request-extra-headers '(("Content-Type" . "application/json;charset=UTF-8")))
        (url-request-data
          (smsn-serde-format-args params)))
    (url-retrieve url callback)))

(defun http-get (url callback)
  "Issue an HTTP GET request to URL"
  (url-retrieve url callback))

(defun strip-http-headers (entity)
  (let ((i (string-match "\n\n" entity)))
    (if i
        (decode-coding-string (substring entity (+ i 2)) 'utf-8)
        "{}")))

(defun get-buffer-content ()
  (strip-http-headers (buffer-string)))

(defun http-connection-url (host port)
  (concat "http://" host ":" (number-to-string port)))

(defun smsn-http-send-and-receive (host port request callback)
    (http-post (http-connection-url host port) request
      (http-callback callback)))


(provide 'smsn-http)
