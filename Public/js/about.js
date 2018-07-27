$(".dropdown-menu li:not(.disabled) a").click(function () {
                                              $(this).closest(".dropdown").find(".btn").html('<span id="donation-amount">' + $(this).text() + '</span> <span class="caret"></span>');
                                              });
