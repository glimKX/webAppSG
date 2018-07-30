
(function ($) {
    "use strict";


    /*==================================================================
    [ Focus input ]*/
    $('.input100').each(function(){
        $(this).on('blur', function(){
            if($(this).val().trim() != "") {
                $(this).addClass('has-val');
            }
            else {
                $(this).removeClass('has-val');
            }
        })    
    })
  
  
    /*==================================================================
    [ Validate ]*/
    var input = $('.validate-input .input100');

    $('.validate-form').on('submit',function(){
	var check=true;
        for(var i=0; i<input.length; i++) {
            if(validate(input[i]) == false){
                showValidate(input[i]);
                check=false;
            }
        }
	login()
    });


    $('.validate-form .input100').each(function(){
        $(this).focus(function(){
           hideValidate(this);
        });
    });

    function validate (input) {
        if($(input).attr('type') == 'email' || $(input).attr('name') == 'email') {
            if($(input).val().trim().match(/^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{1,5}|[0-9]{1,3})(\]?)$/) == null) {
                return false;
            }
        }
        else {
            if($(input).val().trim() == ''){
                return false;
            }
        }
    }

    function showValidate(input) {
        var thisAlert = $(input).parent();

        $(thisAlert).addClass('alert-validate');
    }

    function hideValidate(input) {
        var thisAlert = $(input).parent();

        $(thisAlert).removeClass('alert-validate');
    }

    function login(){
                        var username = document.getElementsByName("username")[0].value;
                        var password = document.getElementsByName("pass")[0].value;
                        if ("WebSocket" in window){
                                var l = window.location;ws = new WebSocket("ws://" + username + password + "@" + (l.hostname ? l.hostname : "localhost") + ":" + (l.port ? l.port : "5030") + "/");
                                ws.onopen=function(e){window.location.href = "main.htm";}
                                ws.onclose=function(e){}
                                ws.onmessage=function(e){
                                        wsTmp=e.data;
                                        wsJsonObj=JSON.parse(wsTmp);
                                        if (wsJsonObj.func == "sourceForSym"){parseForSym(wsJsonObj.output)}
                                        else if (wsJsonObj.func == "selectFromTrade"){parseForQTable(wsJsonObj.output);hide()}
                                        else {out.value=e.data;unHide()}
                                }
                                ws.onerror=function(e){out.value=e.data;}
                        }else alert("WebSockets not supported on your browser.");
                }
    
    

})(jQuery);
