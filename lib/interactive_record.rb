 require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  
  def self.table_name
    self.to_s.downcase.pluralize
  end #.table_name
  
  
  def self.column_names
    DB[:conn].results_as_hash = true
    
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    
    table_info.each {|row| column_names << row['name']}
    column_names.compact
  end #.column_names
  
  
  def initialize(attributes={})
    attributes.each {|property, value| self.send("#{property}=", value)}
  end #initialize
  
  
  def table_name_for_insert
    self.class.table_name
  end #table_name_for_insert
  
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end #col_names_for_insert
    
    
  def values_for_insert
    values = []
    self.class.column_names.each {|col_name| values << "'#{send(col_name)}'" unless send(col_name).nil?}
    values.join(", ")
  end #values_for_insert
  
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end #save
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name)
  end #.find_by_name
  
  def self.find_by(attributes)
    value = attributes.values.first
    alt_value = value.class == Fixnum ? value : "'#{value}'"
    
    sql = "SELECT * FROM #{self.table_name} WHERE #{attributes.keys.first} = #{alt_value}"
    DB[:conn].execute(sql)
  end #.find_by(attributes)
  
  
end #Class InteractiveRecord