# Tzispa

A sparkling web framework

## Frameworks

Tzispa is composed by these frameworks:

* [**Tzispa::Rig**](https://github.com/japiber/tzispa_rig) - Template engine
* [**Tzispa::Utils**](https://github.com/japiber/tzispa_utils) - Ruby class utilities
* [**Tzispa::Helpers**](https://github.com/japiber/tzispa_helpers) - Helper modules
* [**Tzispa::Data**](https://github.com/japiber/tzispa_data) - Data access layer


## Installation

```shell
% gem install tzispa
```

## Usage

```shell
% tzispa generate project myproject
% cd myproject
% tzispa generate app mainapp --host=www.mynewsite.com
% puma start.ru
```

## Adding more apps

Tzispa support multi-app projects. Each app must have a unique mount path

```shell
% tzispa generate app adminapp --host=www.mynewsite.com --mount=admin
```

## Adding templates

There are 3 template types: layout, static and block:

* layout: these are the skeleton entry points of the rig templates
* static: these are "light" templates that are a included without any processing as plain text
* block: the true core of the rig templates, each block template file has an associated ruby file with the template binder class

```shell
% tzispa generate rig lister --type=layout --app=mainapp
% tzispa generate rig sitefoot --type=static --app=mainapp
% tzispa generate rig product_detail --type=block --app=mainapp
```

Work in progress ...
