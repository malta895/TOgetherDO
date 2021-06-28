const functions = require('firebase-functions');

const admin = require('firebase-admin');


exports.onListCreated = functions.firestore.document('lists/{listId}').onCreate(
    async (snapshot, context) => {
        const listId = snapshot.id;
        const userId = context.auth.uid;

        return admin.firestore().collection('lists')
            .doc(listId)
            .set({ userCreator: userId }, { merge: true })
            .then(() => {
                console.log("Created list " + listId + " by user " + userId);
            })
            .catch((error) => {
                console.error("Error while creating list " + listId + ":", error);
                return null;
            });
    }
);
