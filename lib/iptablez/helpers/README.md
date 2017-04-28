# Helpers 

Iptablez helpers are here to make life easier by helping out.

## Method Overview
```ruby
require 'iptablez'

Iptablez.bin_path
Iptablez.version
Iptablez.list
Iptablez.chains
# more to come I'm sure...
```

## Bin Path

Return the full path to `iptables`.

```ruby
Iptablez.bin_path
# => "/sbin/iptables"
```

## Version

Get `iptables` version.

```ruby
Iptablez::Chains.version
# => "1.6.0"
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






