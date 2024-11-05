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
import { Database, GetElementValue, IsNullOrEmpty, AdminIMEI } from "./main.js";

document.getElementById("imei-form").addEventListener("submit", async (e) => {
    e.preventDefault();

    const name = GetElementValue("name") ?? "";
    const imei = GetElementValue("imei") ?? "";
    if (IsNullOrEmpty(name) || IsNullOrEmpty(imei)) {
        ShowNotification("Please fill up all the required data", Colors.Red);
        return;
    }
    ShowLoading();
    await addDoc(collection(Database, "imei"), {
        'name': name,
        'imeiNumber': imei,
    });
    HideLoading();
    ShowNotification("You just created a new IMEI number", Colors.Green);
    document.getElementById("imei-form").reset();
    document.querySelector('.modal-close').click();
    document.getElementById("table-body").innerHTML = "";
    await AdminIMEI();
    HideLoading();
});

const table = document.getElementById("myTable");
table.addEventListener("click", async (event) => {
    if (event.target && event.target.matches(".Button-Red-Icon")) {
        const row = event.target.closest("tr");

        const hiddenInput = row.querySelector("input[type='hidden']");
        const id = hiddenInput.value;
        var result = await ShowPopup('Are you sure you want to delete?', PopupType.Prompt);
        if (result) {
            await deleteDoc(doc(Database, "imei", id));
            row.remove();
            ShowNotification('Deleted Successfully', Colors.Green);
        }
    }
});

document.getElementById("SearchButton").addEventListener("click", async (e) => {
    e.preventDefault();
    ShowLoading();
    document.getElementById("table-body").innerHTML = "";
    await AdminIMEI(document.getElementById("ContentSearch").value);
    HideLoading();
});