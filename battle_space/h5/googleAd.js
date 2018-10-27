//
function sendGoogleAd(amount){
	/* <![CDATA[ */
	var google_conversion_id = 842897815;
	var google_conversion_label = "CacXCN6lln8Ql7P2kQM";
	var google_conversion_value = amount;
	var google_conversion_currency = "USD";
	var google_remarketing_only = false;
	/* ]]> */
	var url = "//www.googleadservices.com/pagead/conversion/842897815/?value="+amount+"&currency_code=USD&label=CacXCN6lln8Ql7P2kQM&guid=ON&script=0";
	
	 var js = document.createElement("script");
    js.src = "//www.googleadservices.com/pagead/conversion.js";
    document.body.appendChild(js);
    var imgpic = document.createElement("img");
    imgpic.width = 1;
    imgpic.height = 1;
    imgpic.style.border = 0;
    imgpic.src = url;
}