var exec = require('cordova/exec');

var PLUGIN_NAME = "CordovaClassKit";

var CordovaClassKit = {
    initContextsFromXml: function(urlPrefix, success, error) {
        exec(success, error, PLUGIN_NAME, "initContextsFromXml", [urlPrefix]);
    },
    addContext: function(urlPrefix, context, success, error) {
        exec(success, error, PLUGIN_NAME, "addContext", [urlPrefix, context]);
    },
    removeContexts: function(success, error) {
        exec(success, error, PLUGIN_NAME, "removeContexts", []);
    },
    removeContext: function(identifierPath, success, error) {
        exec(success, error, PLUGIN_NAME, "removeContext", [identifierPath]);
    },
    beginActivity: function(identifierPath, asNew, success, error) {
        exec(success, error, PLUGIN_NAME, "beginActivity", [identifierPath, asNew]);
    },
    endActivity: function(success, error) {
        exec(success, error, PLUGIN_NAME, "endActivity", []);
    },
    setProgressRange: function(fromStart, toEnd, success, error) {
        exec(success, error, PLUGIN_NAME, "setProgressRange", [fromStart, toEnd]);
    },
    setProgress: function(progress, success, error) {
        exec(success, error, PLUGIN_NAME, "setProgress", [progress]);
    },
    setBinaryItem: function(binaryItem, success, error) {
        exec(success, error, PLUGIN_NAME, "setBinaryItem", [binaryItem]);
    },
    setScoreItem: function(scoreItem, success, error) {
        exec(success, error, PLUGIN_NAME, "setScoreItem", [scoreItem]);
    },
    setQuantityItem: function(quantityItem, success, error) {
        exec(success, error, PLUGIN_NAME, "setQuantityItem", [quantityItem]);
    }
};

module.exports = CordovaClassKit
