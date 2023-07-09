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
		request.structReturn.messages.append("Welcome to my RESTFul Service.");
	}

}
