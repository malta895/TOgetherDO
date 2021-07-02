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
            objectId: context.params.requestId,
            databaseId: ''
        };

        admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
    });