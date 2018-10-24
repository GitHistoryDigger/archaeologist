#!/usr/bin/env ruby -wKU

class GitStatLangAnalyser
  def initialize(cobj, lang)
    @c = cobj
    @lang = lang
  end

  def analyze()
    result = {}
    result.default = [0, 0]
    diff = @c.parents[0].diff(@c)
    diff.find_similar!()
    @lang.brekdown_by_file().each { |l, files|
      diff.each_delta { |d|
        if files.include?(d.new_file["path"])
        end
      }
    }
  end
end
