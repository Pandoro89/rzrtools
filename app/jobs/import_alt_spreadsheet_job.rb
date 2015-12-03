require "google/api_client"
require "google_drive"

class ImportAltSpreadsheetJob < Resque::Job
  @queue = :low 

  def self.perform()

    # The client ID and client secret you obtained in the step above.
    CLIENT_ID = ...
    CLIENT_SECRET = ...

    session = GoogleDrive.saved_session("./stored_token.json", nil, CLIENT_ID, CLIENT_SECRET)


    # Same as the code above to get access_token...

    # Creates a session.
    session = GoogleDrive.login_with_oauth(access_token)

    # First worksheet of
    # https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
    # Or https://docs.google.com/a/someone.com/spreadsheets/d/pz7XtlQC-PYx-jrVMJErTcg/edit?usp=drive_web
    ws = session.spreadsheet_by_key("pz7XtlQC-PYx-jrVMJErTcg").worksheets[0]

    # Gets content of A2 cell.
    p ws[2, 1]  #==> "hoge"

    # Changes content of cells.
    # Changes are not sent to the server until you call ws.save().
    ws[2, 1] = "foo"
    ws[2, 2] = "bar"
    ws.save

    # Dumps all cells.
    (1..ws.num_rows).each do |row|
      (1..ws.num_cols).each do |col|
        p ws[row, col]
      end
    end

    # Yet another way to do so.
    p ws.rows  #==> [["fuga", ""], ["foo", "bar]]

    # Reloads the worksheet to get changes by other clients.
    ws.reload
  end
end