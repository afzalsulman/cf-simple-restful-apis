component {

  /**
   * Constructor
   */
  user function init() {
    return this;
  }

  public query function qGetLoginUser( required string email, required string password ) {
    var paramsStruct = {};
    var sqlString = "
      SELECT
        u.`id`,
        u.`name`,
        u.`email`,
        u.`isActive`,
      FROM
        `user` u
      WHERE
        u.`email` = :email
      AND
        u.`password` = :password";

    structAppend( paramsStruct, { email = { value=arguments.email, cfsqltype="varchar" } } );
    structAppend( paramsStruct, { password = { value=arguments.password, cfsqltype="varchar" } } );

    var qResult = queryNew('');
    qResult = queryExecute( sqlString, paramsStruct , { result="qResult" } );

    return qResult;
  }

  public numeric function qSaveUser(
    required string name, required string email, required string password
  ) {
    var paramsStruct = {};
    var sqlString = "
      INSERT INTO
        `user`
        (
          `name`,
          `email`,
          `password`
        )
      VALUES( :name, :email, :password )";

    structAppend( paramsStruct, { name = { value=arguments.name, cfsqltype="varchar" } } );
    structAppend( paramsStruct, { email = { value=arguments.email, cfsqltype="varchar" } } );
    structAppend( paramsStruct, { password = { value=arguments.password, cfsqltype="varchar" } } );

    var qResult = {};
    queryExecute( sqlString, paramsStruct , { result="qResult" } );
    return qResult.generatedKey;
  }

  // 
  // customer queries
  // 
  // search details
  public query function qCustomerSearch(
    string searchText, numeric maxRows, numeric stepOffset
  ) {
    var paramsStruct = {};
    var sqlString = "
      SELECT
        c.id,
        c.name,
        c.email,
        c.phone
      FROM
        customer c
      WHERE
        1=1";

    if( len(trim(arguments.searchText)) ){
      sqlString = sqlString & " c.name LIKE :name
        OR c.email LIKE :email
        OR c.phone LIKE :phone";

      structAppend( paramsStruct, { name = { value="%#trim(arguments.searchText)#%", cfsqltype="varchar" } } );
      structAppend( paramsStruct, { email = { value="%#trim(arguments.searchText)#%", cfsqltype="varchar" } } );
      structAppend( paramsStruct, { phone = { value="%#trim(arguments.searchText)#%", cfsqltype="varchar" } } );
    }

    sqlString = sqlString & " ORDER BY c.id DESC LIMIT :limitValue OFFSET :offsetValue";
      structAppend( paramsStruct, { limitValue = { value=arguments.maxRows, cfsqltype="integer" } } );
      structAppend( paramsStruct, { offsetValue = { value=arguments.stepOffset, cfsqltype="integer" } } );
    if( isValid("integer", arguments.maxRows) AND isValid("integer", arguments.stepOffset) ){
      
    }

    return queryExecute( sqlString, paramsStruct , { result="qResult" } );
  }

  // save details
  public numeric function qCustomerSave(
    required string name, string email, string phone
  ) {
    var paramsStruct = {};
    var sqlString = "
      INSERT INTO
        `customer`
      (
        `name`, `email`, `phone`
      )
      VALUES
      (
        :name,:email,:phone
      )";

    structAppend( paramsStruct, { name = { value=arguments.name, cfsqltype="varchar" } } );
    structAppend( paramsStruct, { email = { value=arguments.email, cfsqltype="varchar", null="#trim(arguments.email) EQ ''#" } } );
    structAppend( paramsStruct, { phone = { value=arguments.phone, cfsqltype="varchar", null="#trim(arguments.phone) EQ ''#" } } );

    var qResult = {};
    queryExecute( sqlString, paramsStruct , { result="qResult" } );
    return qResult.generatedKey;
  }

  // get details
  public query function qCustomerGet( string id, string email, string phone ) {
    var paramsStruct = {};
    var sqlString = "
      SELECT
        c.id,
        c.name,
        c.email,
        c.phone
      FROM
        customer c
      WHERE
        1 = 1";
    if(isValid('integer', arguments.id)){
      sqlString = sqlString & " AND c.id = :id";
      structAppend( paramsStruct, { id = { value=arguments.id, cfsqltype="integer" } } );
    }
    if(len(trim(arguments.email))){
      sqlString = sqlString & " AND c.email = :email";
      structAppend( paramsStruct, { email = { value=arguments.email, cfsqltype="varchar" } } );
    }
    if(len(trim(arguments.phone))){
      sqlString = sqlString & " AND c.phone = :phone";
      structAppend( paramsStruct, { phone = { value=arguments.phone, cfsqltype="varchar" } } );
    }

    return queryExecute( sqlString, paramsStruct , { result="qResult" } );
  }

  // update query
  public numeric function qCustomerUpdate(
    required numeric id, required string name, string email, string phone
  ) {
    var paramsStruct = {};
    var sqlString = "
      UPDATE customer c
      SET";

    if( len(trim(arguments.email)) ){
      sqlString = sqlString & " c.email = :email,";
      structAppend( paramsStruct, { email = { value=arguments.email, cfsqltype="varchar" } } );
    }
    if( len(trim(arguments.phone)) ){
      sqlString = sqlString & " c.phone = :phone,";
      structAppend( paramsStruct, { phone = { value=arguments.phone, cfsqltype="varchar" } } );
    }

    sqlString = sqlString & " c.name = :name";
    sqlString = sqlString & " WHERE
      c.id = :id";

    structAppend( paramsStruct, { name = { value=arguments.name, cfsqltype="varchar" } } );
    structAppend( paramsStruct, { id = { value=arguments.id, cfsqltype="integer" } } );

    var qResult = {};
    queryExecute( sqlString, paramsStruct , { result="qResult" } );
    return qResult.recordCount;
  }
    // delete query
  public numeric function qCustomerDelete( required numeric id ) {
    var paramsStruct = {};
    var sqlString = "DELETE
        c
      FROM
        customer c
      WHERE
        c.id = :id";
    structAppend( paramsStruct, { id = { value=arguments.id, cfsqltype="integer" } } );

    var qResult = {};
    queryExecute( sqlString, paramsStruct , { result="qResult" } );
    return qResult.recordCount;
  }

}
