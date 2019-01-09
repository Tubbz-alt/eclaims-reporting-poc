require 'pg'

require 'model/shell_adapter'

class PostgresDB
  attr_accessor :connection

  def initialize( args={} )
    self.connection = PG::Connection.new(args)
  end

  def import_csv( file_path:, table_name:, delimiter: ',' )
    sql = [
      '\copy ', table_name, " from '", file_path, "' with DELIMITER '", delimiter, "' CSV HEADER;"
    ].join
    exec_via_cmd_line(sql)
  end

  def exec_via_cmd_line( sql )
    puts ShellAdapter.capture_with_stdin(cmd: cmd_line_args, stdin: sql)
  end

  def cmd_line_args
    [
      "PGPASSWORD=" + connection.pass,
      "psql",
      "-U", connection.user,
      "-h", connection.host,
      "-d", connection.db,
      "-p", connection.port,
      "--single-transaction"
    ]
  end

  def exec_file( file_path )
    puts ShellAdapter.output_of( cmd_line_args + ['-f', file_path])
  end

  def drop_if_exists( table_name )
    sql = [
      "DROP TABLE IF EXISTS", table_name
    ].join(' ')
    connection.exec(sql)
  end

  def truncate( table_name: )
    sql = [
      "TRUNCATE TABLE", table_name
    ].join
    connection.exec(sql)
  end
end
