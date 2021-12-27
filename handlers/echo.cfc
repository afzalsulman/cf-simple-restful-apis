/**
 * A basic handler
**/
component{

	/**
	 * Constructor
	 */
	public echo function init() {
		return this;
	}

	public function index( ) {
		request.messages = request.messages.append("Welcome to my RESTFul Service");
	}

}
