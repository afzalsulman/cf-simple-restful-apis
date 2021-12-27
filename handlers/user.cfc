/**
 * User requests handler
**/
component{

	/**
	 * Constructor
	**/
	user function init( ) {
		userService = new models.user();
		utilService = application.util;
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

		if(NOT len(trim(arguments.name))){
			request.messages = request.messages.append("Please enter a name.");
			request.error = true;
		}

		if(NOT isValid("email", arguments.email)){
			request.messages = request.messages.append("Please enter an email.");
			request.error = true;
		}

		if(len(trim(arguments.password)) LT 6){
			request.messages = request.messages.append("Password should be at least 6 characters.");
			request.error = true;
		}

		if(NOT request.error){

			var token = application.jwt.encode(
				{	userID=1
				}, request.cryptKey, 'HS256'
			);

			request.data['token'] = token;
			request.data['username'] = arguments.name;
			request.data['useremail'] = arguments.email;
			request.messages = request.messages.append("You are successfully registered");

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
			request.messages = request.messages.append("Please enter an email.");
			request.error = true;
		}

		if(len(trim(arguments.password)) LT 6){
			request.messages = request.messages.append("Password should be at least 6 characters.");
			request.error = true;
		}

		if(NOT request.error){

			// var qDetails = userService.qGetLoginUser(arguments.email, arguments.password);
			qDetails.recordCount = 1;
			if(qDetails.recordCount){

				var token = application.jwt.encode(
					{
						userID=1
					}
					, request.cryptKey, 'HS256'
				);
				request.data['token'] = token;
				request.data['useremail'] = arguments.email;

				request.messages = request.messages.append("You successfully logged in.");

				arguments.password = hash(arguments.password, "SHA-256", "UTF-8");

			}else{
				request.messages = request.messages.append("Email or password is wrong.");
				request.error = true;
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

		if(NOT len(trim(arguments.name))){
			request.messages = request.messages.append("Please enter a name.");
			request.error = true;
		}

		if(NOT request.error){
			// var result = userService.qCustomerSave(arguments.name, arguments.email, arguments.phone);
			var result = 1;
			if(result){
				request.data['customerID'] = result;
				request.messages = request.messages.append("Successfully saved.");
			}else{
				request.messages = request.messages.append("Please try again could not save data.");
			}
		}

	}

	/**
	* Search a new customer
	*/
	function customerSearch(
		string searchText, numeric maxRows, numeric page 
	) {

		// get data
		// var qtotalRecords = userService.qCustomerSearch(searchText=arguments.searchText);
		// request.data['pagination'] = utilService.paginationStruct(arguments.maxRows,arguments.page,qtotalRecords.recordCount);
		// var qCustomers = userService.qCustomerSearch(arguments.searchText, arguments.maxRows, request.data.pagination.offset);
		// var aResult = utilService.queryToArray(qCustomers,'id,name,email,phone');
		// request.data['customers'] = aResult;

		var qtotalRecords = queryNew('');
		request.data['pagination'] = utilService.paginationStruct(arguments.maxRows,arguments.page,qtotalRecords.recordCount);
		var qCustomers = queryNew('id,name,email,phone');
		var aResult = utilService.queryToArray(qCustomers,'id,name,email,phone');
		request.data['customers'] = aResult;

	}

	/**
	* Get a customer details by customer id
	* @id customer id
	*/
	function customerDetail(
		required numeric id
	) {

		if(NOT request.error){
			// get data
			// var result = userService.qCustomerGet(arguments.id);
			result.recordCount = 1;
			if(result.recordCount){
				request.data['name'] = 'result.name';
				request.data['email'] = 'result.email';
				request.data['phone'] = 'result.phone';
			}else{
				request.messages = request.messages.append("Please try again could not find data.");
			}
		}
	}

	/**
	* Update customer details
	*/
	function customerUpdate(
		required numeric id, required string name, string email, string phone
	) {

		if(NOT len(trim(arguments.name))){
			request.messages = request.messages.append("Please enter a name.");
			request.error = true;
		}

		if(NOT request.error){
			// update
			// var result = userService.qCustomerUpdate(
			// 	arguments.id, arguments.name, arguments.email, arguments.phone
			// );
			result = 1;
			if(result){
				request.messages = request.messages.append("Successfully updated.");
			}else{
				request.messages = request.messages.append("Please try again could not save data.");
			}
		}
	}

	/**
	* Delete a customer
	* @id customer id
	*/
	function customerDelete( required numeric id ) {

		if(NOT request.error){
			// var result = userService.qCustomerDelete(arguments.id);
			result = 1;
			if(result){
				request.messages = request.messages.append("Successfully deleted.");
			}else{
				request.messages = request.messages.append("Please try again could not delete data.");
			}
		}

	}

}
