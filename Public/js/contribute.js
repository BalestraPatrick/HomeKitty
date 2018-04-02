function toggleBridgesSelectionAppearance() {
    var bridgeOptionsList = document.getElementById('required-bridge-selection');
    if (bridgeOptionsList.style.display !== 'none') {
        bridgeOptionsList.style.display = 'none';
    } else {
        bridgeOptionsList.style.display = 'block';
    }
}

function showHide() {
    var addNewButton = document.getElementById('add-new-button');
    var form = document.getElementById('add-manufacturer-form');
    var optionList = document.getElementById('manufacturer-selection');
    if (form.style.display !== 'none') {
        form.style.display = 'none';
        addNewButton.innerHTML = 'Add New Manufacturer';
        optionList.required = true;
        optionList.disabled = false;
        document.getElementById('manufacturer-name-input').required = false;
        document.getElementById('manufacturer-name-input').disabled = true;
        document.getElementById('manufacturer-logo-input').required = false;
        document.getElementById('manufacturer-logo-input').disabled = true;
        document.getElementById('manufacturer-website-input').required = false;
        document.getElementById('manufacturer-website-input').disabled = true;
    } else {
        form.style.display = 'block';
        addNewButton.innerHTML = 'Choose Existing';
        optionList.required = false;
        optionList.disabled = true;
        document.getElementById('manufacturer-name-input').required = true;
        document.getElementById('manufacturer-name-input').disabled = false;
        document.getElementById('manufacturer-logo-input').required = true;
        document.getElementById('manufacturer-logo-input').disabled = false;
        document.getElementById('manufacturer-website-input').required = true;
        document.getElementById('manufacturer-website-input').disabled = false;
    }
}

function formatPriceInput() {
    var priceInput = document.getElementById('price-input');
    if (priceInput) {
        var formattedPrice = Number(priceInput.value).toFixed(2);
        priceInput.value = isNaN(formattedPrice) ? "" : formattedPrice;
    }
    }
