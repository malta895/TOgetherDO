const functions = require('firebase-functions');

const admin = require('firebase-admin');

exports.setAdminAsMember = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onCreate(
    async (snapshot, context) => {
        return admin.firestore().collection('users')
            .doc(context.params.userId)
            .collection('lists')
            .doc(context.params.listId)
            .members
            .add(context.params.userId)
            .then(() => {
                console.log("Added admin as a member");
            })
            .catch((error) => {
                console.error("Error while adding admin as member");
                return null;
            });
    })

exports.createNotification = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onCreate(
    async (snapshot, context) => {
        const sender = await admin.firestore().collection('users').doc(context.params.userId).get();
        //console.log("Sender" + sender.data().displayName);
        const receivers = snapshot.data().members;
        //console.log("snapshot.data" + snapshot.data());
        //console.log("first element of receivers" + receivers[0]);
        for (const [key, value] of Object.entries(receivers)) {
            console.log(`${key} ${value}`);
            let newNotification = {
                userFrom: context.params.userId,
                listOwner: context.params.userId,
                userId: key,
                notificationType: 'listInvite',
                status: 'pending',
                listId: context.params.listId,
                databaseId: ''
            };
            admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
        }

        /*receivers.forEach(element => {
            let newNotification = {
                userFrom: sender.data().databaseId,
                listOwner: context.params.userId,
                userId: element,
                notificationType: 'listInvite',
                status: 'pending',
                listId: context.params.listId,
                databaseId: ''
            };

            admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
        }
        );*/
    }
);

exports.updateNotification = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onUpdate(
    async (change, context) => {
        //const sender = await admin.firestore().collection('users').doc(context.params.userId).get();
        const oldMembers = change.before.data().members;
        const newMembers = change.after.data().members;

        for (const [key, value] of Object.entries(newMembers)) {
            console.log(`${key} ${value}`);
            if (!oldMembers.hasOwnProperty(key)) {
                let newNotification = {
                    userFrom: context.params.userId,
                    listOwner: context.params.userId,
                    userId: key,
                    notificationType: 'listInvite',
                    status: 'pending',
                    listId: context.params.listId,
                    databaseId: ''
                };
                admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
            }
        }
    }
);

exports.acceptInvite = functions.region('europe-west6').firestore.document('notifications/{notificationId}').onUpdate(
    async (change, context) => {
        if (change.after.data().notificationType == "listInvite") {
            const accepted = change.after.data().status;
            uid = change.after.data().userId;

            list = await admin.firestore().collection('users').doc(change.after.data().listOwner).collection('lists').doc(change.after.data().listId).get();

            console.log(list.data().members);
            members = list.data().members;
            console.log(typeof (members));

            if (accepted == "accepted") {
                members[uid] = true;

                admin.firestore().collection('users').doc(change.after.data().listOwner).collection('lists').doc(change.after.data().listId).set({ members: members }, { merge: true });

            } else {
                delete members[uid];

                console.log(members);

                admin.firestore().collection('users').doc(change.after.data().listOwner).collection('lists').doc(change.after.data().listId).update({ members: members }, { merge: true });
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