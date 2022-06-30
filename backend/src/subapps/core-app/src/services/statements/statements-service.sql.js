var moment = require('moment');
var now = moment();

exports.statementsSQLQueries = {
  getStatements:  "CALL getStatement(0);",
  getStatement:   "CALL getStatement(?);",
  createStatement: "CALL crudStatement(0, ?, ?, ?, ?, ?, 1, 0);",
  updateStatement: "CALL crudStatement(?, ?, ?, ?, ?, ?, ?, 0);",
  deleteStatement: "CALL crudStatement(?, '', '', '', 0, '" + now.format('YYYY-MM-DD').toString() + "', 0, 1);",
};