# SoLaWiS distribution map

This map shows all available distribution points of SoLaWiS.

## Create data

Add your distribution points to `data.json`.
To get the `long` and `lat` values
you can use an OSM Tool like this: http://gll.petschge.de/

## Build

[Node.js](http://nodejs.org/) is required to build this project.

    git clone https://github.com/solawis/distributionMap.git
    cd distributionMap/
    npm install .
    coffee -c map.coffee
    stylus main.styl

## License

This project is licensed under the AGPLv3 license.
