#!/usr/bin/env ruby

# This script processes files generated by org-mode and does some
# transformations to make them acceptable for Jekyll.

require "rubygems"
require "hpricot"
require "yaml"
require "time"

def process_post(post, layout)
  # Check if the post already has been processed (look for YAML header)
  return nil if post[0..2] == '---'

  # Strip off everything outside the main div & extract categories
  doc = Hpricot(post)
  cats = (doc/'category').remove
  cats = cats.inner_html.split(' ').map { |i| i.downcase }

  # Extract h2 title
  h1 = (doc/'h1.title')
  #cleans the title from the post itself, so i can use as meta only
  (doc/'h1.title').remove
  # Extract timestamp
  #timestamp = (doc/'span.timestamp-wrapper').remove
  #if timestamp
  #  br = (doc/'div#text-1 p br:first')
  #  br.remove unless br.nil? # Remove <br /> right after timestamp-wrapper
  #  # I use europen date format, must do some conversion to make Time.parse work
  #  t = timestamp.search('span.timestamp').inner_html
  #  unless t.nil? or t.empty?
  #    t = t.split # 03/06/09 Wed 15:00
  #    tt = t[0].split('/') # 03/06/09
  #    tt = [tt[2], tt[1], tt[0]].join('/') # Euro -> US date
  #    if t[2] # If the timestamp includes time
  #      date = Time.parse("#{tt} #{t[2]} +2") # +2 is my local time zone offset
  #    else # only date
  #      date = Time.parse("#{tt} +2")
  #    end
  #  end
  #end

  # Extract the top outline
  post = doc.search('div#content').inner_html
  
  # Extract footnotes, if any, and downgrade h2 to h3
  footnotes = doc.search('div#footnotes').inner_html.gsub("h2", "h3")

  # Extract metadata and insert yaml
  meta = {}
  meta['layout'] = layout
  meta['title'] = h1.inner_html.gsub('&nbsp;', '').strip # insert h1 title
  meta['categories'] = cats unless cats.empty?
  #meta['date'] = date if date

  meta = meta.to_yaml + "---\n\n"

  # Return the whole thing
  return meta + post + footnotes
end

def process(glob, layout)
  Dir.glob(glob).each do |f|
    file = File.open(f, "r")
    post = process_post(file.read, layout)
    File.open(f, "w").write(post) if post
  end
end

process("#{File.dirname(__FILE__)}/_posts/*.html", "post")
process("#{File.dirname(__FILE__)}/pages/*.html", "page")
