#!/usr/bin/env ruby

require 'open3'
require 'pathname'
require 'open-uri'
require 'tmpdir'

class Changelog
  def initialize(path)
    @path = path
    populate
  end

  attr_reader :source, :version

  private

  def populate
    out, err, status = Open3.capture3('dpkg-parsechangelog', "-l#{@path}")
    unless status.success?
      $stderr.puts "dpkg-parsechangelog exited #{status.exitstatus}"
      $stderr.puts out, err
      exit 1
    end

    # See https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Version for details
    # of the version field
    if out =~ /^Source: (.+)\nVersion: (?:\d+:)?([A-Za-z0-9.+:~-]*?)(?:-[^-\n]+)?\n/
      @source = $1
      @version = $2
    else
      $stderr.puts "Couldn't parse changelog output:"
      $stderr.puts out
      exit 1
    end
  end

end

class Package
  def initialize(path)
    @build_dir = Pathname.new(File.dirname(__FILE__)).join("build").expand_path
    @pkg_dir = Pathname.new(path)
    @url = File.read(@pkg_dir.join('srcurl')).strip

    read_changelog
  end

  def make(debuild_args = nil)
    create_build_dir
    fetch_tarball
    expand_tarball
    copy_debian
    debuild(debuild_args)
  end

  private

  def read_changelog
    cl = Changelog.new(@pkg_dir.join("debian", "changelog"))
    @pkg_build_dir = @build_dir.join("#{cl.source}-#{cl.version}")
    @extracted_pkg_dir = @pkg_build_dir.join("#{cl.source}-#{cl.version}")

    zip_suffix = @url.rpartition('.')[-1]
    tar_filename = "#{cl.source}_#{cl.version}.orig.tar.#{zip_suffix}"
    @tarfile = @pkg_build_dir.join(tar_filename)
  end

  def create_build_dir
    msg = "=> creating build directory"
    if @pkg_build_dir.directory?
      puts "#{msg} [noop]"
      return
    end

    puts msg
    @pkg_build_dir.mkpath
  end

  def fetch_tarball
    msg = "=> fetching tarball"
    if @tarfile.file?
      puts "#{msg} [noop]"
      return
    end

    puts msg
    File.open(@tarfile, 'wb') do |tar|
      open(@url, 'rb') do |net|
        while buf = net.read(16 * 1024)
          tar.write buf
        end
      end
    end
  end

  def expand_tarball
    puts "=> expanding tarball"

    if @extracted_pkg_dir.exist?
      @extracted_pkg_dir.rmtree
    end

    Dir.mktmpdir("extract", @pkg_build_dir) do |tmpdir|
      output, status = Open3.capture2e('tar', '-xf', @tarfile.to_s, :chdir => tmpdir)
      unless status.success?
        $stderr.puts "Tar extraction failed : #{status.exitstatus}"
        $stderr.puts output
        exit 1
      end
      extracted_dirs = Dir["#{tmpdir}/*"]
      unless extracted_dirs.size == 1
        $stderr.puts "Multiple top-level entries in tar : #{extracted_dirs.inspect}"
        exit 1
      end
      FileUtils.mv(extracted_dirs.first, @extracted_pkg_dir)
    end
  end

  def copy_debian
    puts "=> copy new debian directory"
    src = @pkg_dir.join('debian')
    dest = @extracted_pkg_dir.join('debian')
    if dest.exist?
      puts "  orig tarball contains debian directory - deleting"
      dest.rmtree
    end
    FileUtils.cp_r(src, dest)
  end

  def debuild(debuild_args)
    puts "=> debuild"
    command = %w(debuild -S)
    if @debuild_args
      command += @debuild_args.split(/\s+/)
    end
    exec *command, :chdir => @extracted_pkg_dir

    # Never returns
  end
end

def main
  if ARGV.size != 1
    $stderr.puts "Usage: #{$0} <path_containing_debian_directory>"
    exit 2
  end

  pkg_dir = ARGV[0]
  unless File.directory?(File.join(pkg_dir, "debian"))
    $stderr.puts "ERROR: #{pkg_dir} does not contain a debian/ directory"
    exit 2
  end

  pkg = Package.new(pkg_dir)
  retcode = pkg.make(ENV['DEBUILD_ARGS'])
  puts pkg.inspect
  exit retcode
end

if __FILE__ == $0
  main
end
