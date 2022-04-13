// Import and register all your controllers from the importmap under controllers/*
import { application } from "controllers/application"
import Dropdown from 'stimulus-dropdown'

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
application.register('dropdown', Dropdown)
