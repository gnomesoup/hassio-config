(defun mjp/match-file-contents (regex filePath)
  "Matches a regular expression with contents in another file"
  (let ((fContents (with-temp-buffer (insert-file-contents filePath nil)
                                     (buffer-string))))
    (string-match regex fContents)
    (match-string 1 fContents)))

(defun mjp/hassio-gitpull-restart()
  "Restart the hassio Git Pull addon"
  (interactive)
  (save-excursion
    (let* ((hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                             "~/hassio-config/hass-token.txt"))
          (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                           "~/hassio-config/hass-token.txt"))
          (curl-command (concat "curl \"-i\" \"-H\" \"Content-Type: application/json\" \"-H\" \"Authorization: Bearer "
                                hass-token
                                "\" \"-XPOST\" \""
                                hass-url
                                "/api/services/hassio/addon_restart\" "
                                "\"-d\" \"{\\\"addon\\\":\\\"core_git_pull\\\"}\"")))
      (async-shell-command curl-command "*hassio*" "*httperror*")
      )
    )
  )

(defun mjp/hassio-get-all-entities()
  "Get all Entity Id's from Home Assistant"
  (interactive)
  (save-excursion
    (let* ((hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                                "~/hassio-config/hass-token.txt"))
           (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                              "~/hassio-config/hass-token.txt"))
           (curl-command (concat "curl \"-i\" \"-H\" \"Content-Type: application/json\" "
                                 "\"-H\" \"Authorization: Bearer "
                                 hass-token
                                 "\" \"-XPOST\" \""
                                 hass-url
                                 "/api/template\" "
                                 "\"-d\" \"{\\\"template\\\":\\\"{% for state in states %}{{state.entity_id}}\\n{% endfor %}\\\"}\"")))
      (async-shell-command curl-command "*hassio*" "*httperror*")
      )
    )
  )

(defun mjp/hassio-get-state(entity_id)
  "Get the state properties of the entity provided"
  (interactive "sentity_id: ")
  (save-excursion
    (let* ((hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                                "~/hassio-config/hass-token.txt"))
           (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                              "~/hassio-config/hass-token.txt"))
           (curl-command (concat "curl \"-H\" \"Content-Type: application/json\" "
                                 "\"-H\" \"Authorization: Bearer "
                                 hass-token
                                 "\" \"-X GET\" \""
                                 hass-url
                                 "/api/states/"
                                 entity_id
                                 "\"")))
      (async-shell-command curl-command "*hassio*" "*httperror*")
      (message ))))
