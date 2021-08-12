const functions = require('firebase-functions');

const admin = require('firebase-admin');
// const { error } = require('firebase-functions/lib/logger');

// gets an user by email from firebase
exports.getUserByEmail = functions.region('europe-west6').https.onCall(async (data, context) =>  {

const email = data.email;


    try{
        let user = await admin.auth().getUserByEmail(email);
        let listAppUser = await admin.firestore().collection('users').doc(user.uid).get();
        console.log(listAppUser);
        return listAppUser.data();
    }catch(error){
        console.log(error)
        return null;
    }






});
