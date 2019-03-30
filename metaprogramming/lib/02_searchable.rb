require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    # ...
    values = params.values 
    where_statement = []
    params.map { |k,_v| where_statement << "#{k} = ?" }
    data = DBConnection.execute(<<-SQL, *values)
      SELECT 
        * 
      FROM 
        #{self.table_name}
      WHERE 
        #{where_statement.join(" AND ")}
    SQL
    results = data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
