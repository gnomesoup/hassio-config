(defun mjp/hassio-gitpull-restart()
  "Restart the hassio Git Pull addon"
  (interactive)
  (save-excursion
    (let* ((hass-token (mjp/match-file-contents "hass-token = \\(.*\\)"
                                             "~/HomeassistantConfig/hass-token.txt"))
          (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                           "~/HomeassistantConfig/hass-token.txt"))
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
                                                "~/HomeassistantConfig/hass-token.txt"))
           (hass-url (mjp/match-file-contents "hass-url = \\(.*\\)"
                                              "~/HomeassistantConfig/hass-token.txt"))
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
