importScripts(
  'https://www.gstatic.com/firebasejs/11.9.1/firebase-app-compat.js',
  'https://www.gstatic.com/firebasejs/11.9.1/firebase-messaging-compat.js',
  './firebase-messaging-config.js'
);

if (self.parsetaFirebaseConfig) {
  firebase.initializeApp(self.parsetaFirebaseConfig);
  firebase.messaging();
}
