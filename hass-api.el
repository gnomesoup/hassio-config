(require 'json)

(spacemacs/declare-prefix "ah" "hass-api")

(defun mjp/match-file-contents (regex filePath)
  "Matches a regular expression with contents in another file"
  (let ((fContents (with-temp-buffer (insert-file-contents filePath nil)
                                     (buffer-string))))
    (string-match regex fContents)
    (match-string 1 fContents)))

(defun hass-api/gitpull-restart()
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

(defun hass-api/get-all-entities()
  "Get all Entity Id's from Home Assistant"
  (interactive)
  (save-excursion
    (let* ((hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                                "~/hassio-config/hass-token.txt"))
           (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                              "~/hassio-config/hass-token.txt"))
           (curl-command (concat "curl -i -H \"Content-Type: application/json\" "
                                 " -H \"Authorization: Bearer "
                                 hass-token
                                 "\" \"-XPOST\" \""
                                 hass-url
                                 "/api/template\" "
                                 "\"-d\" \"{\\\"template\\\":\\\"{% for state in states %}{{state.entity_id}}\\n{% endfor %}\\\"}\"")))
      (async-shell-command curl-command "*hassio*" "*httperror*")
      )
    )
  )

(defun hass-api/get-state-by-entity(&optional entity_id)
  "Get the state properties of the entity provided"
  (interactive)
  (save-excursion
    (let* ((entity_id (or entity_id (hass-api/get-entity-from-list)))
           (hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                                "~/hassio-config/hass-token.txt"))
           (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                              "~/hassio-config/hass-token.txt"))
           (curl-command (concat "curl -H \"Content-Type: application/json\" "
                                 "-H \"Authorization: Bearer "
                                 hass-token
                                 "\" -X GET "
                                 hass-url
                                 "/api/states/"
                                 entity_id)))
      (async-shell-command curl-command "*hassio*" "*httperror*")
      (message "Entities obtained"))))

(spacemacs/set-leader-keys "ahs" 'hass-api/get-state-by-entity)

(defun hass-api/get-entity-from-list()
  "Get the state properties of the entity provided"
  (save-excursion
    (let* ((entityList (list))
           (helmList)
           (entity_id)
           (hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                                "~/hassio-config/hass-token.txt"))
           (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                              "~/hassio-config/hass-token.txt"))
           (curl-command (concat "curl -i -H \"Content-Type: application/json\" "
                                 " -H \"Authorization: Bearer "
                                 hass-token
                                 "\" \"-XPOST\" \""
                                 hass-url
                                 "/api/template\" "
                                 "\"-d\" \"{\\\"template\\\":\\\"{% for state in states %}{{state.entity_id}}\\n{% endfor %}\\\"}\"")))
      (set 'entityList (nthcdr 6 (split-string (shell-command-to-string curl-command) "\n")))
      ;; (message "entity list length: %d" (length entityList))
      (set 'helmList '((name . "HASS Entities")
                         (candidates . entityList)
                         (action . (lambda (candidate)
                                     (helm-marked-candidates)))))
      (set 'entity_id (car (helm :sources '(helmList))))
      entity_id)))

(defun hass-api/get-entity-from-list-to-buffer()
  "Output selected entity id from a helm list of entities"
  (interactive)
  (let* ((entity_id (hass-api/get-entity-from-list)))
    (insert entity_id)))

(spacemacs/set-leader-keys "ahe" 'hass-api/get-entity-from-list-to-buffer)

(provide hass-api)
