const functions = require('firebase-functions');

const admin = require('firebase-admin');

// gets an user by email from firebase
exports.getUserByEmail = functions.region('europe-west6').https.onCall(async (data, context) =>  {

const email = data.email;

let user = await admin.auth().getUserByEmail(email);

let listAppUser = await admin.firestore().collection('users').doc(user.uid).get();

return listAppUser;

});
