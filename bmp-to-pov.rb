require './BMP.rb'

bmp = BMP.new("heart.bmp")

File.open("bmp.c", 'w') do |file|
	start_file = File.open("start_c.txt")
	IO.copy_stream(start_file, file)
	for x in 0...bmp.width
		bitstr = ""
		for y in 0...bmp.height
			if bmp[x,y] == "000000"
				bitstr+="0"
			else
				bitstr+="1"
			end
		end
		file.puts("B8(#{bitstr}),")
	end
	end_file = File.open("end_c.txt")
	IO.copy_stream(end_file, file)
end