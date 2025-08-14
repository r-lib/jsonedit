# Updating jsonc-parser

To update `jsonc.js` to the latest npm version, run this anywhere in a shell:

```sh
npm install -g browserify
npm install jsonc-parser
echo "global.jsonc = require('jsonc-parser');" > in.js
browserify in.js -o jsonc.js
```

Alternatively, to update to the latest git version:

```sh
npm install -g browserify
git clone https://github.com/microsoft/node-jsonc-parser
cd node-jsonc-parser
npm install .
npm test
echo "global.jsonc = require('.');" > in.js
browserify in.js -o jsonc.js
```
