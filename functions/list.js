const functions = require('firebase-functions');

const admin = require('firebase-admin');



exports.acceptInvite = functions.region('europe-west6').firestore.document('notifications/{notificationId}').onUpdate(
    async (change, context) => {
        if (change.after.data().notificationType === "listInvite") {
            const accepted = change.after.data().status;
            let uid = change.after.data().userToId;

            let list = await admin.firestore().collection('users').doc(change.after.data().listOwnerId).collection('lists').doc(change.after.data().listId).get();

            console.log(list.data().members);
            let members = list.data().members;
            console.log(typeof (members));

            if (accepted === "accepted") {
                members[uid] = true;


                admin.firestore().collection('users').doc(change.after.data().listOwnerId).collection('lists').doc(change.after.data().listId).set({ members: members }, { merge: true });

            } else if (accepted === "rejected") {
                delete members[uid];

                console.log(members);

                admin.firestore().collection('users').doc(change.after.data().listOwnerId).collection('lists').doc(change.after.data().listId).update({ members: members }, { merge: true });
            }
        }
    }
)

exports.deleteSentNotifications = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onDelete(
    async (snapshot, context) => {
        /* list = snapshot.data().members;

        list.forEach(async (member) => {
            console.log("Sto servendo l'user " + member);
            admin.firestore().collection('notifications').where('listId', '==', context.params.listId).delete().then((ok) => console.log("fatto con l'user " + member)).catch((e) => console.log(e));
        }); */

        let query = admin.firestore().collection('notifications').where('listId', '==', String(context.params.listId));

        query.get().then(querySnapshot => {
            querySnapshot.forEach(documentSnapshot => {
                documentSnapshot.ref.delete();
            });
        });
    });