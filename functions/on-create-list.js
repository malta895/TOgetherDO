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
            .set({ databaseId: listId.toString() }, { merge: true }) //TODO convert this to timestamp and add it: `createdAt: new Date().toISOString(),`
            .then(() => {
                console.log("Added date to list " + listId);
            })
            .catch((error) => {
                console.error("Error while creating list " + listId + ":", error);
                return null;
            });
    }
);

exports.createNotification = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onCreate(
    async (snapshot, context) => {
        const sender = await admin.firestore().collection('users').doc(context.params.userId).get();
        console.log("Sender" + sender.data().displayName);
        const receivers = snapshot.data().members;
        console.log("snapshot.data" + snapshot.data());
        console.log("first element of receivers" + receivers[0]);
        receivers.forEach(element => {
            newNotification = {
                userFrom: sender.data().databaseId,
                listOwner: context.params.userId,
                userId: element,
                notificationType: 'listInvite',
                status: 'undefined',
                listId: context.params.listId,
                databaseId: ''
            };

            admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
        }
        );
    }
);