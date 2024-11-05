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
import { Database, GetElementValue, FirebaseConfig, IsNullOrEmpty, AdminUserInformation, getHTTPResponseNoForm  } from "./main.js";

const SecondaryApp = initializeApp(FirebaseConfig, "SecondaryApp");
const SecondaryAuth = getAuth(SecondaryApp);

let isUpdating = false;
let hiddenKey = null;
let currentUser;

document.getElementById("CreateData").addEventListener("click", () => {
    isUpdating = false;
    document.getElementById("CreateAccountButton").innerHTML = "Create Account";
    document.getElementById("user-form").querySelector("section").children[1].textContent = "Create a new user"
    document.getElementById("user-form").querySelector("section").children[4].style.display = "flex";
    document.getElementById("user-form").querySelector("section").children[5].style.display = "flex";
    document.getElementById("user-form").querySelector("section").children[6].style.display = "flex";
    document.getElementById("user-form").querySelector("section").children[7].querySelector("input").disabled = false;
});

document.getElementById("user-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const roleElement = document.getElementById("role");

    const firstName = GetElementValue("first-name") ?? "";
    const lastName = GetElementValue("last-name") ?? "";
    const email = GetElementValue("email") ?? "";
    const password = GetElementValue("password") ?? "";
    const mobileNumber = GetElementValue("contact-no") ?? "";
    const role = (roleElement === null) ? "None" : roleElement.Value;
    if (isUpdating == false) {
        if (IsNullOrEmpty(firstName) || IsNullOrEmpty(lastName) || IsNullOrEmpty(email) || IsNullOrEmpty(password) || IsNullOrEmpty(mobileNumber) || role == "None") {
            ShowNotification("Please fill up all the required data", Colors.Red);
            return;
        }
        const conpassword = GetElementValue('confirm-password');
        if (password != conpassword) {
            ShowNotification("Your password and confirm password didn't match", Colors.Red);
            return;
        }
    }else {
        if (IsNullOrEmpty(firstName) || IsNullOrEmpty(lastName) || IsNullOrEmpty(email) || IsNullOrEmpty(mobileNumber)) {
            ShowNotification("Please fill up all the required data", Colors.Red);
            return;
        }
    }
    ShowLoading();
    if (isUpdating == false) {
        await createUserWithEmailAndPassword(SecondaryAuth, email, password).then(async (userCredential) => {
            await addDoc(collection(Database, "users"), {
                'email': email,
                'first-name': firstName,
                'last-name': lastName,
                'mobile-number': mobileNumber,
                'type': role,
                'uuid': userCredential.user.uid,
                'status': "active"
            });
            signOut(SecondaryAuth).then(() => {
            }).catch((error) => {
                console.log(error.message);
            });
            var result = await getHTTPResponseNoForm("../php/SendEmail.php?email=" + email + "&password=" + password);
        }).catch((error) => {
            HideLoading();
            if (error.code == "auth/email-already-in-use") {
                ShowPopup("Email already in use");
            } else if (error.code == "auth/invalid-email") {
                ShowPopup("Invalid Email");
            } else if (error.code == "auth/weak-password") {
                ShowPopup("Your password is too weak");
            } else {
                ShowPopup(error.message);
            }
            return;
        });
        ShowNotification("You just created a new account", Colors.Green);
    } else if (isUpdating == true) {
        if (hiddenKey != null) {
            await setDoc(doc(Database, "users", hiddenKey), {
                'first-name': firstName,
                'last-name': lastName,
                'mobile-number': mobileNumber
            }, { merge: true });
            hiddenKey = null;
        }
        ShowNotification("You just updated an account", Colors.Green);
    }

    document.getElementById("user-form").reset();
    document.querySelector('.modal-close').click();
    roleElement.SelectedItem = roleElement.Items[0];
    document.getElementById("table-body").innerHTML = "";
    await AdminUserInformation();
    HideLoading();
});

const table = document.getElementById("myTable");
table.addEventListener("click", async (event) => {
    if (event.target && event.target.matches(".Button-Blue-Icon")) {
        isUpdating = true;

        document.getElementById("CreateAccountButton").innerHTML = "Update Account";
        document.getElementById("user-form").querySelector("section").children[1].textContent = "Update user"

        const row = event.target.closest("tr");
        const hiddenInput = row.querySelector("input[type='hidden']");
        const id = hiddenInput.value;
        hiddenKey = hiddenInput.value;

        try {
            const docSnap = await getDoc(doc(Database, "users", id))
            if (docSnap.exists()) {
                const data = docSnap.data();
                document.getElementById("user-form").querySelector("section").children[2].querySelector("input").value = data["first-name"];
                document.getElementById("user-form").querySelector("section").children[3].querySelector("input").value = data["last-name"];
                document.getElementById("user-form").querySelector("section").children[7].querySelector("input").value = data["email"];
                document.getElementById("user-form").querySelector("section").children[7].querySelector("input").disabled = true;
                document.getElementById("user-form").querySelector("section").children[8].querySelector("input").value = data["mobile-number"];
                document.getElementById("user-form").querySelector("section").children[4].style.display = "none";
                document.getElementById("user-form").querySelector("section").children[5].style.display = "none";
                document.getElementById("user-form").querySelector("section").children[6].style.display = "none";
            }
        } catch (error) {
            console.log(error);
        }
    }
});

document.getElementById("SearchButton").addEventListener("click", async (e) => {
    e.preventDefault();
    ShowLoading();
    document.getElementById("table-body").innerHTML = "";
    await AdminUserInformation(document.getElementById("ContentSearch").value);
    HideLoading();
});