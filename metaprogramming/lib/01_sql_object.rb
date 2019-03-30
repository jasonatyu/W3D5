require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    if @columns.nil?
      data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
      @columns = data[0].map(&:to_sym)
    else 
      @columns
    end
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do 
        attributes[:"#{column}"]
      end
      define_method(:"#{column}=") do |val|
        attributes[:"#{column}"] = val
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    if self.to_s == 'Human'
      self.table_name = 'humans'
    else 
      @table_name = self.to_s.tableize 
    end
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
      SELECT 
        * 
      FROM 
        #{self.table_name}
    SQL
    self.parse_all(data)
  end

  def self.parse_all(results)
    # ...
    res = []
    results.each do |result|
      res << self.new(result)
    end
    res
  end

  def self.find(id)
    # ...
    data = DBConnection.execute(<<-SQL, id)
      SELECT 
        * 
      FROM 
        #{self.table_name}
      WHERE 
        id = ?
    SQL
    data.empty? ? nil : self.new(data[0])
  end

  def initialize(params = {})
    # ...
    columns = self.class.columns
    params.each do |k, v|
      sym_k = k.to_sym 
      raise "unknown attribute '#{sym_k}'" if !columns.include?(sym_k)
      self.send("#{sym_k}=", v)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    values = []
    self.class.columns.map { |column| values << self.send(column) }
    values
  end

  def insert
    # ...
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO 
        #{self.class.table_name} (#{self.class.columns.join(',')})
      VALUES
        (#{(["?"] * attribute_values.length).join(',')})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    set_arr = []
    self.class.columns.map { |column| set_arr << "#{column} = ?" }
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_arr.join(',')}
      WHERE
        id = ?
    SQL
  end

  def save
    # ...
    if self.id.nil?
      insert 
    else 
      update
    end
  end
  
end
