// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');
admin.initializeApp();

exports.friendship = require('./friendship');

exports.list = require('./list');

exports.notification = require('./notification');

exports.getUserByEmail = require('./get-user-by-email');
