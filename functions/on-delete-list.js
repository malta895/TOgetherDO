const functions = require('firebase-functions');

const admin = require('firebase-admin');


exports.deleteSentNotifications = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onDelete(
    async (snapshot, context) => {
        const userId = context.params.userId;
        const listId = context.params.listId;

        list = snapshot.data().members;

        list.forEach(async (member) => {
            console.log("Sto servendo l'user " + member);
            admin.firestore().collection('notifications').where('listId', '==', context.params.listId).delete().then((ok) => console.log("fatto con l'user " + member)).catch((e) => console.log(e));
        });

        return true;
    }
);