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

document.getElementById("change-password-form").addEventListener("submit", (e) => {
    e.preventDefault();
    // const oldPassword = GetElementValue('old-password');
    const password = GetElementValue('password');
    const conpassword = GetElementValue('confirm-password');
    if (password != conpassword) {
        ShowNotification("Your password and confirm password didn't match", Colors.Red);
        return;
    }
    ShowLoading();
    updatePassword(Auth.currentUser, password).then(() => {
        HideLoading();
        ShowNotification("Password has been changed successfully", Colors.Green);
    }).catch((error) => {
        console.log(error.message);
        HideLoading();
        ShowNotification("Something went wrong", Colors.Red);
    });
    document.getElementById("change-password-form").reset();

});