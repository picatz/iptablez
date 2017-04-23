# Chains Interface

The `Chains` Inteface is a collection of helpful methods to act as a clear, friendly interface to the possible collection of `Commands` which Iptablez implements. You're free to use the commands, just as the `Chains` interface would under the hood.

## Method Overview
```ruby
require 'iptablez'

Iptablez::Chains.all
Iptablez::Chains.defaults
Iptablez::Chains.create
Iptablez::Chains.rename
Iptablez::Chains.flush
Iptablez::Chains.delete
Iptablez::Chains.exists?
Iptablez::Chains.policies
Iptablez::Chains.policy?
Iptablez::Chains.user_defined
Iptablez::Chains.user_defined?
```

## All

Return a list of all the possible chains including defaults and user defined.

```ruby
Iptablez::Chains.all
# => ["INPUT", "FORWARD", "OUTPUT", "cats", "dogs"]

Iptablez::Chains.all do |chain|
  puts chain
end

Iptablez::Chains.all { |chain| puts chain }

Iptablez::Chains.all.each do |chain|
  puts chain
end
```

## Defaults

Return a list of all the default chains.

```ruby
Iptablez::Chains.defaults
# => ["INPUT", "FORWARD", "OUTPUT"]

Iptablez::Chains.defualts do |chain|
  puts chain
end

Iptablez::Chains.defaults { |chain| puts chain }

Iptablez::Chains.defaults.each do |chain|
  puts chain
end
```

## Delete 

Delete a list of a given single `name` or an array of `names`. If the chain is not empty, the operation will fail. Consider flushing the chain(s) if you want to delete them.

```ruby
Iptablez::Chains.delete(name: "frogs") # frogs is not a real chain
# => false

Iptablez::Chains.delete(name: "frogs") do |name, result|
  if result # this will be false
    puts "#{name} was deleted!"
  else
    puts "#{name} couldn't be deleted!"
  end
end

Iptablez::Chains.delete(names: ["dogs", "cats"])
# => {"dogs"=>true, "cats"=>true}

Iptablez::Chains.delete(names: ["dogs", "cats"]) do |name, result|
  puts name if result # won't happen, already deleted! :)
end
# => {"dogs"=>false, "cats"=>false}
```

## Exists?

Check if a list of a given single `name` or an array of `names` actually exists.

```ruby
Iptablez::Chains.exists?(name: "frogs") # frogs is not a real chain
# => false

Iptablez::Chains.exists?(name: "frogs") do |name, result|
  if result # this will be false
    puts "#{name} exists!"
  else
    puts "#{name} doesn't exist!"
  end
end

Iptablez::Chains.exists?(names: ["dogs", "cats"])
# => {"dogs"=>true, "cats"=>true}

Iptablez::Chains.exists?(names: ["dogs", "cats"]) do |name, result|
  puts name if result # won't happen, already deleted! :)
end
# => {"dogs"=>false, "cats"=>false}
```

## Policies

Get a a list of a given single `name` or an array of `names` default policy response/target.

```ruby
Iptablez::Chains.policies(name: "frogs") # frogs is not a real chain
# => false

Iptablez::Chains.exists?(name: "frogs") do |name, result|
  if result # this will be false
    puts "#{name} exists!"
  else
    puts "#{name} doesn't exist!"
  end
end

Iptablez::Chains.exists?(names: ["dogs", "cats"])
# => {"dogs"=>true, "cats"=>true}

Iptablez::Chains.exists?(names: ["dogs", "cats"]) do |name, result|
  puts name if result # won't happen, already deleted! :)
end
# => {"dogs"=>false, "cats"=>false}
```






