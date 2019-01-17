#!/usr/bin/env ruby -wKU

module Archaeologist
  class GitStatLangAnalyser
    def initialize(cobj, lang)
      @c = cobj
      @lang = lang
    end

    def analyze()
      result = {}
      diff = (@c.parents.empty?) ?
        @c.diff(nil, reverse: true):
        @c.parents[0].diff(@c)
      diff.find_similar!()
      @lang.breakdown_by_file().each { |l, files|
        diff.deltas.zip(diff.patches).each { |el|
          delta = el[0]
          patch = el[1]
          if files.include?(delta.new_file[:path]) ||
              files.include?(delta.old_file[:path])
            status = result.fetch(l, {'add': 0, 'del': 0})
            status[:add] += patch.additions
            status[:del] += patch.deletions
            result[l] = status
          end
        }
      }
      return result
    end
  end
end
