"""Application configuration, loaded from environment variables.

Twelve-Factor style: every setting (database URL, Ollama URL, API keys, vault path,
environment name) comes from the environment, never from a file committed to the repo.
See `.env.example` for the variables that exist today.

TODO(week 3): build this on Day 11 with pydantic-settings. Decide which settings are
required, which have defaults, and how secrets are kept out of logs and error messages.
"""
