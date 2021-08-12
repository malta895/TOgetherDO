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

exports.createNotification = functions.region('europe-west6').firestore.document('users/{userId}/lists/{listId}').onUpdate(
    async (change, context) => {
        //const sender = await admin.firestore().collection('users').doc(context.params.userId).get();
        const oldMembers = change.before.data().members;
        const newMembers = change.after.data().members;
        newMembers.forEach(element => {
            if (!oldMembers.includes(element)) {
                newNotification = {
                    userFrom: context.params.userId,
                    listOwner: context.params.userId,
                    userId: element,
                    notificationType: 'listInvite',
                    status: 'undefined',
                    listId: context.params.listId,
                    databaseId: ''
                };

                admin.firestore().collection('notifications').add(newNotification).then((ok) => console.log(ok)).catch((e) => console.log(e));
            }
        }
        );
    }
);

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