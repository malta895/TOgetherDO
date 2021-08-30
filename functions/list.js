const functions = require('firebase-functions');

const admin = require('firebase-admin');


exports.createNotification = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onCreate(
    async (snapshot, context) => {
        //const sender = await admin.firestore().collection('users').doc(context.params.userId).get();
        //console.log("Sender" + sender.data().displayName);
        const receivers = snapshot.data().members;
        //console.log("snapshot.data" + snapshot.data());
        //console.log("first element of receivers" + receivers[0]);
        for (const [key, value] of Object.entries(receivers)) {
            console.log(`${key} ${value}`);
            let newNotification = {
                userFromId: context.params.userId,
                listOwnerId: context.params.userId,
                userToId: key,
                notificationType: 'listInvite',
                status: 'pending',
                listId: context.params.listId,
                readStatus: "unread",
                databaseId: '',
            };
            admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
        }

    }
);

exports.updateNotification = functisons.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onUpdate(
    async (change, context) => {
        //const sender = await admin.firestore().collection('users').doc(context.params.userId).get();
        const oldMembers = change.before.data().members;
        const newMembers = change.after.data().members;

        for (const [userId, value] of Object.entries(newMembers)) {
            console.log(`${userId} ${value}`);
            if (!oldMembers.hasOwnProperty(userId)) {
                let newNotification = {
                    userFromId: context.params.userId,
                    listOwnerId: context.params.userId,
                    userToId: userId,
                    notificationType: 'listInvite',
                    status: 'pending',
                    readStatus: "unread",
                    listId: context.params.listId,
                    databaseId: '',
                };
                admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
            }
        }
    }
);

exports.acceptInvite = functions.region('europe-west6').firestore.document('notifications/{notificationId}').onUpdate(
    async (change, context) => {
        if (change.after.data().notificationType === "listInvite") {
            const accepted = change.after.data().status;
            uid = change.after.data().userToId;

            list = await admin.firestore().collection('users').doc(change.after.data().listOwnerId).collection('lists').doc(change.after.data().listId).get();

            console.log(list.data().members);
            members = list.data().members;
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