#!/usr/bin/env ruby -wKU

require 'json/ext'
require_relative "../lib/repowalker.rb"
require_relative "../lib/analyzer.rb"
require 'parallel'

def main(repo_path, email)
  walker = Archaeologist::RepoWalker.new(repo_path, email)
  commits = []
  walker.each { |c, lang|
    commits << [c, lang]
  }
  results = Parallel.map(commits){ |el|
    c = el[0]
    lang = el[1]
    a = Archaeologist::GitStatLangAnalyser.new(c, lang)
    ar = a.analyze()
    { 'oid': c.oid, 'languages': ar, 'time': c.time }.to_json
  }
  results.map! {|js| JSON.parse js}
  puts(JSON.pretty_generate(results))
end

if __FILE__ == $0
  main(ARGV[0], ARGV[1])
end
