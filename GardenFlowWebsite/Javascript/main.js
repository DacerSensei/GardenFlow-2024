import {
    initializeApp
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-app.js";
import {
    getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword, sendPasswordResetEmail, onAuthStateChanged, signOut
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-auth.js";
import {
    getDatabase, ref, set, onValue, get, child
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-database.js";
import {
    getStorage
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-storage.js";
import {
    getFirestore, collection, addDoc, updateDoc, getDocs, deleteDoc, query, where, doc, getDoc, setDoc
} from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";

const FirebaseConfig = {
    apiKey: "AIzaSyDsVmqPrj3Hj-ATiGsOqkyPAsrz5KUa6Mo",
    authDomain: "watering-system-95bbc.firebaseapp.com",
    databaseURL: "https://watering-system-95bbc-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "watering-system-95bbc",
    storageBucket: "watering-system-95bbc.appspot.com",
    messagingSenderId: "864707077386",
    appId: "1:864707077386:web:bca9ccdda788d5e03706f3"
};

const App = initializeApp(FirebaseConfig);
const Auth = getAuth(App);
const FirebaseDatabase = getDatabase(App);
const Database = getFirestore(App);
export const FirebaseStorage = getStorage(App);


async function RenderElementInBody(link, elementType, isAppend = true) {
    const response = await fetch(link);
    const responseHTML = await response.text();
    const tempContainer = document.createElement(elementType);
    tempContainer.innerHTML = responseHTML;
    const body = document.body;
    if (isAppend) {
        body.append(...tempContainer.childNodes);
    } else {
        body.prepend(...tempContainer.childNodes);
    }
}

async function RenderElementById(link, elementType, id, isAppend = true) {
    const response = await fetch(link);
    const responseHTML = await response.text();
    const tempContainer = document.createElement(elementType);
    tempContainer.innerHTML = responseHTML;
    const element = document.getElementById(id);
    if (element) {
        if (isAppend) {
            element.append(...tempContainer.childNodes);
        } else {
            element.prepend(...tempContainer.childNodes);
        }
    }
}

(async () => {
    RenderElementInBody("/Library/loading.html", "div", false);
    const storedData = localStorage.getItem('userData');
    if (storedData) {
        const parsedData = JSON.parse(storedData);

        RenderElementInBody("/Library/notification.html", "div");
        if (!window.location.pathname.includes("/index.html")) {
            await RenderElementInBody("/Library/header.html", "header", false);
            if (parsedData.isAdmin) {
                await RenderElementById("/Library/sidebar-admin.html", "aside", "main", false)
            } else {
                await RenderElementById("/Library/sidebar-staff.html", "aside", "main", false)
            }
            const links = document.querySelectorAll(".nav-links");
            const currentURL = window.location.href;
            links.forEach((link) => {
                if (link.href === currentURL) {
                    link.classList.add("NavigationActive");
                } else {
                    link.classList.remove("NavigationActive");
                }
            });
            Logout();
            SetContentByQuerySelector(".user-profile-name", parsedData["first-name"] + " " + parsedData["last-name"]);
        }
        const HeaderButtons = document.getElementsByClassName("header-button");
        if (HeaderButtons) {
            if (HeaderButtons.length > 0) {
                for (let i = 0; i < HeaderButtons.length; i++) {
                    HeaderButtons[i].onclick = function () {

                        for (let j = 0; j < HeaderButtons.length; j++) {
                            let list = HeaderButtons[j].parentNode.getElementsByTagName("ul")[0].classList;
                            if (i == j) continue;
                            if (list.contains("Show")) {
                                list.remove("Show");
                            }
                        }
                        HeaderButtons[i].parentNode.getElementsByTagName("ul")[0].classList.toggle("Show");
                    }
                }
            }
        }
        const SideMenuButton = document.querySelector(".side-menu-collapse");
        if (SideMenuButton) {
            if (SideMenuButton != undefined) {
                SideMenuButton.onclick = SideBarMenuToggleEvent;
            }
        }
        const DropdownButton = document.querySelectorAll(".DropdownMenu");
        if (DropdownButton) {
            function AttachSideMenuEvent() {
                if (DropdownButton.length > 0) {
                    DropdownButton.forEach(button => {
                        let list = button.querySelector(".DropdownMenuList");
                        button.querySelector(".DropdownButton").onclick = function () {
                            list.classList.toggle("show")
                            if (list.classList.contains("show")) {
                                list.style.maxHeight = list.scrollHeight + "px";
                            } else {
                                list.style.maxHeight = 0 + "px";
                            }
                        }
                    });
                }
            }
            AttachSideMenuEvent();
        }
        ShowLoading();
        if (parsedData.type == "admin") {
            if (window.location.pathname.includes("/admin-dashboard.html")) {
                await DashboardLoaded();
            } else if (window.location.pathname.includes("/admin-imei.html")) {
                await AdminIMEI();
            } else if (window.location.pathname.includes("/admin-user-information.html")) {
                await AdminUserInformation();
            } else if (window.location.pathname.includes("/admin-user-request.html")) {
                await AdminUserRequest();
            } else if (window.location.pathname.includes("/admin-request-logs.html")) {
                await AdminRequestLogs();
            } else if (window.location.pathname.includes("/admin-sensors.html")) {
                await AdminSensors()
            } else if (window.location.pathname.includes("/update-information.html")) {
                await UpdateInformation()
            }
        }
        else if (parsedData.type == "staff") {
            if (window.location.pathname.includes("/staff-dashboard.html")) {
                await DashboardLoaded();
            } else if (window.location.pathname.includes("/admin-imei.html")) {
                await AdminIMEI();
            } else if (window.location.pathname.includes("/admin-user-request.html")) {
                await AdminUserRequest();
            } else if (window.location.pathname.includes("/admin-request-logs.html")) {
                await AdminRequestLogs();
            } else if (window.location.pathname.includes("/admin-sensors.html")) {
                await AdminSensors()
            } else if (window.location.pathname.includes("/update-information.html")) {
                await UpdateInformation()
            }
        }

        // else if (window.location.pathname.includes("/admin-accounts.html")) {
        //     await AdminAccount();
        // }
    } else if (window.location.pathname === "/forgot-password.html") { }
    else {
        Login();
    }
    HideLoading();
})();

function SideBarMenuToggleEvent() {
    const sideMenu = document.querySelector("#Side-Menu-Container")
    const logo = document.querySelector("#Logo")
    const root = document.querySelector(':root');
    const liElements = document.querySelectorAll("#MainNavigation > ul > li");
    if (getComputedStyle(document.documentElement).getPropertyValue('--sidebar-toggle') == '16rem') {
        root.style.setProperty('--sidebar-toggle', '4rem');
        document.querySelector("#MainNavigation > h4").style.display = "none";
        if (logo) {
            logo.lastElementChild.style.display = "none";
        }
        liElements.forEach(function (li) {
            li.querySelector("span").style.display = "none";
            if (li.classList.contains("DropdownMenu")) {
                const list = li.querySelector(".DropdownMenuList");
                if (li.querySelector(".DropdownMenuList").classList.contains("show")) {
                    li.querySelector(".DropdownMenuList").classList.remove("show");
                }
                li.querySelector(".DropdownButton").onclick = null;
                list.style.maxHeight = 0 + "px";
                list.classList.add("absolute");
                li.classList.add("flex");
                li.querySelector("svg:nth-of-type(2)").style.display = "none";
                li.onmouseover = function () {
                    list.style.maxHeight = list.scrollHeight + "px";
                }
                li.onmouseout = function () {
                    list.style.maxHeight = 0 + "px";
                }
            }
        });
    } else {
        root.style.setProperty('--sidebar-toggle', '16rem');
        document.querySelector("#MainNavigation > h4").style.display = "block";
        liElements.forEach(function (li) {
            if (li.classList.contains("DropdownMenu")) {
                let list = li.querySelector(".DropdownMenuList");
                list.classList.remove("absolute");
                li.classList.remove("flex");
                li.onmouseover = null;
                li.onmouseout = null;
            }
        });
        setTimeout(() => {
            liElements.forEach(function (li) {
                li.querySelector("span").style.display = "block";
                if (logo) {
                    logo.lastElementChild.style.display = "block";
                }
                if (li.classList.contains("DropdownMenu")) {
                    AttachSideMenuEvent();
                    li.querySelector("svg:nth-of-type(2)").style.display = "block";
                }
            });
        }, 300);
    }
}

async function DashboardLoaded() {
    const usersSnapshot = await getDocs(query(collection(Database, "users")));
    const usersArray = usersSnapshot.docs.map(doc => doc.data());
    let utilityUsers = 0;
    let adminUsers = 0;
    let userRequest = 0;
    adminUsers = usersArray.filter(user => user.type.toLowerCase() === "admin" || user.type.toLowerCase() === "staff").length;
    utilityUsers = usersArray.filter(user => user.type.toLowerCase() === "utility").length;
    userRequest = usersArray.filter(user => user.type.toLowerCase() === "utility" && user.status.toLowerCase() == "pending").length;
    let myList = [];
    var q = query(collection(Database, "users"), where("uuid", "==", Auth.currentUser.uid));
    const querySnapshot = await getDocs(q);
    if (querySnapshot.size >= 1) {

        querySnapshot.forEach((doc) => {
            myList.push({ ...doc.data(), id: doc.id });
        });
    }
    const storedData = localStorage.getItem('userData');
    if (storedData) {
        const parsedData = JSON.parse(storedData);
        if (parsedData.type.toLowerCase() == "admin") {
            SetContentById("AdminStaff", adminUsers);
        }
    }
    SetContentById("UtilityUsers", utilityUsers);
    SetContentById("UserRequest", userRequest);
    const imeiSnapshot = await getDocs(query(collection(Database, "imei")));
    SetContentById("ListEmei", imeiSnapshot.size);
    const logsSnapshot = await getDocs(query(collection(Database, "logs")));
    SetContentById("RequestLogs", logsSnapshot.size);
}

async function AdminIMEI(search = null) {
    try {
        const tableBody = document.getElementById("table-body");
        let querySnapshot = await getDocs(query(collection(Database, "imei")));
        if (querySnapshot.size >= 1) {
            if (!IsNullOrEmpty(search)) {
                querySnapshot = querySnapshot.docs.filter(doc => {
                    const data = doc.data();
                    return IsNullOrEmpty(search) ||
                        data.name.toLowerCase().startsWith(search) ||
                        data.name.toLowerCase().includes(search);
                });
            }
            querySnapshot.forEach((doc) => {
                const data = doc.data();
                const id = doc.id;

                const row = document.createElement("tr");

                const hiddenInput = document.createElement("input");
                hiddenInput.type = "hidden";
                hiddenInput.value = id;

                const usernameCell = document.createElement("td");
                usernameCell.textContent = data.name;

                const emeiCell = document.createElement("td");
                emeiCell.textContent = data.imeiNumber;

                const actionsCell = document.createElement("td");
                const deleteButton = document.createElement("button");
                deleteButton.className = "Button-Red-Icon";
                deleteButton.title = "Delete";
                deleteButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" style="pointer-events: none;"><path d="M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M7,6H17V19H7V6M9,8V17H11V8H9M13,8V17H15V8H13Z" /></svg>';


                actionsCell.appendChild(deleteButton);

                row.appendChild(hiddenInput);
                row.appendChild(usernameCell);
                row.appendChild(emeiCell);
                row.appendChild(actionsCell);

                tableBody.appendChild(row);
            });
        }
    } catch (error) {
        console.log(error);
    }
}

async function AdminUserInformation(search = null) {
    try {
        const tableBody = document.getElementById("table-body");
        let querySnapshot = await getDocs(query(collection(Database, "users")));
        if (querySnapshot.size >= 1) {
            if (!IsNullOrEmpty(search)) {
                querySnapshot = querySnapshot.docs.filter(doc => {
                    const data = doc.data();
                    return data["first-name"].toLowerCase().startsWith(search) || data["first-name"].toLowerCase().includes(search) || data["last-name"].toLowerCase().startsWith(search) || data["last-name"].toLowerCase().includes(search);
                });
            }
            querySnapshot.forEach((doc) => {
                const data = doc.data();
                const id = doc.id;

                const row = document.createElement("tr");

                const hiddenInput = document.createElement("input");
                hiddenInput.type = "hidden";
                hiddenInput.value = id;

                const usernameCell = document.createElement("td");
                usernameCell.textContent = data['first-name'] + " " + data['last-name'];

                const emailCell = document.createElement("td");
                emailCell.textContent = data.email;

                const mobileCell = document.createElement("td");
                mobileCell.textContent = data['mobile-number'];

                const roleCell = document.createElement("td");
                const roleSpan = document.createElement("span");
                roleSpan.textContent = data.type.toUpperCase();
                if (data.type.toLowerCase() == "admin") {
                    roleSpan.className = "Status-Purple";
                } else if (data.type.toLowerCase() == "staff") {
                    roleSpan.className = "Status-Pink";
                } else {
                    roleSpan.className = "Status-Yellow";
                }


                const statusCell = document.createElement("td");
                const statusSpan = document.createElement("span");
                statusSpan.textContent = data.status.toUpperCase();
                if (data.status.toLowerCase() == "active") {
                    statusSpan.className = "Status-Green";
                } else if (data.status.toLowerCase() == "pending") {
                    statusSpan.className = "Status-Yellow";
                } else {
                    statusSpan.className = "Status-Red";
                }


                const actionsCell = document.createElement("td");
                const editButton = document.createElement("button");
                editButton.classList.add('Button-Blue-Icon', 'modal-trigger');
                editButton.title = "Edit";
                editButton.setAttribute('data-target', 'Add-Modal');
                editButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" style="pointer-events: none;"><path d="M14.06,9L15,9.94L5.92,19H5V18.08L14.06,9M17.66,3C17.41,3 17.15,3.1 16.96,3.29L15.13,5.12L18.88,8.87L20.71,7.04C21.1,6.65 21.1,6 20.71,5.63L18.37,3.29C18.17,3.09 17.92,3 17.66,3M14.06,6.19L3,17.25V21H6.75L17.81,9.94L14.06,6.19Z"/></svg>';

                editButton.addEventListener('click', function () {
                    const modal = document.getElementById(this.dataset.target);
                    modal.style.display = 'flex';

                    // When the user clicks on the close button, close the modal
                    var closeBtn = modal.querySelector('.modal-close');
                    closeBtn.addEventListener('click', function () {
                        modal.style.display = 'none';
                        document.getElementById("user-form").reset();
                    });
                });

                const deleteButton = document.createElement("button");
                deleteButton.className = "Button-Red-Icon";
                deleteButton.style = "margin-left: 4px;"
                deleteButton.title = "Delete";
                deleteButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" style="pointer-events: none;"><path d="M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M7,6H17V19H7V6M9,8V17H11V8H9M13,8V17H15V8H13Z" /></svg>';

                actionsCell.appendChild(editButton);
                // actionsCell.appendChild(deleteButton);

                roleCell.appendChild(roleSpan)
                statusCell.appendChild(statusSpan)

                row.appendChild(hiddenInput);
                row.appendChild(usernameCell);
                row.appendChild(emailCell);
                row.appendChild(mobileCell);
                row.appendChild(roleCell);
                row.appendChild(statusCell);
                row.appendChild(actionsCell);

                tableBody.appendChild(row);
            });
        }
    } catch (error) {
        console.log(error);
    }
}

async function AdminUserRequest(search = null) {
    try {
        const tableBody = document.getElementById("table-body");
        let querySnapshot = await getDocs(query(collection(Database, "users")));
        if (querySnapshot.size >= 1) {
            if (!IsNullOrEmpty(search)) {
                querySnapshot = querySnapshot.docs.filter(doc => {
                    const data = doc.data();
                    return data["first-name"].toLowerCase().startsWith(search) || data["first-name"].toLowerCase().includes(search) || data["last-name"].toLowerCase().startsWith(search) || data["last-name"].toLowerCase().includes(search);
                });
            }
            querySnapshot.forEach((doc) => {
                const data = doc.data();
                const id = doc.id;
                if (data.status.toLowerCase() == "pending") {
                    const row = document.createElement("tr");

                    const hiddenInput = document.createElement("input");
                    hiddenInput.type = "hidden";
                    hiddenInput.value = id;

                    const usernameCell = document.createElement("td");
                    usernameCell.textContent = data['first-name'] + " " + data['last-name'];

                    const emailCell = document.createElement("td");
                    emailCell.textContent = data.email;

                    const actionsCell = document.createElement("td");
                    const acceptButton = document.createElement("button");
                    acceptButton.className = "Button-Green-Icon";
                    acceptButton.title = "Accept";
                    acceptButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" style="pointer-events: none;"><title>check</title><path d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z" /></svg>';

                    const rejectButton = document.createElement("button");
                    rejectButton.className = "Button-Red-Icon";
                    rejectButton.style = "margin-left: 4px;"
                    rejectButton.title = "Reject";
                    rejectButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 -960 960 960" width="24" style="pointer-events: none;"><path d="m256-200-56-56 224-224-224-224 56-56 224 224 224-224 56 56-224 224 224 224-56 56-224-224-224 224Z"/></svg>';

                    actionsCell.appendChild(acceptButton);
                    actionsCell.appendChild(rejectButton);

                    row.appendChild(hiddenInput);
                    row.appendChild(usernameCell);
                    row.appendChild(emailCell);
                    row.appendChild(actionsCell);
                    tableBody.appendChild(row);
                }
            });
        }
    } catch (error) {
        console.log(error);
    }
}

async function AdminRequestLogs(search = null) {
    try {
        const tableBody = document.getElementById("table-body");
        let querySnapshot = await getDocs(query(collection(Database, "logs")));
        if (querySnapshot.size >= 1) {
            if (!IsNullOrEmpty(search)) {
                querySnapshot = querySnapshot.docs.filter(doc => {
                    const data = doc.data();
                    return data["first-name"].toLowerCase().startsWith(search) || data["first-name"].toLowerCase().includes(search) || data["last-name"].toLowerCase().startsWith(search) || data["last-name"].toLowerCase().includes(search);
                });
            }
            querySnapshot.forEach((doc) => {
                const data = doc.data();
                const id = doc.id;

                const row = document.createElement("tr");

                const hiddenInput = document.createElement("input");
                hiddenInput.type = "hidden";
                hiddenInput.value = id;

                const usernameCell = document.createElement("td");
                usernameCell.textContent = data['first-name'] + " " + data['last-name'];

                const emailCell = document.createElement("td");
                emailCell.textContent = data.email;


                const dateCell = document.createElement("td");
                dateCell.textContent = data.date;

                const timeCell = document.createElement("td");
                timeCell.textContent = data.time;

                const actionsCell = document.createElement("td");
                const deleteButton = document.createElement("button");
                deleteButton.className = "Button-Red-Icon";
                deleteButton.title = "Delete";
                deleteButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" style="pointer-events: none;"><path d="M9,3V4H4V6H5V19A2,2 0 0,0 7,21H17A2,2 0 0,0 19,19V6H20V4H15V3H9M7,6H17V19H7V6M9,8V17H11V8H9M13,8V17H15V8H13Z" /></svg>';

                actionsCell.appendChild(deleteButton);

                row.appendChild(hiddenInput);
                row.appendChild(usernameCell);
                row.appendChild(emailCell);
                row.appendChild(dateCell);
                row.appendChild(timeCell);
                row.appendChild(actionsCell);

                tableBody.appendChild(row);
            });
        }
    } catch (error) {
        console.log(error);
    }
}

async function AdminSensors() {
    ShowLoading();
    const resultData = ref(FirebaseDatabase, "sensors");
    onValue(resultData, (snapshot) => {
        const data = snapshot.val();
        SetContentById("SensorHumidity", data["humidity"]);
        SetContentById("Soil", data["soil-moisture"]);
        SetContentById("pH", data["ph"]);
        SetContentById("SensorTemperature", data["temperature"]);
        SetContentById("Water", data["water-level"]);
        SetContentById("WateringMotor", data["pump-open"]);
        SetContentById("Rain", data["rain"]);
        SetContentById("Fertilizer", data["mist-open"]);
    });
    const baseUrl = 'https://api.weatherapi.com/v1/current.json?key=8c8e398fdc994ecfb7e50000232806&q=Pasig City';
    // Use fetch to make the API request
    fetch(baseUrl).then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    }).then(data => {
        SetContentById("WeatherTemperature", data["current"]["temp_c"]);
        SetContentById("Windspeed", data["current"]["wind_kph"]);
        SetContentById("City", data["location"]["name"]);
        SetContentById("WeatherHumidity", data["current"]["humidity"]);
    }).catch(error => {
        // Handle errors during the fetch
        console.error('Error fetching data:', error);
    });

    HideLoading();
}

async function UpdateInformation() {
    let user = localStorage.getItem('userData');
    if (user) {
        user = JSON.parse(user);
    }
    console.log(user);
    var q = query(collection(Database, "users"), where("uuid", "==", user.uuid));
    const querySnapshot = await getDocs(q);
    if (querySnapshot.size >= 1) {
        let list = [];
        querySnapshot.forEach((doc) => {
            list.push({ ...doc.data(), id: doc.id });
        });
        user = list[0];
        SetValueById("hidden-key", user.id);
        SetValueById("first-name", user["first-name"]);
        SetValueById("last-name", user["last-name"]);
        SetValueById("mobile-number", user["mobile-number"]);
    }
}

document.addEventListener("DOMContentLoaded", function () {
    const unsubsribe = onAuthStateChanged(Auth, async (userCredentials) => {
        let user;
        if (userCredentials) {
            if (window.location.pathname === "/index.html") {
                let q = query(collection(Database, "users"), where("uuid", "==", userCredentials.uid));
                const querySnapshot = await getDocs(q);
                if (querySnapshot.size >= 1) {
                    let list = [];
                    querySnapshot.forEach((doc) => {
                        list.push({ ...doc.data(), id: doc.id });
                    });
                    user = list[0];
                    if (user.type.toLowerCase() == "admin") {
                        const userData = user;
                        userData.isAdmin = true;
                        userData.isStaff = false;
                        userData.name = user["first-name"] + " " + user["last-name"]
                        localStorage.setItem('userData', JSON.stringify(userData));
                        window.location.href = "/admin-dashboard.html";
                    } else if (user.type.toLowerCase() == "staff") {
                        const userData = user;
                        userData.isAdmin = false;
                        userData.isStaff = true;
                        userData.name = user["first-name"] + " " + user["last-name"]
                        localStorage.setItem('userData', JSON.stringify(userData));
                        window.location.href = "/staff-dashboard.html";
                    } else {
                        ShowNotification("Your account is not admin or staff", Colors.Red);
                        signOut(Auth).then(() => {
                            console.log("Signed out successfully")
                        }).catch((error) => {
                            console.log(error.message);
                        });
                    }
                }
            } else {
                console.log("LoggedOut");
                // window.location.href = "/index.html";
            }
        } else if (window.location.pathname === "/forgot-password.html") {

        } else if (window.location.pathname !== "/index.html") {
            window.location.href = "/index.html";
        }
    });
});

async function Login() {
    const loginForm = document.getElementById("login-form");
    loginForm.addEventListener("submit", async (e) => {
        e.preventDefault();
        const email = GetElementValue("email") ?? "";
        const password = GetElementValue("password") ?? "";
        if (email == "" || password == "") {
            ShowNotification("Email or password cannot be empty", Colors.Red);
            return;
        }
        ShowLoading();
        let q = query(collection(Database, "users"), where("email", "==", email));
        const emailSnapshot = await getDocs(q);
        if (emailSnapshot.size >= 1) {
            signInWithEmailAndPassword(Auth, email, password).then(async (userCredential) => {
            }).catch((error) => {
                console.log(error.message);
                HideLoading();
                ShowNotification("Your email or password is incorrect.", Colors.Red);
            });
        }
        else {
            HideLoading();
            ShowNotification("Your email doesn't exist", Colors.Red);
        }

    });
}

function Logout() {
    const logoutButton = document.getElementById("LogoutButton");
    if (logoutButton) {
        logoutButton.addEventListener("click", () => {
            ShowLoading();
            signOut(Auth).then(() => {
                localStorage.clear();
            }).catch((error) => {
                console.log(error.message);
            });
            HideLoading();
        });
    }
}

function GetElementValue(id) {
    return document.getElementById(id).value;
}

function SetContentById(id, textContent) {
    return document.getElementById(id).textContent = textContent;
}

function SetContentByQuerySelector(querySelector, textContent) {
    if (querySelector) {
        return document.querySelector(querySelector).textContent = textContent;
    }
    return;
}

function IsNullOrEmpty(string) {
    if (string == "" || string == null || string == undefined) {
        return true;
    }
    return false;
}

function SetValueById(id, value) {
    return document.getElementById(id).value = value;
}

function getHTTPResponseNoForm(link) {
    return new Promise(function (resolve, reject) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', link, true);
        xhr.onload = function () {
            if (xhr.status === 200) {
                if (xhr.responseText == "Something went wrong") {
                    resolve("Something went wrong");
                } else {
                    resolve(xhr.responseText);
                }
            } else {
                reject('Something went wrong');
            }
        };
        xhr.send();
    });
}

export {
    Auth,
    Database,
    FirebaseDatabase,
    FirebaseConfig,
    GetElementValue,
    SetValueById,
    SetContentByQuerySelector,
    IsNullOrEmpty,
    AdminIMEI,
    AdminUserInformation,
    AdminUserRequest,
    AdminRequestLogs,
    UpdateInformation,
    getHTTPResponseNoForm
};