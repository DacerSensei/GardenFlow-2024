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
import { Database, GetElementValue, SetContentByQuerySelector, Auth, IsNullOrEmpty, SetValueById } from "./main.js";

document.getElementById("update-information-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const key = GetElementValue('hidden-key');
    const firstName = GetElementValue('first-name');
    const lastName = GetElementValue('last-name');
    const mobileNumber = GetElementValue('mobile-number');

    ShowLoading();

    await setDoc(doc(Database, "users", key), {
        'first-name': firstName,
        'last-name': lastName,
        'mobile-number': mobileNumber
    }, { merge: true });

    const docSnap = await getDoc(doc(Database, "users", key))
    if (docSnap.exists()) {
        const user = docSnap.data();
        if (user.type.toLowerCase() == "admin") {
            const userData = user;
            userData.isAdmin = true;
            userData.isStaff = false;
            userData.name = user["first-name"] + " " + user["last-name"]
            localStorage.setItem('userData', JSON.stringify(userData));
        } else if (user.type.toLowerCase() == "staff") {
            const userData = user;
            userData.isAdmin = false;
            userData.isStaff = true;
            userData.name = user["first-name"] + " " + user["last-name"]
            localStorage.setItem('userData', JSON.stringify(userData));
        }
    }

    SetContentByQuerySelector(".user-profile-name", firstName + " " + lastName);
    HideLoading();
    ShowNotification("Save successfully", Colors.Green);

});