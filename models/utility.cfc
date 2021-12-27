component{

    utility function init( ) {
        return this;
    }

    public struct function setDataStruct(
        required struct data, required array messages, required boolean error
    ){
        var returnStruct = structNew();

        returnStruct['data'] = arguments.data;
        returnStruct['messages'] = arguments.messages;
        returnStruct['error'] = arguments.error;

        return returnStruct;
    }

    public void function sendMail(
        required string from, required string to,
        required string subject, required string mailBody
    ) {

        // Create and populate the mail object
        mailService = new mail(
            to = arguments.to,
            from = arguments.from,
            subject = arguments.subject,
            body = arguments.mailBody
        );

        // Send
        mailService.send();
    }

    /*
        encrypt/decrypt the provided string
    */
    public struct function cryptwise(required string myString, string action = 'enc') {
        var result = {};
        result.error = false;
        result.message = '';
        result.myString = '';
        try{
            if(arguments.action EQ 'enc'){
                result.myString = encrypt(trim(arguments.myString), request.cryptKey, request.cryptAlgorithm, request.cryptEncoding);
            }else if(arguments.action EQ 'dec'){
                result.myString = decrypt(trim(arguments.myString), request.cryptKey, request.cryptAlgorithm, request.cryptEncoding);
            }
        }catch(any e){
            result.error = true;
            result.message = e.message;
            result.myString = '';
        }
        return result;
    }

    /*
        convert query object to array of structs
        first argument is query data
        second argument is the list of query columns
    */
    public function queryToArray(required query data, required string columnList) {
        var returnArray = [];
        var temp = {};
        var q = arguments.data;
        var rc = q.recordCount;
        var fields = listToArray(arguments.columnList);
        var fc = arrayLen(fields);
        var x = 0;
        var y = 0;
        var fieldName = "";

        for ( x = 1; x LTE rc; x++ ){
            temp = {};
            for ( y = 1; y LTE fc; y++ ) {
                fieldName = fields[y];
                temp[fieldName] = q[fieldName][x];
            }
            arrayAppend( returnArray, temp );
        }
        return returnArray;
    }

    /*
        create pagination struct
    */
    public function paginationStruct(required numeric maxRowsValue, required numeric pageValue, required numeric totalRecordsValue) {

        var maxRows = arguments.maxRowsValue;
        var offset = 0;
        var totalRecords = arguments.totalRecordsValue;
        var page = arguments.pageValue;

        // limit the maxRows to 100
        if(maxRows GT 100){
            maxRows = 100;
        }

        // calculate offset
        if(page GT 1){
            offset = (maxRows*(page-1));
        }

        // calculate totalPages
        totalPages = ceiling((totalRecords/maxRows));

        // return struct
        var returnData = {};
        returnData['totalPages'] = totalPages;
        returnData['maxRows'] = maxRows;
        returnData['offset'] = offset;
        returnData['page'] = page;
        returnData['totalRecords'] = totalRecords;

        return returnData;
    }

}
