Tzispa

General purpose web framework

## v0.4.1
- Add support to generate canonical urls 

## v0.4.0
- Added basic cli command engine
- Added some documentation in README.md

## v0.3.3
- Added internationalization support with i18n
- Created new config folder in each domain to store all configurations
- Moved webconfig.yml to the config folder
- New routes definition in-app instead of yml config file
- Added framework routes 'api', 'site' and 'index' in Routes class methods

## v0.3.2
- Added 'use' method in Repository to support multiple adapters in apps
- new repository management to allow 'local' and gem repositories
- repository dup in context to separate repository state between requests
- log unrescued errors in base controller
- raise custom exceptions to notify unknown models, adapters

## v0.3.1
- Moved model to entity monkey patched methods to independent module 'Entity'
- Preload all repository model classes in application startup

## v0.3.0
- Added Rig templates caching in Application
- Added mutex sync access to the shared repository

## v0.2.9
- Move Rig template engine into independent gem: tzispa_rig

## v0.2.8
- Move constantize and camelize functions into class Tzispa::Utils::String
- Move Decorator class into tzispa_utils

## v0.2.7
- Split helpers modules into independent gem: tzispa_helpers

## v0.2.6
- Added mail helper

## v0.2.5
- Split utilities into another gem: tzispa_utils

## v0.2.4
- Added Repository / Model / Entity abstraction layers

## v0.2.0
- Removed Lotus dependencies and implementing a mininal http core framework based on Rack

## v0.1.1
- Added basic configuration api
- Added Model::Base class
- Added Configuration by convention to easy manage Rig Engine parameters

## v0.1.0
- Library implemented as a gem, previously only a bunch of files
