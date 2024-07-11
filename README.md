# Kosli Playground

A playground for learning how to implement Kosli.

This is a very simple demo application. It is made up of three components:

- WebApp: a single-page javascript web app.
- Alpha: a Ruby based API service
- Beta: a Ruby based API service

This repo is a monorepo with each component in its own directory with its own Makefile.
Each component has an independent GitHub Actions workflow. 
Each workflow will trigger when changes to the relevant component are pushed to the main branch.