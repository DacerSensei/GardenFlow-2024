import {
    initializeApp
} from "https://www.gstatic.com/firebasejs/10.5.2/firebase-app.js";
import {
    getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, sendPasswordResetEmail, onAuthStateChanged, signOut, updatePassword
} from "https://www.gstatic.com/firebasejs/10.5.2/firebase-auth.js";
import {
    getDatabase, ref, set, onValue, get, child
} from "https://www.gstatic.com/firebasejs/10.5.2/firebase-database.js";
import {
    getFirestore, collection, addDoc, updateDoc, getDocs, deleteDoc, query, where, doc, getDoc, setDoc
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";
import { Database, GetElementValue, Auth, IsNullOrEmpty, AdminIMEI } from "./main.js";



document.getElementById("forgot-password-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const email = GetElementValue("email") ?? ""
    if (email == "") {
        ShowNotification("Email cannot be empty", Colors.Red);
        return;
    }
    ShowLoading();
    let q = query(collection(Database, "users"), where("email", "==", email));
    const emailSnapshot = await getDocs(q);
    if (emailSnapshot.size >= 1) {
        sendPasswordResetEmail(Auth, email)
            .then(() => {
                ShowNotification("Please check your email for password recovery", Colors.Green);
                window.location.href = "/index.html"
            })
            .catch((error) => {
                const errorCode = error.code;
                const errorMessage = error.message;
                ShowNotification("Something went wrong", Colors.Red);
            });
        HideLoading();
    } else {
        ShowNotification("Your email doesn't exist", Colors.Red);
    }
});
