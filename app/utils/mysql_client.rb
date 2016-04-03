require 'mysql2'
require_relative 'common_util'

# Util class for creating mysql client instance.
class MysqlClient

  REQUIRED_TABLES = %w(acct acct_desc security_question)

  # Singleton mysql client instance.
  @client = nil

  # Flag to indicate if the database has been initialized.
  @initialized = false

  # Flag to indicate if the tables are up to date.
  @updated = false

  # Return the mysql client instance with mysql connection.
  #
  # @param host
  # @param port
  # @param database
  # @param username
  # @param password
  # @return the initialized mysql client
  def self.open(host = 'localhost', port = '3306', database = 'am', username = 'root', password = '')
    self.close

    unless @initialized
      init_db(host, port, database, username, password)
    end

    connect(host, port, database, username, password)

    unless @updated
      self.update_table(database)
    end

    return @client
  end

  # Close the mysql client.
  def self.close
    if @client
      @client.close
      @client = nil
    end
  end

  # Open a new mysql connection.
  #
  # @param host
  # @param port
  # @param database
  # @param username
  # @param password
  def self.connect(host, port, database, username, password)
    begin
      CommonUtil.log_debug("Establishing mysql client instance, host: #{host}, port: #{port}, database = #{database}, username: #{username}")
      @client = Mysql2::Client.new(:host => host, :port => port, :database => database, :username => username, :password => password)
    rescue Mysql2::Error => e
      self.close
      raise Exception.new("Issue establishing mysql client, error: #{e}")
    end
  end

  # Add new tables.
  #
  # @param database
  def self.update_table(database)
    if @client

      tables = @client.query('SHOW tables').collect { |row| row.values }.flatten

      if (tables - REQUIRED_TABLES).empty?
        CommonUtil.log_debug("Tables are up to date for database: #{database}")
        @updated = true
      else
        CommonUtil.log_debug("Initializing tables for database: #{database}")
        `mysql -u root #{database} < #{Dir.home}/Workspace/projects/AcctManagerCLI/app/sql/create.sql;`

        if $?.exitstatus != 0
          raise Exception.new('Issue executing database creating script')
        end

        @updated = true
      end
    else
      raise Exception.new('Unable to execute database creating script. No connection')
    end
  end

  # Initialize the mysql client.
  #
  # @param host
  # @param port
  # @param database
  # @param username
  # @param password
  def self.init_db(host, port, database, username, password)
    CommonUtil.log_debug("Using database: #{database}")

    begin
      connect(host, port, nil, username, password)
      result = @client.query('SHOW databases;').collect { |row| row.values }.flatten

      if result.include?(database)
        CommonUtil.log_debug("Database: #{database} exists, connecting...")
        @initialized = true
      else
        CommonUtil.log_debug("Database: #{database} doesn't exist, creating...")
        @client.query("CREATE database #{database};")

        @initialized = true
      end
    rescue Mysql2::Error => e
      self.close
      raise Exception.new("Issue initializing database: #{database}, error: #{e}")
    end
    self.close
  end
end
