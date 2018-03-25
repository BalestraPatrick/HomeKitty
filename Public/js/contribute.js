function toggleBridgesSelectionAppearance() {
    var bridgeOptionsList = document.getElementById('required-bridge-selection');
    if (bridgeOptionsList.style.display !== 'none') {
        bridgeOptionsList.style.display = 'none';
    } else {
        bridgeOptionsList.style.display = 'block';
    }
    }
