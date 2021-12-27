<cfscript>
	// events to exclude from security check
	request.excludeEvents = "echo.index,user.login,user.register";

	// used in api security check
	request.isValidRequest = true;

	// output setting
	cfcontent( type="application/json" );
	if(NOT application.isDevelopment){
		cfsetting( enablecfoutputonly="true" );
		// cfcontent( type="application/json" );
	}
	// header settings for local host
	if(application.isLocalhost){
		cfheader( name="Access-Control-Allow-Origin", value="*" );
		cfheader( name="Access-Control-Allow-Headers", value="Content-Type" )
		cfheader( name="Access-Control-Allow-Headers", value="Authorization" )
	}

	// global variables
	// these variables are used in response data 
	request.data = structNew();
	request.messages = arrayNew(1);
	request.error = false;
	request.headerCode = 200;

	// request handler
	// event
	param name="url.event" default="echo.index";
	request.handler = listFirst(url.event,'.');
	request.action = 'index';
	if(listLen(url.event,'.') EQ 2){
		request.action = listLast(url.event,'.');
	}

	// http request
	httpRequestData = getHttpRequestData();
	request.userToken = '';
	if(structKeyExists(httpRequestData.headers, 'Authorization')){
		request.userToken = httpRequestData.headers['Authorization'];
	}

	request.requestContent = httpRequestData.content;

	// if request is in json format, convert json struct to form struct
	if(isJSON(request.requestContent)){
		jsonStruct = deserializeJSON(request.requestContent);
		jsonStruct.each(function(key, value) {
			form['#key#'] = value;
		});
	}

	try{

		// api security check
		if(NOT listFindNoCase(request.excludeEvents, url.event)){
			try{
				payload = application.jwt.decode(request.userToken, request.cryptKey, 'HS256');
				if(isStruct(payload)){
					request.userID = payload.userID;
					if(NOT isValid("integer", request.userID)){
						request.messages = request.messages.append("Issue with credentials. Please log out and log in again.");
						request.isValidRequest = false;
					}
				}
			}catch(any e){
				request.isValidRequest = false;
				request.messages = request.messages.append(e.message);
			}
		}

		if(request.isValidRequest){
			// create the handler object
			createObjHandler = createObject("component", "handlers/#request.handler#").init();
			// call specific function of handler for each request
			objHandler = createObjHandler[request.action](argumentCollection=form);
		}

	}catch(any e){
		// errorMessage = e.message & " " & e.detail & " " & e.tagcontext[1].LINE;
		errorMessage = e.message;
		request.messages = request.messages.append(errorMessage);
		request.error = true;
	}

	// call response handler
	// get the content of each request and create the struct
	request.dataStructure = application.util.setDataStruct(request.data, request.messages, request.error);
	writeOutput(serializeJSON(request.dataStructure));
	cfheader( statuscode=request.headerCode );
</cfscript>
