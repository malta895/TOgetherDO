const functions = require('firebase-functions');

const admin = require('firebase-admin');

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