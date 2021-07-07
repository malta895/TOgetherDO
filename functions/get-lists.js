const functions = require('firebase-functions');

const admin = require('firebase-admin');

// gets all the lists the user has access to
exports.getListsByUser = functions.region('europe-west6').https.onCall(async (data, context) =>  {
    let userUid;

    if(context.auth){
        userUid = context.auth.uid;
    } else {
        return [];
    }

    // the lists created by the current user
    let createdLists = await admin.firestore().collection('users')
        .doc(userUid)
        .collection('lists')
        .get();

    createdListsReturn = createdLists.docs.map((doc) => doc.data());

    let participantLists = await admin.firestore().collectionGroup('lists')
        .where('members', 'array-contains', userUid)
        .get()

    participantListsReturn = participantLists.docs.map((doc) => doc.data());

    return createdListsReturn.concat(participantListsReturn);
    
});
