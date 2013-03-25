fs       = require 'fs'
csv2json = require 'csv2json-stream'

opts =
  delim : ','
  headers: true,
  outputArray: true

fs.createReadStream('data.csv')
  .pipe(csv2json(opts))
  .pipe(fs.createWriteStream('data.json'))
