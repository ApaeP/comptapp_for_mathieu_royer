# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.0.1
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/components", under: "components"

pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js"

pin "@nathanvda/cocoon", to: "@nathanvda--cocoon.js" # @1.2.14
pin "sweetalert2" # @11.4.8
pin "stimulus-dropdown" # @2.0.0
pin "hotkeys-js" # @3.8.7
pin "stimulus-use" # @0.50.0
