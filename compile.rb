#!/bin/env ruby

require 'pathname'
require 'fileutils'

include FileUtils

unless ARGV.length == 1 && File.exists?(srcPkg = Pathname(ARGV[0]).realpath)
  puts "Usage: #{$0} <srcPackage>"
  exit 1
end


def os_type
  case RUBY_PLATFORM
  when /linux/: "linux"
  when /sparc-solaris/: "solaris"
  else raise "unsupported platform: #{RUBY_PLATFORM}"
  end
end


def sh(*args)
  unless system(*args)
    raise "failed to execute '#{args.join("' '")}' in #{pwd}"
  end
end


chdir File.dirname($0) do
  rm_rf 'tmp'
  mkdir_p 'tmp'
  chdir 'tmp' do
    sh 'tar', '-xzf', srcPkg
    chdir Dir.new('.').entries.select {|e| e != '.' && e != '..'}[0] do
      version = pwd.gsub(/^.*-(\d+\.\d+\.\d+)(-.*)?$/, '\1')
# TODO: tiff jpeg freetype aus external auspacken und referenzieren
# TODO: compiler aus /usr/local
      sh './configure', "--prefix=#{pwd}/../im", '--without-bzlib', '--without-x', '--without-jp2',
          '--without-perl', '--without-lcms', '--disable-static', '--disable-openmp'
      sh 'make'
      sh 'make', 'install'
      sh 'tar', 'cjf', "../../#{os_type}/#{version}.tbz2", '-C', '../im', '.'
    end
  end
  rm_rf 'tmp'
end
