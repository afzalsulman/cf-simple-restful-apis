component {

  // application properties
  // this.name = hash( getCurrentTemplatePath() );
  this.name = 'cf-restful-apis';
  this.applicationTimeout = createTimeSpan(0,0,0,20);
  this.sessionManagement = true;
  this.sessionTimeout = createTimeSpan(0,1,0,0);
  this.setClientCookies = true;
  // this.timezone = "Asia/Karachi";
  this.mailservers = [{
    host: "host"
    ,port: 25
    ,username: "username"
    ,password: "password"
    ,ssl: false
    ,tls: false
    ,lifeTimespan: CreateTimeSpan( 0, 0, 1, 0 ) //Overall timeout for the connections established to the mail server.
    ,idleTimespan: CreateTimeSpan( 0, 0, 0, 10 ) //Idle timeout for the connections established to the mail server.
  }];

  devServerList = "127.0.0.1,localhost,development";
  if(listFindNoCase(devServerList, cgi.server_name)){
    this.datasource = "datasource_dev";
  }else{
    this.datasource = "datasource_prod";
  }

  // mappings
  // this.mappings[ "models" ] = expandPath('./models');

  public boolean function onApplicationStart(){
    // global variables
    application.globalvars.title = "CF Restful APIs";

    // api logs file
    application.logsFileName = this.name;

    // set environment
    application.isDevelopment = false;
    application.isLocalhost = false;
    application.isProduction = true;
    var devServers = '127.0.0.1,localhost,development';
    if(listFindNoCase(devServers, cgi.server_name)){
      if(cgi.server_name EQ '127.0.0.1' OR cgi.server_name EQ 'localhost'){
        application.isLocalhost = true;
      }
      application.isDevelopment = true;
      application.isProduction = false;
    }

    // jar files path
    application.jarPath = expandPath('includes/libs/');

    // models objects
    application.obj.util = new models.utility( );
    application.obj.user = new models.user( );
    // libraries objects
    application.obj.jwt = new includes.libs.jwt.jwt( );

    return true;
  }

  // application end
  public boolean function onApplicationEnd( struct applicationScope ) {
    // Destroy application-cached components
    if(structKeyExists(arguments.applicationScope, "obj")){
      structDelete(arguments.applicationScope, "obj");
    }

    return true;
  }

  // request start
  public boolean function onRequestStart( string targetPage ){
    // header settings
    // cfheader( name="Access-Control-Allow-Origin", value="*" );
    // allow custom headers
    // cfheader( name="Access-Control-Allow-Headers", value="Authorization" );
    // cfheader( name="Access-Control-Allow-Headers", value="UserToken" );

    // reinitialize application
    if(
        (!application.isProduction)
        || (structKeyExists(url, 'reinit') AND url.reinit EQ "dev")
    ){
      onApplicationStart();
      componentCacheClear();
      pagePoolClear();
    }

    // create url to use globally
    if(cgi.server_port_secure){
      appUrl = 'https://' & cgi.http_host & '/';
    }else{
      appUrl = 'http://' & cgi.http_host & '/';
    }
    request.appUrl = appUrl;
    webRoot = listFirst(cgi.script_name,'/') & "/";
    if(!findNoCase('.cfm', webRoot)){
      request.appUrl = appUrl&webRoot;
    }

    // establish a browser scope to hold client device properties
    request.browser = structNew();
    request.browser.clientIp = cgi.REMOTE_ADDR;
    request.browser.http_referer = '';
    request.browser.http_user_agent = '';
    request.headers = GetHttpRequestData().headers;
    // replace calling IP in case of cloudflare proxies
    if (structKeyExists(request.headers,'x-forwarded-for')){
      request.browser.clientIp = listFirst(request.headers['x-forwarded-for']);
    }
    if (structKeyExists(request.headers,'CF-Connecting-IP')){
      request.browser.clientIp = listFirst(request.headers['CF-Connecting-IP']);
    }
    if (structKeyExists(cgi,'HTTP_REFERER')){
      request.browser.http_referer = cgi.HTTP_REFERER;
    }
    if (structKeyExists(cgi,'HTTP_USER_AGENT')){
      request.browser.http_user_agent = cgi.HTTP_USER_AGENT;
    }

    // encrypt/decrypt settings
    request.cryptKey = 'Tr1jlzChlV6NdH1Yh4fVVg==';
    request.cryptAlgorithm = 'AES/CBC/PKCS5Padding'; //Cipher Block Chaining (CBC) mode
    request.cryptEncoding = 'HEX';

    //email setting
    request.email.noReplyEmail = "noreply@company.com";

    return true;
  }

  public void function onError(required any exception, required string eventName) {
    // events detail string
    var eventNameString = " applicationEventName|" & arguments.eventName;
    if(structKeyExists(url, "event")){
      eventNameString &= " urlEventName|" & url.event;
    }

    // create log
    var logErrorResponse = new models.utility().logErrors(
        error = arguments.exception, fileName=this.name, eventName=eventNameString
    );

    var structReturn = {};
    structReturn['data'] = {};
    structReturn['messages'] = arrayNew(1);
    structReturn['error'] = true;
    structReturn["shouldLogout"] = false;

    if(structKeyExists(application, "isProduction") && !application.isProduction){
      structReturn.messages.append(logErrorResponse.errorMessageDeveloper);
    }

    structReturn.messages.append(logErrorResponse.errorMessageUser);

    // serialized the return struct and output it
    writeOutput(serializeJSON(structReturn));
    cfheader( statuscode=500 );

    return;
  }

}
