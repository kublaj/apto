// entry point, here for require("apto");
apto = require("./lib/apto");
apto_util = require("./lib/util");

module.exports = {
  Site: apto.Site,
  util: {
    watch: apto_util.watch,
    listfilesSync: apto_util.listfilesSync
  }
}
