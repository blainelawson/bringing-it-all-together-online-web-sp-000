
require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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
     sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
     SQL

     result = DB[:conn].execute(sql, id)[0]
     id = result[0]
     name = result[1]
     breed = result[2]

     dog = Dog.new(name: name, id: id, breed: breed)
   end

   def self.find_or_create_by(attr_hash)
     sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
     SQL
# binding.pry
     dog = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])

     if !dog.empty?
       dog_data = dog[0]
       binding.pry
       dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
     else
       dog = self.create(name: attr_hash[:name], breed: attr_hash[:breed])
     end
   end
end
