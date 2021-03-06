Tzispa

General purpose web framework

## v0.9.1
- updated dependencies versions
- bug fix for old app_config requiring

## v0.9.0
- configuration moved into tzispa_config gem
- refactoring for new singleton Repository

## v0.8.3
- refactoring for tzispa_helpers autoloading

## v0.8.1
- rig api handler moved to tzispa_rig gem
- environment constants refactoring & improves env key access throught method_missing
- fix applocation global mutext for apps boot & initialization
- postpone server bind host/port to the Puma web server configuration phase

## v0.8.0
- introducing support for other template engines
- improve errors log
- bugs fixes

## v0.7.6
- added custom error pages option in base controller
- disable custom error page in the api controller

## v0.7.5
- bug fix in controller base response status code was not being set

## v0.7.4
- changed repository load order in app
- tzispa commands bugs fix

## v0.7.3
- bug fix in controllers base prepare_response method

## v0.7.2
- added before/after hooks in controllers and handlers

## v0.7.1
- ensure set response status in prepare_client/server_error
- added result_redirect method in api handlers
- bug fixes

## v0.7.0
- distinct error and http status in api handlers
- better api responses by content type
- controller base: better error handling in invoke
- api handlers: added support for api http verbs using request_method
- independent db/repository configuration file
- app environment implementation
- automatic code reloading in development env (Shotgun)
- added before hook in controllers and api-handlers
- new routes specification file per app
- code refactoring and bug fixes

## v0.6.1
- sessions security improvements
- added "x-frame-option: sameorigin" header to security improvement

## v0.6.0
- code refactoring & templates namespace simplification
- added auth_layout controller
- added context cache
- added default format from config in layout url builders
- removed per app rig engines

## v0.5.17
- remove debug puts

## v0.5.16
- controller/api: not populate body with the handler data if error? at json response
- api/handler: fix i18n key in api handler error message builder
- controller/api: add handler error status in the json response when error

## v0.5.15
- add thor gem missing dependency in gemspec

## v0.5.14
- populate json response when there are handler errros
- api error messages now managed by i18n files
- code fixes for replacing TzString with String refinement

## v0.5.13
- update code creation templates in cli to reflect DSL changes
- remove not used gem dependencies
- bug fixes

## v0.5.12
- minor bug fixes
- added new class run method to improve DSL usage

## v0.5.11
- moved app config files location
- moved app locales base dir
- api sign checking has been moved to handlers by helpers dsl
- api dispatch code improvement and fixes
- code reorganization to expose better interfaces

## v0.5.10
- fix: check if the given layout is the default_layout in config before promote into the path params hash
- add tmp folder in the project creation cli command

## v0.5.9
- add services folder in app domains
- updated new app creation template code in cli

## v0.5.8
- add api mapping verb to method in lib/tzispa/api/handler.rb
- add support for api handler mapping verb to method in lib/tzispa/controller/api.rb
- improve app routing DSL by forwarding methods from routes lib/tzispa/app.rb
- renamed rig related routing methods in lib/tzispa/routes.rb
- add path building methods for rig layouts in lib/tzispa/http/context.rb

## v0.5.7
- add provides DSL method to specify allowed verbs in api handlers
- handler calling improvements in api the controller

## v0.5.6
- more application DSL usage improvements
- application builder passed in the run method
- fix router to response http error 404 when no route match is found

## v0.5.5
- Changes in application initialize to improve DSL usage
- Application mount removed

## v0.5.3
- Add basic inter-app operability for api and url calls

## v0.5.2
- Api download data[:path] must contain full path to the file

## v0.5.1
- Add result_json facility in Api::Handler
- Rack update requirement to 2.0
- Fix http_router not populating env with rack 2.0
- Code optimizations in middlaware management

## v0.5.0
- Add support for signed and unsigned api calls

## v0.4.20
- Add signed_api route and controller previous api controller is for unsigned api calls

## v0.4.19
- fix cli api command errors

## v0.4.18
- rescue Tzispa::Rig::NotFound in controller/base to set response status code 404

## v0.4.17
- response_verb is send to the conttroller not to the handler ...

## v0.4.16
- check response_verb before send it to the handler in controller/api
- move routes from app-class to app-instance

## v0.4.15
- move context creation from app to middleware
- remove controller/layout custom headers

## v0.4.14
- remove moneta session in middleware: now use session goes in App class definition
- remove repository dup in context because isn't required without the respository.use method
- add missing require securerandom for session_id in http/context

## v0.4.13
- Set router default app to http_error 404

## v0.4.12
- Fix controller/base all errors go to error 500

## v0.4.11
- Rescue exceptions and catch halts on controller/base
- http/context error_500 not sets response.status
- Rescue exceptions in app.call only log and set response.status previous code moved to controller/base

## v0.4.10
- http/context api method return a canonical url including hostname

## v0.4.9
- in http/response.rb add missing alias secure? for ssl?
- in controller/api.rb fix redirect url if data is empty

## v0.4.8
- rename context method error to error_500 for conflict with response helper error method
- pass response.status to error_page in controller base class

## v0.4.7
- remove browser detection obsolete code
- remake app error handling and reporting

## v0.4.6
- add browser detection support
- allow specify a url fragment to redirect to the referer page section
- middleware management fixes

## v0.4.5
- remove load_assets_middleware
- add browser detection capability
- App environment constants names moved to app.rb
- code beautify
- Fix crash if there isn't any layout in http context
- Moved routes from Config namespace to Tzispa root
- Moved context creation from Controller::Base to Application::call
- code clean and organize

## v0.4.4
- Add new template_cache config parameter

## v0.4.2
- Preload api and helper modules and classes in app.load

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
