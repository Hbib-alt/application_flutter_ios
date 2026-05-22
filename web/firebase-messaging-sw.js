// 🔥 Firebase Messaging Service Worker (WEB)

importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

// ⚠️ CONFIGURATION FIREBASE (copie depuis firebase_options.dart -> web)
firebase.initializeApp({
  apiKey: "AIzaSyA7TB18U9TubUh2qWJ__PXp7sQcQXx_WY8",
  authDomain: "my-clean-app-2e59e.firebaseapp.com",
  projectId: "my-clean-app-2e59e",
  storageBucket: "my-clean-app-2e59e.firebasestorage.app",
  messagingSenderId: "911434825963",
  appId: "1:911434825963:web:63ef21dc1ea7451fa9feae",
  measurementId: "G-2WWG7JZ09E"
});

// 🔔 Init messaging
const messaging = firebase.messaging();

// 🔔 Notification en background
messaging.onBackgroundMessage(function (payload) {
  console.log("📩 Message reçu (background): ", payload);

  const notificationTitle = payload.notification?.title || "Notification";
  const notificationOptions = {
    body: payload.notification?.body || "",
    icon: "/icons/Icon-192.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});