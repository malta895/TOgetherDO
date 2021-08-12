const functions = require('firebase-functions');
// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');

// Sends a notifications to the user that receives the friend request
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


exports.addFriendAfterAccepted = functions.region('europe-west6').firestore.document('friendships/{requestId}').onUpdate(
    async (change, context) => {
        console.log(change);
        const after = change.after.data();
        const before = change.before.data();

        const requestAccepted = after.requestAccepted == true && before.requestAccepted != after.requestAccepted;
        const userFrom = after.userFrom;
        const userTo = after.userTo;


        console.log("requestAccepted:");
        console.log(requestAccepted);
        console.log(after.requestAccepted);
        console.log(before.requestAccepted !== after.requestAccepted);

        if (requestAccepted == true) {

            const userFromRef = admin.firestore().collection('users').doc(userFrom);

            const userFromDoc = await userFromRef.get();
            
            const userFromFriends  = userFromDoc.data().friends;
            userFromFriends.push(userTo);

            await userFromRef.update({
                friends: userFromFriends
            });

            const userToRef = admin.firestore().collection('users').doc(userTo);

            const userToDoc = await userToRef.get();
            const userToFriends  = userToDoc.data().friends;

            userToFriends.push(userFrom)
            await userToRef.update({
                friends: userToFriends
            });
        }

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
