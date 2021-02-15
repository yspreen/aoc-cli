module AocCli
	module Database
		class Query
			require 'sqlite3'
			attr_reader :db
			def initialize(path:)
				@db = SQLite3::Database.open(path)
			end
			def select(t:, cols:"*", data:)
				db.execute(
				"SELECT #{cols} FROM #{t} "\
				"WHERE #{data
					.map{|k, v| "#{k} = #{v}"}
					.join(" AND ")}")
			end
			def table(t:, cols:)
				db.execute(
				"CREATE TABLE IF NOT EXISTS "\
				"#{t}(#{cols
					.map{|c, t| "#{c} #{t}"}
					.join(", ")})"); self
			end
			def insert(t:, val:)
				db.execute(
					"INSERT INTO #{t} "\
					"VALUES(#{val.join(", ")})"
				); self
			end
		end
		class Log
			attr_reader :attempt, :db
			def initialize(attempt:)
				@attempt = attempt
				@db = Query.new(path:Paths::Database
					.cfg("attempts"))
					.table(t:attempt.user, cols:cols)
			end
			def correct
				db.insert(t:attempt.user, 
						  val:data << 1 << 0 << 0)
			end
			def incorrect(high:, low:)
				db.insert(t:attempt.user, val:data.push(0)
					.push(parse_hi_lo(high:high, low:low)))
			end
			def parse_hi_lo(high:, low:)
				[high ? 1 : 0, low ? 1 : 0]
			end
			def data
				["'#{Time.now}'",
				 "'#{attempt.year}'",
				 "'#{attempt.day}'",
				 "'#{attempt.part}'",
				 "'#{attempt.answer}'"]
			end
			def cols
				{"time"=>:TEXT, 
				 "year"=>:INT, 
				 "day"=>:INT, 
				 "part"=>:INT, 
				 "answer"=>:TEXT, 
				 "correct"=>:INT,
				 "low"=>:INT,
				 "high"=>:INT}
			end
		end
		class PuzzleStats
			attr_reader :user, :year, :day, :part, :time, :db
			def initialize(u:Metafile.get(:user),
						   y:Metafile.get(:year),
						   d:Metafile.get(:day),
						   p:Metafile.get(:part))
				@user = Validate.user(u)
				@year = Validate.year(y)
				@day  = Validate.day(d)
				@part = Validate.part(p)
				@time = Time.now
				@db   = Query.new(path:Paths::Database.cfg("#{user}"))
							 .table(t:"stats", cols:cols)
			end
			def init
				db.insert(t:"stats", val:data)
			end
			def data
				["'#{year}'",
				 "'#{day}'",
				 "'#{part}'",
				 "'#{time}'",
				 "'0'",
				 "NULL"]
			end
			def cols
				    {year: :INT, 
				      day: :INT, 
				     part: :INT, 
				  dl_time: :TEXT,
				 attempts: :INT,
				 end_time: :TEXT}
			end
		end
		class PuzzleComplete < PuzzleStats
			
		end
	end
end 
