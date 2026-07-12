const DEFAULT_PROFILES = [
    "Default",
    "Profile 1",
    "Profile 2",
    "Custom..."
];

const profileSelect = document.getElementById("profile");
const captureButton = document.getElementById("captureButton");

initialize();

async function initialize() {
    const result = await chrome.storage.local.get([
        "profiles",
        "selectedProfile"
    ]);
    const profiles = result.profiles || DEFAULT_PROFILES;
    profiles.forEach(addProfileOption);
    profileSelect.value =
        result.selectedProfile || profiles[0];

}

function addProfileOption(profile) {
    const option = document.createElement("option");
    option.value = profile;
    option.textContent = profile;
    profileSelect.appendChild(option);

}

profileSelect.addEventListener("change", async () => {
    if (profileSelect.value !== "Custom...") {
        await chrome.storage.local.set({
            selectedProfile: profileSelect.value
        });
        return;
    }

    const custom = prompt("Enter Chrome profile name");
    if (!custom) {
        profileSelect.value = "Default";
        return;
    }
    const name = custom.trim();
    if (name.length === 0) {
        profileSelect.value = "Default";
        return;
    }
    const result = await chrome.storage.local.get("profiles");
    let profiles = result.profiles || DEFAULT_PROFILES.slice(0,3);
    if (!profiles.includes(name)) {
        profiles.push(name);
        await chrome.storage.local.set({
            profiles: profiles
        });
        const option = document.createElement("option");
        option.value = name;
        option.textContent = name;
        profileSelect.insertBefore(
            option,
            profileSelect.lastChild
        );

    }

    profileSelect.value = name;
    await chrome.storage.local.set({
        selectedProfile: name

    });

});

captureButton.addEventListener("click", captureWorkspace);

async function captureWorkspace() {
    const profile = profileSelect.value;
    const tabs = await chrome.tabs.query({});
    const workspace = {
        name: profile,
        description: "",
        items: []
    };

    for (const tab of tabs) {
        if (!tab.url)
            continue;
        if (
            tab.url.startsWith("chrome://") ||
            tab.url.startsWith("chrome-extension://")
        )
            continue;
        workspace.items.push({
            type: "url",
            name: tab.title || tab.url,
            enabled: true,
            url: tab.url,
            profile: profile
        });
    }

    const json = JSON.stringify(
        workspace,
        null,
        4
    );

    const blob = new Blob(
        [json],
        { type: "application/json" }
    );

    const url = URL.createObjectURL(blob);

    chrome.downloads.download({
        url: url,
        filename: `${profile}.json`,
        saveAs: true
    });

}