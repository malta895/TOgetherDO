const functions = require('firebase-functions');
// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');

// Sends a notifications to all users when a new message is posted.
exports.createNotifications = functions.region('europe-west6').firestore.document('friendships/{requestId}').onCreate(
    async (snapshot, context) => {
        console.log(snapshot.data().userFrom);
        console.log(snapshot.data().userTo);
        // Notification details.
        const sender = await admin.firestore().collection('users').doc(snapshot.data().userFrom).get();
        const receiver = await admin.firestore().collection('users').doc(snapshot.data().userTo).get();
        const newNotification = {
            userFrom: sender.data().databaseId,
            userId: receiver.data().databaseId,
            notificationType: 'friendship',
            status: 'undefined',
            friendshipId: context.params.requestId,
            databaseId: ''
        };

        admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
    });

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