# Wordpress Breeze
[![](https://images.microbadger.com/badges/version/dorfjungs/wordpress-breeze.svg)](https://microbadger.com/images/dorfjungs/wordpress-breeze)
[![](https://images.microbadger.com/badges/image/dorfjungs/wordpress-breeze.svg)](https://microbadger.com/images/dorfjungs/wordpress-breeze)

> The less shitty wordpress installation. Still crap, though.

## Why?
I am asking myself the same question and couldn't find an answer to that - yet.
This is simply a basic setup for a specific wordpress architecture to reduce the pain for the developers. It's packed into a docker container. So you basically have a package with the basic stuff required for a minimal wordpress setup (including plugins, settings, users etc.). You're welcome. You only need to attach the corresponding volumes in order to customize the instance. Sounds pretty simple? It is, indeed. But don't get me wrong, wordpress still sucks on a very high level and it will suck as long as there are developers supporting (and using) it. Me included, per se. So consider this package a painkiller for the agony that comes with wordpress.

## Documentation
A more detailed documentation can be found [here](https://wordpress-breeze.github.io/).

## Development
This whole package will be published by the dockerhub build automation. To trigger this you can simply push a tag and dockerhub handles the process for you.

### Creating a new release
To create a new release simply create and push a tag with this format: `^v[0-9].[0-9]+`

## License
See the [LICENSE](./LICENSE) file for license rights and limitations (MIT).