const functions = require('firebase-functions');

const admin = require('firebase-admin');


exports.setCreatedAt = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onCreate(
    async (_, context) => {
        const userId = context.params.userId;
        const listId = context.params.listId;

        return admin.firestore().collection('users')
            .doc(userId)
            .collection('lists')
            .doc(listId)
            .set({ createdAt: new Date().toISOString() }, { merge: true })
            .then(() => {
                console.log("Added date to list " + listId);
            })
            .catch((error) => {
                console.error("Error while creating list " + listId + ":", error);
                return null;
            });
    }
);
