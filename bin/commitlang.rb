#!/usr/bin/env ruby -wKU

require "msgpack"
require "time"
require "json/ext"
require_relative "../lib/repowalker.rb"
require_relative "../lib/analyzer.rb"
require 'parallel'

def main(repo_path, email)
  walker = RepoWalker.new(repo_path, email)
  commits = []
  walker.each { |c, lang|
    commits << [c, lang]
  }
  results = Parallel.map(commits){ |el|
    c = el[0]
    lang = el[1]
    a = GitStatLangAnalyser.new(c, lang)
    ar = a.analyze()
    { 'oid': c.oid, 'langages': ar, 'time': c.time.xmlschema }.to_msgpack
  }
  results.map! {|d| MessagePack.unpack d}
  puts(JSON.pretty_generate(results))
end

if __FILE__ == $0
  main(ARGV[0], ARGV[1])
end
