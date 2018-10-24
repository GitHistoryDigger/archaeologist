#!/usr/bin/env ruby -wKU

require 'json/ext'
require_relative "../lib/repowalker.rb"
require 'parallel'

def main(repo_path, email)
  walker = RepoWalker.new(repo_path, email)
  commits = []
  walker.each { |c, lang| commits << [c, lang] }
  results = Parallel.map(commits){ |el|
    c = el[0]
    lang = el[1]
    { 'oid': c.oid, 'langages': lang.languages }.to_json
  }
  results.map!{|s| JSON.parse s}
  puts(results.to_json)
end

if __FILE__ == $0
  main(ARGV[0], ARGV[1])
end
