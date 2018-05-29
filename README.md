# EdFi::Client  [![Gem Version](https://badge.fury.io/rb/ed_fi_client.svg)](https://badge.fury.io/rb/ed_fi_client)

A utility class for authenticating to and making CRUD calls against an Ed-Fi ODS API.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ed_fi_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ed_fi_client


## Using EdFi::Client

### Basic Usage: Reading Data

```ruby
## Establish a connection to an Ed-Fi ODS / API.
## (We'll use the Alliance-hosted Ed-Fi ODS / API sandbox instance.)

sandbox = EdFi::Client.new(
  'https://api.ed-fi.org/api/',
  client_id: 'RvcohKz9zHI4',
  client_secret: 'E1iEFusaNf81xzCxwHfbolkC'
)

sandbox = sandbox.v2(2017)  ## For purposes of these samples, we're only
                            ## concerned with 2017-2018 school-year data.


## Let's pull some assorted values!

sandbox.get('schools', query: { school_id: 255901001 })  ## Get school 255901001.

sandbox.get('disciplineIncidents')  ## Get all discipline incidents.
sandbox.get('disciplineIncidents').sample.school  ## A random incident's school.

all_schools = sandbox.get('schools')  ## All schools.
all_schools.sample.name_of_institution  ## A random school's name.
all_schools.map { |i| [i.id, i.school_id] }.to_h  ## Maps ODS IDs to school IDs.
```

---

### Basic Usage: Writing Data

```ruby
sandbox = EdFi::Client.new(
  'https://api.ed-fi.org/api/',
  client_id: 'RvcohKz9zHI4',
  client_secret: 'E1iEFusaNf81xzCxwHfbolkC'
).v2(2017)

school = sandbox.get('schools').sample
original_name = school.name_of_institution  ## So we can leave it like we found it.


## Via PUT ...

school.name_of_institution = 'New Name, via PUT'
sandbox.put("schools/#{school.id}", payload: school)
sandbox.get("schools/#{school.id}").name_of_institution  ## => "New Name, via PUT"


## Via POST ...

school.name_of_institution = 'New Name, via POST'
sandbox.post("schools", payload: school.except(:id))
sandbox.get("schools/#{school.id}").name_of_institution  ## => "New Name, via POST"


## Let's leave things like we found them.

school.name_of_institution = original_name
sandbox.put("schools/#{school.id}", payload: school)
```

---

[Consult the repo docs for the full EdFi::Client documentation.](http://nestor-custodio.github.io/ed_fi_client/EdFi/Client.html)


## Feature Roadmap / Future Development

Additional features/options coming in the future:

- Cleaner handling of non-body-returning calls.
- Use the given base endpoint's Swagger API definition file (if present) to make collections/resources more easily reachable: `#schools`, `#discipline_incidents`, etc.
- Allow for easier manipulation of resources via AR-like methods (`#find`, `#find_by`, `#where`, `#create`, `#update`, etc).


## Contribution / Development

Bug reports and pull requests are welcome on GitHub at https://github.com/nestor-custodio/ed_fi_client.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Linting is courtesy of [Rubocop](https://github.com/bbatsov/rubocop) and documentation is built using [Yard](https://yardoc.org/). Neither is included in the Gemspec; you'll need to install these locally (`gem install rubocop yard`) to take advantage.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
