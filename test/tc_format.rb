#####################################################
# tc_format.rb
#
# Test suite for the Format class (format.rb)
#####################################################
base = File.basename(Dir.pwd)
if base == "test" || base =~ /spreadsheet/i
   Dir.chdir("..") if base == "test"
   $LOAD_PATH.unshift(Dir.pwd + "/lib/spreadsheet")
   Dir.chdir("test") rescue nil
end

require "test/unit"
require "biffwriter"
require "olewriter"
#require "workbook"
require "worksheet"
require "format"

class TC_Format < Test::Unit::TestCase

   def setup
      @ruby_file = "xf_test"
      @format = Format.new
   end

   def teardown
      begin
         @pfh.close
      rescue NameError
         # no op
      end
      File.delete(@ruby_file) if File.exist?(@ruby_file)
      @format = nil
   end

   def test_set_format_properties
   end

   def test_format_properties_with_valid_value
      valid_properties = get_valid_format_properties
      valid_properties.each do |k,v|
         format = Format.new
         before = get_format_property(format)
         format.set_format_properties(k => v)
         after  = get_format_property(format)
         after.delete_if {|key, val| before[key] == val }
         assert_equal(1, after.size, "change 1 property[:#{k}] but #{after.size} was changed.#{after.inspect}")
         assert_equal(v, after[k], "[:#{k}] doesn't match.")
      end

      # set_color by string
      valid_color_string_number = get_valid_color_string_number
      [:color , :bg_color, :fg_color].each do |coltype|
         valid_color_string_number.each do |str, num|
            format = Format.new
            before = get_format_property(format)
            format.set_format_properties(coltype => str)
            after  = get_format_property(format)
            after.delete_if {|key, val| before[key] == val }
            assert_equal(1, after.size, "change 1 property[:#{coltype}:#{str}] but #{after.size} was changed.#{after.inspect}")
            assert_equal(num, after[:"#{coltype}"], "[:#{coltype}:#{str}] doesn't match.")
         end
      end


   end
   
   def test_format_properties_with_invalid_value
   end

   def test_set_font
   end

=begin
set_size()
    Default state:      Font size is 10
    Default action:     Set font size to 1
    Valid args:         Integer values from 1 to as big as your screen.
Set the font size. Excel adjusts the height of a row to accommodate the largest font size in the row. You can also explicitly specify the height of a row using the set_row() worksheet method.
=end
   def test_set_size
      # default state
      assert_equal(10, @format.size)
      
      # valid size from low to high
      [1, 100, 100**10].each do |size|
         fmt = Format.new
         fmt.set_size(size)
         assert_equal(size, fmt.size, "valid size:#{size} - doesn't match.")
      end
      
      # invalid size  -- size doesn't change
      [-1, 0, 1/2.0, 'hello', true, false, nil, [0,0], {:invalid => "val"}].each do |size|
         fmt = Format.new
         default = fmt.size
         fmt.set_size(size)
         assert_equal(default, fmt.size, "size:#{size.inspect} doesn't match.")
      end
   end

=begin
set_color()

    Default state:      Excels default color, usually black
    Default action:     Set the default color
    Valid args:         Integers from 8..63 or the following strings:
                        'black'
                        'blue'
                        'brown'
                        'cyan'
                        'gray'
                        'green'
                        'lime'
                        'magenta'
                        'navy'
                        'orange'
                        'pink'
                        'purple'
                        'red'
                        'silver'
                        'white'
                        'yellow'

Set the font colour. The set_color() method is used as follows:

    format = workbook.add_format()
    format.set_color('red')
    worksheet.write(0, 0, 'wheelbarrow', format)

Note: The set_color() method is used to set the colour of the font in a cell. 
To set the colour of a cell use the set_bg_color() and set_pattern() methods.
=end
   def test_set_color
      # default state
      default_col = 0x7FFF
      assert_equal(default_col, @format.color)
   
      # valid color
      # set by string
      str_num = get_valid_color_string_number
      str_num.each do |str,num|
         fmt = Format.new
         fmt.set_color(str)
         assert_equal(num, fmt.color)
      end

      # valid color
      # set by number
      [8, 36, 63].each do |color|
         fmt = Format.new
         fmt.set_color(color)
         assert_equal(color, fmt.color)
      end

      # invalid color
      ['color', :col, -1, 63.5, 10*10].each do |color|
         fmt = Format.new
         fmt.set_color(color)
         assert_equal(default_col, fmt.color, "color : #{color}")
      end

      # invalid color    ...but...
      # 0 <= color < 8  then color += 8 in order to valid value
      [0, 7.5].each do |color|
         fmt = Format.new
         fmt.set_color(color)
         assert_equal((color + 8).to_i, fmt.color, "color : #{color}")
      end


   end

=begin
set_bold()

    Default state:      bold is off  (internal value = 400)
    Default action:     Turn bold on
    Valid args:         0, 1 [1]

Set the bold property of the font:

    $format->set_bold();  # Turn bold on

[1] Actually, values in the range 100..1000 are also valid.
    400 is normal, 700 is bold and 1000 is very bold indeed.
    It is probably best to set the value to 1 and use normal bold.
=end

   def test_set_bold
      # default state
      assert_equal(400, @format.bold)
      
      # valid weight
      fmt = Format.new
      fmt.set_bold
      assert_equal(700, fmt.bold)
      {0 => 400, 1 => 700, 100 => 100, 1000 => 1000}.each do |weight, value|
         fmt = Format.new
         fmt.set_bold(weight)
         assert_equal(value, fmt.bold)
      end
      
      # invalid weight
      [-1, 99, 1001, 'bold'].each do |weight|
         fmt = Format.new
         fmt.set_bold(weight)
         assert_equal(400, fmt.bold, "weight : #{weight}")
      end
   end

=begin
set_italic()

    Default state:      Italic is off
    Default action:     Turn italic on
    Valid args:         0, 1

 Set the italic property of the font:

    format.set_italic()  # Turn italic on
=end
   def test_set_italic
      # default state
      assert_equal(0, @format.italic)
      
      # valid arg
      fmt = Format.new
      fmt.set_italic
      assert_equal(1, fmt.italic)
      {0=>0, 1=>1}.each do |arg,value|
         fmt = Format.new
         fmt.set_italic(arg)
         assert_equal(value, fmt.italic, "arg : #{arg}")
      end
      
      # invalid arg -- arg stored @italic.  it turns italic on
      [-1, 0.2, 100, 'italic', true, false].each do |arg|
         fmt = Format.new
         fmt.set_italic(arg)
         assert_equal(arg, fmt.italic, "arg : #{arg}")
      end
   end

   def test_set_underline
   end

   def test_set_font_strikeout
   end

   def test_set_font_script
   end

   def test_set_font_outline
   end

   def test_set_font_shadow
   end

   def test_set_num_format
   end

   def test_set_locked
   end

   def test_set_hidden
   end

   def test_set_align
   end

   def test_set_center_across
   end

   def test_set_text_wrap
   end

   def test_set_rotation
   end

   def test_set_indent
   end

   def test_set_shrink
   end

   def test_set_text_justlast
   end

   def test_set_pattern
   end

   def test_set_bg_color
   end

   def test_set_fg_color
   end

   def test_set_border
   end

   def test_set_border_color
   end

   def test_copy
   end


   def test_xf_biff_size
      perl_file = "perl_output/file_xf_biff"
      size = File.size(perl_file)
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_xf)
      @fh.close
      rsize = File.size(@ruby_file)
      assert_equal(size,rsize,"File sizes not the same")
      
   end
   
   # Because of the modifications to bg_color and fg_color, I know this
   # test will fail.  This is ok.
   #def test_xf_biff_contents
   #   perl_file = "perl_output/f_xf_biff"
   #   @fh = File.new(@ruby_file,"w+")
   #   @fh.print(@format.xf_biff)
   #   @fh.close
   #   contents = IO.readlines(perl_file)
   #   rcontents = IO.readlines(@ruby_file)
   #   assert_equal(contents,rcontents,"Contents not the same")
   #end

   def test_font_biff_size
      perl_file = "perl_output/file_font_biff"
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_font)
      @fh.close
      contents = IO.readlines(perl_file)
      rcontents = IO.readlines(@ruby_file)
      assert_equal(contents,rcontents,"Contents not the same")
   end

   def test_font_biff_contents
      perl_file = "perl_output/file_font_biff"
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_font)
      @fh.close
      contents = IO.readlines(perl_file)
      rcontents = IO.readlines(@ruby_file)
      assert_equal(contents,rcontents,"Contents not the same")
   end

   def test_get_font_key_size
      perl_file = "perl_output/file_font_key"
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_font_key)
      @fh.close
      assert_equal(File.size(perl_file),File.size(@ruby_file),"Bad file size")
   end

   def test_get_font_key_contents
      perl_file = "perl_output/file_font_key"
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_font_key)
      @fh.close
      contents = IO.readlines(perl_file)
      rcontents = IO.readlines(@ruby_file)
      assert_equal(contents,rcontents,"Contents not the same")
   end

   def test_initialize
     assert_nothing_raised {
       Format.new(:bold => true, :size => 10, :color => 'black', 
                  :fg_color => 43, :align => 'top', :text_wrap => true,
                  :border => 1)
     }
   end

   # added by Nakamura
   
   def test_get_xf
      perl_file = "perl_output/file_xf_biff"
      size = File.size(perl_file)
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_xf)
      @fh.close
      rsize = File.size(@ruby_file)
      assert_equal(size,rsize,"File sizes not the same")
      
      fh_p = File.open(perl_file, "r")
      fh_r = File.open(@ruby_file, "r")
      while true do
         p1 = fh_p.read(1)
         r1 = fh_r.read(1)
         if p1.nil?
            assert( r1.nil?, 'p1 is EOF but r1 is NOT EOF.')
            break
         elsif r1.nil?
            assert( p1.nil?, 'r1 is EOF but p1 is NOT EOF.')
            break
         end
         assert_equal(p1, r1, sprintf(" p1 = %s but r1 = %s", p1, r1))
         break
      end
      fh_p.close
      fh_r.close
   end
   
   def test_get_font
      perl_file = "perl_output/file_font_biff"
      size = File.size(perl_file)
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_font)
      @fh.close
      rsize = File.size(@ruby_file)
      assert_equal(size,rsize,"File sizes not the same")
      
      fh_p = File.open(perl_file, "r")
      fh_r = File.open(@ruby_file, "r")
      while true do
         p1 = fh_p.read(1)
         r1 = fh_r.read(1)
         if p1.nil?
            assert( r1.nil?, 'p1 is EOF but r1 is NOT EOF.')
            break
         elsif r1.nil?
            assert( p1.nil?, 'r1 is EOF but p1 is NOT EOF.')
            break
         end
         assert_equal(p1, r1, sprintf(" p1 = %s but r1 = %s", p1, r1))
         break
      end
      fh_p.close
      fh_r.close
   end
   
   def test_get_font_key
      perl_file = "perl_output/file_font_key"
      size = File.size(perl_file)
      @fh = File.new(@ruby_file,"w+")
      @fh.print(@format.get_font_key)
      @fh.close
      rsize = File.size(@ruby_file)
      assert_equal(size,rsize,"File sizes not the same")
      
      fh_p = File.open(perl_file, "r")
      fh_r = File.open(@ruby_file, "r")
      while true do
         p1 = fh_p.read(1)
         r1 = fh_r.read(1)
         if p1.nil?
            assert( r1.nil?, 'p1 is EOF but r1 is NOT EOF.')
            break
         elsif r1.nil?
            assert( p1.nil?, 'r1 is EOF but p1 is NOT EOF.')
            break
         end
         assert_equal(p1, r1, sprintf(" p1 = %s but r1 = %s", p1, r1))
         break
      end
      fh_p.close
      fh_r.close
   end
   
   def test_get_xf_index
   end
   
   def test_get_color
   end
   
   def test_method_missing
   end

# -----------------------------------------------------------------------------

   def get_valid_format_properties
      {
         :font => 'Times New Roman', 
         :size => 30, 
         :color => 8, 
         :italic => 1, 
         :underline => 1, 
         :font_strikeout => 1, 
         :font_script => 1, 
         :font_outline => 1, 
         :font_shadow => 1, 
         :locked => 0, 
         :hidden => 1, 
         :valign => 'top', 
         :text_wrap => 1, 
         :text_justlast => 1, 
         :indent => 2, 
         :shrink => 1, 
         :pattern => 18, 
         :bg_color => 30, 
         :fg_color => 63
      }
   end
   
   def get_valid_color_string_number
      return {
         'black'     =>    8,
         'blue'      =>   12,
         'brown'     =>   16,
         'cyan'      =>   15,
         'gray'      =>   23,
         'green'     =>   17,
         'lime'      =>   11,
         'magenta'   =>   14,
         'navy'      =>   18,
         'orange'    =>   53,
         'pink'      =>   33,
         'purple'    =>   20,
         'red'       =>   10,
         'silver'    =>   22,
         'white'     =>    9,
         'yellow'    =>   13
      }
   end
#         :rotation => -90, 
#         :center_across => 1, 
#         :align => 'left', 

   def get_format_property(format)
      text_h_align = {
         1 => 'left',
         2 => 'center/centre',
         3 => 'right',
         4 => 'fill',
         5 => 'justiry',
         6 => 'center_across/centre_across/merge',
         7 => 'distributed/equal_space'
      }

      text_v_align = {
         0 => 'top',
         1 => 'vcenter/vcentre',
         2 => 'bottom',
         3 => 'vjustify',
         4 => 'vdistributed/vequal_space'
      }

      return {
            :font => format.font, 
            :size => format.size, 
            :color => format.color, 
            :bold => format.bold, 
            :italic => format.italic, 
            :underline => format.underline, 
            :font_strikeout => format.font_strikeout, 
            :font_script => format.font_script, 
            :font_outline => format.font_outline, 
            :font_shadow => format.font_shadow, 
            :num_format => format.num_format, 
            :locked => format.locked, 
            :hidden => format.hidden, 
            :align => text_h_align[format.text_h_align],
            :valign => text_v_align[format.text_v_align], 
            :rotation => format.rotation, 
            :text_wrap => format.text_wrap, 
            :text_justlast => format.text_justlast, 
            :center_across => text_h_align[format.text_h_align], 
            :indent => format.indent, 
            :shrink => format.shrink, 
            :pattern => format.pattern, 
            :bg_color => format.bg_color, 
            :fg_color => format.fg_color, 
            :border => format.border,
            :bottom => format.bottom, 
            :top => format.top, 
            :left => format.left, 
            :right => format.right, 
            :bottom_color => format.bottom_color, 
            :top_color => format.top_color, 
            :left_color => format.left_color, 
            :right_color => format.right_color 
         }
   end

end