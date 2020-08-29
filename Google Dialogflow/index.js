const functions = require('firebase-functions');
var admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
var database=admin.database();


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

	 exports.hello = functions.https.onRequest(async (request, response) => 
	{
	 	let p = request.body.queryResult.parameters;
	 	database.ref("/ledstatus").set(p);
	 	var s = request.body.queryResult.parameters.LED;
		if(s==="1")
			{
				response.send({fulfillmentText:" Ok. As you said , 💡 is turned ON successfully. "});
			}
		else
			{
				response.send({fulfillmentText:" Ok. As you said , 💡 is turned OFF successfully. "});
			}
	
 	});

	
	exports.hellohindi = functions.https.onRequest(async (request, response) => 
	{
	 	let p = request.body.queryResult.parameters;
	 	database.ref("/ledstatus").set(p);
	 	var s = request.body.queryResult.parameters.LED;
		if(s==="1")
			{
				response.send({fulfillmentText:" बिल्कुल। जैसा आप कहे । मेने लाइट 💡 चालू  कर दी है । "});
			}
		else
			{
				response.send({fulfillmentText:" बिल्कुल। जैसा आप कहे । मेने लाइट 💡 बंध कर दी है । "});
			}
	
 	});

	
 