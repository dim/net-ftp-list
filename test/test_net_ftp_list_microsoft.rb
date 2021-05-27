require 'test/unit'
require 'net/ftp/list'

class TestNetFTPListMicrosoft < Test::Unit::TestCase
  def setup
    @dir  = Net::FTP::List.parse('06-25-07  01:08PM       <DIR>          etc')
    @file = Net::FTP::List.parse('11-27-07  08:45PM                23437 README.TXT')
  end

  def test_parse_new
    assert_equal 'Microsoft', @dir.server_type, 'LIST M$ directory'
    assert_equal 'Microsoft', @file.server_type, 'LIST M$ directory'
  end

  def test_parse_dd_mm_yyyy
    dd_mm_yyyy = nil
    assert_nothing_raised do
      dd_mm_yyyy = Net::FTP::List.parse('25-06-2007  01:08PM       <DIR>          etc')
    end
    assert_equal dd_mm_yyyy.mtime.strftime('%Y-%m-%d'), '2007-06-25'
  end

  def test_parse_dd_mm_yy
    dd_mm_yy = nil
    assert_nothing_raised do
      dd_mm_yy = Net::FTP::List.parse('25-06-07  01:08PM       <DIR>          etc')
    end
    assert_equal dd_mm_yy.mtime.strftime('%Y-%m-%d'), '2007-06-25'
  end

  def test_parse_mm_dd_yy
    mm_dd_yy = nil
    assert_nothing_raised do
      mm_dd_yy = Net::FTP::List.parse('06-25-07  01:08PM       <DIR>          etc')
    end
    assert_equal mm_dd_yy.mtime.strftime('%Y-%m-%d'), '2007-06-25'
  end

  def test_default_date_mm_dd_yy
    mm_dd_yy = nil
    assert_nothing_raised do
      mm_dd_yy = Net::FTP::List.parse('01-02-03  01:08PM       <DIR>          etc')
    end
    assert_equal mm_dd_yy.mtime.strftime('%Y-%m-%d'), '2003-01-02'
  end

  def test_parse_slash_delimited_date
    slash_delimited = nil
    assert_nothing_raised do
      slash_delimited = Net::FTP::List.parse('06/25/07  01:08PM       <DIR>          etc')
    end
    assert_equal slash_delimited.mtime.strftime('%Y-%m-%d'), '2007-06-25'
  end

  def test_parse_colon_delimited_date
    colon_delimited = nil
    assert_nothing_raised do
      colon_delimited = Net::FTP::List.parse('06:25:07  01:08PM       <DIR>          etc')
    end
    assert_equal colon_delimited.mtime.strftime('%Y-%m-%d'), '2007-06-25'
  end

  def test_rubbish_lines
    assert_instance_of Net::FTP::List::Entry, Net::FTP::List.parse('++ bah! ++')
  end

  def test_ruby_microsoft_mtime
    assert_equal Time.utc(2007, 6, 25, 13, 8), @dir.mtime
    assert_equal Time.utc(2007, 11, 27, 20, 45), @file.mtime
  end

  def test_ruby_microsoft_like_dir
    assert_equal 'etc', @dir.basename
    assert @dir.dir?
    assert !@dir.file?
  end

  def test_ruby_microsoft_like_file
    assert_equal 'README.TXT', @file.basename
    assert @file.file?
    assert !@file.dir?
  end

  def test_filesize
    assert_equal 0, @dir.filesize
    assert_equal 23437, @file.filesize
  end

  def test_zero_hour
    file = Net::FTP::List.parse('10-15-09  00:34AM       <DIR>          aspnet_client')
    assert_equal Time.utc(2009, 10, 15, 0, 34), file.mtime
  end
end
