const functions = require('firebase-functions');
// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');


exports.addFriendAfterAccepted = functions.region('europe-west6').firestore.document('notifications/{requestId}').onUpdate(
    async (change, context) => {
        console.log(change);
        const after = change.after.data();
        const before = change.before.data();

        if(before.notificationType !== 'friendship') return;

        const requestAccepted = after.status === "accepted" && before.status !== after.status;
        const userFrom = after.userFrom;
        const userTo = after.userId;


        console.log("requestAccepted:");
        console.log(requestAccepted);
        console.log(after.status);
        console.log(before.status !== after.status);

        if (requestAccepted === true) {

            const userFromRef = admin.firestore().collection('users').doc(userFrom);

            const userFromDoc = await userFromRef.get();
            
            let userFromFriends  = userFromDoc.data().friends;
            userFromFriends[userTo] = true;


            await userFromRef.update({
                friends: userFromFriends
            });

            const userToRef = admin.firestore().collection('users').doc(userTo);

            const userToDoc = await userToRef.get();
            const userToFriends = userToDoc.data().friends;

            userToFriends[userFrom] = true;
            await userToRef.update({
                friends: userToFriends
            });
        }

    });

exports.removeFriendAfterDeleted = functions.region('europe-west6').firestore.document('friendships/{requestId}').onDelete(
    async (snapshot, context) => {
        console.log(snapshot);
        const deletedFriendship = snapshot.data();
        const userFrom = deletedFriendship.userFrom;
        const userTo = deletedFriendship.userTo;


        const userFromRef = admin.firestore().collection('users').doc(userFrom);

        const userFromDoc = await userFromRef.get();

        const userFromFriends = userFromDoc.data().friends.filter(e => e !== userTo);


        await userFromRef.update({
            friends: userFromFriends
        });

        const userToRef = admin.firestore().collection('users').doc(userTo);

        const userToDoc = await userToRef.get();
        const userToFriends = userToDoc.data().friends.filter(e => e !== userFrom);

        await userToRef.update({
            friends: userToFriends
        });


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
