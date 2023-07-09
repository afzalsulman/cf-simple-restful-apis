<cfscript>
  // output setting
  cfcontent( type="application/json" );
  cfsetting( enablecfoutputonly="true" );

  // request event handler, get handler name and function from url event
  param name="url.event" default="echo.index";
  handlerName = listFirst(url.event,'.');
  handlerFunction = listLast(url.event,'.');

  // http request
  httpRequestData = getHttpRequestData();
  // get user token from http headers
  userToken = '';
  if(structKeyExists(httpRequestData.headers, 'Authorization')){
    userToken = httpRequestData.headers['Authorization'];
  }

  // if http request content is in json format,
  // convert json struct to form struct because form scope is passed to handler component as a argumentCollection
  jsonStruct = {};
  if(isJSON(httpRequestData.content)){
    jsonStruct = deserializeJSON(httpRequestData.content);
    jsonStruct.each(function(key, value) {
      form[key] = value;
    });
  }

  // global variables used in response structure
  // request.structReturn = createObject( "java", "java.util.LinkedHashMap" ).init();
  // request.structReturn['data'] = createObject( "java", "java.util.LinkedHashMap" ).init();
  request.structReturn = {};
  request.structReturn['data'] = {};
  request.structReturn['messages'] = arrayNew(1);
  request.structReturn['error'] = false;
  request.structReturn["shouldLogout"] = false;
  request.headerCode = 200;

  // api security check using jwt-cfml library
  // events to exclude from security check
  excludeEvents = "echo.index,user.login,user.register";
  if(NOT listFindNoCase(excludeEvents, url.event)){
    // jwt-cfml
    // https://github.com/jcberquist/jwt-cfml
    // This module supports encoding and decoding JSON Web Tokens.
    payload = application.obj.jwt.decode(userToken, request.cryptKey, 'HS256');
    if(isStruct(payload)){
      request.userID = payload.userID;
      if(NOT isValid("integer", request.userID)){
        request.structReturn.messages.append("An issue with credentials, please log in again.");
        request.structReturn.error = true;
        request.structReturn.shouldLogout = true;
      }
    }
  }

  // form fields validation
  typeList = 'date,boolean,numeric,uuid';
  handlerMetaData = getComponentMetadata('handlers.'&handlerName);
  functions = handlerMetaData.functions;

  // validations for required fields, missing parameters
  /* for (f = 1; f <= arrayLen(functions); f++) {
    functionName = functions[f].name;
    if(functionName == handlerFunction){
      parameters = functions[f].parameters;
      for (p = 1; p <= arrayLen(parameters); p++) {
        parameterName = parameters[p].name;
        parameterRequired = parameters[p].required;
        parameterType = parameters[p].type;
        if( // required field condition
          parameterRequired
          && structKeyExists(form, "#parameterName#")
          && len(trim(form[parameterName])) == 0
        ){
          request.structReturn.messages.append("#parameterName# is required field!");
          request.structReturn.error = true;
        }else if( // required field with parameter type condition
          parameterRequired
          && structKeyExists(form, "#parameterName#")
          && len(trim(form[parameterName]))
          && listFindNoCase(typeList, parameterType)
          && !isValid("#parameterType#", form[parameterName])
        ){
          request.structReturn.messages.append("#parameterName# should be #parameterType#");
          request.structReturn.error = true;
        }else if( // !required field with parameter type condition
          structKeyExists(form, "#parameterName#")
          && listFindNoCase(typeList, parameterType)
          && !isValid("#parameterType#", form[parameterName])
        ){
          request.structReturn.messages.append("#parameterName# should be #parameterType#");
          request.structReturn.error = true;
        }else if( // missing parameter condition
          !structKeyExists(form, "#parameterName#")
        ){
          request.structReturn.messages.append("Parameter #parameterName# is missing!");
          request.structReturn.error = true;
        }
      }
      break;
    }
  } */

  // handlerFunction argument validations before calling or passing form scope to the function
  // * required fields
  // check if the field is required and present in the form scope and should not be empty
  // * missing parameters
  // check if a parameter is missing in the form scope
  for (f = 1; f <= arrayLen(functions); f++) {
    functionName = functions[f].name;
    if(functionName == handlerFunction){
      parameters = functions[f].parameters;
      for (p = 1; p <= arrayLen(parameters); p++) {
        parameterName = parameters[p].name;
        parameterRequired = parameters[p].required;
        parameterType = parameters[p].type;
        if( // required field condition
          parameterRequired
          && structKeyExists(form, "#parameterName#")
          && len(trim(form[parameterName])) == 0
        ){
          request.structReturn.messages.append("#parameterName# is required field!");
          request.structReturn.error = true;
        }else if( // missing parameter condition
          !structKeyExists(form, "#parameterName#")
        ){
          request.structReturn.messages.append("Parameter #parameterName# is missing!");
          request.structReturn.error = true;
        }
      }
      break;
    }
  }

  // form validations succeed, complete the request
  if(!request.structReturn.error){
    // create the handler cfc component object
    createObjHandler = createObject("component", "handlers/#handlerName#").init();
    // call specific function of handler for each request
    createObjHandler[handlerFunction](argumentCollection=form);
  }

  // serialized the return struct and output it
  writeOutput(serializeJSON(request.structReturn));
  cfheader( statuscode=request.headerCode );
</cfscript>
