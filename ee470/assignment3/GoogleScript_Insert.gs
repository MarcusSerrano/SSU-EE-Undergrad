/** 
 * Minimal GAS Web App to append rows to a Google Sheet.
 * Deploy → Manage deployments → Web app → *New version* → Deploy.
 * POST to: https://script.google.com/macros/s/<DEPLOYMENT_ID>/exec
 */

var SHEET_ID = ""; // spreadsheet file ID
var SHEET_NAME = "ESP_RawData"                                 // worksheet/tab name (must match exactly)

function doPost(e) {
  var p = e && e.parameter ? e.parameter : {};
  var dateStr = p.date || Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  var sensor  = Number(p.sensor);

  var sh = SpreadsheetApp.openById(SHEET_ID).getSheetByName(SHEET_NAME);

  // next empty row based on column A only (assumes A1 is header)
  var next = sh.getRange("A:A").getValues().filter(String).length + 1;

  sh.getRange(next, 1, 1, 2).setValues([[dateStr, sensor]]);
  return ContentService.createTextOutput('OK');
}
