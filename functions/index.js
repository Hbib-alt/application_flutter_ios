const {
  onDocumentUpdated,
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");

const admin = require("firebase-admin");

admin.initializeApp();

// ======================================================
// CASE APPROVED
// ======================================================

exports.onCaseApproved = onDocumentUpdated(
    "cases/{caseId}",

    async (event) => {
      try {
        const before =
        event.data.before.data();

        const after =
        event.data.after.data();

        if (
          before.status ===
          "approved" ||

          after.status !==
          "approved"
        ) {
          return;
        }

        const userId =
        after.userId;

        if (!userId) {
          return;
        }

        const userDoc =
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        const userData =
        userDoc.data();

        if (!userData) {
          return;
        }

        const token =
        userData.fcmToken;

        if (!token) {
          return;
        }

        await admin.messaging().send({

          token: token,

          notification: {

            title:
            "تمت الموافقة على الطلب",

            body:
            `تمت الموافقة على طلب "${after.title}"`,
          },

          data: {

            type: "case",

            caseId:
            event.params.caseId,
          },

          android: {

            priority: "high",

            notification: {

              sound:
              "notification",
            },
          },
        });

        await admin.firestore()
            .collection(
                "notifications",
            )
            .add({

              userId: userId,

              type: "user",

              title:
              "تمت الموافقة على الطلب",

              body:
              `تمت الموافقة على طلب "${after.title}"`,

              createdAt:
              admin.firestore
                  .FieldValue
                  .serverTimestamp(),

              read: false,
            });

        console.log(
            "Notification envoyée",
        );
      } catch (e) {
        console.error(
            "Erreur function:",
            e,
        );
      }
    },
);

// ======================================================
// NEW OPERATION
// ======================================================

exports.onNewOperation = onDocumentCreated(
    "operations/{operationId}",

    async (event) => {
      try {
        const data =
        event.data.data();

        if (!data) return;

        if (
          data.status !==
          "pending"
        ) {
          return;
        }

        const treasurerQuery =
        await admin.firestore()
            .collection("users")
            .where(
                "role",
                "==",
                "treasurer",
            )
            .limit(1)
            .get();

        if (
          treasurerQuery.empty
        ) {
          return;
        }

        const treasurerDoc =
        treasurerQuery.docs[0];

        const treasurerData =
        treasurerDoc.data();

        const token =
        treasurerData.fcmToken;

        if (!token) {
          return;
        }

        await admin.messaging().send({

          token: token,

          notification: {

            title:
            "عملية جديدة",

            body:
            `${data.name} - ${data.amount} أوقية جديدة`,
          },

          android: {

            priority: "high",

            notification: {

              sound:
              "notification",
            },
          },

          data: {

            type: "operation",

            operationId:
            event.params.operationId,
          },
        });

        await admin.firestore()
            .collection(
                "notifications",
            )
            .add({

              userId:
              treasurerDoc.id,

              title:
              "عملية جديدة",

              body:
              `${data.name} - ${data.amount} أوقية جديدة`,

              createdAt:
              admin.firestore
                  .FieldValue
                  .serverTimestamp(),

              read: false,

              type: "operation",

              operationId:
              event.params.operationId,

              createdByName:
              data.name || "",

              createdByRole:
              "collector",
            });

        console.log(
            "Notification operation envoyée",
        );
      } catch (e) {
        console.error(
            "Erreur operation:",
            e,
        );
      }
    },
);

// ======================================================
// OPERATION APPROVED
// ======================================================

exports.onOperationApproved = onDocumentUpdated(
    "operations/{operationId}",

    async (event) => {
      try {
        const before =
        event.data.before.data();

        const after =
        event.data.after.data();

        if (
          before.status ===
          "approved" ||

          after.status !==
          "approved"
        ) {
          return;
        }

        const amount =
        Number(
            after.amount || 0,
        );

        if (amount <= 0) {
          return;
        }

        const financeRef =
        admin.firestore()
            .collection(
                "finance",
            )
            .doc("main");

        await financeRef.update({

          balance:
          admin.firestore
              .FieldValue
              .increment(amount),

          updatedAt:
          admin.firestore
              .FieldValue
              .serverTimestamp(),
        });

        console.log(
            `Balance +${amount}`,
        );

        const userId =
        after.createdBy;

        if (!userId) {
          return;
        }

        const userDoc =
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();

        const userData =
        userDoc.data();

        if (!userData) {
          return;
        }

        const token =
        userData.fcmToken;

        if (!token) {
          return;
        }

        await admin.messaging().send({

          token: token,

          notification: {

            title:
            "تمت الموافقة على العملية",

            body:
            `تمت إضافة ${amount} أوقية جديدة إلى الرصيد`,
          },

          android: {

            priority: "high",

            notification: {

              sound:
              "notification",
            },
          },
        });

        await admin.firestore()
            .collection(
                "notifications",
            )
            .add({

              userId:
              userId,

              title:
              "تمت الموافقة على العملية",

              body:
              `تمت إضافة ${amount} أوقية جديدة إلى الرصيد`,

              createdAt:
              admin.firestore
                  .FieldValue
                  .serverTimestamp(),

              read: false,
            });

        console.log(
            "Balance updated",
        );
      } catch (e) {
        console.error(
            "Erreur balance:",
            e,
        );
      }
    },
);

// ======================================================
// NEW TRANSACTION
// ======================================================

exports.onNewTransaction = onDocumentCreated(
    "transactions/{transactionId}",

    async (event) => {
      try {
        const data =
        event.data.data();

        if (!data) {
          return;
        }

        if (
          data.paidByRole !==
          "treasurer"
        ) {
          return;
        }

        const committeeQuery =
        await admin.firestore()
            .collection("users")
            .where(
                "role",
                "==",
                "committee",
            )
            .get();

        if (
          committeeQuery.empty
        ) {
          return;
        }

        for (
          const doc
          of committeeQuery.docs
        ) {
          const userData =
          doc.data();

          const token =
          userData.fcmToken;

          if (!token) {
            continue;
          }

          // ================= MESSAGE =================

          const messageBody =

`تم دفع ${data.amount} أوقية جديدة لصالح ${data.beneficiaryName || ""}

الهاتف: ${data.beneficiaryPhone || ""}

الغرض:
${data.note || "غير محدد"}`;

          // ================= PUSH =================

          await admin.messaging().send({

            token: token,

            notification: {

              title:
              "تم تنفيذ عملية دفع",

              body:
              messageBody,
            },

            android: {

              priority: "high",

              notification: {

                sound:
                "notification",
              },
            },

            data: {

              type:
              "transaction",

              transactionId:
              event.params.transactionId,
            },
          });

          // ================= FIRESTORE =================

          await admin.firestore()
              .collection(
                  "notifications",
              )
              .add({

                userId:
                doc.id,

                title:
                "تم تنفيذ عملية دفع",

                body:
                messageBody,

                createdAt:
                admin.firestore
                    .FieldValue
                    .serverTimestamp(),

                read: false,
              });
        }

        console.log(
            "Committee notified",
        );
      } catch (e) {
        console.error(
            "Erreur transaction:",
            e,
        );
      }
    },
);
