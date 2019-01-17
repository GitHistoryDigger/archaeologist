#!/usr/bin/env ruby -wKU

require 'rugged'
require 'linguist'

class Linguist::Repository
  protected
  def compute_stats(old_commit_oid, cache = nil)
    # Patch normal compute_stats to calculate deleted files.
    return {} if current_tree.count_recursive(MAX_TREE_SIZE) >= MAX_TREE_SIZE

    old_tree = old_commit_oid && Rugged::Commit.lookup(repository, old_commit_oid).tree
    read_index
    diff = Rugged::Tree.diff(repository, old_tree, current_tree)

    # Clear file map and fetch full diff if any .gitattributes files are changed
    if cache && diff.each_delta.any? { |delta| File.basename(delta.new_file[:path]) == ".gitattributes" }
      diff = Rugged::Tree.diff(repository, old_tree = nil, current_tree)
      file_map = {}
    else
      file_map = cache ? cache.dup : {}
    end

    diff.each_delta do |delta|
      old = delta.old_file[:path]
      new = delta.new_file[:path]

      file_map.delete(old)
      next if delta.binary

      if [:added, :modified].include? delta.status
        # Skip submodules and symlinks
        mode = delta.new_file[:mode]
        mode_format = (mode & 0170000)
        next if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000

        blob = Linguist::LazyBlob.new(repository, delta.new_file[:oid], new, mode.to_s(8))

        if blob.include_in_language_stats?
          file_map[new] = [blob.language.group.name, blob.size]
        end

        blob.cleanup!
      end
      # NOTE: These lines are newly added. When the behavor of this function
      #   is changed, make sure below lines are included:
      if delta.status == :deleted
        mode = delta.old_file[:mode]
        mode_format = (mode & 0170000)
        next if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000

        blob = Linguist::LazyBlob.new(repository, delta.old_file[:oid], old, mode.to_s(8))

        if blob.include_in_language_stats?
          file_map[old] = [blob.language.group.name, blob.size]
        end

        blob.cleanup!
      end
      # NOTE: the end of the new behavior.
    end

    file_map
  end
end

module Archaeologist
  class RepoWalker
    def initialize(repo, email)
      @repo = Rugged::Repository.new(repo)
      @email = email
    end

    def each()
      walker = Rugged::Walker.new(@repo)
      already_walked = []
      @repo.branches.each { |br|
        cur_l = nil
        cur_oid = nil
        walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
        walker.push(br.target_id)
        walker.each { |c|
          cur_l = c.parents.empty? ?
            Linguist::Repository.new(@repo, c.oid) :
            Linguist::Repository.incremental(
              @repo, c.oid, cur_oid, cur_l.cache
            )
          cur_oid = c.oid
          if (c.author[:email] == @email || !@email&.size) &&
              !already_walked.include?(c.oid)
              already_walked << c.oid
            yield(c, cur_l)
          end
        }
      }
      walker.reset()
    end
  end
end
