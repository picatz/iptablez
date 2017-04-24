# 🦑 Iptablez

A friendly Ruby API to `iptables`. With a squid for a mascot.

### 🚧  Development Notice

Iptablez is still under development.

## Installation

    $ gem install iptablez

## Usage

### ⛓  Chains

Easily list all of the `iptables` chains.

```ruby
Iptablez.chains
# => ["INPUT", "FORWARD", "OUTPUT", "cats", "dogs"]

Iptablez::Chains.all
# => ["INPUT", "FORWARD", "OUTPUT", "cats", "dogs"]
```

Maybe you just want the default chains?

```ruby
Iptablez::Chains.defaults
# => ["INPUT", "FORWARD", "OUTPUT"]

Iptablez::Chains::DEFAULT
# => ["INPUT", "FORWARD", "OUTPUT"]
```

Create a new user defined chain(s)?

```ruby
Iptablez::Chains.create(name: "dogs")
# => true

Iptablez::Chains.create(name: ["dogs", "cats"])
# => {"dogs"=>false, "cats"=>true}
```

Delete a user defined chain(s) ( that's empty )?

```ruby
Iptablez::Chains.delete(name: "dogs")
# => true

Iptablez::Chains.delete(names: ["dogs", "cats"])
# => {"dogs"=>false, "cats"=>true}
``` 

Maybe rename a user defined chain?

```ruby
Iptablez::Chains.rename(from: "dogs", to: "puppies")
# => true

Iptablez::Chains.rename(pairs: { "dogs" => "puppies", "cats" => "kittens"} )
# => {"dogs"=>{"puppies"=>false}, "cats"=>{"kittens"=>true}}
```

Why not check the default chain policies?

```ruby
Iptablez::Chains.policies
# => {"INPUT"=>"ACCEPT", "FORWARD"=>"ACCEPT", "OUTPUT"=>"ACCEPT"}
```

Want to be a little bit more specific when checking policies? I got'chu.

```ruby
Iptablez::Chains.policy?(name: "INPUT", policy: "ACCEPT")
# => true

Iptablez::Chains.policy?(name: "FORWARD", policy: "ACCEPT")
# => false

Iptablez::Chains.policies(names: ["FORWARD", "OUTPUT"])
# => {"FORWARD"=>"ACCEPT", "OUTPUT"=>"ACCEPT"}
```

Feel like flushing some chains? Maybe you're about to delete them and need them to not be empty. I feel you.

```ruby
Iptablez::Chains.flush(name: "wizards")
# => true

Iptablez::Chains.flush(names: ["wizards", "hobbits"])
# => {"wizards"=>false, "hobbits"=>true}
```

Curious if there are any user defined chains?

```ruby
Iptablez::Chains.user_defined?
# => true
```

Curious if a specific chain(s) has been user defined?

```ruby
Iptablez::Chains.user_defined?(name: "frogs")
# => false

Iptablez::Chains.user_defined?(names: ["wizards", "hobbits"])
# => {"wizards"=>true, "hobbits"=>true}
```

TODO add more stuff.

## 🐚  iptablez-shell

This is a TODO. Iptablez provides an interactive shell via the `iptablez-shell` command.

```ruby
$ iptablez-shell
🦑  ~ (main)> Iptablez.version
```

## 🦑  iptablez-cli

This is a TODO. Iptablez provides a simple command-line application via the `iptablez-cli` command.

```shell
$ iptablez-cli -h
```
##  iptablez-web

This is a TODO. Iptablez provides a web application that can be started via the `iptablez-web` command.

##  iptablez-api

This is a TODO. A simple REST API that can be started via the `iptablez-api` command.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

