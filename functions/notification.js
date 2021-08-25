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
        admin.firestore().collection('notifications').doc(context.params.notificationId).set({ databaseId: context.params.notificationId.toString() }, { merge: true }).then(() => {
            console.log("Added databaseId to notification " + context.params.notificationId);
        })
            .catch((error) => {
                console.error("Error while creating databaseId for notification " + context.params.notificationId + ":", error);
                return null;
            });

        // Notification details.
        const sender = await admin.firestore().collection('users').doc(snapshot.data().userFrom).get();
        const receiver = await admin.firestore().collection('users').doc(snapshot.data().userId).get();

        const tokens = receiver.data().notificationTokens;
        tokens.forEach((token) => {
            let message;
        if (snapshot.data().notificationType === "friendship") {
            message = {
                'notification': {
                    'title': `${sender.data().displayName} sent you a friendship request!`,
                    'body': `Accept or decline it, ${receiver.data().username}!`,
                },
                'data': {
                    'sender': snapshot.data().userFrom,
                    'receiver': snapshot.data().userId,
                    'click_action': `FLUTTER_NOTIFICATION_CLICK`,
                }
            };
        } else if (snapshot.data().notificationType === "listInvite") {
            message = {
                'notification': {
                    'title': `${sender.data().displayName} added you to a list!`,
                    'body': `Accept or decline the invitation, ${receiver.data().username}!`,
                },
                'data': {
                    'sender': snapshot.data().userFrom,
                    'receiver': snapshot.data().userId,
                    'click_action': `FLUTTER_NOTIFICATION_CLICK`,
                }
            };
        }

            admin.messaging().sendToDevice(token, message).then((response) => {
                 console.log(response);
            }).catch((error) => {
               console.log(error);
            });
        });

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

/*exports.sendNotificationHTTPS = functions.region('europe-west6').https.onRequest(async (req, res) => {
    const msg = req.query.text;
    const user = await admin.firestore().collection('users').doc('9LUBLCszUrU4mukuRWhHFS2iexL2').get();
    res.json({ result: `Inspecting user with name ${user.displayName}` });
})*/

/*exports.addMessage = functions.region('europe-west6').https.onRequest(async (req, res) => {
    // Grab the text parameter.
    const original = req.query.text;
    const allTokens = await admin.firestore().collection('users').doc("9LUBLCszUrU4mukuRWhHFS2iexL2").get();
    // Push the new message into Firestore using the Firebase Admin SDK.
    const writeResult = await admin.firestore().collection('messages').add({ original: original });
    console.log("DATA FROM DB");
    console.log(allTokens.data());
    let collectionRef = admin.firestore().collection('users');
    console.log(`Path of the subcollection: ${collectionRef.path}`);
    let documentRefWithName = collectionRef.doc('QStCBloQCnemUewGdcPBibJzvLH2');
    console.log(`Reference with name: ${documentRefWithName.path}`);
    let documentRef = admin.firestore().doc('users/QStCBloQCnemUewGdcPBibJzvLH2');

    await documentRef.get().then((documentSnapshot) => {
        if (documentSnapshot.exists) {
            console.log(`Data: ${JSON.stringify(documentSnapshot.data())}`);
        } else {
            console.log("NON ESISTE AWAIT 2");
        }
    });

    const allUsers = await admin.firestore().collection('users').get();
    const users = [];
    allUsers.forEach((user) => {
        users.push(user.id);
        console.log(user.id)
    });
    admin.firestore().collection('users').doc('QStCBloQCnemUewGdcPBibJzvLH2').get().then(queryResult => { return console.log(queryResult.data().id) });
    //allTokens.forEach(token => console.log(token));
    // Send back a message that we've successfully written the message
    res.json({ result: `Message with ID: ${writeResult.id} added.` });
});*/
/* // // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.region('europe-west6').https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original
exports.addMessage = functions.region('europe-west6').https.onRequest(async (req, res) => {
    // Grab the text parameter.
    const original = req.query.text;
    // Push the new message into Firestore using the Firebase Admin SDK.
    const writeResult = await admin.firestore().collection('messages').add({ original: original });
    // Send back a message that we've successfully written the message
    res.json({ result: `Message with ID: ${writeResult.id} added.` });
});

// Listens for new messages added to /messages/:documentId/original and creates an
// uppercase version of the message to /messages/:documentId/uppercase
exports.makeUppercase = functions.region('europe-west6').firestore.document('/messages/{documentId}')
    .onCreate((snap, context) => {
        // Grab the current value of what was written to Firestore.
        const original = snap.data().original;

        // Access the parameter `{documentId}` with `context.params`
        functions.logger.log('Uppercasing', context.params.documentId, original);

        const uppercase = original.toUpperCase();

        // You must return a Promise when performing asynchronous tasks inside a Functions such as
        // writing to Firestore.
        // Setting an 'uppercase' field in Firestore document returns a Promise.
        return snap.ref.set({ uppercase }, { merge: true });
    }); */
