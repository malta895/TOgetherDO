const functions = require('firebase-functions');

const admin = require('firebase-admin');


exports.deleteSentNotifications = functions.region('europe-west6').firestore.document('friendships/{friendshipId}').onDelete(
    async (snapshot, context) => {
        /* list = snapshot.data().members;

        list.forEach(async (member) => {
            console.log("Sto servendo l'user " + member);
            admin.firestore().collection('notifications').where('listId', '==', context.params.listId).delete().then((ok) => console.log("fatto con l'user " + member)).catch((e) => console.log(e));
        }); */

        let query = admin.firestore().collection('notifications').where('friendshipId', '==', String(context.params.friendshipId));

        query.get().then(querySnapshot => {
            querySnapshot.forEach(documentSnapshot => {
                documentSnapshot.ref.delete();
            });
        });
    });