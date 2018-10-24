#!/usr/bin/env ruby -wKU

require 'json/ext'
require_relative "../lib/repowalker.rb"
require 'parallel'

def main(repo_path, email)
  walker = RepoWalker.new(repo_path, email)
  commits = []
  walker.each { |c, lang|
    # puts c.diff(nil, reverse: true).patch
    diff = (c.parents.empty?) ?
      c.diff(nil, reverse: true):
      c.parents[0].diff(c)
    diff.find_similar!()
    # diff.deltas.zip(diff.patches).each {|el|
    #   delta = el[0]
    #   patch = el[1]
    #   puts(delta.new_file[:path])
    #   puts({"ADD": patch.additions, "DEL": patch.deletions})
    # }
    commits << [c, lang]
  }
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
