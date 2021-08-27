const functions = require('firebase-functions');
// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');


exports.setCreatedAt = functions.region('europe-west6').firestore.document('notifications/{notificationId}').onCreate(
    async (_, context) => {
        const notificationId = context.params.notificationId;

        return admin.firestore().collection('notifications')
            .doc(notificationId)
            .set({ createdAt: Date.now() }, { merge: true }) //TODO convert this to timestamp and add it: `createdAt: new Date().toISOString(),`
            .then(() => {
                console.log("Added date to notification " + notificationId);
            })
            .catch((error) => {
                console.error("Error while creating notification " + notificationId + ":", error);
                return null;
            });
    }
);

// Sends a notifications to all users when a new message is posted.
exports.sendNotifications = functions.region('europe-west6').firestore.document('notifications/{notificationId}').onCreate(
    async (snapshot, context) => {
        const notificationId = context.params.notificationId;
        const notification = snapshot.data();


        await admin.firestore().collection('notifications').doc(context.params.notificationId).set({ databaseId: context.params.notificationId.toString() }, { merge: true });

        console.log("Added databaseId to notification " + context.params.notificationId);

        // Notification details.
        const userFromId = await admin.firestore().collection('users').doc(notification.userFromId).get();
        const userToId = await admin.firestore().collection('users').doc(notification.userToId).get();

        const tokens = userToId.data().notificationTokens;
        for (const token of tokens) {
            let message;
        if (notification.notificationType === "friendship") {
            message = {
                'notification': {
                    'title': `${userFromId.data().displayName} sent you a friendship request!`,
                    'body': `Tap here to accept or decline!`,
                },
                'data': {
                    'notificationId': notificationId,
                    'click_action': `FLUTTER_NOTIFICATION_CLICK`,
                }
            };
        } else if (notification.notificationType === "listInvite") {
            message = {
                'notification': {
                    'title': `${userFromId.data().displayName} added you to a list!`,
                    'body': `Tap here to accept or decline!`,
                },
                'data': {
                    'notificationId': notificationId,
                    'click_action': `FLUTTER_NOTIFICATION_CLICK`,
                }
            };
        }

        try{
            await admin.messaging().sendToDevice(token, message);
        } catch(e){
            console.log(e);
        }

        }

    });
//Cleans up the tokens that are no longer valid.
function cleanupTokens(response, tokens) {
    // For each notification we check if there was an error.
    const tokensDelete = [];
    response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
            console.error('Failure sending notification to', tokens[index], error);
            // Cleanup the tokens who are not registered anymore.
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                const deleteTask = admin.firestore().collection('fcmTokens').doc(tokens[index]).delete();
                tokensDelete.push(deleteTask);
            }
        }
    });
    return Promise.all(tokensDelete);
}