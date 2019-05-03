require_relative "../config/environment.rb"
require "pry"
class Student

 attr_accessor :name, :id, :grade

 def initialize(id=nil, name, grade)
  @id=id
  @name=name
  @grade=grade
 end

 def self.create_table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
      ID INTEGER PRIMARY KEY,
      NAME TEXT,
      GRADE INTEGER
    )
    SQL
    DB[:conn].execute(sql)
 end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
 end

 def save
  if self.id
    self.update
  else
    sql = <<-SQL 
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ? 
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM students
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

end
