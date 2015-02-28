# https://practicingruby.com/articles/binary-file-formats
class BMP
  PIXEL_ARRAY_OFFSET = 54
  BITS_PER_PIXEL     = 24
  DIB_HEADER_SIZE    = 40

  def initialize(bmp_filename)
    File.open(bmp_filename, "rb") do |file|
      read_bmp_header(file) # does some validations
      read_dib_header(file) # sets @width, @height
      read_pixels(file)     # populates the @pixels array
    end
  end

  attr_reader :width, :height

  def [](x,y)
    @pixels[y][x]
  end

  def read_bmp_header(file)
    header = file.read(14)
    magic_number, file_size, reserved1,
    reserved2, array_location = header.unpack("A2Vv2V")

    fail "Not a bitmap file!" unless magic_number == "BM"

    unless file.size == file_size
      fail "Corrupted bitmap: File size is not as expected"
    end

    unless array_location == PIXEL_ARRAY_OFFSET
      fail "Unsupported bitmap: pixel array does not start where expected"
    end
  end

  def read_dib_header(file)
    header = file.read(40)

    header_size, width, height, planes, bits_per_pixel,
    compression_method, image_size, hres,
    vres, n_colors, i_colors = header.unpack("Vl<2v2V2l<2V2")

    unless header_size == DIB_HEADER_SIZE
      fail "Corrupted bitmap: DIB header does not match expected size"
    end

    unless planes == 1
      fail "Corrupted bitmap: Expected 1 plane, got #{planes}"
    end

    unless bits_per_pixel == BITS_PER_PIXEL
      fail "#{bits_per_pixel} bits per pixel bitmaps are not supported"
    end

    unless compression_method == 0
      fail "Bitmap compression not supported"
    end

    unless image_size + PIXEL_ARRAY_OFFSET == file.size
      fail "Corrupted bitmap: pixel array size isn't as expected"
    end

    @width, @height = width, height
  end

  def read_pixels(file)
    @pixels = Array.new(@height) { Array.new(@width) }

    (@height-1).downto(0) do |y|
      0.upto(@width - 1) do |x|
        @pixels[y][x] = file.read(3).unpack("H6").first
      end
      advance_to_next_row(file)
    end
  end

  def advance_to_next_row(file)
    padding_bytes = @width % 4
    return if padding_bytes == 0

    file.pos += padding_bytes
  end
end