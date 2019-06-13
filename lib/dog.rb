class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (
      name, breed
    )
    VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, name, breed)

    new_id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    @id = new_id
    self
  end

  def self.create(hash)
    new_dog = new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?;
    SQL

    row = DB[:conn].execute(sql, id)[0]

    hash = { name: row[1], breed: row[2], id: id }

    new(hash)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL

    poss_dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !poss_dog.empty?
      return find_by_id(poss_dog[0][0])
    end

    create(hash)
  end

  def self.new_from_db(row)
    hash = { id: row[0], name: row[1], breed: row[2] }
    new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name)[0]
    hash = { id: row[0], name: row[1], breed: row[2] }
    new(hash)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, name, breed, id)
  end
end
