## [Unreleased]

## [0.3.1] - 2026-09-09

- Updates `README.md` and the `gemspec` file for publishing on rubygems.org

## [0.3.0] - 2026-09-08

- Adds option for additional payload for each key:  
    ```ruby
    register(:some_name, keys: [:key_one])
    # is identical to
    register(:some_name, keys: [key_one: []])
    
    # The method `#use!` allows you to access the payload as well:
    demand (:some_name).use!(:key_one)
    ```

## [0.2.1] - 2026-09-08

- Prevent overriding of already defined demands when `RegistrationOffice[:demand]` is included multiple times.
  This happens automatically when defining both a demand and a registry within the same object.

## [0.2.0] - 2026-09-07

- Uses multiple, named registers and demands instead of anonymous
- Enforces registering keys of same register all at once

## [0.1.0] - 2026-09-04

- Initial release
