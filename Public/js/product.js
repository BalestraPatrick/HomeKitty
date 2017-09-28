Stripe.setPublishableKey('pk_live_k7OpQviQWIUDzR1woxmFBand');

Stripe.applePay.checkAvailability(function(available) {
    if (available) {
        document.getElementById('apple-pay-button').style.display = 'block';
        document.getElementById('apple-pay-button').addEventListener('click', beginApplePay);
    } else {
        document.getElementById('apple-pay-button').style.display = 'none';
    }
});

function getDonationAmount() {
    let dollarsAmount = document.getElementById('donation-amount').innerHTML;
    let amount = parseInt(dollarsAmount.substr(1));
    return amount;
}

function beginApplePay() {
    let amount = getDonationAmount();
    var paymentRequest = {
        countryCode: 'US',
        currencyCode: 'USD',
        total: {
            label: 'HomeKitty Donation',
            amount: amount
        }
    }

    var session = Stripe.applePay.buildSession(paymentRequest, function(result, completion) {
        $.post('/donation', { token: result.token.id, amount: amount }).done(function() {
            completion(ApplePaySession.STATUS_SUCCESS);
            window.location.href = '/donation/thanks';
        }).fail(function() {
            completion(ApplePaySession.STATUS_FAILURE);
        });
    }, function(error) {
        console.log(error.message);
    });
    
    session.oncancel = function() {
        console.log("User hit the cancel button in the payment window");
    };
    
    session.begin();
};
