# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Build

To build the application:

`bin/setup`

## Run the API

To run the TodoApi in your local environment:

`bin/puma`

## Test

To run tests:

`bin/rspec`

Check integration tests at: (https://github.com/crunchloop/interview-tests)

## Contact

- Santiago Doldán (sdoldan@crunchloop.io)

## About Crunchloop

![crunchloop](https://s3.amazonaws.com/crunchloop.io/logo-blue.png)

We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/#contact).

---

## Requerimientos del challenge

- [x] Arreglar tests
- [x] Usar nested routes
- [x] Hacer interfaz web de todo list y todo items, seedear muchos todo items e implementar un complete all
  - Job async
  - Completar en tiempo real en la interfaz web (Turbo)

## Lo que se agregó

- **Interfaz web completa** — vistas HTML para todo lists y todo items con Hotwire (Turbo Frames + Turbo Streams)
- **Complete All** — botón que despacha `CompleteAllItemsJob` y actualiza los items en tiempo real por batches vía ActionCable
- **Paginación** — con Pagy en el index de listas y lazy load de items al expandir cada card
- **Tests corregidos** — specs de `Api::TodoItemsController` pasando con la nueva estructura de rutas
- **Migración a Jbuilder** — respuestas JSON de `Api::TodoListsController` movidas a vistas `.json.jbuilder`
- **Toast notifications** — para mostrar mensajes de éxito/error en la interfaz web usando Stimulus
