
require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

   def self.create(attr_hash)
     dog = Dog.new(attr_hash)
     dog.save
   end

   def self.find_by_id(id)
     result_hash = {}
     sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
     SQL
     result = DB[:conn].execute(sql, id)[0]
     headers = DB[:conn].execute("PRAGMA table_info(dogs)").map {|col| col[1]}

     headers.collect.with_index do |header,i|
       binding.pry
       result_hash.send("#{header}: => #{result[i]}")
        result_hash[:header] = result[i]

     end
     binding.pry

     dog = Dog.new(result_hash)
     dog
   end
end
