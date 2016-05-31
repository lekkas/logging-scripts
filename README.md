# logspout-scripts

Scripts for setting up logspout loggin containers in resin.io devices

## Using

* git clone this project into your application container
* run `LOGGING_SERVER="syslog+tcp://logstash.resin.io:5000" ./logsetup.sh create`. Set `LOGGING_SERVER` accordingly to point to your server.

If you need to remove logspout containers (e.g. you are no longer intersted in logging and want to preserve resources) simply run
* `./logsetup.sh teardown`

## Dependencies

* `jq >= 1.5`

## Support

If you're having any problem, please [raise an issue](https://github.com/resin-io-playground/logspout-scripts/issues/new) on GitHub and the Resin.io team will be happy to help.

## Contribute

- Issue Tracker: [github.com/resin-io/logspout-scripts/issues](https://github.com/resin-io/logspout-scripts/issues)
- Source Code: [github.com/resin-io/logspout-scripts](https://github.com/resin-io/logspout-scripts)`

## Licence

The project is licenced under the Apache 2.0 license.
