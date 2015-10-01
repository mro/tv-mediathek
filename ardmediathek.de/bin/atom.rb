#!/usr/bin/env ruby
#
# Copyright (c) 2015, Marcus Rohrmoser mobile Software
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions
# and the following disclaimer.
#
# 2. The software must not be used for military or intelligence or related purposes nor
# anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require 'uri'

BASE_URL = URI::parse 'http://linkeddata.mro.name/open/tv/mediathek/ardmediathek.de/series/'
PUBSUBHUBBUB_URL = nil

# http://ruby-doc.org/stdlib-1.8.7/libdoc/rexml/rdoc/REXML/Document.html
require 'rexml/document'
require 'open-uri'
require 'fileutils'
require 'timeout'

class REXML::Element
  def add_text_element name, txt=nil
    e = REXML::Element.new name
    e.text = txt unless txt.nil?
    self << e
  end
end
class String
  def to_xml
    self.gsub('&','&amp;')
  end
  def rfc822_to_iso8601
    ms = {'Jan'=>'01','Feb'=>'02','Mar'=>'03','Apr'=>'04','May'=>'05','Jun'=>'06','Jul'=>'07','Aug'=>'08','Sep'=>'09','Oct'=>'10','Nov'=>'11','Dec'=>'12'}
    m = /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (\d{1,2}) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (\d{4}) (\d{2}:\d{2}:\d{2}) ([+-]\d{2})(\d{2})$/.match self
    raise "Not a RFC 822 date: '#{self}'" if m.nil?
    "#{m[4]}-#{ms[m[3]]}-#{m[2]}T#{m[5]}#{m[6]}:#{m[7]}"
  end
end

# Workaround because out-of-the-box ruby on Mountain Lion doesn't know about JSON.
require 'yaml'
def decode_json_via_yaml json
  # http://stackoverflow.com/a/26493639
  # https://en.wikipedia.org/w/index.php?title=JSON&oldid=682239394#YAML
  YAML.load json.gsub(':', ': ').gsub(',', ', ')
end
def decode_json_via_yaml_postprocess s
  s.gsub(', ', ',').gsub(': ', ':')
end

def fetch_mp4_url p, entryId, quality
  $stderr.write '^'
  begin
    js = decode_json_via_yaml( Timeout::timeout(10){open(URI::parse("http://www.ardmediathek.de/play/media/#{entryId}"))}.read )

    p.add_text_element 'tl:durationInt', js['_duration'] unless js['_duration'].nil?

    img = js['_previewImage']
    unless img.nil?
      p.add_element('link', {'rel'=>'enclosure', 'type'=>'image/jpeg', 'href'=>URI::parse(decode_json_via_yaml_postprocess(img)).to_s})
    end

    ret = []
    js['_mediaArray'].each do |media|
      media['_mediaStreamArray'].each do |mediaStream|
        [mediaStream['_stream']].flatten.each do |url|
          next if url.end_with? '.f4m'
          url = decode_json_via_yaml_postprocess(url)
          begin
            mp4url = URI::parse url.gsub('&amp;','&')
            ret << {'href'=>mp4url, 'rel'=>'enclosure', 'type'=>'video/mp4', 'title'=>"q-#{mediaStream['_quality']}"}
          rescue URI::InvalidURIError => e
            # $stderr.puts "Strange URI: '#{url}'"
          end
        end
      end
    end
    ret.sort{|a,b| b['title'] <=> a['title'] }.uniq.each{|atts| p.add_element 'link', atts}
  rescue Timeout::Error
  end
end

if 1 == ARGV.count && ('-h' == ARGV[0])
then
  puts <<EOF
- Fetch ardmediathek.de RSS feeds,
- amend preview image and video enclosure urls,
- add duration,
- convert to Atom,
- re-use existing Atom feeds from previous runs to reduce network traffic.

Example:

  $ ruby #{__FILE__} 1430 4326 bcastId=15757542 'http://www.ardmediathek.de/tv/Tatort/Die-letzte-Wiesn-Video-tgl-ab-20-Uhr/Das-Erste/Video?documentId=30678476&bcastId=602916'

EOF
  exit
end

def process_feed bcastId
  # load existing Atom (result) feed
  bcastId = bcastId.to_s
  atom_file_name = File.join('pub','series',bcastId,'feed.atom')
  old_atom_index = {}
  old_atom = begin
    feed = File.open(atom_file_name, 'r'){|f| REXML::Document.new(f)}
    feed.elements.each('/feed/entry/id'){|e| old_atom_index[ e.text ] = e.parent}
  rescue
  end

  # load RSS (cached source) feed
  rss_uri = URI::parse("http://www.ardmediathek.de/export/rss/id=#{bcastId}")
  rss_file = File.join('cache','series',bcastId,'feed.rss')  
  $stderr.write "\n#{rss_file} "
  current_rss = begin
    File.open(rss_file, 'r'){|f| REXML::Document.new(f)}
  rescue
  end
  current_rss = begin
    $stderr.write "#{rss_uri} "
    REXML::Document.new( Timeout::timeout(20){ open(rss_uri) } )
  rescue
    return nil
  end if current_rss.nil?

  atom_uri = BASE_URL + (bcastId + '/feed.atom')
  new_atom = <<ATOM_XML
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:media="http://search.yahoo.com/mrss/" xmlns:tl="http://purl.org/NET/c4dm/timeline.owl#" xml:lang="de">
  <updated>1970-01-01T00:01:02Z</updated>
  <generator>https://github.com/mro/tv-mediathek/tree/master/ardmediathek.de/bin/atom.rb</generator>
  <link rel='related' href='../index.opml' title='Feed List'/>
</feed>
ATOM_XML
  new_atom = REXML::Document.new new_atom
  new_feed = new_atom.root
  new_feed.add_text_element 'title', current_rss.elements['/rss/channel/title'].text
  new_feed.add_text_element 'id', (BASE_URL + bcastId)
  new_feed.add_element('author').add_text_element('name', current_rss.elements['/rss/channel/copyright'].text)
  new_feed.add_element 'link', {'rel'=>'self', 'type'=>'application/atom+xml', 'href'=>atom_uri}
  new_feed.add_element 'link', {'rel'=>'alternate', 'type'=>'application/rss+xml', 'href'=>rss_uri}
  new_feed.add_element 'link', {'rel'=>'alternate', 'type'=>'text/html', 'href'=>URI::parse("http://www.ardmediathek.de/tv/.../Sendung?documentId=#{bcastId}&bcastId=#{bcastId}")}
  new_feed.add_element 'link', {'rel'=>'hub', 'href'=>PUBSUBHUBBUB_URL} unless PUBSUBHUBBUB_URL.nil?
  current_rss.elements.each('/rss/channel/item') do |item|
    $stderr.write '.'
    # clone RSS entry
    url = URI::parse(item.elements['link'].text)
    entryId = /documentId=(\d+)/.match(url.to_s)[1]
    tag = "tag:ardmediathek.de,2015:documentId=#{entryId}"
    new_entry = new_feed.add_text_element 'entry'
    new_entry.add_element 'link', {'rel'=>'alternate', 'type'=>'text/html', 'href'=>url}
    new_entry.add_text_element 'id', tag
    new_entry.add_text_element 'title', item.elements['title'].text
    new_entry.add_text_element 'summary', item.elements['description'].text
    new_entry.add_text_element 'updated', item.elements['pubDate'].text.rfc822_to_iso8601

    # re-use old atom entry/link[@rel='enclosure']
    encl = nil
    old_entry = old_atom_index[tag]
    unless old_entry.nil?
      ['link[@rel="enclosure"]', 'tl:durationInt'].each do |keep|
        old_entry.elements.each(keep){|o| new_entry << (encl = o)}
      end
      old_entry.remove
    end
    fetch_mp4_url(new_entry, entryId, 3) if encl.nil?
  end

  FileUtils.mkdir_p File.dirname(atom_file_name)
  File.open(atom_file_name,'w'){|f| new_atom.write(f)}
end

ARGV.each.collect do |id_raw|
  m = /cache\/series\/([0-9]+)\/feed.rss/.match(id_raw)
  if m.nil?
    m = /^(?:.*?bcastId=)?([0-9]+).*?/.match(id_raw)
    raise "What a strange id: '#{id_raw}'" if m.nil?
  end
  m[1].to_i
end.sort.uniq.each{|id| process_feed id}
