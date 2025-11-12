# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/helpers", under: "helpers"

pin "flowbite", to: "https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.turbo.min.js"
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.6.4/dist/jquery.min.js", preload: true
pin "cropperjs", to: "cropper.esm.js"
pin "@nathanvda/cocoon", to: "@nathanvda--cocoon.js" # @1.2.14
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
