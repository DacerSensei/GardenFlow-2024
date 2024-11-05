import {
    initializeApp
} from "https://www.gstatic.com/firebasejs/10.5.2/firebase-app.js";
import {
    getAuth, createUserWithEmailAndPassword, signOut
} from "https://www.gstatic.com/firebasejs/10.5.2/firebase-auth.js";
import {
    getDatabase, ref, set, onValue, get, child
} from "https://www.gstatic.com/firebasejs/10.5.2/firebase-database.js";
import {
    getFirestore, collection, addDoc, updateDoc, getDocs, deleteDoc, query, where, doc, getDoc, setDoc
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";
import { Database, GetElementValue, IsNullOrEmpty, AdminUserRequest } from "./main.js";

const table = document.getElementById("myTable");
table.addEventListener("click", async (event) => {
    if (event.target && event.target.matches(".Button-Red-Icon")) {
        const row = event.target.closest("tr");

        const hiddenInput = row.querySelector("input[type='hidden']");
        const id = hiddenInput.value;
        var result = await ShowPopup('Are you sure you want to reject?', PopupType.Prompt);
        if (result) {
            await setDoc(doc(Database, "users", id), { status: "rejected" }, { merge: true });
            row.remove();
            ShowNotification('Rejected Successfully', Colors.Green);
        }
    }
    if (event.target && event.target.matches(".Button-Green-Icon")) {
        const row = event.target.closest("tr");

        const hiddenInput = row.querySelector("input[type='hidden']");
        const id = hiddenInput.value;
        var result = await ShowPopup('Are you sure you want to accept?', PopupType.Prompt);
        if (result) {
            await setDoc(doc(Database, "users", id), { status: "active" }, { merge: true });
            row.remove();
            ShowNotification('Accepted Successfully', Colors.Green);
        }
    }
});

document.getElementById("SearchButton").addEventListener("click", async (e) => {
    e.preventDefault();
    ShowLoading();
    document.getElementById("table-body").innerHTML = "";
    await AdminUserRequest(document.getElementById("ContentSearch").value);
    HideLoading();
});