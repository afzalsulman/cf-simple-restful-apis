/**
 * User requests handler
**/
component{

  /**
   * Constructor
  **/
  user function init( ) {
    // can use application-cached model components
    userService = application.obj.user;
    utilService = application.obj.util;

    // or can create models new objects and use them
    // userService = new models.user();
    // utilService = new models.utility();
    return this;
  }

  /**
   * Register a new user in the system
   * @name user complete name
   * @email user email address
   * @password password of minimum 6 characters
   */
  public void function register(
    required string name, required string email,
    required string password
  ) {

    if(NOT isValid("email", arguments.email)){
      request.structReturn.messages.append("Please enter an email.");
      request.structReturn.error = true;
    }

    if(len(trim(arguments.password)) LT 6){
      request.structReturn.messages.append("Password should be at least 6 characters.");
      request.structReturn.error = true;
    }

    if(NOT request.structReturn.error){

      var token = application.obj.jwt.encode(
        { userID=1
        }, request.cryptKey, 'HS256'
      );

      request.structReturn.data['token'] = token;
      request.structReturn.data['username'] = arguments.name;
      request.structReturn.data['useremail'] = arguments.email;
      request.structReturn.messages.append("You are successfully registered");

    }else{
      request.headerCode = 422;
    }

  }

  /**
  * Login a user into the application
  * @email user email address
  * @password password of minimum 6 characters
  */
  public void function login(
    required string email, required string password
  ) {

    if(NOT isValid("email", arguments.email)){
      request.structReturn.messages.append("Please enter an email.");
      request.structReturn.error = true;
    }

    if(len(trim(arguments.password)) LT 6){
      request.structReturn.messages.append("Password should be at least 6 characters.");
      request.structReturn.error = true;
    }

    if(NOT request.structReturn.error){

      // var qDetails = userService.qGetLoginUser(arguments.email, arguments.password);
      qDetails.recordCount = 1;
      if(qDetails.recordCount){

        var token = application.obj.jwt.encode(
          {
            userID=1
          }
          , request.cryptKey, 'HS256'
        );
        request.structReturn.data['token'] = token;
        request.structReturn.data['useremail'] = arguments.email;

        request.structReturn.messages.append("You successfully logged in.");

        arguments.password = hash(arguments.password, "SHA-256", "UTF-8");

      }else{
        request.structReturn.messages.append("Email or password is wrong.");
        request.structReturn.error = true;
      }

    }else{
      request.headerCode = 422;
    }

  }

  /**
  * Save a new customer
  */
  function customerSave(
    required string name, string email, string phone
  ) {

    // var result = userService.qCustomerSave(arguments.name, arguments.email, arguments.phone);
    var result = 1;
    if(result){
      request.structReturn.data['customerID'] = result;
      request.structReturn.messages.append("Successfully saved.");
    }else{
      request.structReturn.messages.append("Please try again could not save data.");
    }

  }

  /**
  * Search a new customer
  */
  function customerSearch(
    string searchText, numeric maxRows = 10, numeric page = 1
  ) {

    // get data
    // var qtotalRecords = userService.qCustomerSearch(searchText=arguments.searchText);
    // request.structReturn.data['pagination'] = utilService.paginationStruct(arguments.maxRows,arguments.page,qtotalRecords.recordCount);
    // var qCustomers = userService.qCustomerSearch(arguments.searchText, arguments.maxRows, request.structReturn.data.pagination.offset);
    // var aResult = utilService.queryToArray(qCustomers,'id,name,email,phone');
    // request.structReturn.data['customers'] = aResult;

    var qtotalRecords = queryNew('');
    request.structReturn['pagination'] = utilService.paginationStruct(arguments.maxRows,arguments.page,qtotalRecords.recordCount);
    var qCustomers = queryNew('id,name,email,phone');
    var aResult = utilService.queryToArray(qCustomers,'id,name,email,phone');
    request.structReturn.data = aResult;

  }

  /**
  * Get a customer details by customer id
  * @id customer id
  */
  function customerDetail(
    required numeric id
  ) {

    // get data
    // var result = userService.qCustomerGet(arguments.id);
    result.recordCount = 1;
    if(result.recordCount){
      request.structReturn.data['name'] = 'result.name';
      request.structReturn.data['email'] = 'result.email';
      request.structReturn.data['phone'] = 'result.phone';
    }else{
      request.structReturn.messages.append("Please try again could not find data.");
    }
  }

  /**
  * Update customer details
  */
  function customerUpdate(
    required numeric id, required string name, string email, string phone
  ) {

    // update
    // var result = userService.qCustomerUpdate(
    //  arguments.id, arguments.name, arguments.email, arguments.phone
    // );
    result = 1;
    if(result){
      request.structReturn.messages.append("Successfully updated.");
    }else{
      request.structReturn.messages.append("Please try again could not save data.");
    }
  }

  /**
  * Delete a customer
  * @id customer id
  */
  function customerDelete( required numeric id ) {
    // var result = userService.qCustomerDelete(arguments.id);
    result = 1;
    if(result){
      request.structReturn.messages.append("Successfully deleted.");
    }else{
      request.structReturn.messages.append("Please try again could not delete data.");
    }
  }

}
