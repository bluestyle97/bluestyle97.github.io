# based on https://distresssignal.org/busting-css-cache-with-jekyll-md5-hash
# https://gist.github.com/BryanSchuetz/2ee8c115096d7dd98f294362f6a667db
module Jekyll
  module CacheBust
    class CacheDigester
      require 'digest/md5'
      require 'pathname'

      # digest cache, shared for the whole build; see directory_files_content
      @@directory_contents = {}

      attr_accessor :file_name, :directory

      def initialize(file_name:, directory: nil)
        self.file_name = file_name
        self.directory = directory
      end

      def digest!
        [file_name, '?', Digest::MD5.hexdigest(file_contents)].join
      end

      private

      def directory_files_content
        # Called once per page (~100 of them) while the sass tree is ~1.7 MB, so
        # memoise the concatenation, keyed on the newest mtime so that edits during
        # `jekyll serve` still produce a fresh digest.
        files = Dir[File.join(directory, '**', '*')].reject { |f| File.directory?(f) }.sort
        stamp = files.map { |f| File.mtime(f).to_i }.max
        @@directory_contents[[directory, stamp]] ||= files.map { |f| File.binread(f) }.join
      end

      def file_content
        local_file_name = file_name.slice((file_name.index('assets/')..-1))
        File.read(local_file_name)
      end

      def file_contents
        is_directory? ? file_content : directory_files_content
      end

      def is_directory?
        directory.nil?
      end
    end

    def bust_file_cache(file_name)
      CacheDigester.new(file_name: file_name, directory: nil).digest!
    end

    def bust_css_cache(file_name)
      # `_sass`, not `assets/_sass`: the latter does not exist, so the glob matched
      # nothing and every build emitted md5("") = d41d8cd98f00b204e9800998ecf8427e.
      # The stylesheet URL never changed, so browsers kept serving stale CSS.
      CacheDigester.new(file_name: file_name, directory: '_sass').digest!
    end
  end
end

Liquid::Template.register_filter(Jekyll::CacheBust)