<cfoutput>
    <cfparam name="session.userToken" default=""/>
    <cfparam name="form.eventEndpoint" default=""/>
    <cfparam name="form.jsonString" default=""/>
    <cfparam name="form.submitBtn" default=""/>

    <!DOCTYPE html>
    <html lang="en">
        <head>
            <title>API Tester</title>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ" crossorigin="anonymous">
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ENjdO4Dr2bkBIFxQpeoTz1HIcje39Wm4jDKdf19U8gI4ddQ3GYNS7NTKfAdVQSZe" crossorigin="anonymous"></script>
            <link rel="stylesheet" href="//code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
            <script src="https://code.jquery.com/jquery-3.6.0.js"></script>
            <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
            <style>
                pre {
                    display: block;
                    font-family: monospace;
                    white-space: pre;
                    margin: 1em 0;
                } 
            </style>
        </head>
        <body>
            <div class="container">
                <h2>API Tester</h2>
                <cfif form.submitBtn EQ 'testEventForm' OR form.submitBtn EQ 'testEventJson'>
                    <div class="row">
                        <div class="col-lg-12">
                            <!--- <cfset excludeFields = "eventEndpoint,jsonString,submitBtn,userToken,fieldnames"/> --->
                            <cfhttp result="result" method="post" url="#request.appUrl#?event=#form.eventEndpoint#" timeout="30">
                                <cfhttpparam type="header" name="Authorization" value="#session.userToken#" />
                                <cfif form.submitBtn EQ 'testEventJson'>
                                    <cfhttpparam type="header" name="Content-Type" value="application/json" />
                                    <cfhttpparam type="body" value="#form.jsonString#"/>
                                <cfelse>
                                    <cfloop item="currentItem" collection="#form#" index="currentKey">
                                        <!--- <cfif NOT listFindNoCase(excludeFields, currentKey)> --->
                                            <cfhttpparam type="formfield" name="#currentKey#" value="#currentItem#"/>
                                        <!--- </cfif> --->
                                    </cfloop>
                                </cfif>
                            </cfhttp>

                            <!--- <cfif form.submitBtn EQ 'testEventJson'>
                                <cfhttp result="result" method="post" url="http://#cgi.http_host#/?event=#form.eventEndpoint#" timeout="30">
                                    <cfhttpparam type="header" name="Authorization" value="#session.userToken#" />
                                    <cfhttpparam type="header" name="Content-Type" value="application/json" />
                                    <cfhttpparam type="body" value="#form.jsonString#"/>
                                </cfhttp>
                            <cfelse>
                                <cfset excludeFields = "event,jsonString,submitBtn,userToken,fieldnames"/>
                                <cfhttp result="result" method="post" url="http://#cgi.http_host#/?event=#form.eventEndpoint#" timeout="30">
                                    <cfhttpparam type="header" name="Authorization" value="#session.userToken#" />
                                    <cfloop item="currentItem" collection="#form#" index="currentKey">
                                        <cfif NOT listFindNoCase(excludeFields, currentKey)>
                                            <cfhttpparam type="formfield" name="#currentKey#" value="#currentItem#"/>
                                        </cfif>
                                    </cfloop>
                                </cfhttp>
                            </cfif> --->

                            <div class="jumbotron">
                                <br/>
                                <h3>Request & Response Details</h3>
                                <p><b>End Point:</b> #request.appUrl#?event=#form.eventEndpoint#</p>
                                <p>
                                    <cfif len(trim(session.userToken))>
                                        <b>header:</b> Authorization &##8594; <span data-bs-toggle="tooltip" title="#session.userToken#">#left(session.userToken, 80)#....</span><br/>
                                    </cfif>
                                    <cfif form.submitBtn EQ 'testEventJson'>
                                        <b>header:</b> Content-Type &##8594; application/json<br/>
                                        <b>body:</b> <pre>#form.jsonString#</pre>
                                    </cfif>
                                </p>

                                <cfif isJSON(result.filecontent)>
                                    <cfset jsonResponse = deserializeJSON(result.filecontent)/>
                                    <cfif isDefined("jsonResponse.data.token")>
                                        <cfset session.userToken = jsonResponse.data.token/>
                                    </cfif>
                                    <b>JSON Response</b>
                                    <div class="card bg-light text-dark">
                                        <div class="card-body">
                                            <!--- <pre>#result.filecontent#</pre> --->
                                            <cfset serializedData = application.obj.util.buildGson().toJson( deserializeJSON(result.filecontent) )/>
                                            <pre>#encodeForHtml( serializedData )#</pre>
                                        </div>
                                    </div>
                                    <b>Deserialized JSON Response</b>
                                    <cfdump var="#deserializeJSON(result.filecontent)#" label="JSON Struct" expand="false"/>
                                <cfelse>
                                    <b>Invalid Response</b>
                                    #result.filecontent#
                                </cfif>
                                <br/>
                            </div>
                        </div>
                    </div>
                </cfif>

                <cfset cfcDir = expandPath("handlers")>
                <cfdirectory action="list" directory="#cfcDir#" filter="*.cfc" name="qFileList"/>

                <div class="row">
                    <div class="col-lg-12">
                        <div id="accordion" class="accordion">
                            <cfloop query="qFileList">
                                <cfif qFileList.name NEQ 'Application.cfc'>
                                    <cfset handlerName = replace(qFileList.name,".cfc","")/>
                                    <cfset handlerMetaData = getComponentMetadata('handlers.'&handlerName)/>
                                    <cfset displayname = handlerName/>

                                    <cfif structKeyExists(handlerMetaData, 'displayname')>
                                        <cfset displayname = handlerMetaData.displayname/>
                                    </cfif>
                                    <cfset hint = "#displayname# requests handler"/>
                                    <cfif structKeyExists(handlerMetaData, 'hint')>
                                        <cfset hint = handlerMetaData.hint/>
                                    </cfif>

                                    <!--- functions --->
                                    <cfset functions = handlerMetaData.functions/>
                                    <cfloop from="1" to="#arrayLen(functions)#" index="f">
                                        <cfset functionName = functions[f].name/>
                                        <cfset endPoint = "#request.appUrl#?event=#displayname#.#functionName#"/>
                                        <cfset functionHint = ''/>

                                        <cfif isDefined('functions[f].hint')>
                                            <cfset functionHint = functions[f].hint/>
                                        </cfif>
                                        <cfset parameters = functions[f].parameters/>

                                        <cfif functionName NEQ 'init'>
                                            <cfset eventName = displayname&'.'&functionName/>
                                            <cfset createUuid = createUUID()/>
                                            <h3>#eventName#</h3>
                                            <div class="tabs">
                                                <ul>
                                                    <li><a href="##run-#createUuid#">Run</a></li>
                                                    <li><a href="##doc-#createUuid#">Documentation</a></li>
                                                </ul>
                                                <div id="run-#createUuid#">
                                                    <div class="row">
                                                        <div class="col">
                                                            <h3>Form data request</h3>
                                                            <form action="" method="post" enctype='multipart/form-data'>
                                                                <!--- parameters --->
                                                                <cfloop from="1" to="#arrayLen(parameters)#" index="p">
                                                                    <cfset parameterName = parameters[p].name/>
                                                                    <cfset parameterRequired = parameters[p].required/>
                                                                    <cfset parameterType = parameters[p].type/>
                                                                    <cfset parameterDefault = ''/>
                                                                    <cfif isDefined("parameters[p].default")>
                                                                        <cfset parameterDefault = parameters[p].default/>
                                                                    </cfif>

                                                                    <cfif parameterType EQ 'numeric' OR parameterType EQ 'integer'>
                                                                        <cfset parameterType = 'number'/>
                                                                    <cfelseif parameterType EQ 'date'>
                                                                        <cfset parameterType = 'date'/>
                                                                    <cfelse>
                                                                        <cfset parameterType = 'text'/>
                                                                    </cfif>

                                                                    <cfset fieldExtraOptions = ''/>
                                                                    <cfif findNoCase("attachFile", parameterName)>
                                                                        <cfset parameterType = 'file'/>
                                                                        <cfif findNoCase("attachFiles", parameterName)>
                                                                            <cfset fieldExtraOptions = 'multiple'/>
                                                                        </cfif>
                                                                    </cfif>

                                                                    <cfset fieldValue = parameterDefault/>
                                                                    <cfif form.eventEndpoint EQ eventName>
                                                                        <cfloop item="currentItem" collection="#form#" index="currentKey">
                                                                            <cfif parameterName EQ currentKey>
                                                                                <cfset fieldValue = currentItem/>
                                                                            </cfif>
                                                                        </cfloop>
                                                                    </cfif>
                                                                    <div class="mb-3 mt-3">
                                                                        <label for="#parameterName##currentrow##f#" class="form-label">#parameterName#:</label>
                                                                        <input value="#fieldValue#" type="#parameterType#" class="form-control" name="#parameterName#" id="#parameterName##currentrow##f#" <cfif parameterRequired>required</cfif> #fieldExtraOptions#>
                                                                    </div>
                                                                </cfloop>
                                                                <input type="hidden" name="eventEndpoint" value="#eventName#">
                                                                <button type="submit" class="btn btn-primary" name="submitBtn" value="testEventForm">Submit</button>
                                                            </form>
                                                        </div>
                                                        <div class="col">
                                                            <h3>JSON data request</h3>
                                                            <form action="" method="post" enctype='multipart/form-data'>
                                                                <!--- parameters --->
                                                                <cfset sampleJsonString = '{'/>
                                                                <cfloop from="1" to="#arrayLen(parameters)#" index="p">
                                                                    <cfset parameterName = parameters[p].name/>
                                                                    <cfif arrayLen(parameters) NEQ p>
                                                                        <cfset sampleJsonString = sampleJsonString&'"#parameterName#":"",'/>
                                                                    <cfelse>
                                                                        <cfset sampleJsonString = sampleJsonString&'"#parameterName#":""'/>
                                                                    </cfif>
                                                                </cfloop>
                                                                <cfset sampleJsonString = sampleJsonString&'}'/>
                                                                <div class="mb-3 mt-3">
                                                                    <textarea class="form-control" rows="10" name="jsonString">#sampleJsonString#</textarea>
                                                                </div>
                                                                <input type="hidden" name="eventEndpoint" value="#eventName#">
                                                                <button type="submit" class="btn btn-primary" name="submitBtn" value="testEventJson">Submit</button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div id="doc-#createUuid#">
                                                    <p><b>#functionHint#</b></p>
                                                    <p><b>End Point:</b> #endPoint#</p>
                                                    <h4>Parameters</h4>
                                                    <cfloop from="1" to="#arrayLen(parameters)#" index="p">
                                                        <cfset parameterName = parameters[p].name/>
                                                        <cfset parameterRequired = parameters[p].required/>
                                                        <cfset parameterType = parameters[p].type/>
                                                        <cfset parameterHint = ""/>

                                                        <cfif isDefined("parameters[p].hint")>
                                                            <cfset parameterHint = parameters[p].hint/>
                                                        </cfif>
                                                        <cfset parameterDefault = ''/>
                                                        <cfif isDefined("parameters[p].default")>
                                                            <cfset parameterDefault = parameters[p].default/>
                                                        </cfif>
                                                        <p>
                                                            <b>Name:</b> #parameterName#
                                                            &nbsp;&nbsp;<b>Type:</b> #parameterType#
                                                            &nbsp;&nbsp;<b>Required:</b> #parameterRequired#
                                                            <cfif len(trim(parameterDefault))>
                                                                &nbsp;&nbsp;<b>Default:</b> #parameterDefault#
                                                            </cfif>
                                                            <cfif len(trim(parameterHint))>
                                                                &nbsp;&nbsp;<b>Hint:</b> #parameterHint#
                                                            </cfif>
                                                        </p>
                                                    </cfloop>
                                                </div>
                                            </div>
                                        </cfif>
                                    </cfloop>
                                </cfif>
                            </cfloop>
                        </div>
                    </div>
                </div>
            </div>
            <script>
                $( function() {
                    $( ".accordion" ).accordion({
                        collapsible: true,
                        active: false
                    });
                    $( ".tabs" ).tabs();
                    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
                    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                        return new bootstrap.Tooltip(tooltipTriggerEl);
                    });
                });
            </script>
        </body>
    </html>
</cfoutput>
