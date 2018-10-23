#!/usr/bin/env ruby -wKU

require 'json/ext'
require_relative "../lib/repowalker.rb"

def main(repo_path, email)
  walker = RepoWalker.new(repo_path, email)
  walker.each { |c, lang|
    puts({
      'oid': c.oid,
      'langages': lang.languages
    }.to_json)
  }
end

if __FILE__ == $0
  main(ARGV[0], ARGV[1])
end
