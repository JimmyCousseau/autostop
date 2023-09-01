import 'firebase/auth';
import config from './config';
const admin = require('firebase-admin');


admin.initializeApp(config);

const deleteAccountButton = document.getElementById("deleteAccountButton");

deleteAccountButton.addEventListener("click", () => {
    handleDeleteAccountClick();
});

async function deleteAccountWithToken(token) {
    try {
        // Verify the token
        const decodedToken = await admin.auth().verifyIdToken(token);
        const uid = decodedToken.uid;

        // Delete the user
        await admin.auth().deleteUser(uid);

        return true; // Deletion successful
    } catch (error) {
        alert("Error deleting account:", error);
        return false; // Deletion failed
    }
}

async function handleDeleteAccountClick() {
    const token = getTokenFromURL();
    deleteAccountWithToken(token)
        .then(deletionResult => {
            if (deletionResult) {
                alert("Account deleted successfully.");
            } else {
                alert("Account deletion failed.");
            }
        })
        .catch(error => {
            alert("Error:", error);
        });
}

function getTokenFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('token');
}
