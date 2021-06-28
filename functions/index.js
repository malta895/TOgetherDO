// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');
admin.initializeApp();


exports.onCreateList = require('./on-create-list');

exports.notifications = require('./notifications');
