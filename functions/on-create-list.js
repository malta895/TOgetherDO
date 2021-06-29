const functions = require('firebase-functions');

const admin = require('firebase-admin');


exports.setCreatedAt = functions.region('europe-west1').firestore.document('users/{userId}/lists/{listId}').onCreate(
    async (_, context) => {
        const userId = context.params.userId;
        const listId = context.params.listId;

        return admin.firestore().collection('users')
            .doc(userId)
            .collection('lists')
            .doc(listId)
            .set({ createdAt: new Date().toISOString(), databaseId: listId.toString() }, { merge: true })
            .then(() => {
                console.log("Created list " + listId + " by user " + userId);
            })
            .catch((error) => {
                console.error("Error while creating list " + listId + ":", error);
                return null;
            });
    }
);
