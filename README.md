# Activerecord::View [![Build Status](https://travis-ci.org/scryptmouse/activerecord-view.svg?branch=master)](https://travis-ci.org/scryptmouse/activerecord-view)

Integration for ActiveRecord to facilitate easy use of views in migrations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-view'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-view

## Usage

To create a view in a database migration:

```ruby
def change
  # You can provide a string
  create_view :admins, 'SELECT * FROM users WHERE role = "admin"'

  # Or an object that responds #to_sql
  users = User.arel_table

  create_view :authors, users.project('*').where(users[:role].eq('author'))

  # Or a block that returns one of the above if that's more convenient
  create_view :magicians do
    users.project('*').where(users[:role].eq('magician'))
  end
end
```

Use with `change` is fully supported, commands will revert and do the right thing.

Reverting a `drop_view` requires you to pass the body to restore somehow:

```
def change
  drop_view :authors, original_authors_definition_from_elsewhere

  drop_view :admins do
    original_admins_definition_from_elsewhere
  end

  # In a change method, this will raise an ActiveRecord::IrreversibleMigration!
  drop_view :magicians
end
```

Then, in your model

```ruby
class Magician < ActiveRecord::Base
  is_view!
end
```

By default, views are made read-only. [MySQL](https://dev.mysql.com/doc/refman/5.5/en/view-updatability.html) and
[Postgres](http://www.postgresql.org/docs/9.3/static/sql-createview.html#SQL-CREATEVIEW-UPDATABLE-VIEWS) support
the notion of updatable views, but this currently isn't tested.

If you want to make a view updatable:

```ruby
class Magician < ActiveRecord::Base
  is_view! readonly: false
end
```

### Materialized Views
Postgres supports [materialized views](http://www.postgresql.org/docs/9.3/static/rules-materializedviews.html), and so does this gem.

```ruby
def change
  users = User.arel_table

  by_role = ->(role) { users.project('*').where(users[:role].eq('admin')) }

  # The API is basically the same
  create_materialized_view :admins do
    by_role.call 'admin'
  end

  # Except there's the option to pass `with_data: true` to prepopulate the view.
  create_materialized_view :authors, with_data: true do
    by_role.call 'author'
  end

  create_materialized_view :magicians, by_role['magician'], with_data: true

  # Materialized views support indexing
  add_index :admins, :name
  add_index :magicians, :name
  add_index :authors, :email, unique: true
end
```

Then, in your model:

```ruby
class Author < ActiveRecord::Base
  is_materialized_view!
end
```

Like regular views above, materialized views can also be made updatable on MySQL and Postgres
if the conditions are met, via `is_materialized_view! readonly: false`.

To refresh a materialized view, use `ModelName.refresh_view!`.

Concurrent refresh (PG 9.4) is not yet supported through the gem, but it is on the roadmap.

## Requirements

* Ruby 2.1+
* ActiveRecord 4.1+

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/scryptmouse/activerecord-view/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
