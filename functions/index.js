// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');
admin.initializeApp();


exports.onCreateList = require('./on-create-list');

exports.onUpdateList = require('./on-update-list');

exports.onDeleteList = require('./on-delete-list');

exports.onCreateFriendship = require('./on-create-friendship');

exports.onDeleteFriendship = require('./on-create-friendship');

exports.onCreateNotification = require('./on-create-notification');

exports.getListsByUser = require('./get-lists');
